--[[
   The Animal Hospital - ESP v5 + Full Turkish Translation
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local ANOMALY_REVEALS = {
    "DifferentEars", "DifferentFace", "SkinwalkerOpensMouth", "Static",
    "TwistNeck", "VoidPresence", "CursedPhoto", "BrokenBones",
    "HiddenFace", "LizInfectedFace"
}
local ANOMALY_TAGS = { "GhostAnomaly", "AnomalyShadow", "StalkerJumpscare", "Skinwalker" }
local SKINWALKER_PARTS = { "Gulp", "Tooth", "TongueMesh", "Spit", "Teeth" }

local espObjects = {}
local espEnabled = true
local anomalyCount = 0
local normalCount = 0
local NAMETAG_RANGE = 14
local HIGHLIGHT_RANGE = 40

local categoryFilters = {
    Ghost = true, Stalker = true, Hider = true,
    TallMonster = true, Skinwalker = true, Shadow = true,
    Normal = true, ESP_MASTER = true
}

-- Category display names
local CATEGORY_NAMES = {
    Ghost = "Ghost", Stalker = "Stalker", Hider = "Hider",
    TallMonster = "Tall Monster", Skinwalker = "Skinwalker", Shadow = "Shadow",
    Normal = "Normal"
}

-- ==========================================
-- TRANSLATION - Complete Turkish Dictionary
-- ==========================================
local langData = {}
local isTurkish = false

local TR = {
    -- === ANA UI ===
    Objective = "Görev",
    ["Stamp the form"] = "Formu damgala",
    ["Stamp Forms"] = "Formları Damgala",
    SANITY = "AKIL",
    sanity = "akıl",
    Intern = "Stajyer",
    ["SHIFT FINISHED"] = "VARDİYA BİTTİ",
    ["Shift Finished"] = "Vardiya Bitti",
    ["Your bag is full!"] = "Çantan doldu!",
    ["NO SIGNAL"] = "SİNYAL YOK",
    ["NO SIGNAL - REQUIRES FIX"] = "SİNYAL YOK - TAMİR GEREK",
    CAM = "KAM",
    EXIT = "ÇIKIŞ",
    exit = "çıkış",
    Inventory = "Envanter",

    -- === VARDIYARAPOR ===
    Shift = "Vardiya",
    ["Shift 2"] = "Vardiya 2",
    ["Excellent"] = "Mükemmel",
    ["SHIFT REPORT"] = "VARDİYA RAPORU",
    ["Hospital Performance:"] = "Hastane Performansı:",
    ["Patients Treated:"] = "Tedavi Edilen:",
    ["Anomalies Prevented"] = "Engellenen Anomaliler",
    ["Visitors Admitted:"] = "Kabul Edilen Ziyaretçiler:",
    ["Animal Deaths:"] = "Hayvan Ölümleri:",
    ["Bonus!"] = "Bonus!",
    BEST = "EN İYİ",
    ["Hospital Deaths"] = "Hastane Ölümleri",

    -- === UYARILAR ===
    ["Don't look up"] = "Yukarı bakma",
    ["Patient being eaten in room"] = "Hasta yeniyor oda",
    EMERGENCIES = "ACİL DURUMLAR",
    ["Run!"] = "Kaç!",
    ["!"] = "!",

    -- === ÖLÜM ===
    ["YOU DIED"] = "ÖLDÜN",
    ["Your sanity got depleted and went mad"] = "Aklın tükendi ve çıldırdın",
    ["Returning in"] = "Dönüş:",
    ["Lives"] = "Can",
    ["Lives 3/3"] = "Can 3/3",

    -- === REVIVE ===
    ["Revive Everyone"] = "Herkesi Dirilt",
    ["Play Again (0/1)"] = "Tekrar Oyna (0/1)",
    ["Self Revive"] = "Kendini Dirilt",
    ["Revive"] = "Dirilt",

    -- === DURUM ===
    ["fainted"] = "bayıldı",
    ["Fainted"] = "Bayıldı",

    -- === DIYALOG ===
    ["(tap on one option)"] = "(bir seçeneğe dokun)",
    Done = "Tamam",
    ["Goodbye!"] = "Hoşçakal!",
    ["Accept"] = "Kabul Et",
    ["Decline"] = "Reddet",
    ["OK"] = "Tamam",
    ["Ask to Leave"] = "Ayrılmayı İste",
    ["you make yourself a coffee"] = "kendine kahve yapıyorsun",
    ["The doctor is arriving"] = "Doktor geliyor",
    ["the doctor is arriving"] = "doktor geliyor",
    ["Some advice:"] = "Tavsiye:",
    ["doctor"] = "doktor",

    -- === ZAMAN ===
    s = "",
    ["46s"] = "46sn",
    ["47s"] = "47sn",
    ["99s"] = "99sn",
    ["120s"] = "120sn",

    -- === GÜÇLENDIRME ===
    ["Boost:"] = "Güçlendirme:",
    ["Boost: 120s"] = "Güçlendirme: 120sn",
    ["+5 Coffee"] = "+5 Kahve",

    -- === ENVANTER ===
    ["Remove From Hotbar"] = "Hızlı çubuktan kaldır",
    ["Select/Swap"] = "Seç/Değiştir",
    ["Close Backpack"] = "Çantayı kapat",

    -- === PROMPT ACTION ===
    ["Check In"] = "Giriş Yap",
    Heal = "İyileştir",
    Examine = "İncele",
    Inspect = "İncele",
    ["Pick Up"] = "Al",
    Open = "Aç",
    Close = "Kapat",
    Use = "Kullan",
    Drop = "Bırak",
    Store = "Sakla",
    Buy = "Satın Al",
    ["Buy Gun"] = "Tabanca Satın Al",
    Sell = "Sat",
    Interact = "Etkileşim",
    Talk = "Konuş",
    Pat = "Sev",
    Feed = "Besle",
    ["Take Photo"] = "Fotoğraf Çek",
    Take = "Al",
    Register = "Kayıt Oluştur",
    ["Print Badge"] = "Kart Bastır",
    ["Take DNA Sample"] = "DNA Örneği Al",
    ["Apply Treatment"] = "Tedavi Uygula",
    ["Analyze Sample"] = "Örneği Analiz Et",
    ["Process Results"] = "Sonuçları İşle",
    ["Begin X-Ray"] = "Röntgen Çek",
    Begin = "Başlat",
    Collect = "Topla",
    ["Turn On"] = "Aç",
    ["Set Up"] = "Hazırla",
    ["Prepare Patient"] = "Hastayı Hazırla",
    ["Trash Item"] = "Çöpe At",
    Coffee = "Kahve",
    ["Chocolate (60% Sanity)"] = "Çikolata (%60 Akıl)",
    ["Security Cams"] = "Güvenlik Kameraları",
    ["Return Taser"] = "Taser'ı Geri Ver",
    ["Return Fire Ext."] = "Yangın Söndürücüyü Geri Ver",
    ["Break Poster"] = "Posteri Kır",
    Locked = "Kilitli",
    ["Scan Identity"] = "Kimlik Tara",
    ["Un-jam button."] = "Butonu aç.",
    ["Broken Baby Doll"] = "Kırık Bebek",
    Door = "Kapı",
    ["Jumpscare All"] = "Herkese Korkutma",

    -- === TEDAVI / İLAÇLAR ===
    ["Medicine"] = "İlaç",
    ["Bandages"] = "Sargı Bezi",
    ["Bandage"] = "Sargı Bezi",
    ["Ointment"] = "Merhem",
    ["Thermo"] = "Termometre",
    ["Medkit"] = "Medikit",
    ["Cough Syrup"] = "Öksürük Şurubu",
    ["Maple Syrup"] = "Akçaağaç Şurubu",
    ["Eye Drops"] = "Göz Damlası",
    ["Herbs"] = "Bitkiler",
    ["IV Drops"] = "IV Damla",
    ["Antibiotics"] = "Antibiyotik",
    ["Transplant"] = "Nakil",
    ["Organ"] = "Organ",
    ["Scissors"] = "Makas",
    ["Scalpel"] = "Neşter",
    ["RunCola"] = "KoşKol",
    ["Treatment"] = "Tedavi",
    ["treatment"] = "tedavi",

    -- === HASTALIKLAR ===
    ["Dehydration"] = "Dehidrasyon",
    ["Stomach Ache"] = "Karın Ağrısı",
    ["Head Ache"] = "Baş Ağrısı",
    ["Bleeding"] = "Kanama",
    ["Fever"] = "Ateş",
    ["Low Sugar"] = "Düşük Şeker",
    ["Canadian"] = "Kanada",
    ["Flu"] = "Grip",
    ["Rash"] = "Döküntü",
    ["Dried Eyes"] = "Kuru Gözler",
    ["Bruises"] = "Morluklar",

    -- === NPC / VISITOR ===
    ["Visitor"] = "Ziyaretçi",
    ["visitor"] = "ziyaretçi",
    ["Patient"] = "Hasta",
    ["patient"] = "hasta",

    -- === DIYALOG KALIPLARI ===
    ["Hello, my name is "] = "Merhaba, benim adım ",
    ["I'm "] = "Ben ",
    ["Sup, I'm "] = "Selam, ben ",
    ["Hey..."] = "Hey...",
    ["Hello"] = "Merhaba",
    ["Hi"] = "Merhaba",
    ["Goodbye"] = "Hoşçakal",
    ["Please"] = "Lütfen",
    ["Thank you"] = "Teşekkürler",
    ["Thanks"] = "Teşekkürler",
    ["Come with me"] = "Benimle gel",
    ["Follow me"] = "Beni takip et",
    ["This way"] = "Bu taraftan",
    ["Wait here"] = "Burada bekle",
    ["Wait"] = "Bekle",
    ["I'll be right back"] = "Hemen döneceğim",
    ["Let me examine you"] = "Seni muayene edeyim",
    ["Everything looks good"] = "Her şey iyi görünüyor",
    ["You're healed"] = "İyileştin",
    ["All done"] = "Tamamlandı",
    ["You can go now"] = "Şimdi gidebilirsin",
    ["What's wrong?"] = "Sorun nedir?",
    ["Where does it hurt?"] = "Neren ağrıyor?",
    ["Does this hurt?"] = "Burası ağrıyor mu?",
    ["I need help"] = "Yardıma ihtiyacım var",
    ["Help me"] = "Bana yardım et",
    ["Over here"] = "Burada",
    ["I'm scared"] = "Korkuyorum",
    ["Don't worry"] = "Endişelenme",
    ["It's okay"] = "Sorun yok",
    ["Stay calm"] = "Sakin ol",
    ["Breathe"] = "Nefes al",
    ["Almost done"] = "Neredeyse bitti",
    ["Just a moment"] = "Bir dakika",
    ["I found something"] = "Bir şey buldum",
    ["Look at this"] = "Şuna bak",
    ["What is that?"] = "O nedir?",
    ["Something is wrong"] = "Bir şeyler yanlış",
    ["I don't feel good"] = "İyi hissetmiyorum",
    ["Are you okay?"] = "İyi misin?",
    ["I'm fine"] = "İyiyim",
    ["Stay here"] = "Burada kal",
    ["Don't move"] = "Kıpırdama",
    ["I'll get help"] = "Yardım getireceğim",
    ["Wait for me"] = "Beni bekle",
    ["Let's go"] = "Gidelim",
    ["Hurry"] = "Acele et",
    ["Quick"] = "Çabuk",
    ["This is an emergency"] = "Bu bir acil durum",
    ["Code blue"] = "Kod mavi",
    ["Everything is fine"] = "Her şey yolunda",
    ["False alarm"] = "Yanlış alarm",
    ["Just a check-up"] = "Sadece bir kontrol",
    ["Routine examination"] = "Rutin muayene",
    ["Your results are ready"] = "Sonuçların hazır",
    ["The doctor will see you now"] = "Doktor şimdi seni görecek",
    ["Please have a seat"] = "Lütfen otur",
    ["Make yourself comfortable"] = "Rahatına bak",
    ["Report to the chemist"] = "Eczaneye rapor ver",
    ["Report to the"] = "Rapor ver",
    ["chemist"] = "eczacı",
    ["security cameras"] = "güvenlik kameraları",
    ["taser"] = "taser",
    ["Use it wisely."] = "Akıllıca kullan.",
    ["I will fix"] = "Tamir edeceğim",
    ["I will unlock"] = "Kilidini açacağım",
    ["for you"] = "senin için",
    ["advice"] = "tavsiye",
    ["My advice"] = "Tavsiyem",
    ["Don't trust anyone here"] = "Kimseye güvenme burada",
    ["Just keep working"] = "Sadece çalışmaya devam et",
    ["If things get strange"] = "İşler garipleşirse",
    ["strange"] = "garip",

    -- === UPGRADE SHOP ===
    ["Better Printers"] = "Gelişmiş Yazıcılar",
    ["Max Printers"] = "Maksimum Yazıcılar",
    ["Analyzer"] = "Analizör",
    ["Printer"] = "Yazıcı",
    ["25% Faster computers"] = "%25 Daha Hızlı Bilgisayarlar",
    ["33% Faster computers"] = "%33 Daha Hızlı Bilgisayarlar",
    ["25% Faster Printers"] = "%25 Daha Hızlı Yazıcılar",
    ["20% Faster Printers"] = "%20 Daha Hızlı Yazıcılar",

    -- === DİĞER ===
    ["v288"] = "v288",
    ["$999"] = "999$",
    ["$63"] = "63$",
    ["$0"] = "0$",
    ["$10,000"] = "10.000$",
    ["100%"] = "%100",
    ["66%"] = "%66",
    ["67%"] = "%67",
    ["73%"] = "%73",
    ["99s"] = "99sn",
    ["120s"] = "120sn",
    ["30"] = "30",
    ["2"] = "2",
    ["5"] = "5",

    -- === PROMPSHOP ===
    ["Gun"] = "Tabanca",
    ["Scanner"] = "Tarayıcı",
    ["Fire Extinguisher"] = "Yangın Söndürücü",
    ["Deployable Camera"] = "Kurulabilir Kamera",
    ["Large Run Cola"] = "Büyük KoşKol",
    ["X-Taser"] = "X-Taser",
    ["Instant Brew"] = "Anında Demle",
    ["Instant Taser"] = "Anında Taser",
    ["Jumpscare All"] = "Herkese Korkutma",
    ["Reroll Shop"] = "Mağazayı Yenile",

    -- === TÜM DİYALOGLAR ===
    ["I'm here for my appointment..."] = "Randevum için buradayım...",
    ["I'm here for my appointment"] = "Randevum için buradayım",
    ["I have an appointment..."] = "Randevum var...",
    ["I have an appointment"] = "Randevum var",
    ["AAAAH!! I'M ON FIRE!!"] = "AAAAH!! YANIYORUM!!",
    ["I NEED HELP!!!"] = "YARDIM LAZIM!!!",
    ["Thanks, I will be in "] = "Teşekkürler, ",
    ["I will be in "] = "",
    ["I got "] = "",
    ["ROOM "] = "ODA ",
    ["! OK!! AHH!!"] = "! TAMAM!! AHH!!",
    ["...!"] = "...!",
    ["You must be the new hire, I'm "] = "Yeni çalışan sen olmalısın, ben ",
    ["Some advice: If things get strange, just keep working."] = "Tavsiye: İşler garipleşirse, çalışmaya devam et.",
    ["I will fix up the shutters and security cameras for you."] = "Panjurları ve güvenlik kameralarını senin için tamir edeceğim.",
    ["shutters"] = "panjurlar",
    ["security cameras"] = "güvenlik kameraları",
    ["I'm opening new facilities for you."] = "Senin için yeni birimler açıyorum.",
    ["supplies shop"] = "malzeme dükkanı",
    ["limited time"] = "sınırlı süre",
    ["The supplies shop will be open for a limited time each shift."] = "Malzeme dükkanı her vardiyada sınırlı süreliğine açık olacak.",
    ["the shop is open!"] = "dükkan açık!",
    ["shift"] = "vardiya",
    ["Some patients may seem... unstable..."] = "Bazı hastalar... dengesiz görünebilir...",
    ["unstable"] = "dengesiz",
    ["Make sure to use the photo and cameras. Stay alert."] = "Fotoğraf ve kameraları kullanmayı unutma. Tetikte ol.",
    ["I will unlock the taser. Use it wisely."] = "Taser'ın kilidini açacağım. Akıllıca kullan.",
    ["Your sanity is important. Don't DIE on me."] = "Aklın önemli. SAKIN ÖLME bana.",
    ["DIE"] = "ÖLME",
    ["And take good care of the patients."] = "Ve hastalara iyi bak.",
    ["If the hospital records 3 DEATHS it's over."] = "Hastane 3 ÖLÜM kaydederse iş biter.",
    ["DEATHS"] = "ÖLÜM",
    ["There's been a huge anomaly attack!"] = "Büyük bir anomali saldırısı oldu!",
    ["anomaly attack"] = "anomali saldırısı",
    ["6 people died and many more were hurt."] = "6 kişi öldü ve daha fazlası yaralandı.",
    ["Be prepared, the ambulance is coming..."] = "Hazır ol, ambulans geliyor...",
    ["ambulance"] = "ambulans",
    ["Good job, the emergency is over for now."] = "İyi iş, acil durum şimdilik bitti.",
    ["More ambulances will come, be prepared."] = "Daha fazla ambulans gelecek, hazırlıklı ol.",
    ["Here is a bonus for your work."] = "Çalışman için bir bonus.",
    ["bonus"] = "bonus",
    ["Being small has its advantages..."] = "Küçük olmanın avantajları var...",
    ["I hear things... I see things..."] = "Şeyler duyuyorum... Şeyler görüyorum...",
    ["It's a dangerous job..."] = "Tehlikeli bir iş...",
    ["You are a good guy..."] = "İyi adamsın...",
    ["My name is "] = "Benim adım ",
    ["My advice... Don't trust anyone here..."] = "Tavsiyem... Kimseye güvenme burada...",
    ["The people with suitcases are hiding secrets..."] = "Bavullu insanlar sırlar saklıyor...",
    ["Something evil is going on here."] = "Burada kötü bir şeyler dönüyor.",
    ["Stay alert..."] = "Tetikte ol...",
    ["You know, I'm starting to like you."] = "Biliyor musun, senden hoşlanmaya başlıyorum.",
    ["People on the street think I'm some kind of anomaly :("] = "Sokaktakiler beni bir tür anomali sanıyor :(",
    ["But you treat me just like anyone else. I appreciate that..."] = "Ama sen bana herkes gibi davranıyorsun. Bunu takdir ediyorum...",
    ["I may need to disappear for a while..."] = "Bir süreliğine kaybolmam gerekebilir...",
    ["The Animal Corporation is after me..."] = "Hayvan Şirketi peşimde...",
    ["But first I want to chat with you..."] = "Ama önce seninle sohbet etmek istiyorum...",
    ["Slow night, huh? Just how I like 'em."] = "Sakin gece, ha? Tam benlik.",
    ["You're not bad company, you know that?"] = "Fena bir arkadaş değilsin, biliyor musun?",
    ["Most folks don't even look down here."] = "Çoğu kişi aşağıya bile bakmaz.",
    ["Funny thing about being a rat..."] = "Fare olmanın komik yanı...",
    ["Everyone screams. Nobody offers cheese."] = "Herkes çığlık atar. Kimse peynir teklif etmez.",
    ["Ha... old joke. Still gets me though."] = "Ha... eski şaka. Ama hala güldürüyor.",
    ["...Anyway. I wanted to tell you something."] = "...Neyse. Sana bir şey söylemek istiyordum.",
    ["I had a twin sister. Rattina..."] = "İkiz kız kardeşim vardı. Rattina...",
    ["Smart one in the family, that's for sure."] = "Ailenin zeki olanı, orası kesin.",
    ["She worked for the Animal Corporation."] = "Hayvan Şirketi için çalışıyordu.",
    ["Then one day... she just vanished."] = "Sonra bir gün... kayboldu.",
    ["No note. No goodbye. Nothing."] = "Not yok. Hoşçakal yok. Hiçbir şey yok.",
    ["I've been looking for her ever since..."] = "O zamandan beri onu arıyorum...",
    ["...Sorry. Didn't mean to get heavy."] = "...Üzgünüm. Ağırlaşmak istememiştim.",
    ["You know what I do like?"] = "Neyi severim biliyor musun?",
    ["The quiet hours. Just me and the vents."] = "Sessiz saatler. Sadece ben ve havalandırmalar.",
    ["Whole place to myself. It's peaceful."] = "Her yer bana kaldı. Huzurlu.",
    ["...Thanks for listening. Means a lot."] = "...Dinlediğin için teşekkürler. Çok anlamlı.",
    ["This is our goodbye... for now."] = "Bu bizim hoşçakalımız... şimdilik.",
    ["Name's Ron... from accounting."] = "Adım Ron... muhasebeden.",
    ["You ever wonder why they keep hiring new people?"] = "Neden sürekli yeni insan alıyorlar hiç merak ettin mi?",
    ["...Never mind."] = "...Boşver.",
    ["Still here? Huh."] = "Hala burada mısın? Ha.",
    ["The last guy got eaten by the bed monster."] = "Son adam yatak canavarı tarafından yenildi.",
    ["That's why I always carry maple syrup with me."] = "Bu yüzden yanımda hep akçaağaç şurubu taşırım.",
    ["You want to know a secret?"] = "Bir sır öğrenmek ister misin?",
    ["They're testing something here."] = "Burada bir şey test ediyorlar.",
    ["testing"] = "test",
    ["The patients... they're not sick. They're infected."] = "Hastalar... hasta değiller. Enfekte olmuşlar.",
    ["infected"] = "enfekte",
    ["I work for the Corporation, I process the paperwork every night..."] = "Şirket için çalışıyorum, her gece evrak işlerini hallederim...",
    ["Some people go mad over it. You know.. hollowed eyes and stuff..."] = "Bazıları bu yüzden deliriyor. Bilirsin.. oyuk gözler ve falan...",
    ["It's grueling work. That's why coffee is important."] = "Yorucu bir iş. Bu yüzden kahve önemli.",
    ["Ever read the hospital discharge logs?"] = "Hastane çıkış kayıtlarını hiç okudun mu?",
    ["The Corporation owns this place but they hide the logs."] = "Şirket burayı yönetiyor ama kayıtları saklıyorlar.",
    ["Pretty sketchy..."] = "Oldukça şüpheli...",
    ["They moved the old files last month."] = "Geçen ay eski dosyaları taşıdılar.",
    ["Said it was a routine cleanup."] = "Rutin temizlik olduğunu söylediler.",
    ["routine cleanup"] = "rutin temizlik",
    ["Lot of smoke for a routine cleanup."] = "Rutin temizlik için çok fazla duman.",
    ["I once saw eyes staring at me from the ceiling..."] = "Bir keresinde tavandan bana bakan gözler gördüm...",
    ["The doctor at the time panicked looking for eye drops."] = "O zamanki doktor göz damlası ararken panikledi.",
    ["Then *POOF*, he was gone."] = "Sonra *PUFF*, gitmişti.",
    ["You ever feel someone watching you from the corner of your eyes?"] = "Göz ucunla birinin sana baktığını hissettin mi hiç?",
    ["Yeah...I used to work with that guy."] = "Evet... o adamla çalışırdım.",
    ["Just make sure not to stare at him. He is shy"] = "Sadece ona bakma. Utangaçtır",
    ["That rat was in my office once..."] = "O fare bir keresinde ofisime girmişti...",
    ["Chewed through some experiment reports I wasn't supposed to see."] = "Görmemem gereken bazı deney raporlarını kemirdi.",
    ["Did me a favor, honestly."] = "Bana iyilik yaptı, dürüst olmak gerekirse.",
    ["We've been working so hard, we can't rest."] = "Çok sıkı çalışıyoruz, dinlenemiyoruz.",
    ["The BOSS is furious... why did I accept this job?"] = "PATRON çok sinirli... neden bu işi kabul ettim?",
    ["BOSS"] = "PATRON",
    ["I need to get treated before the meeting with him."] = "Onunla toplantıdan önce tedavi olmam lazım.",
    ["Hey there, friend, I'm "] = "Merhaba dostum, ben ",
    ["Can you give me a coffee? I had a long day..."] = "Bana bir kahve verir misin? Uzun bir gün geçirdim...",
    ["coffee: brewing 120s increase sanity"] = "kahve: demleniyor 120sn akıl artışı",
    ["brewing"] = "demleniyor",
    ["increase sanity"] = "akıl artışı",
    ["What's taking so long?"] = "Bu ne kadar sürecek?",
    ["I'm getting tired of waiting."] = "Beklemekten yoruldum.",
    ["Im getting tired of waiting."] = "Beklemekten yoruldum.",
    ["Whats taking so long?"] = "Bu ne kadar sürecek?",
    ["-1 Job Stress"] = "-1 İş Stresi",
    ["Job Stress"] = "İş Stresi",
    ["I hope you're not new at this."] = "Umarım bu işte yeni değilsindir.",
    ["I hope you re not new at this."] = "Umarım bu işte yeni değilsindir.",
    ["I have other things to do, do you know"] = "Yapacak başka işlerim var, biliyor musun",
    ["Is this going to take long"] = "Bu uzun sürecek mi",
    ["Can you speed it up a bit"] = "Biraz hızlandırabilir misin",
    ["Can you speed it us a bit"] = "Biraz hızlandırabilir misin",
    ["Hurry up!"] = "Acele et!",
    ["Hurry up"] = "Acele et",
    ["I came to visit someone"] = "Birini ziyarete geldim",
    ["Death ritual in room 4"] = "Oda 4'te ölüm ritüeli",
    ["Death ritual in room"] = "Ölüm ritüeli oda",
    ["the shop is open"] = "dükkan açık",
    ["Upgrade Extra check in window"] = "Gelişmiş Ek Giriş Penceresi",
    ["Check in window"] = "Giriş Penceresi",
    ["Upgrade 25% Faster Printers"] = "%25 Daha Hızlı Yazıcı Yükseltmesi",
    ["Faster Printers"] = "Daha Hızlı Yazıcılar",
    ["Tool Use to scan a patient for anomalies"] = "Hastayı anomali için tarama aleti",
    ["1 use"] = "1 kullanım",
    ["WHAT!? No service?"] = "NE!? Hizmet yok mu?",
    ["No service"] = "Hizmet yok",
    ["I'm Midnight Spiders"] = "Ben Midnight Spiders",
    ["Came to visit someone"] = "Birini ziyarete geldim",
    ["coffee"] = "kahve",
    ["Coffee"] = "Kahve",
    ["Im here for my appointment"] = "Randevum için buradayım",

    -- === Coffee Guy ===
    ["Can you give me a coffee? I had a long day..."] = "Bana bir kahve verir misin? Uzun bir gündü...",
    ["Hello friend! Can I get another coffee?"] = "Merhaba dostum! Bir kahve daha alabilir miyim?",
    ["Delicious..."] = "Lezzetli...",
    ["Thanks friend, I needed that... I will remember this."] = "Sağol dostum, ihtiyacım vardı... Bunu unutmayacağım.",
    ["You are the best..."] = "En iyisisin...",
    ["May I ask for a favor, friend?"] = "Bir iyilik isteyebilir miyim dostum?",
    ["Can you keep this suitcase safe for a while?"] = "Bu valizi bir süreliğine saklar mısın?",
    ["suitcase"] = "valiz",
    ["You know friend...I need to ask you a favor..."] = "Biliyor musun dostum... bir iyilik istemem gerek...",
    ["Could you use that camera to take a picture of me?"] = "Şu kamerayı kullanıp benim fotoğrafımı çeker misin?",
    ["You truly are a friend, thanks for the photo..."] = "Gerçek bir dostsun, fotoğraf için teşekkürler...",
    ["Hello! Can I get a coffee, friend?"] = "Merhaba! Bir kahve alabilir miyim dostum?",
    ["I have been thinking, and I want to ask you for a favor..."] = "Düşünüyordum da, senden bir iyilik isteyecektim...",
    ["Can I bother you with a Scalpel?"] = "Seni bir Neşter ile rahatsız edebilir miyim?",
    ["This will help a lot, thanks friend!"] = "Bu çok yardımcı olacak, sağol dostum!",
    ["Oh! I'm taking my suitcase with me, bye friend!"] = "Oh! Valizimi alıyorum, görüşürüz dostum!",
    ["My dearest friend, something came up..."] = "En değerli dostum, bir şey çıktı...",
    ["something came up"] = "bir şey çıktı",
    ["I need you to let me hide with you for a bit"] = "Seninle bir süre saklanmama izin vermeni istiyorum",
    ["hide with you"] = "seninle saklanmak",

    -- === Police / Serial Killer ===
    ["We are currently tracking a dangerous serial killer..."] = "Şu anda tehlikeli bir seri katili takip ediyoruz...",
    ["serial killer"] = "seri katil",
    ["SERIAL KILLER"] = "SERİ KATİL",
    ["This is his picture... Have you seen him?"] = "Bu onun fotoğrafı... Onu gördün mü?",
    ["Oh...you better watch out, I don't like being refused..."] = "Oh...dikkat etsen iyi olur, reddedilmekten hoşlanmam...",
    ["Alright, if you see anything suspicious, let me know..."] = "Peki, şüpheli bir şey görürsen bana haber ver...",
    ["THAT'S THE SERIAL KILLER!!! ARREST HIM!!"] = "BU SERİ KATİL!!! TUTUKLAYIN ONU!!",
    ["ARREST HIM"] = "TUTUKLAYIN ONU",
    ["Thank you so much for hiding me, friend..."] = "Beni sakladığın için çok teşekkürler dostum...",
    ["Take this suitcase as a token of my gratitude..."] = "Bu valizi şükranlarımın bir işareti olarak al...",
    ["I think it's best if I leave this place for good... Goodbye, friend..."] = "Sanırım burayı temelli terk etsem iyi olur... Hoşçakal dostum...",

    -- === Lisbeth ===
    ["My name is Lisbeth, but you can call me Liz!"] = "Adım Lisbeth ama bana Liz diyebilirsin!",
    ["I used to work for Animal Corp's news channel but I was fired"] = "Animal Corp'un haber kanalında çalışıyordum ama kovuldum",
    ["I had a huuuuge scoop, but they said it was fake"] = "Çok büyük bir haberim vardı ama sahte dediler",
    ["Ah!!! I know!!!!"] = "Ah!!! Biliyorum!!!!",
    ["Take my UV camera"] = "UV kameramı al",
    ["UV camera"] = "UV kamera",
    ["And snap a photo of"] = "Ve fotoğrafını çek",
    ["Will you help me with this?"] = "Bana yardım eder misin?",
    ["Thanks! The UV Camera is special, it can see things that are invisible to us..."] = "Teşekkürler! UV Kamera özel, bizim göremediklerimizi görebilir...",
    ["Remember, they need to be at the check in window for it to work."] = "Unutma, çalışması için giriş penceresinde olmaları gerek.",
    ["Now, I need to go, see you soon..."] = "Şimdi gitmem gerek, yakında görüşürüz...",
    ["Hey! Did you get the photo?"] = "Hey! Fotoğrafı aldın mı?",
    ["You must be wondering why I need this, right?"] = "Buna neden ihtiyacım olduğunu merak ediyor olmalısın, değil mi?",
    ["Well, I think all these anomalies are not a coincidence"] = "Şey, bence tüm bu anomaliler bir tesadüf değil",
    ["anomalies"] = "anomaliler",
    ["Something strange is going on and I'm doing an investigation"] = "Garip bir şeyler oluyor ve araştırma yapıyorum",
    ["And everything led me to this hospital."] = "Ve her şey beni bu hastaneye getirdi.",
    ["Now, I need you to take a photo of"] = "Şimdi, bir fotoğrafını çekmeni istiyorum",
    ["I know you can do it! Good luck!"] = "Başarabileceğini biliyorum! İyi şanslar!",
    ["Good luck!"] = "İyi şanslar!",
    ["Each patient you have been taking photos of has something in common"] = "Fotoğraflarını çektiğin her hastanın ortak bir yanı var",
    ["They have come here before"] = "Daha önce buraya gelmişler",
    ["Each patient visits the hospital multiple times across weeks"] = "Her hasta haftalar boyunca hastaneyi birden çok kez ziyaret ediyor",
    ["Even before you worked here, they were coming"] = "Sen burada çalışmaya başlamadan önce bile geliyorlardı",
    ["These photos are fantastic."] = "Bu fotoğraflar harika.",
    ["Here, take this."] = "İşte, bunu al.",
    ["I'm sure you noticed but these photos have something weird"] = "Fark etmişsindir ama bu fotoğraflarda garip bir şey var",
    ["It's like some kind of process is going on with the patients"] = "Sanki hastalarla ilgili bir süreç işliyor",
    ["They are transforming"] = "Dönüşüyorlar",
    ["transforming"] = "dönüşüyor",
    ["Now I need one last photo. This time, of"] = "Şimdi son bir fotoğrafa ihtiyacım var. Bu sefer,",
    ["You did it!!! This is exactly what I needed"] = "Başardın!!! Tam olarak ihtiyacım olan şey buydu",
    ["With these photos I can finally publish my story!"] = "Bu fotoğraflarla sonunda hikayemi yayınlayabilirim!",
    ["They didn't fire me because it was fake... they fired me because it was TRUE."] = "Beni sahte diye kovmadılar... GERÇEK diye kovdular.",
    ["TRUE"] = "GERÇEK",
    ["Thank you, friend!"] = "Teşekkürler dostum!",
    ["Oh... okay!! Maybe next time!"] = "Ah... tamam!! Belki başka zaman!",
    ["You wasted the photograph..."] = "Fotoğrafı boşa harcadın...",
    ["I cannot trust you with this anymore... Goodbye..."] = "Artık sana güvenemem... Hoşçakal...",
    ["camera"] = "kamera",

    -- === UPGRADE SHOP ===
    ["Animal Coins"] = "Hayvan Paraları",
    ["Second Check-in"] = "İkinci Giriş",
    ["Extra check in window"] = "Ek giriş penceresi",
    ["Faster Check-Ins"] = "Hızlı Girişler",
    ["Visitors check in faster"] = "Ziyaretçiler daha hızlı giriş yapar",
    ['"No Speaking" Sign'] = '"Konuşmak Yasak" Tabelası',
    ["Faster check in"] = "Daha hızlı giriş",
    ["Adv. DNA Synth"] = "Gelişmiş DNA Sentezi",
    ["50% Faster DNA analysis"] = "%50 Daha Hızlı DNA analizi",
    ["16GB RAM"] = "16GB RAM",
    ["Better Printers"] = "Gelişmiş Yazıcılar",
    ["Max Printers"] = "Maksimum Yazıcılar",
    ["20% Faster Printers"] = "%20 Daha Hızlı Yazıcılar",
    ["Medicine Pockets"] = "İlaç Cepleri",
    ["+1 Carry Capacity"] = "+1 Taşıma Kapasitesi",
    ["Running Shoes"] = "Koşu Ayakkabıları",
    ["Coffee Thermometer"] = "Kahve Termometresi",
    ["Coffee lasts longer"] = "Kahve daha uzun süre dayanır",
    ["Extinguisher Buddy"] = "Yangın Söndürücü Arkadaş",
    ["+1 Fire Extinguisher capacity"] = "+1 Yangın Söndürücü kapasitesi",
    ["Scanner Upgrade"] = "Tarayıcı Yükseltmesi",
    ["Better anomaly detection"] = "Daha iyi anomali tespiti",
    ["Nurse Outfit"] = "Hemşire Kıyafeti",
    ["Unlock Nurse class items"] = "Hemşire sınıfı eşyalarını aç",
    ["Bed Anchor"] = "Yatak Çapası",
    ["Patients wont flee"] = "Hastalar kaçmaz",
    ["Compact Storage"] = "Kompakt Depolama",
    ["+1 inventory capacity"] = "+1 envanter kapasitesi",
    ["Surgeon Outfit"] = "Cerrah Kıyafeti",
    ["Unlock Surgeon class items"] = "Cerrah sınıfı eşyalarını aç",
    ["Head Nurse Outfit"] = "Baş Hemşire Kıyafeti",
    ["Unlock Head Nurse class items"] = "Baş Hemşire sınıfı eşyalarını aç",
    ["Durable Shoes"] = "Dayanıklı Ayakkabılar",

    -- === TOOL SHOP ===
    ["Standard issue firearm"] = "Standart ateşli silah",
    ["Place a security camera"] = "Güvenlik kamerası yerleştir",
    ["Stun an anomaly temporarily"] = "Anomaliyi geçici olarak sersemlet",
    ["Restores sanity"] = "Akıl yeniler",
    ["Extinguish fires"] = "Yangınları söndür",
    ["Brew coffee instantly"] = "Kahveyi anında demle",
    ["Use taser instantly"] = "Taser'ı anında kullan",
    ["Scare all players"] = "Tüm oyuncuları korkut",
    ["Reroll the shop items"] = "Mağaza ürünlerini yenile",

    -- === GENEL ===
    ["happy"] = "mutlu",
    ["sad"] = "üzgün",
    ["angry"] = "kızgın",
    ["scared"] = "korkmuş",
    ["tired"] = "yorgun",
    ["nervous"] = "gergin",
    ["confused"] = "kafası karışık",
    ["excited"] = "heyecanlı",
    ["waiting"] = "bekliyor",
    ["computer"] = "bilgisayar",
    ["monitor"] = "monitör",
    ["screen"] = "ekran",
    ["printer"] = "yazıcı",
    ["results"] = "sonuçlar",
    ["window"] = "pencere",
    ["counter"] = "tezgah",
    ["desk"] = "masa",
    ["chair"] = "sandalye",
    ["bed"] = "yatak",
    ["key"] = "anahtar",
    ["form"] = "form",
    ["badge"] = "kart",
    ["photo"] = "fotoğraf",
    ["sample"] = "örnek",
    ["sorry"] = "üzgünüm",
    ["welcome"] = "hoş geldin",
    ["yes"] = "evet",
    ["no"] = "hayır",
    ["okay"] = "tamam",
    ["sure"] = "tabii",
    ["fine"] = "iyi",
    ["great"] = "harika",
    ["perfect"] = "mükemmel",
    ["awesome"] = "harika",
    ["terrible"] = "korkunç",

    -- === EK DIYALOGLAR ===
    ["I want to check in as a patient..."] = "Hasta olarak giriş yapmak istiyorum...",
    ["I want to check in as a patient"] = "Hasta olarak giriş yapmak istiyorum",
    ["I want to check in as a visitor..."] = "Ziyaretçi olarak giriş yapmak istiyorum...",
    ["I want to check in as a visitor"] = "Ziyaretçi olarak giriş yapmak istiyorum",
    ["You can't just refuse me"] = "Beni reddedemezsin",
    ["You cant just refuse me"] = "Beni reddedemezsin",
    ["You cant just refuse me, I want to check in as a patient..."] = "Beni reddedemezsin, hasta olarak giriş yapmak istiyorum...",
    ["You can't just refuse me, I want to check in as a patient..."] = "Beni reddedemezsin, hasta olarak giriş yapmak istiyorum...",
    ["Im getting tired of waiting"] = "Beklemekten yoruldum",
    ["I have other things to do"] = "Yapacak başka işlerim var",
    ["Is this going to take long?"] = "Bu uzun sürecek mi?",
    ["Can you speed it up a bit?"] = "Biraz hızlandırabilir misin?",
    ["Hurry up"] = "Acele et",
    ["I came to visit someone"] = "Birini ziyarete geldim",
    ["Came to visit"] = "Ziyarete geldi",
    ["I have an appointment"] = "Randevum var",
    ["Lets go"] = "Gidelim",
    ["Lets go!"] = "Gidelim!",
    ["Follow me!"] = "Beni takip et!",
    ["Follow"] = "Takip et",
    ["Come"] = "Gel",
    ["Wait for me!"] = "Bekle beni!",
    ["Im ready"] = "Hazırım",
    ["Im ready!"] = "Hazırım!",
    ["Ready"] = "Hazır",
    ["Not ready"] = "Hazır değil",
    ["Skip"] = "Atla",
    ["Continue"] = "Devam et",
    ["Next"] = "İleri",
    ["Back"] = "Geri",
    ["Close"] = "Kapat",
    ["Start"] = "Başlat",
    ["Stop"] = "Dur",
    ["Help"] = "Yardım",
    ["Settings"] = "Ayarlar",
    ["Options"] = "Seçenekler",
    ["Menu"] = "Menü",
    ["Play"] = "Oyna",
    ["Leave"] = "Ayrıl",
    ["Join"] = "Katıl",
    ["Cancel"] = "İptal",
    ["Confirm"] = "Onayla",
    ["Save"] = "Kaydet",
    ["Load"] = "Yükle",
    ["Delete"] = "Sil",
    ["Edit"] = "Düzenle",
    ["Create"] = "Oluştur",
    ["Add"] = "Ekle",
    ["Remove"] = "Kaldır",
    ["Search"] = "Ara",
    ["Find"] = "Bul",
    ["Look"] = "Bak",
    ["Watch"] = "İzle",
    ["Listen"] = "Dinle",
    ["Speak"] = "Konuş",
    ["Say"] = "Söyle",
    ["Tell"] = "Anlat",
    ["Ask"] = "Sor",
    ["Answer"] = "Cevap ver",
    ["Explain"] = "Açıkla",
    ["Show"] = "Göster",
    ["Hide"] = "Gizle",
    ["Give"] = "Ver",
    ["Take"] = "Al",
    ["Bring"] = "Getir",
    ["Hold"] = "Tut",
    ["Carry"] = "Taşı",
    ["Push"] = "İt",
    ["Pull"] = "Çek",

    -- === EK DIYALOGLAR ===
    ["Are you serious"] = "Ciddi misin",
    ["youre turning me away"] = "beni geri ceviriyorsun",
    ["you're turning me away"] = "beni geri ceviriyorsun",
    ["Are you serious youre turning me away"] = "Ciddi misin beni geri ceviriyorsun",
    ["Are you serious you're turning me away"] = "Ciddi misin beni geri ceviriyorsun",
    ["I need to see a doctor"] = "Bir doktora gorunmem gerek",
    ["I need a doctor"] = "Doktora ihtiyacim var",
    ["Can you help me?"] = "Bana yardim eder misin?",
    ["Please help me"] = "Lutfen bana yardim et",
    ["Are you the doctor?"] = "Doktor sen misin?",
    ["Where is the doctor?"] = "Doktor nerede?",
    ["I need treatment"] = "Tedaviye ihtiyacim var",
    ["I am sick"] = "Hastayim",
    ["Im sick"] = "Hastayim",
    ["I feel sick"] = "Kendimi hasta hissediyorum",
    ["I feel terrible"] = "Berbat hissediyorum",
    ["I dont feel well"] = "Iyı hissetmiyorum",
    ["I don't feel well"] = "Iyı hissetmiyorum",
    ["I am in pain"] = "Aci cekiyorum",
    ["Im in pain"] = "Aci cekiyorum",
    ["It hurts"] = "Aciyor",
    ["Be careful"] = "Dikkatli ol",
    ["That was rude"] = "Bu kabaydi",
    ["Absolutely not"] = "Kesinlikle hayir",
    ["Forget it"] = "Unut gitsin",
    ["Never mind"] = "Bosver",
    ["I dont know"] = "Bilmiyorum",
    ["I don't know"] = "Bilmiyorum",
    ["Im not sure"] = "Emin degilim",
    ["I don't understand"] = "Anlamiyorum",
    ["What do you mean"] = "Ne demek istiyorsun",
    ["Can you explain"] = "Aciklayabilir misin",
    ["Come here"] = "Buraya gel",
    ["Go away"] = "Git buradan",
    ["Leave me alone"] = "Beni yalniz birak",
    ["Get out"] = "Disari cik",
    ["Excuse me"] = "Pardon",
    ["Sorry"] = "Uzgunum",
    ["Im sorry"] = "Uzgunum",
    ["I'm sorry"] = "Uzgunum",
    ["Forgive me"] = "Beni affet",
    ["No problem"] = "Sorun degil",
    ["Its okay"] = "Sorun yok",
    ["Calm down"] = "Sakin ol",
    ["Relax"] = "Rahatla",
    ["Slow down"] = "Yavas",
    ["You okay?"] = "Iyı misin?",
    ["Whats wrong?"] = "Sorun ne?",
    ["What's wrong?"] = "Sorun ne?",
    ["What happened?"] = "Ne oldu?",
    ["How are you?"] = "Nasilsin?",
    ["Nice to meet you"] = "Tanistigima memnun oldum",
    ["See you later"] = "Sonra gorusuruz",
    ["See you soon"] = "Yakinda gorusuruz",
    ["Take care"] = "Kendine iyi bak",
    ["Good luck"] = "Iyı sanslar",
}

local function stripTags(s)
    return s:gsub("<[^>]+>", "")
end

local function translateText(t)
    local clean = stripTags(t)
    if TR[clean] then return TR[clean] end
    if TR[t] then return TR[t] end
    local patterns = {
        { "Take sample from patient in Room (%d+)", function(n) return "Oda " .. n .. "'deki hastadan örnek al" end },
        { "Heal patient in Room (%d+)", function(n) return "Oda " .. n .. "'deki hastayı iyileştir" end },
        { "Check in patient in Room (%d+)", function(n) return "Oda " .. n .. "'deki hastayı kaydet" end },
        { "Take (.+) to Room (%d+)", function(item, n) return item .. "'yı oda " .. n .. "'ye götür" end },
        { "Treat the patient in Room (%d+)", function(n) return "Oda " .. n .. "'deki hastayı tedavi et" end },
        { "Treat (.+) in Room (%d+)", function(ill, n) return "Oda " .. n .. "'de " .. ill .. "'ı tedavi et" end },
        { "Thanks, I will be in room (%d+)", function(n) return "Teşekkürler, " .. n .. ". odada olacağım" end },
        { "Thanks, I will be in (%d+)", function(n) return "Teşekkürler, " .. n .. ". odada" end },
        { "I will be in room (%d+)", function(n) return n .. ". odada olacağım" end },
        { "I got room (%d+)", function(n) return "Oda " .. n .. "'yı aldım" end },
        { "Death ritual in room (%d+)", function(n) return "Oda " .. n .. "'de ölüm ritüeli" end },
        { "Room (%d+)", function(n) return "Oda " .. n end },
        { "Go to Room (%d+)", function(n) return "Oda " .. n .. "'ye git" end },
        { "Apply (.+) in Room (%d+)", function(treatment, n) return treatment .. "'ı oda " .. n .. "'de uygula" end },
        { "Check in patients", function() return "Hastaları kaydet" end },
        { "Check in (%d+) patient", function(n) return n .. " hastayı kaydet" end },
        { "ROOM (%d+)! OK!! AHH!!", function(n) return "ODA " .. n .. "! TAMAM!! AHH!!" end },
    }
    for _, p in ipairs(patterns) do
        local matches = { clean:match(p[1]) }
        if #matches > 0 and matches[1] ~= nil then
            return p[2](unpack(matches))
        end
    end
    for eng, tr in pairs(TR) do
        if #eng >= 3 and clean:find(eng, 1, true) then
            return clean:gsub(eng, tr)
        end
    end
    -- If text had tags but clean version didn't match, return the clean version
    if clean ~= t then return clean end
    return t  -- return original if nothing matched
end

local function restoreEnglish()
    for v, orig in pairs(langData) do
        if v and v.Parent then
            if type(orig) == "table" then
                if orig.ActionText then v.ActionText = orig.ActionText end
                if orig.ObjectText then v.ObjectText = orig.ObjectText end
            else
                v.Text = orig
            end
        end
    end
    langData = {}
    isTurkish = false
end

local function applyTurkish()
    local pg = player:FindFirstChild("PlayerGui")
    if not pg then return end
    if isTurkish then restoreEnglish() end
    langData = {}

    for _, v in pairs(pg:GetDescendants()) do
        if (v:IsA("TextLabel") or v:IsA("TextButton")) and v.Text and #v.Text > 0 and v.Text ~= " " then
            local clean = stripTags(v.Text)
            local tr = translateText(clean)
            if tr and tr ~= clean then langData[v] = v.Text; v.Text = tr end
        end
    end

    for _, v in pairs(CoreGui:GetDescendants()) do
        if (v:IsA("TextLabel") or v:IsA("TextButton")) and v.Text and #v.Text > 0 then
            local tr = TR[v.Text]
            if tr and tr ~= v.Text then langData[v] = v.Text; v.Text = tr end
        end
    end

    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("ProximityPrompt") then
            if v.ActionText and #v.ActionText > 0 then
                local tr = TR[v.ActionText] or translateText(v.ActionText)
                if tr ~= v.ActionText then
                    if not langData[v] then langData[v] = {} end
                    langData[v].ActionText = v.ActionText
                    v.ActionText = tr
                end
            end
            if v.ObjectText and #v.ObjectText > 0 then
                local tr = TR[v.ObjectText]
                if tr and tr ~= v.ObjectText then
                    if not langData[v] then langData[v] = {} end
                    langData[v].ObjectText = v.ObjectText
                    v.ObjectText = tr
                end
            end
        end
    end

    isTurkish = true
end

local function watchTextElement(v)
    if not v or not v:IsA("TextLabel") and not v:IsA("TextButton") then return end
    -- Immediate translate
    local t = v.Text
    if t and #t > 0 then
        if not langData[v] then
            local success, err = pcall(function() return v.Text end)
            if success then langData[v] = t end
        end
        local tr = translateText(t)
        if tr and tr ~= t then pcall(function() v.Text = tr end) end
    end
    -- Watch for changes
    local conn
    conn = v:GetPropertyChangedSignal("Text"):Connect(function()
        if not isTurkish then return end
        task.wait(0.05)
        local success, nt = pcall(function() return v.Text end)
        if not success or not nt or #nt == 0 then return end
        if not langData[v] then
            local ok = pcall(function() langData[v] = nt end)
        end
        local tr = translateText(nt)
        if tr and tr ~= nt then pcall(function() v.Text = tr end) end
    end)
end

local function startTranslationListener()
    local pg = player:FindFirstChild("PlayerGui")
    if not pg then return end
    -- Watch existing text elements
    for _, v in pairs(pg:GetDescendants()) do
        if v:IsA("TextLabel") or v:IsA("TextButton") then
            watchTextElement(v)
        end
    end
    -- Watch new text elements
    pg.DescendantAdded:Connect(function(v)
        task.wait(0.15)
        if not isTurkish then return end
        if v:IsA("TextLabel") or v:IsA("TextButton") then
            watchTextElement(v)
        end
    end)
end

-- ==========================================
-- ANOMALY DETECTION & ESP (unchanged)
-- ==========================================
local function getNPCType(npc)
    if npc:HasTag("GhostAnomaly") then return "Ghost", true end
    if npc:HasTag("StalkerJumpscare") then return "Stalker", true end
    if npc:HasTag("AnomalyShadow") then return "Shadow", true end
    if npc:HasTag("TallMonsterHead") then return "TallMonster", true end
    if npc:HasTag("Skinwalker") then return "Skinwalker", true end
    if not npc:FindFirstChild("Humanoid") then
        local hc = 0
        for _, c in pairs(npc:GetChildren()) do if c.Name:find("^Head") then hc = hc + 1 end end
        if hc >= 4 then return "Hider", true end
    end
    for _, attr in ipairs({ "CameraEffect", "CameraEffect2", "PhotoEffect", "PhotoEffect2" }) do
        local val = npc:GetAttribute(attr)
        if val then
            for _, r in ipairs(ANOMALY_REVEALS) do
                if val == r then
                    if r == "VoidPresence" or r == "HiddenFace" then return "Ghost", true end
                    return "Skinwalker", true
                end
            end
        end
    end
    if npc:GetAttribute("SecondFace") or npc:GetAttribute("DifferentFace") then return "Skinwalker", true end
    if npc:FindFirstChild("VoidHighlight") then return "Ghost", true end
    if npc:FindFirstChild("NoFaceBillboard") then return "Ghost", true end
    for _, pn in ipairs(SKINWALKER_PARTS) do
        local p = npc:FindFirstChild(pn)
        if p and p:IsA("BasePart") and p.Transparency < 0.5 then return "Skinwalker", true end
    end
    local se = npc:FindFirstChild("SecondEars")
    if se then
        for _, p in pairs(se:GetDescendants()) do
            if p:IsA("BasePart") and p.Transparency < 0.5 then return "Skinwalker", true end
        end
    end
    return "Normal", false
end

local function createESP(npc, npcType, isAnom)
    if espObjects[npc] then return end
    local root = npc:FindFirstChild("HumanoidRootPart") or npc:FindFirstChild("RootPart")
    if not root then return end
    if npcType ~= "Normal" and not categoryFilters[npcType] then return end
    if npcType == "Normal" and not categoryFilters.Normal then return end

    local color = isAnom and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)
    local bgColor = isAnom and Color3.fromRGB(180, 0, 0) or Color3.fromRGB(0, 120, 0)

    local bb = Instance.new("BillboardGui")
    bb.Name = "AnomalyESP_" .. npc.Name
    bb.Adornee = root; bb.Size = UDim2.new(0, 200, 0, 80)
    bb.StudsOffset = Vector3.new(0, 3.5, 0); bb.AlwaysOnTop = true

    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 1, 0); f.BackgroundTransparency = 0.3
    f.BackgroundColor3 = bgColor; f.BorderSizePixel = 2; f.BorderColor3 = color; f.Parent = bb
    local fc = Instance.new("UICorner"); fc.CornerRadius = UDim.new(0, 4); fc.Parent = f

    local nl = Instance.new("TextLabel")
    nl.Size = UDim2.new(1, 0, 0, 24); nl.Position = UDim2.new(0, 0, 0, 2)
    nl.BackgroundTransparency = 1; nl.Text = npc.Name
    nl.TextColor3 = Color3.fromRGB(255, 255, 255); nl.TextScaled = true
    nl.Font = Enum.Font.GothamBold; nl.TextStrokeTransparency = 0.3
    nl.TextStrokeColor3 = Color3.new(0, 0, 0); nl.Parent = f

    local sl = Instance.new("TextLabel")
    sl.Size = UDim2.new(1, 0, 0, 24); sl.Position = UDim2.new(0, 0, 0, 28)
    sl.BackgroundTransparency = 1
    sl.Text = isAnom and "[ANOMALY]" or "[ANIMAL]"
    sl.TextColor3 = color; sl.TextScaled = true; sl.Font = Enum.Font.GothamBlack
    sl.TextStrokeTransparency = 0.3; sl.TextStrokeColor3 = Color3.new(0, 0, 0); sl.Parent = f

    local hb = Instance.new("Frame")
    hb.Size = UDim2.new(0.9, 0, 0, 8); hb.Position = UDim2.new(0.05, 0, 0, 56)
    hb.BackgroundColor3 = Color3.fromRGB(40, 40, 40); hb.BorderSizePixel = 1; hb.BorderColor3 = Color3.fromRGB(0, 0, 0); hb.Parent = f
    local hbc = Instance.new("UICorner"); hbc.CornerRadius = UDim.new(0, 2); hbc.Parent = hb
    local hf = Instance.new("Frame")
    hf.Size = UDim2.new(1, 0, 1, 0)
    hf.BackgroundColor3 = isAnom and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(50, 255, 50)
    hf.BorderSizePixel = 0; hf.Parent = hb
    local hfc = Instance.new("UICorner"); hfc.CornerRadius = UDim.new(0, 2); hfc.Parent = hf

    bb.Parent = CoreGui

    local hl = Instance.new("Highlight")
    hl.Name = "AnomalyHighlight_" .. npc.Name
    hl.Adornee = npc; hl.FillColor = color; hl.FillTransparency = 0.65
    hl.OutlineColor = color; hl.OutlineTransparency = 0.3
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop; hl.Parent = CoreGui

    espObjects[npc] = {
        billboard = bb, highlight = hl, hpFill = hf,
        statusLabel = sl, isAnom = isAnom, npcType = npcType, root = root
    }
