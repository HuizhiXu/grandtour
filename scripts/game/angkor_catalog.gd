extends RefCounted
## Only user-reviewed paintings; no placeholder stops for unfinished art.

const ROUTE: Dictionary = {"title": "暹粒 · 吴哥漫步", "tab": "暹粒 · 吴哥", "subtitle": "通王城南门 → 巴戎寺 → 巴方寺 → 空中宫殿 → 战象台 → 癞王台 → 王宫遗址 → 胜利门 → 周萨神庙 → 托玛侬 → 茶胶寺 → 塔布茏寺 → 小吴哥 → 巴肯山 → 班黛喀蒂 → 圣剑寺 → 龙蟠水池 → 塔逊庙 → 东梅棚 → 比粒寺 → 豆蔻寺 → 女王宫 → 崩密列 → 神牛寺 → 巴空寺 → 洞里萨湖", "note": "已开放 26 站。塔布茏寺与小吴哥各有 4 个视角，巴肯山、班黛喀蒂、圣剑寺、龙蟠水池、塔逊庙、东梅棚、比粒寺、豆蔻寺、女王宫、崩密列、神牛寺和巴空寺各有 2 个视角。各站保留景点介绍，可自由欣赏风景。", "stops": ["angkor_south_gate","angkor_bayon","angkor_baphuon","angkor_phimeanakas","angkor_elephants","angkor_leper_king","angkor_royal_palace","angkor_victory_gate","angkor_chau_say","angkor_thommanon","angkor_ta_keo","angkor_ta_prohm","angkor_wat","angkor_bakheng","angkor_banteay_kdei","angkor_preah_khan","angkor_neak_pean","angkor_ta_som","angkor_east_mebon","angkor_pre_rup","angkor_kravan","angkor_banteay_srei","angkor_beng_mealea","angkor_preah_ko","angkor_bakong","angkor_tonle_sap"]}

