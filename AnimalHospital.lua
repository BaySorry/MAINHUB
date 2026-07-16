--[[
   The Animal Hospital - ESP v6 (Icon Menu)
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

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

-- ==========================================
-- TRANSLATION
-- ==========================================
local langData = {}
local isTurkish = false

local TR = {
    Objective = "Görev", ["Stamp the form"] = "Formu damgala", ["Stamp Forms"] = "Formları Damgala",
    SANITY = "AKIL", sanity = "akıl", Intern = "Stajyer",
    ["SHIFT FINISHED"] = "VARDİYA BİTTİ", ["Shift Finished"] = "Vardiya Bitti",
    ["Your bag is full!"] = "Çantan doldu!",
    ["NO SIGNAL"] = "SİNYAL YOK", ["NO SIGNAL - REQUIRES FIX"] = "SİNYAL YOK - TAMİR GEREK",
    CAM = "KAM", EXIT = "ÇIKIŞ", exit = "çıkış", Inventory = "Envanter",
    Shift = "Vardiya", ["Shift 2"] = "Vardiya 2", ["Excellent"] = "Mükemmel",
    ["SHIFT REPORT"] = "VARDİYA RAPORU", ["Hospital Performance:"] = "Hastane Performansı:",
    ["Patients Treated:"] = "Tedavi Edilen:", ["Anomalies Prevented"] = "Engellenen Anomaliler",
    ["Visitors Admitted:"] = "Kabul Edilen Ziyaretçiler:", ["Animal Deaths:"] = "Hayvan Ölümleri:",
    ["Bonus!"] = "Bonus!", BEST = "EN İYİ", ["Hospital Deaths"] = "Hastane Ölümleri",
    ["Don't look up"] = "Yukarı bakma", ["Patient being eaten in room"] = "Hasta yeniyor oda",
    EMERGENCIES = "ACİL DURUMLAR", ["Run!"] = "Kaç!", ["!"] = "!",
    ["YOU DIED"] = "ÖLDÜN", ["Your sanity got depleted and went mad"] = "Aklın tükendi ve çıldırdın",
    ["Returning in"] = "Dönüş:", ["Lives"] = "Can", ["Lives 3/3"] = "Can 3/3",
    ["Revive Everyone"] = "Herkesi Dirilt", ["Play Again (0/1)"] = "Tekrar Oyna (0/1)",
    ["Self Revive"] = "Kendini Dirilt", ["Revive"] = "Dirilt",
    ["fainted"] = "bayıldı", ["Fainted"] = "Bayıldı",
    ["(tap on one option)"] = "(bir seçeneğe dokun)", Done = "Tamam",
    ["Goodbye!"] = "Hoşçakal!", ["Accept"] = "Kabul Et", ["Decline"] = "Reddet",
    ["OK"] = "Tamam", ["Ask to Leave"] = "Ayrılmayı İste",
    ["you make yourself a coffee"] = "kendine kahve yapıyorsun",
    ["The doctor is arriving"] = "Doktor geliyor", ["the doctor is arriving"] = "doktor geliyor",
    ["Some advice:"] = "Tavsiye:", ["doctor"] = "doktor",
    s = "", ["46s"] = "46sn", ["47s"] = "47sn", ["99s"] = "99sn", ["120s"] = "120sn",
    ["Boost:"] = "Güçlendirme:", ["Boost: 120s"] = "Güçlendirme: 120sn", ["+5 Coffee"] = "+5 Kahve",
    ["Remove From Hotbar"] = "Hızlı çubuktan kaldır", ["Select/Swap"] = "Seç/Değiştir",
    ["Close Backpack"] = "Çantayı kapat",
    ["Check In"] = "Giriş Yap", Heal = "İyileştir", Examine = "İncele", Inspect = "İncele",
    ["Pick Up"] = "Al", Open = "Aç", Close = "Kapat", Use = "Kullan", Drop = "Bırak",
    Store = "Sakla", Buy = "Satın Al", ["Buy Gun"] = "Tabanca Satın Al", Sell = "Sat",
    Interact = "Etkileşim", Talk = "Konuş", Pat = "Sev", Feed = "Besle",
    ["Take Photo"] = "Fotoğraf Çek", Take = "Al", Register = "Kayıt Oluştur",
    ["Print Badge"] = "Kart Bastır", ["Take DNA Sample"] = "DNA Örneği Al",
    ["Apply Treatment"] = "Tedavi Uygula", ["Analyze Sample"] = "Örneği Analiz Et",
    ["Process Results"] = "Sonuçları İşle", ["Begin X-Ray"] = "Röntgen Çek",
    Begin = "Başlat", Collect = "Topla", ["Turn On"] = "Aç", ["Set Up"] = "Hazırla",
    ["Prepare Patient"] = "Hastayı Hazırla", ["Trash Item"] = "Çöpe At",
    Coffee = "Kahve", ["Chocolate (60% Sanity)"] = "Çikolata (%60 Akıl)",
    ["Security Cams"] = "Güvenlik Kameraları", ["Return Taser"] = "Taser'ı Geri Ver",
    ["Return Fire Ext."] = "Yangın Söndürücüyü Geri Ver", ["Break Poster"] = "Posteri Kır",
    Locked = "Kilitli", ["Scan Identity"] = "Kimlik Tara",
    ["Un-jam button."] = "Butonu aç.", ["Broken Baby Doll"] = "Kırık Bebek",
    Door = "Kapı", ["Jumpscare All"] = "Herkese Korkutma",
    ["Medicine"] = "İlaç", ["Bandages"] = "Sargı Bezi", ["Bandage"] = "Sargı Bezi",
    ["Ointment"] = "Merhem", ["Thermo"] = "Termometre", ["Medkit"] = "Medikit",
    ["Cough Syrup"] = "Öksürük Şurubu", ["Maple Syrup"] = "Akçaağaç Şurubu",
    ["Eye Drops"] = "Göz Damlası", ["Herbs"] = "Bitkiler", ["IV Drops"] = "IV Damla",
    ["Antibiotics"] = "Antibiyotik", ["Transplant"] = "Nakil", ["Organ"] = "Organ",
    ["Scissors"] = "Makas", ["Scalpel"] = "Neşter", ["RunCola"] = "KoşKol",
    ["Treatment"] = "Tedavi", ["treatment"] = "tedavi",
    ["Dehydration"] = "Dehidrasyon", ["Stomach Ache"] = "Karın Ağrısı", ["Head Ache"] = "Baş Ağrısı",
    ["Bleeding"] = "Kanama", ["Fever"] = "Ateş", ["Low Sugar"] = "Düşük Şeker",
    ["Canadian"] = "Kanada", ["Flu"] = "Grip", ["Rash"] = "Döküntü",
    ["Dried Eyes"] = "Kuru Gözler", ["Bruises"] = "Morluklar",
    ["Visitor"] = "Ziyaretçi", ["visitor"] = "ziyaretçi", ["Patient"] = "Hasta", ["patient"] = "hasta",
    ["Hello, my name is "] = "Merhaba, benim adım ", ["I'm "] = "Ben ",
    ["Sup, I'm "] = "Selam, ben ", ["Hey..."] = "Hey...",
    ["Hello"] = "Merhaba", ["Hi"] = "Merhaba", ["Goodbye"] = "Hoşçakal",
    ["Please"] = "Lütfen", ["Thank you"] = "Teşekkürler", ["Thanks"] = "Teşekkürler",
    ["Come with me"] = "Benimle gel", ["Follow me"] = "Beni takip et",
    ["This way"] = "Bu taraftan", ["Wait here"] = "Burada bekle", ["Wait"] = "Bekle",
    ["I'll be right back"] = "Hemen döneceğim", ["Let me examine you"] = "Seni muayene edeyim",
    ["Everything looks good"] = "Her şey iyi görünüyor", ["You're healed"] = "İyileştin",
    ["All done"] = "Tamamlandı", ["You can go now"] = "Şimdi gidebilirsin",
    ["What's wrong?"] = "Sorun nedir?", ["Where does it hurt?"] = "Neren ağrıyor?",
    ["Does this hurt?"] = "Burası ağrıyor mu?", ["I need help"] = "Yardıma ihtiyacım var",
    ["Help me"] = "Bana yardım et", ["Over here"] = "Burada",
    ["I'm scared"] = "Korkuyorum", ["Don't worry"] = "Endişelenme",
    ["It's okay"] = "Sorun yok", ["Stay calm"] = "Sakin ol", ["Breathe"] = "Nefes al",
    ["Almost done"] = "Neredeyse bitti", ["Just a moment"] = "Bir dakika",
    ["I found something"] = "Bir şey buldum", ["Look at this"] = "Şuna bak",
    ["What is that?"] = "O nedir?", ["Something is wrong"] = "Bir şeyler yanlış",
    ["I don't feel good"] = "İyi hissetmiyorum", ["Are you okay?"] = "İyi misin?",
    ["I'm fine"] = "İyiyim", ["Stay here"] = "Burada kal", ["Don't move"] = "Kıpırdama",
    ["I'll get help"] = "Yardım getireceğim", ["Wait for me"] = "Beni bekle",
    ["Let's go"] = "Gidelim", ["Hurry"] = "Acele et", ["Quick"] = "Çabuk",
    ["This is an emergency"] = "Bu bir acil durum", ["Code blue"] = "Kod mavi",
    ["Everything is fine"] = "Her şey yolunda", ["False alarm"] = "Yanlış alarm",
    ["Just a check-up"] = "Sadece bir kontrol", ["Routine examination"] = "Rutin muayene",
    ["Your results are ready"] = "Sonuçların hazır",
    ["The doctor will see you now"] = "Doktor şimdi seni görecek",
    ["Please have a seat"] = "Lütfen otur", ["Make yourself comfortable"] = "Rahatına bak",
    -- Dialogues
    ["I'm here for my appointment..."] = "Randevum için buradayım...",
    ["I have an appointment..."] = "Randevum var...",
    ["AAAAH!! I'M ON FIRE!!"] = "AAAAH!! YANIYORUM!!",
    ["I NEED HELP!!!"] = "YARDIM LAZIM!!!",
    ["You must be the new hire, I'm Dr Harlow."] = "Yeni çalışan sen olmalısın, ben Dr Harlow.",
    ["Some advice: If things get strange, just keep working."] = "Tavsiye: İşler garipleşirse, çalışmaya devam et.",
    ["I will fix up the shutters and security cameras for you."] = "Panjurları ve kameraları tamir edeceğim.",
    ["shutters"] = "panjurlar", ["security cameras"] = "güvenlik kameraları",
    ["I'm opening new facilities for you."] = "Yeni birimler açıyorum.",
    ["supplies shop"] = "malzeme dükkanı", ["limited time"] = "sınırlı süre",
    ["The supplies shop will be open for a limited time each shift."] = "Malzeme dükkanı her vardiyada sınırlı süre açık.",
    ["the shop is open!"] = "dükkan açık!", ["shift"] = "vardiya",
    ["Some patients may seem... unstable..."] = "Bazı hastalar... dengesiz görünebilir...",
    ["unstable"] = "dengesiz",
    ["Make sure to use the photo and cameras. Stay alert."] = "Fotoğraf ve kameraları kullan. Tetikte ol.",
    ["I will unlock the taser. Use it wisely."] = "Taser'ın kilidini açacağım. Akıllıca kullan.",
    ["Your sanity is important. Don't DIE on me."] = "Aklın önemli. SAKIN ÖLME.",
    ["DIE"] = "ÖLME",
    ["And take good care of the patients."] = "Ve hastalara iyi bak.",
    ["If the hospital records 3 DEATHS it's over."] = "Hastane 3 ÖLÜM kaydederse iş biter.",
    ["DEATHS"] = "ÖLÜM",
    ["There's been a huge anomaly attack!"] = "Büyük bir anomali saldırısı oldu!",
    ["anomaly attack"] = "anomali saldırısı",
    ["6 people died and many more were hurt."] = "6 kişi öldü, daha fazlası yaralandı.",
    ["Be prepared, the ambulance is coming..."] = "Hazır ol, ambulans geliyor...",
    ["ambulance"] = "ambulans",
    ["Good job, the emergency is over for now."] = "İyi iş, acil durum bitti.",
    ["More ambulances will come, be prepared."] = "Daha fazla ambulans gelecek, hazırlıklı ol.",
    ["Here is a bonus for your work."] = "Çalışman için bonus.",
    ["bonus"] = "bonus",
    ["Being small has its advantages..."] = "Küçük olmanın avantajları var...",
    ["I hear things... I see things..."] = "Şeyler duyuyorum... Şeyler görüyorum...",
    ["It's a dangerous job..."] = "Tehlikeli bir iş...",
    ["My advice... Don't trust anyone here..."] = "Tavsiyem... Kimseye güvenme...",
    ["Something evil is going on here."] = "Burada kötü bir şeyler dönüyor.",
    ["Stay alert..."] = "Tetikte ol...",
    ["I may need to disappear for a while..."] = "Kaybolmam gerekebilir...",
    ["The Animal Corporation is after me..."] = "Hayvan Şirketi peşimde...",
    ["Name's Ron... from accounting."] = "Adım Ron... muhasebeden.",
    ["You ever wonder why they keep hiring new people?"] = "Neden sürekli yeni insan alıyorlar?",
    ["...Never mind."] = "...Boşver.",
    ["The last guy got eaten by the bed monster."] = "Son adam yatak canavarına yem oldu.",
    ["You want to know a secret?"] = "Bir sır öğrenmek ister misin?",
    ["They're testing something here."] = "Burada bir şey test ediyorlar.",
    ["testing"] = "test",
    ["The patients... they're not sick. They're infected."] = "Hastalar... hasta değil. Enfekte olmuşlar.",
    ["infected"] = "enfekte",
    ["Pretty sketchy..."] = "Oldukça şüpheli...",
    ["coffee"] = "kahve", ["camera"] = "kamera",
    ["suitcase"] = "valiz", ["serial killer"] = "seri katil",
    ["SERIAL KILLER"] = "SERİ KATİL",
    ["anomalies"] = "anomaliler",
    ["transforming"] = "dönüşüyor",
    ["camera"] = "kamera",
    ["Are you serious"] = "Ciddi misin",
    ["youre turning me away"] = "beni geri çeviriyorsun",
    ["you're turning me away"] = "beni geri çeviriyorsun",
    ["I want to check in as a patient..."] = "Hasta olarak giriş yapmak istiyorum...",
    ["I need to see a doctor"] = "Doktora görünmem gerek",
    ["I am sick"] = "Hastayım",
    ["I feel terrible"] = "Berbat hissediyorum",
    -- Common phrases
    ["Are you sure?"] = "Emin misin?", ["Yes"] = "Evet", ["No"] = "Hayır",
    ["Maybe"] = "Belki", ["Never"] = "Asla", ["Always"] = "Her zaman",
    ["Sometimes"] = "Bazen", ["Often"] = "Sık sık", ["Rarely"] = "Nadiren",
    ["Today"] = "Bugün", ["Tomorrow"] = "Yarın", ["Yesterday"] = "Dün",
    ["Now"] = "Şimdi", ["Later"] = "Sonra", ["Soon"] = "Yakında",
    ["Here"] = "Burada", ["There"] = "Orada", ["Everywhere"] = "Her yerde",
    -- Upgrades
    ["Animal Coins"] = "Hayvan Paraları", ["Second Check-in"] = "İkinci Giriş",
    ["Extra check in window"] = "Ek giriş penceresi",
    ["Faster Check-Ins"] = "Hızlı Girişler",
    ["Faster check in"] = "Daha hızlı giriş",
    ["Adv. DNA Synth"] = "Gelişmiş DNA Sentezi",
    ["50% Faster DNA analysis"] = "%50 Hızlı DNA analizi",
    ["Medicine Pockets"] = "İlaç Cepleri",
    ["+1 Carry Capacity"] = "+1 Taşıma",
    ["Running Shoes"] = "Koşu Ayakkabısı",
    ["Coffee Thermometer"] = "Kahve Termometresi",
    ["Compact Storage"] = "Kompakt Depolama",
    ["+1 inventory capacity"] = "+1 envanter",
    ["Bed Anchor"] = "Yatak Çapası",
    ["Patients wont flee"] = "Hastalar kaçmaz",
    ["Emergency Access"] = "Acil Erişim",
    ["good"] = "iyi", ["bad"] = "kötü", ["great"] = "harika",
    ["perfect"] = "mükemmel", ["awesome"] = "harika", ["terrible"] = "korkunç",
    ["sorry"] = "üzgünüm", ["welcome"] = "hoş geldin",
    ["computer"] = "bilgisayar", ["screen"] = "ekran",
    ["results"] = "sonuçlar", ["printer"] = "yazıcı",
    ["form"] = "form", ["badge"] = "kart",
    ["window"] = "pencere", ["desk"] = "masa",
    ["key"] = "anahtar", ["sample"] = "örnek",
    ["photo"] = "fotoğraf", ["picture"] = "resim",
    ["Stop"] = "Dur", ["Help"] = "Yardım",
    ["Cancel"] = "İptal", ["Confirm"] = "Onayla",
    ["Loading"] = "Yükleniyor", ["Saving"] = "Kaydediliyor",
    ["Error"] = "Hata", ["Success"] = "Başarılı",
}

local function stripTags(s)
    return s:gsub("<[^>]+>", "")
end

    end
    if clean ~= t then return clean end
    return t
end

    langData = {}; isTurkish = false
end

    end
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("ProximityPrompt") then
            if v.ActionText and #v.ActionText > 0 then
                local tr = TR[v.ActionText] or translateText(v.ActionText)
                if tr ~= v.ActionText then
                    if not langData[v] then langData[v] = {} end
                    langData[v].ActionText = v.ActionText; v.ActionText = tr
                end
            end
            if v.ObjectText and #v.ObjectText > 0 then
                local tr = TR[v.ObjectText]
                if tr and tr ~= v.ObjectText then
                    if not langData[v] then langData[v] = {} end
                    langData[v].ObjectText = v.ObjectText; v.ObjectText = tr
                end
            end
        end
    end
    isTurkish = true
end



-- ==========================================
-- ANOMALY DETECTION
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

-- ==========================================
-- ESP
-- ==========================================
local function createESP(npc, npcType, isAnom)
    if espObjects[npc] then return end
    local root = npc:FindFirstChild("HumanoidRootPart") or npc:FindFirstChild("RootPart")
    if not root then return end
    if npcType ~= "Normal" and not categoryFilters[npcType] then return end
    if npcType == "Normal" and not categoryFilters.Normal then return end
    local color = isAnom and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)
    local bgColor = isAnom and Color3.fromRGB(180, 0, 0) or Color3.fromRGB(0, 120, 0)

    local bb = Instance.new("BillboardGui")
    bb.Name = "AnomalyESP_" .. npc.Name; bb.Adornee = root
    bb.Size = UDim2.new(0, 200, 0, 80); bb.StudsOffset = Vector3.new(0, 3.5, 0); bb.AlwaysOnTop = true

    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 1, 0); f.BackgroundTransparency = 0.3
    f.BackgroundColor3 = bgColor; f.BorderSizePixel = 2; f.BorderColor3 = color; f.Parent = bb
    local fc = Instance.new("UICorner"); fc.CornerRadius = UDim.new(0, 4); fc.Parent = f
    local nl = Instance.new("TextLabel")
    nl.Size = UDim2.new(1, 0, 0, 24); nl.Position = UDim2.new(0, 0, 0, 2)
    nl.BackgroundTransparency = 1; nl.Text = npc.Name; nl.TextColor3 = Color3.fromRGB(255, 255, 255)
    nl.TextScaled = true; nl.Font = Enum.Font.GothamBold; nl.TextStrokeTransparency = 0.3
    nl.TextStrokeColor3 = Color3.new(0, 0, 0); nl.Parent = f
    local sl = Instance.new("TextLabel")
    sl.Size = UDim2.new(1, 0, 0, 24); sl.Position = UDim2.new(0, 0, 0, 28)
    sl.BackgroundTransparency = 1; sl.Text = isAnom and "[ANOMALY]" or "[ANIMAL]"
    sl.TextColor3 = color; sl.TextScaled = true; sl.Font = Enum.Font.GothamBlack
    sl.TextStrokeTransparency = 0.3; sl.TextStrokeColor3 = Color3.new(0, 0, 0); sl.Parent = f
    local hb = Instance.new("Frame")
    hb.Size = UDim2.new(0.9, 0, 0, 8); hb.Position = UDim2.new(0.05, 0, 0, 56)
    hb.BackgroundColor3 = Color3.fromRGB(40, 40, 40); hb.BorderSizePixel = 1; hb.BorderColor3 = Color3.fromRGB(0, 0, 0); hb.Parent = f
    local hbc = Instance.new("UICorner"); hbc.CornerRadius = UDim.new(0, 2); hbc.Parent = hb
    local hf = Instance.new("Frame")
    hf.Size = UDim2.new(1, 0, 1, 0); hf.BackgroundColor3 = isAnom and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(50, 255, 50)
    hf.BorderSizePixel = 0; hf.Parent = hb
    local hfc = Instance.new("UICorner"); hfc.CornerRadius = UDim.new(0, 2); hfc.Parent = hf
    bb.Parent = CoreGui

    local hl = Instance.new("Highlight")
    hl.Name = "AnomalyHighlight_" .. npc.Name; hl.Adornee = npc; hl.FillColor = color
    hl.FillTransparency = 0.65; hl.OutlineColor = color; hl.OutlineTransparency = 0.3
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop; hl.Parent = CoreGui

    espObjects[npc] = { billboard = bb, highlight = hl, hpFill = hf, statusLabel = sl, isAnom = isAnom, npcType = npcType, root = root }
