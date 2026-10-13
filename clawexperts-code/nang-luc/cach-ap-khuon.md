# Áp khuôn năng lực — viết cho OpenClaw 2026.9.9

Khuôn năng lực = phần TẤT ĐỊNH của một năng lực (kênh, lịch, ứng dụng, chạy nền), đã chạy thật ở các use-case của
ClawExperts: khoá cấu hình, lệnh vòng đời, nguồn plugin. Bạn áp khuôn rồi chỉ viết phần theo charter (dấu CE_FILL).
Dựng tay từ trang trắng là dính lại đúng các bẫy team đã trả giá.

## `ce_capability_add({ws, capability})` làm gì

1. **Gộp overlay** của khuôn vào `openclaw.<ws>.json` (chỗ giữ `{{WS}}`, `{{AGENT_ID}}`, `{{PLUGIN_ID}}`,
   `{{TOOL_PREFIX}}` đã thay bằng tên của agent): object gộp sâu, mảng hợp không trùng; một giá trị đơn KHÁC giá
   trị project đang có thì TỪ CHỐI và nêu đường khoá — sửa giá trị đó hay bỏ khuôn kia, đừng sửa khuôn.
2. **Chép nguồn plugin** của khuôn vào `agent-<id>/plugins/<id>/` (chưa có plugin thì dựng khung trước) và ghi module
   vào sổ đăng ký `src/capabilities.ts`. Nguồn chỉ chép MỘT lần: áp lại không đè phần bạn đã viết.
3. **Ghi tên khuôn** vào `install/capabilities.json` (đi theo Bundle).
4. **Sinh lại** từ danh sách khuôn đã áp:
   - `install/config.sh`: `post-install` (thêm plugin vào `plugins.allow` nếu máy có allowlist, rồi bước sau cài của
     từng khuôn), mỗi lệnh con của khuôn một nhánh, `help` liệt kê. Thân lệnh con là hàm `cap_<tên_lệnh>`.
   - công cụ của agent: `tools.profile: "minimal"`, `alsoAllow` = `read` + plugin của agent + công cụ các khuôn cần.
     Agent không bao giờ có `exec`.
5. Trả: tệp còn phải viết (CE_FILL), khoá overlay vừa thêm, lệnh con, công cụ của agent.

Áp lại cùng khuôn: không đổi byte nào. Khuôn được sửa sau (bản CE Code mới): `ce_build` / `ce_package` sinh lại
config.sh, công cụ và sổ đăng ký — agent cũ nhận bản mới ở lần đóng gói kế tiếp.

## Module khuôn trong plugin

Mỗi khuôn có plugin chép một module `src/cap/<khuôn>.ts`, export mặc định:

```ts
import type { CapabilityModule } from "../types.ts";
const mod: CapabilityModule = {
  name: "<khuôn>",
  tools: ({ sessionKey }) => [ /* ToolDef, tên bắt đầu bằng TOOL_PREFIX */ ],
  start: (api) => { /* việc nền: chỉ chạy trong tiến trình gateway */ },
};
export default mod;
```

- `tools` vào danh mục tool (`contracts.tools`, mục Công cụ của AGENTS.md) như tool sổ dữ liệu; chỉ agent của plugin
  thấy chúng.
- `start` chỉ được gọi trong gateway, KHÔNG gọi khi lệnh CLI nạp plugin. `register()` chạy HAI lần ⇒ `start` cũng hai
  lần: giành lượt ở mức kho (luật ở `luat-plugin.md` của skill `viet-plugin`, §Chạy nền).
- Test của module: `src/cap/<khuôn>.test.ts` (node:test) — `ce_build` chạy cùng test của khuôn sổ.

## Khuôn có

| Năng lực (charter mục 10) | Khuôn | Bài |
|---|---|---|
| Lưu, tra dữ liệu | `so-du-lieu` (cũng là `ce_plugin_add`) | `luat-plugin.md` của skill `viet-plugin` |

Năng lực chưa có dòng ở đây = chưa có khuôn sẵn: nói thật với người dùng, không tự dựng tay.
