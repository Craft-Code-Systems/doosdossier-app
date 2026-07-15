/**
 * POST /api/lead — stores scan leads in D1 (binding: DB).
 * Intentionally minimal: email + answers + statuses, no IP, no UA,
 * no cookies (see Decision 0006 spirit: data minimization everywhere).
 */
const EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

function json(body, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "content-type": "application/json; charset=utf-8" },
  });
}

export async function onRequestPost({ request, env }) {
  let data;
  try {
    data = await request.json();
  } catch {
    return json({ error: "Ongeldige aanvraag." }, 400);
  }

  const email = String(data.email || "").trim().toLowerCase();
  if (!EMAIL_RE.test(email) || email.length > 254) {
    return json({ error: "Ongeldig e-mailadres." }, 400);
  }

  const answers = JSON.stringify(data.answers ?? {}).slice(0, 4000);
  const statuses = JSON.stringify(data.statuses ?? {}).slice(0, 1000);

  try {
    await env.DB.prepare(
      `INSERT INTO leads (email, answers, statuses)
       VALUES (?1, ?2, ?3)
       ON CONFLICT(email) DO UPDATE
         SET answers = ?2, statuses = ?3, updated_at = datetime('now')`
    ).bind(email, answers, statuses).run();
  } catch (e) {
    return json({ error: "Opslaan lukte niet. Probeer het opnieuw." }, 500);
  }

  return json({ ok: true });
}

// Explicitly reject everything except POST.
export async function onRequest({ request }) {
  if (request.method === "POST") return; // falls through to onRequestPost
  return json({ error: "Method not allowed" }, 405);
}