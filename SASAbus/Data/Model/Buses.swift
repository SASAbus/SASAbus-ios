import Foundation

class Buses {

    static var BUSES = [Int: Bus]()

    static func setup() {
        let sprinter_new = Vehicle(manufacturer: "Mercedes-Benz", model: "Sprinter O 513 NFXL", fuel: 1, color: 1, emission: 90, code: "mercedes_benz_sprinter_o_513_nxfl")
        let urbino_18 = Vehicle(manufacturer: "Solaris", model: "Urbino 18", fuel: 1, color: 1, emission: 90, code: "solaris_urbino_18")
        let urbino_12 = Vehicle(manufacturer: "Solaris", model: "Urbino 12", fuel: 1, color: 1, emission: 90, code: "solaris_urbino_12")
        let hydrogen = Vehicle(manufacturer: "Mercedes-Benz", model: "Citaro O 530 BZ", fuel: 0, color: 0, emission: 0, code: "mercedes_benz_citaro_o_530_bz")
        let vivacity_new = Vehicle(manufacturer: "BredaMenarinibus", model: "Vivacity+ 231 MU/3P/E5 EEV", fuel: 1, color: 1, emission: 90, code: "bredamenarinibus_vivacity_plus")
        let citaro_18 = Vehicle(manufacturer: "Mercedes-Benz", model: "Citaro O 530 GN", fuel: 1, color: 1, emission: 90, code: "mercedes_benz_citaro_o_530_gn")
        let citaro_10 = Vehicle(manufacturer: "Mercedes-Benz", model: "Citaro O 530 K", fuel: 1, color: 1, emission: 90, code: "mercedes_benz_citaro_o_530_k")
        let bus_392 = Vehicle(manufacturer: "MAN", model: "A76 NM 223.3", fuel: 1, color: 1, emission: 110, code: "man_a76_nm_223_3")
        let vivacity_old = Vehicle(manufacturer: "BredaMenarinibus", model: "Vivacity 231 MU/3P/E5", fuel: 1, color: 2, emission: 110, code: "bredamenarinibus_vivacity")
        let bus_388 = Vehicle(manufacturer: "Mercedes-Benz", model: "Citaro O 530 N", fuel: 1, color: 2, emission: 90, code: "mercedes_benz_citaro_o_530_n")
        let bus_387 = Vehicle(manufacturer: "Mercedes-Benz", model: "Citaro O 530 GN", fuel: 1, color: 2, emission: 90, code: "mercedes_benz_citaro_o_530_n_387")
        let mb_gn = Vehicle(manufacturer: "Mercedes-Benz", model: "Citaro O 530 GN", fuel: 1, color: 2, emission: 90, code: "mercedes_benz_citaro_o_530_n_orange")
        let man_lc = Vehicle(manufacturer: "MAN", model: "Lion\"s City 313 NG/CNG", fuel: 2, color: 2, emission: 110, code: "man_lions_city")
        let avancity = Vehicle(manufacturer: "BredaMenarinibus", model: "Avancity NU/3P/CNG", fuel: 2, color: 2, emission: 110, code: "bredamenarinibus_avancity")
        let bmb_short = Vehicle(manufacturer: "BredaMenarinibus", model: "Monocar 231/2/CU/2P E3 CNG", fuel: 2, color: 2, emission: 110, code: "bredamenarinibus_monocar_231")
        let bus_369 = Vehicle(manufacturer: "MAN", model: "313 NG/CNG", fuel: 2, color: 2, emission: 110, code: "man_313_ng_cng")
        let m_240 = Vehicle(manufacturer: "BredaMenarinibus", model: "Monocar 240", fuel: 2, color: 2, emission: 110, code: "bredamenarinibus_monocar_240")
        let bus_330 = Vehicle(manufacturer: "BredaMenarinibus", model: "Monocar 240", fuel: 1, color: 2, emission: 110, code: "bredamenarinibus_monocar_240")
        let irisbus = Vehicle(manufacturer: "Iveco", model: "Irisbus 491E CityClass CNG", fuel: 2, color: 2, emission: 110, code: "iveco_irisbus")
        let m_240_nu = Vehicle(manufacturer: "BredaMenarinibus", model: "Monocar 240 NU", fuel: 1, color: 2, emission: 110, code: "bredamenarinibus_monocar_240_nu")
        let m_221 = Vehicle(manufacturer: "BredaMenarinibus", model: "Monocar 221/1/LU/3P", fuel: 1, color: 2, emission: 160, code: "bredamenarinibus_monocar_221")
        let man_4x_short = Vehicle(manufacturer: "MAN", model: "NL 313", fuel: 1, color: 2, emission: 160, code: "man_nl_313")
        let man_4x_long = Vehicle(manufacturer: "MAN", model: "NG 313", fuel: 1, color: 2, emission: 160, code: "man_ng_313")
        
        BUSES[444] = Bus(444, licensePlate: "FH011KR", vehicle: urbino_18)
        BUSES[443] = Bus(443, licensePlate: "FH010KR", vehicle: urbino_18)
        BUSES[442] = Bus(442, licensePlate: "FH002KR", vehicle: urbino_18)
        BUSES[441] = Bus(441, licensePlate: "FH003KR", vehicle: urbino_18)
        BUSES[440] = Bus(440, licensePlate: "FG146NA", vehicle: urbino_18)
        
        BUSES[439] = Bus(439, licensePlate: "ES788TJ", vehicle: sprinter_new)

        BUSES[438] = Bus(438, licensePlate: "ES802TJ", vehicle: urbino_18)
        BUSES[437] = Bus(437, licensePlate: "ES803TJ", vehicle: urbino_18)

        BUSES[436] = Bus(436, licensePlate: "ES800TJ", vehicle: urbino_12)
        BUSES[435] = Bus(435, licensePlate: "ES805TJ", vehicle: urbino_12)
        BUSES[434] = Bus(434, licensePlate: "ES804TJ", vehicle: urbino_12)
        BUSES[433] = Bus(433, licensePlate: "ES801TJ", vehicle: urbino_12)

        BUSES[432] = Bus(432, licensePlate: "ER345VP", vehicle: hydrogen)
        BUSES[431] = Bus(431, licensePlate: "ER344VP", vehicle: hydrogen)
        BUSES[430] = Bus(430, licensePlate: "ER346VP", vehicle: hydrogen)
        BUSES[429] = Bus(429, licensePlate: "ER342VP", vehicle: hydrogen)
        BUSES[428] = Bus(428, licensePlate: "ER343VP", vehicle: hydrogen)

        BUSES[427] = Bus(427, licensePlate: "EP946LW", vehicle: vivacity_new)
        BUSES[426] = Bus(426, licensePlate: "EP948LW", vehicle: vivacity_new)
        BUSES[425] = Bus(425, licensePlate: "EP997LW", vehicle: vivacity_new)
        BUSES[424] = Bus(424, licensePlate: "EP996LW", vehicle: vivacity_new)
        BUSES[423] = Bus(423, licensePlate: "EP945LW", vehicle: vivacity_new)
        BUSES[422] = Bus(422, licensePlate: "EP947LW", vehicle: vivacity_new)
        BUSES[421] = Bus(421, licensePlate: "EP949LW", vehicle: vivacity_new)
        BUSES[420] = Bus(420, licensePlate: "EP998LW", vehicle: vivacity_new)

        BUSES[419] = Bus(419, licensePlate: "EP605LW", vehicle: citaro_18)
        BUSES[418] = Bus(418, licensePlate: "EP604LW", vehicle: citaro_18)
        BUSES[417] = Bus(417, licensePlate: "EP603LW", vehicle: citaro_18)
        BUSES[416] = Bus(416, licensePlate: "EP602LW", vehicle: citaro_18)
        BUSES[415] = Bus(415, licensePlate: "EP601LW", vehicle: citaro_18)
        BUSES[414] = Bus(414, licensePlate: "EP600LW", vehicle: citaro_18)

        BUSES[413] = Bus(413, licensePlate: "EP694LW", vehicle: urbino_12)
        BUSES[412] = Bus(412, licensePlate: "EP693LW", vehicle: urbino_12)
        BUSES[411] = Bus(411, licensePlate: "EP692LW", vehicle: urbino_12)
        BUSES[410] = Bus(410, licensePlate: "EP691LW", vehicle: urbino_12)
        BUSES[409] = Bus(409, licensePlate: "EP690LW", vehicle: urbino_12)
        BUSES[408] = Bus(408, licensePlate: "EP689LW", vehicle: urbino_12)
        BUSES[407] = Bus(407, licensePlate: "EP688LW", vehicle: urbino_12)
        BUSES[406] = Bus(406, licensePlate: "EP687LW", vehicle: urbino_12)
        BUSES[405] = Bus(405, licensePlate: "EP686LW", vehicle: urbino_12)
        BUSES[404] = Bus(404, licensePlate: "EP685LW", vehicle: urbino_12)
        BUSES[403] = Bus(403, licensePlate: "EP684LW", vehicle: urbino_12)
        BUSES[402] = Bus(402, licensePlate: "EP683LW", vehicle: urbino_12)
        BUSES[401] = Bus(401, licensePlate: "EP682LW", vehicle: urbino_12)
        BUSES[400] = Bus(400, licensePlate: "EP681LW", vehicle: urbino_12)
        BUSES[399] = Bus(399, licensePlate: "EP680LW", vehicle: urbino_12)

        BUSES[398] = Bus(398, licensePlate: "EN844YH", vehicle: citaro_10)
        BUSES[397] = Bus(397, licensePlate: "EN845YH", vehicle: citaro_10)
        BUSES[396] = Bus(396, licensePlate: "EN846YH", vehicle: citaro_10)
        BUSES[395] = Bus(395, licensePlate: "EN847YH", vehicle: citaro_10)
        BUSES[394] = Bus(394, licensePlate: "EN848YH", vehicle: citaro_10)
        BUSES[393] = Bus(393, licensePlate: "EN849YH", vehicle: citaro_10)

        BUSES[392] = Bus(392, licensePlate: "EN538YH", vehicle: bus_392)
        BUSES[389] = Bus(389, licensePlate: "EX039JZ", vehicle: vivacity_old)
        BUSES[388] = Bus(388, licensePlate: "EC069JZ", vehicle: bus_388)
        BUSES[387] = Bus(387, licensePlate: "EC070JZ", vehicle: bus_387)

        BUSES[384] = Bus(384, licensePlate: "DP210RY", vehicle: vivacity_old)
        BUSES[383] = Bus(383, licensePlate: "DP007RY", vehicle: vivacity_old)
        BUSES[382] = Bus(382, licensePlate: "DP006RY", vehicle: vivacity_old)
        BUSES[381] = Bus(381, licensePlate: "DP803BR", vehicle: vivacity_old)
        BUSES[380] = Bus(380, licensePlate: "DP802BR", vehicle: vivacity_old)

        BUSES[379] = Bus(379, licensePlate: "DJ368BJ", vehicle: man_lc)
        BUSES[378] = Bus(378, licensePlate: "DJ367BJ", vehicle: man_lc)
        BUSES[377] = Bus(377, licensePlate: "DJ366BJ", vehicle: man_lc)
        BUSES[376] = Bus(376, licensePlate: "DJ365BJ", vehicle: man_lc)

        BUSES[373] = Bus(373, licensePlate: "DJ214BJ", vehicle: avancity)
        BUSES[372] = Bus(372, licensePlate: "DD506YH", vehicle: avancity)
        BUSES[371] = Bus(371, licensePlate: "DD505YH", vehicle: avancity)

        BUSES[370] = Bus(370, licensePlate: "DC172DL", vehicle: bmb_short)

        BUSES[369] = Bus(369, licensePlate: "CZ298ND", vehicle: bus_369)

        BUSES[368] = Bus(368, licensePlate: "CZ114ND", vehicle: m_240)
        BUSES[367] = Bus(367, licensePlate: "CZ113ND", vehicle: m_240)
        BUSES[366] = Bus(366, licensePlate: "CZ112ND", vehicle: m_240)
        BUSES[365] = Bus(365, licensePlate: "DP487RY", vehicle: m_240)
        BUSES[364] = Bus(364, licensePlate: "CZ110ND", vehicle: m_240)
        BUSES[363] = Bus(363, licensePlate: "CZ109ND", vehicle: m_240)
        BUSES[362] = Bus(362, licensePlate: "CZ108ND", vehicle: m_240)
        BUSES[361] = Bus(361, licensePlate: "CZ107ND", vehicle: m_240)
        BUSES[360] = Bus(360, licensePlate: "CZ106ND", vehicle: m_240)
        BUSES[359] = Bus(359, licensePlate: "CZ105ND", vehicle: m_240)
        BUSES[358] = Bus(358, licensePlate: "CZ104ND", vehicle: m_240)
        BUSES[357] = Bus(357, licensePlate: "CZ103ND", vehicle: m_240)
        BUSES[356] = Bus(356, licensePlate: "CZ102ND", vehicle: m_240)
        BUSES[355] = Bus(355, licensePlate: "CZ101ND", vehicle: m_240)

        BUSES[354] = Bus(354, licensePlate: "CX175GP", vehicle: man_lc)
        BUSES[353] = Bus(353, licensePlate: "CX174GP", vehicle: man_lc)
        BUSES[352] = Bus(352, licensePlate: "CX173GP", vehicle: man_lc)
        BUSES[351] = Bus(351, licensePlate: "CX172GP", vehicle: man_lc)
        BUSES[350] = Bus(350, licensePlate: "CX171GP", vehicle: man_lc)
        BUSES[349] = Bus(349, licensePlate: "CX170GP", vehicle: man_lc)

        BUSES[348] = Bus(348, licensePlate: "CV278MW", vehicle: m_240)
        BUSES[347] = Bus(347, licensePlate: "CV282MW", vehicle: m_240)
        BUSES[346] = Bus(346, licensePlate: "CV281MW", vehicle: m_240)
        BUSES[345] = Bus(345, licensePlate: "CV280MW", vehicle: m_240)
        BUSES[344] = Bus(344, licensePlate: "CV279MW", vehicle: m_240)
        BUSES[343] = Bus(343, licensePlate: "CV145MW", vehicle: m_240)
        BUSES[342] = Bus(342, licensePlate: "CV143MW", vehicle: m_240)

        BUSES[341] = Bus(341, licensePlate: "CS121FG", vehicle: bmb_short)
        BUSES[340] = Bus(340, licensePlate: "CS120FG", vehicle: bmb_short)
        BUSES[339] = Bus(339, licensePlate: "CS119FG", vehicle: bmb_short)
        BUSES[338] = Bus(338, licensePlate: "CS118FG", vehicle: bmb_short)
        BUSES[337] = Bus(337, licensePlate: "CS117FG", vehicle: bmb_short)

        BUSES[336] = Bus(336, licensePlate: "CN309ND", vehicle: m_240)
        BUSES[335] = Bus(335, licensePlate: "CN308ND", vehicle: m_240)
        BUSES[334] = Bus(334, licensePlate: "CN307ND", vehicle: m_240)
        BUSES[333] = Bus(333, licensePlate: "CN306ND", vehicle: m_240)
        BUSES[332] = Bus(332, licensePlate: "CN305ND", vehicle: m_240)
        BUSES[331] = Bus(331, licensePlate: "CN304ND", vehicle: m_240)
        BUSES[330] = Bus(330, licensePlate: "BZ863AD", vehicle: bus_330)

        BUSES[328] = Bus(328, licensePlate: "BZ220AB", vehicle: irisbus)
        BUSES[327] = Bus(327, licensePlate: "BZ195AB", vehicle: irisbus)
        BUSES[326] = Bus(326, licensePlate: "BZ125AB", vehicle: irisbus)
        BUSES[325] = Bus(325, licensePlate: "BZ124AB", vehicle: irisbus)
        BUSES[324] = Bus(324, licensePlate: "BZ123AB", vehicle: irisbus)
        BUSES[323] = Bus(323, licensePlate: "BZ122AB", vehicle: irisbus)
        BUSES[322] = Bus(322, licensePlate: "BZ121AB", vehicle: irisbus)
        BUSES[321] = Bus(321, licensePlate: "BZ120AB", vehicle: irisbus)

        BUSES[320] = Bus(320, licensePlate: "BW046TL", vehicle: mb_gn)
        BUSES[319] = Bus(319, licensePlate: "BW047TL", vehicle: mb_gn)

        BUSES[318] = Bus(318, licensePlate: "BP278TS", vehicle: irisbus)
        BUSES[317] = Bus(317, licensePlate: "BP794TR", vehicle: irisbus)
        BUSES[316] = Bus(316, licensePlate: "BP711TR", vehicle: irisbus)
        BUSES[315] = Bus(315, licensePlate: "BP710TR", vehicle: irisbus)
        BUSES[314] = Bus(314, licensePlate: "BP709TR", vehicle: irisbus)
        BUSES[313] = Bus(313, licensePlate: "BP708TR", vehicle: irisbus)
        BUSES[308] = Bus(308, licensePlate: "BM247PE", vehicle: irisbus)
        BUSES[307] = Bus(307, licensePlate: "BM246PE", vehicle: irisbus)
        BUSES[306] = Bus(306, licensePlate: "BM924PD", vehicle: irisbus)
        BUSES[305] = Bus(305, licensePlate: "BM923PD", vehicle: irisbus)
        BUSES[304] = Bus(304, licensePlate: "BM922PD", vehicle: irisbus)
        BUSES[303] = Bus(303, licensePlate: "BM196PC", vehicle: irisbus)
        BUSES[302] = Bus(302, licensePlate: "BM195PC", vehicle: irisbus)
        BUSES[301] = Bus(301, licensePlate: "BM194PC", vehicle: irisbus)
        BUSES[300] = Bus(300, licensePlate: "BM193PC", vehicle: irisbus)
        BUSES[299] = Bus(299, licensePlate: "BK836SF", vehicle: irisbus)

        BUSES[298] = Bus(298, licensePlate: "BK890SF", vehicle: m_240_nu)
        BUSES[297] = Bus(297, licensePlate: "BK889SF", vehicle: m_240_nu)

        BUSES[296] = Bus(296, licensePlate: "BK246SS", vehicle: irisbus)

        BUSES[277] = Bus(277, licensePlate: "AV742KB", vehicle: m_221)
        BUSES[276] = Bus(276, licensePlate: "AV741KB", vehicle: m_221)
        BUSES[275] = Bus(275, licensePlate: "AV740KB", vehicle: m_221)
        BUSES[274] = Bus(274, licensePlate: "AV739KB", vehicle: m_221)

        BUSES[45] = Bus(45, licensePlate: "BZ478AB", vehicle: man_4x_short)
        BUSES[44] = Bus(44, licensePlate: "BW144TJ", vehicle: man_4x_short)
        BUSES[43] = Bus(43, licensePlate: "BW031TJ", vehicle: man_4x_short)

        BUSES[42] = Bus(42, licensePlate: "BM501PC", vehicle: man_4x_long)
        BUSES[41] = Bus(41, licensePlate: "AY703PR", vehicle: man_4x_long)
    }

    static func getBus(id: Int) -> Bus? {
        return BUSES[id]
    }

    class Bus {

        let id: Int
        let licensePlate: String!
        let vehicle: Vehicle

        init(_ id: Int, licensePlate: String, vehicle: Vehicle) {
            self.id = id
            self.licensePlate = licensePlate
            self.vehicle = vehicle
        }
    }

}
