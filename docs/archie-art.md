# Archie · 玩家角色素材

- 角色身份：用户提供的伙伴 Archie，奶油白绒毛、蓝灰色耳尖、橙色领巾、大眼睛和蓬松卷尾。
- 生成方式：内置 `image_gen`，使用用户图片作为身份参考，透明背景。未使用 CLI/API fallback。
- 原始生成图集：`assets/game/characters/archie-sheet.png`，保留原始 RGBA。
- 游戏图集：`assets/game/runtime/archie-atlas.png`，640 × 640，4 行 × 4 列；每格 160 × 160，脚底基线 154。
- 行顺序：向下、向左、向上、向右。左右使用真实朝向图，不再镜像旧的人物图集。
- 接入过程：`python3 tools/prepare_archie_art.py` 只做游戏切片、统一缩放和脚底对齐，保留生成图的透明通道及绘画内容。
- 碰撞和导航继续使用原来的玩家脚底碰撞体及明确地面范围。

## 最终生成提示词

Use case: identity-preserve, production game sprite sheet. Use the attached image ONLY as Archie character identity reference, not as a background or UI to copy. Create a transparent PNG sprite atlas for a cute quadruped companion Archie replacing the human player in a 2D travel game. Lock his identity: cream/ivory fluffy fox-dog, oversized upright ears with distinctive blue-gray/teal tips, huge warm brown-black eyes with highlights, small black nose and gentle smile, warm muted orange neckerchief, short paws, big curled fluffy cream tail. Keep the lovable soft 3D toy rendering of the reference with readable silhouette at game scale. NO human body, no clothes beyond the orange bandana, no accessories, no text, no interface elements, no shadow plate, no floor, absolutely transparent alpha outside Archie. TECHNICAL LAYOUT: exactly 4 columns by 4 rows equally sized cells, canvas 1024x1024, each cell 256x256. Every cell contains exactly one whole Archie, standing/walking on ALL FOUR PAWS, with consistent scale (about 210px ear-to-paw height) and baseline at local y=236, centered at local x=128, and safe padding so ears and tail never cross a cell boundary. Camera fixed elevated 3/4 perspective appropriate to a cozy 2D isometric map. Row 1: Archie walking toward viewer/down (front view). Row 2: Archie walking screen LEFT (true left profile, nose left). Row 3: Archie walking away/up (back view, fluffy back and tail, back of ears). Row 4: Archie walking screen RIGHT (true right profile, nose right). Within EACH row columns are four successive evenly phased WALK CYCLE poses: paws opposite diagonal pairs alternate, clear visible stride, smooth small changes, same head, body size, ear colors and tail across frames. Column 1 neutral standing/all paws grounded, column 2 diagonal pair forward, column 3 passing stance, column 4 opposite diagonal pair forward. Left/right rows must truly face left/right respectively, and back row must not show the front face. Precisely aligned regular grid, no visible grid lines. Preserve reference character identity faithfully.

原始生成结果为 1254 × 1254；接入时按实际尺寸均分后重新排版为引擎所需的规则图集。