end

local function updateESP()
    local char = player.Character; local hrp = char and char:FindFirstChild("HumanoidRootPart")
    for npc, data in pairs(espObjects) do
        if not npc or not npc.Parent then
            if data.billboard then data.billboard:Destroy() end
            if data.highlight then data.highlight:Destroy() end; espObjects[npc] = nil; continue end
        if not data.root or not data.root.Parent then
            data.root = npc:FindFirstChild("HumanoidRootPart") or npc:FindFirstChild("RootPart") end
        if not data.root then
            if data.billboard then data.billboard.Enabled = false end
            if data.highlight then data.highlight.Enabled = false end; continue end
        local dist = hrp and (data.root.Position - hrp.Position).Magnitude or math.huge
        local bbInRange = dist <= NAMETAG_RANGE; local hlInRange = dist <= HIGHLIGHT_RANGE
        if tick() % 5 < 0.1 then
            local nt, ia = getNPCType(npc)
            if ia ~= data.isAnom or nt ~= data.npcType then
                data.isAnom = ia; data.npcType = nt
                local c = ia and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)
                data.statusLabel.Text = ia and "[ANOMALY]" or "[ANIMAL]"
                data.statusLabel.TextColor3 = c; data.highlight.FillColor = c; data.highlight.OutlineColor = c
            end
        end
        local catOk = categoryFilters[data.npcType]; if catOk == nil then catOk = true end
        local hum = npc:FindFirstChild("Humanoid")
        local alive = not hum or hum.Health >= 0
        local maxRange = 200; local inMaxRange = dist <= maxRange
        local inUse = npc:GetAttribute("InUse")
        local active = inUse == nil or inUse == 1 or inUse == true

        if not espEnabled or not catOk or not bbInRange or not active or not inMaxRange then
            data.billboard.Enabled = false
        else
            if hum and data.hpFill then data.hpFill.Size = UDim2.new(math.max(0, hum.Health / hum.MaxHealth), 0, 1, 0) end
            data.billboard.Enabled = true
        end
        data.highlight.Enabled = espEnabled and catOk and hlInRange and active and inMaxRange
    end
