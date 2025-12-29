const { createClient } = window.supabase;

export const supabase = createClient(
    "https://redvymknnxehwveyzmyw.supabase.co",
    "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJlZHZ5bWtubnhlaHd2ZXl6bXl3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjYwNzM5NTMsImV4cCI6MjA4MTY0OTk1M30.XcdT2RYq5tKFZziLkOO6mcQZzAUHMJf5ORzkZa2-La8"
);

window.supabaseInstance = supabase;