end

local function updateESP()
    local char = player.Character; local hrp = char and char:FindFirstChild("HumanoidRootPart")
    for npc, data in pairs(espObjects) do
        if not npc or not npc.Parent then
            if data.billboard then data.billboard:Destroy() end
            if data.highlight then data.highlight:Destroy() end; espObjects[npc] = nil; continue end
        if not data.root or not data.root.Parent then data.root = npc:FindFirstChild("HumanoidRootPart") or npc:FindFirstChild("RootPart") end
        if not data.root then
            if data.billboard then data.billboard.Enabled = false end; if data.highlight then data.highlight.Enabled = false end; continue end
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
        local hum = npc:FindFirstChild("Humanoid"); local alive = not hum or hum.Health >= 0
        local inUse = npc:GetAttribute("InUse"); local active = inUse == nil or inUse == 1 or inUse == true
        local inMaxRange = dist <= 200
        if not espEnabled or not catOk or not bbInRange or not active or not inMaxRange then data.billboard.Enabled = false
        else
            if hum and data.hpFill then data.hpFill.Size = UDim2.new(math.max(0, hum.Health / hum.MaxHealth), 0, 1, 0) end
            data.billboard.Enabled = true
        end
        data.highlight.Enabled = espEnabled and catOk and hlInRange and active and inMaxRange
    end