const STOPS: Dictionary = {
	"angkor_tonle_sap": {"title":"洞里萨湖","scene":"angkor_tonle_sap","observation_only":true,"info":"高脚木屋立在水边，细长支柱和斜撑托起生活空间。窄木船停在屋前，柔和的屋顶颜色与树影一起落入水面。","views":[{"title":"高脚屋与水影","art":"angkor_tonle_sap"}]},
	"angkor_bakong": {"title":"巴空寺","scene":"angkor_bakong","info":"林荫入口的道路通向远处层层升高的台基与主塔，两侧树冠框住寺院轮廓。切换到侧面全景，可以近看厚重石台、残存小塔和缺顶的低矮石殿。","views":[{"title":"林荫入口石道","art":"angkor_bakong"},{"title":"层台与残殿全景 · 观景","art":"angkor_bakong_platform"}]},
	"angkor_preah_ko": {"title":"神牛寺","scene":"angkor_preah_ko","info":"砖塔并列在低台基上，门框周围仍可见浅色灰泥雕刻，残缺塔顶、深浅砖材和风化石狮保留了不同的时间痕迹。前方石牛面向塔殿，另一幅庭院视角可近看石牛、守护狮与树林。","views":[{"title":"砖塔正面全景","art":"angkor_preah_ko"},{"title":"石牛与守护狮庭院","art":"angkor_preah_ko_bulls"}]},
	"angkor_beng_mealea": {"title":"崩密列","scene":"angkor_beng_mealea","observation_only":true,"info":"树林包围残墙，坍塌石块与树根相互交错。第一幅画面从高处望向穿行其间的窄木步道；另一幅近看粗大树干、裸露根系与残存门框的关系。","views":[{"title":"林间木步道与残墙","art":"angkor_beng_mealea"},{"title":"树根与坍塌石墙","art":"angkor_beng_mealea_roots"}]},
	"angkor_banteay_srei": {"title":"女王宫","scene":"angkor_banteay_srei","info":"红色砂岩塔群立在林荫前，层叠山花、门框与石栏窗显出细密的雕刻。入口石道两侧保留石柱、木步道和保护绳，门内还能看见支撑设施。","views":[{"title":"入口石道与塔群","art":"angkor_banteay_srei"},{"title":"池畔建筑群全景 · 观景","art":"angkor_banteay_srei_pond"}]},
	"angkor_kravan": {"title":"豆蔻寺","scene":"angkor_kravan","info":"五座砖塔并列在同一台基上，中央高塔与两侧不同高度的残存塔身，构成豆蔻寺的轮廓。深色旧砖与浅色修补砖并置，门框和过梁保留风化纹理。","views":[{"title":"五座砖塔正面全景","art":"angkor_kravan"},{"title":"室内砖墙浮雕 · 观景","art":"angkor_kravan_relief"}]},
	"angkor_pre_rup": {"title":"比粒寺","scene":"angkor_pre_rup","info":"林荫围住层层台基，砖塔高低错落，陡峭的石阶通向上方门洞。转到正面视角，可以看见风化砖面、残存石刻和台阶前的方形石构。","views":[{"title":"林荫塔群全景","art":"angkor_pre_rup"},{"title":"正面台阶与砖塔 · 观景","art":"angkor_pre_rup_terrace"}]},
	"angkor_east_mebon": {"title":"东梅棚","scene":"angkor_east_mebon","info":"砖塔错落在层层台基之上，前方的独立石柱与残存基础，留下院落曾有的空间线索。另一幅视角中，一尊风化石象立在台角，长墙向两侧延伸。","views":[{"title":"塔群与残柱全景","art":"angkor_east_mebon"},{"title":"台角石象 · 观景","art":"angkor_east_mebon_elephant"}]},
	"angkor_ta_som": {"title":"塔逊庙","scene":"angkor_ta_som","info":"正面的塔殿、层层门框与风化山花，构成塔逊庙的入口景象。另一幅视角里，粗大的树根包覆门洞，石刻从根系之间露出，门内仍可见保护支撑。","views":[{"title":"正面塔殿门楼","art":"angkor_ta_som"},{"title":"树根包覆门洞 · 观景","art":"angkor_ta_som_roots"}]},
	"angkor_neak_pean": {"title":"龙蟠水池","scene":"angkor_neak_pean","info":"木栈道穿过平静的水面，短柱沿两侧向林岸收拢。切换到寺塔全景，可以看见圆形石台上的残存塔身、池中的小亭与层层石砌池壁。","views":[{"title":"水上木栈道","art":"angkor_neak_pean"},{"title":"池中寺塔 · 观景","art":"angkor_neak_pean_sanctuary"}]},
	"angkor_preah_khan": {"title":"圣剑寺","scene":"angkor_preah_khan","info":"林荫中的长石道通向圣剑寺的门楼，两侧风化的石栏与层叠门框，引导视线走向深处。另一幅临水全景展示柱廊建筑、残存的上层窗洞与四周树林。","views":[{"title":"林荫入口石道","art":"angkor_preah_khan"},{"title":"临水柱廊 · 观景","art":"angkor_preah_khan_pond"}]},
	"angkor_banteay_kdei": {"title":"班黛喀蒂","scene":"angkor_banteay_kdei","info":"林间的面塔门楼、狭长门洞与两侧的墙体，构成班黛喀蒂这一站的景象。石块接缝、青苔、风化雕刻和残缺的轮廓，都值得放慢脚步观察。","views":[{"title":"林间面塔门楼","art":"angkor_banteay_kdei"},{"title":"西门残塔 · 档案视角","art":"angkor_banteay_kdei_west_gate"}]},
	"angkor_bakheng": {"title":"巴肯山","scene":"angkor_bakheng","observation_only":true,"info":"巴肯山的层层石台、残存的小塔与四周林海，组成一处适合驻足观察的山寺景象。晚光照在风化石面上，让台基和门框显出深浅层次。","views":[{"title":"夕照平台全景","art":"angkor_bakheng"},{"title":"残塔近景","art":"angkor_bakheng_terrace"}]},
	"angkor_ta_prohm": {"title":"塔布茏寺","scene":"angkor_ta_prohm","info":"塔布茏寺原名意为皇家寺院，建于阇耶跋摩七世时期，于 1186 年奉献。巨大的树根与门楼、回廊交织，是这里鲜明的景象。保护工程也为石构建筑提供支撑。","views":[{"title":"庭院广角","art":"angkor_ta_prohm"},{"title":"树根与门廊 · 观景","art":"angkor_ta_prohm_roots_gate"},{"title":"树根长廊","art":"angkor_ta_prohm_roots_gallery"},{"title":"长柱廊","art":"angkor_ta_prohm_colonnade"}]},
	"angkor_wat": {"title":"小吴哥 · 吴哥窟","scene":"angkor_wat","info":"吴哥窟建于 12 世纪苏利耶跋摩二世时期，起初为印度教寺院，后来成为佛教圣地。层层回廊、中央塔群和宽阔的石道，组成这座寺院的空间。","views":[{"title":"入口石道","art":"angkor_wat"},{"title":"池畔倒影 · 观景","art":"angkor_wat_reflection"},{"title":"侧面建筑群","art":"angkor_wat_oblique"},{"title":"内庭回廊","art":"angkor_wat_courtyard"}]},
	"angkor_south_gate": {"title":"通王城南门","scene":"angkor_south_gate","info":"石道两侧的石雕与门塔上的面孔，是这座城门鲜明的轮廓。沿道路观察，留意石材的风化和树影。"},
	"angkor_bayon": {"title":"巴戎寺","scene":"angkor_bayon","info":"密集而错落的面塔、低矮的回廊与层叠石台，组成巴戎寺的遗址轮廓。站在岸边观察，不必把风化的雕刻想象成完整时的样子。"},
	"angkor_baphuon": {"title":"巴方寺","scene":"angkor_baphuon","info":"长石道通向层层升高的寺体。台基、门框和残存的石墙展示出建筑的体量，树木又遮住其中一部分。请在前方空地观察，保持遗址原貌。"},
	"angkor_phimeanakas": {"title":"空中宫殿","scene":"angkor_phimeanakas","info":"空中宫殿位于古代王宫范围内。陡阶连接层层台基，顶部只留下部分石造结构。风化石像和散落石块，也是这里原本面貌的一部分。"},
	"angkor_elephants": {"title":"战象台","scene":"angkor_elephants","info":"长台横向展开，台阶与浮雕连接着广场和林地。外墙保留多种人物与动物形象，石面上的缺损和深浅变化值得慢慢看。"},
	"angkor_leper_king": {"title":"癞王台","scene":"angkor_leper_king","info":"折转的外墙上排列着多层浮雕。原石、修补石块和风化的雕像并置，展现出遗址被时间改变的样子。这一站从外墙前观察。"},
	"angkor_royal_palace": {"title":"王宫遗址","scene":"angkor_royal_palace","info":"古代王宫的范围里，水池、宫墙与残存的门楼仍可见。木构建筑已不在眼前；不必补画消失的殿宇，池水和林荫也能讲述这里的故事。"},
	"angkor_victory_gate": {"title":"胜利门","scene":"angkor_victory_gate","info":"道路穿过门塔，树林包围两侧城墙。站在引道上，能看见门塔的轮廓、风化的石面和门洞内的光。沿现有道路漫步，观察这处入城入口。"},
	"angkor_chau_say": {"title":"周萨神庙","scene":"angkor_chau_say","info":"周萨神庙的塔殿、台阶和架在石柱上的引道围合出院落。这里已有保护修复工程，新旧石材的差异依然可见。观察现存建筑，也保留缺失部分的空白。"},
	"angkor_thommanon": {"title":"托玛侬神庙","scene":"angkor_thommanon","info":"托玛侬的主塔与前殿相接，石面上保留精细而风化的雕刻。林荫、树根和落叶围在建筑四周。请在地面观察，不攀爬石墙。"},
	"angkor_ta_keo": {"title":"茶胶寺","scene":"angkor_ta_keo","info":"茶胶寺是一座未完成装饰的山寺。厚重台基、陡峭石阶和较少雕饰的石面，让建筑的体量格外清楚。这一站在地面观察，保留它未完成的样子。"},
}
