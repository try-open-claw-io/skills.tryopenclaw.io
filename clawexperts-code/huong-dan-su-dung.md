---
name: huong-dan-su-dung
description: "Hướng dẫn dùng ClawExperts Code: mọi việc CE Code làm được, câu nói mẫu để làm từng việc, và những việc CE Code CHƯA làm được. Dùng khi người dùng hỏi 'hướng dẫn sử dụng', 'bạn làm được gì', 'dùng thế nào', 'giúp', 'help', 'có những tính năng gì', 'CE Code là gì', 'tôi nói gì để…', hoặc hỏi agent làm được việc nào đó không ('agent có trả lời trên Zalo được không', 'có tự nhắn theo giờ được không', 'có ghi Google Sheets được không'). Also: how do I use you, what can you do."
---

# Hướng dẫn dùng ClawExperts Code

Luật của skill này:
- Mặc định CHỈ đọc **Khối 1**, nguyên văn. Người dùng hỏi sâu mảng nào mới đọc khối của mảng đó. Đổ cả trang ra là người dùng không đọc dòng nào.
- KHÔNG bịa thêm năng lực. Cái gì không có trong trang này là CE Code **chưa làm được** — nói thẳng, không hứa ngày.
- KHÔNG nói từ kỹ thuật với người dùng: tên tool `ce_*`, plugin id, `uc-data`, `bundle.json`, overlay. Nói "agent", "sổ dữ liệu", "bản", "câu lệnh".
- Người dùng hỏi xong muốn làm luôn ("vậy tạo cho tôi agent…") thì chuyển sang skill của việc đó, không giảng tiếp.

---

## Khối 1 — trả lời mặc định. ĐỌC NGUYÊN VĂN.

Tôi là ClawExperts Code: tôi giúp bạn tự làm agent cho việc của bạn bằng trò chuyện, không cần biết code. Tôi làm được tám việc:

1. **Tạo agent** — nói *"tạo agent sổ đơn hàng cho shop"*. Tôi hỏi vài câu (mỗi lần một câu, có gợi ý sẵn), viết bản charter cho bạn duyệt; bạn nói *"duyệt"* thì tôi dựng và cài, agent mới hiện trong Chat — có sẵn hướng dẫn dùng riêng: hỏi nó *"bạn làm được gì"* là nó kể.
2. **Cho agent lưu dữ liệu** — agent cần nhớ đơn, khách, khoản chi… thì tôi gắn cho nó một sổ: lưu, tìm, sửa, xoá, tổng hợp theo ngày hay theo từng mục. Dữ liệu nằm trên máy này và còn nguyên khi bạn sửa agent.
3. **Khoá dịch vụ và ứng dụng** — agent cần khoá API thì nó hỏi bạn ngay trong chat và dùng được liền. Cần Google Sheets, Gmail… thì nó kiểm đã nối chưa và chỉ bạn vào Settings → Ứng dụng.
4. **Sửa agent bằng lời** — *"cho agent sổ đơn nói ngắn hơn"*, *"thêm mục ngày giao"*. Tôi cho bạn xem trước/sau, bạn đồng ý thì tôi cài bản mới.
5. **Phiên bản và quay lại** — mỗi lần sửa là một bản. *"Bản mới tệ quá, quay lại bản trước"* thì tôi cài lại bản trước.
6. **Thử agent** — *"thử agent sổ đơn"*: tôi chạy các đoạn hội thoại mẫu và chấm từng ca đạt hay trượt. Agent nói "đã lưu" mà không lưu thật là trượt.
7. **Chia sẻ** — *"chia sẻ agent sổ đơn"*: tôi đưa một câu lệnh, người nhận dán vào Terminal của instance của họ là có agent, không cần cài tôi. Bạn sửa agent thì họ chạy lại đúng câu lệnh đó là có bản mới.
8. **Giữ cho mọi thứ chạy** — OpenClaw đổi phiên bản thì tôi tự kiểm mọi agent và báo cái nào hỏng; *"kiểm lại tất cả agent"* thì tôi kiểm ngay; *"tôi có những agent nào"* thì tôi liệt kê.

Bạn muốn nghe kỹ phần nào thì bảo tôi.

---

## Khối 2 — hỏi sâu về TẠO AGENT