end

local function scanNPCs()
    local ca, cn = 0, 0

    -- Scan NPC-tagged entities
    for _, npc in pairs(CollectionService:GetTagged("NPC")) do
        if npc:IsA("Model") and npc ~= player.Character then
            if not espObjects[npc] then local t, a = getNPCType(npc); createESP(npc, t, a) end
            local _, a = getNPCType(npc); if a then ca = ca + 1 else cn = cn + 1 end
        end
    end

    -- Scan anomaly-tagged entities that might not have "NPC" tag
    for _, tag in ipairs(ANOMALY_TAGS) do
        for _, npc in pairs(CollectionService:GetTagged(tag)) do
            if npc:IsA("Model") and npc ~= player.Character and not espObjects[npc] then
                local t, a = getNPCType(npc); createESP(npc, t, a)
                if a then ca = ca + 1 else cn = cn + 1 end
            end
        end
    end

    -- Also check TallMonsterHead separately (it's in ANOMALY_TAGS but as safety)
    for _, npc in pairs(CollectionService:GetTagged("TallMonsterHead")) do
        if npc:IsA("Model") and npc ~= player.Character and not espObjects[npc] then
            createESP(npc, "TallMonster", true); ca = ca + 1
        end
    end

    -- Scan workspace.NPCs folder
    local nf = workspace:FindFirstChild("NPCs")
    if nf then
        for _, npc in pairs(nf:GetChildren()) do
            if npc:IsA("Model") and not espObjects[npc] then
                local t, a = getNPCType(npc); createESP(npc, t, a)
                if a then ca = ca + 1 else cn = cn + 1 end
            end
        end
    end
    anomalyCount, normalCount = ca, cn
end

local function cleanupESP()
    for npc, data in pairs(espObjects) do
        if not npc or not npc.Parent then
            if data.billboard then pcall(data.billboard.Destroy, data.billboard) end
            if data.highlight then pcall(data.highlight.Destroy, data.highlight) end; espObjects[npc] = nil end
    end
end

-- ==========================================
-- MENU
-- ==========================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AnomalyESPMenu"; screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling; screenGui.Parent = CoreGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 220, 0, 380); mainFrame.Position = UDim2.new(0.02, 0, 0.25, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20); mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0; mainFrame.Active = true; mainFrame.Draggable = true; mainFrame.Parent = screenGui
local mc = Instance.new("UICorner"); mc.CornerRadius = UDim.new(0, 8); mc.Parent = mainFrame

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 30); titleBar.BackgroundColor3 = Color3.fromRGB(25, 22, 35)
titleBar.BorderSizePixel = 0; titleBar.Parent = mainFrame
local tbc = Instance.new("UICorner"); tbc.CornerRadius = UDim.new(0, 8); tbc.Parent = titleBar
local ug = Instance.new("UIGradient")
ug.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(160, 0, 0)),ColorSequenceKeypoint.new(1, Color3.fromRGB(70, 0, 50))}); ug.Parent = titleBar
local tl = Instance.new("TextLabel")
tl.Size = UDim2.new(1, -36, 1, 0); tl.Position = UDim2.new(0, 8, 0, 0)
tl.BackgroundTransparency = 1; tl.Text = "MORND"
tl.TextColor3 = Color3.fromRGB(255, 255, 255); tl.TextScaled = true
tl.TextXAlignment = Enum.TextXAlignment.Left; tl.Font = Enum.Font.GothamBlack; tl.Parent = titleBar
local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 24, 0, 24); minBtn.Position = UDim2.new(1, -28, 0, 3)
minBtn.BackgroundColor3 = Color3.fromRGB(55, 50, 65); minBtn.Text = "-"
minBtn.TextColor3 = Color3.fromRGB(255, 255, 255); minBtn.TextScaled = true
minBtn.Font = Enum.Font.GothamBold; minBtn.Parent = titleBar
local mbc = Instance.new("UICorner"); mbc.CornerRadius = UDim.new(0, 6); mbc.Parent = minBtn