end

local function scanNPCs()
    local ca, cn = 0, 0
    for _, npc in pairs(CollectionService:GetTagged("NPC")) do
        if npc:IsA("Model") and npc ~= player.Character then
            if not espObjects[npc] then local t, a = getNPCType(npc); createESP(npc, t, a) end
            local _, a = getNPCType(npc); if a then ca = ca + 1 else cn = cn + 1 end
        end
    end
    for _, tag in ipairs(ANOMALY_TAGS) do
        for _, npc in pairs(CollectionService:GetTagged(tag)) do
            if npc:IsA("Model") and npc ~= player.Character and not espObjects[npc] then
                local t, a = getNPCType(npc); createESP(npc, t, a)
                if a then ca = ca + 1 else cn = cn + 1 end
            end
        end
    end
    for _, npc in pairs(CollectionService:GetTagged("TallMonsterHead")) do
        if npc:IsA("Model") and npc ~= player.Character and not espObjects[npc] then createESP(npc, "TallMonster", true); ca = ca + 1 end
    end
    local nf = workspace:FindFirstChild("NPCs")
    if nf then
        for _, npc in pairs(nf:GetChildren()) do
            if npc:IsA("Model") and not espObjects[npc] then local t, a = getNPCType(npc); createESP(npc, t, a); if a then ca = ca + 1 else cn = cn + 1 end end
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
-- ICON BUTTON + MENU (New GUI)
-- ==========================================
local mainGui = Instance.new("ScreenGui")
mainGui.Name = "AnomalyHub"; mainGui.ResetOnSpawn = false; mainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
mainGui.Parent = CoreGui

