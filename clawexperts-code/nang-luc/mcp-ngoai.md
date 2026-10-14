# Khuôn mcp-ngoai — gọi MCP server ngoài, viết cho OpenClaw 2026.9.9

Agent gọi tool của một MCP server ngoài (dịch vụ có MCP: tra cứu, nghiệp vụ nội bộ, hệ thống của công ty người dùng) như
tool của chính nó. OpenClaw nói MCP sẵn bằng CONFIG (`mcp.servers`) — KHÔNG viết plugin-tool bọc lại, không viết skill
hướng dẫn curl. Repo đã chạy thật cách này ở `ws-ce-ops` (Operator MCP của nền tảng).

## Áp khuôn

`ce_capability_add({ws, capability: "mcp-ngoai"})` chép `install/mcp.json` (còn CE_FILL). Viết từ charter mục 10:

```json
{ "servers": [ { "ten": "ty-gia", "url": "https://api.vi-du.vn/mcp", "can_khoa": true, "include": ["getRate"] } ] }
```

- `ten`: chữ thường không dấu, gạch ngang, ≤ 20 ký tự. Tên server thật = `<tiền tố tool của agent>-<ten>`.
- `url`: http(s) CÓ đường dẫn (OpenClaw từ chối `/`), transport streamable-http.
- `can_khoa`: server cần khoá. Mặc định khoá vào `Authorization: Bearer <khoá>`; dịch vụ dùng header khác thì thêm
  `"header": "x-api-key", "tien_to": ""`.
- `include` (nên có): đúng các tool agent được dùng — server lớn có hàng chục tool, mỗi tool tốn chỗ trong ngữ cảnh.
- `ce_package` kiểm tệp (sai thì từ chối, nêu server + trường).
- Công cụ của agent có `<tiền tố>-*` — mở ĐÚNG các server của agent này. KHÔNG thêm `bundle-mcp`: nhóm đó mở mọi MCP
  của máy, kể cả connector Google của người khác.

## Sau khi cài

Server ghi LÚC CHẠY: chủ dán khoá trong Chat với agent ⇒ agent gọi `<prefix>_mcp_noi({ten, khoa})` ⇒ server vào
`mcp.servers`, dùng được từ lượt sau (không khởi động lại máy). `<prefix>_mcp_trang_thai` xem đã nối chưa. Gỡ agent thì
`pre-uninstall` gỡ server của nó.

## Viết gì vào prompt của agent (AGENTS.md, mục MỖI LƯỢT)

- Tên tool của server: `<tên server>__<tên tool>` (vd `binhnt_ty_gia-ty-gia__getRate`). Mô tả việc của từng tool theo
  charter — agent đọc mô tả tool server trả về, nhưng câu "khi nào dùng" phải do bạn viết.
- Tool server trả lỗi 401 ⇒ nói thẳng "khoá MCP sai hay hết hạn — dán khoá mới", không gọi chung chung là "lỗi kết nối".
- Không bao giờ nhắc lại khoá; khoá chỉ dán trong Chat với chủ, không qua kênh khách.

## Ws mẫu

`use-case/ws-ce-ops` — `openclaw.ws-ce-ops.json` khối `mcp.servers.ce-ops-operator` (đọc `$comment`: tiền tố Bearer,
server của chung máy). Bẫy: `bay.md` §MCP ngoài.
