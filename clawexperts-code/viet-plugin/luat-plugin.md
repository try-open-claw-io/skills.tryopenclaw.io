# Luật viết plugin sổ dữ liệu — viết cho OpenClaw 2026.9.7

Plugin chạy BÊN TRONG gateway, chung tiến trình với mọi agent trên instance. Một dòng code hỏng
có thể làm chậm hay lỗi cả instance — vì thế khuôn đã làm sẵn phần khó, bạn chủ yếu KHAI BÁO.

## Cấu trúc (khuôn chép vào `agent-<id>/plugins/<id>/`)

| Tệp | Ai viết |
|---|---|
| `src/collections.ts` | BẠN — khai báo dữ liệu |
| `src/requirements.ts` | bạn, khi charter mục 5 cần secret hay ứng dụng |
| `src/tools-custom.ts` | bạn, chỉ khi thật cần tool riêng (hiếm) |
| `src/config.ts`, `openclaw.plugin.json`, `package.json` | công cụ — đừng sửa |
| `src/store.ts`, `src/secrets.ts`, `src/connectors.ts`, `src/tools.ts`, `src/text.ts`, `src/types.ts`, `index.ts`, test của khuôn | khuôn — đừng sửa: `ce_build` chép lại bản khuôn mới mỗi lần build |

## Khai báo dữ liệu (`src/collections.ts`)

```ts
import type { Collections } from "./types.ts";

export const COLLECTIONS: Collections = {
  don: {
    label: "đơn hàng",
    fields: {
      khach: { type: "text", label: "Tên khách", required: true },
      sdt: { type: "text", label: "Số điện thoại" },
      so_luong: { type: "number", label: "Số lượng", required: true },
      gia: { type: "number", label: "Giá", hint: "số, vd 250000 — không viết 250k" },
      thanh_tien: { type: "number", label: "Thành tiền", compute: (r) => Number(r.so_luong ?? 0) * Number(r.gia ?? 0) },
      trang_thai: { type: "enum", label: "Trạng thái", values: ["chờ xử lý", "đã giao", "huỷ"], default: "chờ xử lý" },
      ngay_giao: { type: "date", label: "Ngày giao" },
    },
  },
};
```

- Khoá loại: chữ thường không dấu, số, gạch dưới, ≤ 16 ký tự (`don`, `khach`, `cham_cong`).
- Khoá trường: chữ thường không dấu, số, gạch dưới, ≤ 30 ký tự. Cấm: `id`, `tu_khoa`, `loc`, `tu_ngay`, `den_ngay`, `toi_da`, `nhom_theo`.
- `type`: `text` · `number` · `date` (YYYY-MM-DD) · `enum` (phải có `values`; `default` phải nằm trong `values`).
- `label`: tên người dùng hiểu — agent đọc nó trong mọi câu trả lời của tool.
- `required: true` chỉ cho trường mà thiếu thì bản ghi vô nghĩa. Tool trả 🔴 kèm tên trường, agent hỏi lại người dùng.
- `hint`: gợi ý cách điền cho model (đơn vị, định dạng).
- `compute`: trường tự tính lúc lưu/sửa (thành tiền, tổng điểm). Không `required`. Model không điền.
- Ngày giờ lưu đã có sẵn ở mọi bản ghi (hiện ở đầu mỗi dòng, `_tim`/`_tong` lọc và nhóm theo nó).
  KHÔNG thêm trường "ngày ghi nhận", "ngày tạo". Chỉ thêm trường `date` cho một ngày KHÁC ngày lưu:
  ngày giao, ngày hẹn, ngày chi thực tế khi người dùng ghi bù.
- `_tong` cộng MỌI trường số. Trường như đơn giá cũng bị cộng — khi trả lời "tổng tiền" hãy dùng trường
  tự tính (thành tiền), không dùng tổng đơn giá.
- Thêm/bớt trường KHÔNG cần đổi bảng: dữ liệu lưu dạng JSON. Đổi khoá một trường = trường mới; dữ liệu cũ nằm ở khoá cũ.
- Mỗi loại sinh đúng 5 tool: `<prefix>_<loại>_them` · `_tim` · `_sua` · `_xoa` (xoá mềm) · `_tong` (đếm, cộng trường số, nhóm theo ngày hay theo trường). Ngày theo giờ Việt Nam.

## Secret và ứng dụng (`src/requirements.ts`)

```ts
import type { ConnectorDecl, SecretDecl } from "./types.ts";

export const SECRETS: SecretDecl[] = [
  { name: "SHOPEE_API_KEY", label: "API key Shopee", howTo: "Shopee Partner → Ứng dụng → Khoá API" },
];
export const CONNECTORS: ConnectorDecl[] = [{ app: "googlesheets", label: "Google Sheets" }];
```

- Chỉ TÊN + chỗ lấy. KHÔNG BAO GIỜ viết giá trị secret vào bất kỳ tệp nào (`ce_build` từ chối chuỗi trông như secret).
- Có `SECRETS` ⇒ khuôn sinh `<prefix>_secret_dat` (agent lưu key người dùng gửi trong chat vào
  `uc-data/<ws>/secrets.json`, quyền 600, dùng được NGAY, không restart) và `<prefix>_secret_thieu`.