-- === MAIN MENU (Hidden by default) ===
local menuFrame = Instance.new("Frame")
menuFrame.Size = UDim2.new(0, 520, 0, 460); menuFrame.Position = UDim2.new(0.12, 0, 0.12, 0)
menuFrame.BackgroundColor3 = Color3.fromRGB(32, 31, 31); menuFrame.BorderSizePixel = 0; menuFrame.Visible = false
menuFrame.Parent = mainGui; menuFrame.Active = true; menuFrame.Draggable = true
local menuCorner = Instance.new("UICorner"); menuCorner.CornerRadius = UDim.new(0, 10); menuCorner.Parent = menuFrame

-- Header
local header = Instance.new("TextLabel")
header.Size = UDim2.new(1, 0, 0, 50); header.BackgroundColor3 = Color3.fromRGB(34, 34, 34)
header.BorderSizePixel = 0; header.Parent = menuFrame
local headerCorner = Instance.new("UICorner"); headerCorner.CornerRadius = UDim.new(0, 10); headerCorner.Parent = header
header.Text = "MAIN HUB"; header.Font = Enum.Font.SourceSans; header.TextSize = 42
header.TextColor3 = Color3.fromRGB(255, 255, 255); header.TextStrokeColor3 = Color3.fromRGB(255, 204, 0)
header.TextStrokeTransparency = 0.58

