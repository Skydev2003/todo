import { createClient } from 'jsr:@supabase/supabase-js@2'
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
// ✅ เปลี่ยนมาใช้ Library มาตรฐานของ Google ผ่าน npm
import { GoogleAuth } from 'npm:google-auth-library@9'

console.log("🚀 Function notify-todos started!")

serve(async (req) => {
  try {
    // 1. Setup Supabase Client
    const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';
    const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';
    const supabase = createClient(supabaseUrl, supabaseKey);

    // 2. ดึงค่า Service Account
    const serviceAccountStr = Deno.env.get('FIREBASE_SERVICE_ACCOUNT');
    if (!serviceAccountStr) {
      throw new Error('Missing FIREBASE_SERVICE_ACCOUNT configuration');
    }
    const serviceAccount = JSON.parse(serviceAccountStr);

    // 3. ✅ ขอ Access Token จาก Google (วิธีใหม่ ใช้ GoogleAuth)
    const auth = new GoogleAuth({
      credentials: {
        client_email: serviceAccount.client_email,
        private_key: serviceAccount.private_key,
      },
      scopes: ['https://www.googleapis.com/auth/firebase.messaging'],
    });

    const client = await auth.getClient();
    const accessToken = await client.getAccessToken();
    const token = accessToken.token; // ได้ Token ตัวจริงมาใช้

    if (!token) throw new Error('Failed to generate access token');

    // 4. หา Todos ที่ถึงเวลาแล้ว
    const now = new Date().toISOString();
    const { data: todos, error } = await supabase
      .from('todos')
      .select('id, title, description, user_id')
      .lte('reminder_time', now)    
      .eq('is_completed', false)   
      .eq('is_notified', false);    

    if (error) throw error;

    console.log(`🔎 Found ${todos?.length ?? 0} todos to notify.`);

    const results = [];

    // 5. วนลูปส่งแจ้งเตือน
    if (todos && todos.length > 0) {
      for (const todo of todos) {
        // หา FCM Token ของ User
        const { data: tokens } = await supabase
          .from('user_fcm_tokens')
          .select('fcm_token')
          .eq('user_id', todo.user_id);

        if (tokens && tokens.length > 0) {
          for (const t of tokens) {
            // ยิง FCM
            await fetch(`https://fcm.googleapis.com/v1/projects/${serviceAccount.project_id}/messages:send`, {
              method: 'POST',
              headers: {
                'Authorization': `Bearer ${token}`, // ✅ ใช้ token จาก GoogleAuth
                'Content-Type': 'application/json',
              },
              body: JSON.stringify({
                message: {
                  token: t.fcm_token,
                  notification: {
                    title: "⏰ ถึงเวลาแล้ว: " + todo.title,
                    body: todo.description ?? "อย่าลืมทำรายการนี้นะ!",
                  },
                  android: {
                    priority: "high",
                    notification: { channel_id: "high_importance_channel" }
                  }
                }
              }),
            });
          }
        }
        // อัปเดตสถานะว่าแจ้งแล้ว
        await supabase.from('todos').update({ is_notified: true }).eq('id', todo.id);
        results.push(todo.id);
      }
    }

    return new Response(JSON.stringify({ success: true, processed: results }), {
      headers: { "Content-Type": "application/json" },
    });

  } catch (err) {
    console.error("Error:", err.message);
    return new Response(JSON.stringify({ error: err.message }), {
      status: 500, headers: { "Content-Type": "application/json" },
    });
  }
});