local sf = Instance.new("ScrollingFrame")
sf.Size = UDim2.new(1, -4, 1, -32); sf.Position = UDim2.new(0, 2, 0, 32)
sf.BackgroundTransparency = 1; sf.BorderSizePixel = 0; sf.ScrollBarThickness = 4
sf.ScrollBarImageColor3 = Color3.fromRGB(70, 70, 80); sf.AutomaticCanvasSize = Enum.AutomaticSize.Y; sf.Parent = mainFrame
local pad = Instance.new("UIPadding"); pad.PaddingLeft = UDim.new(0, 8); pad.PaddingRight = UDim.new(0, 8); pad.PaddingTop = UDim.new(0, 4); pad.Parent = sf
local lay = Instance.new("UIListLayout"); lay.SortOrder = Enum.SortOrder.LayoutOrder; lay.Padding = UDim.new(0, 3); lay.Parent = sf

local function hdr(t) local h = Instance.new("TextLabel"); h.Size = UDim2.new(1, 0, 0, 18); h.BackgroundTransparency = 1; h.Text = t; h.TextColor3 = Color3.fromRGB(170, 170, 190); h.TextScaled = true; h.TextXAlignment = Enum.TextXAlignment.Left; h.Font = Enum.Font.GothamBold; h.Parent = sf end