-- Close button (X) on header
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 32, 0, 32); closeBtn.Position = UDim2.new(1, -40, 0, 9)
closeBtn.BackgroundColor3 = Color3.fromRGB(60, 50, 50); closeBtn.Text = "X"; closeBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
closeBtn.TextScaled = true; closeBtn.Font = Enum.Font.GothamBold; closeBtn.Parent = header
local closeCorner = Instance.new("UICorner"); closeCorner.CornerRadius = UDim.new(0, 6); closeCorner.Parent = closeBtn

-- Content (ScrollingFrame)
local sf = Instance.new("ScrollingFrame")
sf.Size = UDim2.new(1, -12, 1, -60); sf.Position = UDim2.new(0, 6, 0, 56)
sf.BackgroundTransparency = 1; sf.BorderSizePixel = 0; sf.ScrollBarThickness = 5
sf.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 90); sf.AutomaticCanvasSize = Enum.AutomaticSize.Y
sf.Parent = menuFrame
local pad = Instance.new("UIPadding"); pad.PaddingLeft = UDim.new(0, 10); pad.PaddingRight = UDim.new(0, 10); pad.PaddingTop = UDim.new(0, 6); pad.Parent = sf
local lay = Instance.new("UIListLayout"); lay.SortOrder = Enum.SortOrder.LayoutOrder; lay.Padding = UDim.new(0, 4); lay.Parent = sf

