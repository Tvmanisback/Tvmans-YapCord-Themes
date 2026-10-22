# YapCord Themes API contract

The GitHub Pages frontend is static. Set `window.YAPCORD_API_BASE` in a small `config.js` loaded before the main script, or replace the empty value in `index.html`, with your backend's HTTPS base URL.

## Required endpoints

- `GET /api/auth/me` → `{ "user": { "id": "...", "username": "...", "email": "..." } }`; unauthenticated requests may return 401.
- `POST /api/auth/signup` JSON `{ "email": "...", "password": "...", "username": "..." }` → `{ "user": {...} }`
- `POST /api/auth/login` JSON `{ "email": "...", "password": "..." }` → `{ "user": {...} }`
- `POST /api/auth/logout` → success JSON.
- `GET /api/themes` → `{ "themes": [{ "id": "...", "name": "...", "description": "...", "author": "...", "downloadUrl": "https://..." }] }`
- `POST /api/themes` multipart form fields `name`, `description`, and `file` (the `.theme.css` file) → success JSON.

## Backend requirements

Use HTTPS, validate and limit files server-side (the frontend's 500 KB limit is not a security boundary), verify the file suffix and CSS content, rate-limit signup/login/uploads, and enforce authentication/authorization server-side. Store passwords with a modern password hash (never plaintext). Prefer secure, HttpOnly, SameSite cookies; if using cookies cross-origin, configure CORS for this exact Pages origin and `Access-Control-Allow-Credentials: true`. Never put service-role keys or private secrets in this frontend. Consider sanitizing CSS and moderating reports before making uploads public.

The UI can validate and download a selected file locally without a backend, but public accounts and community uploads require one.
