import Foundation

enum WordCategory: String, CaseIterable {
    case wellness = "Wellness"
    case focus = "Focus"
    case nature = "Nature"
    case growth = "Growth"
    case calm = "Calm"
    case confidence = "Confidence"
    case energy = "Energy"
    case positive = "Positive"
    case mindful = "Mindful"
    case strength = "Strength"
}

enum WordDifficulty: Int, CaseIterable {
    case easy = 1
    case medium = 2
    case hard = 3

    var lengthRange: ClosedRange<Int> {
        switch self {
        case .easy: return 3...4
        case .medium: return 4...5
        case .hard: return 5...6
        }
    }
}

struct WordLibrary {
    private static let wordsByCategory: [WordCategory: [String]] = [
        .wellness: [
            "ACE", "AID", "AIM", "AIR", "AWE", "BAL", "BED", "BOW", "BUD", "CAL",
            "CAN", "CAP", "CHI", "COO", "CUP", "DAY", "DEW", "DIM", "EAR", "EAT",
            "ELF", "ERA", "EVE", "EYE", "FAN", "FAR", "FED", "FEW", "FIG", "FIN",
            "FIT", "FLO", "FLY", "FOG", "FUN", "GAL", "GAP", "GEM", "GET", "GIG",
            "GIN", "GIT", "GOD", "GOT", "GUM", "GUT", "GYM", "HAM", "HAP", "HAS",
            "HAT", "HAY", "HEM", "HEN", "HEW", "HEX", "HID", "HIM", "HIP", "HIT",
            "HOB", "HOD", "HOG", "HOP", "HOT", "HOW", "HUB", "HUE", "HUG", "HUM",
            "HUT", "ICE", "ICY", "IMP", "INK", "INN", "ION", "IRE", "IRK", "ITS",
            "IVY", "JAB", "JAM", "JAR", "JAW", "JAY", "JET", "JIG", "JOB", "JOG",
            "JOT", "JOY", "JUG", "KEN", "KEY", "KID", "KIN", "KIT", "LAB", "LAC",
            "LAD", "LAG", "LAP", "LAW", "LAX", "LAY", "LEA", "LED", "LEG", "LET",
            "LID", "LIE", "LIP", "LIT", "LOG", "LOT", "LOW", "LUG", "MAD", "MAN",
            "MAP", "MAR", "MAT", "MAW", "MAY", "MEN", "MET", "MID", "MIX", "MOB",
            "MOD", "MOM", "MOP", "MOW", "MUD", "MUG", "MUM", "NAB", "NAG", "NAP",
            "NAY", "NET", "NEW", "NIB", "NIP", "NIT", "NOB", "NOD", "NOR", "NOT",
            "NOW", "NUB", "NUN", "NUT", "OAK", "OAR", "OAT", "ODD", "ODE", "OFF",
            "OFT", "OHM", "OIL", "OLD", "ONE", "OPT", "ORB", "ORE", "OUR", "OUT",
            "OWE", "OWL", "OWN", "PAD", "PAL", "PAN", "PAP", "PAR", "PAT", "PAW",
            "PAY", "PEA", "PEG", "PEN", "PEP", "PER", "PET", "PEW", "PIE", "PIG",
            "PIN", "PIT", "PLY", "POD", "POP", "POT", "POW", "PRO", "PRY", "PUB",
            "HEAL", "REST", "YOGA", "PURE", "LIFE", "CARE", "WELL", "SAFE", "GLOW",
            "WARM", "SOUL", "MIND", "BODY", "CORE", "EASE", "FREE", "GOOD", "HOPE",
            "HUSH", "CALM", "SOFT", "NICE", "COZY", "COOL", "KEEN", "KIND", "LIFT",
            "LIVE", "LOVE", "LUCK", "MILD", "NEAT", "OPEN", "PACE", "PEAK", "PLAY",
            "PLUS", "POSH", "PRAY", "REAL", "RICH", "RISE", "ROAM", "SAFE", "SAIL",
            "SAVE", "SEEK", "SELF", "SERV", "SHOW", "SING", "SLIM", "SLOW", "SNAP",
            "SOAK", "SOAR", "SOFT", "SONG", "SOON", "STAR", "STAY", "STEP", "STIR",
            "STOP", "SURE", "SWIM", "TAKE", "TALK", "TALL", "TEND", "THAN", "THAT",
            "THEM", "THEN", "THIN", "THIS", "THRU", "TIDY", "TIME", "TONE", "TOPS",
            "TOUR", "TREK", "TRIM", "TRUE", "TURN", "VAST", "VERY", "VIEW", "VOID",
            "WAKE", "WALK", "WANT", "WARD", "WASH", "WAVE", "WAYS", "WEAR", "WEEK",
            "WHOLE", "FRESH", "HAPPY", "SMILE", "DREAM", "BLISS", "PEACE", "RELAX",
            "VITAL", "RENEW", "BOOST", "BLOOM", "BLESS", "GRACE", "HEART", "LIGHT",
            "SHINE", "CLEAR", "CLEAN", "CRISP", "AWAKE", "ALIVE", "ALERT", "AWARE"
        ],
        .focus: [
            "ACT", "ADD", "AIM", "ALL", "AND", "ANT", "ANY", "APE", "APT", "ARC",
            "ARE", "ARK", "ARM", "ART", "ASH", "ASK", "ATE", "AWE", "AXE", "AYE",
            "BAD", "BAG", "BAN", "BAR", "BAT", "BAY", "BEE", "BEG", "BET", "BIG",
            "BIN", "BIT", "BOB", "BOG", "BOW", "BOX", "BOY", "BRA", "BUD", "BUG",
            "BUM", "BUN", "BUS", "BUT", "BUY", "CAB", "CAD", "CAM", "CAN", "CAP",
            "CAR", "CAT", "COB", "COD", "COG", "COP", "COT", "COW", "COX", "COY",
            "CRY", "CUB", "CUD", "CUP", "CUR", "CUT", "DAB", "DAD", "DAM", "DAY",
            "DEN", "DEW", "DID", "DIE", "DIG", "DIM", "DIN", "DIP", "DOC", "DOE",
            "DOG", "DON", "DOT", "DRY", "DUB", "DUD", "DUE", "DUG", "DUN", "DUO",
            "DYE", "EAR", "EAT", "EEL", "EGG", "EGO", "ELF", "ELK", "ELM", "EMU",
            "END", "ERA", "ERR", "EVE", "EWE", "EYE", "FAD", "FAN", "FAR", "FAT",
            "FAX", "FED", "FEE", "FEN", "FEW", "FIG", "FIN", "FIR", "FIT", "FIX",
            "FLU", "FLY", "FOB", "FOE", "FOG", "FOP", "FOR", "FOX", "FRY", "FUN",
            "FUR", "GAB", "GAG", "GAL", "GAP", "GAS", "GAY", "GEL", "GEM", "GET",
            "GIG", "GIN", "GNU", "GOB", "GOD", "GOT", "GUM", "GUN", "GUT", "GUY",
            "GYM", "HAD", "HAG", "HAM", "HAS", "HAT", "HAY", "HEM", "HEN", "HER",
            "HEW", "HEX", "HID", "HIM", "HIP", "HIS", "HIT", "HOB", "HOD", "HOE",
            "HOG", "HOP", "HOT", "HOW", "HUB", "HUE", "HUG", "HUM", "HUT", "ICE",
            "ICY", "ILL", "IMP", "INK", "INN", "ION", "IRE", "IRK", "ITS", "IVY",
            "PLAN", "TASK", "GOAL", "WORK", "LEAD", "MOVE", "PUSH", "PULL", "DRAW",
            "FIND", "SEEK", "LOOK", "VIEW", "SCAN", "READ", "KNOW", "MIND", "IDEA",
            "NOTE", "LIST", "MARK", "SPOT", "PICK", "SORT", "RANK", "TEST", "QUIZ",
            "EXAM", "SIGN", "CLUE", "HINT", "LINK", "BOND", "GRIP", "HOLD", "LOCK",
            "KEYS", "CODE", "DATA", "INFO", "BITS", "BYTE", "FILE", "FORM", "EDIT",
            "SAVE", "LOAD", "SEND", "CALL", "DIAL", "RING", "BUZZ", "BEEP", "TICK",
            "TOCK", "SNAP", "CLIP", "ZOOM", "FAST", "KEEN", "WISE", "SAGE", "WITS",
            "THINK", "LEARN", "STUDY", "SMART", "SHARP", "ALERT", "AWARE", "QUICK",
            "READY", "TRACK", "TRACE", "SOLVE", "CRACK", "BREAK", "STICK", "FOCUS"
        ],
        .nature: [
            "SKY", "SUN", "SEA", "AIR", "DEW", "OAK", "ELM", "IVY", "BAY", "BOG",
            "BUD", "COD", "COW", "CUB", "DAM", "DEN", "DOE", "DOG", "EEL", "EGG",
            "ELK", "EMU", "EVE", "EWE", "FAN", "FAR", "FAT", "FAX", "FED", "FEE",
            "FEN", "FEW", "FIG", "FIN", "FIR", "FIT", "FLY", "FOB", "FOE", "FOG",
            "FOR", "FOX", "FUR", "GEM", "GNU", "HAY", "HEN", "HEW", "HOE", "HOG",
            "ICE", "ICY", "INK", "IVY", "JAM", "JAR", "JAY", "KIT", "LAC", "LAD",
            "LAG", "LAP", "LEA", "LOG", "LOW", "LUG", "MAR", "MAW", "MAY", "MUD",
            "NAG", "NET", "NEW", "NIT", "NUT", "OAK", "OAR", "OAT", "ORB", "ORE",
            "OWL", "PAW", "PEA", "PIG", "PIN", "POD", "RAG", "RAM", "RAT", "RAW",
            "RAY", "RED", "RIB", "RIG", "RIM", "RIP", "ROB", "ROC", "ROD", "ROE",
            "ROT", "ROW", "RUB", "RUG", "RUN", "RUT", "RYE", "SAC", "SAD", "SAG",
            "SAP", "SAT", "SAW", "SAY", "SEA", "SET", "SEW", "SHE", "SHY", "SIN",
            "SIP", "SIS", "SIT", "SIX", "SKI", "SKY", "SLY", "SOB", "SOD", "SON",
            "SOP", "SOT", "SOW", "SOY", "SPA", "SPY", "STY", "SUB", "SUM", "SUN",
            "SUP", "TAB", "TAD", "TAG", "TAN", "TAP", "TAR", "TAT", "TAX", "TEA",
            "TEN", "THE", "THY", "TIC", "TIE", "TIN", "TIP", "TOE", "TON", "TOO",
            "TOP", "TOT", "TOW", "TOY", "TUB", "TUG", "TWO", "URN", "USE", "VAN",
            "VAT", "VET", "VIA", "VIE", "VOW", "WAD", "WAG", "WAR", "WAS", "WAX",
            "WAY", "WEB", "WED", "WEE", "WET", "WHO", "WHY", "WIG", "WIN", "WIT",
            "WOE", "WOK", "WON", "WOO", "WOW", "YAK", "YAM", "YAP", "YAW", "YEA",
            "TREE", "LEAF", "WAVE", "WIND", "RAIN", "SNOW", "MOON", "STAR", "LAKE",
            "HILL", "ROCK", "SAND", "DIRT", "CLAY", "SOIL", "BARK", "ROOT", "STEM",
            "VINE", "MOSS", "FERN", "PALM", "PINE", "ROSE", "LILY", "IRIS", "SEED",
            "BULB", "TWIG", "NEST", "HIVE", "POND", "POOL", "CAVE", "COVE", "GULF",
            "ISLE", "PEAK", "VALE", "DALE", "GLEN", "MOOR", "RILL", "BECK", "BURN",
            "CREEK", "BROOK", "RIVER", "MARSH", "SWAMP", "FIELD", "WOODS", "GROVE",
            "GLADE", "BEACH", "SHORE", "COAST", "CLIFF", "BLUFF", "RIDGE", "SLOPE"
        ],
        .growth: [
            "GO", "UP", "ADD", "AIM", "ASK", "BET", "BIG", "BIT", "BOW", "BUY",
            "CAN", "CUT", "DIG", "DIP", "DUE", "EAT", "END", "FAR", "FED", "FEW",
            "FIT", "FLY", "FOR", "FUN", "GAP", "GAS", "GET", "GIG", "GIN", "GOB",
            "GOD", "GOT", "GUM", "GUN", "GUT", "GUY", "GYM", "HAD", "HAS", "HAT",
            "HID", "HIM", "HIP", "HIS", "HIT", "HOB", "HOD", "HOE", "HOG", "HOP",
            "HOT", "HOW", "HUB", "HUE", "HUG", "HUM", "HUT", "ICE", "ILL", "IMP",
            "INK", "INN", "ION", "IRE", "ITS", "JAB", "JAM", "JAR", "JAW", "JAY",
            "JET", "JIG", "JOB", "JOG", "JOT", "JOY", "JUG", "JUT", "KEG", "KEN",
            "KEY", "KID", "KIN", "KIT", "LAB", "LAD", "LAG", "LAP", "LAW", "LAY",
            "LED", "LEG", "LET", "LID", "LIE", "LIP", "LIT", "LOG", "LOT", "LOW",
            "LUG", "MAD", "MAN", "MAP", "MAR", "MAT", "MAW", "MAX", "MEN", "MET",
            "MID", "MIX", "MOB", "MOD", "MOM", "MOP", "MOW", "MUD", "MUG", "MUM",
            "NAB", "NAG", "NAP", "NAY", "NET", "NEW", "NIB", "NIP", "NIT", "NOB",
            "NOD", "NOR", "NOT", "NOW", "NUB", "NUN", "NUT", "OAK", "OAR", "OAT",
            "ODD", "ODE", "OFF", "OFT", "OHM", "OIL", "OLD", "ONE", "OPT", "ORB",
            "ORE", "OUR", "OUT", "OWE", "OWL", "OWN", "PAD", "PAL", "PAN", "PAP",
            "PAR", "PAT", "PAW", "PAY", "PEA", "PEG", "PEN", "PEP", "PER", "PET",
            "PIE", "PIG", "PIN", "PIT", "PLY", "POD", "POP", "POT", "PRO", "PRY",
            "PUB", "PUG", "PUN", "PUP", "PUS", "PUT", "QUA", "RAG", "RAM", "RAN",
            "GROW", "RISE", "GAIN", "MOVE", "LEAP", "SOAR", "STEP", "JUMP", "LIFT",
            "PUSH", "PULL", "DRAW", "LEAD", "WORK", "EARN", "MAKE", "GIVE", "TAKE",
            "FORM", "MOLD", "CAST", "TURN", "SPIN", "ROLL", "FLOW", "GUSH", "POUR",
            "DRIP", "DROP", "PICK", "GRAB", "HOLD", "GRIP", "BIND", "JOIN", "LINK",
            "BOND", "FUSE", "MELT", "COOK", "BAKE", "BREW", "STIR", "WHIP", "CHOP",
            "BUILD", "CRAFT", "CARVE", "SHAPE", "FORGE", "WIELD", "SWING", "THROW",
            "CATCH", "REACH", "GRASP", "CLIMB", "SCALE", "MOUNT", "VAULT", "BOUND"
        ],
        .calm: [
            "HUM", "LOW", "NAP", "OHM", "SIT", "LIE", "DIM", "COO", "MUM", "ZEN",
            "AIR", "AWE", "BED", "BOW", "CUP", "DAY", "DEW", "EAR", "EAT", "ELF",
            "ERA", "EVE", "EYE", "FAN", "FAR", "FIG", "FIN", "FIT", "FLO", "FLY",
            "FOG", "FUN", "GAL", "GAP", "GEM", "GET", "GIG", "GOT", "GUM", "GUT",
            "HAM", "HAS", "HAT", "HAY", "HEM", "HEN", "HEW", "HEX", "HID", "HIP",
            "HIT", "HOB", "HOD", "HOG", "HOP", "HOT", "HOW", "HUB", "HUE", "HUG",
            "ICE", "ICY", "IMP", "INK", "INN", "ION", "ITS", "IVY", "JAB", "JAM",
            "JAR", "JAW", "JAY", "JET", "JIG", "JOB", "JOG", "JOT", "JOY", "JUG",
            "KEN", "KEY", "KID", "KIN", "KIT", "LAB", "LAC", "LAD", "LAG", "LAP",
            "LAW", "LAX", "LAY", "LEA", "LED", "LEG", "LET", "LID", "LIP", "LIT",
            "LOG", "LOT", "LUG", "MAD", "MAN", "MAP", "MAR", "MAT", "MAW", "MAY",
            "MEN", "MET", "MID", "MIX", "MOB", "MOD", "MOM", "MOP", "MOW", "MUD",
            "MUG", "NAB", "NAG", "NAY", "NET", "NEW", "NIB", "NIP", "NIT", "NOB",
            "NOD", "NOR", "NOT", "NOW", "NUB", "NUN", "NUT", "OAK", "OAR", "OAT",
            "ODD", "ODE", "OFF", "OFT", "OIL", "OLD", "ONE", "OPT", "ORB", "ORE",
            "OUR", "OUT", "OWE", "OWL", "OWN", "PAD", "PAL", "PAN", "PAP", "PAR",
            "PAT", "PAW", "PAY", "PEA", "PEG", "PEN", "PEP", "PER", "PET", "PEW",
            "PIE", "PIG", "PIN", "PIT", "PLY", "POD", "POP", "POT", "POW", "PRO",
            "PRY", "PUB", "PUG", "PUN", "PUP", "PUT", "RAG", "RAM", "RAN", "RAP",
            "CALM", "SLOW", "SOFT", "EASE", "HUSH", "MILD", "WARM", "GLOW", "FLOW",
            "COOL", "COZY", "SAFE", "SNUG", "SUNG", "LULL", "SWAY", "ROCK", "REST",
            "DOZE", "NUMB", "DAZE", "HAZE", "MIST", "FADE", "WANE", "SIGH", "YAWN",
            "LAZE", "IDLE", "LOAF", "LOLL", "BASK", "BATHE", "FLOAT", "DRIFT",
            "GLIDE", "SLIDE", "SLINK", "CREEP", "CRAWL", "AMBLE", "MOSEY", "PLOD",
            "QUIET", "STILL", "PEACE", "SERENE", "GENTLE", "MELLOW", "SMOOTH"
        ],
        .confidence: [
            "CAN", "WIN", "OWN", "ACE", "TOP", "YES", "PRO", "FLY", "BOW", "VOW",
            "AIM", "ALL", "AND", "ANT", "ANY", "APE", "APT", "ARC", "ARE", "ARK",
            "ARM", "ART", "ASH", "ASK", "ATE", "AWE", "AXE", "AYE", "BAD", "BAG",
            "BAN", "BAR", "BAT", "BAY", "BEE", "BEG", "BET", "BIG", "BIN", "BIT",
            "BOB", "BOG", "BOX", "BOY", "BRA", "BUD", "BUG", "BUM", "BUN", "BUS",
            "BUT", "BUY", "CAB", "CAD", "CAM", "CAP", "CAR", "CAT", "COB", "COD",
            "COG", "COP", "COT", "COW", "COX", "COY", "CRY", "CUB", "CUD", "CUP",
            "CUR", "CUT", "DAB", "DAD", "DAM", "DAY", "DEN", "DEW", "DID", "DIE",
            "DIG", "DIM", "DIN", "DIP", "DOC", "DOE", "DOG", "DON", "DOT", "DRY",
            "DUB", "DUD", "DUE", "DUG", "DUN", "DUO", "DYE", "EAR", "EAT", "EEL",
            "EGG", "EGO", "ELF", "ELK", "ELM", "EMU", "END", "ERA", "ERR", "EVE",
            "EWE", "EYE", "FAD", "FAN", "FAR", "FAT", "FAX", "FED", "FEE", "FEN",
            "FEW", "FIG", "FIN", "FIR", "FIT", "FIX", "FLU", "FOB", "FOE", "FOG",
            "FOP", "FOR", "FOX", "FRY", "FUN", "FUR", "GAB", "GAG", "GAL", "GAP",
            "GAS", "GAY", "GEL", "GEM", "GET", "GIG", "GIN", "GNU", "GOB", "GOD",
            "GOT", "GUM", "GUN", "GUT", "GUY", "GYM", "HAD", "HAG", "HAM", "HAS",
            "HAT", "HAY", "HEM", "HEN", "HER", "HEW", "HEX", "HID", "HIM", "HIP",
            "HIS", "HIT", "HOB", "HOD", "HOE", "HOG", "HOP", "HOT", "HOW", "HUB",
            "HUE", "HUG", "HUM", "HUT", "ICE", "ICY", "ILL", "IMP", "INK", "INN",
            "BOLD", "SURE", "TRUE", "FIRM", "SELF", "BEST", "FAST", "GOOD", "HARD",
            "HIGH", "JUST", "KEEN", "LAST", "LOUD", "MAIN", "MOST", "MUCH", "MUST",
            "NEAT", "NEXT", "NICE", "ONLY", "OPEN", "OVER", "PAST", "PLUS", "PURE",
            "RARE", "REAL", "RICH", "SAFE", "SAME", "SUCH", "TALL", "THIS", "THUS",
            "TRUE", "VERY", "WARM", "WIDE", "WILD", "WISE", "ZERO", "ZEST", "ZONE",
            "BRAVE", "PROUD", "POWER", "TRUST", "WORTH", "NOBLE", "MIGHT", "FORCE",
            "GLORY", "HONOR", "VIGOR", "VALOR", "STEEL", "SPINE", "NERVE", "GUTS"
        ],
        .energy: [
            "GO", "RUN", "ZIP", "POP", "ZAP", "HOP", "JOG", "REV", "PEP", "VIM",
            "ACE", "ACT", "ADD", "AID", "AIM", "AIR", "ALL", "AND", "ANT", "ANY",
            "APE", "APT", "ARC", "ARE", "ARK", "ARM", "ART", "ASH", "ASK", "ATE",
            "AWE", "AXE", "AYE", "BAD", "BAG", "BAN", "BAR", "BAT", "BAY", "BEE",
            "BEG", "BET", "BIG", "BIN", "BIT", "BOB", "BOG", "BOW", "BOX", "BOY",
            "BRA", "BUD", "BUG", "BUM", "BUN", "BUS", "BUT", "BUY", "CAB", "CAD",
            "CAM", "CAN", "CAP", "CAR", "CAT", "COB", "COD", "COG", "COP", "COT",
            "COW", "COX", "COY", "CRY", "CUB", "CUD", "CUP", "CUR", "CUT", "DAB",
            "DAD", "DAM", "DAY", "DEN", "DEW", "DID", "DIE", "DIG", "DIM", "DIN",
            "DIP", "DOC", "DOE", "DOG", "DON", "DOT", "DRY", "DUB", "DUD", "DUE",
            "DUG", "DUN", "DUO", "DYE", "EAR", "EAT", "EEL", "EGG", "EGO", "ELF",
            "ELK", "ELM", "EMU", "END", "ERA", "ERR", "EVE", "EWE", "EYE", "FAD",
            "FAN", "FAR", "FAT", "FAX", "FED", "FEE", "FEN", "FEW", "FIG", "FIN",
            "FIR", "FIT", "FIX", "FLU", "FLY", "FOB", "FOE", "FOG", "FOP", "FOR",
            "FOX", "FRY", "FUN", "FUR", "GAB", "GAG", "GAL", "GAP", "GAS", "GAY",
            "GEL", "GEM", "GET", "GIG", "GIN", "GNU", "GOB", "GOD", "GOT", "GUM",
            "GUN", "GUT", "GUY", "GYM", "HAD", "HAG", "HAM", "HAS", "HAT", "HAY",
            "HEM", "HEN", "HER", "HEW", "HEX", "HID", "HIM", "HIP", "HIS", "HIT",
            "HOB", "HOD", "HOE", "HOG", "HOP", "HOT", "HOW", "HUB", "HUE", "HUG",
            "FIRE", "GLOW", "RUSH", "BUZZ", "PUMP", "PUSH", "BOLT", "ZEST", "HEAT",
            "BURN", "BLAZE", "FLASH", "SPARK", "SURGE", "BLAST", "BURST", "CRACK",
            "BANG", "BOOM", "SLAM", "DASH", "RACE", "ZOOM", "WHIZ", "SPIN", "TURN",
            "FLIP", "JUMP", "KICK", "PUNT", "TOSS", "HURL", "FLING", "THROW",
            "DRIVE", "FORCE", "POWER", "MIGHT", "PUNCH", "POUND", "SMASH", "CRASH",
            "QUICK", "SWIFT", "RAPID", "BRISK", "LIVELY", "ACTIVE", "MOVING"
        ],
        .positive: [
            "JOY", "YAY", "WOW", "FUN", "WIN", "ACE", "AIM", "ALL", "AWE", "BIG",
            "CAN", "DAY", "EYE", "FAN", "GAL", "GEM", "GET", "GIG", "GOD", "GOT",
            "HAD", "HAS", "HAT", "HIP", "HIT", "HOT", "HUB", "HUE", "HUG", "HUM",
            "ICE", "ION", "ITS", "IVY", "JAM", "JAY", "JET", "JIG", "JOB", "JOG",
            "JOT", "JOY", "JUG", "KEN", "KEY", "KID", "KIN", "KIT", "LAB", "LAD",
            "LAP", "LAW", "LAY", "LED", "LEG", "LET", "LID", "LIP", "LIT", "LOG",
            "LOT", "LOW", "LUG", "MAN", "MAP", "MAT", "MAW", "MAY", "MEN", "MET",
            "MID", "MIX", "MOB", "MOD", "MOM", "MOP", "MOW", "MUD", "MUG", "MUM",
            "NAB", "NAG", "NAP", "NAY", "NET", "NEW", "NIB", "NIP", "NIT", "NOB",
            "NOD", "NOR", "NOT", "NOW", "NUB", "NUN", "NUT", "OAK", "OAR", "OAT",
            "ODD", "ODE", "OFF", "OFT", "OHM", "OIL", "OLD", "ONE", "OPT", "ORB",
            "ORE", "OUR", "OUT", "OWE", "OWL", "OWN", "PAD", "PAL", "PAN", "PAP",
            "PAR", "PAT", "PAW", "PAY", "PEA", "PEG", "PEN", "PEP", "PER", "PET",
            "PEW", "PIE", "PIG", "PIN", "PIT", "PLY", "POD", "POP", "POT", "POW",
            "PRO", "PRY", "PUB", "PUG", "PUN", "PUP", "PUT", "RAG", "RAM", "RAN",
            "RAP", "RAT", "RAW", "RAY", "RED", "RIB", "RID", "RIG", "RIM", "RIP",
            "ROB", "ROC", "ROD", "ROE", "ROT", "ROW", "RUB", "RUG", "RUN", "RUT",
            "RYE", "SAC", "SAD", "SAG", "SAP", "SAT", "SAW", "SAY", "SEA", "SET",
            "SEW", "SHE", "SHY", "SIN", "SIP", "SIS", "SIT", "SIX", "SKI", "SKY",
            "LOVE", "LIKE", "GOOD", "BEST", "COOL", "NICE", "KIND", "WARM", "TRUE",
            "FAIR", "FINE", "GLAD", "HOPE", "KEEN", "REAL", "SAFE", "SURE", "WELL",
            "WISE", "CALM", "COZY", "EASY", "FREE", "FULL", "GOLD", "GLOW", "GROW",
            "HAPPY", "LUCKY", "MERRY", "JOLLY", "SUNNY", "SWEET", "GREAT", "SUPER",
            "GRAND", "PRIME", "IDEAL", "NOBLE", "ROYAL", "BRAVE", "PROUD", "SMART"
        ],
        .mindful: [
            "SIT", "ZEN", "OHM", "HUM", "AIR", "AWE", "BED", "BOW", "CAL", "CHI",
            "COO", "CUP", "DAY", "DEW", "DIM", "EAR", "EAT", "ELF", "ERA", "EVE",
            "EYE", "FAN", "FAR", "FIG", "FIN", "FIT", "FLO", "FLY", "FOG", "FUN",
            "GAL", "GAP", "GEM", "GET", "GIG", "GOT", "GUM", "GUT", "HAM", "HAS",
            "HAT", "HAY", "HEM", "HEN", "HEW", "HEX", "HID", "HIP", "HIT", "HOB",
            "HOD", "HOG", "HOP", "HOT", "HOW", "HUB", "HUE", "HUG", "HUT", "ICE",
            "ICY", "IMP", "INK", "INN", "ION", "ITS", "IVY", "JAB", "JAM", "JAR",
            "JAW", "JAY", "JET", "JIG", "JOB", "JOG", "JOT", "JOY", "JUG", "KEN",
            "KEY", "KID", "KIN", "KIT", "LAB", "LAC", "LAD", "LAG", "LAP", "LAW",
            "LAX", "LAY", "LEA", "LED", "LEG", "LET", "LID", "LIE", "LIP", "LIT",
            "LOG", "LOT", "LOW", "LUG", "MAD", "MAN", "MAP", "MAR", "MAT", "MAW",
            "MAY", "MEN", "MET", "MID", "MIX", "MOB", "MOD", "MOM", "MOP", "MOW",
            "MUD", "MUG", "MUM", "NAB", "NAG", "NAP", "NAY", "NET", "NEW", "NIB",
            "NIP", "NIT", "NOB", "NOD", "NOR", "NOT", "NOW", "NUB", "NUN", "NUT",
            "OAK", "OAR", "OAT", "ODD", "ODE", "OFF", "OFT", "OIL", "OLD", "ONE",
            "OPT", "ORB", "ORE", "OUR", "OUT", "OWE", "OWL", "OWN", "PAD", "PAL",
            "PAN", "PAP", "PAR", "PAT", "PAW", "PAY", "PEA", "PEG", "PEN", "PEP",
            "PER", "PET", "PEW", "PIE", "PIG", "PIN", "PIT", "PLY", "POD", "POP",
            "POT", "POW", "PRO", "PRY", "PUB", "PUG", "PUN", "PUP", "PUT", "QUA",
            "MIND", "SOUL", "SELF", "FEEL", "KNOW", "WAKE", "GAZE", "LOOK", "SEEN",
            "VIEW", "HEAR", "HEED", "NOTE", "MARK", "SPOT", "FIND", "SEEK", "SCAN",
            "WATCH", "AWARE", "AWAKE", "ALERT", "CLEAR", "SHARP", "KEEN", "OPEN",
            "SENSE", "GRASP", "THINK", "PONDER", "MUSE", "DREAM", "DWELL", "PAUSE",
            "STILL", "QUIET", "PEACE", "CALM", "EASE", "REST", "RELAX", "BREATH"
        ],
        .strength: [
            "ARM", "LEG", "ABS", "FIT", "GYM", "RUN", "JOG", "HOP", "ZIP", "ZAP",
            "ACE", "ACT", "ADD", "AID", "AIM", "AIR", "ALL", "AND", "ANT", "ANY",
            "APE", "APT", "ARC", "ARE", "ARK", "ART", "ASH", "ASK", "ATE", "AWE",
            "AXE", "AYE", "BAD", "BAG", "BAN", "BAR", "BAT", "BAY", "BEE", "BEG",
            "BET", "BIG", "BIN", "BIT", "BOB", "BOG", "BOW", "BOX", "BOY", "BRA",
            "BUD", "BUG", "BUM", "BUN", "BUS", "BUT", "BUY", "CAB", "CAD", "CAM",
            "CAN", "CAP", "CAR", "CAT", "COB", "COD", "COG", "COP", "COT", "COW",
            "COX", "COY", "CRY", "CUB", "CUD", "CUP", "CUR", "CUT", "DAB", "DAD",
            "DAM", "DAY", "DEN", "DEW", "DID", "DIE", "DIG", "DIM", "DIN", "DIP",
            "DOC", "DOE", "DOG", "DON", "DOT", "DRY", "DUB", "DUD", "DUE", "DUG",
            "DUN", "DUO", "DYE", "EAR", "EAT", "EEL", "EGG", "EGO", "ELF", "ELK",
            "ELM", "EMU", "END", "ERA", "ERR", "EVE", "EWE", "EYE", "FAD", "FAN",
            "FAR", "FAT", "FAX", "FED", "FEE", "FEN", "FEW", "FIG", "FIN", "FIR",
            "FIT", "FIX", "FLU", "FLY", "FOB", "FOE", "FOG", "FOP", "FOR", "FOX",
            "FRY", "FUN", "FUR", "GAB", "GAG", "GAL", "GAP", "GAS", "GAY", "GEL",
            "GEM", "GET", "GIG", "GIN", "GNU", "GOB", "GOD", "GOT", "GUM", "GUN",
            "GUT", "GUY", "GYM", "HAD", "HAG", "HAM", "HAS", "HAT", "HAY", "HEM",
            "HEN", "HER", "HEW", "HEX", "HID", "HIM", "HIP", "HIS", "HIT", "HOB",
            "HOD", "HOE", "HOG", "HOP", "HOT", "HOW", "HUB", "HUE", "HUG", "HUM",
            "CORE", "BUFF", "FIRM", "HARD", "IRON", "HULK", "BULK", "MASS", "TONE",
            "FLEX", "PUMP", "LIFT", "PULL", "PUSH", "GRIP", "HOLD", "LOCK", "BIND",
            "BEAR", "HAUL", "DRAG", "HEAVE", "HOIST", "RAISE", "CARRY", "PRESS",
            "SQUAT", "LUNGE", "PLANK", "CRUNCH", "POWER", "FORCE", "MIGHT", "VIGOR",
            "STEEL", "SPINE", "NERVE", "GUTS", "BRAVE", "TOUGH", "HARDY", "STOUT"
        ]
    ]