-- Helper functions
local function hdr(t)
    local h = Instance.new("TextLabel"); h.Size = UDim2.new(1, 0, 0, 22); h.BackgroundTransparency = 1
    h.Text = t; h.TextColor3 = Color3.fromRGB(220, 200, 120); h.TextScaled = true
    h.TextXAlignment = Enum.TextXAlignment.Left; h.Font = Enum.Font.GothamBold; h.Parent = sf
end

local function tgl(name, key, state, color)
    local bg = Instance.new("Frame"); bg.Size = UDim2.new(1, 0, 0, 30); bg.BackgroundColor3 = Color3.fromRGB(42, 41, 41); bg.BorderSizePixel = 0; bg.Parent = sf
    local bgc = Instance.new("UICorner"); bgc.CornerRadius = UDim.new(0, 5); bgc.Parent = bg
    local ind = Instance.new("Frame"); ind.Size = UDim2.new(0, 3, 0, 16); ind.Position = UDim2.new(0, 6, 0, 7); ind.BackgroundColor3 = color; ind.BorderSizePixel = 0; ind.Parent = bg
    local inc = Instance.new("UICorner"); inc.CornerRadius = UDim.new(0, 2); inc.Parent = ind
    local lbl = Instance.new("TextLabel"); lbl.Size = UDim2.new(1, -50, 1, 0); lbl.Position = UDim2.new(0, 14, 0, 0); lbl.BackgroundTransparency = 1; lbl.Text = name; lbl.TextColor3 = Color3.fromRGB(220, 220, 220); lbl.TextScaled = true; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Font = Enum.Font.GothamSemibold; lbl.Parent = bg
    local btn = Instance.new("TextButton"); btn.Size = UDim2.new(0, 32, 0, 20); btn.Position = UDim2.new(1, -38, 0, 5); btn.BackgroundColor3 = state and Color3.fromRGB(0, 170, 45) or Color3.fromRGB(75, 75, 85); btn.Text = ""; btn.Parent = bg
    local btnc = Instance.new("UICorner"); btnc.CornerRadius = UDim.new(0, 4); btnc.Parent = btn
    local circ = Instance.new("Frame"); circ.Size = UDim2.new(0, 14, 0, 14); circ.Position = state and UDim2.new(1, -16, 0, 3) or UDim2.new(0, 2, 0, 3); circ.BackgroundColor3 = Color3.fromRGB(255, 255, 255); circ.BackgroundTransparency = 0.15; circ.BorderSizePixel = 0; circ.Parent = btn
    local cc = Instance.new("UICorner"); cc.CornerRadius = UDim.new(0, 7); cc.Parent = circ
    local en = state
    btn.MouseButton1Click:Connect(function()
        en = not en; if key == "ESP_MASTER" then espEnabled = en; categoryFilters[key] = en else categoryFilters[key] = en end
        btn.BackgroundColor3 = en and Color3.fromRGB(0, 170, 45) or Color3.fromRGB(75, 75, 85)
        circ:TweenPosition(en and UDim2.new(1, -16, 0, 3) or UDim2.new(0, 2, 0, 3), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.15, true)
    end)