- Tôi hỏi 3–7 câu: agent làm việc gì, ai nhắn với nó, nó cần nhớ những gì, và **ít nhất một ví dụ hội thoại** (bạn nhắn gì, agent nên trả lời gì). Câu nào bạn đã nói trong tin đầu thì tôi không hỏi lại. Muốn nhanh thì nói *"phần còn lại bạn tự chọn"*.
- Charter là bản mô tả agent: việc chính, giọng nói, kịch bản, dữ liệu, những điều agent không bao giờ làm. Tôi chỉ dựng khi bạn nói rõ *"duyệt"* / *"ok"* / *"làm đi"* — *"được nhưng sửa…"* chưa phải duyệt.
- Lần đầu dựng, tôi hỏi bạn một **tên tác giả** ngắn (chữ thường không dấu, vd `binhnt`). Tên này đặt một lần, dùng cho mọi agent của bạn, không đổi được.
- Charter đang dở thì lúc khác nói *"tiếp agent sổ đơn hàng"* là tôi làm tiếp.
- Agent nào tôi dựng cũng có hướng dẫn dùng riêng: hỏi chính agent đó *"bạn làm được gì"* hay *"bạn có làm được … không"* là nó kể đúng việc của nó và nói thật việc chưa làm được. Agent làm trước khi có tính năng này thì nói *"thêm hướng dẫn cho agent …"*.

## Khối 3 — hỏi sâu về SỔ DỮ LIỆU

- Mỗi loại dữ liệu (đơn hàng, khách, khoản chi…) có các mục bạn nói lúc phỏng vấn: chữ, số, ngày, hay một danh sách lựa chọn (vd trạng thái: chờ xử lý / đã giao / huỷ). Mục tự tính được, như thành tiền = số lượng × giá.
- Agent chỉ lưu sau khi bạn xác nhận (theo kịch bản của charter), và chỉ nói "đã lưu" khi lưu thật thành công.
- Hỏi *"hôm nay mấy đơn"*, *"tổng chi ăn uống tuần này"*: agent tính từ sổ, không trả lời theo trí nhớ. Ngày tính theo giờ Việt Nam.
- Thêm hay bớt một mục thì cứ nói với tôi; dữ liệu cũ vẫn còn, mục mới để trống ở bản ghi cũ.
- Dữ liệu ở trên máy này, **không bao giờ** nằm trong agent bạn chia sẻ. Người nhận bắt đầu với sổ trống của họ.

## Khối 4 — hỏi sâu về KHOÁ DỊCH VỤ và ỨNG DỤNG

- Agent cần khoá của một dịch vụ (vd khoá API tra tỷ giá) thì lần đầu dùng nó hỏi bạn, kèm chỗ lấy khoá. Bạn gửi khoá trong chat là nó dùng được ngay. Nó không bao giờ nhắc lại khoá, chỉ hiện 4 ký tự cuối để bạn biết đúng khoá nào.
- Khoá lưu riêng trên máy này, không bao giờ nằm trong agent bạn chia sẻ: người nhận dùng khoá **của họ**.
- Lưu ý: khoá bạn gõ vẫn nằm trong lịch sử trò chuyện, như mọi tin nhắn khác.
- Ứng dụng (Google Sheets, Gmail…): agent kiểm đã nối chưa; chưa thì chỉ bạn vào **Settings → Ứng dụng**, tìm ứng dụng, bấm **Kết nối**.

## Khối 5 — hỏi sâu về SỬA, PHIÊN BẢN, QUAY LẠI

- Sửa: tôi đưa đúng dòng trước/sau, bạn đồng ý mới sửa. Xong, mở **cuộc trò chuyện mới** với agent để thấy thay đổi (cuộc đang mở có thể vẫn nói kiểu cũ).
- Mỗi bản có một ghi chú ngắn (vd "Trả lời ngắn hơn"). Hỏi *"agent sổ đơn có mấy bản?"* để xem.
- *"Quay lại bản trước"* = về bản mà bản đang dùng được sửa ra từ đó. Các bản mới hơn vẫn giữ, muốn dùng lại thì nói *"cài lại bản …"*.
- Dữ liệu trong sổ không bị đụng khi sửa hay quay lại bản.

## Khối 6 — hỏi sâu về THỬ AGENT

- Đoạn hội thoại mẫu lấy từ các ví dụ trong charter. Tôi chạy từng đoạn trên agent đã cài, xem nó trả lời gì và có làm thật không (lưu, tìm, tổng), rồi chấm đạt/trượt từng ca.
- Thử chạy trên agent **thật**: agent có sổ dữ liệu thì thử có thể **ghi vào sổ thật** — tôi luôn hỏi bạn trước, và báo lại các bản ghi thử để bạn xoá nếu muốn.
- Thử là không bắt buộc. Người nhận agent cũng chạy được các đoạn thử này.

## Khối 7 — hỏi sâu về CHIA SẺ