local function tgl(name, key, state, color, order)
    local bg = Instance.new("Frame"); bg.Size = UDim2.new(1, 0, 0, 28); bg.BackgroundColor3 = Color3.fromRGB(22, 22, 30); bg.BorderSizePixel = 0; bg.LayoutOrder = order; bg.Parent = sf
    local bgc = Instance.new("UICorner"); bgc.CornerRadius = UDim.new(0, 5); bgc.Parent = bg
    local ind = Instance.new("Frame"); ind.Size = UDim2.new(0, 3, 0, 16); ind.Position = UDim2.new(0, 5, 0, 6); ind.BackgroundColor3 = color; ind.BorderSizePixel = 0; ind.Parent = bg
    local inc = Instance.new("UICorner"); inc.CornerRadius = UDim.new(0, 2); inc.Parent = ind
    local lbl = Instance.new("TextLabel"); lbl.Size = UDim2.new(1, -50, 1, 0); lbl.Position = UDim2.new(0, 12, 0, 0); lbl.BackgroundTransparency = 1; lbl.Text = name; lbl.TextColor3 = Color3.fromRGB(210, 210, 220); lbl.TextScaled = true; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Font = Enum.Font.GothamSemibold; lbl.Parent = bg
    local btn = Instance.new("TextButton"); btn.Size = UDim2.new(0, 32, 0, 20); btn.Position = UDim2.new(1, -38, 0, 4); btn.BackgroundColor3 = state and Color3.fromRGB(0, 170, 45) or Color3.fromRGB(75, 75, 85); btn.Text = ""; btn.Parent = bg
    local btnc = Instance.new("UICorner"); btnc.CornerRadius = UDim.new(0, 4); btnc.Parent = btn
    local circ = Instance.new("Frame"); circ.Size = UDim2.new(0, 14, 0, 14); circ.Position = state and UDim2.new(1, -16, 0, 3) or UDim2.new(0, 2, 0, 3); circ.BackgroundColor3 = Color3.fromRGB(255, 255, 255); circ.BackgroundTransparency = 0.15; circ.BorderSizePixel = 0; circ.Parent = btn
    local cc = Instance.new("UICorner"); cc.CornerRadius = UDim.new(0, 7); cc.Parent = circ
    local en = state
    btn.MouseButton1Click:Connect(function()
        en = not en; if key == "ESP_MASTER" then espEnabled = en; categoryFilters[key] = en else categoryFilters[key] = en end
        btn.BackgroundColor3 = en and Color3.fromRGB(0, 170, 45) or Color3.fromRGB(75, 75, 85)
        circ:TweenPosition(en and UDim2.new(1, -16, 0, 3) or UDim2.new(0, 2, 0, 3),Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.15, true)
    end)