end

local function bigBtn(name, color, callback)
    local bg = Instance.new("Frame"); bg.Size = UDim2.new(1, 0, 0, 34); bg.BackgroundColor3 = Color3.fromRGB(42, 41, 41); bg.BorderSizePixel = 0; bg.Parent = sf
    local bgc = Instance.new("UICorner"); bgc.CornerRadius = UDim.new(0, 5); bgc.Parent = bg
    local btn = Instance.new("TextButton"); btn.Size = UDim2.new(1, -12, 1, -6); btn.Position = UDim2.new(0, 6, 0, 3); btn.BackgroundColor3 = color; btn.Text = name; btn.TextColor3 = Color3.fromRGB(255, 255, 255); btn.TextScaled = true; btn.Font = Enum.Font.GothamBold; btn.Parent = bg
    local btnc = Instance.new("UICorner"); btnc.CornerRadius = UDim.new(0, 4); btnc.Parent = btn
    btn.MouseButton1Click:Connect(callback)
end

-- ====== MENU CONTENT ======
-- Stats
local statLbl = Instance.new("TextLabel")
statLbl.Size = UDim2.new(1, 0, 0, 20); statLbl.BackgroundTransparency = 1
statLbl.Text = "Anomalies: 0 | Normals: 0"; statLbl.TextColor3 = Color3.fromRGB(200, 200, 200)
statLbl.TextScaled = true; statLbl.TextXAlignment = Enum.TextXAlignment.Left; statLbl.Font = Enum.Font.GothamBold; statLbl.Parent = sf

local sep = Instance.new("Frame"); sep.Size = UDim2.new(1, 0, 0, 1); sep.BackgroundColor3 = Color3.fromRGB(60, 60, 70); sep.BorderSizePixel = 0; sep.Parent = sf

hdr("FILTERS")
tgl("ESP Master", "ESP_MASTER", true, Color3.fromRGB(100, 180, 255))
tgl("Ghost", "Ghost", true, Color3.fromRGB(200, 100, 255))
tgl("Stalker", "Stalker", true, Color3.fromRGB(255, 50, 50))
tgl("Hider", "Hider", true, Color3.fromRGB(255, 150, 0))
tgl("Tall Monster", "TallMonster", true, Color3.fromRGB(200, 0, 200))
tgl("Skinwalker", "Skinwalker", true, Color3.fromRGB(255, 0, 100))
tgl("Shadow", "Shadow", true, Color3.fromRGB(100, 100, 255))
tgl("Normal", "Normal", true, Color3.fromRGB(0, 255, 0))

local sep2 = Instance.new("Frame"); sep2.Size = UDim2.new(1, 0, 0, 1); sep2.BackgroundColor3 = Color3.fromRGB(60, 60, 70); sep2.BorderSizePixel = 0; sep2.Parent = sf


    applyTurkish()
end
bigBtn("REFRESH NPC", Color3.fromRGB(50, 50, 60), function() scanNPCs() end)