    private static let letterFrequency: [Character: Int] = [
        "E": 12, "T": 9, "A": 8, "O": 7, "I": 7, "N": 7, "S": 6, "H": 6, "R": 6,
        "D": 4, "L": 4, "C": 3, "U": 3, "M": 3, "W": 2, "F": 2, "G": 2, "Y": 2,
        "P": 2, "B": 1, "V": 1, "K": 1, "J": 1, "X": 1, "Q": 1, "Z": 1
    ]

    static func randomWords(
        count: Int,
        difficulty: WordDifficulty,
        category: WordCategory? = nil,
        rng: inout SeededRandomGenerator
    ) -> [String] {
        var pool: [String] = []
        let lengthRange = difficulty.lengthRange

        if let cat = category {
            pool = wordsByCategory[cat]?.filter { lengthRange.contains($0.count) } ?? []
        } else {
            for (_, words) in wordsByCategory {
                pool.append(contentsOf: words.filter { lengthRange.contains($0.count) })
            }
        }

        pool = Array(Set(pool))
        pool.shuffle(using: &rng)

        return Array(pool.prefix(count))
    }

    static func randomLetter(rng: inout SeededRandomGenerator) -> Character {
        var weightedLetters: [Character] = []
        for (letter, weight) in letterFrequency {
            for _ in 0..<weight {
                weightedLetters.append(letter)
            }
        }
        let index = Int.random(in: 0..<weightedLetters.count, using: &rng)
        return weightedLetters[index]
    }

    static func allWords() -> [String] {
        var all: [String] = []
        for (_, words) in wordsByCategory {
            all.append(contentsOf: words)
        }
        return Array(Set(all))
    }
}
