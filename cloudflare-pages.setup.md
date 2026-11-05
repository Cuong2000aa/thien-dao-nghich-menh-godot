# Cloudflare Pages — Thiên Đạo Nghịch Mệnh (Godot Web)

Cloudflare **không build được Godot** trong form “Build command / Output directory”.
Export Web chạy trên **GitHub Actions**, rồi Wrangler upload lên Cloudflare.

## A. Trên Cloudflare (dashboard)

1. Workers & Pages → **Create** → Pages → **Upload assets** (Direct Upload), **không** chọn “Connect to Git” nếu chỉ muốn tránh lỗi `web` folder.
2. Project name: `thien-dao-nghich-menh-godot` (trùng workflow).
3. Nếu đã Connect to Git và bị fail:
   - Settings → Builds & deployments → **Disconnect** repo, **hoặc**
   - Để Build command trống và đừng trông chờ output `web` — dùng workflow bên dưới.

### Nếu vẫn giữ Connect to Git (không khuyến nghị)

| Field | Value |
| --- | --- |
| Framework preset | None |
| Build command | `exit 0` |
| Build output directory | *(để trống / không dùng — sẽ fail vì không có file Godot)* |

→ Cách này **không đủ**. Phải dùng GitHub Actions deploy.

## B. Token Cloudflare

1. [API Tokens](https://dash.cloudflare.com/profile/api-tokens) → Create Token  
   Template **Edit Cloudflare Workers** (hoặc custom: Account → Cloudflare Pages → Edit).
2. Copy **Account ID** (sidebar Workers & Pages).

## C. GitHub Secrets

Repo `Cuong2000aa/thien-dao-nghich-menh-godot` → Settings → Secrets and variables → Actions:

- `CLOUDFLARE_API_TOKEN`
- `CLOUDFLARE_ACCOUNT_ID`

## D. Deploy

Push `tdnm-web` hoặc Actions → **cloudflare pages** → Run workflow.

Link dạng: `https://thien-dao-nghich-menh-godot.pages.dev`