end

local statLbl = Instance.new("TextLabel")
statLbl.Size = UDim2.new(1, 0, 0, 18); statLbl.BackgroundTransparency = 1; statLbl.Text = "Anomalies: 0 | Normals: 0"
statLbl.TextColor3 = Color3.fromRGB(200, 200, 210); statLbl.TextScaled = true
statLbl.TextXAlignment = Enum.TextXAlignment.Left; statLbl.Font = Enum.Font.GothamBold; statLbl.LayoutOrder = 1; statLbl.Parent = sf

local s1 = Instance.new("Frame"); s1.Size = UDim2.new(1, 0, 0, 1); s1.BackgroundColor3 = Color3.fromRGB(50, 50, 60); s1.BorderSizePixel = 0; s1.LayoutOrder = 2; s1.Parent = sf
hdr("--- FILTERS ---")
tgl("ESP Master", "ESP_MASTER", true, Color3.fromRGB(100, 180, 255), 10)
tgl("Ghost", "Ghost", true, Color3.fromRGB(200, 100, 255), 11)
tgl("Stalker", "Stalker", true, Color3.fromRGB(255, 50, 50), 12)
tgl("Hider", "Hider", true, Color3.fromRGB(255, 150, 0), 13)
tgl("Tall Monster", "TallMonster", true, Color3.fromRGB(200, 0, 200), 14)
tgl("Skinwalker", "Skinwalker", true, Color3.fromRGB(255, 0, 100), 15)
tgl("Shadow", "Shadow", true, Color3.fromRGB(100, 100, 255), 16)
tgl("Normal Animals", "Normal", true, Color3.fromRGB(0, 255, 0), 17)