local sep3 = Instance.new("Frame"); sep3.Size = UDim2.new(1, 0, 0, 1); sep3.BackgroundColor3 = Color3.fromRGB(60, 60, 70); sep3.BorderSizePixel = 0; sep3.Parent = sf

hdr("LEGEND")
local legendItems = {
    {"Ghost", Color3.fromRGB(200, 100, 255)}, {"Stalker", Color3.fromRGB(255, 50, 50)},
    {"Hider", Color3.fromRGB(255, 150, 0)}, {"Tall Monster", Color3.fromRGB(200, 0, 200)},
    {"Skinwalker", Color3.fromRGB(255, 0, 100)}, {"Shadow", Color3.fromRGB(100, 100, 255)},
    {"Normal", Color3.fromRGB(0, 255, 0)}
}
for _, it in ipairs(legendItems) do
    local bg = Instance.new("Frame"); bg.Size = UDim2.new(1, 0, 0, 18); bg.BackgroundTransparency = 1; bg.Parent = sf
    local box = Instance.new("Frame"); box.Size = UDim2.new(0, 10, 0, 10); box.Position = UDim2.new(0, 0, 0, 4); box.BackgroundColor3 = it[2]; box.BorderSizePixel = 0; box.Parent = bg
    local lb = Instance.new("TextLabel"); lb.Size = UDim2.new(1, -16, 1, 0); lb.Position = UDim2.new(0, 14, 0, 0); lb.BackgroundTransparency = 1; lb.Text = it[1]; lb.TextColor3 = it[2]; lb.TextScaled = true; lb.TextXAlignment = Enum.TextXAlignment.Left; lb.Font = Enum.Font.Gotham; lb.Parent = bg
end

local footerLbl = Instance.new("TextLabel")
footerLbl.Size = UDim2.new(1, 0, 0, 16); footerLbl.BackgroundTransparency = 1
footerLbl.Text = "ESP v6 | Shift=Toggle"; footerLbl.TextColor3 = Color3.fromRGB(100, 100, 110)
footerLbl.TextScaled = true; footerLbl.TextXAlignment = Enum.TextXAlignment.Left; footerLbl.Font = Enum.Font.Gotham; footerLbl.Parent = sf

closeBtn.MouseButton1Click:Connect(function()
    menuOpen = false; menuFrame.Visible = false
end)

-- RightShift toggle
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightShift then espEnabled = not espEnabled end
end)

-- Events

-- === FLOATING ICON ===
local iconBtn = Instance.new("ImageButton")
iconBtn.Size = UDim2.new(0, 60, 0, 60); iconBtn.Position = UDim2.new(0.02, 0, 0.45, 0)
iconBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35); iconBtn.BackgroundTransparency = 0.2
iconBtn.BorderSizePixel = 0; iconBtn.Image = "rbxassetid://74010930701899"
iconBtn.Parent = mainGui
local iconCorner = Instance.new("UICorner"); iconCorner.CornerRadius = UDim.new(0, 12); iconCorner.Parent = iconBtn

-- Icon controls
local isDragging = false; local isPressed = false
local pressStartTime = 0; local mouseDownPos = nil; local iconStartPos = nil
local menuOpen = false

iconBtn.MouseButton1Down:Connect(function()
    isPressed = true; isDragging = false
    pressStartTime = tick()
    mouseDownPos = UserInputService:GetMouseLocation()
    iconStartPos = iconBtn.Position
end)

iconBtn.MouseButton1Up:Connect(function()
    isPressed = false
    if not isDragging and (tick() - pressStartTime) < 0.3 then
        menuOpen = not menuOpen; menuFrame.Visible = menuOpen
    end
    isDragging = false
end)

UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and isPressed then
        local delta = UserInputService:GetMouseLocation() - mouseDownPos
        if delta.Magnitude > 10 then isDragging = true end
        if isDragging then
            iconBtn.Position = UDim2.new(iconStartPos.X.Scale, iconStartPos.X.Offset + delta.X, iconStartPos.Y.Scale, iconStartPos.Y.Offset + delta.Y)
        end
    end
end)

-- Events
CollectionService:GetInstanceAddedSignal("NPC"):Connect(function(npc) if npc:IsA("Model") then task.wait(0.5); local t, a = getNPCType(npc); createESP(npc, t, a) end end)
CollectionService:GetInstanceRemovedSignal("NPC"):Connect(function(npc)
    if espObjects[npc] then local d = espObjects[npc]; if d.billboard then pcall(d.billboard.Destroy, d.billboard) end; if d.highlight then pcall(d.highlight.Destroy, d.highlight) end; espObjects[npc] = nil end
end)

-- Main loop
RunService.RenderStepped:Connect(function()
    scanNPCs(); updateESP(); cleanupESP()
    statLbl.Text = "Anomalies: " .. anomalyCount .. " | Normals: " .. normalCount
end)

-- Init
-- task.wait(1); scanNPCs(); startTranslationListener()
return "ESP v6 loaded"