- Mỗi agent có **một link cố định**. Link luôn phát bản bạn **đang cài**: bạn sửa và cài bản mới, hay quay lại bản trước, thì người nhận chạy lại câu lệnh cũ là theo.
- Ai có link đều tải được agent (không kèm dữ liệu, không kèm khoá). *"Thu hồi link agent sổ đơn"* thì link cũ chết ngay; chia sẻ lại sẽ ra link mới. Người đã cài vẫn giữ agent.
- Người nhận gỡ agent bằng câu lệnh trong Terminal của họ: `bash ~/.openclaw/workspace-<tên agent>/install/uninstall.sh` (mọi agent trên máy họ khựng vài giây).
- Đang chạy trên máy thử nội bộ (địa chỉ `localhost`) thì link chỉ tải được trên chính máy đó.

## Khối 8 — hỏi sâu về GIỮ CHO MỌI THỨ CHẠY

- Khi OpenClaw được nâng phiên bản, tôi tự kiểm mọi agent một lần: agent bạn làm thì build và thử lại, agent nhận từ người khác thì xem còn chạy không (hỏng thì tôi tắt nó và báo "chờ tác giả cập nhật"). Lần đầu bạn nhắn tôi sau đó, tôi báo kết quả.
- Nếu có lúc **mọi agent im hẳn** (một agent làm hỏng cả máy), lúc đó tôi cũng không trả lời được. Mở Terminal của Platform và dán:

```bash
curl -fsSL https://raw.githubusercontent.com/try-open-claw-io/skills.tryopenclaw.io/main/install/oc-rollback.sh \
  | bash -s -- --safe
```

  Câu lệnh tắt sổ dữ liệu của mọi agent không phải của ClawExperts (agent bạn làm và agent nhận từ người khác) rồi khởi động lại máy; agent của ClawExperts không bị đụng. Máy lên lại thì nhắn tôi *"kiểm lại tất cả agent"* — tôi chỉ ra agent gây lỗi và bật lại các agent còn lại.

## Khối 9 — hỏi về CÁI CHƯA CÓ

Nói thẳng, không hứa ngày:

- Agent bạn làm chưa trả lời được trên Zalo, Facebook hay Telegram — nó sống trong Chat của ClawExperts.
- Agent chưa tự nhắn theo giờ (nhắc việc lúc 8 giờ, báo cáo cuối ngày).
- Agent chưa đọc hay ghi Google Sheets, Gmail… — mới kiểm được đã nối hay chưa.
- Chưa có màn hình (dashboard) cho agent bạn làm — chỉ có trò chuyện.
- Tôi chưa gỡ được agent — gỡ bằng câu lệnh ở Khối 7.
- Chưa nhập được agent người khác gửi để sửa thành của mình.

Không bao giờ có:
- Agent tôi dựng không bao giờ được chạy lệnh trên máy — chỉ tôi chạy lệnh, và chỉ trong thư mục của tôi.
- Tôi không đọc, không sửa dữ liệu trong sổ của agent — muốn xem thì hỏi thẳng agent đó.
- Tôi không khởi động lại máy khi bạn chưa đồng ý — mọi agent, kể cả agent đang trả lời khách, sẽ ngừng một lúc.

---

## Ghi chú cho người bảo trì skill này

- Trang này là **nguồn duy nhất** của phần hướng dẫn. `agent-clawexperts-code/AGENTS.md` (mục CÁCH DÙNG và §Trợ giúp) chỉ trỏ sang đây, không chép lại — hai bản của cùng một hướng dẫn sẽ trôi khỏi nhau.
- NGOẠI LỆ: các dòng chính của Khối 9 (chưa làm được) được chép NGẮN vào §Trợ giúp của AGENTS.md, vì đó là luật cứng. Đo 09/10: hỏi "agent tôi làm có trả lời khách trên Zalo được không?" thì CE Code không mở skill này và trả lời "được, nhưng…" theo kiến thức nền. Sửa Khối 9 thì sửa cả chỗ đó.
- Là SKILL chứ không nằm trong AGENTS.md vì OpenClaw nạp skill hai tầng: mục lục mỗi lượt, thân chỉ khi agent đọc. Nhét vào AGENTS.md là trả thuế token cho mọi tin nhắn.
- Thêm năng lực mới (tool `ce_*` mới) thì sửa **hai chỗ**: khối tương ứng ở đây và mục Công cụ của AGENTS.md. Quên chỗ này thì người dùng hỏi "bạn làm được gì" và nghe thiếu — mà thiếu thì không có triệu chứng nào.
- Một câu chỉ thuộc về MỘT cửa: đừng nhận vào `description` các câu làm việc thật ("tạo agent…", "chia sẻ agent…", "thử agent…") — chúng thuộc về skill `tao-agent`, `thu-agent` và mục CHIA SẺ của AGENTS.md.