local s2 = Instance.new("Frame"); s2.Size = UDim2.new(1, 0, 0, 1); s2.BackgroundColor3 = Color3.fromRGB(50, 50, 60); s2.BorderSizePixel = 0; s2.LayoutOrder = 18; s2.Parent = sf
local refBg = Instance.new("Frame"); refBg.Size = UDim2.new(1, 0, 0, 28); refBg.BackgroundColor3 = Color3.fromRGB(22, 22, 30); refBg.BorderSizePixel = 0; refBg.LayoutOrder = 19; refBg.Parent = sf
local refc = Instance.new("UICorner"); refc.CornerRadius = UDim.new(0, 5); refc.Parent = refBg
local refBtn = Instance.new("TextButton"); refBtn.Size = UDim2.new(1, -12, 1, -6); refBtn.Position = UDim2.new(0, 6, 0, 3); refBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55); refBtn.Text = "REFRESH"; refBtn.TextColor3 = Color3.fromRGB(200, 200, 210); refBtn.TextScaled = true; refBtn.Font = Enum.Font.GothamBold; refBtn.Parent = refBg
local refBc = Instance.new("UICorner"); refBc.CornerRadius = UDim.new(0, 4); refBc.Parent = refBtn
refBtn.MouseButton1Click:Connect(function() scanNPCs(); refBtn.Text = "OK"; task.delay(0.6, function() refBtn.Text = "REFRESH" end) end)

