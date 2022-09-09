modifind = T{};

local slips = {
    [29312] ={},
    [29313] ={},
    [29314] ={},
    [29315]  = {12511, 12638, 13961, 14214, 14089, 12512, 12639, 13962, 14215, 14090, 13855, 12640, 13963, 14216, 14091, 13856, 12641, 13964, 14217, 14092, 12513, 12642, 13965, 14218, 14093, 12514, 12643, 13966, 14219, 14094, 12515, 12644, 13967, 14220, 14095, 12516, 12645, 13968, 14221, 14096, 12517, 12646, 13969, 14222, 14097, 13857, 12647, 13970, 14223, 14098, 12518, 12648, 13971, 14099, 14224, 13868, 13781, 13972, 14225, 14100, 13869, 13782, 13973, 14226, 14101, 12519, 12649, 13974, 14227, 14102, 12520, 12650, 13975, 14228, 14103, 15265, 14521, 14928, 15600, 15684, 15266, 14522, 14929, 15601, 15685, 15267, 14523, 14930, 15602, 15686, 16138, 14578, 15002, 15659, 15746, 16139, 14579, 15003, 15660, 15747, 16140, 14580, 15004, 16311, 15748, 16678, 17478, 17422, 17423, 16829, 16764, 17643, 16798, 16680, 16766, 17188, 17812, 17771, 17772, 16887, 17532, 17717, 18702, 17858, 19203, 21461, 21124, 20776, 27786, 27926, 28066, 28206, 28346, 27787, 27927, 28067, 28207, 28347}, -- 138
    [29316]  = {15225, 14473, 14890, 15561, 15352, 15226, 14474, 14891, 15562, 15353, 15227, 14475, 14892, 15563, 15354, 15228, 14476, 14893, 15564, 15355, 15229, 14477, 14894, 15565, 15356, 15230, 14478, 14895, 15566, 15357, 15231, 14479, 14896, 15567, 15358, 15232, 14480, 14897, 15568, 15359, 15233, 14481, 14898, 15569, 15360, 15234, 14482, 14899, 15570, 15361, 15235, 14483, 14900, 15362, 15571, 15236, 14484, 14901, 15572, 15363, 15237, 14485, 14902, 15573, 15364, 15238, 14486, 14903, 15574, 15365, 15239, 14487, 14904, 15575, 15366, 11464, 11291, 15024, 16345, 11381, 11467, 11294, 15027, 16348, 11384, 11470, 11297, 15030, 16351, 11387, 11475, 11302, 15035, 16357, 11393, 11476, 11303, 15036, 16358, 11394, 11477, 11304, 15037, 16359, 11395}, -- 105
    [29317]  = {15072, 15087, 15102, 15117, 15132, 15871, 15073, 15088, 15103, 15118, 15133, 15478, 15074, 15089, 15104, 15119, 15134, 15872, 15075, 15090, 15105, 15120, 15135, 15874, 15076, 15091, 15106, 15121, 15136, 15873, 15077, 15092, 15107, 15122, 15137, 15480, 15078, 15093, 15108, 15123, 15138, 15481, 15079, 15094, 15109, 15124, 15139, 15479, 15080, 15095, 15110, 15125, 15140, 15875, 15081, 15096, 15111, 15126, 15141, 15482, 15082, 15097, 15112, 15127, 15142, 15876, 15083, 15098, 15113, 15128, 15143, 15879, 15084, 15099, 15114, 15129, 15144, 15877, 15085, 15100, 15115, 15130, 15145, 15878, 15086, 15101, 15116, 15131, 15146, 15484, 11465, 11292, 15025, 16346, 11382, 16244, 11468, 11295, 15028, 16349, 11385, 15920, 11471, 11298, 15031, 16352, 11388, 16245, 11478, 11305, 15038, 16360, 11396, 16248, 11480, 11307, 15040, 16362, 11398, 15925}, -- 120
    [29318]  = {15245, 14500, 14909, 15580, 15665, 15246, 14501, 14910, 15581, 15666, 15247, 14502, 14911, 15582, 15667, 15248, 14503, 14912, 15583, 15668, 15249, 14504, 14913, 15584, 15669, 15250, 14505, 14914, 15585, 15670, 15251, 14506, 14915, 15586, 15671, 15252, 14507, 14916, 15587, 15672, 15253, 14508, 14917, 15588, 15673, 15254, 14509, 14918, 15589, 15674, 15255, 14510, 14919, 15590, 15675, 15256, 14511, 14920, 15591, 15676, 15257, 14512, 14921, 15592, 15677, 15258, 14513, 14922, 15593, 15678, 15259, 14514, 14923, 15594, 15679, 11466, 11293, 15026, 16347, 11383, 11469, 11296, 15029, 16350, 11386, 11472, 11299, 15032, 16353, 11389, 11479, 11306, 15039, 16361, 11397, 11481, 11308, 15041, 16363, 11399}, -- 100
    [29319]  = {12008, 12028, 12048, 12068, 12088, 11591, 19253, 12009, 12029, 12049, 12069, 12089, 11592, 19254, 12010, 12030, 12050, 12070, 12090, 11615, 11554, 12011, 12031, 12051, 12071, 12091, 11593, 16203, 12012, 12032, 12052, 12072, 12092, 11594, 16204, 12013, 12033, 12053, 12073, 12093, 11736, 19260, 12014, 12034, 12054, 12074, 12094, 11595, 11750, 12015, 12035, 12055, 12075, 12095, 11616, 11737, 12016, 12036, 12056, 12076, 12096, 11617, 11555, 12017, 12037, 12057, 12077, 12097, 11618, 11738, 12018, 12038, 12058, 12078, 12098, 11596, 16205, 12019, 12039, 12059, 12079, 12099, 11597, 16206, 12020, 12040, 12060, 12080, 12100, 11598, 16207, 12021, 12041, 12061, 12081, 12101, 11599, 16208, 12022, 12042, 12062, 12082, 12102, 11619, 11739, 12023, 12043, 12063, 12083, 12103, 11600, 19255, 12024, 12044, 12064, 12084, 12104, 11601, 16209, 12025, 12045, 12065, 12085, 12105, 11602, 11751, 12026, 12046, 12066, 12086, 12106, 11603, 19256, 12027, 12047, 12067, 12087, 12107, 11620, 19247, 11703, 11704, 11705, 11706, 11707, 11708, 11709, 11710, 11711, 11712, 11713, 11714, 11715, 11716, 11717, 11718, 11719, 11720, 11721, 11722}, -- 160
    [29320]  = {11164, 11184, 11204, 11224, 11244, 11165, 11185, 11205, 11225, 11245, 11166, 11186, 11206, 11226, 11246, 11167, 11187, 11207, 11227, 11247, 11168, 11188, 11208, 11228, 11248, 11169, 11189, 11209, 11229, 11249, 11170, 11190, 11210, 11230, 11250, 11171, 11191, 11211, 11231, 11251, 11172, 11192, 11212, 11232, 11252, 11173, 11193, 11213, 11233, 11253, 11174, 11194, 11214, 11234, 11254, 11175, 11195, 11215, 11235, 11255, 11176, 11196, 11216, 11236, 11256, 11177, 11197, 11217, 11237, 11257, 11178, 11198, 11218, 11238, 11258, 11179, 11199, 11219, 11239, 11259, 11180, 11200, 11220, 11240, 11260, 11181, 11201, 11221, 11241, 11261, 11182, 11202, 11222, 11242, 11262, 11183, 11203, 11223, 11243, 11263}, -- 100
    [29321] = {11064, 11084, 11104, 11124, 11144, 11065, 11085, 11105, 11125, 11145, 11066, 11086, 11106, 11126, 11146, 11067, 11087, 11107, 11127, 11147, 11068, 11088, 11108, 11128, 11148, 11069, 11089, 11109, 11129, 11149, 11070, 11090, 11110, 11130, 11150, 11071, 11091, 11111, 11131, 11151, 11072, 11092, 11112, 11132, 11152, 11073, 11093, 11113, 11133, 11153, 11074, 11094, 11114, 11134, 11154, 11075, 11095, 11115, 11135, 11155, 11076, 11096, 11116, 11136, 11156, 11077, 11097, 11117, 11137, 11157, 11078, 11098, 11118, 11138, 11158, 11079, 11099, 11119, 11139, 11159, 11080, 11100, 11120, 11140, 11160, 11081, 11101, 11121, 11141, 11161, 11082, 11102, 11122, 11142, 11162, 11083, 11103, 11123, 11143, 11163}, -- 100
    [29322] ={},
    [29323] ={},
    [29324] = {10650, 10670, 10690, 10710, 10730, 10651, 10671, 10691, 10711, 10731, 10652, 10672, 10692, 10712, 10732, 10653, 10673, 10693, 10713, 10733, 10654, 10674, 10694, 10714, 10734, 10655, 10675, 10695, 10715, 10735, 10656, 10676, 10696, 10716, 10736, 10657, 10677, 10697, 10717, 10737, 10658, 10678, 10698, 10718, 10738, 10659, 10679, 10699, 10719, 10739, 10660, 10680, 10700, 10720, 10740, 10661, 10681, 10701, 10721, 10741, 10662, 10682, 10702, 10722, 10742, 10663, 10683, 10703, 10723, 10743, 10664, 10684, 10704, 10724, 10744, 10665, 10685, 10705, 10725, 10745, 10666, 10686, 10706, 10726, 10746, 10667, 10687, 10707, 10727, 10747, 10668, 10688, 10708, 10728, 10748, 10669, 10689, 10709, 10729, 10749}, -- 100
    [29325] ={},
    [29326] = {27663, 27807, 27943, 28090, 28223, 27664, 27808, 27944, 28091, 28224, 27665, 27809, 27945, 28092, 28225, 27666, 27810, 27946, 28093, 28226, 27667, 27811, 27947, 28094, 28227, 27668, 27812, 27948, 28095, 28228, 27669, 27813, 27949, 28096, 28229, 27670, 27814, 27950, 28097, 28230, 27671, 27815, 27951, 28098, 28231, 27672, 27816, 27952, 28099, 28232, 27673, 27817, 27953, 28100, 28233, 27674, 27818, 27954, 28101, 28234, 27675, 27819, 27955, 28102, 28235, 27676, 27820, 27956, 28103, 28236, 27677, 27821, 27957, 28104, 28237, 27678, 27822, 27958, 28105, 28238, 27679, 27823, 27959, 28106, 28239, 27680, 27824, 27960, 28107, 28240, 27681, 27825, 27961, 28108, 28241, 27682, 27826, 27962, 28109, 28242, 27683, 27827, 27963, 28110, 28243}, -- 105
    [29327] = {27684, 27828, 27964, 28111, 28244, 27685, 27829, 27965, 28112, 28245, 27686, 27830, 27966, 28113, 28246, 27687, 27831, 27967, 28114, 28247, 27688, 27832, 27968, 28115, 28248, 27689, 27833, 27969, 28116, 28249, 27690, 27834, 27970, 28117, 28250, 27691, 27835, 27971, 28118, 28251, 27692, 27836, 27972, 28119, 28252, 27693, 27837, 27973, 28120, 28253, 27694, 27838, 27974, 28121, 28254, 27695, 27839, 27975, 28122, 28255, 27696, 27840, 27976, 28123, 28256, 27697, 27841, 27977, 28124, 28257, 27698, 27842, 27978, 28125, 28258, 27699, 27843, 27979, 28126, 28259, 27700, 27844, 27980, 28127, 28260, 27701, 27845, 27981, 28128, 28261, 27702, 27846, 27982, 28129, 28262, 27703, 27847, 27983, 28130, 28263, 27704, 27848, 27984, 28131, 28264, 27705, 27849, 27985, 28132, 28265, 27706, 27850, 27986, 28133, 28266}, -- 115
    [29328] = {26624, 26800, 26976, 27152, 27328, 26626, 26802, 26978, 27154, 27330, 26628, 26804, 26980, 27156, 27332, 26630, 26806, 26982, 27158, 27334, 26632, 26808, 26984, 27160, 27336, 26634, 26810, 26986, 27162, 27338, 26636, 26812, 26988, 27164, 27340, 26638, 26814, 26990, 27166, 27342, 26640, 26816, 26992, 27168, 27344, 26642, 26818, 26994, 27170, 27346, 26644, 26820, 26996, 27172, 27348, 26646, 26822, 26998, 27174, 27350, 26648, 26824, 27000, 27176, 27352, 26650, 26826, 27002, 27178, 27354, 26652, 26828, 27004, 27180, 27356, 26654, 26830, 27006, 27182, 27358, 26656, 26832, 27008, 27184, 27360, 26658, 26834, 27010, 27186, 27362, 26660, 26836, 27012, 27188, 27364, 26662, 26838, 27014, 27190, 27366, 26664, 26840, 27016, 27192, 27368, 26666, 26842, 27018, 27194, 27370}, -- 110
    [29329] = {26625, 26801, 26977, 27153, 27329, 26627, 26803, 26979, 27155, 27331, 26629, 26805, 26981, 27157, 27333, 26631, 26807, 26983, 27159, 27335, 26633, 26809, 26985, 27161, 27337, 26635, 26811, 26987, 27163, 27339, 26637, 26813, 26989, 27165, 27341, 26639, 26815, 26991, 27167, 27343, 26641, 26817, 26993, 27169, 27345, 26643, 26819, 26995, 27171, 27347, 26645, 26821, 26997, 27173, 27349, 26647, 26823, 26999, 27175, 27351, 26649, 26825, 27001, 27177, 27353, 26651, 26827, 27003, 27179, 27355, 26653, 26829, 27005, 27181, 27357, 26655, 26831, 27007, 27183, 27359, 26657, 26833, 27009, 27185, 27361, 26659, 26835, 27011, 27187, 27363, 26661, 26837, 27013, 27189, 27365, 26663, 26839, 27015, 27191, 27367, 26665, 26841, 27017, 27193, 27369, 26667, 26843, 27019, 27195, 27371}, -- 110
    [29330] ={},
    [29331] = {26740, 26898, 27052, 27237, 27411, 26742, 26900, 27054, 27239, 27413, 26744, 26902, 27056, 27241, 27415, 26746, 26904, 27058, 27243, 27417, 26748, 26906, 27060, 27245, 27419, 26750, 26908, 27062, 27247, 27421, 26752, 26910, 27064, 27249, 27423, 26754, 26912, 27066, 27251, 27425, 26756, 26914, 27068, 27253, 27427, 26758, 26916, 27070, 27255, 27429, 26760, 26918, 27072, 27257, 27431, 26762, 26920, 27074, 27259, 27433, 26764, 26922, 27076, 27261, 27435, 26766, 26924, 27078, 27263, 27437, 26768, 26926, 27080, 27265, 27439, 26770, 26928, 27082, 27267, 27441, 26772, 26930, 27084, 27269, 27443, 26774, 26932, 27086, 27271, 27445, 26776, 26934, 27088, 27273, 27447, 26778, 26936, 27090, 27275, 27449, 26780, 26938, 27092, 27277, 27451, 26782, 26940, 27094, 27279, 27453}, -- 110
    [29332] = {26741, 26899, 27053, 27238, 27412, 26743, 26901, 27055, 27240, 27414, 26745, 26903, 27057, 27242, 27416, 26747, 26905, 27059, 27244, 27418, 26749, 26907, 27061, 27246, 27420, 26751, 26909, 27063, 27248, 27422, 26753, 26911, 27065, 27250, 27424, 26755, 26913, 27067, 27252, 27426, 26757, 26915, 27069, 27254, 27428, 26759, 26917, 27071, 27256, 27430, 26761, 26919, 27073, 27258, 27432, 26763, 26921, 27075, 27260, 27434, 26765, 26923, 27077, 27262, 27436, 26767, 26925, 27079, 27264, 27438, 26769, 26927, 27081, 27266, 27440, 26771, 26929, 27083, 27268, 27442, 26773, 26931, 27085, 27270, 27444, 26775, 26933, 27087, 27272, 27446, 26777, 26935, 27089, 27274, 27448, 26779, 26937, 27091, 27276, 27450, 26781, 26939, 27093, 27278, 27452, 26783, 26941, 27095, 27280, 27454}, -- 110
    [29333] ={},
    [29334] = {25659, 25745, 25800, 25858, 25925, 25660, 25746, 25801, 25859, 25926, 25663, 25749, 25804, 25862, 25929, 25664, 25750, 25805, 25863, 25930, 25665, 25751, 25806, 25865, 25931, 25666, 25752, 25807, 25866, 25932, 25661, 25747, 25802, 25860, 25927, 25662, 25748, 25803, 25861, 25928, 25667, 25753, 25808, 25867, 25933, 25668, 25754, 25809, 25868, 25934, 25579, 25779, 25818, 25873, 25940, 25580, 25780, 25819, 25874, 25941, 25590, 25764, 25812, 25871, 25937, 25591, 25765, 25813, 25872, 25938, 25581, 25781, 25820, 25875, 25942, 25582, 25782, 25821, 25876, 25943, 25588, 25762, 25810, 25869, 25935, 25589, 25763, 25811, 25870, 25936, 25583, 25783, 25822, 25877, 25944, 25584, 25784, 25823, 25878, 25945, 25574, 25790, 25828, 25879, 25946, 25575, 25791, 25829, 25880, 25947, 25576, 25792, 25830, 25881, 25948, 25577, 25793, 25831, 25882, 25949, 25578, 25794, 25832, 25883, 25950, 26204, 26205, 26206, 26207, 26208, 25569, 25797, 25835, 25886, 25953, 25573, 25796, 25834, 25885, 25952, 25570, 25798, 25836, 25887, 25954, 25572, 25795, 25833, 25884, 25951, 25571, 25799, 25837, 25888, 25955, 26211, 26210, 26212, 26209, 26213, 21863, 22004, 21744, 21272, 20576, 21761, 26409, 22070, 21681, 22005, 21745, 22068, 21759, 21770, 22067}, --175
    [29335] = {23040, 23107, 23174, 23241, 23308, 23041, 23108, 23175, 23242, 23309, 23042, 23109, 23176, 23243, 23310, 23043, 23110, 23177, 23244, 23311, 23044, 23111, 23178, 23245, 23312, 23045, 23112, 23179, 23246, 23313, 23046, 23113, 23180, 23247, 23314, 23047, 23114, 23181, 23248, 23315, 23048, 23115, 23182, 23249, 23316, 23049, 23116, 23183, 23250, 23317, 23050, 23117, 23184, 23251, 23318, 23051, 23118, 23185, 23252, 23319, 23052, 23119, 23186, 23253, 23320, 23053, 23120, 23187, 23254, 23321, 23054, 23121, 23188, 23255, 23322, 23055, 23122, 23189, 23256, 23323, 23056, 23123, 23190, 23257, 23324, 23057, 23124, 23191, 23258, 23325, 23058, 23125, 23192, 23259, 23326, 23059, 23126, 23193, 23260, 23327, 23060, 23127, 23194, 23261, 23328, 23061, 23128, 23195, 23262, 23329, 23062, 23129, 23196, 23263, 23330}, --115
    [29336] = {23375, 23442, 23509, 23576, 23643, 23376, 23443, 23510, 23577, 23644, 23377, 23444, 23511, 23578, 23645, 23378, 23445, 23512, 23579, 23646, 23379, 23446, 23513, 23580, 23647, 23380, 23447, 23514, 23581, 23648, 23381, 23448, 23515, 23582, 23649, 23382, 23449, 23516, 23583, 23650, 23383, 23450, 23517, 23584, 23651, 23384, 23451, 23518, 23585, 23652, 23385, 23452, 23519, 23586, 23653, 23386, 23453, 23520, 23587, 23654, 23387, 23454, 23521, 23588, 23655, 23388, 23455, 23522, 23589, 23656, 23389, 23456, 23523, 23590, 23657, 23390, 23457, 23524, 23591, 23658, 23391, 23458, 23525, 23592, 23659, 23392, 23459, 23526, 23593, 23660, 23393, 23460, 23527, 23594, 23661, 23394, 23461, 23528, 23595, 23662, 23395, 23462, 23529, 23596, 23663, 23396, 23463, 23530, 23597, 23664, 23397, 23464, 23531, 23598, 23665}, --115
    [29337] = {23063, 23130, 23197, 23264, 23331, 23064, 23131, 23198, 23265, 23332, 23065, 23132, 23199, 23266, 23333, 23066, 23133, 23200, 23267, 23334, 23067, 23134, 23201, 23268, 23335, 23068, 23135, 23202, 23269, 23336, 23069, 23136, 23203, 23270, 23337, 23070, 23137, 23204, 23271, 23338, 23071, 23138, 23205, 23272, 23339, 23072, 23139, 23206, 23273, 23340, 23073, 23140, 23207, 23274, 23341, 23074, 23141, 23208, 23275, 23342, 23075, 23142, 23209, 23276, 23343, 23076, 23143, 23210, 23277, 23344, 23077, 23144, 23211, 23278, 23345, 23078, 23145, 23212, 23279, 23346, 23079, 23146, 23213, 23280, 23347, 23080, 23147, 23214, 23281, 23348, 23081, 23148, 23215, 23282, 23349, 23082, 23149, 23216, 23283, 23350, 23083, 23150, 23217, 23284, 23351, 23084, 23151, 23218, 23285, 23352}, --110
    [29338] = {23398, 23465, 23532, 23599, 23666, 23399, 23466, 23533, 23600, 23667, 23400, 23467, 23534, 23601, 23668, 23401, 23468, 23535, 23602, 23669, 23402, 23469, 23536, 23603, 23670, 23403, 23470, 23537, 23604, 23671, 23404, 23471, 23538, 23605, 23672, 23405, 23472, 23539, 23606, 23673, 23406, 23473, 23540, 23607, 23674, 23407, 23474, 23541, 23608, 23675, 23408, 23475, 23542, 23609, 23676, 23409, 23476, 23543, 23610, 23677, 23410, 23477, 23544, 23611, 23678, 23411, 23478, 23545, 23612, 23679, 23412, 23479, 23546, 23613, 23680, 23413, 23480, 23547, 23614, 23681, 23414, 23481, 23548, 23615, 23682, 23415, 23482, 23549, 23616, 23683, 23416, 23483, 23550, 23617, 23684, 23417, 23484, 23551, 23618, 23685, 23418, 23485, 23552, 23619, 23686, 23419, 23486, 23553, 23620, 23687}, --110
    [29339] = {21515, 21561, 21617, 21670, 21718, 21775, 21826, 21879, 21918, 21971, 22027, 22082, 22108, 22214, 21516, 21562, 21618, 21671, 21719, 21776, 21827, 21880, 21919, 21972, 22028, 22083, 22109, 22215, 21517, 21563, 21619, 21672, 21720, 21777, 21828, 21881, 21920, 21973, 22029, 22084, 22110, 22216, 21518, 21564, 21620, 21673, 21721, 21778, 21829, 21882, 21921, 21974, 22030, 22085, 22111, 22217, 21519, 21565, 21621, 21674, 21722, 21779, 21830, 21883, 21922, 21975, 22031, 22086, 22107, 22218, 22089}, --71
};