- Có `CONNECTORS` ⇒ sinh `<prefix>_ung_dung_kiem`: báo ứng dụng nào chưa nối và chỉ đúng Settings → Ứng dụng.
  `app` là mã viết thường: `gmail`, `googlesheets`, `googledrive`, `googlecalendar`…
- Bundle không mang secret: người nhận nhập key CỦA HỌ trong chat lần đầu dùng.

## Tool riêng (`src/tools-custom.ts`) — chỉ khi 5 tool sinh sẵn không làm được

- Tên bắt đầu bằng `TOOL_PREFIX` (import từ `./config.ts`), ≤ 64 ký tự, chỉ `a-z A-Z 0-9 _ -`.
- `execute(toolCallId, args)` — args là tham số THỨ HAI. Trả `{ content: [{ type: "text", text }], details }`; model chỉ đọc `content`, nên mọi thứ agent cần nói lại phải nằm trong `text`.
- Mở đầu `text` bằng 🟢 khi đã ghi xong, 🔴 khi từ chối — kèm TÊN trường phải sửa.
- Đọc/ghi qua `openStore()` và các hàm của `src/store.ts`. KHÔNG mở tệp nào ngoài kho của agent.
- Cần secret: ``requireSecret(SECRETS[i], `${TOOL_PREFIX}_secret_dat`)`` từ `./secrets.ts` — đọc lại tệp ở MỖI lần
  gọi; thiếu thì trả nguyên câu `text` nó đưa (🔴 + chỗ lấy). KHÔNG đọc `process.env`, KHÔNG giữ key trong biến
  toàn cục.
- Gọi mạng CHỈ tới đúng dịch vụ của secret/ứng dụng đã khai, dùng `fetch` có `AbortController` (≤ 20 giây),
  và KHÔNG đưa key vào chữ trả về hay log.
- KHÔNG `child_process`, KHÔNG `setInterval` (plugin `register()` chạy hai lần trong gateway: mọi bộ đếm giờ sẽ nhân đôi).
- KHÔNG chặn tiến trình: không vòng lặp nặng, không `*Sync` trên tệp lớn.
- Viết test cho tool riêng trong `src/*.test.ts` bằng `node:test` + `node:assert/strict`, đặt tên tệp KHÁC test của
  khuôn (`tools.test.ts`, `requirements.test.ts`, `collections.test.ts`, `trial.test.ts`) — tệp trùng tên bị chép đè.
- Bản ghi lưu bằng tool `_them` trong phiên chạy thử (`agent:<id>:eval:<ca>:<lượt>`) mang dấu "thử" để `ce_test_clean`
  xoá đúng chúng. Tool riêng KHÔNG ghi vào sổ: ghi ngoài `_them` thì bản ghi thử không có dấu.

## TypeScript chạy thẳng bằng Node (không có Bun trong container)

- Import kèm đuôi `.ts`: `import { openStore } from "./store.ts";`
- Chỉ cú pháp "xoá kiểu là chạy": KHÔNG `enum`, `namespace`, tham số constructor kiểu `constructor(private x)`. Dùng object `as const` thay `enum`.

## Tài liệu đúng bản đang chạy

`/app/docs` trong container (đã xác minh 08/10 trên image tryopenclaw 2026.9.7: `openclaw` là wrapper gọi
`/app/openclaw.mjs`). Ghi chú phát hành: `/app/docs/releases/<bản>.md` + `index.md`; image không có
CHANGELOG.md. Luật này viết cho bản ghi ở dòng đầu — máy chạy bản mới hơn thì `ce_health` cảnh báo; tra
`/app/docs/plugins/` trước khi viết tool riêng.

## `ce_build` làm gì (để hiểu log lỗi)

1. Làm mới tệp khuôn từ bản khuôn đi kèm ClawExperts Code đang cài (log "Làm mới khuôn: …"). Không đụng
   `collections.ts`, `requirements.ts`, `tools-custom.ts`, `config.ts`, `package.json`, `openclaw.plugin.json`
   và test riêng. Sửa tay tệp khuôn sẽ mất ở lần build sau.
2. Chặn khi còn dấu CE_FILL hay có chuỗi trông như secret.
3. `npm install` chỉ khi `package.json` có `dependencies` (thư viện npm được gói vào `dist`).
4. `node --test "src/**/*.test.ts"` — gồm test khói chạy trên khai báo THẬT của bạn. Đỏ thì dừng.
5. Đọc danh sách tool, ghi `contracts.tools` (gateway bỏ im lặng tool không khai ở đây).
6. esbuild → `dist/<id>.zip` (layout `package/…`). Chỉ thay zip cũ khi mọi bước trên xanh.
7. Viết mục "Công cụ" (AGENTS.md), "Giới hạn của bản này" (SOUL.md) và "Khối Dữ liệu" của skill hướng
   dẫn dùng (`agent-<id>/skills/huong-dan-su-dung/SKILL.md`). Tool sổ (đuôi `_them/_tim/_sua/_xoa/_tong`)
   ghi vào "việc làm được với sổ"; tool riêng ghi vào "việc khác làm được".

Gateway 9.7 nạp plugin mới hoặc bản thay thế mà không restart; bản thay thế nạp lỗi thì gateway tự
giữ bản cũ. Plugin MỚI nạp lỗi thì không có bản cũ để giữ — vì vậy test phải xanh trước khi cài.