-- TRANSLATE BUTTONS
local sLang = Instance.new("Frame"); sLang.Size = UDim2.new(1, 0, 0, 1); sLang.BackgroundColor3 = Color3.fromRGB(50, 50, 60); sLang.BorderSizePixel = 0; sLang.LayoutOrder = 21; sLang.Parent = sf
hdr("--- TRANSLATE ---")
local trBg = Instance.new("Frame"); trBg.Size = UDim2.new(1, 0, 0, 28); trBg.BackgroundColor3 = Color3.fromRGB(22, 22, 30); trBg.BorderSizePixel = 0; trBg.LayoutOrder = 22; trBg.Parent = sf
local trc = Instance.new("UICorner"); trc.CornerRadius = UDim.new(0, 5); trc.Parent = trBg
local trBtn = Instance.new("TextButton"); trBtn.Size = UDim2.new(1, -12, 1, -6); trBtn.Position = UDim2.new(0, 6, 0, 3); trBtn.BackgroundColor3 = Color3.fromRGB(180, 30, 30); trBtn.Text = "🇹🇷 Turkce Yap"; trBtn.TextColor3 = Color3.fromRGB(255, 255, 255); trBtn.TextScaled = true; trBtn.Font = Enum.Font.GothamBold; trBtn.Parent = trBg
local trBc = Instance.new("UICorner"); trBc.CornerRadius = UDim.new(0, 4); trBc.Parent = trBtn

local enBg = Instance.new("Frame"); enBg.Size = UDim2.new(1, 0, 0, 28); enBg.BackgroundColor3 = Color3.fromRGB(22, 22, 30); enBg.BorderSizePixel = 0; enBg.LayoutOrder = 23; enBg.Parent = sf
local enc = Instance.new("UICorner"); enc.CornerRadius = UDim.new(0, 5); enc.Parent = enBg
local enBtn = Instance.new("TextButton"); enBtn.Size = UDim2.new(1, -12, 1, -6); enBtn.Position = UDim2.new(0, 6, 0, 3); enBtn.BackgroundColor3 = Color3.fromRGB(30, 80, 180); enBtn.Text = "🇬🇧 English Yap"; enBtn.TextColor3 = Color3.fromRGB(255, 255, 255); enBtn.TextScaled = true; enBtn.Font = Enum.Font.GothamBold; enBtn.Parent = enBg
local enBc = Instance.new("UICorner"); enBc.CornerRadius = UDim.new(0, 4); enBc.Parent = enBtn

trBtn.MouseButton1Click:Connect(function() applyTurkish(); trBtn.Text = "✓ TURKCE"; enBtn.Text = "🇬🇧 English Yap"; task.delay(1.5, function() if isTurkish then trBtn.Text = "🇹🇷 Turkce Yap" end end) end)
enBtn.MouseButton1Click:Connect(function() restoreEnglish(); enBtn.Text = "✓ ENGLISH"; trBtn.Text = "🇹🇷 Turkce Yap"; task.delay(1.5, function() if not isTurkish then enBtn.Text = "🇬🇧 English Yap" end end) end)

local s3 = Instance.new("Frame"); s3.Size = UDim2.new(1, 0, 0, 1); s3.BackgroundColor3 = Color3.fromRGB(50, 50, 60); s3.BorderSizePixel = 0; s3.LayoutOrder = 24; s3.Parent = sf
hdr("--- LEGEND ---")
local items = {{"Ghost", Color3.fromRGB(200, 100, 255), 30},{"Stalker", Color3.fromRGB(255, 50, 50), 31},{"Hider", Color3.fromRGB(255, 150, 0), 32},{"Tall Monster", Color3.fromRGB(200, 0, 200), 33},{"Skinwalker", Color3.fromRGB(255, 0, 100), 34},{"Shadow", Color3.fromRGB(100, 100, 255), 35},{"Normal", Color3.fromRGB(0, 255, 0), 36}}
for _, it in ipairs(items) do
    local bg = Instance.new("Frame"); bg.Size = UDim2.new(1, 0, 0, 16); bg.BackgroundTransparency = 1; bg.LayoutOrder = it[3]; bg.Parent = sf
    local box = Instance.new("Frame"); box.Size = UDim2.new(0, 8, 0, 8); box.Position = UDim2.new(0, 0, 0, 4); box.BackgroundColor3 = it[2]; box.BorderSizePixel = 0; box.Parent = bg
    local lb = Instance.new("TextLabel"); lb.Size = UDim2.new(1, -12, 1, 0); lb.Position = UDim2.new(0, 10, 0, 0); lb.BackgroundTransparency = 1; lb.Text = it[1]; lb.TextColor3 = it[2]; lb.TextScaled = true; lb.TextXAlignment = Enum.TextXAlignment.Left; lb.Font = Enum.Font.Gotham; lb.Parent = bg
end
local ft = Instance.new("TextLabel"); ft.Size = UDim2.new(1, 0, 0, 14); ft.BackgroundTransparency = 1; ft.Text = "Shift=ESP"; ft.TextColor3 = Color3.fromRGB(90, 90, 100); ft.TextScaled = true; ft.TextXAlignment = Enum.TextXAlignment.Left; ft.Font = Enum.Font.Gotham; ft.LayoutOrder = 40; ft.Parent = sf

local minimized = false
minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized; sf.Visible = not minimized
    mainFrame:TweenSize(minimized and UDim2.new(0, 220, 0, 30) or UDim2.new(0, 220, 0, 380),Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
    minBtn.Text = minimized and "+" or "-"
end)

UserInputService.InputBegan:Connect(function(input, gp) if gp then return end; if input.KeyCode == Enum.KeyCode.RightShift then espEnabled = not espEnabled end end)
CollectionService:GetInstanceAddedSignal("NPC"):Connect(function(npc) if npc:IsA("Model") then task.wait(0.5); local t, a = getNPCType(npc); createESP(npc, t, a) end end)
CollectionService:GetInstanceRemovedSignal("NPC"):Connect(function(npc) if espObjects[npc] then local d = espObjects[npc]; if d.billboard then pcall(d.billboard.Destroy, d.billboard) end; if d.highlight then pcall(d.highlight.Destroy, d.highlight) end; espObjects[npc] = nil end end)

RunService.RenderStepped:Connect(function() scanNPCs(); updateESP(); cleanupESP(); statLbl.Text = "Anomalies: " .. anomalyCount .. " | Normals: " .. normalCount end)

task.wait(1); scanNPCs(); startTranslationListener()
task.spawn(function()
    task.wait(1.5)
    applyTurkish()
    player.CharacterAdded:Connect(function()
        task.wait(2)
        applyTurkish()
    end)
end)
return "Loaded - Auto Turkish"