function modifind.search(searchID)
    local searchString = AshitaCore:GetResourceManager():GetItemById(searchID);
    if (searchString == nil) then return; end

    local inventory = AshitaCore:GetMemoryManager():GetInventory();
    local resources = AshitaCore:GetResourceManager();
    local FoundSlips = {};

    for c = 0, 16 do
        local foundCount = 1;
        for j = 0, inventory:GetContainerCountMax(c), 1 do
            local itemEntry = inventory:GetContainerItem(c, j);
            if (itemEntry.Id ~= 0 and itemEntry.Id ~= 65535) then
                local item = resources:GetItemById(itemEntry.Id);

                if (item ~= nil) then
                    if (item.Name[1] == searchString.Name[1]) then
                        return true;
                    end

                    if item.Name[1]:contains('Storage Slip ') then
                        FoundSlips[#FoundSlips + 1] = {item, itemEntry};
                    end
                end
            end
        end
    end

    for k,v in ipairs(FoundSlips) do
        local slipItems = slips[v[1].Id];
        local extra = v[2].Extra;

        for i,slipItemID in ipairs(slipItems) do
            local slipItem = resources:GetItemById(slipItemID);
            if (slipItem.Name[1] == searchString.Name[1]) then
                local byte = struct.unpack('B',extra,math.floor((i - 1) / 8)+1);
                if byte < 0 then
                    byte = byte + 256;
                end

                if (modifind.hasBit(byte, modifind.Bit((i - 1) % 8 + 1))) then
                    return true; 
                else 
                    return false;
                end
            end
        end
    end
end

function modifind.Bit(p)
    return 2 ^ (p - 1);
 end

function modifind.hasBit(x, p)
    return x % (p + p) >= p;
end

return modifind;