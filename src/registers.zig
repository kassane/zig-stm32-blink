pub fn Register(comptime R: type) type {
    return RegisterRW(R, R);
}

pub fn RegisterRW(comptime Read: type, comptime Write: type) type {
    return struct {
        raw_ptr: *volatile u32,

        const Self = @This();

        pub fn init(address: usize) Self {
            return Self{ .raw_ptr = @intToPtr(*volatile u32, address) };
        }

        pub fn initRange(address: usize, comptime dim_increment: usize, comptime num_registers: usize) [num_registers]Self {
            var registers: [num_registers]Self = undefined;
            var i: usize = 0;
            while (i < num_registers) : (i += 1) {
                registers[i] = Self.init(address + (i * dim_increment));
            }
            return registers;
        }

        pub fn read(self: Self) Read {
            return @bitCast(Read, self.raw_ptr.*);
        }

        pub fn write(self: Self, value: Write) void {
            // Forcing the alignment is a workaround for stores through
            // volatile pointers generating multiple loads and stores.
            // This is necessary for LLVM to generate code that can successfully
            // modify MMIO registers that only allow word-sized stores.
            // https://github.com/ziglang/zig/issues/8981#issuecomment-854911077
            const aligned: Write align(4) = value;
            self.raw_ptr.* = @ptrCast(*const u32, &aligned).*;
        }

        pub fn modify(self: Self, new_value: anytype) void {
            if (Read != Write) {
                @compileError("Can't modify because read and write types for this register aren't the same.");
            }
            var old_value = self.read();
            const info = @typeInfo(@TypeOf(new_value));
            inline for (info.Struct.fields) |field| {
                @field(old_value, field.name) = @field(new_value, field.name);
            }
            self.write(old_value);
        }

        pub fn read_raw(self: Self) u32 {
            return self.raw_ptr.*;
        }

        pub fn write_raw(self: Self, value: u32) void {
            self.raw_ptr.* = value;
        }

        pub fn default_read_value(_: Self) Read {
            return Read{};
        }

        pub fn default_write_value(_: Self) Write {
            return Write{};
        }
    };
}

pub const device_name = "STM32F103xx";
pub const device_revision = "1.3";
pub const device_description = "STM32F103xx";

/// Flexible static memory controller
pub const FSMC = struct {
    const base_address = 0xa0000000;
    /// BCR1
    const BCR1_val = packed struct {
        /// MBKEN [0:0]
        /// MBKEN
        MBKEN: u1 = 0,
        /// MUXEN [1:1]
        /// MUXEN
        MUXEN: u1 = 0,
        /// MTYP [2:3]
        /// MTYP
        MTYP: u2 = 0,
        /// MWID [4:5]
        /// MWID
        MWID: u2 = 1,
        /// FACCEN [6:6]
        /// FACCEN
        FACCEN: u1 = 1,
        /// unused [7:7]
        _unused7: u1 = 1,
        /// BURSTEN [8:8]
        /// BURSTEN
        BURSTEN: u1 = 0,
        /// WAITPOL [9:9]
        /// WAITPOL
        WAITPOL: u1 = 0,
        /// unused [10:10]
        _unused10: u1 = 0,
        /// WAITCFG [11:11]
        /// WAITCFG
        WAITCFG: u1 = 0,
        /// WREN [12:12]
        /// WREN
        WREN: u1 = 1,
        /// WAITEN [13:13]
        /// WAITEN
        WAITEN: u1 = 1,
        /// EXTMOD [14:14]
        /// EXTMOD
        EXTMOD: u1 = 0,
        /// ASYNCWAIT [15:15]
        /// ASYNCWAIT
        ASYNCWAIT: u1 = 0,
        /// unused [16:18]
        _unused16: u3 = 0,
        /// CBURSTRW [19:19]
        /// CBURSTRW
        CBURSTRW: u1 = 0,
        /// unused [20:31]
        _unused20: u4 = 0,
        _unused24: u8 = 0,
    };
    /// SRAM/NOR-Flash chip-select control register
    pub const BCR1 = Register(BCR1_val).init(base_address + 0x0);

    /// BTR1
    const BTR1_val = packed struct {
        /// ADDSET [0:3]
        /// ADDSET
        ADDSET: u4 = 15,
        /// ADDHLD [4:7]
        /// ADDHLD
        ADDHLD: u4 = 15,
        /// DATAST [8:15]
        /// DATAST
        DATAST: u8 = 255,
        /// BUSTURN [16:19]
        /// BUSTURN
        BUSTURN: u4 = 15,
        /// CLKDIV [20:23]
        /// CLKDIV
        CLKDIV: u4 = 15,
        /// DATLAT [24:27]
        /// DATLAT
        DATLAT: u4 = 15,
        /// ACCMOD [28:29]
        /// ACCMOD
        ACCMOD: u2 = 3,
        /// unused [30:31]
        _unused30: u2 = 3,
    };
    /// SRAM/NOR-Flash chip-select timing register
    pub const BTR1 = Register(BTR1_val).init(base_address + 0x4);

    /// BCR2
    const BCR2_val = packed struct {
        /// MBKEN [0:0]
        /// MBKEN
        MBKEN: u1 = 0,
        /// MUXEN [1:1]
        /// MUXEN
        MUXEN: u1 = 0,
        /// MTYP [2:3]
        /// MTYP
        MTYP: u2 = 0,
        /// MWID [4:5]
        /// MWID
        MWID: u2 = 1,
        /// FACCEN [6:6]
        /// FACCEN
        FACCEN: u1 = 1,
        /// unused [7:7]
        _unused7: u1 = 1,
        /// BURSTEN [8:8]
        /// BURSTEN
        BURSTEN: u1 = 0,
        /// WAITPOL [9:9]
        /// WAITPOL
        WAITPOL: u1 = 0,
        /// WRAPMOD [10:10]
        /// WRAPMOD
        WRAPMOD: u1 = 0,
        /// WAITCFG [11:11]
        /// WAITCFG
        WAITCFG: u1 = 0,
        /// WREN [12:12]
        /// WREN
        WREN: u1 = 1,
        /// WAITEN [13:13]
        /// WAITEN
        WAITEN: u1 = 1,
        /// EXTMOD [14:14]
        /// EXTMOD
        EXTMOD: u1 = 0,
        /// ASYNCWAIT [15:15]
        /// ASYNCWAIT
        ASYNCWAIT: u1 = 0,
        /// unused [16:18]
        _unused16: u3 = 0,
        /// CBURSTRW [19:19]
        /// CBURSTRW
        CBURSTRW: u1 = 0,
        /// unused [20:31]
        _unused20: u4 = 0,
        _unused24: u8 = 0,
    };
    /// SRAM/NOR-Flash chip-select control register
    pub const BCR2 = Register(BCR2_val).init(base_address + 0x8);

    /// BTR2
    const BTR2_val = packed struct {
        /// ADDSET [0:3]
        /// ADDSET
        ADDSET: u4 = 15,
        /// ADDHLD [4:7]
        /// ADDHLD
        ADDHLD: u4 = 15,
        /// DATAST [8:15]
        /// DATAST
        DATAST: u8 = 255,
        /// BUSTURN [16:19]
        /// BUSTURN
        BUSTURN: u4 = 15,
        /// CLKDIV [20:23]
        /// CLKDIV
        CLKDIV: u4 = 15,
        /// DATLAT [24:27]
        /// DATLAT
        DATLAT: u4 = 15,
        /// ACCMOD [28:29]
        /// ACCMOD
        ACCMOD: u2 = 3,
        /// unused [30:31]
        _unused30: u2 = 3,
    };
    /// SRAM/NOR-Flash chip-select timing register
    pub const BTR2 = Register(BTR2_val).init(base_address + 0xc);

    /// BCR3
    const BCR3_val = packed struct {
        /// MBKEN [0:0]
        /// MBKEN
        MBKEN: u1 = 0,
        /// MUXEN [1:1]
        /// MUXEN
        MUXEN: u1 = 0,
        /// MTYP [2:3]
        /// MTYP
        MTYP: u2 = 0,
        /// MWID [4:5]
        /// MWID
        MWID: u2 = 1,
        /// FACCEN [6:6]
        /// FACCEN
        FACCEN: u1 = 1,
        /// unused [7:7]
        _unused7: u1 = 1,
        /// BURSTEN [8:8]
        /// BURSTEN
        BURSTEN: u1 = 0,
        /// WAITPOL [9:9]
        /// WAITPOL
        WAITPOL: u1 = 0,
        /// WRAPMOD [10:10]
        /// WRAPMOD
        WRAPMOD: u1 = 0,
        /// WAITCFG [11:11]
        /// WAITCFG
        WAITCFG: u1 = 0,
        /// WREN [12:12]
        /// WREN
        WREN: u1 = 1,
        /// WAITEN [13:13]
        /// WAITEN
        WAITEN: u1 = 1,
        /// EXTMOD [14:14]
        /// EXTMOD
        EXTMOD: u1 = 0,
        /// ASYNCWAIT [15:15]
        /// ASYNCWAIT
        ASYNCWAIT: u1 = 0,
        /// unused [16:18]
        _unused16: u3 = 0,
        /// CBURSTRW [19:19]
        /// CBURSTRW
        CBURSTRW: u1 = 0,
        /// unused [20:31]
        _unused20: u4 = 0,
        _unused24: u8 = 0,
    };
    /// SRAM/NOR-Flash chip-select control register
    pub const BCR3 = Register(BCR3_val).init(base_address + 0x10);

    /// BTR3
    const BTR3_val = packed struct {
        /// ADDSET [0:3]
        /// ADDSET
        ADDSET: u4 = 15,
        /// ADDHLD [4:7]
        /// ADDHLD
        ADDHLD: u4 = 15,
        /// DATAST [8:15]
        /// DATAST
        DATAST: u8 = 255,
        /// BUSTURN [16:19]
        /// BUSTURN
        BUSTURN: u4 = 15,
        /// CLKDIV [20:23]
        /// CLKDIV
        CLKDIV: u4 = 15,
        /// DATLAT [24:27]
        /// DATLAT
        DATLAT: u4 = 15,
        /// ACCMOD [28:29]
        /// ACCMOD
        ACCMOD: u2 = 3,
        /// unused [30:31]
        _unused30: u2 = 3,
    };
    /// SRAM/NOR-Flash chip-select timing register
    pub const BTR3 = Register(BTR3_val).init(base_address + 0x14);

    /// BCR4
    const BCR4_val = packed struct {
        /// MBKEN [0:0]
        /// MBKEN
        MBKEN: u1 = 0,
        /// MUXEN [1:1]
        /// MUXEN
        MUXEN: u1 = 0,
        /// MTYP [2:3]
        /// MTYP
        MTYP: u2 = 0,
        /// MWID [4:5]
        /// MWID
        MWID: u2 = 1,
        /// FACCEN [6:6]
        /// FACCEN
        FACCEN: u1 = 1,
        /// unused [7:7]
        _unused7: u1 = 1,
        /// BURSTEN [8:8]
        /// BURSTEN
        BURSTEN: u1 = 0,
        /// WAITPOL [9:9]
        /// WAITPOL
        WAITPOL: u1 = 0,
        /// WRAPMOD [10:10]
        /// WRAPMOD
        WRAPMOD: u1 = 0,
        /// WAITCFG [11:11]
        /// WAITCFG
        WAITCFG: u1 = 0,
        /// WREN [12:12]
        /// WREN
        WREN: u1 = 1,
        /// WAITEN [13:13]
        /// WAITEN
        WAITEN: u1 = 1,
        /// EXTMOD [14:14]
        /// EXTMOD
        EXTMOD: u1 = 0,
        /// ASYNCWAIT [15:15]
        /// ASYNCWAIT
        ASYNCWAIT: u1 = 0,
        /// unused [16:18]
        _unused16: u3 = 0,
        /// CBURSTRW [19:19]
        /// CBURSTRW
        CBURSTRW: u1 = 0,
        /// unused [20:31]
        _unused20: u4 = 0,
        _unused24: u8 = 0,
    };
    /// SRAM/NOR-Flash chip-select control register
    pub const BCR4 = Register(BCR4_val).init(base_address + 0x18);

    /// BTR4
    const BTR4_val = packed struct {
        /// ADDSET [0:3]
        /// ADDSET
        ADDSET: u4 = 15,
        /// ADDHLD [4:7]
        /// ADDHLD
        ADDHLD: u4 = 15,
        /// DATAST [8:15]
        /// DATAST
        DATAST: u8 = 255,
        /// BUSTURN [16:19]
        /// BUSTURN
        BUSTURN: u4 = 15,
        /// CLKDIV [20:23]
        /// CLKDIV
        CLKDIV: u4 = 15,
        /// DATLAT [24:27]
        /// DATLAT
        DATLAT: u4 = 15,
        /// ACCMOD [28:29]
        /// ACCMOD
        ACCMOD: u2 = 3,
        /// unused [30:31]
        _unused30: u2 = 3,
    };
    /// SRAM/NOR-Flash chip-select timing register
    pub const BTR4 = Register(BTR4_val).init(base_address + 0x1c);

    /// PCR2
    const PCR2_val = packed struct {
        /// unused [0:0]
        _unused0: u1 = 0,
        /// PWAITEN [1:1]
        /// PWAITEN
        PWAITEN: u1 = 0,
        /// PBKEN [2:2]
        /// PBKEN
        PBKEN: u1 = 0,
        /// PTYP [3:3]
        /// PTYP
        PTYP: u1 = 1,
        /// PWID [4:5]
        /// PWID
        PWID: u2 = 1,
        /// ECCEN [6:6]
        /// ECCEN
        ECCEN: u1 = 0,
        /// unused [7:8]
        _unused7: u1 = 0,
        _unused8: u1 = 0,
        /// TCLR [9:12]
        /// TCLR
        TCLR: u4 = 0,
        /// TAR [13:16]
        /// TAR
        TAR: u4 = 0,
        /// ECCPS [17:19]
        /// ECCPS
        ECCPS: u3 = 0,
        /// unused [20:31]
        _unused20: u4 = 0,
        _unused24: u8 = 0,
    };
    /// PC Card/NAND Flash control register
    pub const PCR2 = Register(PCR2_val).init(base_address + 0x60);

    /// SR2
    const SR2_val = packed struct {
        /// IRS [0:0]
        /// IRS
        IRS: u1 = 0,
        /// ILS [1:1]
        /// ILS
        ILS: u1 = 0,
        /// IFS [2:2]
        /// IFS
        IFS: u1 = 0,
        /// IREN [3:3]
        /// IREN
        IREN: u1 = 0,
        /// ILEN [4:4]
        /// ILEN
        ILEN: u1 = 0,
        /// IFEN [5:5]
        /// IFEN
        IFEN: u1 = 0,
        /// FEMPT [6:6]
        /// FEMPT
        FEMPT: u1 = 1,
        /// unused [7:31]
        _unused7: u1 = 0,
        _unused8: u8 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// FIFO status and interrupt register
    pub const SR2 = Register(SR2_val).init(base_address + 0x64);

    /// PMEM2
    const PMEM2_val = packed struct {
        /// MEMSETx [0:7]
        /// MEMSETx
        MEMSETx: u8 = 252,
        /// MEMWAITx [8:15]
        /// MEMWAITx
        MEMWAITx: u8 = 252,
        /// MEMHOLDx [16:23]
        /// MEMHOLDx
        MEMHOLDx: u8 = 252,
        /// MEMHIZx [24:31]
        /// MEMHIZx
        MEMHIZx: u8 = 252,
    };
    /// Common memory space timing register
    pub const PMEM2 = Register(PMEM2_val).init(base_address + 0x68);

    /// PATT2
    const PATT2_val = packed struct {
        /// ATTSETx [0:7]
        /// Attribute memory x setup
        ATTSETx: u8 = 252,
        /// ATTWAITx [8:15]
        /// Attribute memory x wait
        ATTWAITx: u8 = 252,
        /// ATTHOLDx [16:23]
        /// Attribute memory x hold
        ATTHOLDx: u8 = 252,
        /// ATTHIZx [24:31]
        /// Attribute memory x databus HiZ
        ATTHIZx: u8 = 252,
    };
    /// Attribute memory space timing register
    pub const PATT2 = Register(PATT2_val).init(base_address + 0x6c);

    /// ECCR2
    const ECCR2_val = packed struct {
        /// ECCx [0:31]
        /// ECC result
        ECCx: u32 = 0,
    };
    /// ECC result register 2
    pub const ECCR2 = Register(ECCR2_val).init(base_address + 0x74);

    /// PCR3
    const PCR3_val = packed struct {
        /// unused [0:0]
        _unused0: u1 = 0,
        /// PWAITEN [1:1]
        /// PWAITEN
        PWAITEN: u1 = 0,
        /// PBKEN [2:2]
        /// PBKEN
        PBKEN: u1 = 0,
        /// PTYP [3:3]
        /// PTYP
        PTYP: u1 = 1,
        /// PWID [4:5]
        /// PWID
        PWID: u2 = 1,
        /// ECCEN [6:6]
        /// ECCEN
        ECCEN: u1 = 0,
        /// unused [7:8]
        _unused7: u1 = 0,
        _unused8: u1 = 0,
        /// TCLR [9:12]
        /// TCLR
        TCLR: u4 = 0,
        /// TAR [13:16]
        /// TAR
        TAR: u4 = 0,
        /// ECCPS [17:19]
        /// ECCPS
        ECCPS: u3 = 0,
        /// unused [20:31]
        _unused20: u4 = 0,
        _unused24: u8 = 0,
    };
    /// PC Card/NAND Flash control register
    pub const PCR3 = Register(PCR3_val).init(base_address + 0x80);

    /// SR3
    const SR3_val = packed struct {
        /// IRS [0:0]
        /// IRS
        IRS: u1 = 0,
        /// ILS [1:1]
        /// ILS
        ILS: u1 = 0,
        /// IFS [2:2]
        /// IFS
        IFS: u1 = 0,
        /// IREN [3:3]
        /// IREN
        IREN: u1 = 0,
        /// ILEN [4:4]
        /// ILEN
        ILEN: u1 = 0,
        /// IFEN [5:5]
        /// IFEN
        IFEN: u1 = 0,
        /// FEMPT [6:6]
        /// FEMPT
        FEMPT: u1 = 1,
        /// unused [7:31]
        _unused7: u1 = 0,
        _unused8: u8 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// FIFO status and interrupt register
    pub const SR3 = Register(SR3_val).init(base_address + 0x84);

    /// PMEM3
    const PMEM3_val = packed struct {
        /// MEMSETx [0:7]
        /// MEMSETx
        MEMSETx: u8 = 252,
        /// MEMWAITx [8:15]
        /// MEMWAITx
        MEMWAITx: u8 = 252,
        /// MEMHOLDx [16:23]
        /// MEMHOLDx
        MEMHOLDx: u8 = 252,
        /// MEMHIZx [24:31]
        /// MEMHIZx
        MEMHIZx: u8 = 252,
    };
    /// Common memory space timing register
    pub const PMEM3 = Register(PMEM3_val).init(base_address + 0x88);

    /// PATT3
    const PATT3_val = packed struct {
        /// ATTSETx [0:7]
        /// ATTSETx
        ATTSETx: u8 = 252,
        /// ATTWAITx [8:15]
        /// ATTWAITx
        ATTWAITx: u8 = 252,
        /// ATTHOLDx [16:23]
        /// ATTHOLDx
        ATTHOLDx: u8 = 252,
        /// ATTHIZx [24:31]
        /// ATTHIZx
        ATTHIZx: u8 = 252,
    };
    /// Attribute memory space timing register
    pub const PATT3 = Register(PATT3_val).init(base_address + 0x8c);

    /// ECCR3
    const ECCR3_val = packed struct {
        /// ECCx [0:31]
        /// ECCx
        ECCx: u32 = 0,
    };
    /// ECC result register 3
    pub const ECCR3 = Register(ECCR3_val).init(base_address + 0x94);

    /// PCR4
    const PCR4_val = packed struct {
        /// unused [0:0]
        _unused0: u1 = 0,
        /// PWAITEN [1:1]
        /// PWAITEN
        PWAITEN: u1 = 0,
        /// PBKEN [2:2]
        /// PBKEN
        PBKEN: u1 = 0,
        /// PTYP [3:3]
        /// PTYP
        PTYP: u1 = 1,
        /// PWID [4:5]
        /// PWID
        PWID: u2 = 1,
        /// ECCEN [6:6]
        /// ECCEN
        ECCEN: u1 = 0,
        /// unused [7:8]
        _unused7: u1 = 0,
        _unused8: u1 = 0,
        /// TCLR [9:12]
        /// TCLR
        TCLR: u4 = 0,
        /// TAR [13:16]
        /// TAR
        TAR: u4 = 0,
        /// ECCPS [17:19]
        /// ECCPS
        ECCPS: u3 = 0,
        /// unused [20:31]
        _unused20: u4 = 0,
        _unused24: u8 = 0,
    };
    /// PC Card/NAND Flash control register
    pub const PCR4 = Register(PCR4_val).init(base_address + 0xa0);

    /// SR4
    const SR4_val = packed struct {
        /// IRS [0:0]
        /// IRS
        IRS: u1 = 0,
        /// ILS [1:1]
        /// ILS
        ILS: u1 = 0,
        /// IFS [2:2]
        /// IFS
        IFS: u1 = 0,
        /// IREN [3:3]
        /// IREN
        IREN: u1 = 0,
        /// ILEN [4:4]
        /// ILEN
        ILEN: u1 = 0,
        /// IFEN [5:5]
        /// IFEN
        IFEN: u1 = 0,
        /// FEMPT [6:6]
        /// FEMPT
        FEMPT: u1 = 1,
        /// unused [7:31]
        _unused7: u1 = 0,
        _unused8: u8 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// FIFO status and interrupt register
    pub const SR4 = Register(SR4_val).init(base_address + 0xa4);

    /// PMEM4
    const PMEM4_val = packed struct {
        /// MEMSETx [0:7]
        /// MEMSETx
        MEMSETx: u8 = 252,
        /// MEMWAITx [8:15]
        /// MEMWAITx
        MEMWAITx: u8 = 252,
        /// MEMHOLDx [16:23]
        /// MEMHOLDx
        MEMHOLDx: u8 = 252,
        /// MEMHIZx [24:31]
        /// MEMHIZx
        MEMHIZx: u8 = 252,
    };
    /// Common memory space timing register
    pub const PMEM4 = Register(PMEM4_val).init(base_address + 0xa8);

    /// PATT4
    const PATT4_val = packed struct {
        /// ATTSETx [0:7]
        /// ATTSETx
        ATTSETx: u8 = 252,
        /// ATTWAITx [8:15]
        /// ATTWAITx
        ATTWAITx: u8 = 252,
        /// ATTHOLDx [16:23]
        /// ATTHOLDx
        ATTHOLDx: u8 = 252,
        /// ATTHIZx [24:31]
        /// ATTHIZx
        ATTHIZx: u8 = 252,
    };
    /// Attribute memory space timing register
    pub const PATT4 = Register(PATT4_val).init(base_address + 0xac);

    /// PIO4
    const PIO4_val = packed struct {
        /// IOSETx [0:7]
        /// IOSETx
        IOSETx: u8 = 252,
        /// IOWAITx [8:15]
        /// IOWAITx
        IOWAITx: u8 = 252,
        /// IOHOLDx [16:23]
        /// IOHOLDx
        IOHOLDx: u8 = 252,
        /// IOHIZx [24:31]
        /// IOHIZx
        IOHIZx: u8 = 252,
    };
    /// I/O space timing register 4
    pub const PIO4 = Register(PIO4_val).init(base_address + 0xb0);

    /// BWTR1
    const BWTR1_val = packed struct {
        /// ADDSET [0:3]
        /// ADDSET
        ADDSET: u4 = 15,
        /// ADDHLD [4:7]
        /// ADDHLD
        ADDHLD: u4 = 15,
        /// DATAST [8:15]
        /// DATAST
        DATAST: u8 = 255,
        /// unused [16:19]
        _unused16: u4 = 15,
        /// CLKDIV [20:23]
        /// CLKDIV
        CLKDIV: u4 = 15,
        /// DATLAT [24:27]
        /// DATLAT
        DATLAT: u4 = 15,
        /// ACCMOD [28:29]
        /// ACCMOD
        ACCMOD: u2 = 0,
        /// unused [30:31]
        _unused30: u2 = 0,
    };
    /// SRAM/NOR-Flash write timing registers
    pub const BWTR1 = Register(BWTR1_val).init(base_address + 0x104);

    /// BWTR2
    const BWTR2_val = packed struct {
        /// ADDSET [0:3]
        /// ADDSET
        ADDSET: u4 = 15,
        /// ADDHLD [4:7]
        /// ADDHLD
        ADDHLD: u4 = 15,
        /// DATAST [8:15]
        /// DATAST
        DATAST: u8 = 255,
        /// unused [16:19]
        _unused16: u4 = 15,
        /// CLKDIV [20:23]
        /// CLKDIV
        CLKDIV: u4 = 15,
        /// DATLAT [24:27]
        /// DATLAT
        DATLAT: u4 = 15,
        /// ACCMOD [28:29]
        /// ACCMOD
        ACCMOD: u2 = 0,
        /// unused [30:31]
        _unused30: u2 = 0,
    };
    /// SRAM/NOR-Flash write timing registers
    pub const BWTR2 = Register(BWTR2_val).init(base_address + 0x10c);

    /// BWTR3
    const BWTR3_val = packed struct {
        /// ADDSET [0:3]
        /// ADDSET
        ADDSET: u4 = 15,
        /// ADDHLD [4:7]
        /// ADDHLD
        ADDHLD: u4 = 15,
        /// DATAST [8:15]
        /// DATAST
        DATAST: u8 = 255,
        /// unused [16:19]
        _unused16: u4 = 15,
        /// CLKDIV [20:23]
        /// CLKDIV
        CLKDIV: u4 = 15,
        /// DATLAT [24:27]
        /// DATLAT
        DATLAT: u4 = 15,
        /// ACCMOD [28:29]
        /// ACCMOD
        ACCMOD: u2 = 0,
        /// unused [30:31]
        _unused30: u2 = 0,
    };
    /// SRAM/NOR-Flash write timing registers
    pub const BWTR3 = Register(BWTR3_val).init(base_address + 0x114);

    /// BWTR4
    const BWTR4_val = packed struct {
        /// ADDSET [0:3]
        /// ADDSET
        ADDSET: u4 = 15,
        /// ADDHLD [4:7]
        /// ADDHLD
        ADDHLD: u4 = 15,
        /// DATAST [8:15]
        /// DATAST
        DATAST: u8 = 255,
        /// unused [16:19]
        _unused16: u4 = 15,
        /// CLKDIV [20:23]
        /// CLKDIV
        CLKDIV: u4 = 15,
        /// DATLAT [24:27]
        /// DATLAT
        DATLAT: u4 = 15,
        /// ACCMOD [28:29]
        /// ACCMOD
        ACCMOD: u2 = 0,
        /// unused [30:31]
        _unused30: u2 = 0,
    };
    /// SRAM/NOR-Flash write timing registers
    pub const BWTR4 = Register(BWTR4_val).init(base_address + 0x11c);
};

/// Power control
pub const PWR = struct {
    const base_address = 0x40007000;
    /// CR
    const CR_val = packed struct {
        /// LPDS [0:0]
        /// Low Power Deep Sleep
        LPDS: u1 = 0,
        /// PDDS [1:1]
        /// Power Down Deep Sleep
        PDDS: u1 = 0,
        /// CWUF [2:2]
        /// Clear Wake-up Flag
        CWUF: u1 = 0,
        /// CSBF [3:3]
        /// Clear STANDBY Flag
        CSBF: u1 = 0,
        /// PVDE [4:4]
        /// Power Voltage Detector
        PVDE: u1 = 0,
        /// PLS [5:7]
        /// PVD Level Selection
        PLS: u3 = 0,
        /// DBP [8:8]
        /// Disable Backup Domain write
        DBP: u1 = 0,
        /// unused [9:31]
        _unused9: u7 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Power control register
    pub const CR = Register(CR_val).init(base_address + 0x0);

    /// CSR
    const CSR_val = packed struct {
        /// WUF [0:0]
        /// Wake-Up Flag
        WUF: u1 = 0,
        /// SBF [1:1]
        /// STANDBY Flag
        SBF: u1 = 0,
        /// PVDO [2:2]
        /// PVD Output
        PVDO: u1 = 0,
        /// unused [3:7]
        _unused3: u5 = 0,
        /// EWUP [8:8]
        /// Enable WKUP pin
        EWUP: u1 = 0,
        /// unused [9:31]
        _unused9: u7 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Power control register
    pub const CSR = Register(CSR_val).init(base_address + 0x4);
};

/// Reset and clock control
pub const RCC = struct {
    const base_address = 0x40021000;
    /// CR
    const CR_val = packed struct {
        /// HSION [0:0]
        /// Internal High Speed clock
        HSION: u1 = 1,
        /// HSIRDY [1:1]
        /// Internal High Speed clock ready
        HSIRDY: u1 = 1,
        /// unused [2:2]
        _unused2: u1 = 0,
        /// HSITRIM [3:7]
        /// Internal High Speed clock
        HSITRIM: u5 = 16,
        /// HSICAL [8:15]
        /// Internal High Speed clock
        HSICAL: u8 = 0,
        /// HSEON [16:16]
        /// External High Speed clock
        HSEON: u1 = 0,
        /// HSERDY [17:17]
        /// External High Speed clock ready
        HSERDY: u1 = 0,
        /// HSEBYP [18:18]
        /// External High Speed clock
        HSEBYP: u1 = 0,
        /// CSSON [19:19]
        /// Clock Security System
        CSSON: u1 = 0,
        /// unused [20:23]
        _unused20: u4 = 0,
        /// PLLON [24:24]
        /// PLL enable
        PLLON: u1 = 0,
        /// PLLRDY [25:25]
        /// PLL clock ready flag
        PLLRDY: u1 = 0,
        /// unused [26:31]
        _unused26: u6 = 0,
    };
    /// Clock control register
    pub const CR = Register(CR_val).init(base_address + 0x0);

    /// CFGR
    const CFGR_val = packed struct {
        /// SW [0:1]
        /// System clock Switch
        SW: u2 = 0,
        /// SWS [2:3]
        /// System Clock Switch Status
        SWS: u2 = 0,
        /// HPRE [4:7]
        /// AHB prescaler
        HPRE: u4 = 0,
        /// PPRE1 [8:10]
        /// APB Low speed prescaler
        PPRE1: u3 = 0,
        /// PPRE2 [11:13]
        /// APB High speed prescaler
        PPRE2: u3 = 0,
        /// ADCPRE [14:15]
        /// ADC prescaler
        ADCPRE: u2 = 0,
        /// PLLSRC [16:16]
        /// PLL entry clock source
        PLLSRC: u1 = 0,
        /// PLLXTPRE [17:17]
        /// HSE divider for PLL entry
        PLLXTPRE: u1 = 0,
        /// PLLMUL [18:21]
        /// PLL Multiplication Factor
        PLLMUL: u4 = 0,
        /// OTGFSPRE [22:22]
        /// USB OTG FS prescaler
        OTGFSPRE: u1 = 0,
        /// unused [23:23]
        _unused23: u1 = 0,
        /// MCO [24:26]
        /// Microcontroller clock
        MCO: u3 = 0,
        /// unused [27:31]
        _unused27: u5 = 0,
    };
    /// Clock configuration register
    pub const CFGR = Register(CFGR_val).init(base_address + 0x4);

    /// CIR
    const CIR_val = packed struct {
        /// LSIRDYF [0:0]
        /// LSI Ready Interrupt flag
        LSIRDYF: u1 = 0,
        /// LSERDYF [1:1]
        /// LSE Ready Interrupt flag
        LSERDYF: u1 = 0,
        /// HSIRDYF [2:2]
        /// HSI Ready Interrupt flag
        HSIRDYF: u1 = 0,
        /// HSERDYF [3:3]
        /// HSE Ready Interrupt flag
        HSERDYF: u1 = 0,
        /// PLLRDYF [4:4]
        /// PLL Ready Interrupt flag
        PLLRDYF: u1 = 0,
        /// unused [5:6]
        _unused5: u2 = 0,
        /// CSSF [7:7]
        /// Clock Security System Interrupt
        CSSF: u1 = 0,
        /// LSIRDYIE [8:8]
        /// LSI Ready Interrupt Enable
        LSIRDYIE: u1 = 0,
        /// LSERDYIE [9:9]
        /// LSE Ready Interrupt Enable
        LSERDYIE: u1 = 0,
        /// HSIRDYIE [10:10]
        /// HSI Ready Interrupt Enable
        HSIRDYIE: u1 = 0,
        /// HSERDYIE [11:11]
        /// HSE Ready Interrupt Enable
        HSERDYIE: u1 = 0,
        /// PLLRDYIE [12:12]
        /// PLL Ready Interrupt Enable
        PLLRDYIE: u1 = 0,
        /// unused [13:15]
        _unused13: u3 = 0,
        /// LSIRDYC [16:16]
        /// LSI Ready Interrupt Clear
        LSIRDYC: u1 = 0,
        /// LSERDYC [17:17]
        /// LSE Ready Interrupt Clear
        LSERDYC: u1 = 0,
        /// HSIRDYC [18:18]
        /// HSI Ready Interrupt Clear
        HSIRDYC: u1 = 0,
        /// HSERDYC [19:19]
        /// HSE Ready Interrupt Clear
        HSERDYC: u1 = 0,
        /// PLLRDYC [20:20]
        /// PLL Ready Interrupt Clear
        PLLRDYC: u1 = 0,
        /// unused [21:22]
        _unused21: u2 = 0,
        /// CSSC [23:23]
        /// Clock security system interrupt
        CSSC: u1 = 0,
        /// unused [24:31]
        _unused24: u8 = 0,
    };
    /// Clock interrupt register
    pub const CIR = Register(CIR_val).init(base_address + 0x8);

    /// APB2RSTR
    const APB2RSTR_val = packed struct {
        /// AFIORST [0:0]
        /// Alternate function I/O
        AFIORST: u1 = 0,
        /// unused [1:1]
        _unused1: u1 = 0,
        /// IOPARST [2:2]
        /// IO port A reset
        IOPARST: u1 = 0,
        /// IOPBRST [3:3]
        /// IO port B reset
        IOPBRST: u1 = 0,
        /// IOPCRST [4:4]
        /// IO port C reset
        IOPCRST: u1 = 0,
        /// IOPDRST [5:5]
        /// IO port D reset
        IOPDRST: u1 = 0,
        /// IOPERST [6:6]
        /// IO port E reset
        IOPERST: u1 = 0,
        /// IOPFRST [7:7]
        /// IO port F reset
        IOPFRST: u1 = 0,
        /// IOPGRST [8:8]
        /// IO port G reset
        IOPGRST: u1 = 0,
        /// ADC1RST [9:9]
        /// ADC 1 interface reset
        ADC1RST: u1 = 0,
        /// ADC2RST [10:10]
        /// ADC 2 interface reset
        ADC2RST: u1 = 0,
        /// TIM1RST [11:11]
        /// TIM1 timer reset
        TIM1RST: u1 = 0,
        /// SPI1RST [12:12]
        /// SPI 1 reset
        SPI1RST: u1 = 0,
        /// TIM8RST [13:13]
        /// TIM8 timer reset
        TIM8RST: u1 = 0,
        /// USART1RST [14:14]
        /// USART1 reset
        USART1RST: u1 = 0,
        /// ADC3RST [15:15]
        /// ADC 3 interface reset
        ADC3RST: u1 = 0,
        /// unused [16:18]
        _unused16: u3 = 0,
        /// TIM9RST [19:19]
        /// TIM9 timer reset
        TIM9RST: u1 = 0,
        /// TIM10RST [20:20]
        /// TIM10 timer reset
        TIM10RST: u1 = 0,
        /// TIM11RST [21:21]
        /// TIM11 timer reset
        TIM11RST: u1 = 0,
        /// unused [22:31]
        _unused22: u2 = 0,
        _unused24: u8 = 0,
    };
    /// APB2 peripheral reset register
    pub const APB2RSTR = Register(APB2RSTR_val).init(base_address + 0xc);

    /// APB1RSTR
    const APB1RSTR_val = packed struct {
        /// TIM2RST [0:0]
        /// Timer 2 reset
        TIM2RST: u1 = 0,
        /// TIM3RST [1:1]
        /// Timer 3 reset
        TIM3RST: u1 = 0,
        /// TIM4RST [2:2]
        /// Timer 4 reset
        TIM4RST: u1 = 0,
        /// TIM5RST [3:3]
        /// Timer 5 reset
        TIM5RST: u1 = 0,
        /// TIM6RST [4:4]
        /// Timer 6 reset
        TIM6RST: u1 = 0,
        /// TIM7RST [5:5]
        /// Timer 7 reset
        TIM7RST: u1 = 0,
        /// TIM12RST [6:6]
        /// Timer 12 reset
        TIM12RST: u1 = 0,
        /// TIM13RST [7:7]
        /// Timer 13 reset
        TIM13RST: u1 = 0,
        /// TIM14RST [8:8]
        /// Timer 14 reset
        TIM14RST: u1 = 0,
        /// unused [9:10]
        _unused9: u2 = 0,
        /// WWDGRST [11:11]
        /// Window watchdog reset
        WWDGRST: u1 = 0,
        /// unused [12:13]
        _unused12: u2 = 0,
        /// SPI2RST [14:14]
        /// SPI2 reset
        SPI2RST: u1 = 0,
        /// SPI3RST [15:15]
        /// SPI3 reset
        SPI3RST: u1 = 0,
        /// unused [16:16]
        _unused16: u1 = 0,
        /// USART2RST [17:17]
        /// USART 2 reset
        USART2RST: u1 = 0,
        /// USART3RST [18:18]
        /// USART 3 reset
        USART3RST: u1 = 0,
        /// UART4RST [19:19]
        /// UART 4 reset
        UART4RST: u1 = 0,
        /// UART5RST [20:20]
        /// UART 5 reset
        UART5RST: u1 = 0,
        /// I2C1RST [21:21]
        /// I2C1 reset
        I2C1RST: u1 = 0,
        /// I2C2RST [22:22]
        /// I2C2 reset
        I2C2RST: u1 = 0,
        /// USBRST [23:23]
        /// USB reset
        USBRST: u1 = 0,
        /// unused [24:24]
        _unused24: u1 = 0,
        /// CANRST [25:25]
        /// CAN reset
        CANRST: u1 = 0,
        /// unused [26:26]
        _unused26: u1 = 0,
        /// BKPRST [27:27]
        /// Backup interface reset
        BKPRST: u1 = 0,
        /// PWRRST [28:28]
        /// Power interface reset
        PWRRST: u1 = 0,
        /// DACRST [29:29]
        /// DAC interface reset
        DACRST: u1 = 0,
        /// unused [30:31]
        _unused30: u2 = 0,
    };
    /// APB1 peripheral reset register
    pub const APB1RSTR = Register(APB1RSTR_val).init(base_address + 0x10);

    /// AHBENR
    const AHBENR_val = packed struct {
        /// DMA1EN [0:0]
        /// DMA1 clock enable
        DMA1EN: u1 = 0,
        /// DMA2EN [1:1]
        /// DMA2 clock enable
        DMA2EN: u1 = 0,
        /// SRAMEN [2:2]
        /// SRAM interface clock
        SRAMEN: u1 = 1,
        /// unused [3:3]
        _unused3: u1 = 0,
        /// FLITFEN [4:4]
        /// FLITF clock enable
        FLITFEN: u1 = 1,
        /// unused [5:5]
        _unused5: u1 = 0,
        /// CRCEN [6:6]
        /// CRC clock enable
        CRCEN: u1 = 0,
        /// unused [7:7]
        _unused7: u1 = 0,
        /// FSMCEN [8:8]
        /// FSMC clock enable
        FSMCEN: u1 = 0,
        /// unused [9:9]
        _unused9: u1 = 0,
        /// SDIOEN [10:10]
        /// SDIO clock enable
        SDIOEN: u1 = 0,
        /// unused [11:31]
        _unused11: u5 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// AHB Peripheral Clock enable register
    pub const AHBENR = Register(AHBENR_val).init(base_address + 0x14);

    /// APB2ENR
    const APB2ENR_val = packed struct {
        /// AFIOEN [0:0]
        /// Alternate function I/O clock
        AFIOEN: u1 = 0,
        /// unused [1:1]
        _unused1: u1 = 0,
        /// IOPAEN [2:2]
        /// I/O port A clock enable
        IOPAEN: u1 = 0,
        /// IOPBEN [3:3]
        /// I/O port B clock enable
        IOPBEN: u1 = 0,
        /// IOPCEN [4:4]
        /// I/O port C clock enable
        IOPCEN: u1 = 0,
        /// IOPDEN [5:5]
        /// I/O port D clock enable
        IOPDEN: u1 = 0,
        /// IOPEEN [6:6]
        /// I/O port E clock enable
        IOPEEN: u1 = 0,
        /// IOPFEN [7:7]
        /// I/O port F clock enable
        IOPFEN: u1 = 0,
        /// IOPGEN [8:8]
        /// I/O port G clock enable
        IOPGEN: u1 = 0,
        /// ADC1EN [9:9]
        /// ADC 1 interface clock
        ADC1EN: u1 = 0,
        /// ADC2EN [10:10]
        /// ADC 2 interface clock
        ADC2EN: u1 = 0,
        /// TIM1EN [11:11]
        /// TIM1 Timer clock enable
        TIM1EN: u1 = 0,
        /// SPI1EN [12:12]
        /// SPI 1 clock enable
        SPI1EN: u1 = 0,
        /// TIM8EN [13:13]
        /// TIM8 Timer clock enable
        TIM8EN: u1 = 0,
        /// USART1EN [14:14]
        /// USART1 clock enable
        USART1EN: u1 = 0,
        /// ADC3EN [15:15]
        /// ADC3 interface clock
        ADC3EN: u1 = 0,
        /// unused [16:18]
        _unused16: u3 = 0,
        /// TIM9EN [19:19]
        /// TIM9 Timer clock enable
        TIM9EN: u1 = 0,
        /// TIM10EN [20:20]
        /// TIM10 Timer clock enable
        TIM10EN: u1 = 0,
        /// TIM11EN [21:21]
        /// TIM11 Timer clock enable
        TIM11EN: u1 = 0,
        /// unused [22:31]
        _unused22: u2 = 0,
        _unused24: u8 = 0,
    };
    /// APB2 peripheral clock enable register
    pub const APB2ENR = Register(APB2ENR_val).init(base_address + 0x18);

    /// APB1ENR
    const APB1ENR_val = packed struct {
        /// TIM2EN [0:0]
        /// Timer 2 clock enable
        TIM2EN: u1 = 0,
        /// TIM3EN [1:1]
        /// Timer 3 clock enable
        TIM3EN: u1 = 0,
        /// TIM4EN [2:2]
        /// Timer 4 clock enable
        TIM4EN: u1 = 0,
        /// TIM5EN [3:3]
        /// Timer 5 clock enable
        TIM5EN: u1 = 0,
        /// TIM6EN [4:4]
        /// Timer 6 clock enable
        TIM6EN: u1 = 0,
        /// TIM7EN [5:5]
        /// Timer 7 clock enable
        TIM7EN: u1 = 0,
        /// TIM12EN [6:6]
        /// Timer 12 clock enable
        TIM12EN: u1 = 0,
        /// TIM13EN [7:7]
        /// Timer 13 clock enable
        TIM13EN: u1 = 0,
        /// TIM14EN [8:8]
        /// Timer 14 clock enable
        TIM14EN: u1 = 0,
        /// unused [9:10]
        _unused9: u2 = 0,
        /// WWDGEN [11:11]
        /// Window watchdog clock
        WWDGEN: u1 = 0,
        /// unused [12:13]
        _unused12: u2 = 0,
        /// SPI2EN [14:14]
        /// SPI 2 clock enable
        SPI2EN: u1 = 0,
        /// SPI3EN [15:15]
        /// SPI 3 clock enable
        SPI3EN: u1 = 0,
        /// unused [16:16]
        _unused16: u1 = 0,
        /// USART2EN [17:17]
        /// USART 2 clock enable
        USART2EN: u1 = 0,
        /// USART3EN [18:18]
        /// USART 3 clock enable
        USART3EN: u1 = 0,
        /// UART4EN [19:19]
        /// UART 4 clock enable
        UART4EN: u1 = 0,
        /// UART5EN [20:20]
        /// UART 5 clock enable
        UART5EN: u1 = 0,
        /// I2C1EN [21:21]
        /// I2C 1 clock enable
        I2C1EN: u1 = 0,
        /// I2C2EN [22:22]
        /// I2C 2 clock enable
        I2C2EN: u1 = 0,
        /// USBEN [23:23]
        /// USB clock enable
        USBEN: u1 = 0,
        /// unused [24:24]
        _unused24: u1 = 0,
        /// CANEN [25:25]
        /// CAN clock enable
        CANEN: u1 = 0,
        /// unused [26:26]
        _unused26: u1 = 0,
        /// BKPEN [27:27]
        /// Backup interface clock
        BKPEN: u1 = 0,
        /// PWREN [28:28]
        /// Power interface clock
        PWREN: u1 = 0,
        /// DACEN [29:29]
        /// DAC interface clock enable
        DACEN: u1 = 0,
        /// unused [30:31]
        _unused30: u2 = 0,
    };
    /// APB1 peripheral clock enable register
    pub const APB1ENR = Register(APB1ENR_val).init(base_address + 0x1c);

    /// BDCR
    const BDCR_val = packed struct {
        /// LSEON [0:0]
        /// External Low Speed oscillator
        LSEON: u1 = 0,
        /// LSERDY [1:1]
        /// External Low Speed oscillator
        LSERDY: u1 = 0,
        /// LSEBYP [2:2]
        /// External Low Speed oscillator
        LSEBYP: u1 = 0,
        /// unused [3:7]
        _unused3: u5 = 0,
        /// RTCSEL [8:9]
        /// RTC clock source selection
        RTCSEL: u2 = 0,
        /// unused [10:14]
        _unused10: u5 = 0,
        /// RTCEN [15:15]
        /// RTC clock enable
        RTCEN: u1 = 0,
        /// BDRST [16:16]
        /// Backup domain software
        BDRST: u1 = 0,
        /// unused [17:31]
        _unused17: u7 = 0,
        _unused24: u8 = 0,
    };
    /// Backup domain control register
    pub const BDCR = Register(BDCR_val).init(base_address + 0x20);

    /// CSR
    const CSR_val = packed struct {
        /// LSION [0:0]
        /// Internal low speed oscillator
        LSION: u1 = 0,
        /// LSIRDY [1:1]
        /// Internal low speed oscillator
        LSIRDY: u1 = 0,
        /// unused [2:23]
        _unused2: u6 = 0,
        _unused8: u8 = 0,
        _unused16: u8 = 0,
        /// RMVF [24:24]
        /// Remove reset flag
        RMVF: u1 = 0,
        /// unused [25:25]
        _unused25: u1 = 0,
        /// PINRSTF [26:26]
        /// PIN reset flag
        PINRSTF: u1 = 1,
        /// PORRSTF [27:27]
        /// POR/PDR reset flag
        PORRSTF: u1 = 1,
        /// SFTRSTF [28:28]
        /// Software reset flag
        SFTRSTF: u1 = 0,
        /// IWDGRSTF [29:29]
        /// Independent watchdog reset
        IWDGRSTF: u1 = 0,
        /// WWDGRSTF [30:30]
        /// Window watchdog reset flag
        WWDGRSTF: u1 = 0,
        /// LPWRRSTF [31:31]
        /// Low-power reset flag
        LPWRRSTF: u1 = 0,
    };
    /// Control/status register
    pub const CSR = Register(CSR_val).init(base_address + 0x24);
};

/// General purpose I/O
pub const GPIOA = struct {
    const base_address = 0x40010800;
    /// CRL
    const CRL_val = packed struct {
        /// MODE0 [0:1]
        /// Port n.0 mode bits
        MODE0: u2 = 0,
        /// CNF0 [2:3]
        /// Port n.0 configuration
        CNF0: u2 = 1,
        /// MODE1 [4:5]
        /// Port n.1 mode bits
        MODE1: u2 = 0,
        /// CNF1 [6:7]
        /// Port n.1 configuration
        CNF1: u2 = 1,
        /// MODE2 [8:9]
        /// Port n.2 mode bits
        MODE2: u2 = 0,
        /// CNF2 [10:11]
        /// Port n.2 configuration
        CNF2: u2 = 1,
        /// MODE3 [12:13]
        /// Port n.3 mode bits
        MODE3: u2 = 0,
        /// CNF3 [14:15]
        /// Port n.3 configuration
        CNF3: u2 = 1,
        /// MODE4 [16:17]
        /// Port n.4 mode bits
        MODE4: u2 = 0,
        /// CNF4 [18:19]
        /// Port n.4 configuration
        CNF4: u2 = 1,
        /// MODE5 [20:21]
        /// Port n.5 mode bits
        MODE5: u2 = 0,
        /// CNF5 [22:23]
        /// Port n.5 configuration
        CNF5: u2 = 1,
        /// MODE6 [24:25]
        /// Port n.6 mode bits
        MODE6: u2 = 0,
        /// CNF6 [26:27]
        /// Port n.6 configuration
        CNF6: u2 = 1,
        /// MODE7 [28:29]
        /// Port n.7 mode bits
        MODE7: u2 = 0,
        /// CNF7 [30:31]
        /// Port n.7 configuration
        CNF7: u2 = 1,
    };
    /// Port configuration register low
    pub const CRL = Register(CRL_val).init(base_address + 0x0);

    /// CRH
    const CRH_val = packed struct {
        /// MODE8 [0:1]
        /// Port n.8 mode bits
        MODE8: u2 = 0,
        /// CNF8 [2:3]
        /// Port n.8 configuration
        CNF8: u2 = 1,
        /// MODE9 [4:5]
        /// Port n.9 mode bits
        MODE9: u2 = 0,
        /// CNF9 [6:7]
        /// Port n.9 configuration
        CNF9: u2 = 1,
        /// MODE10 [8:9]
        /// Port n.10 mode bits
        MODE10: u2 = 0,
        /// CNF10 [10:11]
        /// Port n.10 configuration
        CNF10: u2 = 1,
        /// MODE11 [12:13]
        /// Port n.11 mode bits
        MODE11: u2 = 0,
        /// CNF11 [14:15]
        /// Port n.11 configuration
        CNF11: u2 = 1,
        /// MODE12 [16:17]
        /// Port n.12 mode bits
        MODE12: u2 = 0,
        /// CNF12 [18:19]
        /// Port n.12 configuration
        CNF12: u2 = 1,
        /// MODE13 [20:21]
        /// Port n.13 mode bits
        MODE13: u2 = 0,
        /// CNF13 [22:23]
        /// Port n.13 configuration
        CNF13: u2 = 1,
        /// MODE14 [24:25]
        /// Port n.14 mode bits
        MODE14: u2 = 0,
        /// CNF14 [26:27]
        /// Port n.14 configuration
        CNF14: u2 = 1,
        /// MODE15 [28:29]
        /// Port n.15 mode bits
        MODE15: u2 = 0,
        /// CNF15 [30:31]
        /// Port n.15 configuration
        CNF15: u2 = 1,
    };
    /// Port configuration register high
    pub const CRH = Register(CRH_val).init(base_address + 0x4);

    /// IDR
    const IDR_val = packed struct {
        /// IDR0 [0:0]
        /// Port input data
        IDR0: u1 = 0,
        /// IDR1 [1:1]
        /// Port input data
        IDR1: u1 = 0,
        /// IDR2 [2:2]
        /// Port input data
        IDR2: u1 = 0,
        /// IDR3 [3:3]
        /// Port input data
        IDR3: u1 = 0,
        /// IDR4 [4:4]
        /// Port input data
        IDR4: u1 = 0,
        /// IDR5 [5:5]
        /// Port input data
        IDR5: u1 = 0,
        /// IDR6 [6:6]
        /// Port input data
        IDR6: u1 = 0,
        /// IDR7 [7:7]
        /// Port input data
        IDR7: u1 = 0,
        /// IDR8 [8:8]
        /// Port input data
        IDR8: u1 = 0,
        /// IDR9 [9:9]
        /// Port input data
        IDR9: u1 = 0,
        /// IDR10 [10:10]
        /// Port input data
        IDR10: u1 = 0,
        /// IDR11 [11:11]
        /// Port input data
        IDR11: u1 = 0,
        /// IDR12 [12:12]
        /// Port input data
        IDR12: u1 = 0,
        /// IDR13 [13:13]
        /// Port input data
        IDR13: u1 = 0,
        /// IDR14 [14:14]
        /// Port input data
        IDR14: u1 = 0,
        /// IDR15 [15:15]
        /// Port input data
        IDR15: u1 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Port input data register
    pub const IDR = Register(IDR_val).init(base_address + 0x8);

    /// ODR
    const ODR_val = packed struct {
        /// ODR0 [0:0]
        /// Port output data
        ODR0: u1 = 0,
        /// ODR1 [1:1]
        /// Port output data
        ODR1: u1 = 0,
        /// ODR2 [2:2]
        /// Port output data
        ODR2: u1 = 0,
        /// ODR3 [3:3]
        /// Port output data
        ODR3: u1 = 0,
        /// ODR4 [4:4]
        /// Port output data
        ODR4: u1 = 0,
        /// ODR5 [5:5]
        /// Port output data
        ODR5: u1 = 0,
        /// ODR6 [6:6]
        /// Port output data
        ODR6: u1 = 0,
        /// ODR7 [7:7]
        /// Port output data
        ODR7: u1 = 0,
        /// ODR8 [8:8]
        /// Port output data
        ODR8: u1 = 0,
        /// ODR9 [9:9]
        /// Port output data
        ODR9: u1 = 0,
        /// ODR10 [10:10]
        /// Port output data
        ODR10: u1 = 0,
        /// ODR11 [11:11]
        /// Port output data
        ODR11: u1 = 0,
        /// ODR12 [12:12]
        /// Port output data
        ODR12: u1 = 0,
        /// ODR13 [13:13]
        /// Port output data
        ODR13: u1 = 0,
        /// ODR14 [14:14]
        /// Port output data
        ODR14: u1 = 0,
        /// ODR15 [15:15]
        /// Port output data
        ODR15: u1 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Port output data register
    pub const ODR = Register(ODR_val).init(base_address + 0xc);

    /// BSRR
    const BSRR_val = packed struct {
        /// BS0 [0:0]
        /// Set bit 0
        BS0: u1 = 0,
        /// BS1 [1:1]
        /// Set bit 1
        BS1: u1 = 0,
        /// BS2 [2:2]
        /// Set bit 1
        BS2: u1 = 0,
        /// BS3 [3:3]
        /// Set bit 3
        BS3: u1 = 0,
        /// BS4 [4:4]
        /// Set bit 4
        BS4: u1 = 0,
        /// BS5 [5:5]
        /// Set bit 5
        BS5: u1 = 0,
        /// BS6 [6:6]
        /// Set bit 6
        BS6: u1 = 0,
        /// BS7 [7:7]
        /// Set bit 7
        BS7: u1 = 0,
        /// BS8 [8:8]
        /// Set bit 8
        BS8: u1 = 0,
        /// BS9 [9:9]
        /// Set bit 9
        BS9: u1 = 0,
        /// BS10 [10:10]
        /// Set bit 10
        BS10: u1 = 0,
        /// BS11 [11:11]
        /// Set bit 11
        BS11: u1 = 0,
        /// BS12 [12:12]
        /// Set bit 12
        BS12: u1 = 0,
        /// BS13 [13:13]
        /// Set bit 13
        BS13: u1 = 0,
        /// BS14 [14:14]
        /// Set bit 14
        BS14: u1 = 0,
        /// BS15 [15:15]
        /// Set bit 15
        BS15: u1 = 0,
        /// BR0 [16:16]
        /// Reset bit 0
        BR0: u1 = 0,
        /// BR1 [17:17]
        /// Reset bit 1
        BR1: u1 = 0,
        /// BR2 [18:18]
        /// Reset bit 2
        BR2: u1 = 0,
        /// BR3 [19:19]
        /// Reset bit 3
        BR3: u1 = 0,
        /// BR4 [20:20]
        /// Reset bit 4
        BR4: u1 = 0,
        /// BR5 [21:21]
        /// Reset bit 5
        BR5: u1 = 0,
        /// BR6 [22:22]
        /// Reset bit 6
        BR6: u1 = 0,
        /// BR7 [23:23]
        /// Reset bit 7
        BR7: u1 = 0,
        /// BR8 [24:24]
        /// Reset bit 8
        BR8: u1 = 0,
        /// BR9 [25:25]
        /// Reset bit 9
        BR9: u1 = 0,
        /// BR10 [26:26]
        /// Reset bit 10
        BR10: u1 = 0,
        /// BR11 [27:27]
        /// Reset bit 11
        BR11: u1 = 0,
        /// BR12 [28:28]
        /// Reset bit 12
        BR12: u1 = 0,
        /// BR13 [29:29]
        /// Reset bit 13
        BR13: u1 = 0,
        /// BR14 [30:30]
        /// Reset bit 14
        BR14: u1 = 0,
        /// BR15 [31:31]
        /// Reset bit 15
        BR15: u1 = 0,
    };
    /// Port bit set/reset register
    pub const BSRR = Register(BSRR_val).init(base_address + 0x10);

    /// BRR
    const BRR_val = packed struct {
        /// BR0 [0:0]
        /// Reset bit 0
        BR0: u1 = 0,
        /// BR1 [1:1]
        /// Reset bit 1
        BR1: u1 = 0,
        /// BR2 [2:2]
        /// Reset bit 1
        BR2: u1 = 0,
        /// BR3 [3:3]
        /// Reset bit 3
        BR3: u1 = 0,
        /// BR4 [4:4]
        /// Reset bit 4
        BR4: u1 = 0,
        /// BR5 [5:5]
        /// Reset bit 5
        BR5: u1 = 0,
        /// BR6 [6:6]
        /// Reset bit 6
        BR6: u1 = 0,
        /// BR7 [7:7]
        /// Reset bit 7
        BR7: u1 = 0,
        /// BR8 [8:8]
        /// Reset bit 8
        BR8: u1 = 0,
        /// BR9 [9:9]
        /// Reset bit 9
        BR9: u1 = 0,
        /// BR10 [10:10]
        /// Reset bit 10
        BR10: u1 = 0,
        /// BR11 [11:11]
        /// Reset bit 11
        BR11: u1 = 0,
        /// BR12 [12:12]
        /// Reset bit 12
        BR12: u1 = 0,
        /// BR13 [13:13]
        /// Reset bit 13
        BR13: u1 = 0,
        /// BR14 [14:14]
        /// Reset bit 14
        BR14: u1 = 0,
        /// BR15 [15:15]
        /// Reset bit 15
        BR15: u1 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Port bit reset register
    pub const BRR = Register(BRR_val).init(base_address + 0x14);

    /// LCKR
    const LCKR_val = packed struct {
        /// LCK0 [0:0]
        /// Port A Lock bit 0
        LCK0: u1 = 0,
        /// LCK1 [1:1]
        /// Port A Lock bit 1
        LCK1: u1 = 0,
        /// LCK2 [2:2]
        /// Port A Lock bit 2
        LCK2: u1 = 0,
        /// LCK3 [3:3]
        /// Port A Lock bit 3
        LCK3: u1 = 0,
        /// LCK4 [4:4]
        /// Port A Lock bit 4
        LCK4: u1 = 0,
        /// LCK5 [5:5]
        /// Port A Lock bit 5
        LCK5: u1 = 0,
        /// LCK6 [6:6]
        /// Port A Lock bit 6
        LCK6: u1 = 0,
        /// LCK7 [7:7]
        /// Port A Lock bit 7
        LCK7: u1 = 0,
        /// LCK8 [8:8]
        /// Port A Lock bit 8
        LCK8: u1 = 0,
        /// LCK9 [9:9]
        /// Port A Lock bit 9
        LCK9: u1 = 0,
        /// LCK10 [10:10]
        /// Port A Lock bit 10
        LCK10: u1 = 0,
        /// LCK11 [11:11]
        /// Port A Lock bit 11
        LCK11: u1 = 0,
        /// LCK12 [12:12]
        /// Port A Lock bit 12
        LCK12: u1 = 0,
        /// LCK13 [13:13]
        /// Port A Lock bit 13
        LCK13: u1 = 0,
        /// LCK14 [14:14]
        /// Port A Lock bit 14
        LCK14: u1 = 0,
        /// LCK15 [15:15]
        /// Port A Lock bit 15
        LCK15: u1 = 0,
        /// LCKK [16:16]
        /// Lock key
        LCKK: u1 = 0,
        /// unused [17:31]
        _unused17: u7 = 0,
        _unused24: u8 = 0,
    };
    /// Port configuration lock
    pub const LCKR = Register(LCKR_val).init(base_address + 0x18);
};

/// General purpose I/O
pub const GPIOB = struct {
    const base_address = 0x40010c00;
    /// CRL
    const CRL_val = packed struct {
        /// MODE0 [0:1]
        /// Port n.0 mode bits
        MODE0: u2 = 0,
        /// CNF0 [2:3]
        /// Port n.0 configuration
        CNF0: u2 = 1,
        /// MODE1 [4:5]
        /// Port n.1 mode bits
        MODE1: u2 = 0,
        /// CNF1 [6:7]
        /// Port n.1 configuration
        CNF1: u2 = 1,
        /// MODE2 [8:9]
        /// Port n.2 mode bits
        MODE2: u2 = 0,
        /// CNF2 [10:11]
        /// Port n.2 configuration
        CNF2: u2 = 1,
        /// MODE3 [12:13]
        /// Port n.3 mode bits
        MODE3: u2 = 0,
        /// CNF3 [14:15]
        /// Port n.3 configuration
        CNF3: u2 = 1,
        /// MODE4 [16:17]
        /// Port n.4 mode bits
        MODE4: u2 = 0,
        /// CNF4 [18:19]
        /// Port n.4 configuration
        CNF4: u2 = 1,
        /// MODE5 [20:21]
        /// Port n.5 mode bits
        MODE5: u2 = 0,
        /// CNF5 [22:23]
        /// Port n.5 configuration
        CNF5: u2 = 1,
        /// MODE6 [24:25]
        /// Port n.6 mode bits
        MODE6: u2 = 0,
        /// CNF6 [26:27]
        /// Port n.6 configuration
        CNF6: u2 = 1,
        /// MODE7 [28:29]
        /// Port n.7 mode bits
        MODE7: u2 = 0,
        /// CNF7 [30:31]
        /// Port n.7 configuration
        CNF7: u2 = 1,
    };
    /// Port configuration register low
    pub const CRL = Register(CRL_val).init(base_address + 0x0);

    /// CRH
    const CRH_val = packed struct {
        /// MODE8 [0:1]
        /// Port n.8 mode bits
        MODE8: u2 = 0,
        /// CNF8 [2:3]
        /// Port n.8 configuration
        CNF8: u2 = 1,
        /// MODE9 [4:5]
        /// Port n.9 mode bits
        MODE9: u2 = 0,
        /// CNF9 [6:7]
        /// Port n.9 configuration
        CNF9: u2 = 1,
        /// MODE10 [8:9]
        /// Port n.10 mode bits
        MODE10: u2 = 0,
        /// CNF10 [10:11]
        /// Port n.10 configuration
        CNF10: u2 = 1,
        /// MODE11 [12:13]
        /// Port n.11 mode bits
        MODE11: u2 = 0,
        /// CNF11 [14:15]
        /// Port n.11 configuration
        CNF11: u2 = 1,
        /// MODE12 [16:17]
        /// Port n.12 mode bits
        MODE12: u2 = 0,
        /// CNF12 [18:19]
        /// Port n.12 configuration
        CNF12: u2 = 1,
        /// MODE13 [20:21]
        /// Port n.13 mode bits
        MODE13: u2 = 0,
        /// CNF13 [22:23]
        /// Port n.13 configuration
        CNF13: u2 = 1,
        /// MODE14 [24:25]
        /// Port n.14 mode bits
        MODE14: u2 = 0,
        /// CNF14 [26:27]
        /// Port n.14 configuration
        CNF14: u2 = 1,
        /// MODE15 [28:29]
        /// Port n.15 mode bits
        MODE15: u2 = 0,
        /// CNF15 [30:31]
        /// Port n.15 configuration
        CNF15: u2 = 1,
    };
    /// Port configuration register high
    pub const CRH = Register(CRH_val).init(base_address + 0x4);

    /// IDR
    const IDR_val = packed struct {
        /// IDR0 [0:0]
        /// Port input data
        IDR0: u1 = 0,
        /// IDR1 [1:1]
        /// Port input data
        IDR1: u1 = 0,
        /// IDR2 [2:2]
        /// Port input data
        IDR2: u1 = 0,
        /// IDR3 [3:3]
        /// Port input data
        IDR3: u1 = 0,
        /// IDR4 [4:4]
        /// Port input data
        IDR4: u1 = 0,
        /// IDR5 [5:5]
        /// Port input data
        IDR5: u1 = 0,
        /// IDR6 [6:6]
        /// Port input data
        IDR6: u1 = 0,
        /// IDR7 [7:7]
        /// Port input data
        IDR7: u1 = 0,
        /// IDR8 [8:8]
        /// Port input data
        IDR8: u1 = 0,
        /// IDR9 [9:9]
        /// Port input data
        IDR9: u1 = 0,
        /// IDR10 [10:10]
        /// Port input data
        IDR10: u1 = 0,
        /// IDR11 [11:11]
        /// Port input data
        IDR11: u1 = 0,
        /// IDR12 [12:12]
        /// Port input data
        IDR12: u1 = 0,
        /// IDR13 [13:13]
        /// Port input data
        IDR13: u1 = 0,
        /// IDR14 [14:14]
        /// Port input data
        IDR14: u1 = 0,
        /// IDR15 [15:15]
        /// Port input data
        IDR15: u1 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Port input data register
    pub const IDR = Register(IDR_val).init(base_address + 0x8);

    /// ODR
    const ODR_val = packed struct {
        /// ODR0 [0:0]
        /// Port output data
        ODR0: u1 = 0,
        /// ODR1 [1:1]
        /// Port output data
        ODR1: u1 = 0,
        /// ODR2 [2:2]
        /// Port output data
        ODR2: u1 = 0,
        /// ODR3 [3:3]
        /// Port output data
        ODR3: u1 = 0,
        /// ODR4 [4:4]
        /// Port output data
        ODR4: u1 = 0,
        /// ODR5 [5:5]
        /// Port output data
        ODR5: u1 = 0,
        /// ODR6 [6:6]
        /// Port output data
        ODR6: u1 = 0,
        /// ODR7 [7:7]
        /// Port output data
        ODR7: u1 = 0,
        /// ODR8 [8:8]
        /// Port output data
        ODR8: u1 = 0,
        /// ODR9 [9:9]
        /// Port output data
        ODR9: u1 = 0,
        /// ODR10 [10:10]
        /// Port output data
        ODR10: u1 = 0,
        /// ODR11 [11:11]
        /// Port output data
        ODR11: u1 = 0,
        /// ODR12 [12:12]
        /// Port output data
        ODR12: u1 = 0,
        /// ODR13 [13:13]
        /// Port output data
        ODR13: u1 = 0,
        /// ODR14 [14:14]
        /// Port output data
        ODR14: u1 = 0,
        /// ODR15 [15:15]
        /// Port output data
        ODR15: u1 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Port output data register
    pub const ODR = Register(ODR_val).init(base_address + 0xc);

    /// BSRR
    const BSRR_val = packed struct {
        /// BS0 [0:0]
        /// Set bit 0
        BS0: u1 = 0,
        /// BS1 [1:1]
        /// Set bit 1
        BS1: u1 = 0,
        /// BS2 [2:2]
        /// Set bit 1
        BS2: u1 = 0,
        /// BS3 [3:3]
        /// Set bit 3
        BS3: u1 = 0,
        /// BS4 [4:4]
        /// Set bit 4
        BS4: u1 = 0,
        /// BS5 [5:5]
        /// Set bit 5
        BS5: u1 = 0,
        /// BS6 [6:6]
        /// Set bit 6
        BS6: u1 = 0,
        /// BS7 [7:7]
        /// Set bit 7
        BS7: u1 = 0,
        /// BS8 [8:8]
        /// Set bit 8
        BS8: u1 = 0,
        /// BS9 [9:9]
        /// Set bit 9
        BS9: u1 = 0,
        /// BS10 [10:10]
        /// Set bit 10
        BS10: u1 = 0,
        /// BS11 [11:11]
        /// Set bit 11
        BS11: u1 = 0,
        /// BS12 [12:12]
        /// Set bit 12
        BS12: u1 = 0,
        /// BS13 [13:13]
        /// Set bit 13
        BS13: u1 = 0,
        /// BS14 [14:14]
        /// Set bit 14
        BS14: u1 = 0,
        /// BS15 [15:15]
        /// Set bit 15
        BS15: u1 = 0,
        /// BR0 [16:16]
        /// Reset bit 0
        BR0: u1 = 0,
        /// BR1 [17:17]
        /// Reset bit 1
        BR1: u1 = 0,
        /// BR2 [18:18]
        /// Reset bit 2
        BR2: u1 = 0,
        /// BR3 [19:19]
        /// Reset bit 3
        BR3: u1 = 0,
        /// BR4 [20:20]
        /// Reset bit 4
        BR4: u1 = 0,
        /// BR5 [21:21]
        /// Reset bit 5
        BR5: u1 = 0,
        /// BR6 [22:22]
        /// Reset bit 6
        BR6: u1 = 0,
        /// BR7 [23:23]
        /// Reset bit 7
        BR7: u1 = 0,
        /// BR8 [24:24]
        /// Reset bit 8
        BR8: u1 = 0,
        /// BR9 [25:25]
        /// Reset bit 9
        BR9: u1 = 0,
        /// BR10 [26:26]
        /// Reset bit 10
        BR10: u1 = 0,
        /// BR11 [27:27]
        /// Reset bit 11
        BR11: u1 = 0,
        /// BR12 [28:28]
        /// Reset bit 12
        BR12: u1 = 0,
        /// BR13 [29:29]
        /// Reset bit 13
        BR13: u1 = 0,
        /// BR14 [30:30]
        /// Reset bit 14
        BR14: u1 = 0,
        /// BR15 [31:31]
        /// Reset bit 15
        BR15: u1 = 0,
    };
    /// Port bit set/reset register
    pub const BSRR = Register(BSRR_val).init(base_address + 0x10);

    /// BRR
    const BRR_val = packed struct {
        /// BR0 [0:0]
        /// Reset bit 0
        BR0: u1 = 0,
        /// BR1 [1:1]
        /// Reset bit 1
        BR1: u1 = 0,
        /// BR2 [2:2]
        /// Reset bit 1
        BR2: u1 = 0,
        /// BR3 [3:3]
        /// Reset bit 3
        BR3: u1 = 0,
        /// BR4 [4:4]
        /// Reset bit 4
        BR4: u1 = 0,
        /// BR5 [5:5]
        /// Reset bit 5
        BR5: u1 = 0,
        /// BR6 [6:6]
        /// Reset bit 6
        BR6: u1 = 0,
        /// BR7 [7:7]
        /// Reset bit 7
        BR7: u1 = 0,
        /// BR8 [8:8]
        /// Reset bit 8
        BR8: u1 = 0,
        /// BR9 [9:9]
        /// Reset bit 9
        BR9: u1 = 0,
        /// BR10 [10:10]
        /// Reset bit 10
        BR10: u1 = 0,
        /// BR11 [11:11]
        /// Reset bit 11
        BR11: u1 = 0,
        /// BR12 [12:12]
        /// Reset bit 12
        BR12: u1 = 0,
        /// BR13 [13:13]
        /// Reset bit 13
        BR13: u1 = 0,
        /// BR14 [14:14]
        /// Reset bit 14
        BR14: u1 = 0,
        /// BR15 [15:15]
        /// Reset bit 15
        BR15: u1 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Port bit reset register
    pub const BRR = Register(BRR_val).init(base_address + 0x14);

    /// LCKR
    const LCKR_val = packed struct {
        /// LCK0 [0:0]
        /// Port A Lock bit 0
        LCK0: u1 = 0,
        /// LCK1 [1:1]
        /// Port A Lock bit 1
        LCK1: u1 = 0,
        /// LCK2 [2:2]
        /// Port A Lock bit 2
        LCK2: u1 = 0,
        /// LCK3 [3:3]
        /// Port A Lock bit 3
        LCK3: u1 = 0,
        /// LCK4 [4:4]
        /// Port A Lock bit 4
        LCK4: u1 = 0,
        /// LCK5 [5:5]
        /// Port A Lock bit 5
        LCK5: u1 = 0,
        /// LCK6 [6:6]
        /// Port A Lock bit 6
        LCK6: u1 = 0,
        /// LCK7 [7:7]
        /// Port A Lock bit 7
        LCK7: u1 = 0,
        /// LCK8 [8:8]
        /// Port A Lock bit 8
        LCK8: u1 = 0,
        /// LCK9 [9:9]
        /// Port A Lock bit 9
        LCK9: u1 = 0,
        /// LCK10 [10:10]
        /// Port A Lock bit 10
        LCK10: u1 = 0,
        /// LCK11 [11:11]
        /// Port A Lock bit 11
        LCK11: u1 = 0,
        /// LCK12 [12:12]
        /// Port A Lock bit 12
        LCK12: u1 = 0,
        /// LCK13 [13:13]
        /// Port A Lock bit 13
        LCK13: u1 = 0,
        /// LCK14 [14:14]
        /// Port A Lock bit 14
        LCK14: u1 = 0,
        /// LCK15 [15:15]
        /// Port A Lock bit 15
        LCK15: u1 = 0,
        /// LCKK [16:16]
        /// Lock key
        LCKK: u1 = 0,
        /// unused [17:31]
        _unused17: u7 = 0,
        _unused24: u8 = 0,
    };
    /// Port configuration lock
    pub const LCKR = Register(LCKR_val).init(base_address + 0x18);
};

/// General purpose I/O
pub const GPIOC = struct {
    const base_address = 0x40011000;
    /// CRL
    const CRL_val = packed struct {
        /// MODE0 [0:1]
        /// Port n.0 mode bits
        MODE0: u2 = 0,
        /// CNF0 [2:3]
        /// Port n.0 configuration
        CNF0: u2 = 1,
        /// MODE1 [4:5]
        /// Port n.1 mode bits
        MODE1: u2 = 0,
        /// CNF1 [6:7]
        /// Port n.1 configuration
        CNF1: u2 = 1,
        /// MODE2 [8:9]
        /// Port n.2 mode bits
        MODE2: u2 = 0,
        /// CNF2 [10:11]
        /// Port n.2 configuration
        CNF2: u2 = 1,
        /// MODE3 [12:13]
        /// Port n.3 mode bits
        MODE3: u2 = 0,
        /// CNF3 [14:15]
        /// Port n.3 configuration
        CNF3: u2 = 1,
        /// MODE4 [16:17]
        /// Port n.4 mode bits
        MODE4: u2 = 0,
        /// CNF4 [18:19]
        /// Port n.4 configuration
        CNF4: u2 = 1,
        /// MODE5 [20:21]
        /// Port n.5 mode bits
        MODE5: u2 = 0,
        /// CNF5 [22:23]
        /// Port n.5 configuration
        CNF5: u2 = 1,
        /// MODE6 [24:25]
        /// Port n.6 mode bits
        MODE6: u2 = 0,
        /// CNF6 [26:27]
        /// Port n.6 configuration
        CNF6: u2 = 1,
        /// MODE7 [28:29]
        /// Port n.7 mode bits
        MODE7: u2 = 0,
        /// CNF7 [30:31]
        /// Port n.7 configuration
        CNF7: u2 = 1,
    };
    /// Port configuration register low
    pub const CRL = Register(CRL_val).init(base_address + 0x0);

    /// CRH
    const CRH_val = packed struct {
        /// MODE8 [0:1]
        /// Port n.8 mode bits
        MODE8: u2 = 0,
        /// CNF8 [2:3]
        /// Port n.8 configuration
        CNF8: u2 = 1,
        /// MODE9 [4:5]
        /// Port n.9 mode bits
        MODE9: u2 = 0,
        /// CNF9 [6:7]
        /// Port n.9 configuration
        CNF9: u2 = 1,
        /// MODE10 [8:9]
        /// Port n.10 mode bits
        MODE10: u2 = 0,
        /// CNF10 [10:11]
        /// Port n.10 configuration
        CNF10: u2 = 1,
        /// MODE11 [12:13]
        /// Port n.11 mode bits
        MODE11: u2 = 0,
        /// CNF11 [14:15]
        /// Port n.11 configuration
        CNF11: u2 = 1,
        /// MODE12 [16:17]
        /// Port n.12 mode bits
        MODE12: u2 = 0,
        /// CNF12 [18:19]
        /// Port n.12 configuration
        CNF12: u2 = 1,
        /// MODE13 [20:21]
        /// Port n.13 mode bits
        MODE13: u2 = 0,
        /// CNF13 [22:23]
        /// Port n.13 configuration
        CNF13: u2 = 1,
        /// MODE14 [24:25]
        /// Port n.14 mode bits
        MODE14: u2 = 0,
        /// CNF14 [26:27]
        /// Port n.14 configuration
        CNF14: u2 = 1,
        /// MODE15 [28:29]
        /// Port n.15 mode bits
        MODE15: u2 = 0,
        /// CNF15 [30:31]
        /// Port n.15 configuration
        CNF15: u2 = 1,
    };
    /// Port configuration register high
    pub const CRH = Register(CRH_val).init(base_address + 0x4);

    /// IDR
    const IDR_val = packed struct {
        /// IDR0 [0:0]
        /// Port input data
        IDR0: u1 = 0,
        /// IDR1 [1:1]
        /// Port input data
        IDR1: u1 = 0,
        /// IDR2 [2:2]
        /// Port input data
        IDR2: u1 = 0,
        /// IDR3 [3:3]
        /// Port input data
        IDR3: u1 = 0,
        /// IDR4 [4:4]
        /// Port input data
        IDR4: u1 = 0,
        /// IDR5 [5:5]
        /// Port input data
        IDR5: u1 = 0,
        /// IDR6 [6:6]
        /// Port input data
        IDR6: u1 = 0,
        /// IDR7 [7:7]
        /// Port input data
        IDR7: u1 = 0,
        /// IDR8 [8:8]
        /// Port input data
        IDR8: u1 = 0,
        /// IDR9 [9:9]
        /// Port input data
        IDR9: u1 = 0,
        /// IDR10 [10:10]
        /// Port input data
        IDR10: u1 = 0,
        /// IDR11 [11:11]
        /// Port input data
        IDR11: u1 = 0,
        /// IDR12 [12:12]
        /// Port input data
        IDR12: u1 = 0,
        /// IDR13 [13:13]
        /// Port input data
        IDR13: u1 = 0,
        /// IDR14 [14:14]
        /// Port input data
        IDR14: u1 = 0,
        /// IDR15 [15:15]
        /// Port input data
        IDR15: u1 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Port input data register
    pub const IDR = Register(IDR_val).init(base_address + 0x8);

    /// ODR
    const ODR_val = packed struct {
        /// ODR0 [0:0]
        /// Port output data
        ODR0: u1 = 0,
        /// ODR1 [1:1]
        /// Port output data
        ODR1: u1 = 0,
        /// ODR2 [2:2]
        /// Port output data
        ODR2: u1 = 0,
        /// ODR3 [3:3]
        /// Port output data
        ODR3: u1 = 0,
        /// ODR4 [4:4]
        /// Port output data
        ODR4: u1 = 0,
        /// ODR5 [5:5]
        /// Port output data
        ODR5: u1 = 0,
        /// ODR6 [6:6]
        /// Port output data
        ODR6: u1 = 0,
        /// ODR7 [7:7]
        /// Port output data
        ODR7: u1 = 0,
        /// ODR8 [8:8]
        /// Port output data
        ODR8: u1 = 0,
        /// ODR9 [9:9]
        /// Port output data
        ODR9: u1 = 0,
        /// ODR10 [10:10]
        /// Port output data
        ODR10: u1 = 0,
        /// ODR11 [11:11]
        /// Port output data
        ODR11: u1 = 0,
        /// ODR12 [12:12]
        /// Port output data
        ODR12: u1 = 0,
        /// ODR13 [13:13]
        /// Port output data
        ODR13: u1 = 0,
        /// ODR14 [14:14]
        /// Port output data
        ODR14: u1 = 0,
        /// ODR15 [15:15]
        /// Port output data
        ODR15: u1 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Port output data register
    pub const ODR = Register(ODR_val).init(base_address + 0xc);

    /// BSRR
    const BSRR_val = packed struct {
        /// BS0 [0:0]
        /// Set bit 0
        BS0: u1 = 0,
        /// BS1 [1:1]
        /// Set bit 1
        BS1: u1 = 0,
        /// BS2 [2:2]
        /// Set bit 1
        BS2: u1 = 0,
        /// BS3 [3:3]
        /// Set bit 3
        BS3: u1 = 0,
        /// BS4 [4:4]
        /// Set bit 4
        BS4: u1 = 0,
        /// BS5 [5:5]
        /// Set bit 5
        BS5: u1 = 0,
        /// BS6 [6:6]
        /// Set bit 6
        BS6: u1 = 0,
        /// BS7 [7:7]
        /// Set bit 7
        BS7: u1 = 0,
        /// BS8 [8:8]
        /// Set bit 8
        BS8: u1 = 0,
        /// BS9 [9:9]
        /// Set bit 9
        BS9: u1 = 0,
        /// BS10 [10:10]
        /// Set bit 10
        BS10: u1 = 0,
        /// BS11 [11:11]
        /// Set bit 11
        BS11: u1 = 0,
        /// BS12 [12:12]
        /// Set bit 12
        BS12: u1 = 0,
        /// BS13 [13:13]
        /// Set bit 13
        BS13: u1 = 0,
        /// BS14 [14:14]
        /// Set bit 14
        BS14: u1 = 0,
        /// BS15 [15:15]
        /// Set bit 15
        BS15: u1 = 0,
        /// BR0 [16:16]
        /// Reset bit 0
        BR0: u1 = 0,
        /// BR1 [17:17]
        /// Reset bit 1
        BR1: u1 = 0,
        /// BR2 [18:18]
        /// Reset bit 2
        BR2: u1 = 0,
        /// BR3 [19:19]
        /// Reset bit 3
        BR3: u1 = 0,
        /// BR4 [20:20]
        /// Reset bit 4
        BR4: u1 = 0,
        /// BR5 [21:21]
        /// Reset bit 5
        BR5: u1 = 0,
        /// BR6 [22:22]
        /// Reset bit 6
        BR6: u1 = 0,
        /// BR7 [23:23]
        /// Reset bit 7
        BR7: u1 = 0,
        /// BR8 [24:24]
        /// Reset bit 8
        BR8: u1 = 0,
        /// BR9 [25:25]
        /// Reset bit 9
        BR9: u1 = 0,
        /// BR10 [26:26]
        /// Reset bit 10
        BR10: u1 = 0,
        /// BR11 [27:27]
        /// Reset bit 11
        BR11: u1 = 0,
        /// BR12 [28:28]
        /// Reset bit 12
        BR12: u1 = 0,
        /// BR13 [29:29]
        /// Reset bit 13
        BR13: u1 = 0,
        /// BR14 [30:30]
        /// Reset bit 14
        BR14: u1 = 0,
        /// BR15 [31:31]
        /// Reset bit 15
        BR15: u1 = 0,
    };
    /// Port bit set/reset register
    pub const BSRR = Register(BSRR_val).init(base_address + 0x10);

    /// BRR
    const BRR_val = packed struct {
        /// BR0 [0:0]
        /// Reset bit 0
        BR0: u1 = 0,
        /// BR1 [1:1]
        /// Reset bit 1
        BR1: u1 = 0,
        /// BR2 [2:2]
        /// Reset bit 1
        BR2: u1 = 0,
        /// BR3 [3:3]
        /// Reset bit 3
        BR3: u1 = 0,
        /// BR4 [4:4]
        /// Reset bit 4
        BR4: u1 = 0,
        /// BR5 [5:5]
        /// Reset bit 5
        BR5: u1 = 0,
        /// BR6 [6:6]
        /// Reset bit 6
        BR6: u1 = 0,
        /// BR7 [7:7]
        /// Reset bit 7
        BR7: u1 = 0,
        /// BR8 [8:8]
        /// Reset bit 8
        BR8: u1 = 0,
        /// BR9 [9:9]
        /// Reset bit 9
        BR9: u1 = 0,
        /// BR10 [10:10]
        /// Reset bit 10
        BR10: u1 = 0,
        /// BR11 [11:11]
        /// Reset bit 11
        BR11: u1 = 0,
        /// BR12 [12:12]
        /// Reset bit 12
        BR12: u1 = 0,
        /// BR13 [13:13]
        /// Reset bit 13
        BR13: u1 = 0,
        /// BR14 [14:14]
        /// Reset bit 14
        BR14: u1 = 0,
        /// BR15 [15:15]
        /// Reset bit 15
        BR15: u1 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Port bit reset register
    pub const BRR = Register(BRR_val).init(base_address + 0x14);

    /// LCKR
    const LCKR_val = packed struct {
        /// LCK0 [0:0]
        /// Port A Lock bit 0
        LCK0: u1 = 0,
        /// LCK1 [1:1]
        /// Port A Lock bit 1
        LCK1: u1 = 0,
        /// LCK2 [2:2]
        /// Port A Lock bit 2
        LCK2: u1 = 0,
        /// LCK3 [3:3]
        /// Port A Lock bit 3
        LCK3: u1 = 0,
        /// LCK4 [4:4]
        /// Port A Lock bit 4
        LCK4: u1 = 0,
        /// LCK5 [5:5]
        /// Port A Lock bit 5
        LCK5: u1 = 0,
        /// LCK6 [6:6]
        /// Port A Lock bit 6
        LCK6: u1 = 0,
        /// LCK7 [7:7]
        /// Port A Lock bit 7
        LCK7: u1 = 0,
        /// LCK8 [8:8]
        /// Port A Lock bit 8
        LCK8: u1 = 0,
        /// LCK9 [9:9]
        /// Port A Lock bit 9
        LCK9: u1 = 0,
        /// LCK10 [10:10]
        /// Port A Lock bit 10
        LCK10: u1 = 0,
        /// LCK11 [11:11]
        /// Port A Lock bit 11
        LCK11: u1 = 0,
        /// LCK12 [12:12]
        /// Port A Lock bit 12
        LCK12: u1 = 0,
        /// LCK13 [13:13]
        /// Port A Lock bit 13
        LCK13: u1 = 0,
        /// LCK14 [14:14]
        /// Port A Lock bit 14
        LCK14: u1 = 0,
        /// LCK15 [15:15]
        /// Port A Lock bit 15
        LCK15: u1 = 0,
        /// LCKK [16:16]
        /// Lock key
        LCKK: u1 = 0,
        /// unused [17:31]
        _unused17: u7 = 0,
        _unused24: u8 = 0,
    };
    /// Port configuration lock
    pub const LCKR = Register(LCKR_val).init(base_address + 0x18);
};

/// General purpose I/O
pub const GPIOD = struct {
    const base_address = 0x40011400;
    /// CRL
    const CRL_val = packed struct {
        /// MODE0 [0:1]
        /// Port n.0 mode bits
        MODE0: u2 = 0,
        /// CNF0 [2:3]
        /// Port n.0 configuration
        CNF0: u2 = 1,
        /// MODE1 [4:5]
        /// Port n.1 mode bits
        MODE1: u2 = 0,
        /// CNF1 [6:7]
        /// Port n.1 configuration
        CNF1: u2 = 1,
        /// MODE2 [8:9]
        /// Port n.2 mode bits
        MODE2: u2 = 0,
        /// CNF2 [10:11]
        /// Port n.2 configuration
        CNF2: u2 = 1,
        /// MODE3 [12:13]
        /// Port n.3 mode bits
        MODE3: u2 = 0,
        /// CNF3 [14:15]
        /// Port n.3 configuration
        CNF3: u2 = 1,
        /// MODE4 [16:17]
        /// Port n.4 mode bits
        MODE4: u2 = 0,
        /// CNF4 [18:19]
        /// Port n.4 configuration
        CNF4: u2 = 1,
        /// MODE5 [20:21]
        /// Port n.5 mode bits
        MODE5: u2 = 0,
        /// CNF5 [22:23]
        /// Port n.5 configuration
        CNF5: u2 = 1,
        /// MODE6 [24:25]
        /// Port n.6 mode bits
        MODE6: u2 = 0,
        /// CNF6 [26:27]
        /// Port n.6 configuration
        CNF6: u2 = 1,
        /// MODE7 [28:29]
        /// Port n.7 mode bits
        MODE7: u2 = 0,
        /// CNF7 [30:31]
        /// Port n.7 configuration
        CNF7: u2 = 1,
    };
    /// Port configuration register low
    pub const CRL = Register(CRL_val).init(base_address + 0x0);

    /// CRH
    const CRH_val = packed struct {
        /// MODE8 [0:1]
        /// Port n.8 mode bits
        MODE8: u2 = 0,
        /// CNF8 [2:3]
        /// Port n.8 configuration
        CNF8: u2 = 1,
        /// MODE9 [4:5]
        /// Port n.9 mode bits
        MODE9: u2 = 0,
        /// CNF9 [6:7]
        /// Port n.9 configuration
        CNF9: u2 = 1,
        /// MODE10 [8:9]
        /// Port n.10 mode bits
        MODE10: u2 = 0,
        /// CNF10 [10:11]
        /// Port n.10 configuration
        CNF10: u2 = 1,
        /// MODE11 [12:13]
        /// Port n.11 mode bits
        MODE11: u2 = 0,
        /// CNF11 [14:15]
        /// Port n.11 configuration
        CNF11: u2 = 1,
        /// MODE12 [16:17]
        /// Port n.12 mode bits
        MODE12: u2 = 0,
        /// CNF12 [18:19]
        /// Port n.12 configuration
        CNF12: u2 = 1,
        /// MODE13 [20:21]
        /// Port n.13 mode bits
        MODE13: u2 = 0,
        /// CNF13 [22:23]
        /// Port n.13 configuration
        CNF13: u2 = 1,
        /// MODE14 [24:25]
        /// Port n.14 mode bits
        MODE14: u2 = 0,
        /// CNF14 [26:27]
        /// Port n.14 configuration
        CNF14: u2 = 1,
        /// MODE15 [28:29]
        /// Port n.15 mode bits
        MODE15: u2 = 0,
        /// CNF15 [30:31]
        /// Port n.15 configuration
        CNF15: u2 = 1,
    };
    /// Port configuration register high
    pub const CRH = Register(CRH_val).init(base_address + 0x4);

    /// IDR
    const IDR_val = packed struct {
        /// IDR0 [0:0]
        /// Port input data
        IDR0: u1 = 0,
        /// IDR1 [1:1]
        /// Port input data
        IDR1: u1 = 0,
        /// IDR2 [2:2]
        /// Port input data
        IDR2: u1 = 0,
        /// IDR3 [3:3]
        /// Port input data
        IDR3: u1 = 0,
        /// IDR4 [4:4]
        /// Port input data
        IDR4: u1 = 0,
        /// IDR5 [5:5]
        /// Port input data
        IDR5: u1 = 0,
        /// IDR6 [6:6]
        /// Port input data
        IDR6: u1 = 0,
        /// IDR7 [7:7]
        /// Port input data
        IDR7: u1 = 0,
        /// IDR8 [8:8]
        /// Port input data
        IDR8: u1 = 0,
        /// IDR9 [9:9]
        /// Port input data
        IDR9: u1 = 0,
        /// IDR10 [10:10]
        /// Port input data
        IDR10: u1 = 0,
        /// IDR11 [11:11]
        /// Port input data
        IDR11: u1 = 0,
        /// IDR12 [12:12]
        /// Port input data
        IDR12: u1 = 0,
        /// IDR13 [13:13]
        /// Port input data
        IDR13: u1 = 0,
        /// IDR14 [14:14]
        /// Port input data
        IDR14: u1 = 0,
        /// IDR15 [15:15]
        /// Port input data
        IDR15: u1 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Port input data register
    pub const IDR = Register(IDR_val).init(base_address + 0x8);

    /// ODR
    const ODR_val = packed struct {
        /// ODR0 [0:0]
        /// Port output data
        ODR0: u1 = 0,
        /// ODR1 [1:1]
        /// Port output data
        ODR1: u1 = 0,
        /// ODR2 [2:2]
        /// Port output data
        ODR2: u1 = 0,
        /// ODR3 [3:3]
        /// Port output data
        ODR3: u1 = 0,
        /// ODR4 [4:4]
        /// Port output data
        ODR4: u1 = 0,
        /// ODR5 [5:5]
        /// Port output data
        ODR5: u1 = 0,
        /// ODR6 [6:6]
        /// Port output data
        ODR6: u1 = 0,
        /// ODR7 [7:7]
        /// Port output data
        ODR7: u1 = 0,
        /// ODR8 [8:8]
        /// Port output data
        ODR8: u1 = 0,
        /// ODR9 [9:9]
        /// Port output data
        ODR9: u1 = 0,
        /// ODR10 [10:10]
        /// Port output data
        ODR10: u1 = 0,
        /// ODR11 [11:11]
        /// Port output data
        ODR11: u1 = 0,
        /// ODR12 [12:12]
        /// Port output data
        ODR12: u1 = 0,
        /// ODR13 [13:13]
        /// Port output data
        ODR13: u1 = 0,
        /// ODR14 [14:14]
        /// Port output data
        ODR14: u1 = 0,
        /// ODR15 [15:15]
        /// Port output data
        ODR15: u1 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Port output data register
    pub const ODR = Register(ODR_val).init(base_address + 0xc);

    /// BSRR
    const BSRR_val = packed struct {
        /// BS0 [0:0]
        /// Set bit 0
        BS0: u1 = 0,
        /// BS1 [1:1]
        /// Set bit 1
        BS1: u1 = 0,
        /// BS2 [2:2]
        /// Set bit 1
        BS2: u1 = 0,
        /// BS3 [3:3]
        /// Set bit 3
        BS3: u1 = 0,
        /// BS4 [4:4]
        /// Set bit 4
        BS4: u1 = 0,
        /// BS5 [5:5]
        /// Set bit 5
        BS5: u1 = 0,
        /// BS6 [6:6]
        /// Set bit 6
        BS6: u1 = 0,
        /// BS7 [7:7]
        /// Set bit 7
        BS7: u1 = 0,
        /// BS8 [8:8]
        /// Set bit 8
        BS8: u1 = 0,
        /// BS9 [9:9]
        /// Set bit 9
        BS9: u1 = 0,
        /// BS10 [10:10]
        /// Set bit 10
        BS10: u1 = 0,
        /// BS11 [11:11]
        /// Set bit 11
        BS11: u1 = 0,
        /// BS12 [12:12]
        /// Set bit 12
        BS12: u1 = 0,
        /// BS13 [13:13]
        /// Set bit 13
        BS13: u1 = 0,
        /// BS14 [14:14]
        /// Set bit 14
        BS14: u1 = 0,
        /// BS15 [15:15]
        /// Set bit 15
        BS15: u1 = 0,
        /// BR0 [16:16]
        /// Reset bit 0
        BR0: u1 = 0,
        /// BR1 [17:17]
        /// Reset bit 1
        BR1: u1 = 0,
        /// BR2 [18:18]
        /// Reset bit 2
        BR2: u1 = 0,
        /// BR3 [19:19]
        /// Reset bit 3
        BR3: u1 = 0,
        /// BR4 [20:20]
        /// Reset bit 4
        BR4: u1 = 0,
        /// BR5 [21:21]
        /// Reset bit 5
        BR5: u1 = 0,
        /// BR6 [22:22]
        /// Reset bit 6
        BR6: u1 = 0,
        /// BR7 [23:23]
        /// Reset bit 7
        BR7: u1 = 0,
        /// BR8 [24:24]
        /// Reset bit 8
        BR8: u1 = 0,
        /// BR9 [25:25]
        /// Reset bit 9
        BR9: u1 = 0,
        /// BR10 [26:26]
        /// Reset bit 10
        BR10: u1 = 0,
        /// BR11 [27:27]
        /// Reset bit 11
        BR11: u1 = 0,
        /// BR12 [28:28]
        /// Reset bit 12
        BR12: u1 = 0,
        /// BR13 [29:29]
        /// Reset bit 13
        BR13: u1 = 0,
        /// BR14 [30:30]
        /// Reset bit 14
        BR14: u1 = 0,
        /// BR15 [31:31]
        /// Reset bit 15
        BR15: u1 = 0,
    };
    /// Port bit set/reset register
    pub const BSRR = Register(BSRR_val).init(base_address + 0x10);

    /// BRR
    const BRR_val = packed struct {
        /// BR0 [0:0]
        /// Reset bit 0
        BR0: u1 = 0,
        /// BR1 [1:1]
        /// Reset bit 1
        BR1: u1 = 0,
        /// BR2 [2:2]
        /// Reset bit 1
        BR2: u1 = 0,
        /// BR3 [3:3]
        /// Reset bit 3
        BR3: u1 = 0,
        /// BR4 [4:4]
        /// Reset bit 4
        BR4: u1 = 0,
        /// BR5 [5:5]
        /// Reset bit 5
        BR5: u1 = 0,
        /// BR6 [6:6]
        /// Reset bit 6
        BR6: u1 = 0,
        /// BR7 [7:7]
        /// Reset bit 7
        BR7: u1 = 0,
        /// BR8 [8:8]
        /// Reset bit 8
        BR8: u1 = 0,
        /// BR9 [9:9]
        /// Reset bit 9
        BR9: u1 = 0,
        /// BR10 [10:10]
        /// Reset bit 10
        BR10: u1 = 0,
        /// BR11 [11:11]
        /// Reset bit 11
        BR11: u1 = 0,
        /// BR12 [12:12]
        /// Reset bit 12
        BR12: u1 = 0,
        /// BR13 [13:13]
        /// Reset bit 13
        BR13: u1 = 0,
        /// BR14 [14:14]
        /// Reset bit 14
        BR14: u1 = 0,
        /// BR15 [15:15]
        /// Reset bit 15
        BR15: u1 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Port bit reset register
    pub const BRR = Register(BRR_val).init(base_address + 0x14);

    /// LCKR
    const LCKR_val = packed struct {
        /// LCK0 [0:0]
        /// Port A Lock bit 0
        LCK0: u1 = 0,
        /// LCK1 [1:1]
        /// Port A Lock bit 1
        LCK1: u1 = 0,
        /// LCK2 [2:2]
        /// Port A Lock bit 2
        LCK2: u1 = 0,
        /// LCK3 [3:3]
        /// Port A Lock bit 3
        LCK3: u1 = 0,
        /// LCK4 [4:4]
        /// Port A Lock bit 4
        LCK4: u1 = 0,
        /// LCK5 [5:5]
        /// Port A Lock bit 5
        LCK5: u1 = 0,
        /// LCK6 [6:6]
        /// Port A Lock bit 6
        LCK6: u1 = 0,
        /// LCK7 [7:7]
        /// Port A Lock bit 7
        LCK7: u1 = 0,
        /// LCK8 [8:8]
        /// Port A Lock bit 8
        LCK8: u1 = 0,
        /// LCK9 [9:9]
        /// Port A Lock bit 9
        LCK9: u1 = 0,
        /// LCK10 [10:10]
        /// Port A Lock bit 10
        LCK10: u1 = 0,
        /// LCK11 [11:11]
        /// Port A Lock bit 11
        LCK11: u1 = 0,
        /// LCK12 [12:12]
        /// Port A Lock bit 12
        LCK12: u1 = 0,
        /// LCK13 [13:13]
        /// Port A Lock bit 13
        LCK13: u1 = 0,
        /// LCK14 [14:14]
        /// Port A Lock bit 14
        LCK14: u1 = 0,
        /// LCK15 [15:15]
        /// Port A Lock bit 15
        LCK15: u1 = 0,
        /// LCKK [16:16]
        /// Lock key
        LCKK: u1 = 0,
        /// unused [17:31]
        _unused17: u7 = 0,
        _unused24: u8 = 0,
    };
    /// Port configuration lock
    pub const LCKR = Register(LCKR_val).init(base_address + 0x18);
};

/// General purpose I/O
pub const GPIOE = struct {
    const base_address = 0x40011800;
    /// CRL
    const CRL_val = packed struct {
        /// MODE0 [0:1]
        /// Port n.0 mode bits
        MODE0: u2 = 0,
        /// CNF0 [2:3]
        /// Port n.0 configuration
        CNF0: u2 = 1,
        /// MODE1 [4:5]
        /// Port n.1 mode bits
        MODE1: u2 = 0,
        /// CNF1 [6:7]
        /// Port n.1 configuration
        CNF1: u2 = 1,
        /// MODE2 [8:9]
        /// Port n.2 mode bits
        MODE2: u2 = 0,
        /// CNF2 [10:11]
        /// Port n.2 configuration
        CNF2: u2 = 1,
        /// MODE3 [12:13]
        /// Port n.3 mode bits
        MODE3: u2 = 0,
        /// CNF3 [14:15]
        /// Port n.3 configuration
        CNF3: u2 = 1,
        /// MODE4 [16:17]
        /// Port n.4 mode bits
        MODE4: u2 = 0,
        /// CNF4 [18:19]
        /// Port n.4 configuration
        CNF4: u2 = 1,
        /// MODE5 [20:21]
        /// Port n.5 mode bits
        MODE5: u2 = 0,
        /// CNF5 [22:23]
        /// Port n.5 configuration
        CNF5: u2 = 1,
        /// MODE6 [24:25]
        /// Port n.6 mode bits
        MODE6: u2 = 0,
        /// CNF6 [26:27]
        /// Port n.6 configuration
        CNF6: u2 = 1,
        /// MODE7 [28:29]
        /// Port n.7 mode bits
        MODE7: u2 = 0,
        /// CNF7 [30:31]
        /// Port n.7 configuration
        CNF7: u2 = 1,
    };
    /// Port configuration register low
    pub const CRL = Register(CRL_val).init(base_address + 0x0);

    /// CRH
    const CRH_val = packed struct {
        /// MODE8 [0:1]
        /// Port n.8 mode bits
        MODE8: u2 = 0,
        /// CNF8 [2:3]
        /// Port n.8 configuration
        CNF8: u2 = 1,
        /// MODE9 [4:5]
        /// Port n.9 mode bits
        MODE9: u2 = 0,
        /// CNF9 [6:7]
        /// Port n.9 configuration
        CNF9: u2 = 1,
        /// MODE10 [8:9]
        /// Port n.10 mode bits
        MODE10: u2 = 0,
        /// CNF10 [10:11]
        /// Port n.10 configuration
        CNF10: u2 = 1,
        /// MODE11 [12:13]
        /// Port n.11 mode bits
        MODE11: u2 = 0,
        /// CNF11 [14:15]
        /// Port n.11 configuration
        CNF11: u2 = 1,
        /// MODE12 [16:17]
        /// Port n.12 mode bits
        MODE12: u2 = 0,
        /// CNF12 [18:19]
        /// Port n.12 configuration
        CNF12: u2 = 1,
        /// MODE13 [20:21]
        /// Port n.13 mode bits
        MODE13: u2 = 0,
        /// CNF13 [22:23]
        /// Port n.13 configuration
        CNF13: u2 = 1,
        /// MODE14 [24:25]
        /// Port n.14 mode bits
        MODE14: u2 = 0,
        /// CNF14 [26:27]
        /// Port n.14 configuration
        CNF14: u2 = 1,
        /// MODE15 [28:29]
        /// Port n.15 mode bits
        MODE15: u2 = 0,
        /// CNF15 [30:31]
        /// Port n.15 configuration
        CNF15: u2 = 1,
    };
    /// Port configuration register high
    pub const CRH = Register(CRH_val).init(base_address + 0x4);

    /// IDR
    const IDR_val = packed struct {
        /// IDR0 [0:0]
        /// Port input data
        IDR0: u1 = 0,
        /// IDR1 [1:1]
        /// Port input data
        IDR1: u1 = 0,
        /// IDR2 [2:2]
        /// Port input data
        IDR2: u1 = 0,
        /// IDR3 [3:3]
        /// Port input data
        IDR3: u1 = 0,
        /// IDR4 [4:4]
        /// Port input data
        IDR4: u1 = 0,
        /// IDR5 [5:5]
        /// Port input data
        IDR5: u1 = 0,
        /// IDR6 [6:6]
        /// Port input data
        IDR6: u1 = 0,
        /// IDR7 [7:7]
        /// Port input data
        IDR7: u1 = 0,
        /// IDR8 [8:8]
        /// Port input data
        IDR8: u1 = 0,
        /// IDR9 [9:9]
        /// Port input data
        IDR9: u1 = 0,
        /// IDR10 [10:10]
        /// Port input data
        IDR10: u1 = 0,
        /// IDR11 [11:11]
        /// Port input data
        IDR11: u1 = 0,
        /// IDR12 [12:12]
        /// Port input data
        IDR12: u1 = 0,
        /// IDR13 [13:13]
        /// Port input data
        IDR13: u1 = 0,
        /// IDR14 [14:14]
        /// Port input data
        IDR14: u1 = 0,
        /// IDR15 [15:15]
        /// Port input data
        IDR15: u1 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Port input data register
    pub const IDR = Register(IDR_val).init(base_address + 0x8);

    /// ODR
    const ODR_val = packed struct {
        /// ODR0 [0:0]
        /// Port output data
        ODR0: u1 = 0,
        /// ODR1 [1:1]
        /// Port output data
        ODR1: u1 = 0,
        /// ODR2 [2:2]
        /// Port output data
        ODR2: u1 = 0,
        /// ODR3 [3:3]
        /// Port output data
        ODR3: u1 = 0,
        /// ODR4 [4:4]
        /// Port output data
        ODR4: u1 = 0,
        /// ODR5 [5:5]
        /// Port output data
        ODR5: u1 = 0,
        /// ODR6 [6:6]
        /// Port output data
        ODR6: u1 = 0,
        /// ODR7 [7:7]
        /// Port output data
        ODR7: u1 = 0,
        /// ODR8 [8:8]
        /// Port output data
        ODR8: u1 = 0,
        /// ODR9 [9:9]
        /// Port output data
        ODR9: u1 = 0,
        /// ODR10 [10:10]
        /// Port output data
        ODR10: u1 = 0,
        /// ODR11 [11:11]
        /// Port output data
        ODR11: u1 = 0,
        /// ODR12 [12:12]
        /// Port output data
        ODR12: u1 = 0,
        /// ODR13 [13:13]
        /// Port output data
        ODR13: u1 = 0,
        /// ODR14 [14:14]
        /// Port output data
        ODR14: u1 = 0,
        /// ODR15 [15:15]
        /// Port output data
        ODR15: u1 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Port output data register
    pub const ODR = Register(ODR_val).init(base_address + 0xc);

    /// BSRR
    const BSRR_val = packed struct {
        /// BS0 [0:0]
        /// Set bit 0
        BS0: u1 = 0,
        /// BS1 [1:1]
        /// Set bit 1
        BS1: u1 = 0,
        /// BS2 [2:2]
        /// Set bit 1
        BS2: u1 = 0,
        /// BS3 [3:3]
        /// Set bit 3
        BS3: u1 = 0,
        /// BS4 [4:4]
        /// Set bit 4
        BS4: u1 = 0,
        /// BS5 [5:5]
        /// Set bit 5
        BS5: u1 = 0,
        /// BS6 [6:6]
        /// Set bit 6
        BS6: u1 = 0,
        /// BS7 [7:7]
        /// Set bit 7
        BS7: u1 = 0,
        /// BS8 [8:8]
        /// Set bit 8
        BS8: u1 = 0,
        /// BS9 [9:9]
        /// Set bit 9
        BS9: u1 = 0,
        /// BS10 [10:10]
        /// Set bit 10
        BS10: u1 = 0,
        /// BS11 [11:11]
        /// Set bit 11
        BS11: u1 = 0,
        /// BS12 [12:12]
        /// Set bit 12
        BS12: u1 = 0,
        /// BS13 [13:13]
        /// Set bit 13
        BS13: u1 = 0,
        /// BS14 [14:14]
        /// Set bit 14
        BS14: u1 = 0,
        /// BS15 [15:15]
        /// Set bit 15
        BS15: u1 = 0,
        /// BR0 [16:16]
        /// Reset bit 0
        BR0: u1 = 0,
        /// BR1 [17:17]
        /// Reset bit 1
        BR1: u1 = 0,
        /// BR2 [18:18]
        /// Reset bit 2
        BR2: u1 = 0,
        /// BR3 [19:19]
        /// Reset bit 3
        BR3: u1 = 0,
        /// BR4 [20:20]
        /// Reset bit 4
        BR4: u1 = 0,
        /// BR5 [21:21]
        /// Reset bit 5
        BR5: u1 = 0,
        /// BR6 [22:22]
        /// Reset bit 6
        BR6: u1 = 0,
        /// BR7 [23:23]
        /// Reset bit 7
        BR7: u1 = 0,
        /// BR8 [24:24]
        /// Reset bit 8
        BR8: u1 = 0,
        /// BR9 [25:25]
        /// Reset bit 9
        BR9: u1 = 0,
        /// BR10 [26:26]
        /// Reset bit 10
        BR10: u1 = 0,
        /// BR11 [27:27]
        /// Reset bit 11
        BR11: u1 = 0,
        /// BR12 [28:28]
        /// Reset bit 12
        BR12: u1 = 0,
        /// BR13 [29:29]
        /// Reset bit 13
        BR13: u1 = 0,
        /// BR14 [30:30]
        /// Reset bit 14
        BR14: u1 = 0,
        /// BR15 [31:31]
        /// Reset bit 15
        BR15: u1 = 0,
    };
    /// Port bit set/reset register
    pub const BSRR = Register(BSRR_val).init(base_address + 0x10);

    /// BRR
    const BRR_val = packed struct {
        /// BR0 [0:0]
        /// Reset bit 0
        BR0: u1 = 0,
        /// BR1 [1:1]
        /// Reset bit 1
        BR1: u1 = 0,
        /// BR2 [2:2]
        /// Reset bit 1
        BR2: u1 = 0,
        /// BR3 [3:3]
        /// Reset bit 3
        BR3: u1 = 0,
        /// BR4 [4:4]
        /// Reset bit 4
        BR4: u1 = 0,
        /// BR5 [5:5]
        /// Reset bit 5
        BR5: u1 = 0,
        /// BR6 [6:6]
        /// Reset bit 6
        BR6: u1 = 0,
        /// BR7 [7:7]
        /// Reset bit 7
        BR7: u1 = 0,
        /// BR8 [8:8]
        /// Reset bit 8
        BR8: u1 = 0,
        /// BR9 [9:9]
        /// Reset bit 9
        BR9: u1 = 0,
        /// BR10 [10:10]
        /// Reset bit 10
        BR10: u1 = 0,
        /// BR11 [11:11]
        /// Reset bit 11
        BR11: u1 = 0,
        /// BR12 [12:12]
        /// Reset bit 12
        BR12: u1 = 0,
        /// BR13 [13:13]
        /// Reset bit 13
        BR13: u1 = 0,
        /// BR14 [14:14]
        /// Reset bit 14
        BR14: u1 = 0,
        /// BR15 [15:15]
        /// Reset bit 15
        BR15: u1 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Port bit reset register
    pub const BRR = Register(BRR_val).init(base_address + 0x14);

    /// LCKR
    const LCKR_val = packed struct {
        /// LCK0 [0:0]
        /// Port A Lock bit 0
        LCK0: u1 = 0,
        /// LCK1 [1:1]
        /// Port A Lock bit 1
        LCK1: u1 = 0,
        /// LCK2 [2:2]
        /// Port A Lock bit 2
        LCK2: u1 = 0,
        /// LCK3 [3:3]
        /// Port A Lock bit 3
        LCK3: u1 = 0,
        /// LCK4 [4:4]
        /// Port A Lock bit 4
        LCK4: u1 = 0,
        /// LCK5 [5:5]
        /// Port A Lock bit 5
        LCK5: u1 = 0,
        /// LCK6 [6:6]
        /// Port A Lock bit 6
        LCK6: u1 = 0,
        /// LCK7 [7:7]
        /// Port A Lock bit 7
        LCK7: u1 = 0,
        /// LCK8 [8:8]
        /// Port A Lock bit 8
        LCK8: u1 = 0,
        /// LCK9 [9:9]
        /// Port A Lock bit 9
        LCK9: u1 = 0,
        /// LCK10 [10:10]
        /// Port A Lock bit 10
        LCK10: u1 = 0,
        /// LCK11 [11:11]
        /// Port A Lock bit 11
        LCK11: u1 = 0,
        /// LCK12 [12:12]
        /// Port A Lock bit 12
        LCK12: u1 = 0,
        /// LCK13 [13:13]
        /// Port A Lock bit 13
        LCK13: u1 = 0,
        /// LCK14 [14:14]
        /// Port A Lock bit 14
        LCK14: u1 = 0,
        /// LCK15 [15:15]
        /// Port A Lock bit 15
        LCK15: u1 = 0,
        /// LCKK [16:16]
        /// Lock key
        LCKK: u1 = 0,
        /// unused [17:31]
        _unused17: u7 = 0,
        _unused24: u8 = 0,
    };
    /// Port configuration lock
    pub const LCKR = Register(LCKR_val).init(base_address + 0x18);
};

/// General purpose I/O
pub const GPIOF = struct {
    const base_address = 0x40011c00;
    /// CRL
    const CRL_val = packed struct {
        /// MODE0 [0:1]
        /// Port n.0 mode bits
        MODE0: u2 = 0,
        /// CNF0 [2:3]
        /// Port n.0 configuration
        CNF0: u2 = 1,
        /// MODE1 [4:5]
        /// Port n.1 mode bits
        MODE1: u2 = 0,
        /// CNF1 [6:7]
        /// Port n.1 configuration
        CNF1: u2 = 1,
        /// MODE2 [8:9]
        /// Port n.2 mode bits
        MODE2: u2 = 0,
        /// CNF2 [10:11]
        /// Port n.2 configuration
        CNF2: u2 = 1,
        /// MODE3 [12:13]
        /// Port n.3 mode bits
        MODE3: u2 = 0,
        /// CNF3 [14:15]
        /// Port n.3 configuration
        CNF3: u2 = 1,
        /// MODE4 [16:17]
        /// Port n.4 mode bits
        MODE4: u2 = 0,
        /// CNF4 [18:19]
        /// Port n.4 configuration
        CNF4: u2 = 1,
        /// MODE5 [20:21]
        /// Port n.5 mode bits
        MODE5: u2 = 0,
        /// CNF5 [22:23]
        /// Port n.5 configuration
        CNF5: u2 = 1,
        /// MODE6 [24:25]
        /// Port n.6 mode bits
        MODE6: u2 = 0,
        /// CNF6 [26:27]
        /// Port n.6 configuration
        CNF6: u2 = 1,
        /// MODE7 [28:29]
        /// Port n.7 mode bits
        MODE7: u2 = 0,
        /// CNF7 [30:31]
        /// Port n.7 configuration
        CNF7: u2 = 1,
    };
    /// Port configuration register low
    pub const CRL = Register(CRL_val).init(base_address + 0x0);

    /// CRH
    const CRH_val = packed struct {
        /// MODE8 [0:1]
        /// Port n.8 mode bits
        MODE8: u2 = 0,
        /// CNF8 [2:3]
        /// Port n.8 configuration
        CNF8: u2 = 1,
        /// MODE9 [4:5]
        /// Port n.9 mode bits
        MODE9: u2 = 0,
        /// CNF9 [6:7]
        /// Port n.9 configuration
        CNF9: u2 = 1,
        /// MODE10 [8:9]
        /// Port n.10 mode bits
        MODE10: u2 = 0,
        /// CNF10 [10:11]
        /// Port n.10 configuration
        CNF10: u2 = 1,
        /// MODE11 [12:13]
        /// Port n.11 mode bits
        MODE11: u2 = 0,
        /// CNF11 [14:15]
        /// Port n.11 configuration
        CNF11: u2 = 1,
        /// MODE12 [16:17]
        /// Port n.12 mode bits
        MODE12: u2 = 0,
        /// CNF12 [18:19]
        /// Port n.12 configuration
        CNF12: u2 = 1,
        /// MODE13 [20:21]
        /// Port n.13 mode bits
        MODE13: u2 = 0,
        /// CNF13 [22:23]
        /// Port n.13 configuration
        CNF13: u2 = 1,
        /// MODE14 [24:25]
        /// Port n.14 mode bits
        MODE14: u2 = 0,
        /// CNF14 [26:27]
        /// Port n.14 configuration
        CNF14: u2 = 1,
        /// MODE15 [28:29]
        /// Port n.15 mode bits
        MODE15: u2 = 0,
        /// CNF15 [30:31]
        /// Port n.15 configuration
        CNF15: u2 = 1,
    };
    /// Port configuration register high
    pub const CRH = Register(CRH_val).init(base_address + 0x4);

    /// IDR
    const IDR_val = packed struct {
        /// IDR0 [0:0]
        /// Port input data
        IDR0: u1 = 0,
        /// IDR1 [1:1]
        /// Port input data
        IDR1: u1 = 0,
        /// IDR2 [2:2]
        /// Port input data
        IDR2: u1 = 0,
        /// IDR3 [3:3]
        /// Port input data
        IDR3: u1 = 0,
        /// IDR4 [4:4]
        /// Port input data
        IDR4: u1 = 0,
        /// IDR5 [5:5]
        /// Port input data
        IDR5: u1 = 0,
        /// IDR6 [6:6]
        /// Port input data
        IDR6: u1 = 0,
        /// IDR7 [7:7]
        /// Port input data
        IDR7: u1 = 0,
        /// IDR8 [8:8]
        /// Port input data
        IDR8: u1 = 0,
        /// IDR9 [9:9]
        /// Port input data
        IDR9: u1 = 0,
        /// IDR10 [10:10]
        /// Port input data
        IDR10: u1 = 0,
        /// IDR11 [11:11]
        /// Port input data
        IDR11: u1 = 0,
        /// IDR12 [12:12]
        /// Port input data
        IDR12: u1 = 0,
        /// IDR13 [13:13]
        /// Port input data
        IDR13: u1 = 0,
        /// IDR14 [14:14]
        /// Port input data
        IDR14: u1 = 0,
        /// IDR15 [15:15]
        /// Port input data
        IDR15: u1 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Port input data register
    pub const IDR = Register(IDR_val).init(base_address + 0x8);

    /// ODR
    const ODR_val = packed struct {
        /// ODR0 [0:0]
        /// Port output data
        ODR0: u1 = 0,
        /// ODR1 [1:1]
        /// Port output data
        ODR1: u1 = 0,
        /// ODR2 [2:2]
        /// Port output data
        ODR2: u1 = 0,
        /// ODR3 [3:3]
        /// Port output data
        ODR3: u1 = 0,
        /// ODR4 [4:4]
        /// Port output data
        ODR4: u1 = 0,
        /// ODR5 [5:5]
        /// Port output data
        ODR5: u1 = 0,
        /// ODR6 [6:6]
        /// Port output data
        ODR6: u1 = 0,
        /// ODR7 [7:7]
        /// Port output data
        ODR7: u1 = 0,
        /// ODR8 [8:8]
        /// Port output data
        ODR8: u1 = 0,
        /// ODR9 [9:9]
        /// Port output data
        ODR9: u1 = 0,
        /// ODR10 [10:10]
        /// Port output data
        ODR10: u1 = 0,
        /// ODR11 [11:11]
        /// Port output data
        ODR11: u1 = 0,
        /// ODR12 [12:12]
        /// Port output data
        ODR12: u1 = 0,
        /// ODR13 [13:13]
        /// Port output data
        ODR13: u1 = 0,
        /// ODR14 [14:14]
        /// Port output data
        ODR14: u1 = 0,
        /// ODR15 [15:15]
        /// Port output data
        ODR15: u1 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Port output data register
    pub const ODR = Register(ODR_val).init(base_address + 0xc);

    /// BSRR
    const BSRR_val = packed struct {
        /// BS0 [0:0]
        /// Set bit 0
        BS0: u1 = 0,
        /// BS1 [1:1]
        /// Set bit 1
        BS1: u1 = 0,
        /// BS2 [2:2]
        /// Set bit 1
        BS2: u1 = 0,
        /// BS3 [3:3]
        /// Set bit 3
        BS3: u1 = 0,
        /// BS4 [4:4]
        /// Set bit 4
        BS4: u1 = 0,
        /// BS5 [5:5]
        /// Set bit 5
        BS5: u1 = 0,
        /// BS6 [6:6]
        /// Set bit 6
        BS6: u1 = 0,
        /// BS7 [7:7]
        /// Set bit 7
        BS7: u1 = 0,
        /// BS8 [8:8]
        /// Set bit 8
        BS8: u1 = 0,
        /// BS9 [9:9]
        /// Set bit 9
        BS9: u1 = 0,
        /// BS10 [10:10]
        /// Set bit 10
        BS10: u1 = 0,
        /// BS11 [11:11]
        /// Set bit 11
        BS11: u1 = 0,
        /// BS12 [12:12]
        /// Set bit 12
        BS12: u1 = 0,
        /// BS13 [13:13]
        /// Set bit 13
        BS13: u1 = 0,
        /// BS14 [14:14]
        /// Set bit 14
        BS14: u1 = 0,
        /// BS15 [15:15]
        /// Set bit 15
        BS15: u1 = 0,
        /// BR0 [16:16]
        /// Reset bit 0
        BR0: u1 = 0,
        /// BR1 [17:17]
        /// Reset bit 1
        BR1: u1 = 0,
        /// BR2 [18:18]
        /// Reset bit 2
        BR2: u1 = 0,
        /// BR3 [19:19]
        /// Reset bit 3
        BR3: u1 = 0,
        /// BR4 [20:20]
        /// Reset bit 4
        BR4: u1 = 0,
        /// BR5 [21:21]
        /// Reset bit 5
        BR5: u1 = 0,
        /// BR6 [22:22]
        /// Reset bit 6
        BR6: u1 = 0,
        /// BR7 [23:23]
        /// Reset bit 7
        BR7: u1 = 0,
        /// BR8 [24:24]
        /// Reset bit 8
        BR8: u1 = 0,
        /// BR9 [25:25]
        /// Reset bit 9
        BR9: u1 = 0,
        /// BR10 [26:26]
        /// Reset bit 10
        BR10: u1 = 0,
        /// BR11 [27:27]
        /// Reset bit 11
        BR11: u1 = 0,
        /// BR12 [28:28]
        /// Reset bit 12
        BR12: u1 = 0,
        /// BR13 [29:29]
        /// Reset bit 13
        BR13: u1 = 0,
        /// BR14 [30:30]
        /// Reset bit 14
        BR14: u1 = 0,
        /// BR15 [31:31]
        /// Reset bit 15
        BR15: u1 = 0,
    };
    /// Port bit set/reset register
    pub const BSRR = Register(BSRR_val).init(base_address + 0x10);

    /// BRR
    const BRR_val = packed struct {
        /// BR0 [0:0]
        /// Reset bit 0
        BR0: u1 = 0,
        /// BR1 [1:1]
        /// Reset bit 1
        BR1: u1 = 0,
        /// BR2 [2:2]
        /// Reset bit 1
        BR2: u1 = 0,
        /// BR3 [3:3]
        /// Reset bit 3
        BR3: u1 = 0,
        /// BR4 [4:4]
        /// Reset bit 4
        BR4: u1 = 0,
        /// BR5 [5:5]
        /// Reset bit 5
        BR5: u1 = 0,
        /// BR6 [6:6]
        /// Reset bit 6
        BR6: u1 = 0,
        /// BR7 [7:7]
        /// Reset bit 7
        BR7: u1 = 0,
        /// BR8 [8:8]
        /// Reset bit 8
        BR8: u1 = 0,
        /// BR9 [9:9]
        /// Reset bit 9
        BR9: u1 = 0,
        /// BR10 [10:10]
        /// Reset bit 10
        BR10: u1 = 0,
        /// BR11 [11:11]
        /// Reset bit 11
        BR11: u1 = 0,
        /// BR12 [12:12]
        /// Reset bit 12
        BR12: u1 = 0,
        /// BR13 [13:13]
        /// Reset bit 13
        BR13: u1 = 0,
        /// BR14 [14:14]
        /// Reset bit 14
        BR14: u1 = 0,
        /// BR15 [15:15]
        /// Reset bit 15
        BR15: u1 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Port bit reset register
    pub const BRR = Register(BRR_val).init(base_address + 0x14);

    /// LCKR
    const LCKR_val = packed struct {
        /// LCK0 [0:0]
        /// Port A Lock bit 0
        LCK0: u1 = 0,
        /// LCK1 [1:1]
        /// Port A Lock bit 1
        LCK1: u1 = 0,
        /// LCK2 [2:2]
        /// Port A Lock bit 2
        LCK2: u1 = 0,
        /// LCK3 [3:3]
        /// Port A Lock bit 3
        LCK3: u1 = 0,
        /// LCK4 [4:4]
        /// Port A Lock bit 4
        LCK4: u1 = 0,
        /// LCK5 [5:5]
        /// Port A Lock bit 5
        LCK5: u1 = 0,
        /// LCK6 [6:6]
        /// Port A Lock bit 6
        LCK6: u1 = 0,
        /// LCK7 [7:7]
        /// Port A Lock bit 7
        LCK7: u1 = 0,
        /// LCK8 [8:8]
        /// Port A Lock bit 8
        LCK8: u1 = 0,
        /// LCK9 [9:9]
        /// Port A Lock bit 9
        LCK9: u1 = 0,
        /// LCK10 [10:10]
        /// Port A Lock bit 10
        LCK10: u1 = 0,
        /// LCK11 [11:11]
        /// Port A Lock bit 11
        LCK11: u1 = 0,
        /// LCK12 [12:12]
        /// Port A Lock bit 12
        LCK12: u1 = 0,
        /// LCK13 [13:13]
        /// Port A Lock bit 13
        LCK13: u1 = 0,
        /// LCK14 [14:14]
        /// Port A Lock bit 14
        LCK14: u1 = 0,
        /// LCK15 [15:15]
        /// Port A Lock bit 15
        LCK15: u1 = 0,
        /// LCKK [16:16]
        /// Lock key
        LCKK: u1 = 0,
        /// unused [17:31]
        _unused17: u7 = 0,
        _unused24: u8 = 0,
    };
    /// Port configuration lock
    pub const LCKR = Register(LCKR_val).init(base_address + 0x18);
};

/// General purpose I/O
pub const GPIOG = struct {
    const base_address = 0x40012000;
    /// CRL
    const CRL_val = packed struct {
        /// MODE0 [0:1]
        /// Port n.0 mode bits
        MODE0: u2 = 0,
        /// CNF0 [2:3]
        /// Port n.0 configuration
        CNF0: u2 = 1,
        /// MODE1 [4:5]
        /// Port n.1 mode bits
        MODE1: u2 = 0,
        /// CNF1 [6:7]
        /// Port n.1 configuration
        CNF1: u2 = 1,
        /// MODE2 [8:9]
        /// Port n.2 mode bits
        MODE2: u2 = 0,
        /// CNF2 [10:11]
        /// Port n.2 configuration
        CNF2: u2 = 1,
        /// MODE3 [12:13]
        /// Port n.3 mode bits
        MODE3: u2 = 0,
        /// CNF3 [14:15]
        /// Port n.3 configuration
        CNF3: u2 = 1,
        /// MODE4 [16:17]
        /// Port n.4 mode bits
        MODE4: u2 = 0,
        /// CNF4 [18:19]
        /// Port n.4 configuration
        CNF4: u2 = 1,
        /// MODE5 [20:21]
        /// Port n.5 mode bits
        MODE5: u2 = 0,
        /// CNF5 [22:23]
        /// Port n.5 configuration
        CNF5: u2 = 1,
        /// MODE6 [24:25]
        /// Port n.6 mode bits
        MODE6: u2 = 0,
        /// CNF6 [26:27]
        /// Port n.6 configuration
        CNF6: u2 = 1,
        /// MODE7 [28:29]
        /// Port n.7 mode bits
        MODE7: u2 = 0,
        /// CNF7 [30:31]
        /// Port n.7 configuration
        CNF7: u2 = 1,
    };
    /// Port configuration register low
    pub const CRL = Register(CRL_val).init(base_address + 0x0);

    /// CRH
    const CRH_val = packed struct {
        /// MODE8 [0:1]
        /// Port n.8 mode bits
        MODE8: u2 = 0,
        /// CNF8 [2:3]
        /// Port n.8 configuration
        CNF8: u2 = 1,
        /// MODE9 [4:5]
        /// Port n.9 mode bits
        MODE9: u2 = 0,
        /// CNF9 [6:7]
        /// Port n.9 configuration
        CNF9: u2 = 1,
        /// MODE10 [8:9]
        /// Port n.10 mode bits
        MODE10: u2 = 0,
        /// CNF10 [10:11]
        /// Port n.10 configuration
        CNF10: u2 = 1,
        /// MODE11 [12:13]
        /// Port n.11 mode bits
        MODE11: u2 = 0,
        /// CNF11 [14:15]
        /// Port n.11 configuration
        CNF11: u2 = 1,
        /// MODE12 [16:17]
        /// Port n.12 mode bits
        MODE12: u2 = 0,
        /// CNF12 [18:19]
        /// Port n.12 configuration
        CNF12: u2 = 1,
        /// MODE13 [20:21]
        /// Port n.13 mode bits
        MODE13: u2 = 0,
        /// CNF13 [22:23]
        /// Port n.13 configuration
        CNF13: u2 = 1,
        /// MODE14 [24:25]
        /// Port n.14 mode bits
        MODE14: u2 = 0,
        /// CNF14 [26:27]
        /// Port n.14 configuration
        CNF14: u2 = 1,
        /// MODE15 [28:29]
        /// Port n.15 mode bits
        MODE15: u2 = 0,
        /// CNF15 [30:31]
        /// Port n.15 configuration
        CNF15: u2 = 1,
    };
    /// Port configuration register high
    pub const CRH = Register(CRH_val).init(base_address + 0x4);

    /// IDR
    const IDR_val = packed struct {
        /// IDR0 [0:0]
        /// Port input data
        IDR0: u1 = 0,
        /// IDR1 [1:1]
        /// Port input data
        IDR1: u1 = 0,
        /// IDR2 [2:2]
        /// Port input data
        IDR2: u1 = 0,
        /// IDR3 [3:3]
        /// Port input data
        IDR3: u1 = 0,
        /// IDR4 [4:4]
        /// Port input data
        IDR4: u1 = 0,
        /// IDR5 [5:5]
        /// Port input data
        IDR5: u1 = 0,
        /// IDR6 [6:6]
        /// Port input data
        IDR6: u1 = 0,
        /// IDR7 [7:7]
        /// Port input data
        IDR7: u1 = 0,
        /// IDR8 [8:8]
        /// Port input data
        IDR8: u1 = 0,
        /// IDR9 [9:9]
        /// Port input data
        IDR9: u1 = 0,
        /// IDR10 [10:10]
        /// Port input data
        IDR10: u1 = 0,
        /// IDR11 [11:11]
        /// Port input data
        IDR11: u1 = 0,
        /// IDR12 [12:12]
        /// Port input data
        IDR12: u1 = 0,
        /// IDR13 [13:13]
        /// Port input data
        IDR13: u1 = 0,
        /// IDR14 [14:14]
        /// Port input data
        IDR14: u1 = 0,
        /// IDR15 [15:15]
        /// Port input data
        IDR15: u1 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Port input data register
    pub const IDR = Register(IDR_val).init(base_address + 0x8);

    /// ODR
    const ODR_val = packed struct {
        /// ODR0 [0:0]
        /// Port output data
        ODR0: u1 = 0,
        /// ODR1 [1:1]
        /// Port output data
        ODR1: u1 = 0,
        /// ODR2 [2:2]
        /// Port output data
        ODR2: u1 = 0,
        /// ODR3 [3:3]
        /// Port output data
        ODR3: u1 = 0,
        /// ODR4 [4:4]
        /// Port output data
        ODR4: u1 = 0,
        /// ODR5 [5:5]
        /// Port output data
        ODR5: u1 = 0,
        /// ODR6 [6:6]
        /// Port output data
        ODR6: u1 = 0,
        /// ODR7 [7:7]
        /// Port output data
        ODR7: u1 = 0,
        /// ODR8 [8:8]
        /// Port output data
        ODR8: u1 = 0,
        /// ODR9 [9:9]
        /// Port output data
        ODR9: u1 = 0,
        /// ODR10 [10:10]
        /// Port output data
        ODR10: u1 = 0,
        /// ODR11 [11:11]
        /// Port output data
        ODR11: u1 = 0,
        /// ODR12 [12:12]
        /// Port output data
        ODR12: u1 = 0,
        /// ODR13 [13:13]
        /// Port output data
        ODR13: u1 = 0,
        /// ODR14 [14:14]
        /// Port output data
        ODR14: u1 = 0,
        /// ODR15 [15:15]
        /// Port output data
        ODR15: u1 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Port output data register
    pub const ODR = Register(ODR_val).init(base_address + 0xc);

    /// BSRR
    const BSRR_val = packed struct {
        /// BS0 [0:0]
        /// Set bit 0
        BS0: u1 = 0,
        /// BS1 [1:1]
        /// Set bit 1
        BS1: u1 = 0,
        /// BS2 [2:2]
        /// Set bit 1
        BS2: u1 = 0,
        /// BS3 [3:3]
        /// Set bit 3
        BS3: u1 = 0,
        /// BS4 [4:4]
        /// Set bit 4
        BS4: u1 = 0,
        /// BS5 [5:5]
        /// Set bit 5
        BS5: u1 = 0,
        /// BS6 [6:6]
        /// Set bit 6
        BS6: u1 = 0,
        /// BS7 [7:7]
        /// Set bit 7
        BS7: u1 = 0,
        /// BS8 [8:8]
        /// Set bit 8
        BS8: u1 = 0,
        /// BS9 [9:9]
        /// Set bit 9
        BS9: u1 = 0,
        /// BS10 [10:10]
        /// Set bit 10
        BS10: u1 = 0,
        /// BS11 [11:11]
        /// Set bit 11
        BS11: u1 = 0,
        /// BS12 [12:12]
        /// Set bit 12
        BS12: u1 = 0,
        /// BS13 [13:13]
        /// Set bit 13
        BS13: u1 = 0,
        /// BS14 [14:14]
        /// Set bit 14
        BS14: u1 = 0,
        /// BS15 [15:15]
        /// Set bit 15
        BS15: u1 = 0,
        /// BR0 [16:16]
        /// Reset bit 0
        BR0: u1 = 0,
        /// BR1 [17:17]
        /// Reset bit 1
        BR1: u1 = 0,
        /// BR2 [18:18]
        /// Reset bit 2
        BR2: u1 = 0,
        /// BR3 [19:19]
        /// Reset bit 3
        BR3: u1 = 0,
        /// BR4 [20:20]
        /// Reset bit 4
        BR4: u1 = 0,
        /// BR5 [21:21]
        /// Reset bit 5
        BR5: u1 = 0,
        /// BR6 [22:22]
        /// Reset bit 6
        BR6: u1 = 0,
        /// BR7 [23:23]
        /// Reset bit 7
        BR7: u1 = 0,
        /// BR8 [24:24]
        /// Reset bit 8
        BR8: u1 = 0,
        /// BR9 [25:25]
        /// Reset bit 9
        BR9: u1 = 0,
        /// BR10 [26:26]
        /// Reset bit 10
        BR10: u1 = 0,
        /// BR11 [27:27]
        /// Reset bit 11
        BR11: u1 = 0,
        /// BR12 [28:28]
        /// Reset bit 12
        BR12: u1 = 0,
        /// BR13 [29:29]
        /// Reset bit 13
        BR13: u1 = 0,
        /// BR14 [30:30]
        /// Reset bit 14
        BR14: u1 = 0,
        /// BR15 [31:31]
        /// Reset bit 15
        BR15: u1 = 0,
    };
    /// Port bit set/reset register
    pub const BSRR = Register(BSRR_val).init(base_address + 0x10);

    /// BRR
    const BRR_val = packed struct {
        /// BR0 [0:0]
        /// Reset bit 0
        BR0: u1 = 0,
        /// BR1 [1:1]
        /// Reset bit 1
        BR1: u1 = 0,
        /// BR2 [2:2]
        /// Reset bit 1
        BR2: u1 = 0,
        /// BR3 [3:3]
        /// Reset bit 3
        BR3: u1 = 0,
        /// BR4 [4:4]
        /// Reset bit 4
        BR4: u1 = 0,
        /// BR5 [5:5]
        /// Reset bit 5
        BR5: u1 = 0,
        /// BR6 [6:6]
        /// Reset bit 6
        BR6: u1 = 0,
        /// BR7 [7:7]
        /// Reset bit 7
        BR7: u1 = 0,
        /// BR8 [8:8]
        /// Reset bit 8
        BR8: u1 = 0,
        /// BR9 [9:9]
        /// Reset bit 9
        BR9: u1 = 0,
        /// BR10 [10:10]
        /// Reset bit 10
        BR10: u1 = 0,
        /// BR11 [11:11]
        /// Reset bit 11
        BR11: u1 = 0,
        /// BR12 [12:12]
        /// Reset bit 12
        BR12: u1 = 0,
        /// BR13 [13:13]
        /// Reset bit 13
        BR13: u1 = 0,
        /// BR14 [14:14]
        /// Reset bit 14
        BR14: u1 = 0,
        /// BR15 [15:15]
        /// Reset bit 15
        BR15: u1 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Port bit reset register
    pub const BRR = Register(BRR_val).init(base_address + 0x14);

    /// LCKR
    const LCKR_val = packed struct {
        /// LCK0 [0:0]
        /// Port A Lock bit 0
        LCK0: u1 = 0,
        /// LCK1 [1:1]
        /// Port A Lock bit 1
        LCK1: u1 = 0,
        /// LCK2 [2:2]
        /// Port A Lock bit 2
        LCK2: u1 = 0,
        /// LCK3 [3:3]
        /// Port A Lock bit 3
        LCK3: u1 = 0,
        /// LCK4 [4:4]
        /// Port A Lock bit 4
        LCK4: u1 = 0,
        /// LCK5 [5:5]
        /// Port A Lock bit 5
        LCK5: u1 = 0,
        /// LCK6 [6:6]
        /// Port A Lock bit 6
        LCK6: u1 = 0,
        /// LCK7 [7:7]
        /// Port A Lock bit 7
        LCK7: u1 = 0,
        /// LCK8 [8:8]
        /// Port A Lock bit 8
        LCK8: u1 = 0,
        /// LCK9 [9:9]
        /// Port A Lock bit 9
        LCK9: u1 = 0,
        /// LCK10 [10:10]
        /// Port A Lock bit 10
        LCK10: u1 = 0,
        /// LCK11 [11:11]
        /// Port A Lock bit 11
        LCK11: u1 = 0,
        /// LCK12 [12:12]
        /// Port A Lock bit 12
        LCK12: u1 = 0,
        /// LCK13 [13:13]
        /// Port A Lock bit 13
        LCK13: u1 = 0,
        /// LCK14 [14:14]
        /// Port A Lock bit 14
        LCK14: u1 = 0,
        /// LCK15 [15:15]
        /// Port A Lock bit 15
        LCK15: u1 = 0,
        /// LCKK [16:16]
        /// Lock key
        LCKK: u1 = 0,
        /// unused [17:31]
        _unused17: u7 = 0,
        _unused24: u8 = 0,
    };
    /// Port configuration lock
    pub const LCKR = Register(LCKR_val).init(base_address + 0x18);
};

/// Alternate function I/O
pub const AFIO = struct {
    const base_address = 0x40010000;
    /// EVCR
    const EVCR_val = packed struct {
        /// PIN [0:3]
        /// Pin selection
        PIN: u4 = 0,
        /// PORT [4:6]
        /// Port selection
        PORT: u3 = 0,
        /// EVOE [7:7]
        /// Event Output Enable
        EVOE: u1 = 0,
        /// unused [8:31]
        _unused8: u8 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Event Control Register
    pub const EVCR = Register(EVCR_val).init(base_address + 0x0);

    /// MAPR
    const MAPR_val = packed struct {
        /// SPI1_REMAP [0:0]
        /// SPI1 remapping
        SPI1_REMAP: u1 = 0,
        /// I2C1_REMAP [1:1]
        /// I2C1 remapping
        I2C1_REMAP: u1 = 0,
        /// USART1_REMAP [2:2]
        /// USART1 remapping
        USART1_REMAP: u1 = 0,
        /// USART2_REMAP [3:3]
        /// USART2 remapping
        USART2_REMAP: u1 = 0,
        /// USART3_REMAP [4:5]
        /// USART3 remapping
        USART3_REMAP: u2 = 0,
        /// TIM1_REMAP [6:7]
        /// TIM1 remapping
        TIM1_REMAP: u2 = 0,
        /// TIM2_REMAP [8:9]
        /// TIM2 remapping
        TIM2_REMAP: u2 = 0,
        /// TIM3_REMAP [10:11]
        /// TIM3 remapping
        TIM3_REMAP: u2 = 0,
        /// TIM4_REMAP [12:12]
        /// TIM4 remapping
        TIM4_REMAP: u1 = 0,
        /// CAN_REMAP [13:14]
        /// CAN1 remapping
        CAN_REMAP: u2 = 0,
        /// PD01_REMAP [15:15]
        /// Port D0/Port D1 mapping on
        PD01_REMAP: u1 = 0,
        /// TIM5CH4_IREMAP [16:16]
        /// Set and cleared by
        TIM5CH4_IREMAP: u1 = 0,
        /// ADC1_ETRGINJ_REMAP [17:17]
        /// ADC 1 External trigger injected
        ADC1_ETRGINJ_REMAP: u1 = 0,
        /// ADC1_ETRGREG_REMAP [18:18]
        /// ADC 1 external trigger regular
        ADC1_ETRGREG_REMAP: u1 = 0,
        /// ADC2_ETRGINJ_REMAP [19:19]
        /// ADC 2 external trigger injected
        ADC2_ETRGINJ_REMAP: u1 = 0,
        /// ADC2_ETRGREG_REMAP [20:20]
        /// ADC 2 external trigger regular
        ADC2_ETRGREG_REMAP: u1 = 0,
        /// unused [21:23]
        _unused21: u3 = 0,
        /// SWJ_CFG [24:26]
        /// Serial wire JTAG
        SWJ_CFG: u3 = 0,
        /// unused [27:31]
        _unused27: u5 = 0,
    };
    /// AF remap and debug I/O configuration
    pub const MAPR = Register(MAPR_val).init(base_address + 0x4);

    /// EXTICR1
    const EXTICR1_val = packed struct {
        /// EXTI0 [0:3]
        /// EXTI0 configuration
        EXTI0: u4 = 0,
        /// EXTI1 [4:7]
        /// EXTI1 configuration
        EXTI1: u4 = 0,
        /// EXTI2 [8:11]
        /// EXTI2 configuration
        EXTI2: u4 = 0,
        /// EXTI3 [12:15]
        /// EXTI3 configuration
        EXTI3: u4 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// External interrupt configuration register 1
    pub const EXTICR1 = Register(EXTICR1_val).init(base_address + 0x8);

    /// EXTICR2
    const EXTICR2_val = packed struct {
        /// EXTI4 [0:3]
        /// EXTI4 configuration
        EXTI4: u4 = 0,
        /// EXTI5 [4:7]
        /// EXTI5 configuration
        EXTI5: u4 = 0,
        /// EXTI6 [8:11]
        /// EXTI6 configuration
        EXTI6: u4 = 0,
        /// EXTI7 [12:15]
        /// EXTI7 configuration
        EXTI7: u4 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// External interrupt configuration register 2
    pub const EXTICR2 = Register(EXTICR2_val).init(base_address + 0xc);

    /// EXTICR3
    const EXTICR3_val = packed struct {
        /// EXTI8 [0:3]
        /// EXTI8 configuration
        EXTI8: u4 = 0,
        /// EXTI9 [4:7]
        /// EXTI9 configuration
        EXTI9: u4 = 0,
        /// EXTI10 [8:11]
        /// EXTI10 configuration
        EXTI10: u4 = 0,
        /// EXTI11 [12:15]
        /// EXTI11 configuration
        EXTI11: u4 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// External interrupt configuration register 3
    pub const EXTICR3 = Register(EXTICR3_val).init(base_address + 0x10);

    /// EXTICR4
    const EXTICR4_val = packed struct {
        /// EXTI12 [0:3]
        /// EXTI12 configuration
        EXTI12: u4 = 0,
        /// EXTI13 [4:7]
        /// EXTI13 configuration
        EXTI13: u4 = 0,
        /// EXTI14 [8:11]
        /// EXTI14 configuration
        EXTI14: u4 = 0,
        /// EXTI15 [12:15]
        /// EXTI15 configuration
        EXTI15: u4 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// External interrupt configuration register 4
    pub const EXTICR4 = Register(EXTICR4_val).init(base_address + 0x14);

    /// MAPR2
    const MAPR2_val = packed struct {
        /// unused [0:4]
        _unused0: u5 = 0,
        /// TIM9_REMAP [5:5]
        /// TIM9 remapping
        TIM9_REMAP: u1 = 0,
        /// TIM10_REMAP [6:6]
        /// TIM10 remapping
        TIM10_REMAP: u1 = 0,
        /// TIM11_REMAP [7:7]
        /// TIM11 remapping
        TIM11_REMAP: u1 = 0,
        /// TIM13_REMAP [8:8]
        /// TIM13 remapping
        TIM13_REMAP: u1 = 0,
        /// TIM14_REMAP [9:9]
        /// TIM14 remapping
        TIM14_REMAP: u1 = 0,
        /// FSMC_NADV [10:10]
        /// NADV connect/disconnect
        FSMC_NADV: u1 = 0,
        /// unused [11:31]
        _unused11: u5 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// AF remap and debug I/O configuration
    pub const MAPR2 = Register(MAPR2_val).init(base_address + 0x1c);
};

/// EXTI
pub const EXTI = struct {
    const base_address = 0x40010400;
    /// IMR
    const IMR_val = packed struct {
        /// MR0 [0:0]
        /// Interrupt Mask on line 0
        MR0: u1 = 0,
        /// MR1 [1:1]
        /// Interrupt Mask on line 1
        MR1: u1 = 0,
        /// MR2 [2:2]
        /// Interrupt Mask on line 2
        MR2: u1 = 0,
        /// MR3 [3:3]
        /// Interrupt Mask on line 3
        MR3: u1 = 0,
        /// MR4 [4:4]
        /// Interrupt Mask on line 4
        MR4: u1 = 0,
        /// MR5 [5:5]
        /// Interrupt Mask on line 5
        MR5: u1 = 0,
        /// MR6 [6:6]
        /// Interrupt Mask on line 6
        MR6: u1 = 0,
        /// MR7 [7:7]
        /// Interrupt Mask on line 7
        MR7: u1 = 0,
        /// MR8 [8:8]
        /// Interrupt Mask on line 8
        MR8: u1 = 0,
        /// MR9 [9:9]
        /// Interrupt Mask on line 9
        MR9: u1 = 0,
        /// MR10 [10:10]
        /// Interrupt Mask on line 10
        MR10: u1 = 0,
        /// MR11 [11:11]
        /// Interrupt Mask on line 11
        MR11: u1 = 0,
        /// MR12 [12:12]
        /// Interrupt Mask on line 12
        MR12: u1 = 0,
        /// MR13 [13:13]
        /// Interrupt Mask on line 13
        MR13: u1 = 0,
        /// MR14 [14:14]
        /// Interrupt Mask on line 14
        MR14: u1 = 0,
        /// MR15 [15:15]
        /// Interrupt Mask on line 15
        MR15: u1 = 0,
        /// MR16 [16:16]
        /// Interrupt Mask on line 16
        MR16: u1 = 0,
        /// MR17 [17:17]
        /// Interrupt Mask on line 17
        MR17: u1 = 0,
        /// MR18 [18:18]
        /// Interrupt Mask on line 18
        MR18: u1 = 0,
        /// unused [19:31]
        _unused19: u5 = 0,
        _unused24: u8 = 0,
    };
    /// Interrupt mask register
    pub const IMR = Register(IMR_val).init(base_address + 0x0);

    /// EMR
    const EMR_val = packed struct {
        /// MR0 [0:0]
        /// Event Mask on line 0
        MR0: u1 = 0,
        /// MR1 [1:1]
        /// Event Mask on line 1
        MR1: u1 = 0,
        /// MR2 [2:2]
        /// Event Mask on line 2
        MR2: u1 = 0,
        /// MR3 [3:3]
        /// Event Mask on line 3
        MR3: u1 = 0,
        /// MR4 [4:4]
        /// Event Mask on line 4
        MR4: u1 = 0,
        /// MR5 [5:5]
        /// Event Mask on line 5
        MR5: u1 = 0,
        /// MR6 [6:6]
        /// Event Mask on line 6
        MR6: u1 = 0,
        /// MR7 [7:7]
        /// Event Mask on line 7
        MR7: u1 = 0,
        /// MR8 [8:8]
        /// Event Mask on line 8
        MR8: u1 = 0,
        /// MR9 [9:9]
        /// Event Mask on line 9
        MR9: u1 = 0,
        /// MR10 [10:10]
        /// Event Mask on line 10
        MR10: u1 = 0,
        /// MR11 [11:11]
        /// Event Mask on line 11
        MR11: u1 = 0,
        /// MR12 [12:12]
        /// Event Mask on line 12
        MR12: u1 = 0,
        /// MR13 [13:13]
        /// Event Mask on line 13
        MR13: u1 = 0,
        /// MR14 [14:14]
        /// Event Mask on line 14
        MR14: u1 = 0,
        /// MR15 [15:15]
        /// Event Mask on line 15
        MR15: u1 = 0,
        /// MR16 [16:16]
        /// Event Mask on line 16
        MR16: u1 = 0,
        /// MR17 [17:17]
        /// Event Mask on line 17
        MR17: u1 = 0,
        /// MR18 [18:18]
        /// Event Mask on line 18
        MR18: u1 = 0,
        /// unused [19:31]
        _unused19: u5 = 0,
        _unused24: u8 = 0,
    };
    /// Event mask register (EXTI_EMR)
    pub const EMR = Register(EMR_val).init(base_address + 0x4);

    /// RTSR
    const RTSR_val = packed struct {
        /// TR0 [0:0]
        /// Rising trigger event configuration of
        TR0: u1 = 0,
        /// TR1 [1:1]
        /// Rising trigger event configuration of
        TR1: u1 = 0,
        /// TR2 [2:2]
        /// Rising trigger event configuration of
        TR2: u1 = 0,
        /// TR3 [3:3]
        /// Rising trigger event configuration of
        TR3: u1 = 0,
        /// TR4 [4:4]
        /// Rising trigger event configuration of
        TR4: u1 = 0,
        /// TR5 [5:5]
        /// Rising trigger event configuration of
        TR5: u1 = 0,
        /// TR6 [6:6]
        /// Rising trigger event configuration of
        TR6: u1 = 0,
        /// TR7 [7:7]
        /// Rising trigger event configuration of
        TR7: u1 = 0,
        /// TR8 [8:8]
        /// Rising trigger event configuration of
        TR8: u1 = 0,
        /// TR9 [9:9]
        /// Rising trigger event configuration of
        TR9: u1 = 0,
        /// TR10 [10:10]
        /// Rising trigger event configuration of
        TR10: u1 = 0,
        /// TR11 [11:11]
        /// Rising trigger event configuration of
        TR11: u1 = 0,
        /// TR12 [12:12]
        /// Rising trigger event configuration of
        TR12: u1 = 0,
        /// TR13 [13:13]
        /// Rising trigger event configuration of
        TR13: u1 = 0,
        /// TR14 [14:14]
        /// Rising trigger event configuration of
        TR14: u1 = 0,
        /// TR15 [15:15]
        /// Rising trigger event configuration of
        TR15: u1 = 0,
        /// TR16 [16:16]
        /// Rising trigger event configuration of
        TR16: u1 = 0,
        /// TR17 [17:17]
        /// Rising trigger event configuration of
        TR17: u1 = 0,
        /// TR18 [18:18]
        /// Rising trigger event configuration of
        TR18: u1 = 0,
        /// unused [19:31]
        _unused19: u5 = 0,
        _unused24: u8 = 0,
    };
    /// Rising Trigger selection register
    pub const RTSR = Register(RTSR_val).init(base_address + 0x8);

    /// FTSR
    const FTSR_val = packed struct {
        /// TR0 [0:0]
        /// Falling trigger event configuration of
        TR0: u1 = 0,
        /// TR1 [1:1]
        /// Falling trigger event configuration of
        TR1: u1 = 0,
        /// TR2 [2:2]
        /// Falling trigger event configuration of
        TR2: u1 = 0,
        /// TR3 [3:3]
        /// Falling trigger event configuration of
        TR3: u1 = 0,
        /// TR4 [4:4]
        /// Falling trigger event configuration of
        TR4: u1 = 0,
        /// TR5 [5:5]
        /// Falling trigger event configuration of
        TR5: u1 = 0,
        /// TR6 [6:6]
        /// Falling trigger event configuration of
        TR6: u1 = 0,
        /// TR7 [7:7]
        /// Falling trigger event configuration of
        TR7: u1 = 0,
        /// TR8 [8:8]
        /// Falling trigger event configuration of
        TR8: u1 = 0,
        /// TR9 [9:9]
        /// Falling trigger event configuration of
        TR9: u1 = 0,
        /// TR10 [10:10]
        /// Falling trigger event configuration of
        TR10: u1 = 0,
        /// TR11 [11:11]
        /// Falling trigger event configuration of
        TR11: u1 = 0,
        /// TR12 [12:12]
        /// Falling trigger event configuration of
        TR12: u1 = 0,
        /// TR13 [13:13]
        /// Falling trigger event configuration of
        TR13: u1 = 0,
        /// TR14 [14:14]
        /// Falling trigger event configuration of
        TR14: u1 = 0,
        /// TR15 [15:15]
        /// Falling trigger event configuration of
        TR15: u1 = 0,
        /// TR16 [16:16]
        /// Falling trigger event configuration of
        TR16: u1 = 0,
        /// TR17 [17:17]
        /// Falling trigger event configuration of
        TR17: u1 = 0,
        /// TR18 [18:18]
        /// Falling trigger event configuration of
        TR18: u1 = 0,
        /// unused [19:31]
        _unused19: u5 = 0,
        _unused24: u8 = 0,
    };
    /// Falling Trigger selection register
    pub const FTSR = Register(FTSR_val).init(base_address + 0xc);

    /// SWIER
    const SWIER_val = packed struct {
        /// SWIER0 [0:0]
        /// Software Interrupt on line
        SWIER0: u1 = 0,
        /// SWIER1 [1:1]
        /// Software Interrupt on line
        SWIER1: u1 = 0,
        /// SWIER2 [2:2]
        /// Software Interrupt on line
        SWIER2: u1 = 0,
        /// SWIER3 [3:3]
        /// Software Interrupt on line
        SWIER3: u1 = 0,
        /// SWIER4 [4:4]
        /// Software Interrupt on line
        SWIER4: u1 = 0,
        /// SWIER5 [5:5]
        /// Software Interrupt on line
        SWIER5: u1 = 0,
        /// SWIER6 [6:6]
        /// Software Interrupt on line
        SWIER6: u1 = 0,
        /// SWIER7 [7:7]
        /// Software Interrupt on line
        SWIER7: u1 = 0,
        /// SWIER8 [8:8]
        /// Software Interrupt on line
        SWIER8: u1 = 0,
        /// SWIER9 [9:9]
        /// Software Interrupt on line
        SWIER9: u1 = 0,
        /// SWIER10 [10:10]
        /// Software Interrupt on line
        SWIER10: u1 = 0,
        /// SWIER11 [11:11]
        /// Software Interrupt on line
        SWIER11: u1 = 0,
        /// SWIER12 [12:12]
        /// Software Interrupt on line
        SWIER12: u1 = 0,
        /// SWIER13 [13:13]
        /// Software Interrupt on line
        SWIER13: u1 = 0,
        /// SWIER14 [14:14]
        /// Software Interrupt on line
        SWIER14: u1 = 0,
        /// SWIER15 [15:15]
        /// Software Interrupt on line
        SWIER15: u1 = 0,
        /// SWIER16 [16:16]
        /// Software Interrupt on line
        SWIER16: u1 = 0,
        /// SWIER17 [17:17]
        /// Software Interrupt on line
        SWIER17: u1 = 0,
        /// SWIER18 [18:18]
        /// Software Interrupt on line
        SWIER18: u1 = 0,
        /// unused [19:31]
        _unused19: u5 = 0,
        _unused24: u8 = 0,
    };
    /// Software interrupt event register
    pub const SWIER = Register(SWIER_val).init(base_address + 0x10);

    /// PR
    const PR_val = packed struct {
        /// PR0 [0:0]
        /// Pending bit 0
        PR0: u1 = 0,
        /// PR1 [1:1]
        /// Pending bit 1
        PR1: u1 = 0,
        /// PR2 [2:2]
        /// Pending bit 2
        PR2: u1 = 0,
        /// PR3 [3:3]
        /// Pending bit 3
        PR3: u1 = 0,
        /// PR4 [4:4]
        /// Pending bit 4
        PR4: u1 = 0,
        /// PR5 [5:5]
        /// Pending bit 5
        PR5: u1 = 0,
        /// PR6 [6:6]
        /// Pending bit 6
        PR6: u1 = 0,
        /// PR7 [7:7]
        /// Pending bit 7
        PR7: u1 = 0,
        /// PR8 [8:8]
        /// Pending bit 8
        PR8: u1 = 0,
        /// PR9 [9:9]
        /// Pending bit 9
        PR9: u1 = 0,
        /// PR10 [10:10]
        /// Pending bit 10
        PR10: u1 = 0,
        /// PR11 [11:11]
        /// Pending bit 11
        PR11: u1 = 0,
        /// PR12 [12:12]
        /// Pending bit 12
        PR12: u1 = 0,
        /// PR13 [13:13]
        /// Pending bit 13
        PR13: u1 = 0,
        /// PR14 [14:14]
        /// Pending bit 14
        PR14: u1 = 0,
        /// PR15 [15:15]
        /// Pending bit 15
        PR15: u1 = 0,
        /// PR16 [16:16]
        /// Pending bit 16
        PR16: u1 = 0,
        /// PR17 [17:17]
        /// Pending bit 17
        PR17: u1 = 0,
        /// PR18 [18:18]
        /// Pending bit 18
        PR18: u1 = 0,
        /// unused [19:31]
        _unused19: u5 = 0,
        _unused24: u8 = 0,
    };
    /// Pending register (EXTI_PR)
    pub const PR = Register(PR_val).init(base_address + 0x14);
};

/// DMA controller
pub const DMA1 = struct {
    const base_address = 0x40020000;
    /// ISR
    const ISR_val = packed struct {
        /// GIF1 [0:0]
        /// Channel 1 Global interrupt
        GIF1: u1 = 0,
        /// TCIF1 [1:1]
        /// Channel 1 Transfer Complete
        TCIF1: u1 = 0,
        /// HTIF1 [2:2]
        /// Channel 1 Half Transfer Complete
        HTIF1: u1 = 0,
        /// TEIF1 [3:3]
        /// Channel 1 Transfer Error
        TEIF1: u1 = 0,
        /// GIF2 [4:4]
        /// Channel 2 Global interrupt
        GIF2: u1 = 0,
        /// TCIF2 [5:5]
        /// Channel 2 Transfer Complete
        TCIF2: u1 = 0,
        /// HTIF2 [6:6]
        /// Channel 2 Half Transfer Complete
        HTIF2: u1 = 0,
        /// TEIF2 [7:7]
        /// Channel 2 Transfer Error
        TEIF2: u1 = 0,
        /// GIF3 [8:8]
        /// Channel 3 Global interrupt
        GIF3: u1 = 0,
        /// TCIF3 [9:9]
        /// Channel 3 Transfer Complete
        TCIF3: u1 = 0,
        /// HTIF3 [10:10]
        /// Channel 3 Half Transfer Complete
        HTIF3: u1 = 0,
        /// TEIF3 [11:11]
        /// Channel 3 Transfer Error
        TEIF3: u1 = 0,
        /// GIF4 [12:12]
        /// Channel 4 Global interrupt
        GIF4: u1 = 0,
        /// TCIF4 [13:13]
        /// Channel 4 Transfer Complete
        TCIF4: u1 = 0,
        /// HTIF4 [14:14]
        /// Channel 4 Half Transfer Complete
        HTIF4: u1 = 0,
        /// TEIF4 [15:15]
        /// Channel 4 Transfer Error
        TEIF4: u1 = 0,
        /// GIF5 [16:16]
        /// Channel 5 Global interrupt
        GIF5: u1 = 0,
        /// TCIF5 [17:17]
        /// Channel 5 Transfer Complete
        TCIF5: u1 = 0,
        /// HTIF5 [18:18]
        /// Channel 5 Half Transfer Complete
        HTIF5: u1 = 0,
        /// TEIF5 [19:19]
        /// Channel 5 Transfer Error
        TEIF5: u1 = 0,
        /// GIF6 [20:20]
        /// Channel 6 Global interrupt
        GIF6: u1 = 0,
        /// TCIF6 [21:21]
        /// Channel 6 Transfer Complete
        TCIF6: u1 = 0,
        /// HTIF6 [22:22]
        /// Channel 6 Half Transfer Complete
        HTIF6: u1 = 0,
        /// TEIF6 [23:23]
        /// Channel 6 Transfer Error
        TEIF6: u1 = 0,
        /// GIF7 [24:24]
        /// Channel 7 Global interrupt
        GIF7: u1 = 0,
        /// TCIF7 [25:25]
        /// Channel 7 Transfer Complete
        TCIF7: u1 = 0,
        /// HTIF7 [26:26]
        /// Channel 7 Half Transfer Complete
        HTIF7: u1 = 0,
        /// TEIF7 [27:27]
        /// Channel 7 Transfer Error
        TEIF7: u1 = 0,
        /// unused [28:31]
        _unused28: u4 = 0,
    };
    /// DMA interrupt status register
    pub const ISR = Register(ISR_val).init(base_address + 0x0);

    /// IFCR
    const IFCR_val = packed struct {
        /// CGIF1 [0:0]
        /// Channel 1 Global interrupt
        CGIF1: u1 = 0,
        /// CTCIF1 [1:1]
        /// Channel 1 Transfer Complete
        CTCIF1: u1 = 0,
        /// CHTIF1 [2:2]
        /// Channel 1 Half Transfer
        CHTIF1: u1 = 0,
        /// CTEIF1 [3:3]
        /// Channel 1 Transfer Error
        CTEIF1: u1 = 0,
        /// CGIF2 [4:4]
        /// Channel 2 Global interrupt
        CGIF2: u1 = 0,
        /// CTCIF2 [5:5]
        /// Channel 2 Transfer Complete
        CTCIF2: u1 = 0,
        /// CHTIF2 [6:6]
        /// Channel 2 Half Transfer
        CHTIF2: u1 = 0,
        /// CTEIF2 [7:7]
        /// Channel 2 Transfer Error
        CTEIF2: u1 = 0,
        /// CGIF3 [8:8]
        /// Channel 3 Global interrupt
        CGIF3: u1 = 0,
        /// CTCIF3 [9:9]
        /// Channel 3 Transfer Complete
        CTCIF3: u1 = 0,
        /// CHTIF3 [10:10]
        /// Channel 3 Half Transfer
        CHTIF3: u1 = 0,
        /// CTEIF3 [11:11]
        /// Channel 3 Transfer Error
        CTEIF3: u1 = 0,
        /// CGIF4 [12:12]
        /// Channel 4 Global interrupt
        CGIF4: u1 = 0,
        /// CTCIF4 [13:13]
        /// Channel 4 Transfer Complete
        CTCIF4: u1 = 0,
        /// CHTIF4 [14:14]
        /// Channel 4 Half Transfer
        CHTIF4: u1 = 0,
        /// CTEIF4 [15:15]
        /// Channel 4 Transfer Error
        CTEIF4: u1 = 0,
        /// CGIF5 [16:16]
        /// Channel 5 Global interrupt
        CGIF5: u1 = 0,
        /// CTCIF5 [17:17]
        /// Channel 5 Transfer Complete
        CTCIF5: u1 = 0,
        /// CHTIF5 [18:18]
        /// Channel 5 Half Transfer
        CHTIF5: u1 = 0,
        /// CTEIF5 [19:19]
        /// Channel 5 Transfer Error
        CTEIF5: u1 = 0,
        /// CGIF6 [20:20]
        /// Channel 6 Global interrupt
        CGIF6: u1 = 0,
        /// CTCIF6 [21:21]
        /// Channel 6 Transfer Complete
        CTCIF6: u1 = 0,
        /// CHTIF6 [22:22]
        /// Channel 6 Half Transfer
        CHTIF6: u1 = 0,
        /// CTEIF6 [23:23]
        /// Channel 6 Transfer Error
        CTEIF6: u1 = 0,
        /// CGIF7 [24:24]
        /// Channel 7 Global interrupt
        CGIF7: u1 = 0,
        /// CTCIF7 [25:25]
        /// Channel 7 Transfer Complete
        CTCIF7: u1 = 0,
        /// CHTIF7 [26:26]
        /// Channel 7 Half Transfer
        CHTIF7: u1 = 0,
        /// CTEIF7 [27:27]
        /// Channel 7 Transfer Error
        CTEIF7: u1 = 0,
        /// unused [28:31]
        _unused28: u4 = 0,
    };
    /// DMA interrupt flag clear register
    pub const IFCR = Register(IFCR_val).init(base_address + 0x4);

    /// CCR1
    const CCR1_val = packed struct {
        /// EN [0:0]
        /// Channel enable
        EN: u1 = 0,
        /// TCIE [1:1]
        /// Transfer complete interrupt
        TCIE: u1 = 0,
        /// HTIE [2:2]
        /// Half Transfer interrupt
        HTIE: u1 = 0,
        /// TEIE [3:3]
        /// Transfer error interrupt
        TEIE: u1 = 0,
        /// DIR [4:4]
        /// Data transfer direction
        DIR: u1 = 0,
        /// CIRC [5:5]
        /// Circular mode
        CIRC: u1 = 0,
        /// PINC [6:6]
        /// Peripheral increment mode
        PINC: u1 = 0,
        /// MINC [7:7]
        /// Memory increment mode
        MINC: u1 = 0,
        /// PSIZE [8:9]
        /// Peripheral size
        PSIZE: u2 = 0,
        /// MSIZE [10:11]
        /// Memory size
        MSIZE: u2 = 0,
        /// PL [12:13]
        /// Channel Priority level
        PL: u2 = 0,
        /// MEM2MEM [14:14]
        /// Memory to memory mode
        MEM2MEM: u1 = 0,
        /// unused [15:31]
        _unused15: u1 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// DMA channel configuration register
    pub const CCR1 = Register(CCR1_val).init(base_address + 0x8);

    /// CNDTR1
    const CNDTR1_val = packed struct {
        /// NDT [0:15]
        /// Number of data to transfer
        NDT: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// DMA channel 1 number of data
    pub const CNDTR1 = Register(CNDTR1_val).init(base_address + 0xc);

    /// CPAR1
    const CPAR1_val = packed struct {
        /// PA [0:31]
        /// Peripheral address
        PA: u32 = 0,
    };
    /// DMA channel 1 peripheral address
    pub const CPAR1 = Register(CPAR1_val).init(base_address + 0x10);

    /// CMAR1
    const CMAR1_val = packed struct {
        /// MA [0:31]
        /// Memory address
        MA: u32 = 0,
    };
    /// DMA channel 1 memory address
    pub const CMAR1 = Register(CMAR1_val).init(base_address + 0x14);

    /// CCR2
    const CCR2_val = packed struct {
        /// EN [0:0]
        /// Channel enable
        EN: u1 = 0,
        /// TCIE [1:1]
        /// Transfer complete interrupt
        TCIE: u1 = 0,
        /// HTIE [2:2]
        /// Half Transfer interrupt
        HTIE: u1 = 0,
        /// TEIE [3:3]
        /// Transfer error interrupt
        TEIE: u1 = 0,
        /// DIR [4:4]
        /// Data transfer direction
        DIR: u1 = 0,
        /// CIRC [5:5]
        /// Circular mode
        CIRC: u1 = 0,
        /// PINC [6:6]
        /// Peripheral increment mode
        PINC: u1 = 0,
        /// MINC [7:7]
        /// Memory increment mode
        MINC: u1 = 0,
        /// PSIZE [8:9]
        /// Peripheral size
        PSIZE: u2 = 0,
        /// MSIZE [10:11]
        /// Memory size
        MSIZE: u2 = 0,
        /// PL [12:13]
        /// Channel Priority level
        PL: u2 = 0,
        /// MEM2MEM [14:14]
        /// Memory to memory mode
        MEM2MEM: u1 = 0,
        /// unused [15:31]
        _unused15: u1 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// DMA channel configuration register
    pub const CCR2 = Register(CCR2_val).init(base_address + 0x1c);

    /// CNDTR2
    const CNDTR2_val = packed struct {
        /// NDT [0:15]
        /// Number of data to transfer
        NDT: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// DMA channel 2 number of data
    pub const CNDTR2 = Register(CNDTR2_val).init(base_address + 0x20);

    /// CPAR2
    const CPAR2_val = packed struct {
        /// PA [0:31]
        /// Peripheral address
        PA: u32 = 0,
    };
    /// DMA channel 2 peripheral address
    pub const CPAR2 = Register(CPAR2_val).init(base_address + 0x24);

    /// CMAR2
    const CMAR2_val = packed struct {
        /// MA [0:31]
        /// Memory address
        MA: u32 = 0,
    };
    /// DMA channel 2 memory address
    pub const CMAR2 = Register(CMAR2_val).init(base_address + 0x28);

    /// CCR3
    const CCR3_val = packed struct {
        /// EN [0:0]
        /// Channel enable
        EN: u1 = 0,
        /// TCIE [1:1]
        /// Transfer complete interrupt
        TCIE: u1 = 0,
        /// HTIE [2:2]
        /// Half Transfer interrupt
        HTIE: u1 = 0,
        /// TEIE [3:3]
        /// Transfer error interrupt
        TEIE: u1 = 0,
        /// DIR [4:4]
        /// Data transfer direction
        DIR: u1 = 0,
        /// CIRC [5:5]
        /// Circular mode
        CIRC: u1 = 0,
        /// PINC [6:6]
        /// Peripheral increment mode
        PINC: u1 = 0,
        /// MINC [7:7]
        /// Memory increment mode
        MINC: u1 = 0,
        /// PSIZE [8:9]
        /// Peripheral size
        PSIZE: u2 = 0,
        /// MSIZE [10:11]
        /// Memory size
        MSIZE: u2 = 0,
        /// PL [12:13]
        /// Channel Priority level
        PL: u2 = 0,
        /// MEM2MEM [14:14]
        /// Memory to memory mode
        MEM2MEM: u1 = 0,
        /// unused [15:31]
        _unused15: u1 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// DMA channel configuration register
    pub const CCR3 = Register(CCR3_val).init(base_address + 0x30);

    /// CNDTR3
    const CNDTR3_val = packed struct {
        /// NDT [0:15]
        /// Number of data to transfer
        NDT: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// DMA channel 3 number of data
    pub const CNDTR3 = Register(CNDTR3_val).init(base_address + 0x34);

    /// CPAR3
    const CPAR3_val = packed struct {
        /// PA [0:31]
        /// Peripheral address
        PA: u32 = 0,
    };
    /// DMA channel 3 peripheral address
    pub const CPAR3 = Register(CPAR3_val).init(base_address + 0x38);

    /// CMAR3
    const CMAR3_val = packed struct {
        /// MA [0:31]
        /// Memory address
        MA: u32 = 0,
    };
    /// DMA channel 3 memory address
    pub const CMAR3 = Register(CMAR3_val).init(base_address + 0x3c);

    /// CCR4
    const CCR4_val = packed struct {
        /// EN [0:0]
        /// Channel enable
        EN: u1 = 0,
        /// TCIE [1:1]
        /// Transfer complete interrupt
        TCIE: u1 = 0,
        /// HTIE [2:2]
        /// Half Transfer interrupt
        HTIE: u1 = 0,
        /// TEIE [3:3]
        /// Transfer error interrupt
        TEIE: u1 = 0,
        /// DIR [4:4]
        /// Data transfer direction
        DIR: u1 = 0,
        /// CIRC [5:5]
        /// Circular mode
        CIRC: u1 = 0,
        /// PINC [6:6]
        /// Peripheral increment mode
        PINC: u1 = 0,
        /// MINC [7:7]
        /// Memory increment mode
        MINC: u1 = 0,
        /// PSIZE [8:9]
        /// Peripheral size
        PSIZE: u2 = 0,
        /// MSIZE [10:11]
        /// Memory size
        MSIZE: u2 = 0,
        /// PL [12:13]
        /// Channel Priority level
        PL: u2 = 0,
        /// MEM2MEM [14:14]
        /// Memory to memory mode
        MEM2MEM: u1 = 0,
        /// unused [15:31]
        _unused15: u1 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// DMA channel configuration register
    pub const CCR4 = Register(CCR4_val).init(base_address + 0x44);

    /// CNDTR4
    const CNDTR4_val = packed struct {
        /// NDT [0:15]
        /// Number of data to transfer
        NDT: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// DMA channel 4 number of data
    pub const CNDTR4 = Register(CNDTR4_val).init(base_address + 0x48);

    /// CPAR4
    const CPAR4_val = packed struct {
        /// PA [0:31]
        /// Peripheral address
        PA: u32 = 0,
    };
    /// DMA channel 4 peripheral address
    pub const CPAR4 = Register(CPAR4_val).init(base_address + 0x4c);

    /// CMAR4
    const CMAR4_val = packed struct {
        /// MA [0:31]
        /// Memory address
        MA: u32 = 0,
    };
    /// DMA channel 4 memory address
    pub const CMAR4 = Register(CMAR4_val).init(base_address + 0x50);

    /// CCR5
    const CCR5_val = packed struct {
        /// EN [0:0]
        /// Channel enable
        EN: u1 = 0,
        /// TCIE [1:1]
        /// Transfer complete interrupt
        TCIE: u1 = 0,
        /// HTIE [2:2]
        /// Half Transfer interrupt
        HTIE: u1 = 0,
        /// TEIE [3:3]
        /// Transfer error interrupt
        TEIE: u1 = 0,
        /// DIR [4:4]
        /// Data transfer direction
        DIR: u1 = 0,
        /// CIRC [5:5]
        /// Circular mode
        CIRC: u1 = 0,
        /// PINC [6:6]
        /// Peripheral increment mode
        PINC: u1 = 0,
        /// MINC [7:7]
        /// Memory increment mode
        MINC: u1 = 0,
        /// PSIZE [8:9]
        /// Peripheral size
        PSIZE: u2 = 0,
        /// MSIZE [10:11]
        /// Memory size
        MSIZE: u2 = 0,
        /// PL [12:13]
        /// Channel Priority level
        PL: u2 = 0,
        /// MEM2MEM [14:14]
        /// Memory to memory mode
        MEM2MEM: u1 = 0,
        /// unused [15:31]
        _unused15: u1 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// DMA channel configuration register
    pub const CCR5 = Register(CCR5_val).init(base_address + 0x58);

    /// CNDTR5
    const CNDTR5_val = packed struct {
        /// NDT [0:15]
        /// Number of data to transfer
        NDT: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// DMA channel 5 number of data
    pub const CNDTR5 = Register(CNDTR5_val).init(base_address + 0x5c);

    /// CPAR5
    const CPAR5_val = packed struct {
        /// PA [0:31]
        /// Peripheral address
        PA: u32 = 0,
    };
    /// DMA channel 5 peripheral address
    pub const CPAR5 = Register(CPAR5_val).init(base_address + 0x60);

    /// CMAR5
    const CMAR5_val = packed struct {
        /// MA [0:31]
        /// Memory address
        MA: u32 = 0,
    };
    /// DMA channel 5 memory address
    pub const CMAR5 = Register(CMAR5_val).init(base_address + 0x64);

    /// CCR6
    const CCR6_val = packed struct {
        /// EN [0:0]
        /// Channel enable
        EN: u1 = 0,
        /// TCIE [1:1]
        /// Transfer complete interrupt
        TCIE: u1 = 0,
        /// HTIE [2:2]
        /// Half Transfer interrupt
        HTIE: u1 = 0,
        /// TEIE [3:3]
        /// Transfer error interrupt
        TEIE: u1 = 0,
        /// DIR [4:4]
        /// Data transfer direction
        DIR: u1 = 0,
        /// CIRC [5:5]
        /// Circular mode
        CIRC: u1 = 0,
        /// PINC [6:6]
        /// Peripheral increment mode
        PINC: u1 = 0,
        /// MINC [7:7]
        /// Memory increment mode
        MINC: u1 = 0,
        /// PSIZE [8:9]
        /// Peripheral size
        PSIZE: u2 = 0,
        /// MSIZE [10:11]
        /// Memory size
        MSIZE: u2 = 0,
        /// PL [12:13]
        /// Channel Priority level
        PL: u2 = 0,
        /// MEM2MEM [14:14]
        /// Memory to memory mode
        MEM2MEM: u1 = 0,
        /// unused [15:31]
        _unused15: u1 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// DMA channel configuration register
    pub const CCR6 = Register(CCR6_val).init(base_address + 0x6c);

    /// CNDTR6
    const CNDTR6_val = packed struct {
        /// NDT [0:15]
        /// Number of data to transfer
        NDT: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// DMA channel 6 number of data
    pub const CNDTR6 = Register(CNDTR6_val).init(base_address + 0x70);

    /// CPAR6
    const CPAR6_val = packed struct {
        /// PA [0:31]
        /// Peripheral address
        PA: u32 = 0,
    };
    /// DMA channel 6 peripheral address
    pub const CPAR6 = Register(CPAR6_val).init(base_address + 0x74);

    /// CMAR6
    const CMAR6_val = packed struct {
        /// MA [0:31]
        /// Memory address
        MA: u32 = 0,
    };
    /// DMA channel 6 memory address
    pub const CMAR6 = Register(CMAR6_val).init(base_address + 0x78);

    /// CCR7
    const CCR7_val = packed struct {
        /// EN [0:0]
        /// Channel enable
        EN: u1 = 0,
        /// TCIE [1:1]
        /// Transfer complete interrupt
        TCIE: u1 = 0,
        /// HTIE [2:2]
        /// Half Transfer interrupt
        HTIE: u1 = 0,
        /// TEIE [3:3]
        /// Transfer error interrupt
        TEIE: u1 = 0,
        /// DIR [4:4]
        /// Data transfer direction
        DIR: u1 = 0,
        /// CIRC [5:5]
        /// Circular mode
        CIRC: u1 = 0,
        /// PINC [6:6]
        /// Peripheral increment mode
        PINC: u1 = 0,
        /// MINC [7:7]
        /// Memory increment mode
        MINC: u1 = 0,
        /// PSIZE [8:9]
        /// Peripheral size
        PSIZE: u2 = 0,
        /// MSIZE [10:11]
        /// Memory size
        MSIZE: u2 = 0,
        /// PL [12:13]
        /// Channel Priority level
        PL: u2 = 0,
        /// MEM2MEM [14:14]
        /// Memory to memory mode
        MEM2MEM: u1 = 0,
        /// unused [15:31]
        _unused15: u1 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// DMA channel configuration register
    pub const CCR7 = Register(CCR7_val).init(base_address + 0x80);

    /// CNDTR7
    const CNDTR7_val = packed struct {
        /// NDT [0:15]
        /// Number of data to transfer
        NDT: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// DMA channel 7 number of data
    pub const CNDTR7 = Register(CNDTR7_val).init(base_address + 0x84);

    /// CPAR7
    const CPAR7_val = packed struct {
        /// PA [0:31]
        /// Peripheral address
        PA: u32 = 0,
    };
    /// DMA channel 7 peripheral address
    pub const CPAR7 = Register(CPAR7_val).init(base_address + 0x88);

    /// CMAR7
    const CMAR7_val = packed struct {
        /// MA [0:31]
        /// Memory address
        MA: u32 = 0,
    };
    /// DMA channel 7 memory address
    pub const CMAR7 = Register(CMAR7_val).init(base_address + 0x8c);
};

/// DMA controller
pub const DMA2 = struct {
    const base_address = 0x40020400;
    /// ISR
    const ISR_val = packed struct {
        /// GIF1 [0:0]
        /// Channel 1 Global interrupt
        GIF1: u1 = 0,
        /// TCIF1 [1:1]
        /// Channel 1 Transfer Complete
        TCIF1: u1 = 0,
        /// HTIF1 [2:2]
        /// Channel 1 Half Transfer Complete
        HTIF1: u1 = 0,
        /// TEIF1 [3:3]
        /// Channel 1 Transfer Error
        TEIF1: u1 = 0,
        /// GIF2 [4:4]
        /// Channel 2 Global interrupt
        GIF2: u1 = 0,
        /// TCIF2 [5:5]
        /// Channel 2 Transfer Complete
        TCIF2: u1 = 0,
        /// HTIF2 [6:6]
        /// Channel 2 Half Transfer Complete
        HTIF2: u1 = 0,
        /// TEIF2 [7:7]
        /// Channel 2 Transfer Error
        TEIF2: u1 = 0,
        /// GIF3 [8:8]
        /// Channel 3 Global interrupt
        GIF3: u1 = 0,
        /// TCIF3 [9:9]
        /// Channel 3 Transfer Complete
        TCIF3: u1 = 0,
        /// HTIF3 [10:10]
        /// Channel 3 Half Transfer Complete
        HTIF3: u1 = 0,
        /// TEIF3 [11:11]
        /// Channel 3 Transfer Error
        TEIF3: u1 = 0,
        /// GIF4 [12:12]
        /// Channel 4 Global interrupt
        GIF4: u1 = 0,
        /// TCIF4 [13:13]
        /// Channel 4 Transfer Complete
        TCIF4: u1 = 0,
        /// HTIF4 [14:14]
        /// Channel 4 Half Transfer Complete
        HTIF4: u1 = 0,
        /// TEIF4 [15:15]
        /// Channel 4 Transfer Error
        TEIF4: u1 = 0,
        /// GIF5 [16:16]
        /// Channel 5 Global interrupt
        GIF5: u1 = 0,
        /// TCIF5 [17:17]
        /// Channel 5 Transfer Complete
        TCIF5: u1 = 0,
        /// HTIF5 [18:18]
        /// Channel 5 Half Transfer Complete
        HTIF5: u1 = 0,
        /// TEIF5 [19:19]
        /// Channel 5 Transfer Error
        TEIF5: u1 = 0,
        /// GIF6 [20:20]
        /// Channel 6 Global interrupt
        GIF6: u1 = 0,
        /// TCIF6 [21:21]
        /// Channel 6 Transfer Complete
        TCIF6: u1 = 0,
        /// HTIF6 [22:22]
        /// Channel 6 Half Transfer Complete
        HTIF6: u1 = 0,
        /// TEIF6 [23:23]
        /// Channel 6 Transfer Error
        TEIF6: u1 = 0,
        /// GIF7 [24:24]
        /// Channel 7 Global interrupt
        GIF7: u1 = 0,
        /// TCIF7 [25:25]
        /// Channel 7 Transfer Complete
        TCIF7: u1 = 0,
        /// HTIF7 [26:26]
        /// Channel 7 Half Transfer Complete
        HTIF7: u1 = 0,
        /// TEIF7 [27:27]
        /// Channel 7 Transfer Error
        TEIF7: u1 = 0,
        /// unused [28:31]
        _unused28: u4 = 0,
    };
    /// DMA interrupt status register
    pub const ISR = Register(ISR_val).init(base_address + 0x0);

    /// IFCR
    const IFCR_val = packed struct {
        /// CGIF1 [0:0]
        /// Channel 1 Global interrupt
        CGIF1: u1 = 0,
        /// CTCIF1 [1:1]
        /// Channel 1 Transfer Complete
        CTCIF1: u1 = 0,
        /// CHTIF1 [2:2]
        /// Channel 1 Half Transfer
        CHTIF1: u1 = 0,
        /// CTEIF1 [3:3]
        /// Channel 1 Transfer Error
        CTEIF1: u1 = 0,
        /// CGIF2 [4:4]
        /// Channel 2 Global interrupt
        CGIF2: u1 = 0,
        /// CTCIF2 [5:5]
        /// Channel 2 Transfer Complete
        CTCIF2: u1 = 0,
        /// CHTIF2 [6:6]
        /// Channel 2 Half Transfer
        CHTIF2: u1 = 0,
        /// CTEIF2 [7:7]
        /// Channel 2 Transfer Error
        CTEIF2: u1 = 0,
        /// CGIF3 [8:8]
        /// Channel 3 Global interrupt
        CGIF3: u1 = 0,
        /// CTCIF3 [9:9]
        /// Channel 3 Transfer Complete
        CTCIF3: u1 = 0,
        /// CHTIF3 [10:10]
        /// Channel 3 Half Transfer
        CHTIF3: u1 = 0,
        /// CTEIF3 [11:11]
        /// Channel 3 Transfer Error
        CTEIF3: u1 = 0,
        /// CGIF4 [12:12]
        /// Channel 4 Global interrupt
        CGIF4: u1 = 0,
        /// CTCIF4 [13:13]
        /// Channel 4 Transfer Complete
        CTCIF4: u1 = 0,
        /// CHTIF4 [14:14]
        /// Channel 4 Half Transfer
        CHTIF4: u1 = 0,
        /// CTEIF4 [15:15]
        /// Channel 4 Transfer Error
        CTEIF4: u1 = 0,
        /// CGIF5 [16:16]
        /// Channel 5 Global interrupt
        CGIF5: u1 = 0,
        /// CTCIF5 [17:17]
        /// Channel 5 Transfer Complete
        CTCIF5: u1 = 0,
        /// CHTIF5 [18:18]
        /// Channel 5 Half Transfer
        CHTIF5: u1 = 0,
        /// CTEIF5 [19:19]
        /// Channel 5 Transfer Error
        CTEIF5: u1 = 0,
        /// CGIF6 [20:20]
        /// Channel 6 Global interrupt
        CGIF6: u1 = 0,
        /// CTCIF6 [21:21]
        /// Channel 6 Transfer Complete
        CTCIF6: u1 = 0,
        /// CHTIF6 [22:22]
        /// Channel 6 Half Transfer
        CHTIF6: u1 = 0,
        /// CTEIF6 [23:23]
        /// Channel 6 Transfer Error
        CTEIF6: u1 = 0,
        /// CGIF7 [24:24]
        /// Channel 7 Global interrupt
        CGIF7: u1 = 0,
        /// CTCIF7 [25:25]
        /// Channel 7 Transfer Complete
        CTCIF7: u1 = 0,
        /// CHTIF7 [26:26]
        /// Channel 7 Half Transfer
        CHTIF7: u1 = 0,
        /// CTEIF7 [27:27]
        /// Channel 7 Transfer Error
        CTEIF7: u1 = 0,
        /// unused [28:31]
        _unused28: u4 = 0,
    };
    /// DMA interrupt flag clear register
    pub const IFCR = Register(IFCR_val).init(base_address + 0x4);

    /// CCR1
    const CCR1_val = packed struct {
        /// EN [0:0]
        /// Channel enable
        EN: u1 = 0,
        /// TCIE [1:1]
        /// Transfer complete interrupt
        TCIE: u1 = 0,
        /// HTIE [2:2]
        /// Half Transfer interrupt
        HTIE: u1 = 0,
        /// TEIE [3:3]
        /// Transfer error interrupt
        TEIE: u1 = 0,
        /// DIR [4:4]
        /// Data transfer direction
        DIR: u1 = 0,
        /// CIRC [5:5]
        /// Circular mode
        CIRC: u1 = 0,
        /// PINC [6:6]
        /// Peripheral increment mode
        PINC: u1 = 0,
        /// MINC [7:7]
        /// Memory increment mode
        MINC: u1 = 0,
        /// PSIZE [8:9]
        /// Peripheral size
        PSIZE: u2 = 0,
        /// MSIZE [10:11]
        /// Memory size
        MSIZE: u2 = 0,
        /// PL [12:13]
        /// Channel Priority level
        PL: u2 = 0,
        /// MEM2MEM [14:14]
        /// Memory to memory mode
        MEM2MEM: u1 = 0,
        /// unused [15:31]
        _unused15: u1 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// DMA channel configuration register
    pub const CCR1 = Register(CCR1_val).init(base_address + 0x8);

    /// CNDTR1
    const CNDTR1_val = packed struct {
        /// NDT [0:15]
        /// Number of data to transfer
        NDT: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// DMA channel 1 number of data
    pub const CNDTR1 = Register(CNDTR1_val).init(base_address + 0xc);

    /// CPAR1
    const CPAR1_val = packed struct {
        /// PA [0:31]
        /// Peripheral address
        PA: u32 = 0,
    };
    /// DMA channel 1 peripheral address
    pub const CPAR1 = Register(CPAR1_val).init(base_address + 0x10);

    /// CMAR1
    const CMAR1_val = packed struct {
        /// MA [0:31]
        /// Memory address
        MA: u32 = 0,
    };
    /// DMA channel 1 memory address
    pub const CMAR1 = Register(CMAR1_val).init(base_address + 0x14);

    /// CCR2
    const CCR2_val = packed struct {
        /// EN [0:0]
        /// Channel enable
        EN: u1 = 0,
        /// TCIE [1:1]
        /// Transfer complete interrupt
        TCIE: u1 = 0,
        /// HTIE [2:2]
        /// Half Transfer interrupt
        HTIE: u1 = 0,
        /// TEIE [3:3]
        /// Transfer error interrupt
        TEIE: u1 = 0,
        /// DIR [4:4]
        /// Data transfer direction
        DIR: u1 = 0,
        /// CIRC [5:5]
        /// Circular mode
        CIRC: u1 = 0,
        /// PINC [6:6]
        /// Peripheral increment mode
        PINC: u1 = 0,
        /// MINC [7:7]
        /// Memory increment mode
        MINC: u1 = 0,
        /// PSIZE [8:9]
        /// Peripheral size
        PSIZE: u2 = 0,
        /// MSIZE [10:11]
        /// Memory size
        MSIZE: u2 = 0,
        /// PL [12:13]
        /// Channel Priority level
        PL: u2 = 0,
        /// MEM2MEM [14:14]
        /// Memory to memory mode
        MEM2MEM: u1 = 0,
        /// unused [15:31]
        _unused15: u1 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// DMA channel configuration register
    pub const CCR2 = Register(CCR2_val).init(base_address + 0x1c);

    /// CNDTR2
    const CNDTR2_val = packed struct {
        /// NDT [0:15]
        /// Number of data to transfer
        NDT: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// DMA channel 2 number of data
    pub const CNDTR2 = Register(CNDTR2_val).init(base_address + 0x20);

    /// CPAR2
    const CPAR2_val = packed struct {
        /// PA [0:31]
        /// Peripheral address
        PA: u32 = 0,
    };
    /// DMA channel 2 peripheral address
    pub const CPAR2 = Register(CPAR2_val).init(base_address + 0x24);

    /// CMAR2
    const CMAR2_val = packed struct {
        /// MA [0:31]
        /// Memory address
        MA: u32 = 0,
    };
    /// DMA channel 2 memory address
    pub const CMAR2 = Register(CMAR2_val).init(base_address + 0x28);

    /// CCR3
    const CCR3_val = packed struct {
        /// EN [0:0]
        /// Channel enable
        EN: u1 = 0,
        /// TCIE [1:1]
        /// Transfer complete interrupt
        TCIE: u1 = 0,
        /// HTIE [2:2]
        /// Half Transfer interrupt
        HTIE: u1 = 0,
        /// TEIE [3:3]
        /// Transfer error interrupt
        TEIE: u1 = 0,
        /// DIR [4:4]
        /// Data transfer direction
        DIR: u1 = 0,
        /// CIRC [5:5]
        /// Circular mode
        CIRC: u1 = 0,
        /// PINC [6:6]
        /// Peripheral increment mode
        PINC: u1 = 0,
        /// MINC [7:7]
        /// Memory increment mode
        MINC: u1 = 0,
        /// PSIZE [8:9]
        /// Peripheral size
        PSIZE: u2 = 0,
        /// MSIZE [10:11]
        /// Memory size
        MSIZE: u2 = 0,
        /// PL [12:13]
        /// Channel Priority level
        PL: u2 = 0,
        /// MEM2MEM [14:14]
        /// Memory to memory mode
        MEM2MEM: u1 = 0,
        /// unused [15:31]
        _unused15: u1 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// DMA channel configuration register
    pub const CCR3 = Register(CCR3_val).init(base_address + 0x30);

    /// CNDTR3
    const CNDTR3_val = packed struct {
        /// NDT [0:15]
        /// Number of data to transfer
        NDT: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// DMA channel 3 number of data
    pub const CNDTR3 = Register(CNDTR3_val).init(base_address + 0x34);

    /// CPAR3
    const CPAR3_val = packed struct {
        /// PA [0:31]
        /// Peripheral address
        PA: u32 = 0,
    };
    /// DMA channel 3 peripheral address
    pub const CPAR3 = Register(CPAR3_val).init(base_address + 0x38);

    /// CMAR3
    const CMAR3_val = packed struct {
        /// MA [0:31]
        /// Memory address
        MA: u32 = 0,
    };
    /// DMA channel 3 memory address
    pub const CMAR3 = Register(CMAR3_val).init(base_address + 0x3c);

    /// CCR4
    const CCR4_val = packed struct {
        /// EN [0:0]
        /// Channel enable
        EN: u1 = 0,
        /// TCIE [1:1]
        /// Transfer complete interrupt
        TCIE: u1 = 0,
        /// HTIE [2:2]
        /// Half Transfer interrupt
        HTIE: u1 = 0,
        /// TEIE [3:3]
        /// Transfer error interrupt
        TEIE: u1 = 0,
        /// DIR [4:4]
        /// Data transfer direction
        DIR: u1 = 0,
        /// CIRC [5:5]
        /// Circular mode
        CIRC: u1 = 0,
        /// PINC [6:6]
        /// Peripheral increment mode
        PINC: u1 = 0,
        /// MINC [7:7]
        /// Memory increment mode
        MINC: u1 = 0,
        /// PSIZE [8:9]
        /// Peripheral size
        PSIZE: u2 = 0,
        /// MSIZE [10:11]
        /// Memory size
        MSIZE: u2 = 0,
        /// PL [12:13]
        /// Channel Priority level
        PL: u2 = 0,
        /// MEM2MEM [14:14]
        /// Memory to memory mode
        MEM2MEM: u1 = 0,
        /// unused [15:31]
        _unused15: u1 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// DMA channel configuration register
    pub const CCR4 = Register(CCR4_val).init(base_address + 0x44);

    /// CNDTR4
    const CNDTR4_val = packed struct {
        /// NDT [0:15]
        /// Number of data to transfer
        NDT: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// DMA channel 4 number of data
    pub const CNDTR4 = Register(CNDTR4_val).init(base_address + 0x48);

    /// CPAR4
    const CPAR4_val = packed struct {
        /// PA [0:31]
        /// Peripheral address
        PA: u32 = 0,
    };
    /// DMA channel 4 peripheral address
    pub const CPAR4 = Register(CPAR4_val).init(base_address + 0x4c);

    /// CMAR4
    const CMAR4_val = packed struct {
        /// MA [0:31]
        /// Memory address
        MA: u32 = 0,
    };
    /// DMA channel 4 memory address
    pub const CMAR4 = Register(CMAR4_val).init(base_address + 0x50);

    /// CCR5
    const CCR5_val = packed struct {
        /// EN [0:0]
        /// Channel enable
        EN: u1 = 0,
        /// TCIE [1:1]
        /// Transfer complete interrupt
        TCIE: u1 = 0,
        /// HTIE [2:2]
        /// Half Transfer interrupt
        HTIE: u1 = 0,
        /// TEIE [3:3]
        /// Transfer error interrupt
        TEIE: u1 = 0,
        /// DIR [4:4]
        /// Data transfer direction
        DIR: u1 = 0,
        /// CIRC [5:5]
        /// Circular mode
        CIRC: u1 = 0,
        /// PINC [6:6]
        /// Peripheral increment mode
        PINC: u1 = 0,
        /// MINC [7:7]
        /// Memory increment mode
        MINC: u1 = 0,
        /// PSIZE [8:9]
        /// Peripheral size
        PSIZE: u2 = 0,
        /// MSIZE [10:11]
        /// Memory size
        MSIZE: u2 = 0,
        /// PL [12:13]
        /// Channel Priority level
        PL: u2 = 0,
        /// MEM2MEM [14:14]
        /// Memory to memory mode
        MEM2MEM: u1 = 0,
        /// unused [15:31]
        _unused15: u1 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// DMA channel configuration register
    pub const CCR5 = Register(CCR5_val).init(base_address + 0x58);

    /// CNDTR5
    const CNDTR5_val = packed struct {
        /// NDT [0:15]
        /// Number of data to transfer
        NDT: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// DMA channel 5 number of data
    pub const CNDTR5 = Register(CNDTR5_val).init(base_address + 0x5c);

    /// CPAR5
    const CPAR5_val = packed struct {
        /// PA [0:31]
        /// Peripheral address
        PA: u32 = 0,
    };
    /// DMA channel 5 peripheral address
    pub const CPAR5 = Register(CPAR5_val).init(base_address + 0x60);

    /// CMAR5
    const CMAR5_val = packed struct {
        /// MA [0:31]
        /// Memory address
        MA: u32 = 0,
    };
    /// DMA channel 5 memory address
    pub const CMAR5 = Register(CMAR5_val).init(base_address + 0x64);

    /// CCR6
    const CCR6_val = packed struct {
        /// EN [0:0]
        /// Channel enable
        EN: u1 = 0,
        /// TCIE [1:1]
        /// Transfer complete interrupt
        TCIE: u1 = 0,
        /// HTIE [2:2]
        /// Half Transfer interrupt
        HTIE: u1 = 0,
        /// TEIE [3:3]
        /// Transfer error interrupt
        TEIE: u1 = 0,
        /// DIR [4:4]
        /// Data transfer direction
        DIR: u1 = 0,
        /// CIRC [5:5]
        /// Circular mode
        CIRC: u1 = 0,
        /// PINC [6:6]
        /// Peripheral increment mode
        PINC: u1 = 0,
        /// MINC [7:7]
        /// Memory increment mode
        MINC: u1 = 0,
        /// PSIZE [8:9]
        /// Peripheral size
        PSIZE: u2 = 0,
        /// MSIZE [10:11]
        /// Memory size
        MSIZE: u2 = 0,
        /// PL [12:13]
        /// Channel Priority level
        PL: u2 = 0,
        /// MEM2MEM [14:14]
        /// Memory to memory mode
        MEM2MEM: u1 = 0,
        /// unused [15:31]
        _unused15: u1 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// DMA channel configuration register
    pub const CCR6 = Register(CCR6_val).init(base_address + 0x6c);

    /// CNDTR6
    const CNDTR6_val = packed struct {
        /// NDT [0:15]
        /// Number of data to transfer
        NDT: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// DMA channel 6 number of data
    pub const CNDTR6 = Register(CNDTR6_val).init(base_address + 0x70);

    /// CPAR6
    const CPAR6_val = packed struct {
        /// PA [0:31]
        /// Peripheral address
        PA: u32 = 0,
    };
    /// DMA channel 6 peripheral address
    pub const CPAR6 = Register(CPAR6_val).init(base_address + 0x74);

    /// CMAR6
    const CMAR6_val = packed struct {
        /// MA [0:31]
        /// Memory address
        MA: u32 = 0,
    };
    /// DMA channel 6 memory address
    pub const CMAR6 = Register(CMAR6_val).init(base_address + 0x78);

    /// CCR7
    const CCR7_val = packed struct {
        /// EN [0:0]
        /// Channel enable
        EN: u1 = 0,
        /// TCIE [1:1]
        /// Transfer complete interrupt
        TCIE: u1 = 0,
        /// HTIE [2:2]
        /// Half Transfer interrupt
        HTIE: u1 = 0,
        /// TEIE [3:3]
        /// Transfer error interrupt
        TEIE: u1 = 0,
        /// DIR [4:4]
        /// Data transfer direction
        DIR: u1 = 0,
        /// CIRC [5:5]
        /// Circular mode
        CIRC: u1 = 0,
        /// PINC [6:6]
        /// Peripheral increment mode
        PINC: u1 = 0,
        /// MINC [7:7]
        /// Memory increment mode
        MINC: u1 = 0,
        /// PSIZE [8:9]
        /// Peripheral size
        PSIZE: u2 = 0,
        /// MSIZE [10:11]
        /// Memory size
        MSIZE: u2 = 0,
        /// PL [12:13]
        /// Channel Priority level
        PL: u2 = 0,
        /// MEM2MEM [14:14]
        /// Memory to memory mode
        MEM2MEM: u1 = 0,
        /// unused [15:31]
        _unused15: u1 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// DMA channel configuration register
    pub const CCR7 = Register(CCR7_val).init(base_address + 0x80);

    /// CNDTR7
    const CNDTR7_val = packed struct {
        /// NDT [0:15]
        /// Number of data to transfer
        NDT: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// DMA channel 7 number of data
    pub const CNDTR7 = Register(CNDTR7_val).init(base_address + 0x84);

    /// CPAR7
    const CPAR7_val = packed struct {
        /// PA [0:31]
        /// Peripheral address
        PA: u32 = 0,
    };
    /// DMA channel 7 peripheral address
    pub const CPAR7 = Register(CPAR7_val).init(base_address + 0x88);

    /// CMAR7
    const CMAR7_val = packed struct {
        /// MA [0:31]
        /// Memory address
        MA: u32 = 0,
    };
    /// DMA channel 7 memory address
    pub const CMAR7 = Register(CMAR7_val).init(base_address + 0x8c);
};

/// Secure digital input/output
pub const SDIO = struct {
    const base_address = 0x40018000;
    /// POWER
    const POWER_val = packed struct {
        /// PWRCTRL [0:1]
        /// PWRCTRL
        PWRCTRL: u2 = 0,
        /// unused [2:31]
        _unused2: u6 = 0,
        _unused8: u8 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Bits 1:0 = PWRCTRL: Power supply control
    pub const POWER = Register(POWER_val).init(base_address + 0x0);

    /// CLKCR
    const CLKCR_val = packed struct {
        /// CLKDIV [0:7]
        /// Clock divide factor
        CLKDIV: u8 = 0,
        /// CLKEN [8:8]
        /// Clock enable bit
        CLKEN: u1 = 0,
        /// PWRSAV [9:9]
        /// Power saving configuration
        PWRSAV: u1 = 0,
        /// BYPASS [10:10]
        /// Clock divider bypass enable
        BYPASS: u1 = 0,
        /// WIDBUS [11:12]
        /// Wide bus mode enable bit
        WIDBUS: u2 = 0,
        /// NEGEDGE [13:13]
        /// SDIO_CK dephasing selection
        NEGEDGE: u1 = 0,
        /// HWFC_EN [14:14]
        /// HW Flow Control enable
        HWFC_EN: u1 = 0,
        /// unused [15:31]
        _unused15: u1 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// SDI clock control register
    pub const CLKCR = Register(CLKCR_val).init(base_address + 0x4);

    /// ARG
    const ARG_val = packed struct {
        /// CMDARG [0:31]
        /// Command argument
        CMDARG: u32 = 0,
    };
    /// Bits 31:0 = : Command argument
    pub const ARG = Register(ARG_val).init(base_address + 0x8);

    /// CMD
    const CMD_val = packed struct {
        /// CMDINDEX [0:5]
        /// CMDINDEX
        CMDINDEX: u6 = 0,
        /// WAITRESP [6:7]
        /// WAITRESP
        WAITRESP: u2 = 0,
        /// WAITINT [8:8]
        /// WAITINT
        WAITINT: u1 = 0,
        /// WAITPEND [9:9]
        /// WAITPEND
        WAITPEND: u1 = 0,
        /// CPSMEN [10:10]
        /// CPSMEN
        CPSMEN: u1 = 0,
        /// SDIOSuspend [11:11]
        /// SDIOSuspend
        SDIOSuspend: u1 = 0,
        /// ENCMDcompl [12:12]
        /// ENCMDcompl
        ENCMDcompl: u1 = 0,
        /// nIEN [13:13]
        /// nIEN
        nIEN: u1 = 0,
        /// CE_ATACMD [14:14]
        /// CE_ATACMD
        CE_ATACMD: u1 = 0,
        /// unused [15:31]
        _unused15: u1 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// SDIO command register
    pub const CMD = Register(CMD_val).init(base_address + 0xc);

    /// RESPCMD
    const RESPCMD_val = packed struct {
        /// RESPCMD [0:5]
        /// RESPCMD
        RESPCMD: u6 = 0,
        /// unused [6:31]
        _unused6: u2 = 0,
        _unused8: u8 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// SDIO command register
    pub const RESPCMD = Register(RESPCMD_val).init(base_address + 0x10);

    /// RESPI1
    const RESPI1_val = packed struct {
        /// CARDSTATUS1 [0:31]
        /// CARDSTATUS1
        CARDSTATUS1: u32 = 0,
    };
    /// Bits 31:0 = CARDSTATUS1
    pub const RESPI1 = Register(RESPI1_val).init(base_address + 0x14);

    /// RESP2
    const RESP2_val = packed struct {
        /// CARDSTATUS2 [0:31]
        /// CARDSTATUS2
        CARDSTATUS2: u32 = 0,
    };
    /// Bits 31:0 = CARDSTATUS2
    pub const RESP2 = Register(RESP2_val).init(base_address + 0x18);

    /// RESP3
    const RESP3_val = packed struct {
        /// CARDSTATUS3 [0:31]
        /// CARDSTATUS3
        CARDSTATUS3: u32 = 0,
    };
    /// Bits 31:0 = CARDSTATUS3
    pub const RESP3 = Register(RESP3_val).init(base_address + 0x1c);

    /// RESP4
    const RESP4_val = packed struct {
        /// CARDSTATUS4 [0:31]
        /// CARDSTATUS4
        CARDSTATUS4: u32 = 0,
    };
    /// Bits 31:0 = CARDSTATUS4
    pub const RESP4 = Register(RESP4_val).init(base_address + 0x20);

    /// DTIMER
    const DTIMER_val = packed struct {
        /// DATATIME [0:31]
        /// Data timeout period
        DATATIME: u32 = 0,
    };
    /// Bits 31:0 = DATATIME: Data timeout
    pub const DTIMER = Register(DTIMER_val).init(base_address + 0x24);

    /// DLEN
    const DLEN_val = packed struct {
        /// DATALENGTH [0:24]
        /// Data length value
        DATALENGTH: u25 = 0,
        /// unused [25:31]
        _unused25: u7 = 0,
    };
    /// Bits 24:0 = DATALENGTH: Data length
    pub const DLEN = Register(DLEN_val).init(base_address + 0x28);

    /// DCTRL
    const DCTRL_val = packed struct {
        /// DTEN [0:0]
        /// DTEN
        DTEN: u1 = 0,
        /// DTDIR [1:1]
        /// DTDIR
        DTDIR: u1 = 0,
        /// DTMODE [2:2]
        /// DTMODE
        DTMODE: u1 = 0,
        /// DMAEN [3:3]
        /// DMAEN
        DMAEN: u1 = 0,
        /// DBLOCKSIZE [4:7]
        /// DBLOCKSIZE
        DBLOCKSIZE: u4 = 0,
        /// PWSTART [8:8]
        /// PWSTART
        PWSTART: u1 = 0,
        /// PWSTOP [9:9]
        /// PWSTOP
        PWSTOP: u1 = 0,
        /// RWMOD [10:10]
        /// RWMOD
        RWMOD: u1 = 0,
        /// SDIOEN [11:11]
        /// SDIOEN
        SDIOEN: u1 = 0,
        /// unused [12:31]
        _unused12: u4 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// SDIO data control register
    pub const DCTRL = Register(DCTRL_val).init(base_address + 0x2c);

    /// DCOUNT
    const DCOUNT_val = packed struct {
        /// DATACOUNT [0:24]
        /// Data count value
        DATACOUNT: u25 = 0,
        /// unused [25:31]
        _unused25: u7 = 0,
    };
    /// Bits 24:0 = DATACOUNT: Data count
    pub const DCOUNT = Register(DCOUNT_val).init(base_address + 0x30);

    /// STA
    const STA_val = packed struct {
        /// CCRCFAIL [0:0]
        /// CCRCFAIL
        CCRCFAIL: u1 = 0,
        /// DCRCFAIL [1:1]
        /// DCRCFAIL
        DCRCFAIL: u1 = 0,
        /// CTIMEOUT [2:2]
        /// CTIMEOUT
        CTIMEOUT: u1 = 0,
        /// DTIMEOUT [3:3]
        /// DTIMEOUT
        DTIMEOUT: u1 = 0,
        /// TXUNDERR [4:4]
        /// TXUNDERR
        TXUNDERR: u1 = 0,
        /// RXOVERR [5:5]
        /// RXOVERR
        RXOVERR: u1 = 0,
        /// CMDREND [6:6]
        /// CMDREND
        CMDREND: u1 = 0,
        /// CMDSENT [7:7]
        /// CMDSENT
        CMDSENT: u1 = 0,
        /// DATAEND [8:8]
        /// DATAEND
        DATAEND: u1 = 0,
        /// STBITERR [9:9]
        /// STBITERR
        STBITERR: u1 = 0,
        /// DBCKEND [10:10]
        /// DBCKEND
        DBCKEND: u1 = 0,
        /// CMDACT [11:11]
        /// CMDACT
        CMDACT: u1 = 0,
        /// TXACT [12:12]
        /// TXACT
        TXACT: u1 = 0,
        /// RXACT [13:13]
        /// RXACT
        RXACT: u1 = 0,
        /// TXFIFOHE [14:14]
        /// TXFIFOHE
        TXFIFOHE: u1 = 0,
        /// RXFIFOHF [15:15]
        /// RXFIFOHF
        RXFIFOHF: u1 = 0,
        /// TXFIFOF [16:16]
        /// TXFIFOF
        TXFIFOF: u1 = 0,
        /// RXFIFOF [17:17]
        /// RXFIFOF
        RXFIFOF: u1 = 0,
        /// TXFIFOE [18:18]
        /// TXFIFOE
        TXFIFOE: u1 = 0,
        /// RXFIFOE [19:19]
        /// RXFIFOE
        RXFIFOE: u1 = 0,
        /// TXDAVL [20:20]
        /// TXDAVL
        TXDAVL: u1 = 0,
        /// RXDAVL [21:21]
        /// RXDAVL
        RXDAVL: u1 = 0,
        /// SDIOIT [22:22]
        /// SDIOIT
        SDIOIT: u1 = 0,
        /// CEATAEND [23:23]
        /// CEATAEND
        CEATAEND: u1 = 0,
        /// unused [24:31]
        _unused24: u8 = 0,
    };
    /// SDIO status register
    pub const STA = Register(STA_val).init(base_address + 0x34);

    /// ICR
    const ICR_val = packed struct {
        /// CCRCFAILC [0:0]
        /// CCRCFAILC
        CCRCFAILC: u1 = 0,
        /// DCRCFAILC [1:1]
        /// DCRCFAILC
        DCRCFAILC: u1 = 0,
        /// CTIMEOUTC [2:2]
        /// CTIMEOUTC
        CTIMEOUTC: u1 = 0,
        /// DTIMEOUTC [3:3]
        /// DTIMEOUTC
        DTIMEOUTC: u1 = 0,
        /// TXUNDERRC [4:4]
        /// TXUNDERRC
        TXUNDERRC: u1 = 0,
        /// RXOVERRC [5:5]
        /// RXOVERRC
        RXOVERRC: u1 = 0,
        /// CMDRENDC [6:6]
        /// CMDRENDC
        CMDRENDC: u1 = 0,
        /// CMDSENTC [7:7]
        /// CMDSENTC
        CMDSENTC: u1 = 0,
        /// DATAENDC [8:8]
        /// DATAENDC
        DATAENDC: u1 = 0,
        /// STBITERRC [9:9]
        /// STBITERRC
        STBITERRC: u1 = 0,
        /// DBCKENDC [10:10]
        /// DBCKENDC
        DBCKENDC: u1 = 0,
        /// unused [11:21]
        _unused11: u5 = 0,
        _unused16: u6 = 0,
        /// SDIOITC [22:22]
        /// SDIOITC
        SDIOITC: u1 = 0,
        /// CEATAENDC [23:23]
        /// CEATAENDC
        CEATAENDC: u1 = 0,
        /// unused [24:31]
        _unused24: u8 = 0,
    };
    /// SDIO interrupt clear register
    pub const ICR = Register(ICR_val).init(base_address + 0x38);

    /// MASK
    const MASK_val = packed struct {
        /// CCRCFAILIE [0:0]
        /// CCRCFAILIE
        CCRCFAILIE: u1 = 0,
        /// DCRCFAILIE [1:1]
        /// DCRCFAILIE
        DCRCFAILIE: u1 = 0,
        /// CTIMEOUTIE [2:2]
        /// CTIMEOUTIE
        CTIMEOUTIE: u1 = 0,
        /// DTIMEOUTIE [3:3]
        /// DTIMEOUTIE
        DTIMEOUTIE: u1 = 0,
        /// TXUNDERRIE [4:4]
        /// TXUNDERRIE
        TXUNDERRIE: u1 = 0,
        /// RXOVERRIE [5:5]
        /// RXOVERRIE
        RXOVERRIE: u1 = 0,
        /// CMDRENDIE [6:6]
        /// CMDRENDIE
        CMDRENDIE: u1 = 0,
        /// CMDSENTIE [7:7]
        /// CMDSENTIE
        CMDSENTIE: u1 = 0,
        /// DATAENDIE [8:8]
        /// DATAENDIE
        DATAENDIE: u1 = 0,
        /// STBITERRIE [9:9]
        /// STBITERRIE
        STBITERRIE: u1 = 0,
        /// DBACKENDIE [10:10]
        /// DBACKENDIE
        DBACKENDIE: u1 = 0,
        /// CMDACTIE [11:11]
        /// CMDACTIE
        CMDACTIE: u1 = 0,
        /// TXACTIE [12:12]
        /// TXACTIE
        TXACTIE: u1 = 0,
        /// RXACTIE [13:13]
        /// RXACTIE
        RXACTIE: u1 = 0,
        /// TXFIFOHEIE [14:14]
        /// TXFIFOHEIE
        TXFIFOHEIE: u1 = 0,
        /// RXFIFOHFIE [15:15]
        /// RXFIFOHFIE
        RXFIFOHFIE: u1 = 0,
        /// TXFIFOFIE [16:16]
        /// TXFIFOFIE
        TXFIFOFIE: u1 = 0,
        /// RXFIFOFIE [17:17]
        /// RXFIFOFIE
        RXFIFOFIE: u1 = 0,
        /// TXFIFOEIE [18:18]
        /// TXFIFOEIE
        TXFIFOEIE: u1 = 0,
        /// RXFIFOEIE [19:19]
        /// RXFIFOEIE
        RXFIFOEIE: u1 = 0,
        /// TXDAVLIE [20:20]
        /// TXDAVLIE
        TXDAVLIE: u1 = 0,
        /// RXDAVLIE [21:21]
        /// RXDAVLIE
        RXDAVLIE: u1 = 0,
        /// SDIOITIE [22:22]
        /// SDIOITIE
        SDIOITIE: u1 = 0,
        /// CEATENDIE [23:23]
        /// CEATENDIE
        CEATENDIE: u1 = 0,
        /// unused [24:31]
        _unused24: u8 = 0,
    };
    /// SDIO mask register (SDIO_MASK)
    pub const MASK = Register(MASK_val).init(base_address + 0x3c);

    /// FIFOCNT
    const FIFOCNT_val = packed struct {
        /// FIF0COUNT [0:23]
        /// FIF0COUNT
        FIF0COUNT: u24 = 0,
        /// unused [24:31]
        _unused24: u8 = 0,
    };
    /// Bits 23:0 = FIFOCOUNT: Remaining number of
    pub const FIFOCNT = Register(FIFOCNT_val).init(base_address + 0x48);

    /// FIFO
    const FIFO_val = packed struct {
        /// FIFOData [0:31]
        /// FIFOData
        FIFOData: u32 = 0,
    };
    /// bits 31:0 = FIFOData: Receive and transmit
    pub const FIFO = Register(FIFO_val).init(base_address + 0x80);
};

/// Real time clock
pub const RTC = struct {
    const base_address = 0x40002800;
    /// CRH
    const CRH_val = packed struct {
        /// SECIE [0:0]
        /// Second interrupt Enable
        SECIE: u1 = 0,
        /// ALRIE [1:1]
        /// Alarm interrupt Enable
        ALRIE: u1 = 0,
        /// OWIE [2:2]
        /// Overflow interrupt Enable
        OWIE: u1 = 0,
        /// unused [3:31]
        _unused3: u5 = 0,
        _unused8: u8 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// RTC Control Register High
    pub const CRH = Register(CRH_val).init(base_address + 0x0);

    /// CRL
    const CRL_val = packed struct {
        /// SECF [0:0]
        /// Second Flag
        SECF: u1 = 0,
        /// ALRF [1:1]
        /// Alarm Flag
        ALRF: u1 = 0,
        /// OWF [2:2]
        /// Overflow Flag
        OWF: u1 = 0,
        /// RSF [3:3]
        /// Registers Synchronized
        RSF: u1 = 0,
        /// CNF [4:4]
        /// Configuration Flag
        CNF: u1 = 0,
        /// RTOFF [5:5]
        /// RTC operation OFF
        RTOFF: u1 = 1,
        /// unused [6:31]
        _unused6: u2 = 0,
        _unused8: u8 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// RTC Control Register Low
    pub const CRL = Register(CRL_val).init(base_address + 0x4);

    /// PRLH
    const PRLH_val = packed struct {
        /// PRLH [0:3]
        /// RTC Prescaler Load Register
        PRLH: u4 = 0,
        /// unused [4:31]
        _unused4: u4 = 0,
        _unused8: u8 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// RTC Prescaler Load Register
    pub const PRLH = Register(PRLH_val).init(base_address + 0x8);

    /// PRLL
    const PRLL_val = packed struct {
        /// PRLL [0:15]
        /// RTC Prescaler Divider Register
        PRLL: u16 = 32768,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// RTC Prescaler Load Register
    pub const PRLL = Register(PRLL_val).init(base_address + 0xc);

    /// DIVH
    const DIVH_val = packed struct {
        /// DIVH [0:3]
        /// RTC prescaler divider register
        DIVH: u4 = 0,
        /// unused [4:31]
        _unused4: u4 = 0,
        _unused8: u8 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// RTC Prescaler Divider Register
    pub const DIVH = Register(DIVH_val).init(base_address + 0x10);

    /// DIVL
    const DIVL_val = packed struct {
        /// DIVL [0:15]
        /// RTC prescaler divider register
        DIVL: u16 = 32768,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// RTC Prescaler Divider Register
    pub const DIVL = Register(DIVL_val).init(base_address + 0x14);

    /// CNTH
    const CNTH_val = packed struct {
        /// CNTH [0:15]
        /// RTC counter register high
        CNTH: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// RTC Counter Register High
    pub const CNTH = Register(CNTH_val).init(base_address + 0x18);

    /// CNTL
    const CNTL_val = packed struct {
        /// CNTL [0:15]
        /// RTC counter register Low
        CNTL: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// RTC Counter Register Low
    pub const CNTL = Register(CNTL_val).init(base_address + 0x1c);

    /// ALRH
    const ALRH_val = packed struct {
        /// ALRH [0:15]
        /// RTC alarm register high
        ALRH: u16 = 65535,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// RTC Alarm Register High
    pub const ALRH = Register(ALRH_val).init(base_address + 0x20);

    /// ALRL
    const ALRL_val = packed struct {
        /// ALRL [0:15]
        /// RTC alarm register low
        ALRL: u16 = 65535,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// RTC Alarm Register Low
    pub const ALRL = Register(ALRL_val).init(base_address + 0x24);
};

/// Backup registers
pub const BKP = struct {
    const base_address = 0x40006c04;
    /// DR1
    const DR1_val = packed struct {
        /// D1 [0:15]
        /// Backup data
        D1: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Backup data register (BKP_DR)
    pub const DR1 = Register(DR1_val).init(base_address + 0x0);

    /// DR2
    const DR2_val = packed struct {
        /// D2 [0:15]
        /// Backup data
        D2: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Backup data register (BKP_DR)
    pub const DR2 = Register(DR2_val).init(base_address + 0x4);

    /// DR3
    const DR3_val = packed struct {
        /// D3 [0:15]
        /// Backup data
        D3: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Backup data register (BKP_DR)
    pub const DR3 = Register(DR3_val).init(base_address + 0x8);

    /// DR4
    const DR4_val = packed struct {
        /// D4 [0:15]
        /// Backup data
        D4: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Backup data register (BKP_DR)
    pub const DR4 = Register(DR4_val).init(base_address + 0xc);

    /// DR5
    const DR5_val = packed struct {
        /// D5 [0:15]
        /// Backup data
        D5: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Backup data register (BKP_DR)
    pub const DR5 = Register(DR5_val).init(base_address + 0x10);

    /// DR6
    const DR6_val = packed struct {
        /// D6 [0:15]
        /// Backup data
        D6: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Backup data register (BKP_DR)
    pub const DR6 = Register(DR6_val).init(base_address + 0x14);

    /// DR7
    const DR7_val = packed struct {
        /// D7 [0:15]
        /// Backup data
        D7: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Backup data register (BKP_DR)
    pub const DR7 = Register(DR7_val).init(base_address + 0x18);

    /// DR8
    const DR8_val = packed struct {
        /// D8 [0:15]
        /// Backup data
        D8: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Backup data register (BKP_DR)
    pub const DR8 = Register(DR8_val).init(base_address + 0x1c);

    /// DR9
    const DR9_val = packed struct {
        /// D9 [0:15]
        /// Backup data
        D9: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Backup data register (BKP_DR)
    pub const DR9 = Register(DR9_val).init(base_address + 0x20);

    /// DR10
    const DR10_val = packed struct {
        /// D10 [0:15]
        /// Backup data
        D10: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Backup data register (BKP_DR)
    pub const DR10 = Register(DR10_val).init(base_address + 0x24);

    /// DR11
    const DR11_val = packed struct {
        /// DR11 [0:15]
        /// Backup data
        DR11: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Backup data register (BKP_DR)
    pub const DR11 = Register(DR11_val).init(base_address + 0x3c);

    /// DR12
    const DR12_val = packed struct {
        /// DR12 [0:15]
        /// Backup data
        DR12: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Backup data register (BKP_DR)
    pub const DR12 = Register(DR12_val).init(base_address + 0x40);

    /// DR13
    const DR13_val = packed struct {
        /// DR13 [0:15]
        /// Backup data
        DR13: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Backup data register (BKP_DR)
    pub const DR13 = Register(DR13_val).init(base_address + 0x44);

    /// DR14
    const DR14_val = packed struct {
        /// D14 [0:15]
        /// Backup data
        D14: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Backup data register (BKP_DR)
    pub const DR14 = Register(DR14_val).init(base_address + 0x48);

    /// DR15
    const DR15_val = packed struct {
        /// D15 [0:15]
        /// Backup data
        D15: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Backup data register (BKP_DR)
    pub const DR15 = Register(DR15_val).init(base_address + 0x4c);

    /// DR16
    const DR16_val = packed struct {
        /// D16 [0:15]
        /// Backup data
        D16: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Backup data register (BKP_DR)
    pub const DR16 = Register(DR16_val).init(base_address + 0x50);

    /// DR17
    const DR17_val = packed struct {
        /// D17 [0:15]
        /// Backup data
        D17: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Backup data register (BKP_DR)
    pub const DR17 = Register(DR17_val).init(base_address + 0x54);

    /// DR18
    const DR18_val = packed struct {
        /// D18 [0:15]
        /// Backup data
        D18: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Backup data register (BKP_DR)
    pub const DR18 = Register(DR18_val).init(base_address + 0x58);

    /// DR19
    const DR19_val = packed struct {
        /// D19 [0:15]
        /// Backup data
        D19: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Backup data register (BKP_DR)
    pub const DR19 = Register(DR19_val).init(base_address + 0x5c);

    /// DR20
    const DR20_val = packed struct {
        /// D20 [0:15]
        /// Backup data
        D20: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Backup data register (BKP_DR)
    pub const DR20 = Register(DR20_val).init(base_address + 0x60);

    /// DR21
    const DR21_val = packed struct {
        /// D21 [0:15]
        /// Backup data
        D21: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Backup data register (BKP_DR)
    pub const DR21 = Register(DR21_val).init(base_address + 0x64);

    /// DR22
    const DR22_val = packed struct {
        /// D22 [0:15]
        /// Backup data
        D22: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Backup data register (BKP_DR)
    pub const DR22 = Register(DR22_val).init(base_address + 0x68);

    /// DR23
    const DR23_val = packed struct {
        /// D23 [0:15]
        /// Backup data
        D23: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Backup data register (BKP_DR)
    pub const DR23 = Register(DR23_val).init(base_address + 0x6c);

    /// DR24
    const DR24_val = packed struct {
        /// D24 [0:15]
        /// Backup data
        D24: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Backup data register (BKP_DR)
    pub const DR24 = Register(DR24_val).init(base_address + 0x70);

    /// DR25
    const DR25_val = packed struct {
        /// D25 [0:15]
        /// Backup data
        D25: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Backup data register (BKP_DR)
    pub const DR25 = Register(DR25_val).init(base_address + 0x74);

    /// DR26
    const DR26_val = packed struct {
        /// D26 [0:15]
        /// Backup data
        D26: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Backup data register (BKP_DR)
    pub const DR26 = Register(DR26_val).init(base_address + 0x78);

    /// DR27
    const DR27_val = packed struct {
        /// D27 [0:15]
        /// Backup data
        D27: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Backup data register (BKP_DR)
    pub const DR27 = Register(DR27_val).init(base_address + 0x7c);

    /// DR28
    const DR28_val = packed struct {
        /// D28 [0:15]
        /// Backup data
        D28: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Backup data register (BKP_DR)
    pub const DR28 = Register(DR28_val).init(base_address + 0x80);

    /// DR29
    const DR29_val = packed struct {
        /// D29 [0:15]
        /// Backup data
        D29: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Backup data register (BKP_DR)
    pub const DR29 = Register(DR29_val).init(base_address + 0x84);

    /// DR30
    const DR30_val = packed struct {
        /// D30 [0:15]
        /// Backup data
        D30: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Backup data register (BKP_DR)
    pub const DR30 = Register(DR30_val).init(base_address + 0x88);

    /// DR31
    const DR31_val = packed struct {
        /// D31 [0:15]
        /// Backup data
        D31: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Backup data register (BKP_DR)
    pub const DR31 = Register(DR31_val).init(base_address + 0x8c);

    /// DR32
    const DR32_val = packed struct {
        /// D32 [0:15]
        /// Backup data
        D32: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Backup data register (BKP_DR)
    pub const DR32 = Register(DR32_val).init(base_address + 0x90);

    /// DR33
    const DR33_val = packed struct {
        /// D33 [0:15]
        /// Backup data
        D33: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Backup data register (BKP_DR)
    pub const DR33 = Register(DR33_val).init(base_address + 0x94);

    /// DR34
    const DR34_val = packed struct {
        /// D34 [0:15]
        /// Backup data
        D34: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Backup data register (BKP_DR)
    pub const DR34 = Register(DR34_val).init(base_address + 0x98);

    /// DR35
    const DR35_val = packed struct {
        /// D35 [0:15]
        /// Backup data
        D35: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Backup data register (BKP_DR)
    pub const DR35 = Register(DR35_val).init(base_address + 0x9c);

    /// DR36
    const DR36_val = packed struct {
        /// D36 [0:15]
        /// Backup data
        D36: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Backup data register (BKP_DR)
    pub const DR36 = Register(DR36_val).init(base_address + 0xa0);

    /// DR37
    const DR37_val = packed struct {
        /// D37 [0:15]
        /// Backup data
        D37: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Backup data register (BKP_DR)
    pub const DR37 = Register(DR37_val).init(base_address + 0xa4);

    /// DR38
    const DR38_val = packed struct {
        /// D38 [0:15]
        /// Backup data
        D38: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Backup data register (BKP_DR)
    pub const DR38 = Register(DR38_val).init(base_address + 0xa8);

    /// DR39
    const DR39_val = packed struct {
        /// D39 [0:15]
        /// Backup data
        D39: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Backup data register (BKP_DR)
    pub const DR39 = Register(DR39_val).init(base_address + 0xac);

    /// DR40
    const DR40_val = packed struct {
        /// D40 [0:15]
        /// Backup data
        D40: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Backup data register (BKP_DR)
    pub const DR40 = Register(DR40_val).init(base_address + 0xb0);

    /// DR41
    const DR41_val = packed struct {
        /// D41 [0:15]
        /// Backup data
        D41: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Backup data register (BKP_DR)
    pub const DR41 = Register(DR41_val).init(base_address + 0xb4);

    /// DR42
    const DR42_val = packed struct {
        /// D42 [0:15]
        /// Backup data
        D42: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Backup data register (BKP_DR)
    pub const DR42 = Register(DR42_val).init(base_address + 0xb8);

    /// RTCCR
    const RTCCR_val = packed struct {
        /// CAL [0:6]
        /// Calibration value
        CAL: u7 = 0,
        /// CCO [7:7]
        /// Calibration Clock Output
        CCO: u1 = 0,
        /// ASOE [8:8]
        /// Alarm or second output
        ASOE: u1 = 0,
        /// ASOS [9:9]
        /// Alarm or second output
        ASOS: u1 = 0,
        /// unused [10:31]
        _unused10: u6 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// RTC clock calibration register
    pub const RTCCR = Register(RTCCR_val).init(base_address + 0x28);

    /// CR
    const CR_val = packed struct {
        /// TPE [0:0]
        /// Tamper pin enable
        TPE: u1 = 0,
        /// TPAL [1:1]
        /// Tamper pin active level
        TPAL: u1 = 0,
        /// unused [2:31]
        _unused2: u6 = 0,
        _unused8: u8 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Backup control register
    pub const CR = Register(CR_val).init(base_address + 0x2c);

    /// CSR
    const CSR_val = packed struct {
        /// CTE [0:0]
        /// Clear Tamper event
        CTE: u1 = 0,
        /// CTI [1:1]
        /// Clear Tamper Interrupt
        CTI: u1 = 0,
        /// TPIE [2:2]
        /// Tamper Pin interrupt
        TPIE: u1 = 0,
        /// unused [3:7]
        _unused3: u5 = 0,
        /// TEF [8:8]
        /// Tamper Event Flag
        TEF: u1 = 0,
        /// TIF [9:9]
        /// Tamper Interrupt Flag
        TIF: u1 = 0,
        /// unused [10:31]
        _unused10: u6 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// BKP_CSR control/status register
    pub const CSR = Register(CSR_val).init(base_address + 0x30);
};

/// Independent watchdog
pub const IWDG = struct {
    const base_address = 0x40003000;
    /// KR
    const KR_val = packed struct {
        /// KEY [0:15]
        /// Key value
        KEY: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Key register (IWDG_KR)
    pub const KR = Register(KR_val).init(base_address + 0x0);

    /// PR
    const PR_val = packed struct {
        /// PR [0:2]
        /// Prescaler divider
        PR: u3 = 0,
        /// unused [3:31]
        _unused3: u5 = 0,
        _unused8: u8 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Prescaler register (IWDG_PR)
    pub const PR = Register(PR_val).init(base_address + 0x4);

    /// RLR
    const RLR_val = packed struct {
        /// RL [0:11]
        /// Watchdog counter reload
        RL: u12 = 4095,
        /// unused [12:31]
        _unused12: u4 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Reload register (IWDG_RLR)
    pub const RLR = Register(RLR_val).init(base_address + 0x8);

    /// SR
    const SR_val = packed struct {
        /// PVU [0:0]
        /// Watchdog prescaler value
        PVU: u1 = 0,
        /// RVU [1:1]
        /// Watchdog counter reload value
        RVU: u1 = 0,
        /// unused [2:31]
        _unused2: u6 = 0,
        _unused8: u8 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Status register (IWDG_SR)
    pub const SR = Register(SR_val).init(base_address + 0xc);
};

/// Window watchdog
pub const WWDG = struct {
    const base_address = 0x40002c00;
    /// CR
    const CR_val = packed struct {
        /// T [0:6]
        /// 7-bit counter (MSB to LSB)
        T: u7 = 127,
        /// WDGA [7:7]
        /// Activation bit
        WDGA: u1 = 0,
        /// unused [8:31]
        _unused8: u8 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Control register (WWDG_CR)
    pub const CR = Register(CR_val).init(base_address + 0x0);

    /// CFR
    const CFR_val = packed struct {
        /// W [0:6]
        /// 7-bit window value
        W: u7 = 127,
        /// WDGTB [7:8]
        /// Timer Base
        WDGTB: u2 = 0,
        /// EWI [9:9]
        /// Early Wakeup Interrupt
        EWI: u1 = 0,
        /// unused [10:31]
        _unused10: u6 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Configuration register
    pub const CFR = Register(CFR_val).init(base_address + 0x4);

    /// SR
    const SR_val = packed struct {
        /// EWI [0:0]
        /// Early Wakeup Interrupt
        EWI: u1 = 0,
        /// unused [1:31]
        _unused1: u7 = 0,
        _unused8: u8 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Status register (WWDG_SR)
    pub const SR = Register(SR_val).init(base_address + 0x8);
};

/// Advanced timer
pub const TIM1 = struct {
    const base_address = 0x40012c00;
    /// CR1
    const CR1_val = packed struct {
        /// CEN [0:0]
        /// Counter enable
        CEN: u1 = 0,
        /// UDIS [1:1]
        /// Update disable
        UDIS: u1 = 0,
        /// URS [2:2]
        /// Update request source
        URS: u1 = 0,
        /// OPM [3:3]
        /// One-pulse mode
        OPM: u1 = 0,
        /// DIR [4:4]
        /// Direction
        DIR: u1 = 0,
        /// CMS [5:6]
        /// Center-aligned mode
        CMS: u2 = 0,
        /// ARPE [7:7]
        /// Auto-reload preload enable
        ARPE: u1 = 0,
        /// CKD [8:9]
        /// Clock division
        CKD: u2 = 0,
        /// unused [10:31]
        _unused10: u6 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// control register 1
    pub const CR1 = Register(CR1_val).init(base_address + 0x0);

    /// CR2
    const CR2_val = packed struct {
        /// CCPC [0:0]
        /// Capture/compare preloaded
        CCPC: u1 = 0,
        /// unused [1:1]
        _unused1: u1 = 0,
        /// CCUS [2:2]
        /// Capture/compare control update
        CCUS: u1 = 0,
        /// CCDS [3:3]
        /// Capture/compare DMA
        CCDS: u1 = 0,
        /// MMS [4:6]
        /// Master mode selection
        MMS: u3 = 0,
        /// TI1S [7:7]
        /// TI1 selection
        TI1S: u1 = 0,
        /// OIS1 [8:8]
        /// Output Idle state 1
        OIS1: u1 = 0,
        /// OIS1N [9:9]
        /// Output Idle state 1
        OIS1N: u1 = 0,
        /// OIS2 [10:10]
        /// Output Idle state 2
        OIS2: u1 = 0,
        /// OIS2N [11:11]
        /// Output Idle state 2
        OIS2N: u1 = 0,
        /// OIS3 [12:12]
        /// Output Idle state 3
        OIS3: u1 = 0,
        /// OIS3N [13:13]
        /// Output Idle state 3
        OIS3N: u1 = 0,
        /// OIS4 [14:14]
        /// Output Idle state 4
        OIS4: u1 = 0,
        /// unused [15:31]
        _unused15: u1 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// control register 2
    pub const CR2 = Register(CR2_val).init(base_address + 0x4);

    /// SMCR
    const SMCR_val = packed struct {
        /// SMS [0:2]
        /// Slave mode selection
        SMS: u3 = 0,
        /// unused [3:3]
        _unused3: u1 = 0,
        /// TS [4:6]
        /// Trigger selection
        TS: u3 = 0,
        /// MSM [7:7]
        /// Master/Slave mode
        MSM: u1 = 0,
        /// ETF [8:11]
        /// External trigger filter
        ETF: u4 = 0,
        /// ETPS [12:13]
        /// External trigger prescaler
        ETPS: u2 = 0,
        /// ECE [14:14]
        /// External clock enable
        ECE: u1 = 0,
        /// ETP [15:15]
        /// External trigger polarity
        ETP: u1 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// slave mode control register
    pub const SMCR = Register(SMCR_val).init(base_address + 0x8);

    /// DIER
    const DIER_val = packed struct {
        /// UIE [0:0]
        /// Update interrupt enable
        UIE: u1 = 0,
        /// CC1IE [1:1]
        /// Capture/Compare 1 interrupt
        CC1IE: u1 = 0,
        /// CC2IE [2:2]
        /// Capture/Compare 2 interrupt
        CC2IE: u1 = 0,
        /// CC3IE [3:3]
        /// Capture/Compare 3 interrupt
        CC3IE: u1 = 0,
        /// CC4IE [4:4]
        /// Capture/Compare 4 interrupt
        CC4IE: u1 = 0,
        /// COMIE [5:5]
        /// COM interrupt enable
        COMIE: u1 = 0,
        /// TIE [6:6]
        /// Trigger interrupt enable
        TIE: u1 = 0,
        /// BIE [7:7]
        /// Break interrupt enable
        BIE: u1 = 0,
        /// UDE [8:8]
        /// Update DMA request enable
        UDE: u1 = 0,
        /// CC1DE [9:9]
        /// Capture/Compare 1 DMA request
        CC1DE: u1 = 0,
        /// CC2DE [10:10]
        /// Capture/Compare 2 DMA request
        CC2DE: u1 = 0,
        /// CC3DE [11:11]
        /// Capture/Compare 3 DMA request
        CC3DE: u1 = 0,
        /// CC4DE [12:12]
        /// Capture/Compare 4 DMA request
        CC4DE: u1 = 0,
        /// COMDE [13:13]
        /// COM DMA request enable
        COMDE: u1 = 0,
        /// TDE [14:14]
        /// Trigger DMA request enable
        TDE: u1 = 0,
        /// unused [15:31]
        _unused15: u1 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// DMA/Interrupt enable register
    pub const DIER = Register(DIER_val).init(base_address + 0xc);

    /// SR
    const SR_val = packed struct {
        /// UIF [0:0]
        /// Update interrupt flag
        UIF: u1 = 0,
        /// CC1IF [1:1]
        /// Capture/compare 1 interrupt
        CC1IF: u1 = 0,
        /// CC2IF [2:2]
        /// Capture/Compare 2 interrupt
        CC2IF: u1 = 0,
        /// CC3IF [3:3]
        /// Capture/Compare 3 interrupt
        CC3IF: u1 = 0,
        /// CC4IF [4:4]
        /// Capture/Compare 4 interrupt
        CC4IF: u1 = 0,
        /// COMIF [5:5]
        /// COM interrupt flag
        COMIF: u1 = 0,
        /// TIF [6:6]
        /// Trigger interrupt flag
        TIF: u1 = 0,
        /// BIF [7:7]
        /// Break interrupt flag
        BIF: u1 = 0,
        /// unused [8:8]
        _unused8: u1 = 0,
        /// CC1OF [9:9]
        /// Capture/Compare 1 overcapture
        CC1OF: u1 = 0,
        /// CC2OF [10:10]
        /// Capture/compare 2 overcapture
        CC2OF: u1 = 0,
        /// CC3OF [11:11]
        /// Capture/Compare 3 overcapture
        CC3OF: u1 = 0,
        /// CC4OF [12:12]
        /// Capture/Compare 4 overcapture
        CC4OF: u1 = 0,
        /// unused [13:31]
        _unused13: u3 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// status register
    pub const SR = Register(SR_val).init(base_address + 0x10);

    /// EGR
    const EGR_val = packed struct {
        /// UG [0:0]
        /// Update generation
        UG: u1 = 0,
        /// CC1G [1:1]
        /// Capture/compare 1
        CC1G: u1 = 0,
        /// CC2G [2:2]
        /// Capture/compare 2
        CC2G: u1 = 0,
        /// CC3G [3:3]
        /// Capture/compare 3
        CC3G: u1 = 0,
        /// CC4G [4:4]
        /// Capture/compare 4
        CC4G: u1 = 0,
        /// COMG [5:5]
        /// Capture/Compare control update
        COMG: u1 = 0,
        /// TG [6:6]
        /// Trigger generation
        TG: u1 = 0,
        /// BG [7:7]
        /// Break generation
        BG: u1 = 0,
        /// unused [8:31]
        _unused8: u8 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// event generation register
    pub const EGR = Register(EGR_val).init(base_address + 0x14);

    /// CCMR1_Output
    const CCMR1_Output_val = packed struct {
        /// CC1S [0:1]
        /// Capture/Compare 1
        CC1S: u2 = 0,
        /// OC1FE [2:2]
        /// Output Compare 1 fast
        OC1FE: u1 = 0,
        /// OC1PE [3:3]
        /// Output Compare 1 preload
        OC1PE: u1 = 0,
        /// OC1M [4:6]
        /// Output Compare 1 mode
        OC1M: u3 = 0,
        /// OC1CE [7:7]
        /// Output Compare 1 clear
        OC1CE: u1 = 0,
        /// CC2S [8:9]
        /// Capture/Compare 2
        CC2S: u2 = 0,
        /// OC2FE [10:10]
        /// Output Compare 2 fast
        OC2FE: u1 = 0,
        /// OC2PE [11:11]
        /// Output Compare 2 preload
        OC2PE: u1 = 0,
        /// OC2M [12:14]
        /// Output Compare 2 mode
        OC2M: u3 = 0,
        /// OC2CE [15:15]
        /// Output Compare 2 clear
        OC2CE: u1 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// capture/compare mode register (output
    pub const CCMR1_Output = Register(CCMR1_Output_val).init(base_address + 0x18);

    /// CCMR1_Input
    const CCMR1_Input_val = packed struct {
        /// CC1S [0:1]
        /// Capture/Compare 1
        CC1S: u2 = 0,
        /// ICPCS [2:3]
        /// Input capture 1 prescaler
        ICPCS: u2 = 0,
        /// IC1F [4:7]
        /// Input capture 1 filter
        IC1F: u4 = 0,
        /// CC2S [8:9]
        /// Capture/Compare 2
        CC2S: u2 = 0,
        /// IC2PCS [10:11]
        /// Input capture 2 prescaler
        IC2PCS: u2 = 0,
        /// IC2F [12:15]
        /// Input capture 2 filter
        IC2F: u4 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// capture/compare mode register 1 (input
    pub const CCMR1_Input = Register(CCMR1_Input_val).init(base_address + 0x18);

    /// CCMR2_Output
    const CCMR2_Output_val = packed struct {
        /// CC3S [0:1]
        /// Capture/Compare 3
        CC3S: u2 = 0,
        /// OC3FE [2:2]
        /// Output compare 3 fast
        OC3FE: u1 = 0,
        /// OC3PE [3:3]
        /// Output compare 3 preload
        OC3PE: u1 = 0,
        /// OC3M [4:6]
        /// Output compare 3 mode
        OC3M: u3 = 0,
        /// OC3CE [7:7]
        /// Output compare 3 clear
        OC3CE: u1 = 0,
        /// CC4S [8:9]
        /// Capture/Compare 4
        CC4S: u2 = 0,
        /// OC4FE [10:10]
        /// Output compare 4 fast
        OC4FE: u1 = 0,
        /// OC4PE [11:11]
        /// Output compare 4 preload
        OC4PE: u1 = 0,
        /// OC4M [12:14]
        /// Output compare 4 mode
        OC4M: u3 = 0,
        /// OC4CE [15:15]
        /// Output compare 4 clear
        OC4CE: u1 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// capture/compare mode register (output
    pub const CCMR2_Output = Register(CCMR2_Output_val).init(base_address + 0x1c);

    /// CCMR2_Input
    const CCMR2_Input_val = packed struct {
        /// CC3S [0:1]
        /// Capture/compare 3
        CC3S: u2 = 0,
        /// IC3PSC [2:3]
        /// Input capture 3 prescaler
        IC3PSC: u2 = 0,
        /// IC3F [4:7]
        /// Input capture 3 filter
        IC3F: u4 = 0,
        /// CC4S [8:9]
        /// Capture/Compare 4
        CC4S: u2 = 0,
        /// IC4PSC [10:11]
        /// Input capture 4 prescaler
        IC4PSC: u2 = 0,
        /// IC4F [12:15]
        /// Input capture 4 filter
        IC4F: u4 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// capture/compare mode register 2 (input
    pub const CCMR2_Input = Register(CCMR2_Input_val).init(base_address + 0x1c);

    /// CCER
    const CCER_val = packed struct {
        /// CC1E [0:0]
        /// Capture/Compare 1 output
        CC1E: u1 = 0,
        /// CC1P [1:1]
        /// Capture/Compare 1 output
        CC1P: u1 = 0,
        /// CC1NE [2:2]
        /// Capture/Compare 1 complementary output
        CC1NE: u1 = 0,
        /// CC1NP [3:3]
        /// Capture/Compare 1 output
        CC1NP: u1 = 0,
        /// CC2E [4:4]
        /// Capture/Compare 2 output
        CC2E: u1 = 0,
        /// CC2P [5:5]
        /// Capture/Compare 2 output
        CC2P: u1 = 0,
        /// CC2NE [6:6]
        /// Capture/Compare 2 complementary output
        CC2NE: u1 = 0,
        /// CC2NP [7:7]
        /// Capture/Compare 2 output
        CC2NP: u1 = 0,
        /// CC3E [8:8]
        /// Capture/Compare 3 output
        CC3E: u1 = 0,
        /// CC3P [9:9]
        /// Capture/Compare 3 output
        CC3P: u1 = 0,
        /// CC3NE [10:10]
        /// Capture/Compare 3 complementary output
        CC3NE: u1 = 0,
        /// CC3NP [11:11]
        /// Capture/Compare 3 output
        CC3NP: u1 = 0,
        /// CC4E [12:12]
        /// Capture/Compare 4 output
        CC4E: u1 = 0,
        /// CC4P [13:13]
        /// Capture/Compare 3 output
        CC4P: u1 = 0,
        /// unused [14:31]
        _unused14: u2 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// capture/compare enable
    pub const CCER = Register(CCER_val).init(base_address + 0x20);

    /// CNT
    const CNT_val = packed struct {
        /// CNT [0:15]
        /// counter value
        CNT: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// counter
    pub const CNT = Register(CNT_val).init(base_address + 0x24);

    /// PSC
    const PSC_val = packed struct {
        /// PSC [0:15]
        /// Prescaler value
        PSC: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// prescaler
    pub const PSC = Register(PSC_val).init(base_address + 0x28);

    /// ARR
    const ARR_val = packed struct {
        /// ARR [0:15]
        /// Auto-reload value
        ARR: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// auto-reload register
    pub const ARR = Register(ARR_val).init(base_address + 0x2c);

    /// CCR1
    const CCR1_val = packed struct {
        /// CCR1 [0:15]
        /// Capture/Compare 1 value
        CCR1: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// capture/compare register 1
    pub const CCR1 = Register(CCR1_val).init(base_address + 0x34);

    /// CCR2
    const CCR2_val = packed struct {
        /// CCR2 [0:15]
        /// Capture/Compare 2 value
        CCR2: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// capture/compare register 2
    pub const CCR2 = Register(CCR2_val).init(base_address + 0x38);

    /// CCR3
    const CCR3_val = packed struct {
        /// CCR3 [0:15]
        /// Capture/Compare value
        CCR3: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// capture/compare register 3
    pub const CCR3 = Register(CCR3_val).init(base_address + 0x3c);

    /// CCR4
    const CCR4_val = packed struct {
        /// CCR4 [0:15]
        /// Capture/Compare value
        CCR4: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// capture/compare register 4
    pub const CCR4 = Register(CCR4_val).init(base_address + 0x40);

    /// DCR
    const DCR_val = packed struct {
        /// DBA [0:4]
        /// DMA base address
        DBA: u5 = 0,
        /// unused [5:7]
        _unused5: u3 = 0,
        /// DBL [8:12]
        /// DMA burst length
        DBL: u5 = 0,
        /// unused [13:31]
        _unused13: u3 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// DMA control register
    pub const DCR = Register(DCR_val).init(base_address + 0x48);

    /// DMAR
    const DMAR_val = packed struct {
        /// DMAB [0:15]
        /// DMA register for burst
        DMAB: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// DMA address for full transfer
    pub const DMAR = Register(DMAR_val).init(base_address + 0x4c);

    /// RCR
    const RCR_val = packed struct {
        /// REP [0:7]
        /// Repetition counter value
        REP: u8 = 0,
        /// unused [8:31]
        _unused8: u8 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// repetition counter register
    pub const RCR = Register(RCR_val).init(base_address + 0x30);

    /// BDTR
    const BDTR_val = packed struct {
        /// DTG [0:7]
        /// Dead-time generator setup
        DTG: u8 = 0,
        /// LOCK [8:9]
        /// Lock configuration
        LOCK: u2 = 0,
        /// OSSI [10:10]
        /// Off-state selection for Idle
        OSSI: u1 = 0,
        /// OSSR [11:11]
        /// Off-state selection for Run
        OSSR: u1 = 0,
        /// BKE [12:12]
        /// Break enable
        BKE: u1 = 0,
        /// BKP [13:13]
        /// Break polarity
        BKP: u1 = 0,
        /// AOE [14:14]
        /// Automatic output enable
        AOE: u1 = 0,
        /// MOE [15:15]
        /// Main output enable
        MOE: u1 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// break and dead-time register
    pub const BDTR = Register(BDTR_val).init(base_address + 0x44);
};

/// Advanced timer
pub const TIM8 = struct {
    const base_address = 0x40013400;
    /// CR1
    const CR1_val = packed struct {
        /// CEN [0:0]
        /// Counter enable
        CEN: u1 = 0,
        /// UDIS [1:1]
        /// Update disable
        UDIS: u1 = 0,
        /// URS [2:2]
        /// Update request source
        URS: u1 = 0,
        /// OPM [3:3]
        /// One-pulse mode
        OPM: u1 = 0,
        /// DIR [4:4]
        /// Direction
        DIR: u1 = 0,
        /// CMS [5:6]
        /// Center-aligned mode
        CMS: u2 = 0,
        /// ARPE [7:7]
        /// Auto-reload preload enable
        ARPE: u1 = 0,
        /// CKD [8:9]
        /// Clock division
        CKD: u2 = 0,
        /// unused [10:31]
        _unused10: u6 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// control register 1
    pub const CR1 = Register(CR1_val).init(base_address + 0x0);

    /// CR2
    const CR2_val = packed struct {
        /// CCPC [0:0]
        /// Capture/compare preloaded
        CCPC: u1 = 0,
        /// unused [1:1]
        _unused1: u1 = 0,
        /// CCUS [2:2]
        /// Capture/compare control update
        CCUS: u1 = 0,
        /// CCDS [3:3]
        /// Capture/compare DMA
        CCDS: u1 = 0,
        /// MMS [4:6]
        /// Master mode selection
        MMS: u3 = 0,
        /// TI1S [7:7]
        /// TI1 selection
        TI1S: u1 = 0,
        /// OIS1 [8:8]
        /// Output Idle state 1
        OIS1: u1 = 0,
        /// OIS1N [9:9]
        /// Output Idle state 1
        OIS1N: u1 = 0,
        /// OIS2 [10:10]
        /// Output Idle state 2
        OIS2: u1 = 0,
        /// OIS2N [11:11]
        /// Output Idle state 2
        OIS2N: u1 = 0,
        /// OIS3 [12:12]
        /// Output Idle state 3
        OIS3: u1 = 0,
        /// OIS3N [13:13]
        /// Output Idle state 3
        OIS3N: u1 = 0,
        /// OIS4 [14:14]
        /// Output Idle state 4
        OIS4: u1 = 0,
        /// unused [15:31]
        _unused15: u1 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// control register 2
    pub const CR2 = Register(CR2_val).init(base_address + 0x4);

    /// SMCR
    const SMCR_val = packed struct {
        /// SMS [0:2]
        /// Slave mode selection
        SMS: u3 = 0,
        /// unused [3:3]
        _unused3: u1 = 0,
        /// TS [4:6]
        /// Trigger selection
        TS: u3 = 0,
        /// MSM [7:7]
        /// Master/Slave mode
        MSM: u1 = 0,
        /// ETF [8:11]
        /// External trigger filter
        ETF: u4 = 0,
        /// ETPS [12:13]
        /// External trigger prescaler
        ETPS: u2 = 0,
        /// ECE [14:14]
        /// External clock enable
        ECE: u1 = 0,
        /// ETP [15:15]
        /// External trigger polarity
        ETP: u1 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// slave mode control register
    pub const SMCR = Register(SMCR_val).init(base_address + 0x8);

    /// DIER
    const DIER_val = packed struct {
        /// UIE [0:0]
        /// Update interrupt enable
        UIE: u1 = 0,
        /// CC1IE [1:1]
        /// Capture/Compare 1 interrupt
        CC1IE: u1 = 0,
        /// CC2IE [2:2]
        /// Capture/Compare 2 interrupt
        CC2IE: u1 = 0,
        /// CC3IE [3:3]
        /// Capture/Compare 3 interrupt
        CC3IE: u1 = 0,
        /// CC4IE [4:4]
        /// Capture/Compare 4 interrupt
        CC4IE: u1 = 0,
        /// COMIE [5:5]
        /// COM interrupt enable
        COMIE: u1 = 0,
        /// TIE [6:6]
        /// Trigger interrupt enable
        TIE: u1 = 0,
        /// BIE [7:7]
        /// Break interrupt enable
        BIE: u1 = 0,
        /// UDE [8:8]
        /// Update DMA request enable
        UDE: u1 = 0,
        /// CC1DE [9:9]
        /// Capture/Compare 1 DMA request
        CC1DE: u1 = 0,
        /// CC2DE [10:10]
        /// Capture/Compare 2 DMA request
        CC2DE: u1 = 0,
        /// CC3DE [11:11]
        /// Capture/Compare 3 DMA request
        CC3DE: u1 = 0,
        /// CC4DE [12:12]
        /// Capture/Compare 4 DMA request
        CC4DE: u1 = 0,
        /// COMDE [13:13]
        /// COM DMA request enable
        COMDE: u1 = 0,
        /// TDE [14:14]
        /// Trigger DMA request enable
        TDE: u1 = 0,
        /// unused [15:31]
        _unused15: u1 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// DMA/Interrupt enable register
    pub const DIER = Register(DIER_val).init(base_address + 0xc);

    /// SR
    const SR_val = packed struct {
        /// UIF [0:0]
        /// Update interrupt flag
        UIF: u1 = 0,
        /// CC1IF [1:1]
        /// Capture/compare 1 interrupt
        CC1IF: u1 = 0,
        /// CC2IF [2:2]
        /// Capture/Compare 2 interrupt
        CC2IF: u1 = 0,
        /// CC3IF [3:3]
        /// Capture/Compare 3 interrupt
        CC3IF: u1 = 0,
        /// CC4IF [4:4]
        /// Capture/Compare 4 interrupt
        CC4IF: u1 = 0,
        /// COMIF [5:5]
        /// COM interrupt flag
        COMIF: u1 = 0,
        /// TIF [6:6]
        /// Trigger interrupt flag
        TIF: u1 = 0,
        /// BIF [7:7]
        /// Break interrupt flag
        BIF: u1 = 0,
        /// unused [8:8]
        _unused8: u1 = 0,
        /// CC1OF [9:9]
        /// Capture/Compare 1 overcapture
        CC1OF: u1 = 0,
        /// CC2OF [10:10]
        /// Capture/compare 2 overcapture
        CC2OF: u1 = 0,
        /// CC3OF [11:11]
        /// Capture/Compare 3 overcapture
        CC3OF: u1 = 0,
        /// CC4OF [12:12]
        /// Capture/Compare 4 overcapture
        CC4OF: u1 = 0,
        /// unused [13:31]
        _unused13: u3 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// status register
    pub const SR = Register(SR_val).init(base_address + 0x10);

    /// EGR
    const EGR_val = packed struct {
        /// UG [0:0]
        /// Update generation
        UG: u1 = 0,
        /// CC1G [1:1]
        /// Capture/compare 1
        CC1G: u1 = 0,
        /// CC2G [2:2]
        /// Capture/compare 2
        CC2G: u1 = 0,
        /// CC3G [3:3]
        /// Capture/compare 3
        CC3G: u1 = 0,
        /// CC4G [4:4]
        /// Capture/compare 4
        CC4G: u1 = 0,
        /// COMG [5:5]
        /// Capture/Compare control update
        COMG: u1 = 0,
        /// TG [6:6]
        /// Trigger generation
        TG: u1 = 0,
        /// BG [7:7]
        /// Break generation
        BG: u1 = 0,
        /// unused [8:31]
        _unused8: u8 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// event generation register
    pub const EGR = Register(EGR_val).init(base_address + 0x14);

    /// CCMR1_Output
    const CCMR1_Output_val = packed struct {
        /// CC1S [0:1]
        /// Capture/Compare 1
        CC1S: u2 = 0,
        /// OC1FE [2:2]
        /// Output Compare 1 fast
        OC1FE: u1 = 0,
        /// OC1PE [3:3]
        /// Output Compare 1 preload
        OC1PE: u1 = 0,
        /// OC1M [4:6]
        /// Output Compare 1 mode
        OC1M: u3 = 0,
        /// OC1CE [7:7]
        /// Output Compare 1 clear
        OC1CE: u1 = 0,
        /// CC2S [8:9]
        /// Capture/Compare 2
        CC2S: u2 = 0,
        /// OC2FE [10:10]
        /// Output Compare 2 fast
        OC2FE: u1 = 0,
        /// OC2PE [11:11]
        /// Output Compare 2 preload
        OC2PE: u1 = 0,
        /// OC2M [12:14]
        /// Output Compare 2 mode
        OC2M: u3 = 0,
        /// OC2CE [15:15]
        /// Output Compare 2 clear
        OC2CE: u1 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// capture/compare mode register (output
    pub const CCMR1_Output = Register(CCMR1_Output_val).init(base_address + 0x18);

    /// CCMR1_Input
    const CCMR1_Input_val = packed struct {
        /// CC1S [0:1]
        /// Capture/Compare 1
        CC1S: u2 = 0,
        /// ICPCS [2:3]
        /// Input capture 1 prescaler
        ICPCS: u2 = 0,
        /// IC1F [4:7]
        /// Input capture 1 filter
        IC1F: u4 = 0,
        /// CC2S [8:9]
        /// Capture/Compare 2
        CC2S: u2 = 0,
        /// IC2PCS [10:11]
        /// Input capture 2 prescaler
        IC2PCS: u2 = 0,
        /// IC2F [12:15]
        /// Input capture 2 filter
        IC2F: u4 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// capture/compare mode register 1 (input
    pub const CCMR1_Input = Register(CCMR1_Input_val).init(base_address + 0x18);

    /// CCMR2_Output
    const CCMR2_Output_val = packed struct {
        /// CC3S [0:1]
        /// Capture/Compare 3
        CC3S: u2 = 0,
        /// OC3FE [2:2]
        /// Output compare 3 fast
        OC3FE: u1 = 0,
        /// OC3PE [3:3]
        /// Output compare 3 preload
        OC3PE: u1 = 0,
        /// OC3M [4:6]
        /// Output compare 3 mode
        OC3M: u3 = 0,
        /// OC3CE [7:7]
        /// Output compare 3 clear
        OC3CE: u1 = 0,
        /// CC4S [8:9]
        /// Capture/Compare 4
        CC4S: u2 = 0,
        /// OC4FE [10:10]
        /// Output compare 4 fast
        OC4FE: u1 = 0,
        /// OC4PE [11:11]
        /// Output compare 4 preload
        OC4PE: u1 = 0,
        /// OC4M [12:14]
        /// Output compare 4 mode
        OC4M: u3 = 0,
        /// OC4CE [15:15]
        /// Output compare 4 clear
        OC4CE: u1 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// capture/compare mode register (output
    pub const CCMR2_Output = Register(CCMR2_Output_val).init(base_address + 0x1c);

    /// CCMR2_Input
    const CCMR2_Input_val = packed struct {
        /// CC3S [0:1]
        /// Capture/compare 3
        CC3S: u2 = 0,
        /// IC3PSC [2:3]
        /// Input capture 3 prescaler
        IC3PSC: u2 = 0,
        /// IC3F [4:7]
        /// Input capture 3 filter
        IC3F: u4 = 0,
        /// CC4S [8:9]
        /// Capture/Compare 4
        CC4S: u2 = 0,
        /// IC4PSC [10:11]
        /// Input capture 4 prescaler
        IC4PSC: u2 = 0,
        /// IC4F [12:15]
        /// Input capture 4 filter
        IC4F: u4 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// capture/compare mode register 2 (input
    pub const CCMR2_Input = Register(CCMR2_Input_val).init(base_address + 0x1c);

    /// CCER
    const CCER_val = packed struct {
        /// CC1E [0:0]
        /// Capture/Compare 1 output
        CC1E: u1 = 0,
        /// CC1P [1:1]
        /// Capture/Compare 1 output
        CC1P: u1 = 0,
        /// CC1NE [2:2]
        /// Capture/Compare 1 complementary output
        CC1NE: u1 = 0,
        /// CC1NP [3:3]
        /// Capture/Compare 1 output
        CC1NP: u1 = 0,
        /// CC2E [4:4]
        /// Capture/Compare 2 output
        CC2E: u1 = 0,
        /// CC2P [5:5]
        /// Capture/Compare 2 output
        CC2P: u1 = 0,
        /// CC2NE [6:6]
        /// Capture/Compare 2 complementary output
        CC2NE: u1 = 0,
        /// CC2NP [7:7]
        /// Capture/Compare 2 output
        CC2NP: u1 = 0,
        /// CC3E [8:8]
        /// Capture/Compare 3 output
        CC3E: u1 = 0,
        /// CC3P [9:9]
        /// Capture/Compare 3 output
        CC3P: u1 = 0,
        /// CC3NE [10:10]
        /// Capture/Compare 3 complementary output
        CC3NE: u1 = 0,
        /// CC3NP [11:11]
        /// Capture/Compare 3 output
        CC3NP: u1 = 0,
        /// CC4E [12:12]
        /// Capture/Compare 4 output
        CC4E: u1 = 0,
        /// CC4P [13:13]
        /// Capture/Compare 3 output
        CC4P: u1 = 0,
        /// unused [14:31]
        _unused14: u2 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// capture/compare enable
    pub const CCER = Register(CCER_val).init(base_address + 0x20);

    /// CNT
    const CNT_val = packed struct {
        /// CNT [0:15]
        /// counter value
        CNT: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// counter
    pub const CNT = Register(CNT_val).init(base_address + 0x24);

    /// PSC
    const PSC_val = packed struct {
        /// PSC [0:15]
        /// Prescaler value
        PSC: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// prescaler
    pub const PSC = Register(PSC_val).init(base_address + 0x28);

    /// ARR
    const ARR_val = packed struct {
        /// ARR [0:15]
        /// Auto-reload value
        ARR: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// auto-reload register
    pub const ARR = Register(ARR_val).init(base_address + 0x2c);

    /// CCR1
    const CCR1_val = packed struct {
        /// CCR1 [0:15]
        /// Capture/Compare 1 value
        CCR1: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// capture/compare register 1
    pub const CCR1 = Register(CCR1_val).init(base_address + 0x34);

    /// CCR2
    const CCR2_val = packed struct {
        /// CCR2 [0:15]
        /// Capture/Compare 2 value
        CCR2: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// capture/compare register 2
    pub const CCR2 = Register(CCR2_val).init(base_address + 0x38);

    /// CCR3
    const CCR3_val = packed struct {
        /// CCR3 [0:15]
        /// Capture/Compare value
        CCR3: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// capture/compare register 3
    pub const CCR3 = Register(CCR3_val).init(base_address + 0x3c);

    /// CCR4
    const CCR4_val = packed struct {
        /// CCR4 [0:15]
        /// Capture/Compare value
        CCR4: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// capture/compare register 4
    pub const CCR4 = Register(CCR4_val).init(base_address + 0x40);

    /// DCR
    const DCR_val = packed struct {
        /// DBA [0:4]
        /// DMA base address
        DBA: u5 = 0,
        /// unused [5:7]
        _unused5: u3 = 0,
        /// DBL [8:12]
        /// DMA burst length
        DBL: u5 = 0,
        /// unused [13:31]
        _unused13: u3 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// DMA control register
    pub const DCR = Register(DCR_val).init(base_address + 0x48);

    /// DMAR
    const DMAR_val = packed struct {
        /// DMAB [0:15]
        /// DMA register for burst
        DMAB: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// DMA address for full transfer
    pub const DMAR = Register(DMAR_val).init(base_address + 0x4c);

    /// RCR
    const RCR_val = packed struct {
        /// REP [0:7]
        /// Repetition counter value
        REP: u8 = 0,
        /// unused [8:31]
        _unused8: u8 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// repetition counter register
    pub const RCR = Register(RCR_val).init(base_address + 0x30);

    /// BDTR
    const BDTR_val = packed struct {
        /// DTG [0:7]
        /// Dead-time generator setup
        DTG: u8 = 0,
        /// LOCK [8:9]
        /// Lock configuration
        LOCK: u2 = 0,
        /// OSSI [10:10]
        /// Off-state selection for Idle
        OSSI: u1 = 0,
        /// OSSR [11:11]
        /// Off-state selection for Run
        OSSR: u1 = 0,
        /// BKE [12:12]
        /// Break enable
        BKE: u1 = 0,
        /// BKP [13:13]
        /// Break polarity
        BKP: u1 = 0,
        /// AOE [14:14]
        /// Automatic output enable
        AOE: u1 = 0,
        /// MOE [15:15]
        /// Main output enable
        MOE: u1 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// break and dead-time register
    pub const BDTR = Register(BDTR_val).init(base_address + 0x44);
};

/// General purpose timer
pub const TIM2 = struct {
    const base_address = 0x40000000;
    /// CR1
    const CR1_val = packed struct {
        /// CEN [0:0]
        /// Counter enable
        CEN: u1 = 0,
        /// UDIS [1:1]
        /// Update disable
        UDIS: u1 = 0,
        /// URS [2:2]
        /// Update request source
        URS: u1 = 0,
        /// OPM [3:3]
        /// One-pulse mode
        OPM: u1 = 0,
        /// DIR [4:4]
        /// Direction
        DIR: u1 = 0,
        /// CMS [5:6]
        /// Center-aligned mode
        CMS: u2 = 0,
        /// ARPE [7:7]
        /// Auto-reload preload enable
        ARPE: u1 = 0,
        /// CKD [8:9]
        /// Clock division
        CKD: u2 = 0,
        /// unused [10:31]
        _unused10: u6 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// control register 1
    pub const CR1 = Register(CR1_val).init(base_address + 0x0);

    /// CR2
    const CR2_val = packed struct {
        /// unused [0:2]
        _unused0: u3 = 0,
        /// CCDS [3:3]
        /// Capture/compare DMA
        CCDS: u1 = 0,
        /// MMS [4:6]
        /// Master mode selection
        MMS: u3 = 0,
        /// TI1S [7:7]
        /// TI1 selection
        TI1S: u1 = 0,
        /// unused [8:31]
        _unused8: u8 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// control register 2
    pub const CR2 = Register(CR2_val).init(base_address + 0x4);

    /// SMCR
    const SMCR_val = packed struct {
        /// SMS [0:2]
        /// Slave mode selection
        SMS: u3 = 0,
        /// unused [3:3]
        _unused3: u1 = 0,
        /// TS [4:6]
        /// Trigger selection
        TS: u3 = 0,
        /// MSM [7:7]
        /// Master/Slave mode
        MSM: u1 = 0,
        /// ETF [8:11]
        /// External trigger filter
        ETF: u4 = 0,
        /// ETPS [12:13]
        /// External trigger prescaler
        ETPS: u2 = 0,
        /// ECE [14:14]
        /// External clock enable
        ECE: u1 = 0,
        /// ETP [15:15]
        /// External trigger polarity
        ETP: u1 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// slave mode control register
    pub const SMCR = Register(SMCR_val).init(base_address + 0x8);

    /// DIER
    const DIER_val = packed struct {
        /// UIE [0:0]
        /// Update interrupt enable
        UIE: u1 = 0,
        /// CC1IE [1:1]
        /// Capture/Compare 1 interrupt
        CC1IE: u1 = 0,
        /// CC2IE [2:2]
        /// Capture/Compare 2 interrupt
        CC2IE: u1 = 0,
        /// CC3IE [3:3]
        /// Capture/Compare 3 interrupt
        CC3IE: u1 = 0,
        /// CC4IE [4:4]
        /// Capture/Compare 4 interrupt
        CC4IE: u1 = 0,
        /// unused [5:5]
        _unused5: u1 = 0,
        /// TIE [6:6]
        /// Trigger interrupt enable
        TIE: u1 = 0,
        /// unused [7:7]
        _unused7: u1 = 0,
        /// UDE [8:8]
        /// Update DMA request enable
        UDE: u1 = 0,
        /// CC1DE [9:9]
        /// Capture/Compare 1 DMA request
        CC1DE: u1 = 0,
        /// CC2DE [10:10]
        /// Capture/Compare 2 DMA request
        CC2DE: u1 = 0,
        /// CC3DE [11:11]
        /// Capture/Compare 3 DMA request
        CC3DE: u1 = 0,
        /// CC4DE [12:12]
        /// Capture/Compare 4 DMA request
        CC4DE: u1 = 0,
        /// unused [13:13]
        _unused13: u1 = 0,
        /// TDE [14:14]
        /// Trigger DMA request enable
        TDE: u1 = 0,
        /// unused [15:31]
        _unused15: u1 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// DMA/Interrupt enable register
    pub const DIER = Register(DIER_val).init(base_address + 0xc);

    /// SR
    const SR_val = packed struct {
        /// UIF [0:0]
        /// Update interrupt flag
        UIF: u1 = 0,
        /// CC1IF [1:1]
        /// Capture/compare 1 interrupt
        CC1IF: u1 = 0,
        /// CC2IF [2:2]
        /// Capture/Compare 2 interrupt
        CC2IF: u1 = 0,
        /// CC3IF [3:3]
        /// Capture/Compare 3 interrupt
        CC3IF: u1 = 0,
        /// CC4IF [4:4]
        /// Capture/Compare 4 interrupt
        CC4IF: u1 = 0,
        /// unused [5:5]
        _unused5: u1 = 0,
        /// TIF [6:6]
        /// Trigger interrupt flag
        TIF: u1 = 0,
        /// unused [7:8]
        _unused7: u1 = 0,
        _unused8: u1 = 0,
        /// CC1OF [9:9]
        /// Capture/Compare 1 overcapture
        CC1OF: u1 = 0,
        /// CC2OF [10:10]
        /// Capture/compare 2 overcapture
        CC2OF: u1 = 0,
        /// CC3OF [11:11]
        /// Capture/Compare 3 overcapture
        CC3OF: u1 = 0,
        /// CC4OF [12:12]
        /// Capture/Compare 4 overcapture
        CC4OF: u1 = 0,
        /// unused [13:31]
        _unused13: u3 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// status register
    pub const SR = Register(SR_val).init(base_address + 0x10);

    /// EGR
    const EGR_val = packed struct {
        /// UG [0:0]
        /// Update generation
        UG: u1 = 0,
        /// CC1G [1:1]
        /// Capture/compare 1
        CC1G: u1 = 0,
        /// CC2G [2:2]
        /// Capture/compare 2
        CC2G: u1 = 0,
        /// CC3G [3:3]
        /// Capture/compare 3
        CC3G: u1 = 0,
        /// CC4G [4:4]
        /// Capture/compare 4
        CC4G: u1 = 0,
        /// unused [5:5]
        _unused5: u1 = 0,
        /// TG [6:6]
        /// Trigger generation
        TG: u1 = 0,
        /// unused [7:31]
        _unused7: u1 = 0,
        _unused8: u8 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// event generation register
    pub const EGR = Register(EGR_val).init(base_address + 0x14);

    /// CCMR1_Output
    const CCMR1_Output_val = packed struct {
        /// CC1S [0:1]
        /// Capture/Compare 1
        CC1S: u2 = 0,
        /// OC1FE [2:2]
        /// Output compare 1 fast
        OC1FE: u1 = 0,
        /// OC1PE [3:3]
        /// Output compare 1 preload
        OC1PE: u1 = 0,
        /// OC1M [4:6]
        /// Output compare 1 mode
        OC1M: u3 = 0,
        /// OC1CE [7:7]
        /// Output compare 1 clear
        OC1CE: u1 = 0,
        /// CC2S [8:9]
        /// Capture/Compare 2
        CC2S: u2 = 0,
        /// OC2FE [10:10]
        /// Output compare 2 fast
        OC2FE: u1 = 0,
        /// OC2PE [11:11]
        /// Output compare 2 preload
        OC2PE: u1 = 0,
        /// OC2M [12:14]
        /// Output compare 2 mode
        OC2M: u3 = 0,
        /// OC2CE [15:15]
        /// Output compare 2 clear
        OC2CE: u1 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// capture/compare mode register 1 (output
    pub const CCMR1_Output = Register(CCMR1_Output_val).init(base_address + 0x18);

    /// CCMR1_Input
    const CCMR1_Input_val = packed struct {
        /// CC1S [0:1]
        /// Capture/Compare 1
        CC1S: u2 = 0,
        /// IC1PSC [2:3]
        /// Input capture 1 prescaler
        IC1PSC: u2 = 0,
        /// IC1F [4:7]
        /// Input capture 1 filter
        IC1F: u4 = 0,
        /// CC2S [8:9]
        /// Capture/compare 2
        CC2S: u2 = 0,
        /// IC2PSC [10:11]
        /// Input capture 2 prescaler
        IC2PSC: u2 = 0,
        /// IC2F [12:15]
        /// Input capture 2 filter
        IC2F: u4 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// capture/compare mode register 1 (input
    pub const CCMR1_Input = Register(CCMR1_Input_val).init(base_address + 0x18);

    /// CCMR2_Output
    const CCMR2_Output_val = packed struct {
        /// CC3S [0:1]
        /// Capture/Compare 3
        CC3S: u2 = 0,
        /// OC3FE [2:2]
        /// Output compare 3 fast
        OC3FE: u1 = 0,
        /// OC3PE [3:3]
        /// Output compare 3 preload
        OC3PE: u1 = 0,
        /// OC3M [4:6]
        /// Output compare 3 mode
        OC3M: u3 = 0,
        /// OC3CE [7:7]
        /// Output compare 3 clear
        OC3CE: u1 = 0,
        /// CC4S [8:9]
        /// Capture/Compare 4
        CC4S: u2 = 0,
        /// OC4FE [10:10]
        /// Output compare 4 fast
        OC4FE: u1 = 0,
        /// OC4PE [11:11]
        /// Output compare 4 preload
        OC4PE: u1 = 0,
        /// OC4M [12:14]
        /// Output compare 4 mode
        OC4M: u3 = 0,
        /// O24CE [15:15]
        /// Output compare 4 clear
        O24CE: u1 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// capture/compare mode register 2 (output
    pub const CCMR2_Output = Register(CCMR2_Output_val).init(base_address + 0x1c);

    /// CCMR2_Input
    const CCMR2_Input_val = packed struct {
        /// CC3S [0:1]
        /// Capture/Compare 3
        CC3S: u2 = 0,
        /// IC3PSC [2:3]
        /// Input capture 3 prescaler
        IC3PSC: u2 = 0,
        /// IC3F [4:7]
        /// Input capture 3 filter
        IC3F: u4 = 0,
        /// CC4S [8:9]
        /// Capture/Compare 4
        CC4S: u2 = 0,
        /// IC4PSC [10:11]
        /// Input capture 4 prescaler
        IC4PSC: u2 = 0,
        /// IC4F [12:15]
        /// Input capture 4 filter
        IC4F: u4 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// capture/compare mode register 2 (input
    pub const CCMR2_Input = Register(CCMR2_Input_val).init(base_address + 0x1c);

    /// CCER
    const CCER_val = packed struct {
        /// CC1E [0:0]
        /// Capture/Compare 1 output
        CC1E: u1 = 0,
        /// CC1P [1:1]
        /// Capture/Compare 1 output
        CC1P: u1 = 0,
        /// unused [2:3]
        _unused2: u2 = 0,
        /// CC2E [4:4]
        /// Capture/Compare 2 output
        CC2E: u1 = 0,
        /// CC2P [5:5]
        /// Capture/Compare 2 output
        CC2P: u1 = 0,
        /// unused [6:7]
        _unused6: u2 = 0,
        /// CC3E [8:8]
        /// Capture/Compare 3 output
        CC3E: u1 = 0,
        /// CC3P [9:9]
        /// Capture/Compare 3 output
        CC3P: u1 = 0,
        /// unused [10:11]
        _unused10: u2 = 0,
        /// CC4E [12:12]
        /// Capture/Compare 4 output
        CC4E: u1 = 0,
        /// CC4P [13:13]
        /// Capture/Compare 3 output
        CC4P: u1 = 0,
        /// unused [14:31]
        _unused14: u2 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// capture/compare enable
    pub const CCER = Register(CCER_val).init(base_address + 0x20);

    /// CNT
    const CNT_val = packed struct {
        /// CNT [0:15]
        /// counter value
        CNT: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// counter
    pub const CNT = Register(CNT_val).init(base_address + 0x24);

    /// PSC
    const PSC_val = packed struct {
        /// PSC [0:15]
        /// Prescaler value
        PSC: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// prescaler
    pub const PSC = Register(PSC_val).init(base_address + 0x28);

    /// ARR
    const ARR_val = packed struct {
        /// ARR [0:15]
        /// Auto-reload value
        ARR: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// auto-reload register
    pub const ARR = Register(ARR_val).init(base_address + 0x2c);

    /// CCR1
    const CCR1_val = packed struct {
        /// CCR1 [0:15]
        /// Capture/Compare 1 value
        CCR1: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// capture/compare register 1
    pub const CCR1 = Register(CCR1_val).init(base_address + 0x34);

    /// CCR2
    const CCR2_val = packed struct {
        /// CCR2 [0:15]
        /// Capture/Compare 2 value
        CCR2: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// capture/compare register 2
    pub const CCR2 = Register(CCR2_val).init(base_address + 0x38);

    /// CCR3
    const CCR3_val = packed struct {
        /// CCR3 [0:15]
        /// Capture/Compare value
        CCR3: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// capture/compare register 3
    pub const CCR3 = Register(CCR3_val).init(base_address + 0x3c);

    /// CCR4
    const CCR4_val = packed struct {
        /// CCR4 [0:15]
        /// Capture/Compare value
        CCR4: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// capture/compare register 4
    pub const CCR4 = Register(CCR4_val).init(base_address + 0x40);

    /// DCR
    const DCR_val = packed struct {
        /// DBA [0:4]
        /// DMA base address
        DBA: u5 = 0,
        /// unused [5:7]
        _unused5: u3 = 0,
        /// DBL [8:12]
        /// DMA burst length
        DBL: u5 = 0,
        /// unused [13:31]
        _unused13: u3 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// DMA control register
    pub const DCR = Register(DCR_val).init(base_address + 0x48);

    /// DMAR
    const DMAR_val = packed struct {
        /// DMAB [0:15]
        /// DMA register for burst
        DMAB: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// DMA address for full transfer
    pub const DMAR = Register(DMAR_val).init(base_address + 0x4c);
};

/// General purpose timer
pub const TIM3 = struct {
    const base_address = 0x40000400;
    /// CR1
    const CR1_val = packed struct {
        /// CEN [0:0]
        /// Counter enable
        CEN: u1 = 0,
        /// UDIS [1:1]
        /// Update disable
        UDIS: u1 = 0,
        /// URS [2:2]
        /// Update request source
        URS: u1 = 0,
        /// OPM [3:3]
        /// One-pulse mode
        OPM: u1 = 0,
        /// DIR [4:4]
        /// Direction
        DIR: u1 = 0,
        /// CMS [5:6]
        /// Center-aligned mode
        CMS: u2 = 0,
        /// ARPE [7:7]
        /// Auto-reload preload enable
        ARPE: u1 = 0,
        /// CKD [8:9]
        /// Clock division
        CKD: u2 = 0,
        /// unused [10:31]
        _unused10: u6 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// control register 1
    pub const CR1 = Register(CR1_val).init(base_address + 0x0);

    /// CR2
    const CR2_val = packed struct {
        /// unused [0:2]
        _unused0: u3 = 0,
        /// CCDS [3:3]
        /// Capture/compare DMA
        CCDS: u1 = 0,
        /// MMS [4:6]
        /// Master mode selection
        MMS: u3 = 0,
        /// TI1S [7:7]
        /// TI1 selection
        TI1S: u1 = 0,
        /// unused [8:31]
        _unused8: u8 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// control register 2
    pub const CR2 = Register(CR2_val).init(base_address + 0x4);

    /// SMCR
    const SMCR_val = packed struct {
        /// SMS [0:2]
        /// Slave mode selection
        SMS: u3 = 0,
        /// unused [3:3]
        _unused3: u1 = 0,
        /// TS [4:6]
        /// Trigger selection
        TS: u3 = 0,
        /// MSM [7:7]
        /// Master/Slave mode
        MSM: u1 = 0,
        /// ETF [8:11]
        /// External trigger filter
        ETF: u4 = 0,
        /// ETPS [12:13]
        /// External trigger prescaler
        ETPS: u2 = 0,
        /// ECE [14:14]
        /// External clock enable
        ECE: u1 = 0,
        /// ETP [15:15]
        /// External trigger polarity
        ETP: u1 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// slave mode control register
    pub const SMCR = Register(SMCR_val).init(base_address + 0x8);

    /// DIER
    const DIER_val = packed struct {
        /// UIE [0:0]
        /// Update interrupt enable
        UIE: u1 = 0,
        /// CC1IE [1:1]
        /// Capture/Compare 1 interrupt
        CC1IE: u1 = 0,
        /// CC2IE [2:2]
        /// Capture/Compare 2 interrupt
        CC2IE: u1 = 0,
        /// CC3IE [3:3]
        /// Capture/Compare 3 interrupt
        CC3IE: u1 = 0,
        /// CC4IE [4:4]
        /// Capture/Compare 4 interrupt
        CC4IE: u1 = 0,
        /// unused [5:5]
        _unused5: u1 = 0,
        /// TIE [6:6]
        /// Trigger interrupt enable
        TIE: u1 = 0,
        /// unused [7:7]
        _unused7: u1 = 0,
        /// UDE [8:8]
        /// Update DMA request enable
        UDE: u1 = 0,
        /// CC1DE [9:9]
        /// Capture/Compare 1 DMA request
        CC1DE: u1 = 0,
        /// CC2DE [10:10]
        /// Capture/Compare 2 DMA request
        CC2DE: u1 = 0,
        /// CC3DE [11:11]
        /// Capture/Compare 3 DMA request
        CC3DE: u1 = 0,
        /// CC4DE [12:12]
        /// Capture/Compare 4 DMA request
        CC4DE: u1 = 0,
        /// unused [13:13]
        _unused13: u1 = 0,
        /// TDE [14:14]
        /// Trigger DMA request enable
        TDE: u1 = 0,
        /// unused [15:31]
        _unused15: u1 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// DMA/Interrupt enable register
    pub const DIER = Register(DIER_val).init(base_address + 0xc);

    /// SR
    const SR_val = packed struct {
        /// UIF [0:0]
        /// Update interrupt flag
        UIF: u1 = 0,
        /// CC1IF [1:1]
        /// Capture/compare 1 interrupt
        CC1IF: u1 = 0,
        /// CC2IF [2:2]
        /// Capture/Compare 2 interrupt
        CC2IF: u1 = 0,
        /// CC3IF [3:3]
        /// Capture/Compare 3 interrupt
        CC3IF: u1 = 0,
        /// CC4IF [4:4]
        /// Capture/Compare 4 interrupt
        CC4IF: u1 = 0,
        /// unused [5:5]
        _unused5: u1 = 0,
        /// TIF [6:6]
        /// Trigger interrupt flag
        TIF: u1 = 0,
        /// unused [7:8]
        _unused7: u1 = 0,
        _unused8: u1 = 0,
        /// CC1OF [9:9]
        /// Capture/Compare 1 overcapture
        CC1OF: u1 = 0,
        /// CC2OF [10:10]
        /// Capture/compare 2 overcapture
        CC2OF: u1 = 0,
        /// CC3OF [11:11]
        /// Capture/Compare 3 overcapture
        CC3OF: u1 = 0,
        /// CC4OF [12:12]
        /// Capture/Compare 4 overcapture
        CC4OF: u1 = 0,
        /// unused [13:31]
        _unused13: u3 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// status register
    pub const SR = Register(SR_val).init(base_address + 0x10);

    /// EGR
    const EGR_val = packed struct {
        /// UG [0:0]
        /// Update generation
        UG: u1 = 0,
        /// CC1G [1:1]
        /// Capture/compare 1
        CC1G: u1 = 0,
        /// CC2G [2:2]
        /// Capture/compare 2
        CC2G: u1 = 0,
        /// CC3G [3:3]
        /// Capture/compare 3
        CC3G: u1 = 0,
        /// CC4G [4:4]
        /// Capture/compare 4
        CC4G: u1 = 0,
        /// unused [5:5]
        _unused5: u1 = 0,
        /// TG [6:6]
        /// Trigger generation
        TG: u1 = 0,
        /// unused [7:31]
        _unused7: u1 = 0,
        _unused8: u8 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// event generation register
    pub const EGR = Register(EGR_val).init(base_address + 0x14);

    /// CCMR1_Output
    const CCMR1_Output_val = packed struct {
        /// CC1S [0:1]
        /// Capture/Compare 1
        CC1S: u2 = 0,
        /// OC1FE [2:2]
        /// Output compare 1 fast
        OC1FE: u1 = 0,
        /// OC1PE [3:3]
        /// Output compare 1 preload
        OC1PE: u1 = 0,
        /// OC1M [4:6]
        /// Output compare 1 mode
        OC1M: u3 = 0,
        /// OC1CE [7:7]
        /// Output compare 1 clear
        OC1CE: u1 = 0,
        /// CC2S [8:9]
        /// Capture/Compare 2
        CC2S: u2 = 0,
        /// OC2FE [10:10]
        /// Output compare 2 fast
        OC2FE: u1 = 0,
        /// OC2PE [11:11]
        /// Output compare 2 preload
        OC2PE: u1 = 0,
        /// OC2M [12:14]
        /// Output compare 2 mode
        OC2M: u3 = 0,
        /// OC2CE [15:15]
        /// Output compare 2 clear
        OC2CE: u1 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// capture/compare mode register 1 (output
    pub const CCMR1_Output = Register(CCMR1_Output_val).init(base_address + 0x18);

    /// CCMR1_Input
    const CCMR1_Input_val = packed struct {
        /// CC1S [0:1]
        /// Capture/Compare 1
        CC1S: u2 = 0,
        /// IC1PSC [2:3]
        /// Input capture 1 prescaler
        IC1PSC: u2 = 0,
        /// IC1F [4:7]
        /// Input capture 1 filter
        IC1F: u4 = 0,
        /// CC2S [8:9]
        /// Capture/compare 2
        CC2S: u2 = 0,
        /// IC2PSC [10:11]
        /// Input capture 2 prescaler
        IC2PSC: u2 = 0,
        /// IC2F [12:15]
        /// Input capture 2 filter
        IC2F: u4 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// capture/compare mode register 1 (input
    pub const CCMR1_Input = Register(CCMR1_Input_val).init(base_address + 0x18);

    /// CCMR2_Output
    const CCMR2_Output_val = packed struct {
        /// CC3S [0:1]
        /// Capture/Compare 3
        CC3S: u2 = 0,
        /// OC3FE [2:2]
        /// Output compare 3 fast
        OC3FE: u1 = 0,
        /// OC3PE [3:3]
        /// Output compare 3 preload
        OC3PE: u1 = 0,
        /// OC3M [4:6]
        /// Output compare 3 mode
        OC3M: u3 = 0,
        /// OC3CE [7:7]
        /// Output compare 3 clear
        OC3CE: u1 = 0,
        /// CC4S [8:9]
        /// Capture/Compare 4
        CC4S: u2 = 0,
        /// OC4FE [10:10]
        /// Output compare 4 fast
        OC4FE: u1 = 0,
        /// OC4PE [11:11]
        /// Output compare 4 preload
        OC4PE: u1 = 0,
        /// OC4M [12:14]
        /// Output compare 4 mode
        OC4M: u3 = 0,
        /// O24CE [15:15]
        /// Output compare 4 clear
        O24CE: u1 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// capture/compare mode register 2 (output
    pub const CCMR2_Output = Register(CCMR2_Output_val).init(base_address + 0x1c);

    /// CCMR2_Input
    const CCMR2_Input_val = packed struct {
        /// CC3S [0:1]
        /// Capture/Compare 3
        CC3S: u2 = 0,
        /// IC3PSC [2:3]
        /// Input capture 3 prescaler
        IC3PSC: u2 = 0,
        /// IC3F [4:7]
        /// Input capture 3 filter
        IC3F: u4 = 0,
        /// CC4S [8:9]
        /// Capture/Compare 4
        CC4S: u2 = 0,
        /// IC4PSC [10:11]
        /// Input capture 4 prescaler
        IC4PSC: u2 = 0,
        /// IC4F [12:15]
        /// Input capture 4 filter
        IC4F: u4 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// capture/compare mode register 2 (input
    pub const CCMR2_Input = Register(CCMR2_Input_val).init(base_address + 0x1c);

    /// CCER
    const CCER_val = packed struct {
        /// CC1E [0:0]
        /// Capture/Compare 1 output
        CC1E: u1 = 0,
        /// CC1P [1:1]
        /// Capture/Compare 1 output
        CC1P: u1 = 0,
        /// unused [2:3]
        _unused2: u2 = 0,
        /// CC2E [4:4]
        /// Capture/Compare 2 output
        CC2E: u1 = 0,
        /// CC2P [5:5]
        /// Capture/Compare 2 output
        CC2P: u1 = 0,
        /// unused [6:7]
        _unused6: u2 = 0,
        /// CC3E [8:8]
        /// Capture/Compare 3 output
        CC3E: u1 = 0,
        /// CC3P [9:9]
        /// Capture/Compare 3 output
        CC3P: u1 = 0,
        /// unused [10:11]
        _unused10: u2 = 0,
        /// CC4E [12:12]
        /// Capture/Compare 4 output
        CC4E: u1 = 0,
        /// CC4P [13:13]
        /// Capture/Compare 3 output
        CC4P: u1 = 0,
        /// unused [14:31]
        _unused14: u2 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// capture/compare enable
    pub const CCER = Register(CCER_val).init(base_address + 0x20);

    /// CNT
    const CNT_val = packed struct {
        /// CNT [0:15]
        /// counter value
        CNT: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// counter
    pub const CNT = Register(CNT_val).init(base_address + 0x24);

    /// PSC
    const PSC_val = packed struct {
        /// PSC [0:15]
        /// Prescaler value
        PSC: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// prescaler
    pub const PSC = Register(PSC_val).init(base_address + 0x28);

    /// ARR
    const ARR_val = packed struct {
        /// ARR [0:15]
        /// Auto-reload value
        ARR: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// auto-reload register
    pub const ARR = Register(ARR_val).init(base_address + 0x2c);

    /// CCR1
    const CCR1_val = packed struct {
        /// CCR1 [0:15]
        /// Capture/Compare 1 value
        CCR1: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// capture/compare register 1
    pub const CCR1 = Register(CCR1_val).init(base_address + 0x34);

    /// CCR2
    const CCR2_val = packed struct {
        /// CCR2 [0:15]
        /// Capture/Compare 2 value
        CCR2: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// capture/compare register 2
    pub const CCR2 = Register(CCR2_val).init(base_address + 0x38);

    /// CCR3
    const CCR3_val = packed struct {
        /// CCR3 [0:15]
        /// Capture/Compare value
        CCR3: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// capture/compare register 3
    pub const CCR3 = Register(CCR3_val).init(base_address + 0x3c);

    /// CCR4
    const CCR4_val = packed struct {
        /// CCR4 [0:15]
        /// Capture/Compare value
        CCR4: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// capture/compare register 4
    pub const CCR4 = Register(CCR4_val).init(base_address + 0x40);

    /// DCR
    const DCR_val = packed struct {
        /// DBA [0:4]
        /// DMA base address
        DBA: u5 = 0,
        /// unused [5:7]
        _unused5: u3 = 0,
        /// DBL [8:12]
        /// DMA burst length
        DBL: u5 = 0,
        /// unused [13:31]
        _unused13: u3 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// DMA control register
    pub const DCR = Register(DCR_val).init(base_address + 0x48);

    /// DMAR
    const DMAR_val = packed struct {
        /// DMAB [0:15]
        /// DMA register for burst
        DMAB: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// DMA address for full transfer
    pub const DMAR = Register(DMAR_val).init(base_address + 0x4c);
};

/// General purpose timer
pub const TIM4 = struct {
    const base_address = 0x40000800;
    /// CR1
    const CR1_val = packed struct {
        /// CEN [0:0]
        /// Counter enable
        CEN: u1 = 0,
        /// UDIS [1:1]
        /// Update disable
        UDIS: u1 = 0,
        /// URS [2:2]
        /// Update request source
        URS: u1 = 0,
        /// OPM [3:3]
        /// One-pulse mode
        OPM: u1 = 0,
        /// DIR [4:4]
        /// Direction
        DIR: u1 = 0,
        /// CMS [5:6]
        /// Center-aligned mode
        CMS: u2 = 0,
        /// ARPE [7:7]
        /// Auto-reload preload enable
        ARPE: u1 = 0,
        /// CKD [8:9]
        /// Clock division
        CKD: u2 = 0,
        /// unused [10:31]
        _unused10: u6 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// control register 1
    pub const CR1 = Register(CR1_val).init(base_address + 0x0);

    /// CR2
    const CR2_val = packed struct {
        /// unused [0:2]
        _unused0: u3 = 0,
        /// CCDS [3:3]
        /// Capture/compare DMA
        CCDS: u1 = 0,
        /// MMS [4:6]
        /// Master mode selection
        MMS: u3 = 0,
        /// TI1S [7:7]
        /// TI1 selection
        TI1S: u1 = 0,
        /// unused [8:31]
        _unused8: u8 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// control register 2
    pub const CR2 = Register(CR2_val).init(base_address + 0x4);

    /// SMCR
    const SMCR_val = packed struct {
        /// SMS [0:2]
        /// Slave mode selection
        SMS: u3 = 0,
        /// unused [3:3]
        _unused3: u1 = 0,
        /// TS [4:6]
        /// Trigger selection
        TS: u3 = 0,
        /// MSM [7:7]
        /// Master/Slave mode
        MSM: u1 = 0,
        /// ETF [8:11]
        /// External trigger filter
        ETF: u4 = 0,
        /// ETPS [12:13]
        /// External trigger prescaler
        ETPS: u2 = 0,
        /// ECE [14:14]
        /// External clock enable
        ECE: u1 = 0,
        /// ETP [15:15]
        /// External trigger polarity
        ETP: u1 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// slave mode control register
    pub const SMCR = Register(SMCR_val).init(base_address + 0x8);

    /// DIER
    const DIER_val = packed struct {
        /// UIE [0:0]
        /// Update interrupt enable
        UIE: u1 = 0,
        /// CC1IE [1:1]
        /// Capture/Compare 1 interrupt
        CC1IE: u1 = 0,
        /// CC2IE [2:2]
        /// Capture/Compare 2 interrupt
        CC2IE: u1 = 0,
        /// CC3IE [3:3]
        /// Capture/Compare 3 interrupt
        CC3IE: u1 = 0,
        /// CC4IE [4:4]
        /// Capture/Compare 4 interrupt
        CC4IE: u1 = 0,
        /// unused [5:5]
        _unused5: u1 = 0,
        /// TIE [6:6]
        /// Trigger interrupt enable
        TIE: u1 = 0,
        /// unused [7:7]
        _unused7: u1 = 0,
        /// UDE [8:8]
        /// Update DMA request enable
        UDE: u1 = 0,
        /// CC1DE [9:9]
        /// Capture/Compare 1 DMA request
        CC1DE: u1 = 0,
        /// CC2DE [10:10]
        /// Capture/Compare 2 DMA request
        CC2DE: u1 = 0,
        /// CC3DE [11:11]
        /// Capture/Compare 3 DMA request
        CC3DE: u1 = 0,
        /// CC4DE [12:12]
        /// Capture/Compare 4 DMA request
        CC4DE: u1 = 0,
        /// unused [13:13]
        _unused13: u1 = 0,
        /// TDE [14:14]
        /// Trigger DMA request enable
        TDE: u1 = 0,
        /// unused [15:31]
        _unused15: u1 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// DMA/Interrupt enable register
    pub const DIER = Register(DIER_val).init(base_address + 0xc);

    /// SR
    const SR_val = packed struct {
        /// UIF [0:0]
        /// Update interrupt flag
        UIF: u1 = 0,
        /// CC1IF [1:1]
        /// Capture/compare 1 interrupt
        CC1IF: u1 = 0,
        /// CC2IF [2:2]
        /// Capture/Compare 2 interrupt
        CC2IF: u1 = 0,
        /// CC3IF [3:3]
        /// Capture/Compare 3 interrupt
        CC3IF: u1 = 0,
        /// CC4IF [4:4]
        /// Capture/Compare 4 interrupt
        CC4IF: u1 = 0,
        /// unused [5:5]
        _unused5: u1 = 0,
        /// TIF [6:6]
        /// Trigger interrupt flag
        TIF: u1 = 0,
        /// unused [7:8]
        _unused7: u1 = 0,
        _unused8: u1 = 0,
        /// CC1OF [9:9]
        /// Capture/Compare 1 overcapture
        CC1OF: u1 = 0,
        /// CC2OF [10:10]
        /// Capture/compare 2 overcapture
        CC2OF: u1 = 0,
        /// CC3OF [11:11]
        /// Capture/Compare 3 overcapture
        CC3OF: u1 = 0,
        /// CC4OF [12:12]
        /// Capture/Compare 4 overcapture
        CC4OF: u1 = 0,
        /// unused [13:31]
        _unused13: u3 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// status register
    pub const SR = Register(SR_val).init(base_address + 0x10);

    /// EGR
    const EGR_val = packed struct {
        /// UG [0:0]
        /// Update generation
        UG: u1 = 0,
        /// CC1G [1:1]
        /// Capture/compare 1
        CC1G: u1 = 0,
        /// CC2G [2:2]
        /// Capture/compare 2
        CC2G: u1 = 0,
        /// CC3G [3:3]
        /// Capture/compare 3
        CC3G: u1 = 0,
        /// CC4G [4:4]
        /// Capture/compare 4
        CC4G: u1 = 0,
        /// unused [5:5]
        _unused5: u1 = 0,
        /// TG [6:6]
        /// Trigger generation
        TG: u1 = 0,
        /// unused [7:31]
        _unused7: u1 = 0,
        _unused8: u8 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// event generation register
    pub const EGR = Register(EGR_val).init(base_address + 0x14);

    /// CCMR1_Output
    const CCMR1_Output_val = packed struct {
        /// CC1S [0:1]
        /// Capture/Compare 1
        CC1S: u2 = 0,
        /// OC1FE [2:2]
        /// Output compare 1 fast
        OC1FE: u1 = 0,
        /// OC1PE [3:3]
        /// Output compare 1 preload
        OC1PE: u1 = 0,
        /// OC1M [4:6]
        /// Output compare 1 mode
        OC1M: u3 = 0,
        /// OC1CE [7:7]
        /// Output compare 1 clear
        OC1CE: u1 = 0,
        /// CC2S [8:9]
        /// Capture/Compare 2
        CC2S: u2 = 0,
        /// OC2FE [10:10]
        /// Output compare 2 fast
        OC2FE: u1 = 0,
        /// OC2PE [11:11]
        /// Output compare 2 preload
        OC2PE: u1 = 0,
        /// OC2M [12:14]
        /// Output compare 2 mode
        OC2M: u3 = 0,
        /// OC2CE [15:15]
        /// Output compare 2 clear
        OC2CE: u1 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// capture/compare mode register 1 (output
    pub const CCMR1_Output = Register(CCMR1_Output_val).init(base_address + 0x18);

    /// CCMR1_Input
    const CCMR1_Input_val = packed struct {
        /// CC1S [0:1]
        /// Capture/Compare 1
        CC1S: u2 = 0,
        /// IC1PSC [2:3]
        /// Input capture 1 prescaler
        IC1PSC: u2 = 0,
        /// IC1F [4:7]
        /// Input capture 1 filter
        IC1F: u4 = 0,
        /// CC2S [8:9]
        /// Capture/compare 2
        CC2S: u2 = 0,
        /// IC2PSC [10:11]
        /// Input capture 2 prescaler
        IC2PSC: u2 = 0,
        /// IC2F [12:15]
        /// Input capture 2 filter
        IC2F: u4 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// capture/compare mode register 1 (input
    pub const CCMR1_Input = Register(CCMR1_Input_val).init(base_address + 0x18);

    /// CCMR2_Output
    const CCMR2_Output_val = packed struct {
        /// CC3S [0:1]
        /// Capture/Compare 3
        CC3S: u2 = 0,
        /// OC3FE [2:2]
        /// Output compare 3 fast
        OC3FE: u1 = 0,
        /// OC3PE [3:3]
        /// Output compare 3 preload
        OC3PE: u1 = 0,
        /// OC3M [4:6]
        /// Output compare 3 mode
        OC3M: u3 = 0,
        /// OC3CE [7:7]
        /// Output compare 3 clear
        OC3CE: u1 = 0,
        /// CC4S [8:9]
        /// Capture/Compare 4
        CC4S: u2 = 0,
        /// OC4FE [10:10]
        /// Output compare 4 fast
        OC4FE: u1 = 0,
        /// OC4PE [11:11]
        /// Output compare 4 preload
        OC4PE: u1 = 0,
        /// OC4M [12:14]
        /// Output compare 4 mode
        OC4M: u3 = 0,
        /// O24CE [15:15]
        /// Output compare 4 clear
        O24CE: u1 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// capture/compare mode register 2 (output
    pub const CCMR2_Output = Register(CCMR2_Output_val).init(base_address + 0x1c);

    /// CCMR2_Input
    const CCMR2_Input_val = packed struct {
        /// CC3S [0:1]
        /// Capture/Compare 3
        CC3S: u2 = 0,
        /// IC3PSC [2:3]
        /// Input capture 3 prescaler
        IC3PSC: u2 = 0,
        /// IC3F [4:7]
        /// Input capture 3 filter
        IC3F: u4 = 0,
        /// CC4S [8:9]
        /// Capture/Compare 4
        CC4S: u2 = 0,
        /// IC4PSC [10:11]
        /// Input capture 4 prescaler
        IC4PSC: u2 = 0,
        /// IC4F [12:15]
        /// Input capture 4 filter
        IC4F: u4 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// capture/compare mode register 2 (input
    pub const CCMR2_Input = Register(CCMR2_Input_val).init(base_address + 0x1c);

    /// CCER
    const CCER_val = packed struct {
        /// CC1E [0:0]
        /// Capture/Compare 1 output
        CC1E: u1 = 0,
        /// CC1P [1:1]
        /// Capture/Compare 1 output
        CC1P: u1 = 0,
        /// unused [2:3]
        _unused2: u2 = 0,
        /// CC2E [4:4]
        /// Capture/Compare 2 output
        CC2E: u1 = 0,
        /// CC2P [5:5]
        /// Capture/Compare 2 output
        CC2P: u1 = 0,
        /// unused [6:7]
        _unused6: u2 = 0,
        /// CC3E [8:8]
        /// Capture/Compare 3 output
        CC3E: u1 = 0,
        /// CC3P [9:9]
        /// Capture/Compare 3 output
        CC3P: u1 = 0,
        /// unused [10:11]
        _unused10: u2 = 0,
        /// CC4E [12:12]
        /// Capture/Compare 4 output
        CC4E: u1 = 0,
        /// CC4P [13:13]
        /// Capture/Compare 3 output
        CC4P: u1 = 0,
        /// unused [14:31]
        _unused14: u2 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// capture/compare enable
    pub const CCER = Register(CCER_val).init(base_address + 0x20);

    /// CNT
    const CNT_val = packed struct {
        /// CNT [0:15]
        /// counter value
        CNT: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// counter
    pub const CNT = Register(CNT_val).init(base_address + 0x24);

    /// PSC
    const PSC_val = packed struct {
        /// PSC [0:15]
        /// Prescaler value
        PSC: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// prescaler
    pub const PSC = Register(PSC_val).init(base_address + 0x28);

    /// ARR
    const ARR_val = packed struct {
        /// ARR [0:15]
        /// Auto-reload value
        ARR: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// auto-reload register
    pub const ARR = Register(ARR_val).init(base_address + 0x2c);

    /// CCR1
    const CCR1_val = packed struct {
        /// CCR1 [0:15]
        /// Capture/Compare 1 value
        CCR1: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// capture/compare register 1
    pub const CCR1 = Register(CCR1_val).init(base_address + 0x34);

    /// CCR2
    const CCR2_val = packed struct {
        /// CCR2 [0:15]
        /// Capture/Compare 2 value
        CCR2: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// capture/compare register 2
    pub const CCR2 = Register(CCR2_val).init(base_address + 0x38);

    /// CCR3
    const CCR3_val = packed struct {
        /// CCR3 [0:15]
        /// Capture/Compare value
        CCR3: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// capture/compare register 3
    pub const CCR3 = Register(CCR3_val).init(base_address + 0x3c);

    /// CCR4
    const CCR4_val = packed struct {
        /// CCR4 [0:15]
        /// Capture/Compare value
        CCR4: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// capture/compare register 4
    pub const CCR4 = Register(CCR4_val).init(base_address + 0x40);

    /// DCR
    const DCR_val = packed struct {
        /// DBA [0:4]
        /// DMA base address
        DBA: u5 = 0,
        /// unused [5:7]
        _unused5: u3 = 0,
        /// DBL [8:12]
        /// DMA burst length
        DBL: u5 = 0,
        /// unused [13:31]
        _unused13: u3 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// DMA control register
    pub const DCR = Register(DCR_val).init(base_address + 0x48);

    /// DMAR
    const DMAR_val = packed struct {
        /// DMAB [0:15]
        /// DMA register for burst
        DMAB: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// DMA address for full transfer
    pub const DMAR = Register(DMAR_val).init(base_address + 0x4c);
};

/// General purpose timer
pub const TIM5 = struct {
    const base_address = 0x40000c00;
    /// CR1
    const CR1_val = packed struct {
        /// CEN [0:0]
        /// Counter enable
        CEN: u1 = 0,
        /// UDIS [1:1]
        /// Update disable
        UDIS: u1 = 0,
        /// URS [2:2]
        /// Update request source
        URS: u1 = 0,
        /// OPM [3:3]
        /// One-pulse mode
        OPM: u1 = 0,
        /// DIR [4:4]
        /// Direction
        DIR: u1 = 0,
        /// CMS [5:6]
        /// Center-aligned mode
        CMS: u2 = 0,
        /// ARPE [7:7]
        /// Auto-reload preload enable
        ARPE: u1 = 0,
        /// CKD [8:9]
        /// Clock division
        CKD: u2 = 0,
        /// unused [10:31]
        _unused10: u6 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// control register 1
    pub const CR1 = Register(CR1_val).init(base_address + 0x0);

    /// CR2
    const CR2_val = packed struct {
        /// unused [0:2]
        _unused0: u3 = 0,
        /// CCDS [3:3]
        /// Capture/compare DMA
        CCDS: u1 = 0,
        /// MMS [4:6]
        /// Master mode selection
        MMS: u3 = 0,
        /// TI1S [7:7]
        /// TI1 selection
        TI1S: u1 = 0,
        /// unused [8:31]
        _unused8: u8 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// control register 2
    pub const CR2 = Register(CR2_val).init(base_address + 0x4);

    /// SMCR
    const SMCR_val = packed struct {
        /// SMS [0:2]
        /// Slave mode selection
        SMS: u3 = 0,
        /// unused [3:3]
        _unused3: u1 = 0,
        /// TS [4:6]
        /// Trigger selection
        TS: u3 = 0,
        /// MSM [7:7]
        /// Master/Slave mode
        MSM: u1 = 0,
        /// ETF [8:11]
        /// External trigger filter
        ETF: u4 = 0,
        /// ETPS [12:13]
        /// External trigger prescaler
        ETPS: u2 = 0,
        /// ECE [14:14]
        /// External clock enable
        ECE: u1 = 0,
        /// ETP [15:15]
        /// External trigger polarity
        ETP: u1 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// slave mode control register
    pub const SMCR = Register(SMCR_val).init(base_address + 0x8);

    /// DIER
    const DIER_val = packed struct {
        /// UIE [0:0]
        /// Update interrupt enable
        UIE: u1 = 0,
        /// CC1IE [1:1]
        /// Capture/Compare 1 interrupt
        CC1IE: u1 = 0,
        /// CC2IE [2:2]
        /// Capture/Compare 2 interrupt
        CC2IE: u1 = 0,
        /// CC3IE [3:3]
        /// Capture/Compare 3 interrupt
        CC3IE: u1 = 0,
        /// CC4IE [4:4]
        /// Capture/Compare 4 interrupt
        CC4IE: u1 = 0,
        /// unused [5:5]
        _unused5: u1 = 0,
        /// TIE [6:6]
        /// Trigger interrupt enable
        TIE: u1 = 0,
        /// unused [7:7]
        _unused7: u1 = 0,
        /// UDE [8:8]
        /// Update DMA request enable
        UDE: u1 = 0,
        /// CC1DE [9:9]
        /// Capture/Compare 1 DMA request
        CC1DE: u1 = 0,
        /// CC2DE [10:10]
        /// Capture/Compare 2 DMA request
        CC2DE: u1 = 0,
        /// CC3DE [11:11]
        /// Capture/Compare 3 DMA request
        CC3DE: u1 = 0,
        /// CC4DE [12:12]
        /// Capture/Compare 4 DMA request
        CC4DE: u1 = 0,
        /// unused [13:13]
        _unused13: u1 = 0,
        /// TDE [14:14]
        /// Trigger DMA request enable
        TDE: u1 = 0,
        /// unused [15:31]
        _unused15: u1 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// DMA/Interrupt enable register
    pub const DIER = Register(DIER_val).init(base_address + 0xc);

    /// SR
    const SR_val = packed struct {
        /// UIF [0:0]
        /// Update interrupt flag
        UIF: u1 = 0,
        /// CC1IF [1:1]
        /// Capture/compare 1 interrupt
        CC1IF: u1 = 0,
        /// CC2IF [2:2]
        /// Capture/Compare 2 interrupt
        CC2IF: u1 = 0,
        /// CC3IF [3:3]
        /// Capture/Compare 3 interrupt
        CC3IF: u1 = 0,
        /// CC4IF [4:4]
        /// Capture/Compare 4 interrupt
        CC4IF: u1 = 0,
        /// unused [5:5]
        _unused5: u1 = 0,
        /// TIF [6:6]
        /// Trigger interrupt flag
        TIF: u1 = 0,
        /// unused [7:8]
        _unused7: u1 = 0,
        _unused8: u1 = 0,
        /// CC1OF [9:9]
        /// Capture/Compare 1 overcapture
        CC1OF: u1 = 0,
        /// CC2OF [10:10]
        /// Capture/compare 2 overcapture
        CC2OF: u1 = 0,
        /// CC3OF [11:11]
        /// Capture/Compare 3 overcapture
        CC3OF: u1 = 0,
        /// CC4OF [12:12]
        /// Capture/Compare 4 overcapture
        CC4OF: u1 = 0,
        /// unused [13:31]
        _unused13: u3 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// status register
    pub const SR = Register(SR_val).init(base_address + 0x10);

    /// EGR
    const EGR_val = packed struct {
        /// UG [0:0]
        /// Update generation
        UG: u1 = 0,
        /// CC1G [1:1]
        /// Capture/compare 1
        CC1G: u1 = 0,
        /// CC2G [2:2]
        /// Capture/compare 2
        CC2G: u1 = 0,
        /// CC3G [3:3]
        /// Capture/compare 3
        CC3G: u1 = 0,
        /// CC4G [4:4]
        /// Capture/compare 4
        CC4G: u1 = 0,
        /// unused [5:5]
        _unused5: u1 = 0,
        /// TG [6:6]
        /// Trigger generation
        TG: u1 = 0,
        /// unused [7:31]
        _unused7: u1 = 0,
        _unused8: u8 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// event generation register
    pub const EGR = Register(EGR_val).init(base_address + 0x14);

    /// CCMR1_Output
    const CCMR1_Output_val = packed struct {
        /// CC1S [0:1]
        /// Capture/Compare 1
        CC1S: u2 = 0,
        /// OC1FE [2:2]
        /// Output compare 1 fast
        OC1FE: u1 = 0,
        /// OC1PE [3:3]
        /// Output compare 1 preload
        OC1PE: u1 = 0,
        /// OC1M [4:6]
        /// Output compare 1 mode
        OC1M: u3 = 0,
        /// OC1CE [7:7]
        /// Output compare 1 clear
        OC1CE: u1 = 0,
        /// CC2S [8:9]
        /// Capture/Compare 2
        CC2S: u2 = 0,
        /// OC2FE [10:10]
        /// Output compare 2 fast
        OC2FE: u1 = 0,
        /// OC2PE [11:11]
        /// Output compare 2 preload
        OC2PE: u1 = 0,
        /// OC2M [12:14]
        /// Output compare 2 mode
        OC2M: u3 = 0,
        /// OC2CE [15:15]
        /// Output compare 2 clear
        OC2CE: u1 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// capture/compare mode register 1 (output
    pub const CCMR1_Output = Register(CCMR1_Output_val).init(base_address + 0x18);

    /// CCMR1_Input
    const CCMR1_Input_val = packed struct {
        /// CC1S [0:1]
        /// Capture/Compare 1
        CC1S: u2 = 0,
        /// IC1PSC [2:3]
        /// Input capture 1 prescaler
        IC1PSC: u2 = 0,
        /// IC1F [4:7]
        /// Input capture 1 filter
        IC1F: u4 = 0,
        /// CC2S [8:9]
        /// Capture/compare 2
        CC2S: u2 = 0,
        /// IC2PSC [10:11]
        /// Input capture 2 prescaler
        IC2PSC: u2 = 0,
        /// IC2F [12:15]
        /// Input capture 2 filter
        IC2F: u4 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// capture/compare mode register 1 (input
    pub const CCMR1_Input = Register(CCMR1_Input_val).init(base_address + 0x18);

    /// CCMR2_Output
    const CCMR2_Output_val = packed struct {
        /// CC3S [0:1]
        /// Capture/Compare 3
        CC3S: u2 = 0,
        /// OC3FE [2:2]
        /// Output compare 3 fast
        OC3FE: u1 = 0,
        /// OC3PE [3:3]
        /// Output compare 3 preload
        OC3PE: u1 = 0,
        /// OC3M [4:6]
        /// Output compare 3 mode
        OC3M: u3 = 0,
        /// OC3CE [7:7]
        /// Output compare 3 clear
        OC3CE: u1 = 0,
        /// CC4S [8:9]
        /// Capture/Compare 4
        CC4S: u2 = 0,
        /// OC4FE [10:10]
        /// Output compare 4 fast
        OC4FE: u1 = 0,
        /// OC4PE [11:11]
        /// Output compare 4 preload
        OC4PE: u1 = 0,
        /// OC4M [12:14]
        /// Output compare 4 mode
        OC4M: u3 = 0,
        /// O24CE [15:15]
        /// Output compare 4 clear
        O24CE: u1 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// capture/compare mode register 2 (output
    pub const CCMR2_Output = Register(CCMR2_Output_val).init(base_address + 0x1c);

    /// CCMR2_Input
    const CCMR2_Input_val = packed struct {
        /// CC3S [0:1]
        /// Capture/Compare 3
        CC3S: u2 = 0,
        /// IC3PSC [2:3]
        /// Input capture 3 prescaler
        IC3PSC: u2 = 0,
        /// IC3F [4:7]
        /// Input capture 3 filter
        IC3F: u4 = 0,
        /// CC4S [8:9]
        /// Capture/Compare 4
        CC4S: u2 = 0,
        /// IC4PSC [10:11]
        /// Input capture 4 prescaler
        IC4PSC: u2 = 0,
        /// IC4F [12:15]
        /// Input capture 4 filter
        IC4F: u4 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// capture/compare mode register 2 (input
    pub const CCMR2_Input = Register(CCMR2_Input_val).init(base_address + 0x1c);

    /// CCER
    const CCER_val = packed struct {
        /// CC1E [0:0]
        /// Capture/Compare 1 output
        CC1E: u1 = 0,
        /// CC1P [1:1]
        /// Capture/Compare 1 output
        CC1P: u1 = 0,
        /// unused [2:3]
        _unused2: u2 = 0,
        /// CC2E [4:4]
        /// Capture/Compare 2 output
        CC2E: u1 = 0,
        /// CC2P [5:5]
        /// Capture/Compare 2 output
        CC2P: u1 = 0,
        /// unused [6:7]
        _unused6: u2 = 0,
        /// CC3E [8:8]
        /// Capture/Compare 3 output
        CC3E: u1 = 0,
        /// CC3P [9:9]
        /// Capture/Compare 3 output
        CC3P: u1 = 0,
        /// unused [10:11]
        _unused10: u2 = 0,
        /// CC4E [12:12]
        /// Capture/Compare 4 output
        CC4E: u1 = 0,
        /// CC4P [13:13]
        /// Capture/Compare 3 output
        CC4P: u1 = 0,
        /// unused [14:31]
        _unused14: u2 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// capture/compare enable
    pub const CCER = Register(CCER_val).init(base_address + 0x20);

    /// CNT
    const CNT_val = packed struct {
        /// CNT [0:15]
        /// counter value
        CNT: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// counter
    pub const CNT = Register(CNT_val).init(base_address + 0x24);

    /// PSC
    const PSC_val = packed struct {
        /// PSC [0:15]
        /// Prescaler value
        PSC: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// prescaler
    pub const PSC = Register(PSC_val).init(base_address + 0x28);

    /// ARR
    const ARR_val = packed struct {
        /// ARR [0:15]
        /// Auto-reload value
        ARR: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// auto-reload register
    pub const ARR = Register(ARR_val).init(base_address + 0x2c);

    /// CCR1
    const CCR1_val = packed struct {
        /// CCR1 [0:15]
        /// Capture/Compare 1 value
        CCR1: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// capture/compare register 1
    pub const CCR1 = Register(CCR1_val).init(base_address + 0x34);

    /// CCR2
    const CCR2_val = packed struct {
        /// CCR2 [0:15]
        /// Capture/Compare 2 value
        CCR2: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// capture/compare register 2
    pub const CCR2 = Register(CCR2_val).init(base_address + 0x38);

    /// CCR3
    const CCR3_val = packed struct {
        /// CCR3 [0:15]
        /// Capture/Compare value
        CCR3: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// capture/compare register 3
    pub const CCR3 = Register(CCR3_val).init(base_address + 0x3c);

    /// CCR4
    const CCR4_val = packed struct {
        /// CCR4 [0:15]
        /// Capture/Compare value
        CCR4: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// capture/compare register 4
    pub const CCR4 = Register(CCR4_val).init(base_address + 0x40);

    /// DCR
    const DCR_val = packed struct {
        /// DBA [0:4]
        /// DMA base address
        DBA: u5 = 0,
        /// unused [5:7]
        _unused5: u3 = 0,
        /// DBL [8:12]
        /// DMA burst length
        DBL: u5 = 0,
        /// unused [13:31]
        _unused13: u3 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// DMA control register
    pub const DCR = Register(DCR_val).init(base_address + 0x48);

    /// DMAR
    const DMAR_val = packed struct {
        /// DMAB [0:15]
        /// DMA register for burst
        DMAB: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// DMA address for full transfer
    pub const DMAR = Register(DMAR_val).init(base_address + 0x4c);
};

/// General purpose timer
pub const TIM9 = struct {
    const base_address = 0x40014c00;
    /// CR1
    const CR1_val = packed struct {
        /// CEN [0:0]
        /// Counter enable
        CEN: u1 = 0,
        /// UDIS [1:1]
        /// Update disable
        UDIS: u1 = 0,
        /// URS [2:2]
        /// Update request source
        URS: u1 = 0,
        /// OPM [3:3]
        /// One-pulse mode
        OPM: u1 = 0,
        /// unused [4:6]
        _unused4: u3 = 0,
        /// ARPE [7:7]
        /// Auto-reload preload enable
        ARPE: u1 = 0,
        /// CKD [8:9]
        /// Clock division
        CKD: u2 = 0,
        /// unused [10:31]
        _unused10: u6 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// control register 1
    pub const CR1 = Register(CR1_val).init(base_address + 0x0);

    /// CR2
    const CR2_val = packed struct {
        /// unused [0:3]
        _unused0: u4 = 0,
        /// MMS [4:6]
        /// Master mode selection
        MMS: u3 = 0,
        /// unused [7:31]
        _unused7: u1 = 0,
        _unused8: u8 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// control register 2
    pub const CR2 = Register(CR2_val).init(base_address + 0x4);

    /// SMCR
    const SMCR_val = packed struct {
        /// SMS [0:2]
        /// Slave mode selection
        SMS: u3 = 0,
        /// unused [3:3]
        _unused3: u1 = 0,
        /// TS [4:6]
        /// Trigger selection
        TS: u3 = 0,
        /// MSM [7:7]
        /// Master/Slave mode
        MSM: u1 = 0,
        /// unused [8:31]
        _unused8: u8 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// slave mode control register
    pub const SMCR = Register(SMCR_val).init(base_address + 0x8);

    /// DIER
    const DIER_val = packed struct {
        /// UIE [0:0]
        /// Update interrupt enable
        UIE: u1 = 0,
        /// CC1IE [1:1]
        /// Capture/Compare 1 interrupt
        CC1IE: u1 = 0,
        /// CC2IE [2:2]
        /// Capture/Compare 2 interrupt
        CC2IE: u1 = 0,
        /// unused [3:5]
        _unused3: u3 = 0,
        /// TIE [6:6]
        /// Trigger interrupt enable
        TIE: u1 = 0,
        /// unused [7:31]
        _unused7: u1 = 0,
        _unused8: u8 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// DMA/Interrupt enable register
    pub const DIER = Register(DIER_val).init(base_address + 0xc);

    /// SR
    const SR_val = packed struct {
        /// UIF [0:0]
        /// Update interrupt flag
        UIF: u1 = 0,
        /// CC1IF [1:1]
        /// Capture/compare 1 interrupt
        CC1IF: u1 = 0,
        /// CC2IF [2:2]
        /// Capture/Compare 2 interrupt
        CC2IF: u1 = 0,
        /// unused [3:5]
        _unused3: u3 = 0,
        /// TIF [6:6]
        /// Trigger interrupt flag
        TIF: u1 = 0,
        /// unused [7:8]
        _unused7: u1 = 0,
        _unused8: u1 = 0,
        /// CC1OF [9:9]
        /// Capture/Compare 1 overcapture
        CC1OF: u1 = 0,
        /// CC2OF [10:10]
        /// Capture/compare 2 overcapture
        CC2OF: u1 = 0,
        /// unused [11:31]
        _unused11: u5 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// status register
    pub const SR = Register(SR_val).init(base_address + 0x10);

    /// EGR
    const EGR_val = packed struct {
        /// UG [0:0]
        /// Update generation
        UG: u1 = 0,
        /// CC1G [1:1]
        /// Capture/compare 1
        CC1G: u1 = 0,
        /// CC2G [2:2]
        /// Capture/compare 2
        CC2G: u1 = 0,
        /// unused [3:5]
        _unused3: u3 = 0,
        /// TG [6:6]
        /// Trigger generation
        TG: u1 = 0,
        /// unused [7:31]
        _unused7: u1 = 0,
        _unused8: u8 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// event generation register
    pub const EGR = Register(EGR_val).init(base_address + 0x14);

    /// CCMR1_Output
    const CCMR1_Output_val = packed struct {
        /// CC1S [0:1]
        /// Capture/Compare 1
        CC1S: u2 = 0,
        /// OC1FE [2:2]
        /// Output Compare 1 fast
        OC1FE: u1 = 0,
        /// OC1PE [3:3]
        /// Output Compare 1 preload
        OC1PE: u1 = 0,
        /// OC1M [4:6]
        /// Output Compare 1 mode
        OC1M: u3 = 0,
        /// unused [7:7]
        _unused7: u1 = 0,
        /// CC2S [8:9]
        /// Capture/Compare 2
        CC2S: u2 = 0,
        /// OC2FE [10:10]
        /// Output Compare 2 fast
        OC2FE: u1 = 0,
        /// OC2PE [11:11]
        /// Output Compare 2 preload
        OC2PE: u1 = 0,
        /// OC2M [12:14]
        /// Output Compare 2 mode
        OC2M: u3 = 0,
        /// unused [15:31]
        _unused15: u1 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// capture/compare mode register 1 (output
    pub const CCMR1_Output = Register(CCMR1_Output_val).init(base_address + 0x18);

    /// CCMR1_Input
    const CCMR1_Input_val = packed struct {
        /// CC1S [0:1]
        /// Capture/Compare 1
        CC1S: u2 = 0,
        /// IC1PSC [2:3]
        /// Input capture 1 prescaler
        IC1PSC: u2 = 0,
        /// IC1F [4:7]
        /// Input capture 1 filter
        IC1F: u4 = 0,
        /// CC2S [8:9]
        /// Capture/Compare 2
        CC2S: u2 = 0,
        /// IC2PSC [10:11]
        /// Input capture 2 prescaler
        IC2PSC: u2 = 0,
        /// IC2F [12:15]
        /// Input capture 2 filter
        IC2F: u4 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// capture/compare mode register 1 (input
    pub const CCMR1_Input = Register(CCMR1_Input_val).init(base_address + 0x18);

    /// CCER
    const CCER_val = packed struct {
        /// CC1E [0:0]
        /// Capture/Compare 1 output
        CC1E: u1 = 0,
        /// CC1P [1:1]
        /// Capture/Compare 1 output
        CC1P: u1 = 0,
        /// unused [2:2]
        _unused2: u1 = 0,
        /// CC1NP [3:3]
        /// Capture/Compare 1 output
        CC1NP: u1 = 0,
        /// CC2E [4:4]
        /// Capture/Compare 2 output
        CC2E: u1 = 0,
        /// CC2P [5:5]
        /// Capture/Compare 2 output
        CC2P: u1 = 0,
        /// unused [6:6]
        _unused6: u1 = 0,
        /// CC2NP [7:7]
        /// Capture/Compare 2 output
        CC2NP: u1 = 0,
        /// unused [8:31]
        _unused8: u8 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// capture/compare enable
    pub const CCER = Register(CCER_val).init(base_address + 0x20);

    /// CNT
    const CNT_val = packed struct {
        /// CNT [0:15]
        /// counter value
        CNT: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// counter
    pub const CNT = Register(CNT_val).init(base_address + 0x24);

    /// PSC
    const PSC_val = packed struct {
        /// PSC [0:15]
        /// Prescaler value
        PSC: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// prescaler
    pub const PSC = Register(PSC_val).init(base_address + 0x28);

    /// ARR
    const ARR_val = packed struct {
        /// ARR [0:15]
        /// Auto-reload value
        ARR: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// auto-reload register
    pub const ARR = Register(ARR_val).init(base_address + 0x2c);

    /// CCR1
    const CCR1_val = packed struct {
        /// CCR1 [0:15]
        /// Capture/Compare 1 value
        CCR1: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// capture/compare register 1
    pub const CCR1 = Register(CCR1_val).init(base_address + 0x34);

    /// CCR2
    const CCR2_val = packed struct {
        /// CCR2 [0:15]
        /// Capture/Compare 2 value
        CCR2: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// capture/compare register 2
    pub const CCR2 = Register(CCR2_val).init(base_address + 0x38);
};

/// General purpose timer
pub const TIM12 = struct {
    const base_address = 0x40001800;
    /// CR1
    const CR1_val = packed struct {
        /// CEN [0:0]
        /// Counter enable
        CEN: u1 = 0,
        /// UDIS [1:1]
        /// Update disable
        UDIS: u1 = 0,
        /// URS [2:2]
        /// Update request source
        URS: u1 = 0,
        /// OPM [3:3]
        /// One-pulse mode
        OPM: u1 = 0,
        /// unused [4:6]
        _unused4: u3 = 0,
        /// ARPE [7:7]
        /// Auto-reload preload enable
        ARPE: u1 = 0,
        /// CKD [8:9]
        /// Clock division
        CKD: u2 = 0,
        /// unused [10:31]
        _unused10: u6 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// control register 1
    pub const CR1 = Register(CR1_val).init(base_address + 0x0);

    /// CR2
    const CR2_val = packed struct {
        /// unused [0:3]
        _unused0: u4 = 0,
        /// MMS [4:6]
        /// Master mode selection
        MMS: u3 = 0,
        /// unused [7:31]
        _unused7: u1 = 0,
        _unused8: u8 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// control register 2
    pub const CR2 = Register(CR2_val).init(base_address + 0x4);

    /// SMCR
    const SMCR_val = packed struct {
        /// SMS [0:2]
        /// Slave mode selection
        SMS: u3 = 0,
        /// unused [3:3]
        _unused3: u1 = 0,
        /// TS [4:6]
        /// Trigger selection
        TS: u3 = 0,
        /// MSM [7:7]
        /// Master/Slave mode
        MSM: u1 = 0,
        /// unused [8:31]
        _unused8: u8 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// slave mode control register
    pub const SMCR = Register(SMCR_val).init(base_address + 0x8);

    /// DIER
    const DIER_val = packed struct {
        /// UIE [0:0]
        /// Update interrupt enable
        UIE: u1 = 0,
        /// CC1IE [1:1]
        /// Capture/Compare 1 interrupt
        CC1IE: u1 = 0,
        /// CC2IE [2:2]
        /// Capture/Compare 2 interrupt
        CC2IE: u1 = 0,
        /// unused [3:5]
        _unused3: u3 = 0,
        /// TIE [6:6]
        /// Trigger interrupt enable
        TIE: u1 = 0,
        /// unused [7:31]
        _unused7: u1 = 0,
        _unused8: u8 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// DMA/Interrupt enable register
    pub const DIER = Register(DIER_val).init(base_address + 0xc);

    /// SR
    const SR_val = packed struct {
        /// UIF [0:0]
        /// Update interrupt flag
        UIF: u1 = 0,
        /// CC1IF [1:1]
        /// Capture/compare 1 interrupt
        CC1IF: u1 = 0,
        /// CC2IF [2:2]
        /// Capture/Compare 2 interrupt
        CC2IF: u1 = 0,
        /// unused [3:5]
        _unused3: u3 = 0,
        /// TIF [6:6]
        /// Trigger interrupt flag
        TIF: u1 = 0,
        /// unused [7:8]
        _unused7: u1 = 0,
        _unused8: u1 = 0,
        /// CC1OF [9:9]
        /// Capture/Compare 1 overcapture
        CC1OF: u1 = 0,
        /// CC2OF [10:10]
        /// Capture/compare 2 overcapture
        CC2OF: u1 = 0,
        /// unused [11:31]
        _unused11: u5 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// status register
    pub const SR = Register(SR_val).init(base_address + 0x10);

    /// EGR
    const EGR_val = packed struct {
        /// UG [0:0]
        /// Update generation
        UG: u1 = 0,
        /// CC1G [1:1]
        /// Capture/compare 1
        CC1G: u1 = 0,
        /// CC2G [2:2]
        /// Capture/compare 2
        CC2G: u1 = 0,
        /// unused [3:5]
        _unused3: u3 = 0,
        /// TG [6:6]
        /// Trigger generation
        TG: u1 = 0,
        /// unused [7:31]
        _unused7: u1 = 0,
        _unused8: u8 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// event generation register
    pub const EGR = Register(EGR_val).init(base_address + 0x14);

    /// CCMR1_Output
    const CCMR1_Output_val = packed struct {
        /// CC1S [0:1]
        /// Capture/Compare 1
        CC1S: u2 = 0,
        /// OC1FE [2:2]
        /// Output Compare 1 fast
        OC1FE: u1 = 0,
        /// OC1PE [3:3]
        /// Output Compare 1 preload
        OC1PE: u1 = 0,
        /// OC1M [4:6]
        /// Output Compare 1 mode
        OC1M: u3 = 0,
        /// unused [7:7]
        _unused7: u1 = 0,
        /// CC2S [8:9]
        /// Capture/Compare 2
        CC2S: u2 = 0,
        /// OC2FE [10:10]
        /// Output Compare 2 fast
        OC2FE: u1 = 0,
        /// OC2PE [11:11]
        /// Output Compare 2 preload
        OC2PE: u1 = 0,
        /// OC2M [12:14]
        /// Output Compare 2 mode
        OC2M: u3 = 0,
        /// unused [15:31]
        _unused15: u1 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// capture/compare mode register 1 (output
    pub const CCMR1_Output = Register(CCMR1_Output_val).init(base_address + 0x18);

    /// CCMR1_Input
    const CCMR1_Input_val = packed struct {
        /// CC1S [0:1]
        /// Capture/Compare 1
        CC1S: u2 = 0,
        /// IC1PSC [2:3]
        /// Input capture 1 prescaler
        IC1PSC: u2 = 0,
        /// IC1F [4:7]
        /// Input capture 1 filter
        IC1F: u4 = 0,
        /// CC2S [8:9]
        /// Capture/Compare 2
        CC2S: u2 = 0,
        /// IC2PSC [10:11]
        /// Input capture 2 prescaler
        IC2PSC: u2 = 0,
        /// IC2F [12:15]
        /// Input capture 2 filter
        IC2F: u4 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// capture/compare mode register 1 (input
    pub const CCMR1_Input = Register(CCMR1_Input_val).init(base_address + 0x18);

    /// CCER
    const CCER_val = packed struct {
        /// CC1E [0:0]
        /// Capture/Compare 1 output
        CC1E: u1 = 0,
        /// CC1P [1:1]
        /// Capture/Compare 1 output
        CC1P: u1 = 0,
        /// unused [2:2]
        _unused2: u1 = 0,
        /// CC1NP [3:3]
        /// Capture/Compare 1 output
        CC1NP: u1 = 0,
        /// CC2E [4:4]
        /// Capture/Compare 2 output
        CC2E: u1 = 0,
        /// CC2P [5:5]
        /// Capture/Compare 2 output
        CC2P: u1 = 0,
        /// unused [6:6]
        _unused6: u1 = 0,
        /// CC2NP [7:7]
        /// Capture/Compare 2 output
        CC2NP: u1 = 0,
        /// unused [8:31]
        _unused8: u8 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// capture/compare enable
    pub const CCER = Register(CCER_val).init(base_address + 0x20);

    /// CNT
    const CNT_val = packed struct {
        /// CNT [0:15]
        /// counter value
        CNT: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// counter
    pub const CNT = Register(CNT_val).init(base_address + 0x24);

    /// PSC
    const PSC_val = packed struct {
        /// PSC [0:15]
        /// Prescaler value
        PSC: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// prescaler
    pub const PSC = Register(PSC_val).init(base_address + 0x28);

    /// ARR
    const ARR_val = packed struct {
        /// ARR [0:15]
        /// Auto-reload value
        ARR: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// auto-reload register
    pub const ARR = Register(ARR_val).init(base_address + 0x2c);

    /// CCR1
    const CCR1_val = packed struct {
        /// CCR1 [0:15]
        /// Capture/Compare 1 value
        CCR1: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// capture/compare register 1
    pub const CCR1 = Register(CCR1_val).init(base_address + 0x34);

    /// CCR2
    const CCR2_val = packed struct {
        /// CCR2 [0:15]
        /// Capture/Compare 2 value
        CCR2: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// capture/compare register 2
    pub const CCR2 = Register(CCR2_val).init(base_address + 0x38);
};

/// General purpose timer
pub const TIM10 = struct {
    const base_address = 0x40015000;
    /// CR1
    const CR1_val = packed struct {
        /// CEN [0:0]
        /// Counter enable
        CEN: u1 = 0,
        /// UDIS [1:1]
        /// Update disable
        UDIS: u1 = 0,
        /// URS [2:2]
        /// Update request source
        URS: u1 = 0,
        /// unused [3:6]
        _unused3: u4 = 0,
        /// ARPE [7:7]
        /// Auto-reload preload enable
        ARPE: u1 = 0,
        /// CKD [8:9]
        /// Clock division
        CKD: u2 = 0,
        /// unused [10:31]
        _unused10: u6 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// control register 1
    pub const CR1 = Register(CR1_val).init(base_address + 0x0);

    /// CR2
    const CR2_val = packed struct {
        /// unused [0:3]
        _unused0: u4 = 0,
        /// MMS [4:6]
        /// Master mode selection
        MMS: u3 = 0,
        /// unused [7:31]
        _unused7: u1 = 0,
        _unused8: u8 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// control register 2
    pub const CR2 = Register(CR2_val).init(base_address + 0x4);

    /// DIER
    const DIER_val = packed struct {
        /// UIE [0:0]
        /// Update interrupt enable
        UIE: u1 = 0,
        /// CC1IE [1:1]
        /// Capture/Compare 1 interrupt
        CC1IE: u1 = 0,
        /// unused [2:31]
        _unused2: u6 = 0,
        _unused8: u8 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// DMA/Interrupt enable register
    pub const DIER = Register(DIER_val).init(base_address + 0xc);

    /// SR
    const SR_val = packed struct {
        /// UIF [0:0]
        /// Update interrupt flag
        UIF: u1 = 0,
        /// CC1IF [1:1]
        /// Capture/compare 1 interrupt
        CC1IF: u1 = 0,
        /// unused [2:8]
        _unused2: u6 = 0,
        _unused8: u1 = 0,
        /// CC1OF [9:9]
        /// Capture/Compare 1 overcapture
        CC1OF: u1 = 0,
        /// unused [10:31]
        _unused10: u6 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// status register
    pub const SR = Register(SR_val).init(base_address + 0x10);

    /// EGR
    const EGR_val = packed struct {
        /// UG [0:0]
        /// Update generation
        UG: u1 = 0,
        /// CC1G [1:1]
        /// Capture/compare 1
        CC1G: u1 = 0,
        /// unused [2:31]
        _unused2: u6 = 0,
        _unused8: u8 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// event generation register
    pub const EGR = Register(EGR_val).init(base_address + 0x14);

    /// CCMR1_Output
    const CCMR1_Output_val = packed struct {
        /// CC1S [0:1]
        /// Capture/Compare 1
        CC1S: u2 = 0,
        /// unused [2:2]
        _unused2: u1 = 0,
        /// OC1PE [3:3]
        /// Output Compare 1 preload
        OC1PE: u1 = 0,
        /// OC1M [4:6]
        /// Output Compare 1 mode
        OC1M: u3 = 0,
        /// unused [7:31]
        _unused7: u1 = 0,
        _unused8: u8 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// capture/compare mode register (output
    pub const CCMR1_Output = Register(CCMR1_Output_val).init(base_address + 0x18);

    /// CCMR1_Input
    const CCMR1_Input_val = packed struct {
        /// CC1S [0:1]
        /// Capture/Compare 1
        CC1S: u2 = 0,
        /// IC1PSC [2:3]
        /// Input capture 1 prescaler
        IC1PSC: u2 = 0,
        /// IC1F [4:7]
        /// Input capture 1 filter
        IC1F: u4 = 0,
        /// unused [8:31]
        _unused8: u8 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// capture/compare mode register (input
    pub const CCMR1_Input = Register(CCMR1_Input_val).init(base_address + 0x18);

    /// CCER
    const CCER_val = packed struct {
        /// CC1E [0:0]
        /// Capture/Compare 1 output
        CC1E: u1 = 0,
        /// CC1P [1:1]
        /// Capture/Compare 1 output
        CC1P: u1 = 0,
        /// unused [2:2]
        _unused2: u1 = 0,
        /// CC1NP [3:3]
        /// Capture/Compare 1 output
        CC1NP: u1 = 0,
        /// unused [4:31]
        _unused4: u4 = 0,
        _unused8: u8 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// capture/compare enable
    pub const CCER = Register(CCER_val).init(base_address + 0x20);

    /// CNT
    const CNT_val = packed struct {
        /// CNT [0:15]
        /// counter value
        CNT: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// counter
    pub const CNT = Register(CNT_val).init(base_address + 0x24);

    /// PSC
    const PSC_val = packed struct {
        /// PSC [0:15]
        /// Prescaler value
        PSC: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// prescaler
    pub const PSC = Register(PSC_val).init(base_address + 0x28);

    /// ARR
    const ARR_val = packed struct {
        /// ARR [0:15]
        /// Auto-reload value
        ARR: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// auto-reload register
    pub const ARR = Register(ARR_val).init(base_address + 0x2c);

    /// CCR1
    const CCR1_val = packed struct {
        /// CCR1 [0:15]
        /// Capture/Compare 1 value
        CCR1: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// capture/compare register 1
    pub const CCR1 = Register(CCR1_val).init(base_address + 0x34);
};

/// General purpose timer
pub const TIM11 = struct {
    const base_address = 0x40015400;
    /// CR1
    const CR1_val = packed struct {
        /// CEN [0:0]
        /// Counter enable
        CEN: u1 = 0,
        /// UDIS [1:1]
        /// Update disable
        UDIS: u1 = 0,
        /// URS [2:2]
        /// Update request source
        URS: u1 = 0,
        /// unused [3:6]
        _unused3: u4 = 0,
        /// ARPE [7:7]
        /// Auto-reload preload enable
        ARPE: u1 = 0,
        /// CKD [8:9]
        /// Clock division
        CKD: u2 = 0,
        /// unused [10:31]
        _unused10: u6 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// control register 1
    pub const CR1 = Register(CR1_val).init(base_address + 0x0);

    /// CR2
    const CR2_val = packed struct {
        /// unused [0:3]
        _unused0: u4 = 0,
        /// MMS [4:6]
        /// Master mode selection
        MMS: u3 = 0,
        /// unused [7:31]
        _unused7: u1 = 0,
        _unused8: u8 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// control register 2
    pub const CR2 = Register(CR2_val).init(base_address + 0x4);

    /// DIER
    const DIER_val = packed struct {
        /// UIE [0:0]
        /// Update interrupt enable
        UIE: u1 = 0,
        /// CC1IE [1:1]
        /// Capture/Compare 1 interrupt
        CC1IE: u1 = 0,
        /// unused [2:31]
        _unused2: u6 = 0,
        _unused8: u8 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// DMA/Interrupt enable register
    pub const DIER = Register(DIER_val).init(base_address + 0xc);

    /// SR
    const SR_val = packed struct {
        /// UIF [0:0]
        /// Update interrupt flag
        UIF: u1 = 0,
        /// CC1IF [1:1]
        /// Capture/compare 1 interrupt
        CC1IF: u1 = 0,
        /// unused [2:8]
        _unused2: u6 = 0,
        _unused8: u1 = 0,
        /// CC1OF [9:9]
        /// Capture/Compare 1 overcapture
        CC1OF: u1 = 0,
        /// unused [10:31]
        _unused10: u6 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// status register
    pub const SR = Register(SR_val).init(base_address + 0x10);

    /// EGR
    const EGR_val = packed struct {
        /// UG [0:0]
        /// Update generation
        UG: u1 = 0,
        /// CC1G [1:1]
        /// Capture/compare 1
        CC1G: u1 = 0,
        /// unused [2:31]
        _unused2: u6 = 0,
        _unused8: u8 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// event generation register
    pub const EGR = Register(EGR_val).init(base_address + 0x14);

    /// CCMR1_Output
    const CCMR1_Output_val = packed struct {
        /// CC1S [0:1]
        /// Capture/Compare 1
        CC1S: u2 = 0,
        /// unused [2:2]
        _unused2: u1 = 0,
        /// OC1PE [3:3]
        /// Output Compare 1 preload
        OC1PE: u1 = 0,
        /// OC1M [4:6]
        /// Output Compare 1 mode
        OC1M: u3 = 0,
        /// unused [7:31]
        _unused7: u1 = 0,
        _unused8: u8 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// capture/compare mode register (output
    pub const CCMR1_Output = Register(CCMR1_Output_val).init(base_address + 0x18);

    /// CCMR1_Input
    const CCMR1_Input_val = packed struct {
        /// CC1S [0:1]
        /// Capture/Compare 1
        CC1S: u2 = 0,
        /// IC1PSC [2:3]
        /// Input capture 1 prescaler
        IC1PSC: u2 = 0,
        /// IC1F [4:7]
        /// Input capture 1 filter
        IC1F: u4 = 0,
        /// unused [8:31]
        _unused8: u8 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// capture/compare mode register (input
    pub const CCMR1_Input = Register(CCMR1_Input_val).init(base_address + 0x18);

    /// CCER
    const CCER_val = packed struct {
        /// CC1E [0:0]
        /// Capture/Compare 1 output
        CC1E: u1 = 0,
        /// CC1P [1:1]
        /// Capture/Compare 1 output
        CC1P: u1 = 0,
        /// unused [2:2]
        _unused2: u1 = 0,
        /// CC1NP [3:3]
        /// Capture/Compare 1 output
        CC1NP: u1 = 0,
        /// unused [4:31]
        _unused4: u4 = 0,
        _unused8: u8 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// capture/compare enable
    pub const CCER = Register(CCER_val).init(base_address + 0x20);

    /// CNT
    const CNT_val = packed struct {
        /// CNT [0:15]
        /// counter value
        CNT: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// counter
    pub const CNT = Register(CNT_val).init(base_address + 0x24);

    /// PSC
    const PSC_val = packed struct {
        /// PSC [0:15]
        /// Prescaler value
        PSC: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// prescaler
    pub const PSC = Register(PSC_val).init(base_address + 0x28);

    /// ARR
    const ARR_val = packed struct {
        /// ARR [0:15]
        /// Auto-reload value
        ARR: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// auto-reload register
    pub const ARR = Register(ARR_val).init(base_address + 0x2c);

    /// CCR1
    const CCR1_val = packed struct {
        /// CCR1 [0:15]
        /// Capture/Compare 1 value
        CCR1: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// capture/compare register 1
    pub const CCR1 = Register(CCR1_val).init(base_address + 0x34);
};

/// General purpose timer
pub const TIM13 = struct {
    const base_address = 0x40001c00;
    /// CR1
    const CR1_val = packed struct {
        /// CEN [0:0]
        /// Counter enable
        CEN: u1 = 0,
        /// UDIS [1:1]
        /// Update disable
        UDIS: u1 = 0,
        /// URS [2:2]
        /// Update request source
        URS: u1 = 0,
        /// unused [3:6]
        _unused3: u4 = 0,
        /// ARPE [7:7]
        /// Auto-reload preload enable
        ARPE: u1 = 0,
        /// CKD [8:9]
        /// Clock division
        CKD: u2 = 0,
        /// unused [10:31]
        _unused10: u6 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// control register 1
    pub const CR1 = Register(CR1_val).init(base_address + 0x0);

    /// CR2
    const CR2_val = packed struct {
        /// unused [0:3]
        _unused0: u4 = 0,
        /// MMS [4:6]
        /// Master mode selection
        MMS: u3 = 0,
        /// unused [7:31]
        _unused7: u1 = 0,
        _unused8: u8 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// control register 2
    pub const CR2 = Register(CR2_val).init(base_address + 0x4);

    /// DIER
    const DIER_val = packed struct {
        /// UIE [0:0]
        /// Update interrupt enable
        UIE: u1 = 0,
        /// CC1IE [1:1]
        /// Capture/Compare 1 interrupt
        CC1IE: u1 = 0,
        /// unused [2:31]
        _unused2: u6 = 0,
        _unused8: u8 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// DMA/Interrupt enable register
    pub const DIER = Register(DIER_val).init(base_address + 0xc);

    /// SR
    const SR_val = packed struct {
        /// UIF [0:0]
        /// Update interrupt flag
        UIF: u1 = 0,
        /// CC1IF [1:1]
        /// Capture/compare 1 interrupt
        CC1IF: u1 = 0,
        /// unused [2:8]
        _unused2: u6 = 0,
        _unused8: u1 = 0,
        /// CC1OF [9:9]
        /// Capture/Compare 1 overcapture
        CC1OF: u1 = 0,
        /// unused [10:31]
        _unused10: u6 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// status register
    pub const SR = Register(SR_val).init(base_address + 0x10);

    /// EGR
    const EGR_val = packed struct {
        /// UG [0:0]
        /// Update generation
        UG: u1 = 0,
        /// CC1G [1:1]
        /// Capture/compare 1
        CC1G: u1 = 0,
        /// unused [2:31]
        _unused2: u6 = 0,
        _unused8: u8 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// event generation register
    pub const EGR = Register(EGR_val).init(base_address + 0x14);

    /// CCMR1_Output
    const CCMR1_Output_val = packed struct {
        /// CC1S [0:1]
        /// Capture/Compare 1
        CC1S: u2 = 0,
        /// unused [2:2]
        _unused2: u1 = 0,
        /// OC1PE [3:3]
        /// Output Compare 1 preload
        OC1PE: u1 = 0,
        /// OC1M [4:6]
        /// Output Compare 1 mode
        OC1M: u3 = 0,
        /// unused [7:31]
        _unused7: u1 = 0,
        _unused8: u8 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// capture/compare mode register (output
    pub const CCMR1_Output = Register(CCMR1_Output_val).init(base_address + 0x18);

    /// CCMR1_Input
    const CCMR1_Input_val = packed struct {
        /// CC1S [0:1]
        /// Capture/Compare 1
        CC1S: u2 = 0,
        /// IC1PSC [2:3]
        /// Input capture 1 prescaler
        IC1PSC: u2 = 0,
        /// IC1F [4:7]
        /// Input capture 1 filter
        IC1F: u4 = 0,
        /// unused [8:31]
        _unused8: u8 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// capture/compare mode register (input
    pub const CCMR1_Input = Register(CCMR1_Input_val).init(base_address + 0x18);

    /// CCER
    const CCER_val = packed struct {
        /// CC1E [0:0]
        /// Capture/Compare 1 output
        CC1E: u1 = 0,
        /// CC1P [1:1]
        /// Capture/Compare 1 output
        CC1P: u1 = 0,
        /// unused [2:2]
        _unused2: u1 = 0,
        /// CC1NP [3:3]
        /// Capture/Compare 1 output
        CC1NP: u1 = 0,
        /// unused [4:31]
        _unused4: u4 = 0,
        _unused8: u8 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// capture/compare enable
    pub const CCER = Register(CCER_val).init(base_address + 0x20);

    /// CNT
    const CNT_val = packed struct {
        /// CNT [0:15]
        /// counter value
        CNT: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// counter
    pub const CNT = Register(CNT_val).init(base_address + 0x24);

    /// PSC
    const PSC_val = packed struct {
        /// PSC [0:15]
        /// Prescaler value
        PSC: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// prescaler
    pub const PSC = Register(PSC_val).init(base_address + 0x28);

    /// ARR
    const ARR_val = packed struct {
        /// ARR [0:15]
        /// Auto-reload value
        ARR: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// auto-reload register
    pub const ARR = Register(ARR_val).init(base_address + 0x2c);

    /// CCR1
    const CCR1_val = packed struct {
        /// CCR1 [0:15]
        /// Capture/Compare 1 value
        CCR1: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// capture/compare register 1
    pub const CCR1 = Register(CCR1_val).init(base_address + 0x34);
};

/// General purpose timer
pub const TIM14 = struct {
    const base_address = 0x40002000;
    /// CR1
    const CR1_val = packed struct {
        /// CEN [0:0]
        /// Counter enable
        CEN: u1 = 0,
        /// UDIS [1:1]
        /// Update disable
        UDIS: u1 = 0,
        /// URS [2:2]
        /// Update request source
        URS: u1 = 0,
        /// unused [3:6]
        _unused3: u4 = 0,
        /// ARPE [7:7]
        /// Auto-reload preload enable
        ARPE: u1 = 0,
        /// CKD [8:9]
        /// Clock division
        CKD: u2 = 0,
        /// unused [10:31]
        _unused10: u6 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// control register 1
    pub const CR1 = Register(CR1_val).init(base_address + 0x0);

    /// CR2
    const CR2_val = packed struct {
        /// unused [0:3]
        _unused0: u4 = 0,
        /// MMS [4:6]
        /// Master mode selection
        MMS: u3 = 0,
        /// unused [7:31]
        _unused7: u1 = 0,
        _unused8: u8 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// control register 2
    pub const CR2 = Register(CR2_val).init(base_address + 0x4);

    /// DIER
    const DIER_val = packed struct {
        /// UIE [0:0]
        /// Update interrupt enable
        UIE: u1 = 0,
        /// CC1IE [1:1]
        /// Capture/Compare 1 interrupt
        CC1IE: u1 = 0,
        /// unused [2:31]
        _unused2: u6 = 0,
        _unused8: u8 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// DMA/Interrupt enable register
    pub const DIER = Register(DIER_val).init(base_address + 0xc);

    /// SR
    const SR_val = packed struct {
        /// UIF [0:0]
        /// Update interrupt flag
        UIF: u1 = 0,
        /// CC1IF [1:1]
        /// Capture/compare 1 interrupt
        CC1IF: u1 = 0,
        /// unused [2:8]
        _unused2: u6 = 0,
        _unused8: u1 = 0,
        /// CC1OF [9:9]
        /// Capture/Compare 1 overcapture
        CC1OF: u1 = 0,
        /// unused [10:31]
        _unused10: u6 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// status register
    pub const SR = Register(SR_val).init(base_address + 0x10);

    /// EGR
    const EGR_val = packed struct {
        /// UG [0:0]
        /// Update generation
        UG: u1 = 0,
        /// CC1G [1:1]
        /// Capture/compare 1
        CC1G: u1 = 0,
        /// unused [2:31]
        _unused2: u6 = 0,
        _unused8: u8 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// event generation register
    pub const EGR = Register(EGR_val).init(base_address + 0x14);

    /// CCMR1_Output
    const CCMR1_Output_val = packed struct {
        /// CC1S [0:1]
        /// Capture/Compare 1
        CC1S: u2 = 0,
        /// unused [2:2]
        _unused2: u1 = 0,
        /// OC1PE [3:3]
        /// Output Compare 1 preload
        OC1PE: u1 = 0,
        /// OC1M [4:6]
        /// Output Compare 1 mode
        OC1M: u3 = 0,
        /// unused [7:31]
        _unused7: u1 = 0,
        _unused8: u8 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// capture/compare mode register (output
    pub const CCMR1_Output = Register(CCMR1_Output_val).init(base_address + 0x18);

    /// CCMR1_Input
    const CCMR1_Input_val = packed struct {
        /// CC1S [0:1]
        /// Capture/Compare 1
        CC1S: u2 = 0,
        /// IC1PSC [2:3]
        /// Input capture 1 prescaler
        IC1PSC: u2 = 0,
        /// IC1F [4:7]
        /// Input capture 1 filter
        IC1F: u4 = 0,
        /// unused [8:31]
        _unused8: u8 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// capture/compare mode register (input
    pub const CCMR1_Input = Register(CCMR1_Input_val).init(base_address + 0x18);

    /// CCER
    const CCER_val = packed struct {
        /// CC1E [0:0]
        /// Capture/Compare 1 output
        CC1E: u1 = 0,
        /// CC1P [1:1]
        /// Capture/Compare 1 output
        CC1P: u1 = 0,
        /// unused [2:2]
        _unused2: u1 = 0,
        /// CC1NP [3:3]
        /// Capture/Compare 1 output
        CC1NP: u1 = 0,
        /// unused [4:31]
        _unused4: u4 = 0,
        _unused8: u8 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// capture/compare enable
    pub const CCER = Register(CCER_val).init(base_address + 0x20);

    /// CNT
    const CNT_val = packed struct {
        /// CNT [0:15]
        /// counter value
        CNT: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// counter
    pub const CNT = Register(CNT_val).init(base_address + 0x24);

    /// PSC
    const PSC_val = packed struct {
        /// PSC [0:15]
        /// Prescaler value
        PSC: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// prescaler
    pub const PSC = Register(PSC_val).init(base_address + 0x28);

    /// ARR
    const ARR_val = packed struct {
        /// ARR [0:15]
        /// Auto-reload value
        ARR: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// auto-reload register
    pub const ARR = Register(ARR_val).init(base_address + 0x2c);

    /// CCR1
    const CCR1_val = packed struct {
        /// CCR1 [0:15]
        /// Capture/Compare 1 value
        CCR1: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// capture/compare register 1
    pub const CCR1 = Register(CCR1_val).init(base_address + 0x34);
};

/// Basic timer
pub const TIM6 = struct {
    const base_address = 0x40001000;
    /// CR1
    const CR1_val = packed struct {
        /// CEN [0:0]
        /// Counter enable
        CEN: u1 = 0,
        /// UDIS [1:1]
        /// Update disable
        UDIS: u1 = 0,
        /// URS [2:2]
        /// Update request source
        URS: u1 = 0,
        /// OPM [3:3]
        /// One-pulse mode
        OPM: u1 = 0,
        /// unused [4:6]
        _unused4: u3 = 0,
        /// ARPE [7:7]
        /// Auto-reload preload enable
        ARPE: u1 = 0,
        /// unused [8:31]
        _unused8: u8 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// control register 1
    pub const CR1 = Register(CR1_val).init(base_address + 0x0);

    /// CR2
    const CR2_val = packed struct {
        /// unused [0:3]
        _unused0: u4 = 0,
        /// MMS [4:6]
        /// Master mode selection
        MMS: u3 = 0,
        /// unused [7:31]
        _unused7: u1 = 0,
        _unused8: u8 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// control register 2
    pub const CR2 = Register(CR2_val).init(base_address + 0x4);

    /// DIER
    const DIER_val = packed struct {
        /// UIE [0:0]
        /// Update interrupt enable
        UIE: u1 = 0,
        /// unused [1:7]
        _unused1: u7 = 0,
        /// UDE [8:8]
        /// Update DMA request enable
        UDE: u1 = 0,
        /// unused [9:31]
        _unused9: u7 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// DMA/Interrupt enable register
    pub const DIER = Register(DIER_val).init(base_address + 0xc);

    /// SR
    const SR_val = packed struct {
        /// UIF [0:0]
        /// Update interrupt flag
        UIF: u1 = 0,
        /// unused [1:31]
        _unused1: u7 = 0,
        _unused8: u8 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// status register
    pub const SR = Register(SR_val).init(base_address + 0x10);

    /// EGR
    const EGR_val = packed struct {
        /// UG [0:0]
        /// Update generation
        UG: u1 = 0,
        /// unused [1:31]
        _unused1: u7 = 0,
        _unused8: u8 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// event generation register
    pub const EGR = Register(EGR_val).init(base_address + 0x14);

    /// CNT
    const CNT_val = packed struct {
        /// CNT [0:15]
        /// Low counter value
        CNT: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// counter
    pub const CNT = Register(CNT_val).init(base_address + 0x24);

    /// PSC
    const PSC_val = packed struct {
        /// PSC [0:15]
        /// Prescaler value
        PSC: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// prescaler
    pub const PSC = Register(PSC_val).init(base_address + 0x28);

    /// ARR
    const ARR_val = packed struct {
        /// ARR [0:15]
        /// Low Auto-reload value
        ARR: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// auto-reload register
    pub const ARR = Register(ARR_val).init(base_address + 0x2c);
};

/// Basic timer
pub const TIM7 = struct {
    const base_address = 0x40001400;
    /// CR1
    const CR1_val = packed struct {
        /// CEN [0:0]
        /// Counter enable
        CEN: u1 = 0,
        /// UDIS [1:1]
        /// Update disable
        UDIS: u1 = 0,
        /// URS [2:2]
        /// Update request source
        URS: u1 = 0,
        /// OPM [3:3]
        /// One-pulse mode
        OPM: u1 = 0,
        /// unused [4:6]
        _unused4: u3 = 0,
        /// ARPE [7:7]
        /// Auto-reload preload enable
        ARPE: u1 = 0,
        /// unused [8:31]
        _unused8: u8 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// control register 1
    pub const CR1 = Register(CR1_val).init(base_address + 0x0);

    /// CR2
    const CR2_val = packed struct {
        /// unused [0:3]
        _unused0: u4 = 0,
        /// MMS [4:6]
        /// Master mode selection
        MMS: u3 = 0,
        /// unused [7:31]
        _unused7: u1 = 0,
        _unused8: u8 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// control register 2
    pub const CR2 = Register(CR2_val).init(base_address + 0x4);

    /// DIER
    const DIER_val = packed struct {
        /// UIE [0:0]
        /// Update interrupt enable
        UIE: u1 = 0,
        /// unused [1:7]
        _unused1: u7 = 0,
        /// UDE [8:8]
        /// Update DMA request enable
        UDE: u1 = 0,
        /// unused [9:31]
        _unused9: u7 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// DMA/Interrupt enable register
    pub const DIER = Register(DIER_val).init(base_address + 0xc);

    /// SR
    const SR_val = packed struct {
        /// UIF [0:0]
        /// Update interrupt flag
        UIF: u1 = 0,
        /// unused [1:31]
        _unused1: u7 = 0,
        _unused8: u8 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// status register
    pub const SR = Register(SR_val).init(base_address + 0x10);

    /// EGR
    const EGR_val = packed struct {
        /// UG [0:0]
        /// Update generation
        UG: u1 = 0,
        /// unused [1:31]
        _unused1: u7 = 0,
        _unused8: u8 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// event generation register
    pub const EGR = Register(EGR_val).init(base_address + 0x14);

    /// CNT
    const CNT_val = packed struct {
        /// CNT [0:15]
        /// Low counter value
        CNT: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// counter
    pub const CNT = Register(CNT_val).init(base_address + 0x24);

    /// PSC
    const PSC_val = packed struct {
        /// PSC [0:15]
        /// Prescaler value
        PSC: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// prescaler
    pub const PSC = Register(PSC_val).init(base_address + 0x28);

    /// ARR
    const ARR_val = packed struct {
        /// ARR [0:15]
        /// Low Auto-reload value
        ARR: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// auto-reload register
    pub const ARR = Register(ARR_val).init(base_address + 0x2c);
};

/// Inter integrated circuit
pub const I2C1 = struct {
    const base_address = 0x40005400;
    /// CR1
    const CR1_val = packed struct {
        /// PE [0:0]
        /// Peripheral enable
        PE: u1 = 0,
        /// SMBUS [1:1]
        /// SMBus mode
        SMBUS: u1 = 0,
        /// unused [2:2]
        _unused2: u1 = 0,
        /// SMBTYPE [3:3]
        /// SMBus type
        SMBTYPE: u1 = 0,
        /// ENARP [4:4]
        /// ARP enable
        ENARP: u1 = 0,
        /// ENPEC [5:5]
        /// PEC enable
        ENPEC: u1 = 0,
        /// ENGC [6:6]
        /// General call enable
        ENGC: u1 = 0,
        /// NOSTRETCH [7:7]
        /// Clock stretching disable (Slave
        NOSTRETCH: u1 = 0,
        /// START [8:8]
        /// Start generation
        START: u1 = 0,
        /// STOP [9:9]
        /// Stop generation
        STOP: u1 = 0,
        /// ACK [10:10]
        /// Acknowledge enable
        ACK: u1 = 0,
        /// POS [11:11]
        /// Acknowledge/PEC Position (for data
        POS: u1 = 0,
        /// PEC [12:12]
        /// Packet error checking
        PEC: u1 = 0,
        /// ALERT [13:13]
        /// SMBus alert
        ALERT: u1 = 0,
        /// unused [14:14]
        _unused14: u1 = 0,
        /// SWRST [15:15]
        /// Software reset
        SWRST: u1 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Control register 1
    pub const CR1 = Register(CR1_val).init(base_address + 0x0);

    /// CR2
    const CR2_val = packed struct {
        /// FREQ [0:5]
        /// Peripheral clock frequency
        FREQ: u6 = 0,
        /// unused [6:7]
        _unused6: u2 = 0,
        /// ITERREN [8:8]
        /// Error interrupt enable
        ITERREN: u1 = 0,
        /// ITEVTEN [9:9]
        /// Event interrupt enable
        ITEVTEN: u1 = 0,
        /// ITBUFEN [10:10]
        /// Buffer interrupt enable
        ITBUFEN: u1 = 0,
        /// DMAEN [11:11]
        /// DMA requests enable
        DMAEN: u1 = 0,
        /// LAST [12:12]
        /// DMA last transfer
        LAST: u1 = 0,
        /// unused [13:31]
        _unused13: u3 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Control register 2
    pub const CR2 = Register(CR2_val).init(base_address + 0x4);

    /// OAR1
    const OAR1_val = packed struct {
        /// ADD0 [0:0]
        /// Interface address
        ADD0: u1 = 0,
        /// ADD7 [1:7]
        /// Interface address
        ADD7: u7 = 0,
        /// ADD10 [8:9]
        /// Interface address
        ADD10: u2 = 0,
        /// unused [10:14]
        _unused10: u5 = 0,
        /// ADDMODE [15:15]
        /// Addressing mode (slave
        ADDMODE: u1 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Own address register 1
    pub const OAR1 = Register(OAR1_val).init(base_address + 0x8);

    /// OAR2
    const OAR2_val = packed struct {
        /// ENDUAL [0:0]
        /// Dual addressing mode
        ENDUAL: u1 = 0,
        /// ADD2 [1:7]
        /// Interface address
        ADD2: u7 = 0,
        /// unused [8:31]
        _unused8: u8 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Own address register 2
    pub const OAR2 = Register(OAR2_val).init(base_address + 0xc);

    /// DR
    const DR_val = packed struct {
        /// DR [0:7]
        /// 8-bit data register
        DR: u8 = 0,
        /// unused [8:31]
        _unused8: u8 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Data register
    pub const DR = Register(DR_val).init(base_address + 0x10);

    /// SR1
    const SR1_val = packed struct {
        /// SB [0:0]
        /// Start bit (Master mode)
        SB: u1 = 0,
        /// ADDR [1:1]
        /// Address sent (master mode)/matched
        ADDR: u1 = 0,
        /// BTF [2:2]
        /// Byte transfer finished
        BTF: u1 = 0,
        /// ADD10 [3:3]
        /// 10-bit header sent (Master
        ADD10: u1 = 0,
        /// STOPF [4:4]
        /// Stop detection (slave
        STOPF: u1 = 0,
        /// unused [5:5]
        _unused5: u1 = 0,
        /// RxNE [6:6]
        /// Data register not empty
        RxNE: u1 = 0,
        /// TxE [7:7]
        /// Data register empty
        TxE: u1 = 0,
        /// BERR [8:8]
        /// Bus error
        BERR: u1 = 0,
        /// ARLO [9:9]
        /// Arbitration lost (master
        ARLO: u1 = 0,
        /// AF [10:10]
        /// Acknowledge failure
        AF: u1 = 0,
        /// OVR [11:11]
        /// Overrun/Underrun
        OVR: u1 = 0,
        /// PECERR [12:12]
        /// PEC Error in reception
        PECERR: u1 = 0,
        /// unused [13:13]
        _unused13: u1 = 0,
        /// TIMEOUT [14:14]
        /// Timeout or Tlow error
        TIMEOUT: u1 = 0,
        /// SMBALERT [15:15]
        /// SMBus alert
        SMBALERT: u1 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Status register 1
    pub const SR1 = Register(SR1_val).init(base_address + 0x14);

    /// SR2
    const SR2_val = packed struct {
        /// MSL [0:0]
        /// Master/slave
        MSL: u1 = 0,
        /// BUSY [1:1]
        /// Bus busy
        BUSY: u1 = 0,
        /// TRA [2:2]
        /// Transmitter/receiver
        TRA: u1 = 0,
        /// unused [3:3]
        _unused3: u1 = 0,
        /// GENCALL [4:4]
        /// General call address (Slave
        GENCALL: u1 = 0,
        /// SMBDEFAULT [5:5]
        /// SMBus device default address (Slave
        SMBDEFAULT: u1 = 0,
        /// SMBHOST [6:6]
        /// SMBus host header (Slave
        SMBHOST: u1 = 0,
        /// DUALF [7:7]
        /// Dual flag (Slave mode)
        DUALF: u1 = 0,
        /// PEC [8:15]
        /// acket error checking
        PEC: u8 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Status register 2
    pub const SR2 = Register(SR2_val).init(base_address + 0x18);

    /// CCR
    const CCR_val = packed struct {
        /// CCR [0:11]
        /// Clock control register in Fast/Standard
        CCR: u12 = 0,
        /// unused [12:13]
        _unused12: u2 = 0,
        /// DUTY [14:14]
        /// Fast mode duty cycle
        DUTY: u1 = 0,
        /// F_S [15:15]
        /// I2C master mode selection
        F_S: u1 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Clock control register
    pub const CCR = Register(CCR_val).init(base_address + 0x1c);

    /// TRISE
    const TRISE_val = packed struct {
        /// TRISE [0:5]
        /// Maximum rise time in Fast/Standard mode
        TRISE: u6 = 2,
        /// unused [6:31]
        _unused6: u2 = 0,
        _unused8: u8 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// TRISE register
    pub const TRISE = Register(TRISE_val).init(base_address + 0x20);
};

/// Inter integrated circuit
pub const I2C2 = struct {
    const base_address = 0x40005800;
    /// CR1
    const CR1_val = packed struct {
        /// PE [0:0]
        /// Peripheral enable
        PE: u1 = 0,
        /// SMBUS [1:1]
        /// SMBus mode
        SMBUS: u1 = 0,
        /// unused [2:2]
        _unused2: u1 = 0,
        /// SMBTYPE [3:3]
        /// SMBus type
        SMBTYPE: u1 = 0,
        /// ENARP [4:4]
        /// ARP enable
        ENARP: u1 = 0,
        /// ENPEC [5:5]
        /// PEC enable
        ENPEC: u1 = 0,
        /// ENGC [6:6]
        /// General call enable
        ENGC: u1 = 0,
        /// NOSTRETCH [7:7]
        /// Clock stretching disable (Slave
        NOSTRETCH: u1 = 0,
        /// START [8:8]
        /// Start generation
        START: u1 = 0,
        /// STOP [9:9]
        /// Stop generation
        STOP: u1 = 0,
        /// ACK [10:10]
        /// Acknowledge enable
        ACK: u1 = 0,
        /// POS [11:11]
        /// Acknowledge/PEC Position (for data
        POS: u1 = 0,
        /// PEC [12:12]
        /// Packet error checking
        PEC: u1 = 0,
        /// ALERT [13:13]
        /// SMBus alert
        ALERT: u1 = 0,
        /// unused [14:14]
        _unused14: u1 = 0,
        /// SWRST [15:15]
        /// Software reset
        SWRST: u1 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Control register 1
    pub const CR1 = Register(CR1_val).init(base_address + 0x0);

    /// CR2
    const CR2_val = packed struct {
        /// FREQ [0:5]
        /// Peripheral clock frequency
        FREQ: u6 = 0,
        /// unused [6:7]
        _unused6: u2 = 0,
        /// ITERREN [8:8]
        /// Error interrupt enable
        ITERREN: u1 = 0,
        /// ITEVTEN [9:9]
        /// Event interrupt enable
        ITEVTEN: u1 = 0,
        /// ITBUFEN [10:10]
        /// Buffer interrupt enable
        ITBUFEN: u1 = 0,
        /// DMAEN [11:11]
        /// DMA requests enable
        DMAEN: u1 = 0,
        /// LAST [12:12]
        /// DMA last transfer
        LAST: u1 = 0,
        /// unused [13:31]
        _unused13: u3 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Control register 2
    pub const CR2 = Register(CR2_val).init(base_address + 0x4);

    /// OAR1
    const OAR1_val = packed struct {
        /// ADD0 [0:0]
        /// Interface address
        ADD0: u1 = 0,
        /// ADD7 [1:7]
        /// Interface address
        ADD7: u7 = 0,
        /// ADD10 [8:9]
        /// Interface address
        ADD10: u2 = 0,
        /// unused [10:14]
        _unused10: u5 = 0,
        /// ADDMODE [15:15]
        /// Addressing mode (slave
        ADDMODE: u1 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Own address register 1
    pub const OAR1 = Register(OAR1_val).init(base_address + 0x8);

    /// OAR2
    const OAR2_val = packed struct {
        /// ENDUAL [0:0]
        /// Dual addressing mode
        ENDUAL: u1 = 0,
        /// ADD2 [1:7]
        /// Interface address
        ADD2: u7 = 0,
        /// unused [8:31]
        _unused8: u8 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Own address register 2
    pub const OAR2 = Register(OAR2_val).init(base_address + 0xc);

    /// DR
    const DR_val = packed struct {
        /// DR [0:7]
        /// 8-bit data register
        DR: u8 = 0,
        /// unused [8:31]
        _unused8: u8 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Data register
    pub const DR = Register(DR_val).init(base_address + 0x10);

    /// SR1
    const SR1_val = packed struct {
        /// SB [0:0]
        /// Start bit (Master mode)
        SB: u1 = 0,
        /// ADDR [1:1]
        /// Address sent (master mode)/matched
        ADDR: u1 = 0,
        /// BTF [2:2]
        /// Byte transfer finished
        BTF: u1 = 0,
        /// ADD10 [3:3]
        /// 10-bit header sent (Master
        ADD10: u1 = 0,
        /// STOPF [4:4]
        /// Stop detection (slave
        STOPF: u1 = 0,
        /// unused [5:5]
        _unused5: u1 = 0,
        /// RxNE [6:6]
        /// Data register not empty
        RxNE: u1 = 0,
        /// TxE [7:7]
        /// Data register empty
        TxE: u1 = 0,
        /// BERR [8:8]
        /// Bus error
        BERR: u1 = 0,
        /// ARLO [9:9]
        /// Arbitration lost (master
        ARLO: u1 = 0,
        /// AF [10:10]
        /// Acknowledge failure
        AF: u1 = 0,
        /// OVR [11:11]
        /// Overrun/Underrun
        OVR: u1 = 0,
        /// PECERR [12:12]
        /// PEC Error in reception
        PECERR: u1 = 0,
        /// unused [13:13]
        _unused13: u1 = 0,
        /// TIMEOUT [14:14]
        /// Timeout or Tlow error
        TIMEOUT: u1 = 0,
        /// SMBALERT [15:15]
        /// SMBus alert
        SMBALERT: u1 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Status register 1
    pub const SR1 = Register(SR1_val).init(base_address + 0x14);

    /// SR2
    const SR2_val = packed struct {
        /// MSL [0:0]
        /// Master/slave
        MSL: u1 = 0,
        /// BUSY [1:1]
        /// Bus busy
        BUSY: u1 = 0,
        /// TRA [2:2]
        /// Transmitter/receiver
        TRA: u1 = 0,
        /// unused [3:3]
        _unused3: u1 = 0,
        /// GENCALL [4:4]
        /// General call address (Slave
        GENCALL: u1 = 0,
        /// SMBDEFAULT [5:5]
        /// SMBus device default address (Slave
        SMBDEFAULT: u1 = 0,
        /// SMBHOST [6:6]
        /// SMBus host header (Slave
        SMBHOST: u1 = 0,
        /// DUALF [7:7]
        /// Dual flag (Slave mode)
        DUALF: u1 = 0,
        /// PEC [8:15]
        /// acket error checking
        PEC: u8 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Status register 2
    pub const SR2 = Register(SR2_val).init(base_address + 0x18);

    /// CCR
    const CCR_val = packed struct {
        /// CCR [0:11]
        /// Clock control register in Fast/Standard
        CCR: u12 = 0,
        /// unused [12:13]
        _unused12: u2 = 0,
        /// DUTY [14:14]
        /// Fast mode duty cycle
        DUTY: u1 = 0,
        /// F_S [15:15]
        /// I2C master mode selection
        F_S: u1 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Clock control register
    pub const CCR = Register(CCR_val).init(base_address + 0x1c);

    /// TRISE
    const TRISE_val = packed struct {
        /// TRISE [0:5]
        /// Maximum rise time in Fast/Standard mode
        TRISE: u6 = 2,
        /// unused [6:31]
        _unused6: u2 = 0,
        _unused8: u8 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// TRISE register
    pub const TRISE = Register(TRISE_val).init(base_address + 0x20);
};

/// Serial peripheral interface
pub const SPI1 = struct {
    const base_address = 0x40013000;
    /// CR1
    const CR1_val = packed struct {
        /// CPHA [0:0]
        /// Clock phase
        CPHA: u1 = 0,
        /// CPOL [1:1]
        /// Clock polarity
        CPOL: u1 = 0,
        /// MSTR [2:2]
        /// Master selection
        MSTR: u1 = 0,
        /// BR [3:5]
        /// Baud rate control
        BR: u3 = 0,
        /// SPE [6:6]
        /// SPI enable
        SPE: u1 = 0,
        /// LSBFIRST [7:7]
        /// Frame format
        LSBFIRST: u1 = 0,
        /// SSI [8:8]
        /// Internal slave select
        SSI: u1 = 0,
        /// SSM [9:9]
        /// Software slave management
        SSM: u1 = 0,
        /// RXONLY [10:10]
        /// Receive only
        RXONLY: u1 = 0,
        /// DFF [11:11]
        /// Data frame format
        DFF: u1 = 0,
        /// CRCNEXT [12:12]
        /// CRC transfer next
        CRCNEXT: u1 = 0,
        /// CRCEN [13:13]
        /// Hardware CRC calculation
        CRCEN: u1 = 0,
        /// BIDIOE [14:14]
        /// Output enable in bidirectional
        BIDIOE: u1 = 0,
        /// BIDIMODE [15:15]
        /// Bidirectional data mode
        BIDIMODE: u1 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// control register 1
    pub const CR1 = Register(CR1_val).init(base_address + 0x0);

    /// CR2
    const CR2_val = packed struct {
        /// RXDMAEN [0:0]
        /// Rx buffer DMA enable
        RXDMAEN: u1 = 0,
        /// TXDMAEN [1:1]
        /// Tx buffer DMA enable
        TXDMAEN: u1 = 0,
        /// SSOE [2:2]
        /// SS output enable
        SSOE: u1 = 0,
        /// unused [3:4]
        _unused3: u2 = 0,
        /// ERRIE [5:5]
        /// Error interrupt enable
        ERRIE: u1 = 0,
        /// RXNEIE [6:6]
        /// RX buffer not empty interrupt
        RXNEIE: u1 = 0,
        /// TXEIE [7:7]
        /// Tx buffer empty interrupt
        TXEIE: u1 = 0,
        /// unused [8:31]
        _unused8: u8 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// control register 2
    pub const CR2 = Register(CR2_val).init(base_address + 0x4);

    /// SR
    const SR_val = packed struct {
        /// RXNE [0:0]
        /// Receive buffer not empty
        RXNE: u1 = 0,
        /// TXE [1:1]
        /// Transmit buffer empty
        TXE: u1 = 1,
        /// CHSIDE [2:2]
        /// Channel side
        CHSIDE: u1 = 0,
        /// UDR [3:3]
        /// Underrun flag
        UDR: u1 = 0,
        /// CRCERR [4:4]
        /// CRC error flag
        CRCERR: u1 = 0,
        /// MODF [5:5]
        /// Mode fault
        MODF: u1 = 0,
        /// OVR [6:6]
        /// Overrun flag
        OVR: u1 = 0,
        /// BSY [7:7]
        /// Busy flag
        BSY: u1 = 0,
        /// unused [8:31]
        _unused8: u8 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// status register
    pub const SR = Register(SR_val).init(base_address + 0x8);

    /// DR
    const DR_val = packed struct {
        /// DR [0:15]
        /// Data register
        DR: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// data register
    pub const DR = Register(DR_val).init(base_address + 0xc);

    /// CRCPR
    const CRCPR_val = packed struct {
        /// CRCPOLY [0:15]
        /// CRC polynomial register
        CRCPOLY: u16 = 7,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// CRC polynomial register
    pub const CRCPR = Register(CRCPR_val).init(base_address + 0x10);

    /// RXCRCR
    const RXCRCR_val = packed struct {
        /// RxCRC [0:15]
        /// Rx CRC register
        RxCRC: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// RX CRC register
    pub const RXCRCR = Register(RXCRCR_val).init(base_address + 0x14);

    /// TXCRCR
    const TXCRCR_val = packed struct {
        /// TxCRC [0:15]
        /// Tx CRC register
        TxCRC: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// TX CRC register
    pub const TXCRCR = Register(TXCRCR_val).init(base_address + 0x18);

    /// I2SCFGR
    const I2SCFGR_val = packed struct {
        /// CHLEN [0:0]
        /// Channel length (number of bits per audio
        CHLEN: u1 = 0,
        /// DATLEN [1:2]
        /// Data length to be
        DATLEN: u2 = 0,
        /// CKPOL [3:3]
        /// Steady state clock
        CKPOL: u1 = 0,
        /// I2SSTD [4:5]
        /// I2S standard selection
        I2SSTD: u2 = 0,
        /// unused [6:6]
        _unused6: u1 = 0,
        /// PCMSYNC [7:7]
        /// PCM frame synchronization
        PCMSYNC: u1 = 0,
        /// I2SCFG [8:9]
        /// I2S configuration mode
        I2SCFG: u2 = 0,
        /// I2SE [10:10]
        /// I2S Enable
        I2SE: u1 = 0,
        /// I2SMOD [11:11]
        /// I2S mode selection
        I2SMOD: u1 = 0,
        /// unused [12:31]
        _unused12: u4 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// I2S configuration register
    pub const I2SCFGR = Register(I2SCFGR_val).init(base_address + 0x1c);

    /// I2SPR
    const I2SPR_val = packed struct {
        /// I2SDIV [0:7]
        /// I2S Linear prescaler
        I2SDIV: u8 = 16,
        /// ODD [8:8]
        /// Odd factor for the
        ODD: u1 = 0,
        /// MCKOE [9:9]
        /// Master clock output enable
        MCKOE: u1 = 0,
        /// unused [10:31]
        _unused10: u6 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// I2S prescaler register
    pub const I2SPR = Register(I2SPR_val).init(base_address + 0x20);
};

/// Serial peripheral interface
pub const SPI2 = struct {
    const base_address = 0x40003800;
    /// CR1
    const CR1_val = packed struct {
        /// CPHA [0:0]
        /// Clock phase
        CPHA: u1 = 0,
        /// CPOL [1:1]
        /// Clock polarity
        CPOL: u1 = 0,
        /// MSTR [2:2]
        /// Master selection
        MSTR: u1 = 0,
        /// BR [3:5]
        /// Baud rate control
        BR: u3 = 0,
        /// SPE [6:6]
        /// SPI enable
        SPE: u1 = 0,
        /// LSBFIRST [7:7]
        /// Frame format
        LSBFIRST: u1 = 0,
        /// SSI [8:8]
        /// Internal slave select
        SSI: u1 = 0,
        /// SSM [9:9]
        /// Software slave management
        SSM: u1 = 0,
        /// RXONLY [10:10]
        /// Receive only
        RXONLY: u1 = 0,
        /// DFF [11:11]
        /// Data frame format
        DFF: u1 = 0,
        /// CRCNEXT [12:12]
        /// CRC transfer next
        CRCNEXT: u1 = 0,
        /// CRCEN [13:13]
        /// Hardware CRC calculation
        CRCEN: u1 = 0,
        /// BIDIOE [14:14]
        /// Output enable in bidirectional
        BIDIOE: u1 = 0,
        /// BIDIMODE [15:15]
        /// Bidirectional data mode
        BIDIMODE: u1 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// control register 1
    pub const CR1 = Register(CR1_val).init(base_address + 0x0);

    /// CR2
    const CR2_val = packed struct {
        /// RXDMAEN [0:0]
        /// Rx buffer DMA enable
        RXDMAEN: u1 = 0,
        /// TXDMAEN [1:1]
        /// Tx buffer DMA enable
        TXDMAEN: u1 = 0,
        /// SSOE [2:2]
        /// SS output enable
        SSOE: u1 = 0,
        /// unused [3:4]
        _unused3: u2 = 0,
        /// ERRIE [5:5]
        /// Error interrupt enable
        ERRIE: u1 = 0,
        /// RXNEIE [6:6]
        /// RX buffer not empty interrupt
        RXNEIE: u1 = 0,
        /// TXEIE [7:7]
        /// Tx buffer empty interrupt
        TXEIE: u1 = 0,
        /// unused [8:31]
        _unused8: u8 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// control register 2
    pub const CR2 = Register(CR2_val).init(base_address + 0x4);

    /// SR
    const SR_val = packed struct {
        /// RXNE [0:0]
        /// Receive buffer not empty
        RXNE: u1 = 0,
        /// TXE [1:1]
        /// Transmit buffer empty
        TXE: u1 = 1,
        /// CHSIDE [2:2]
        /// Channel side
        CHSIDE: u1 = 0,
        /// UDR [3:3]
        /// Underrun flag
        UDR: u1 = 0,
        /// CRCERR [4:4]
        /// CRC error flag
        CRCERR: u1 = 0,
        /// MODF [5:5]
        /// Mode fault
        MODF: u1 = 0,
        /// OVR [6:6]
        /// Overrun flag
        OVR: u1 = 0,
        /// BSY [7:7]
        /// Busy flag
        BSY: u1 = 0,
        /// unused [8:31]
        _unused8: u8 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// status register
    pub const SR = Register(SR_val).init(base_address + 0x8);

    /// DR
    const DR_val = packed struct {
        /// DR [0:15]
        /// Data register
        DR: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// data register
    pub const DR = Register(DR_val).init(base_address + 0xc);

    /// CRCPR
    const CRCPR_val = packed struct {
        /// CRCPOLY [0:15]
        /// CRC polynomial register
        CRCPOLY: u16 = 7,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// CRC polynomial register
    pub const CRCPR = Register(CRCPR_val).init(base_address + 0x10);

    /// RXCRCR
    const RXCRCR_val = packed struct {
        /// RxCRC [0:15]
        /// Rx CRC register
        RxCRC: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// RX CRC register
    pub const RXCRCR = Register(RXCRCR_val).init(base_address + 0x14);

    /// TXCRCR
    const TXCRCR_val = packed struct {
        /// TxCRC [0:15]
        /// Tx CRC register
        TxCRC: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// TX CRC register
    pub const TXCRCR = Register(TXCRCR_val).init(base_address + 0x18);

    /// I2SCFGR
    const I2SCFGR_val = packed struct {
        /// CHLEN [0:0]
        /// Channel length (number of bits per audio
        CHLEN: u1 = 0,
        /// DATLEN [1:2]
        /// Data length to be
        DATLEN: u2 = 0,
        /// CKPOL [3:3]
        /// Steady state clock
        CKPOL: u1 = 0,
        /// I2SSTD [4:5]
        /// I2S standard selection
        I2SSTD: u2 = 0,
        /// unused [6:6]
        _unused6: u1 = 0,
        /// PCMSYNC [7:7]
        /// PCM frame synchronization
        PCMSYNC: u1 = 0,
        /// I2SCFG [8:9]
        /// I2S configuration mode
        I2SCFG: u2 = 0,
        /// I2SE [10:10]
        /// I2S Enable
        I2SE: u1 = 0,
        /// I2SMOD [11:11]
        /// I2S mode selection
        I2SMOD: u1 = 0,
        /// unused [12:31]
        _unused12: u4 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// I2S configuration register
    pub const I2SCFGR = Register(I2SCFGR_val).init(base_address + 0x1c);

    /// I2SPR
    const I2SPR_val = packed struct {
        /// I2SDIV [0:7]
        /// I2S Linear prescaler
        I2SDIV: u8 = 16,
        /// ODD [8:8]
        /// Odd factor for the
        ODD: u1 = 0,
        /// MCKOE [9:9]
        /// Master clock output enable
        MCKOE: u1 = 0,
        /// unused [10:31]
        _unused10: u6 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// I2S prescaler register
    pub const I2SPR = Register(I2SPR_val).init(base_address + 0x20);
};

/// Serial peripheral interface
pub const SPI3 = struct {
    const base_address = 0x40003c00;
    /// CR1
    const CR1_val = packed struct {
        /// CPHA [0:0]
        /// Clock phase
        CPHA: u1 = 0,
        /// CPOL [1:1]
        /// Clock polarity
        CPOL: u1 = 0,
        /// MSTR [2:2]
        /// Master selection
        MSTR: u1 = 0,
        /// BR [3:5]
        /// Baud rate control
        BR: u3 = 0,
        /// SPE [6:6]
        /// SPI enable
        SPE: u1 = 0,
        /// LSBFIRST [7:7]
        /// Frame format
        LSBFIRST: u1 = 0,
        /// SSI [8:8]
        /// Internal slave select
        SSI: u1 = 0,
        /// SSM [9:9]
        /// Software slave management
        SSM: u1 = 0,
        /// RXONLY [10:10]
        /// Receive only
        RXONLY: u1 = 0,
        /// DFF [11:11]
        /// Data frame format
        DFF: u1 = 0,
        /// CRCNEXT [12:12]
        /// CRC transfer next
        CRCNEXT: u1 = 0,
        /// CRCEN [13:13]
        /// Hardware CRC calculation
        CRCEN: u1 = 0,
        /// BIDIOE [14:14]
        /// Output enable in bidirectional
        BIDIOE: u1 = 0,
        /// BIDIMODE [15:15]
        /// Bidirectional data mode
        BIDIMODE: u1 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// control register 1
    pub const CR1 = Register(CR1_val).init(base_address + 0x0);

    /// CR2
    const CR2_val = packed struct {
        /// RXDMAEN [0:0]
        /// Rx buffer DMA enable
        RXDMAEN: u1 = 0,
        /// TXDMAEN [1:1]
        /// Tx buffer DMA enable
        TXDMAEN: u1 = 0,
        /// SSOE [2:2]
        /// SS output enable
        SSOE: u1 = 0,
        /// unused [3:4]
        _unused3: u2 = 0,
        /// ERRIE [5:5]
        /// Error interrupt enable
        ERRIE: u1 = 0,
        /// RXNEIE [6:6]
        /// RX buffer not empty interrupt
        RXNEIE: u1 = 0,
        /// TXEIE [7:7]
        /// Tx buffer empty interrupt
        TXEIE: u1 = 0,
        /// unused [8:31]
        _unused8: u8 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// control register 2
    pub const CR2 = Register(CR2_val).init(base_address + 0x4);

    /// SR
    const SR_val = packed struct {
        /// RXNE [0:0]
        /// Receive buffer not empty
        RXNE: u1 = 0,
        /// TXE [1:1]
        /// Transmit buffer empty
        TXE: u1 = 1,
        /// CHSIDE [2:2]
        /// Channel side
        CHSIDE: u1 = 0,
        /// UDR [3:3]
        /// Underrun flag
        UDR: u1 = 0,
        /// CRCERR [4:4]
        /// CRC error flag
        CRCERR: u1 = 0,
        /// MODF [5:5]
        /// Mode fault
        MODF: u1 = 0,
        /// OVR [6:6]
        /// Overrun flag
        OVR: u1 = 0,
        /// BSY [7:7]
        /// Busy flag
        BSY: u1 = 0,
        /// unused [8:31]
        _unused8: u8 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// status register
    pub const SR = Register(SR_val).init(base_address + 0x8);

    /// DR
    const DR_val = packed struct {
        /// DR [0:15]
        /// Data register
        DR: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// data register
    pub const DR = Register(DR_val).init(base_address + 0xc);

    /// CRCPR
    const CRCPR_val = packed struct {
        /// CRCPOLY [0:15]
        /// CRC polynomial register
        CRCPOLY: u16 = 7,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// CRC polynomial register
    pub const CRCPR = Register(CRCPR_val).init(base_address + 0x10);

    /// RXCRCR
    const RXCRCR_val = packed struct {
        /// RxCRC [0:15]
        /// Rx CRC register
        RxCRC: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// RX CRC register
    pub const RXCRCR = Register(RXCRCR_val).init(base_address + 0x14);

    /// TXCRCR
    const TXCRCR_val = packed struct {
        /// TxCRC [0:15]
        /// Tx CRC register
        TxCRC: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// TX CRC register
    pub const TXCRCR = Register(TXCRCR_val).init(base_address + 0x18);

    /// I2SCFGR
    const I2SCFGR_val = packed struct {
        /// CHLEN [0:0]
        /// Channel length (number of bits per audio
        CHLEN: u1 = 0,
        /// DATLEN [1:2]
        /// Data length to be
        DATLEN: u2 = 0,
        /// CKPOL [3:3]
        /// Steady state clock
        CKPOL: u1 = 0,
        /// I2SSTD [4:5]
        /// I2S standard selection
        I2SSTD: u2 = 0,
        /// unused [6:6]
        _unused6: u1 = 0,
        /// PCMSYNC [7:7]
        /// PCM frame synchronization
        PCMSYNC: u1 = 0,
        /// I2SCFG [8:9]
        /// I2S configuration mode
        I2SCFG: u2 = 0,
        /// I2SE [10:10]
        /// I2S Enable
        I2SE: u1 = 0,
        /// I2SMOD [11:11]
        /// I2S mode selection
        I2SMOD: u1 = 0,
        /// unused [12:31]
        _unused12: u4 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// I2S configuration register
    pub const I2SCFGR = Register(I2SCFGR_val).init(base_address + 0x1c);

    /// I2SPR
    const I2SPR_val = packed struct {
        /// I2SDIV [0:7]
        /// I2S Linear prescaler
        I2SDIV: u8 = 16,
        /// ODD [8:8]
        /// Odd factor for the
        ODD: u1 = 0,
        /// MCKOE [9:9]
        /// Master clock output enable
        MCKOE: u1 = 0,
        /// unused [10:31]
        _unused10: u6 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// I2S prescaler register
    pub const I2SPR = Register(I2SPR_val).init(base_address + 0x20);
};

/// Universal synchronous asynchronous receiver
pub const USART1 = struct {
    const base_address = 0x40013800;
    /// SR
    const SR_val = packed struct {
        /// PE [0:0]
        /// Parity error
        PE: u1 = 0,
        /// FE [1:1]
        /// Framing error
        FE: u1 = 0,
        /// NE [2:2]
        /// Noise error flag
        NE: u1 = 0,
        /// ORE [3:3]
        /// Overrun error
        ORE: u1 = 0,
        /// IDLE [4:4]
        /// IDLE line detected
        IDLE: u1 = 0,
        /// RXNE [5:5]
        /// Read data register not
        RXNE: u1 = 0,
        /// TC [6:6]
        /// Transmission complete
        TC: u1 = 1,
        /// TXE [7:7]
        /// Transmit data register
        TXE: u1 = 1,
        /// LBD [8:8]
        /// LIN break detection flag
        LBD: u1 = 0,
        /// CTS [9:9]
        /// CTS flag
        CTS: u1 = 0,
        /// unused [10:31]
        _unused10: u6 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Status register
    pub const SR = Register(SR_val).init(base_address + 0x0);

    /// DR
    const DR_val = packed struct {
        /// DR [0:8]
        /// Data value
        DR: u9 = 0,
        /// unused [9:31]
        _unused9: u7 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Data register
    pub const DR = Register(DR_val).init(base_address + 0x4);

    /// BRR
    const BRR_val = packed struct {
        /// DIV_Fraction [0:3]
        /// fraction of USARTDIV
        DIV_Fraction: u4 = 0,
        /// DIV_Mantissa [4:15]
        /// mantissa of USARTDIV
        DIV_Mantissa: u12 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Baud rate register
    pub const BRR = Register(BRR_val).init(base_address + 0x8);

    /// CR1
    const CR1_val = packed struct {
        /// SBK [0:0]
        /// Send break
        SBK: u1 = 0,
        /// RWU [1:1]
        /// Receiver wakeup
        RWU: u1 = 0,
        /// RE [2:2]
        /// Receiver enable
        RE: u1 = 0,
        /// TE [3:3]
        /// Transmitter enable
        TE: u1 = 0,
        /// IDLEIE [4:4]
        /// IDLE interrupt enable
        IDLEIE: u1 = 0,
        /// RXNEIE [5:5]
        /// RXNE interrupt enable
        RXNEIE: u1 = 0,
        /// TCIE [6:6]
        /// Transmission complete interrupt
        TCIE: u1 = 0,
        /// TXEIE [7:7]
        /// TXE interrupt enable
        TXEIE: u1 = 0,
        /// PEIE [8:8]
        /// PE interrupt enable
        PEIE: u1 = 0,
        /// PS [9:9]
        /// Parity selection
        PS: u1 = 0,
        /// PCE [10:10]
        /// Parity control enable
        PCE: u1 = 0,
        /// WAKE [11:11]
        /// Wakeup method
        WAKE: u1 = 0,
        /// M [12:12]
        /// Word length
        M: u1 = 0,
        /// UE [13:13]
        /// USART enable
        UE: u1 = 0,
        /// unused [14:31]
        _unused14: u2 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Control register 1
    pub const CR1 = Register(CR1_val).init(base_address + 0xc);

    /// CR2
    const CR2_val = packed struct {
        /// ADD [0:3]
        /// Address of the USART node
        ADD: u4 = 0,
        /// unused [4:4]
        _unused4: u1 = 0,
        /// LBDL [5:5]
        /// lin break detection length
        LBDL: u1 = 0,
        /// LBDIE [6:6]
        /// LIN break detection interrupt
        LBDIE: u1 = 0,
        /// unused [7:7]
        _unused7: u1 = 0,
        /// LBCL [8:8]
        /// Last bit clock pulse
        LBCL: u1 = 0,
        /// CPHA [9:9]
        /// Clock phase
        CPHA: u1 = 0,
        /// CPOL [10:10]
        /// Clock polarity
        CPOL: u1 = 0,
        /// CLKEN [11:11]
        /// Clock enable
        CLKEN: u1 = 0,
        /// STOP [12:13]
        /// STOP bits
        STOP: u2 = 0,
        /// LINEN [14:14]
        /// LIN mode enable
        LINEN: u1 = 0,
        /// unused [15:31]
        _unused15: u1 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Control register 2
    pub const CR2 = Register(CR2_val).init(base_address + 0x10);

    /// CR3
    const CR3_val = packed struct {
        /// EIE [0:0]
        /// Error interrupt enable
        EIE: u1 = 0,
        /// IREN [1:1]
        /// IrDA mode enable
        IREN: u1 = 0,
        /// IRLP [2:2]
        /// IrDA low-power
        IRLP: u1 = 0,
        /// HDSEL [3:3]
        /// Half-duplex selection
        HDSEL: u1 = 0,
        /// NACK [4:4]
        /// Smartcard NACK enable
        NACK: u1 = 0,
        /// SCEN [5:5]
        /// Smartcard mode enable
        SCEN: u1 = 0,
        /// DMAR [6:6]
        /// DMA enable receiver
        DMAR: u1 = 0,
        /// DMAT [7:7]
        /// DMA enable transmitter
        DMAT: u1 = 0,
        /// RTSE [8:8]
        /// RTS enable
        RTSE: u1 = 0,
        /// CTSE [9:9]
        /// CTS enable
        CTSE: u1 = 0,
        /// CTSIE [10:10]
        /// CTS interrupt enable
        CTSIE: u1 = 0,
        /// unused [11:31]
        _unused11: u5 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Control register 3
    pub const CR3 = Register(CR3_val).init(base_address + 0x14);

    /// GTPR
    const GTPR_val = packed struct {
        /// PSC [0:7]
        /// Prescaler value
        PSC: u8 = 0,
        /// GT [8:15]
        /// Guard time value
        GT: u8 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Guard time and prescaler
    pub const GTPR = Register(GTPR_val).init(base_address + 0x18);
};

/// Universal synchronous asynchronous receiver
pub const USART2 = struct {
    const base_address = 0x40004400;
    /// SR
    const SR_val = packed struct {
        /// PE [0:0]
        /// Parity error
        PE: u1 = 0,
        /// FE [1:1]
        /// Framing error
        FE: u1 = 0,
        /// NE [2:2]
        /// Noise error flag
        NE: u1 = 0,
        /// ORE [3:3]
        /// Overrun error
        ORE: u1 = 0,
        /// IDLE [4:4]
        /// IDLE line detected
        IDLE: u1 = 0,
        /// RXNE [5:5]
        /// Read data register not
        RXNE: u1 = 0,
        /// TC [6:6]
        /// Transmission complete
        TC: u1 = 1,
        /// TXE [7:7]
        /// Transmit data register
        TXE: u1 = 1,
        /// LBD [8:8]
        /// LIN break detection flag
        LBD: u1 = 0,
        /// CTS [9:9]
        /// CTS flag
        CTS: u1 = 0,
        /// unused [10:31]
        _unused10: u6 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Status register
    pub const SR = Register(SR_val).init(base_address + 0x0);

    /// DR
    const DR_val = packed struct {
        /// DR [0:8]
        /// Data value
        DR: u9 = 0,
        /// unused [9:31]
        _unused9: u7 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Data register
    pub const DR = Register(DR_val).init(base_address + 0x4);

    /// BRR
    const BRR_val = packed struct {
        /// DIV_Fraction [0:3]
        /// fraction of USARTDIV
        DIV_Fraction: u4 = 0,
        /// DIV_Mantissa [4:15]
        /// mantissa of USARTDIV
        DIV_Mantissa: u12 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Baud rate register
    pub const BRR = Register(BRR_val).init(base_address + 0x8);

    /// CR1
    const CR1_val = packed struct {
        /// SBK [0:0]
        /// Send break
        SBK: u1 = 0,
        /// RWU [1:1]
        /// Receiver wakeup
        RWU: u1 = 0,
        /// RE [2:2]
        /// Receiver enable
        RE: u1 = 0,
        /// TE [3:3]
        /// Transmitter enable
        TE: u1 = 0,
        /// IDLEIE [4:4]
        /// IDLE interrupt enable
        IDLEIE: u1 = 0,
        /// RXNEIE [5:5]
        /// RXNE interrupt enable
        RXNEIE: u1 = 0,
        /// TCIE [6:6]
        /// Transmission complete interrupt
        TCIE: u1 = 0,
        /// TXEIE [7:7]
        /// TXE interrupt enable
        TXEIE: u1 = 0,
        /// PEIE [8:8]
        /// PE interrupt enable
        PEIE: u1 = 0,
        /// PS [9:9]
        /// Parity selection
        PS: u1 = 0,
        /// PCE [10:10]
        /// Parity control enable
        PCE: u1 = 0,
        /// WAKE [11:11]
        /// Wakeup method
        WAKE: u1 = 0,
        /// M [12:12]
        /// Word length
        M: u1 = 0,
        /// UE [13:13]
        /// USART enable
        UE: u1 = 0,
        /// unused [14:31]
        _unused14: u2 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Control register 1
    pub const CR1 = Register(CR1_val).init(base_address + 0xc);

    /// CR2
    const CR2_val = packed struct {
        /// ADD [0:3]
        /// Address of the USART node
        ADD: u4 = 0,
        /// unused [4:4]
        _unused4: u1 = 0,
        /// LBDL [5:5]
        /// lin break detection length
        LBDL: u1 = 0,
        /// LBDIE [6:6]
        /// LIN break detection interrupt
        LBDIE: u1 = 0,
        /// unused [7:7]
        _unused7: u1 = 0,
        /// LBCL [8:8]
        /// Last bit clock pulse
        LBCL: u1 = 0,
        /// CPHA [9:9]
        /// Clock phase
        CPHA: u1 = 0,
        /// CPOL [10:10]
        /// Clock polarity
        CPOL: u1 = 0,
        /// CLKEN [11:11]
        /// Clock enable
        CLKEN: u1 = 0,
        /// STOP [12:13]
        /// STOP bits
        STOP: u2 = 0,
        /// LINEN [14:14]
        /// LIN mode enable
        LINEN: u1 = 0,
        /// unused [15:31]
        _unused15: u1 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Control register 2
    pub const CR2 = Register(CR2_val).init(base_address + 0x10);

    /// CR3
    const CR3_val = packed struct {
        /// EIE [0:0]
        /// Error interrupt enable
        EIE: u1 = 0,
        /// IREN [1:1]
        /// IrDA mode enable
        IREN: u1 = 0,
        /// IRLP [2:2]
        /// IrDA low-power
        IRLP: u1 = 0,
        /// HDSEL [3:3]
        /// Half-duplex selection
        HDSEL: u1 = 0,
        /// NACK [4:4]
        /// Smartcard NACK enable
        NACK: u1 = 0,
        /// SCEN [5:5]
        /// Smartcard mode enable
        SCEN: u1 = 0,
        /// DMAR [6:6]
        /// DMA enable receiver
        DMAR: u1 = 0,
        /// DMAT [7:7]
        /// DMA enable transmitter
        DMAT: u1 = 0,
        /// RTSE [8:8]
        /// RTS enable
        RTSE: u1 = 0,
        /// CTSE [9:9]
        /// CTS enable
        CTSE: u1 = 0,
        /// CTSIE [10:10]
        /// CTS interrupt enable
        CTSIE: u1 = 0,
        /// unused [11:31]
        _unused11: u5 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Control register 3
    pub const CR3 = Register(CR3_val).init(base_address + 0x14);

    /// GTPR
    const GTPR_val = packed struct {
        /// PSC [0:7]
        /// Prescaler value
        PSC: u8 = 0,
        /// GT [8:15]
        /// Guard time value
        GT: u8 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Guard time and prescaler
    pub const GTPR = Register(GTPR_val).init(base_address + 0x18);
};

/// Universal synchronous asynchronous receiver
pub const USART3 = struct {
    const base_address = 0x40004800;
    /// SR
    const SR_val = packed struct {
        /// PE [0:0]
        /// Parity error
        PE: u1 = 0,
        /// FE [1:1]
        /// Framing error
        FE: u1 = 0,
        /// NE [2:2]
        /// Noise error flag
        NE: u1 = 0,
        /// ORE [3:3]
        /// Overrun error
        ORE: u1 = 0,
        /// IDLE [4:4]
        /// IDLE line detected
        IDLE: u1 = 0,
        /// RXNE [5:5]
        /// Read data register not
        RXNE: u1 = 0,
        /// TC [6:6]
        /// Transmission complete
        TC: u1 = 1,
        /// TXE [7:7]
        /// Transmit data register
        TXE: u1 = 1,
        /// LBD [8:8]
        /// LIN break detection flag
        LBD: u1 = 0,
        /// CTS [9:9]
        /// CTS flag
        CTS: u1 = 0,
        /// unused [10:31]
        _unused10: u6 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Status register
    pub const SR = Register(SR_val).init(base_address + 0x0);

    /// DR
    const DR_val = packed struct {
        /// DR [0:8]
        /// Data value
        DR: u9 = 0,
        /// unused [9:31]
        _unused9: u7 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Data register
    pub const DR = Register(DR_val).init(base_address + 0x4);

    /// BRR
    const BRR_val = packed struct {
        /// DIV_Fraction [0:3]
        /// fraction of USARTDIV
        DIV_Fraction: u4 = 0,
        /// DIV_Mantissa [4:15]
        /// mantissa of USARTDIV
        DIV_Mantissa: u12 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Baud rate register
    pub const BRR = Register(BRR_val).init(base_address + 0x8);

    /// CR1
    const CR1_val = packed struct {
        /// SBK [0:0]
        /// Send break
        SBK: u1 = 0,
        /// RWU [1:1]
        /// Receiver wakeup
        RWU: u1 = 0,
        /// RE [2:2]
        /// Receiver enable
        RE: u1 = 0,
        /// TE [3:3]
        /// Transmitter enable
        TE: u1 = 0,
        /// IDLEIE [4:4]
        /// IDLE interrupt enable
        IDLEIE: u1 = 0,
        /// RXNEIE [5:5]
        /// RXNE interrupt enable
        RXNEIE: u1 = 0,
        /// TCIE [6:6]
        /// Transmission complete interrupt
        TCIE: u1 = 0,
        /// TXEIE [7:7]
        /// TXE interrupt enable
        TXEIE: u1 = 0,
        /// PEIE [8:8]
        /// PE interrupt enable
        PEIE: u1 = 0,
        /// PS [9:9]
        /// Parity selection
        PS: u1 = 0,
        /// PCE [10:10]
        /// Parity control enable
        PCE: u1 = 0,
        /// WAKE [11:11]
        /// Wakeup method
        WAKE: u1 = 0,
        /// M [12:12]
        /// Word length
        M: u1 = 0,
        /// UE [13:13]
        /// USART enable
        UE: u1 = 0,
        /// unused [14:31]
        _unused14: u2 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Control register 1
    pub const CR1 = Register(CR1_val).init(base_address + 0xc);

    /// CR2
    const CR2_val = packed struct {
        /// ADD [0:3]
        /// Address of the USART node
        ADD: u4 = 0,
        /// unused [4:4]
        _unused4: u1 = 0,
        /// LBDL [5:5]
        /// lin break detection length
        LBDL: u1 = 0,
        /// LBDIE [6:6]
        /// LIN break detection interrupt
        LBDIE: u1 = 0,
        /// unused [7:7]
        _unused7: u1 = 0,
        /// LBCL [8:8]
        /// Last bit clock pulse
        LBCL: u1 = 0,
        /// CPHA [9:9]
        /// Clock phase
        CPHA: u1 = 0,
        /// CPOL [10:10]
        /// Clock polarity
        CPOL: u1 = 0,
        /// CLKEN [11:11]
        /// Clock enable
        CLKEN: u1 = 0,
        /// STOP [12:13]
        /// STOP bits
        STOP: u2 = 0,
        /// LINEN [14:14]
        /// LIN mode enable
        LINEN: u1 = 0,
        /// unused [15:31]
        _unused15: u1 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Control register 2
    pub const CR2 = Register(CR2_val).init(base_address + 0x10);

    /// CR3
    const CR3_val = packed struct {
        /// EIE [0:0]
        /// Error interrupt enable
        EIE: u1 = 0,
        /// IREN [1:1]
        /// IrDA mode enable
        IREN: u1 = 0,
        /// IRLP [2:2]
        /// IrDA low-power
        IRLP: u1 = 0,
        /// HDSEL [3:3]
        /// Half-duplex selection
        HDSEL: u1 = 0,
        /// NACK [4:4]
        /// Smartcard NACK enable
        NACK: u1 = 0,
        /// SCEN [5:5]
        /// Smartcard mode enable
        SCEN: u1 = 0,
        /// DMAR [6:6]
        /// DMA enable receiver
        DMAR: u1 = 0,
        /// DMAT [7:7]
        /// DMA enable transmitter
        DMAT: u1 = 0,
        /// RTSE [8:8]
        /// RTS enable
        RTSE: u1 = 0,
        /// CTSE [9:9]
        /// CTS enable
        CTSE: u1 = 0,
        /// CTSIE [10:10]
        /// CTS interrupt enable
        CTSIE: u1 = 0,
        /// unused [11:31]
        _unused11: u5 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Control register 3
    pub const CR3 = Register(CR3_val).init(base_address + 0x14);

    /// GTPR
    const GTPR_val = packed struct {
        /// PSC [0:7]
        /// Prescaler value
        PSC: u8 = 0,
        /// GT [8:15]
        /// Guard time value
        GT: u8 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Guard time and prescaler
    pub const GTPR = Register(GTPR_val).init(base_address + 0x18);
};

/// Analog to digital converter
pub const ADC1 = struct {
    const base_address = 0x40012400;
    /// SR
    const SR_val = packed struct {
        /// AWD [0:0]
        /// Analog watchdog flag
        AWD: u1 = 0,
        /// EOC [1:1]
        /// Regular channel end of
        EOC: u1 = 0,
        /// JEOC [2:2]
        /// Injected channel end of
        JEOC: u1 = 0,
        /// JSTRT [3:3]
        /// Injected channel start
        JSTRT: u1 = 0,
        /// STRT [4:4]
        /// Regular channel start flag
        STRT: u1 = 0,
        /// unused [5:31]
        _unused5: u3 = 0,
        _unused8: u8 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// status register
    pub const SR = Register(SR_val).init(base_address + 0x0);

    /// CR1
    const CR1_val = packed struct {
        /// AWDCH [0:4]
        /// Analog watchdog channel select
        AWDCH: u5 = 0,
        /// EOCIE [5:5]
        /// Interrupt enable for EOC
        EOCIE: u1 = 0,
        /// AWDIE [6:6]
        /// Analog watchdog interrupt
        AWDIE: u1 = 0,
        /// JEOCIE [7:7]
        /// Interrupt enable for injected
        JEOCIE: u1 = 0,
        /// SCAN [8:8]
        /// Scan mode
        SCAN: u1 = 0,
        /// AWDSGL [9:9]
        /// Enable the watchdog on a single channel
        AWDSGL: u1 = 0,
        /// JAUTO [10:10]
        /// Automatic injected group
        JAUTO: u1 = 0,
        /// DISCEN [11:11]
        /// Discontinuous mode on regular
        DISCEN: u1 = 0,
        /// JDISCEN [12:12]
        /// Discontinuous mode on injected
        JDISCEN: u1 = 0,
        /// DISCNUM [13:15]
        /// Discontinuous mode channel
        DISCNUM: u3 = 0,
        /// DUALMOD [16:19]
        /// Dual mode selection
        DUALMOD: u4 = 0,
        /// unused [20:21]
        _unused20: u2 = 0,
        /// JAWDEN [22:22]
        /// Analog watchdog enable on injected
        JAWDEN: u1 = 0,
        /// AWDEN [23:23]
        /// Analog watchdog enable on regular
        AWDEN: u1 = 0,
        /// unused [24:31]
        _unused24: u8 = 0,
    };
    /// control register 1
    pub const CR1 = Register(CR1_val).init(base_address + 0x4);

    /// CR2
    const CR2_val = packed struct {
        /// ADON [0:0]
        /// A/D converter ON / OFF
        ADON: u1 = 0,
        /// CONT [1:1]
        /// Continuous conversion
        CONT: u1 = 0,
        /// CAL [2:2]
        /// A/D calibration
        CAL: u1 = 0,
        /// RSTCAL [3:3]
        /// Reset calibration
        RSTCAL: u1 = 0,
        /// unused [4:7]
        _unused4: u4 = 0,
        /// DMA [8:8]
        /// Direct memory access mode
        DMA: u1 = 0,
        /// unused [9:10]
        _unused9: u2 = 0,
        /// ALIGN [11:11]
        /// Data alignment
        ALIGN: u1 = 0,
        /// JEXTSEL [12:14]
        /// External event select for injected
        JEXTSEL: u3 = 0,
        /// JEXTTRIG [15:15]
        /// External trigger conversion mode for
        JEXTTRIG: u1 = 0,
        /// unused [16:16]
        _unused16: u1 = 0,
        /// EXTSEL [17:19]
        /// External event select for regular
        EXTSEL: u3 = 0,
        /// EXTTRIG [20:20]
        /// External trigger conversion mode for
        EXTTRIG: u1 = 0,
        /// JSWSTART [21:21]
        /// Start conversion of injected
        JSWSTART: u1 = 0,
        /// SWSTART [22:22]
        /// Start conversion of regular
        SWSTART: u1 = 0,
        /// TSVREFE [23:23]
        /// Temperature sensor and VREFINT
        TSVREFE: u1 = 0,
        /// unused [24:31]
        _unused24: u8 = 0,
    };
    /// control register 2
    pub const CR2 = Register(CR2_val).init(base_address + 0x8);

    /// SMPR1
    const SMPR1_val = packed struct {
        /// SMP10 [0:2]
        /// Channel 10 sample time
        SMP10: u3 = 0,
        /// SMP11 [3:5]
        /// Channel 11 sample time
        SMP11: u3 = 0,
        /// SMP12 [6:8]
        /// Channel 12 sample time
        SMP12: u3 = 0,
        /// SMP13 [9:11]
        /// Channel 13 sample time
        SMP13: u3 = 0,
        /// SMP14 [12:14]
        /// Channel 14 sample time
        SMP14: u3 = 0,
        /// SMP15 [15:17]
        /// Channel 15 sample time
        SMP15: u3 = 0,
        /// SMP16 [18:20]
        /// Channel 16 sample time
        SMP16: u3 = 0,
        /// SMP17 [21:23]
        /// Channel 17 sample time
        SMP17: u3 = 0,
        /// unused [24:31]
        _unused24: u8 = 0,
    };
    /// sample time register 1
    pub const SMPR1 = Register(SMPR1_val).init(base_address + 0xc);

    /// SMPR2
    const SMPR2_val = packed struct {
        /// SMP0 [0:2]
        /// Channel 0 sample time
        SMP0: u3 = 0,
        /// SMP1 [3:5]
        /// Channel 1 sample time
        SMP1: u3 = 0,
        /// SMP2 [6:8]
        /// Channel 2 sample time
        SMP2: u3 = 0,
        /// SMP3 [9:11]
        /// Channel 3 sample time
        SMP3: u3 = 0,
        /// SMP4 [12:14]
        /// Channel 4 sample time
        SMP4: u3 = 0,
        /// SMP5 [15:17]
        /// Channel 5 sample time
        SMP5: u3 = 0,
        /// SMP6 [18:20]
        /// Channel 6 sample time
        SMP6: u3 = 0,
        /// SMP7 [21:23]
        /// Channel 7 sample time
        SMP7: u3 = 0,
        /// SMP8 [24:26]
        /// Channel 8 sample time
        SMP8: u3 = 0,
        /// SMP9 [27:29]
        /// Channel 9 sample time
        SMP9: u3 = 0,
        /// unused [30:31]
        _unused30: u2 = 0,
    };
    /// sample time register 2
    pub const SMPR2 = Register(SMPR2_val).init(base_address + 0x10);

    /// JOFR1
    const JOFR1_val = packed struct {
        /// JOFFSET1 [0:11]
        /// Data offset for injected channel
        JOFFSET1: u12 = 0,
        /// unused [12:31]
        _unused12: u4 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// injected channel data offset register
    pub const JOFR1 = Register(JOFR1_val).init(base_address + 0x14);

    /// JOFR2
    const JOFR2_val = packed struct {
        /// JOFFSET2 [0:11]
        /// Data offset for injected channel
        JOFFSET2: u12 = 0,
        /// unused [12:31]
        _unused12: u4 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// injected channel data offset register
    pub const JOFR2 = Register(JOFR2_val).init(base_address + 0x18);

    /// JOFR3
    const JOFR3_val = packed struct {
        /// JOFFSET3 [0:11]
        /// Data offset for injected channel
        JOFFSET3: u12 = 0,
        /// unused [12:31]
        _unused12: u4 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// injected channel data offset register
    pub const JOFR3 = Register(JOFR3_val).init(base_address + 0x1c);

    /// JOFR4
    const JOFR4_val = packed struct {
        /// JOFFSET4 [0:11]
        /// Data offset for injected channel
        JOFFSET4: u12 = 0,
        /// unused [12:31]
        _unused12: u4 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// injected channel data offset register
    pub const JOFR4 = Register(JOFR4_val).init(base_address + 0x20);

    /// HTR
    const HTR_val = packed struct {
        /// HT [0:11]
        /// Analog watchdog higher
        HT: u12 = 4095,
        /// unused [12:31]
        _unused12: u4 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// watchdog higher threshold
    pub const HTR = Register(HTR_val).init(base_address + 0x24);

    /// LTR
    const LTR_val = packed struct {
        /// LT [0:11]
        /// Analog watchdog lower
        LT: u12 = 0,
        /// unused [12:31]
        _unused12: u4 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// watchdog lower threshold
    pub const LTR = Register(LTR_val).init(base_address + 0x28);

    /// SQR1
    const SQR1_val = packed struct {
        /// SQ13 [0:4]
        /// 13th conversion in regular
        SQ13: u5 = 0,
        /// SQ14 [5:9]
        /// 14th conversion in regular
        SQ14: u5 = 0,
        /// SQ15 [10:14]
        /// 15th conversion in regular
        SQ15: u5 = 0,
        /// SQ16 [15:19]
        /// 16th conversion in regular
        SQ16: u5 = 0,
        /// L [20:23]
        /// Regular channel sequence
        L: u4 = 0,
        /// unused [24:31]
        _unused24: u8 = 0,
    };
    /// regular sequence register 1
    pub const SQR1 = Register(SQR1_val).init(base_address + 0x2c);

    /// SQR2
    const SQR2_val = packed struct {
        /// SQ7 [0:4]
        /// 7th conversion in regular
        SQ7: u5 = 0,
        /// SQ8 [5:9]
        /// 8th conversion in regular
        SQ8: u5 = 0,
        /// SQ9 [10:14]
        /// 9th conversion in regular
        SQ9: u5 = 0,
        /// SQ10 [15:19]
        /// 10th conversion in regular
        SQ10: u5 = 0,
        /// SQ11 [20:24]
        /// 11th conversion in regular
        SQ11: u5 = 0,
        /// SQ12 [25:29]
        /// 12th conversion in regular
        SQ12: u5 = 0,
        /// unused [30:31]
        _unused30: u2 = 0,
    };
    /// regular sequence register 2
    pub const SQR2 = Register(SQR2_val).init(base_address + 0x30);

    /// SQR3
    const SQR3_val = packed struct {
        /// SQ1 [0:4]
        /// 1st conversion in regular
        SQ1: u5 = 0,
        /// SQ2 [5:9]
        /// 2nd conversion in regular
        SQ2: u5 = 0,
        /// SQ3 [10:14]
        /// 3rd conversion in regular
        SQ3: u5 = 0,
        /// SQ4 [15:19]
        /// 4th conversion in regular
        SQ4: u5 = 0,
        /// SQ5 [20:24]
        /// 5th conversion in regular
        SQ5: u5 = 0,
        /// SQ6 [25:29]
        /// 6th conversion in regular
        SQ6: u5 = 0,
        /// unused [30:31]
        _unused30: u2 = 0,
    };
    /// regular sequence register 3
    pub const SQR3 = Register(SQR3_val).init(base_address + 0x34);

    /// JSQR
    const JSQR_val = packed struct {
        /// JSQ1 [0:4]
        /// 1st conversion in injected
        JSQ1: u5 = 0,
        /// JSQ2 [5:9]
        /// 2nd conversion in injected
        JSQ2: u5 = 0,
        /// JSQ3 [10:14]
        /// 3rd conversion in injected
        JSQ3: u5 = 0,
        /// JSQ4 [15:19]
        /// 4th conversion in injected
        JSQ4: u5 = 0,
        /// JL [20:21]
        /// Injected sequence length
        JL: u2 = 0,
        /// unused [22:31]
        _unused22: u2 = 0,
        _unused24: u8 = 0,
    };
    /// injected sequence register
    pub const JSQR = Register(JSQR_val).init(base_address + 0x38);

    /// JDR1
    const JDR1_val = packed struct {
        /// JDATA [0:15]
        /// Injected data
        JDATA: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// injected data register x
    pub const JDR1 = Register(JDR1_val).init(base_address + 0x3c);

    /// JDR2
    const JDR2_val = packed struct {
        /// JDATA [0:15]
        /// Injected data
        JDATA: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// injected data register x
    pub const JDR2 = Register(JDR2_val).init(base_address + 0x40);

    /// JDR3
    const JDR3_val = packed struct {
        /// JDATA [0:15]
        /// Injected data
        JDATA: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// injected data register x
    pub const JDR3 = Register(JDR3_val).init(base_address + 0x44);

    /// JDR4
    const JDR4_val = packed struct {
        /// JDATA [0:15]
        /// Injected data
        JDATA: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// injected data register x
    pub const JDR4 = Register(JDR4_val).init(base_address + 0x48);

    /// DR
    const DR_val = packed struct {
        /// DATA [0:15]
        /// Regular data
        DATA: u16 = 0,
        /// ADC2DATA [16:31]
        /// ADC2 data
        ADC2DATA: u16 = 0,
    };
    /// regular data register
    pub const DR = Register(DR_val).init(base_address + 0x4c);
};

/// Analog to digital converter
pub const ADC2 = struct {
    const base_address = 0x40012800;
    /// SR
    const SR_val = packed struct {
        /// AWD [0:0]
        /// Analog watchdog flag
        AWD: u1 = 0,
        /// EOC [1:1]
        /// Regular channel end of
        EOC: u1 = 0,
        /// JEOC [2:2]
        /// Injected channel end of
        JEOC: u1 = 0,
        /// JSTRT [3:3]
        /// Injected channel start
        JSTRT: u1 = 0,
        /// STRT [4:4]
        /// Regular channel start flag
        STRT: u1 = 0,
        /// unused [5:31]
        _unused5: u3 = 0,
        _unused8: u8 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// status register
    pub const SR = Register(SR_val).init(base_address + 0x0);

    /// CR1
    const CR1_val = packed struct {
        /// AWDCH [0:4]
        /// Analog watchdog channel select
        AWDCH: u5 = 0,
        /// EOCIE [5:5]
        /// Interrupt enable for EOC
        EOCIE: u1 = 0,
        /// AWDIE [6:6]
        /// Analog watchdog interrupt
        AWDIE: u1 = 0,
        /// JEOCIE [7:7]
        /// Interrupt enable for injected
        JEOCIE: u1 = 0,
        /// SCAN [8:8]
        /// Scan mode
        SCAN: u1 = 0,
        /// AWDSGL [9:9]
        /// Enable the watchdog on a single channel
        AWDSGL: u1 = 0,
        /// JAUTO [10:10]
        /// Automatic injected group
        JAUTO: u1 = 0,
        /// DISCEN [11:11]
        /// Discontinuous mode on regular
        DISCEN: u1 = 0,
        /// JDISCEN [12:12]
        /// Discontinuous mode on injected
        JDISCEN: u1 = 0,
        /// DISCNUM [13:15]
        /// Discontinuous mode channel
        DISCNUM: u3 = 0,
        /// unused [16:21]
        _unused16: u6 = 0,
        /// JAWDEN [22:22]
        /// Analog watchdog enable on injected
        JAWDEN: u1 = 0,
        /// AWDEN [23:23]
        /// Analog watchdog enable on regular
        AWDEN: u1 = 0,
        /// unused [24:31]
        _unused24: u8 = 0,
    };
    /// control register 1
    pub const CR1 = Register(CR1_val).init(base_address + 0x4);

    /// CR2
    const CR2_val = packed struct {
        /// ADON [0:0]
        /// A/D converter ON / OFF
        ADON: u1 = 0,
        /// CONT [1:1]
        /// Continuous conversion
        CONT: u1 = 0,
        /// CAL [2:2]
        /// A/D calibration
        CAL: u1 = 0,
        /// RSTCAL [3:3]
        /// Reset calibration
        RSTCAL: u1 = 0,
        /// unused [4:7]
        _unused4: u4 = 0,
        /// DMA [8:8]
        /// Direct memory access mode
        DMA: u1 = 0,
        /// unused [9:10]
        _unused9: u2 = 0,
        /// ALIGN [11:11]
        /// Data alignment
        ALIGN: u1 = 0,
        /// JEXTSEL [12:14]
        /// External event select for injected
        JEXTSEL: u3 = 0,
        /// JEXTTRIG [15:15]
        /// External trigger conversion mode for
        JEXTTRIG: u1 = 0,
        /// unused [16:16]
        _unused16: u1 = 0,
        /// EXTSEL [17:19]
        /// External event select for regular
        EXTSEL: u3 = 0,
        /// EXTTRIG [20:20]
        /// External trigger conversion mode for
        EXTTRIG: u1 = 0,
        /// JSWSTART [21:21]
        /// Start conversion of injected
        JSWSTART: u1 = 0,
        /// SWSTART [22:22]
        /// Start conversion of regular
        SWSTART: u1 = 0,
        /// TSVREFE [23:23]
        /// Temperature sensor and VREFINT
        TSVREFE: u1 = 0,
        /// unused [24:31]
        _unused24: u8 = 0,
    };
    /// control register 2
    pub const CR2 = Register(CR2_val).init(base_address + 0x8);

    /// SMPR1
    const SMPR1_val = packed struct {
        /// SMP10 [0:2]
        /// Channel 10 sample time
        SMP10: u3 = 0,
        /// SMP11 [3:5]
        /// Channel 11 sample time
        SMP11: u3 = 0,
        /// SMP12 [6:8]
        /// Channel 12 sample time
        SMP12: u3 = 0,
        /// SMP13 [9:11]
        /// Channel 13 sample time
        SMP13: u3 = 0,
        /// SMP14 [12:14]
        /// Channel 14 sample time
        SMP14: u3 = 0,
        /// SMP15 [15:17]
        /// Channel 15 sample time
        SMP15: u3 = 0,
        /// SMP16 [18:20]
        /// Channel 16 sample time
        SMP16: u3 = 0,
        /// SMP17 [21:23]
        /// Channel 17 sample time
        SMP17: u3 = 0,
        /// unused [24:31]
        _unused24: u8 = 0,
    };
    /// sample time register 1
    pub const SMPR1 = Register(SMPR1_val).init(base_address + 0xc);

    /// SMPR2
    const SMPR2_val = packed struct {
        /// SMP0 [0:2]
        /// Channel 0 sample time
        SMP0: u3 = 0,
        /// SMP1 [3:5]
        /// Channel 1 sample time
        SMP1: u3 = 0,
        /// SMP2 [6:8]
        /// Channel 2 sample time
        SMP2: u3 = 0,
        /// SMP3 [9:11]
        /// Channel 3 sample time
        SMP3: u3 = 0,
        /// SMP4 [12:14]
        /// Channel 4 sample time
        SMP4: u3 = 0,
        /// SMP5 [15:17]
        /// Channel 5 sample time
        SMP5: u3 = 0,
        /// SMP6 [18:20]
        /// Channel 6 sample time
        SMP6: u3 = 0,
        /// SMP7 [21:23]
        /// Channel 7 sample time
        SMP7: u3 = 0,
        /// SMP8 [24:26]
        /// Channel 8 sample time
        SMP8: u3 = 0,
        /// SMP9 [27:29]
        /// Channel 9 sample time
        SMP9: u3 = 0,
        /// unused [30:31]
        _unused30: u2 = 0,
    };
    /// sample time register 2
    pub const SMPR2 = Register(SMPR2_val).init(base_address + 0x10);

    /// JOFR1
    const JOFR1_val = packed struct {
        /// JOFFSET1 [0:11]
        /// Data offset for injected channel
        JOFFSET1: u12 = 0,
        /// unused [12:31]
        _unused12: u4 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// injected channel data offset register
    pub const JOFR1 = Register(JOFR1_val).init(base_address + 0x14);

    /// JOFR2
    const JOFR2_val = packed struct {
        /// JOFFSET2 [0:11]
        /// Data offset for injected channel
        JOFFSET2: u12 = 0,
        /// unused [12:31]
        _unused12: u4 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// injected channel data offset register
    pub const JOFR2 = Register(JOFR2_val).init(base_address + 0x18);

    /// JOFR3
    const JOFR3_val = packed struct {
        /// JOFFSET3 [0:11]
        /// Data offset for injected channel
        JOFFSET3: u12 = 0,
        /// unused [12:31]
        _unused12: u4 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// injected channel data offset register
    pub const JOFR3 = Register(JOFR3_val).init(base_address + 0x1c);

    /// JOFR4
    const JOFR4_val = packed struct {
        /// JOFFSET4 [0:11]
        /// Data offset for injected channel
        JOFFSET4: u12 = 0,
        /// unused [12:31]
        _unused12: u4 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// injected channel data offset register
    pub const JOFR4 = Register(JOFR4_val).init(base_address + 0x20);

    /// HTR
    const HTR_val = packed struct {
        /// HT [0:11]
        /// Analog watchdog higher
        HT: u12 = 4095,
        /// unused [12:31]
        _unused12: u4 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// watchdog higher threshold
    pub const HTR = Register(HTR_val).init(base_address + 0x24);

    /// LTR
    const LTR_val = packed struct {
        /// LT [0:11]
        /// Analog watchdog lower
        LT: u12 = 0,
        /// unused [12:31]
        _unused12: u4 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// watchdog lower threshold
    pub const LTR = Register(LTR_val).init(base_address + 0x28);

    /// SQR1
    const SQR1_val = packed struct {
        /// SQ13 [0:4]
        /// 13th conversion in regular
        SQ13: u5 = 0,
        /// SQ14 [5:9]
        /// 14th conversion in regular
        SQ14: u5 = 0,
        /// SQ15 [10:14]
        /// 15th conversion in regular
        SQ15: u5 = 0,
        /// SQ16 [15:19]
        /// 16th conversion in regular
        SQ16: u5 = 0,
        /// L [20:23]
        /// Regular channel sequence
        L: u4 = 0,
        /// unused [24:31]
        _unused24: u8 = 0,
    };
    /// regular sequence register 1
    pub const SQR1 = Register(SQR1_val).init(base_address + 0x2c);

    /// SQR2
    const SQR2_val = packed struct {
        /// SQ7 [0:4]
        /// 7th conversion in regular
        SQ7: u5 = 0,
        /// SQ8 [5:9]
        /// 8th conversion in regular
        SQ8: u5 = 0,
        /// SQ9 [10:14]
        /// 9th conversion in regular
        SQ9: u5 = 0,
        /// SQ10 [15:19]
        /// 10th conversion in regular
        SQ10: u5 = 0,
        /// SQ11 [20:24]
        /// 11th conversion in regular
        SQ11: u5 = 0,
        /// SQ12 [25:29]
        /// 12th conversion in regular
        SQ12: u5 = 0,
        /// unused [30:31]
        _unused30: u2 = 0,
    };
    /// regular sequence register 2
    pub const SQR2 = Register(SQR2_val).init(base_address + 0x30);

    /// SQR3
    const SQR3_val = packed struct {
        /// SQ1 [0:4]
        /// 1st conversion in regular
        SQ1: u5 = 0,
        /// SQ2 [5:9]
        /// 2nd conversion in regular
        SQ2: u5 = 0,
        /// SQ3 [10:14]
        /// 3rd conversion in regular
        SQ3: u5 = 0,
        /// SQ4 [15:19]
        /// 4th conversion in regular
        SQ4: u5 = 0,
        /// SQ5 [20:24]
        /// 5th conversion in regular
        SQ5: u5 = 0,
        /// SQ6 [25:29]
        /// 6th conversion in regular
        SQ6: u5 = 0,
        /// unused [30:31]
        _unused30: u2 = 0,
    };
    /// regular sequence register 3
    pub const SQR3 = Register(SQR3_val).init(base_address + 0x34);

    /// JSQR
    const JSQR_val = packed struct {
        /// JSQ1 [0:4]
        /// 1st conversion in injected
        JSQ1: u5 = 0,
        /// JSQ2 [5:9]
        /// 2nd conversion in injected
        JSQ2: u5 = 0,
        /// JSQ3 [10:14]
        /// 3rd conversion in injected
        JSQ3: u5 = 0,
        /// JSQ4 [15:19]
        /// 4th conversion in injected
        JSQ4: u5 = 0,
        /// JL [20:21]
        /// Injected sequence length
        JL: u2 = 0,
        /// unused [22:31]
        _unused22: u2 = 0,
        _unused24: u8 = 0,
    };
    /// injected sequence register
    pub const JSQR = Register(JSQR_val).init(base_address + 0x38);

    /// JDR1
    const JDR1_val = packed struct {
        /// JDATA [0:15]
        /// Injected data
        JDATA: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// injected data register x
    pub const JDR1 = Register(JDR1_val).init(base_address + 0x3c);

    /// JDR2
    const JDR2_val = packed struct {
        /// JDATA [0:15]
        /// Injected data
        JDATA: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// injected data register x
    pub const JDR2 = Register(JDR2_val).init(base_address + 0x40);

    /// JDR3
    const JDR3_val = packed struct {
        /// JDATA [0:15]
        /// Injected data
        JDATA: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// injected data register x
    pub const JDR3 = Register(JDR3_val).init(base_address + 0x44);

    /// JDR4
    const JDR4_val = packed struct {
        /// JDATA [0:15]
        /// Injected data
        JDATA: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// injected data register x
    pub const JDR4 = Register(JDR4_val).init(base_address + 0x48);

    /// DR
    const DR_val = packed struct {
        /// DATA [0:15]
        /// Regular data
        DATA: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// regular data register
    pub const DR = Register(DR_val).init(base_address + 0x4c);
};

/// Analog to digital converter
pub const ADC3 = struct {
    const base_address = 0x40013c00;
    /// SR
    const SR_val = packed struct {
        /// AWD [0:0]
        /// Analog watchdog flag
        AWD: u1 = 0,
        /// EOC [1:1]
        /// Regular channel end of
        EOC: u1 = 0,
        /// JEOC [2:2]
        /// Injected channel end of
        JEOC: u1 = 0,
        /// JSTRT [3:3]
        /// Injected channel start
        JSTRT: u1 = 0,
        /// STRT [4:4]
        /// Regular channel start flag
        STRT: u1 = 0,
        /// unused [5:31]
        _unused5: u3 = 0,
        _unused8: u8 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// status register
    pub const SR = Register(SR_val).init(base_address + 0x0);

    /// CR1
    const CR1_val = packed struct {
        /// AWDCH [0:4]
        /// Analog watchdog channel select
        AWDCH: u5 = 0,
        /// EOCIE [5:5]
        /// Interrupt enable for EOC
        EOCIE: u1 = 0,
        /// AWDIE [6:6]
        /// Analog watchdog interrupt
        AWDIE: u1 = 0,
        /// JEOCIE [7:7]
        /// Interrupt enable for injected
        JEOCIE: u1 = 0,
        /// SCAN [8:8]
        /// Scan mode
        SCAN: u1 = 0,
        /// AWDSGL [9:9]
        /// Enable the watchdog on a single channel
        AWDSGL: u1 = 0,
        /// JAUTO [10:10]
        /// Automatic injected group
        JAUTO: u1 = 0,
        /// DISCEN [11:11]
        /// Discontinuous mode on regular
        DISCEN: u1 = 0,
        /// JDISCEN [12:12]
        /// Discontinuous mode on injected
        JDISCEN: u1 = 0,
        /// DISCNUM [13:15]
        /// Discontinuous mode channel
        DISCNUM: u3 = 0,
        /// unused [16:21]
        _unused16: u6 = 0,
        /// JAWDEN [22:22]
        /// Analog watchdog enable on injected
        JAWDEN: u1 = 0,
        /// AWDEN [23:23]
        /// Analog watchdog enable on regular
        AWDEN: u1 = 0,
        /// unused [24:31]
        _unused24: u8 = 0,
    };
    /// control register 1
    pub const CR1 = Register(CR1_val).init(base_address + 0x4);

    /// CR2
    const CR2_val = packed struct {
        /// ADON [0:0]
        /// A/D converter ON / OFF
        ADON: u1 = 0,
        /// CONT [1:1]
        /// Continuous conversion
        CONT: u1 = 0,
        /// CAL [2:2]
        /// A/D calibration
        CAL: u1 = 0,
        /// RSTCAL [3:3]
        /// Reset calibration
        RSTCAL: u1 = 0,
        /// unused [4:7]
        _unused4: u4 = 0,
        /// DMA [8:8]
        /// Direct memory access mode
        DMA: u1 = 0,
        /// unused [9:10]
        _unused9: u2 = 0,
        /// ALIGN [11:11]
        /// Data alignment
        ALIGN: u1 = 0,
        /// JEXTSEL [12:14]
        /// External event select for injected
        JEXTSEL: u3 = 0,
        /// JEXTTRIG [15:15]
        /// External trigger conversion mode for
        JEXTTRIG: u1 = 0,
        /// unused [16:16]
        _unused16: u1 = 0,
        /// EXTSEL [17:19]
        /// External event select for regular
        EXTSEL: u3 = 0,
        /// EXTTRIG [20:20]
        /// External trigger conversion mode for
        EXTTRIG: u1 = 0,
        /// JSWSTART [21:21]
        /// Start conversion of injected
        JSWSTART: u1 = 0,
        /// SWSTART [22:22]
        /// Start conversion of regular
        SWSTART: u1 = 0,
        /// TSVREFE [23:23]
        /// Temperature sensor and VREFINT
        TSVREFE: u1 = 0,
        /// unused [24:31]
        _unused24: u8 = 0,
    };
    /// control register 2
    pub const CR2 = Register(CR2_val).init(base_address + 0x8);

    /// SMPR1
    const SMPR1_val = packed struct {
        /// SMP10 [0:2]
        /// Channel 10 sample time
        SMP10: u3 = 0,
        /// SMP11 [3:5]
        /// Channel 11 sample time
        SMP11: u3 = 0,
        /// SMP12 [6:8]
        /// Channel 12 sample time
        SMP12: u3 = 0,
        /// SMP13 [9:11]
        /// Channel 13 sample time
        SMP13: u3 = 0,
        /// SMP14 [12:14]
        /// Channel 14 sample time
        SMP14: u3 = 0,
        /// SMP15 [15:17]
        /// Channel 15 sample time
        SMP15: u3 = 0,
        /// SMP16 [18:20]
        /// Channel 16 sample time
        SMP16: u3 = 0,
        /// SMP17 [21:23]
        /// Channel 17 sample time
        SMP17: u3 = 0,
        /// unused [24:31]
        _unused24: u8 = 0,
    };
    /// sample time register 1
    pub const SMPR1 = Register(SMPR1_val).init(base_address + 0xc);

    /// SMPR2
    const SMPR2_val = packed struct {
        /// SMP0 [0:2]
        /// Channel 0 sample time
        SMP0: u3 = 0,
        /// SMP1 [3:5]
        /// Channel 1 sample time
        SMP1: u3 = 0,
        /// SMP2 [6:8]
        /// Channel 2 sample time
        SMP2: u3 = 0,
        /// SMP3 [9:11]
        /// Channel 3 sample time
        SMP3: u3 = 0,
        /// SMP4 [12:14]
        /// Channel 4 sample time
        SMP4: u3 = 0,
        /// SMP5 [15:17]
        /// Channel 5 sample time
        SMP5: u3 = 0,
        /// SMP6 [18:20]
        /// Channel 6 sample time
        SMP6: u3 = 0,
        /// SMP7 [21:23]
        /// Channel 7 sample time
        SMP7: u3 = 0,
        /// SMP8 [24:26]
        /// Channel 8 sample time
        SMP8: u3 = 0,
        /// SMP9 [27:29]
        /// Channel 9 sample time
        SMP9: u3 = 0,
        /// unused [30:31]
        _unused30: u2 = 0,
    };
    /// sample time register 2
    pub const SMPR2 = Register(SMPR2_val).init(base_address + 0x10);

    /// JOFR1
    const JOFR1_val = packed struct {
        /// JOFFSET1 [0:11]
        /// Data offset for injected channel
        JOFFSET1: u12 = 0,
        /// unused [12:31]
        _unused12: u4 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// injected channel data offset register
    pub const JOFR1 = Register(JOFR1_val).init(base_address + 0x14);

    /// JOFR2
    const JOFR2_val = packed struct {
        /// JOFFSET2 [0:11]
        /// Data offset for injected channel
        JOFFSET2: u12 = 0,
        /// unused [12:31]
        _unused12: u4 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// injected channel data offset register
    pub const JOFR2 = Register(JOFR2_val).init(base_address + 0x18);

    /// JOFR3
    const JOFR3_val = packed struct {
        /// JOFFSET3 [0:11]
        /// Data offset for injected channel
        JOFFSET3: u12 = 0,
        /// unused [12:31]
        _unused12: u4 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// injected channel data offset register
    pub const JOFR3 = Register(JOFR3_val).init(base_address + 0x1c);

    /// JOFR4
    const JOFR4_val = packed struct {
        /// JOFFSET4 [0:11]
        /// Data offset for injected channel
        JOFFSET4: u12 = 0,
        /// unused [12:31]
        _unused12: u4 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// injected channel data offset register
    pub const JOFR4 = Register(JOFR4_val).init(base_address + 0x20);

    /// HTR
    const HTR_val = packed struct {
        /// HT [0:11]
        /// Analog watchdog higher
        HT: u12 = 4095,
        /// unused [12:31]
        _unused12: u4 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// watchdog higher threshold
    pub const HTR = Register(HTR_val).init(base_address + 0x24);

    /// LTR
    const LTR_val = packed struct {
        /// LT [0:11]
        /// Analog watchdog lower
        LT: u12 = 0,
        /// unused [12:31]
        _unused12: u4 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// watchdog lower threshold
    pub const LTR = Register(LTR_val).init(base_address + 0x28);

    /// SQR1
    const SQR1_val = packed struct {
        /// SQ13 [0:4]
        /// 13th conversion in regular
        SQ13: u5 = 0,
        /// SQ14 [5:9]
        /// 14th conversion in regular
        SQ14: u5 = 0,
        /// SQ15 [10:14]
        /// 15th conversion in regular
        SQ15: u5 = 0,
        /// SQ16 [15:19]
        /// 16th conversion in regular
        SQ16: u5 = 0,
        /// L [20:23]
        /// Regular channel sequence
        L: u4 = 0,
        /// unused [24:31]
        _unused24: u8 = 0,
    };
    /// regular sequence register 1
    pub const SQR1 = Register(SQR1_val).init(base_address + 0x2c);

    /// SQR2
    const SQR2_val = packed struct {
        /// SQ7 [0:4]
        /// 7th conversion in regular
        SQ7: u5 = 0,
        /// SQ8 [5:9]
        /// 8th conversion in regular
        SQ8: u5 = 0,
        /// SQ9 [10:14]
        /// 9th conversion in regular
        SQ9: u5 = 0,
        /// SQ10 [15:19]
        /// 10th conversion in regular
        SQ10: u5 = 0,
        /// SQ11 [20:24]
        /// 11th conversion in regular
        SQ11: u5 = 0,
        /// SQ12 [25:29]
        /// 12th conversion in regular
        SQ12: u5 = 0,
        /// unused [30:31]
        _unused30: u2 = 0,
    };
    /// regular sequence register 2
    pub const SQR2 = Register(SQR2_val).init(base_address + 0x30);

    /// SQR3
    const SQR3_val = packed struct {
        /// SQ1 [0:4]
        /// 1st conversion in regular
        SQ1: u5 = 0,
        /// SQ2 [5:9]
        /// 2nd conversion in regular
        SQ2: u5 = 0,
        /// SQ3 [10:14]
        /// 3rd conversion in regular
        SQ3: u5 = 0,
        /// SQ4 [15:19]
        /// 4th conversion in regular
        SQ4: u5 = 0,
        /// SQ5 [20:24]
        /// 5th conversion in regular
        SQ5: u5 = 0,
        /// SQ6 [25:29]
        /// 6th conversion in regular
        SQ6: u5 = 0,
        /// unused [30:31]
        _unused30: u2 = 0,
    };
    /// regular sequence register 3
    pub const SQR3 = Register(SQR3_val).init(base_address + 0x34);

    /// JSQR
    const JSQR_val = packed struct {
        /// JSQ1 [0:4]
        /// 1st conversion in injected
        JSQ1: u5 = 0,
        /// JSQ2 [5:9]
        /// 2nd conversion in injected
        JSQ2: u5 = 0,
        /// JSQ3 [10:14]
        /// 3rd conversion in injected
        JSQ3: u5 = 0,
        /// JSQ4 [15:19]
        /// 4th conversion in injected
        JSQ4: u5 = 0,
        /// JL [20:21]
        /// Injected sequence length
        JL: u2 = 0,
        /// unused [22:31]
        _unused22: u2 = 0,
        _unused24: u8 = 0,
    };
    /// injected sequence register
    pub const JSQR = Register(JSQR_val).init(base_address + 0x38);

    /// JDR1
    const JDR1_val = packed struct {
        /// JDATA [0:15]
        /// Injected data
        JDATA: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// injected data register x
    pub const JDR1 = Register(JDR1_val).init(base_address + 0x3c);

    /// JDR2
    const JDR2_val = packed struct {
        /// JDATA [0:15]
        /// Injected data
        JDATA: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// injected data register x
    pub const JDR2 = Register(JDR2_val).init(base_address + 0x40);

    /// JDR3
    const JDR3_val = packed struct {
        /// JDATA [0:15]
        /// Injected data
        JDATA: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// injected data register x
    pub const JDR3 = Register(JDR3_val).init(base_address + 0x44);

    /// JDR4
    const JDR4_val = packed struct {
        /// JDATA [0:15]
        /// Injected data
        JDATA: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// injected data register x
    pub const JDR4 = Register(JDR4_val).init(base_address + 0x48);

    /// DR
    const DR_val = packed struct {
        /// DATA [0:15]
        /// Regular data
        DATA: u16 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// regular data register
    pub const DR = Register(DR_val).init(base_address + 0x4c);
};

/// Controller area network
pub const CAN = struct {
    const base_address = 0x40006400;
    /// CAN_MCR
    const CAN_MCR_val = packed struct {
        /// INRQ [0:0]
        /// INRQ
        INRQ: u1 = 0,
        /// SLEEP [1:1]
        /// SLEEP
        SLEEP: u1 = 0,
        /// TXFP [2:2]
        /// TXFP
        TXFP: u1 = 0,
        /// RFLM [3:3]
        /// RFLM
        RFLM: u1 = 0,
        /// NART [4:4]
        /// NART
        NART: u1 = 0,
        /// AWUM [5:5]
        /// AWUM
        AWUM: u1 = 0,
        /// ABOM [6:6]
        /// ABOM
        ABOM: u1 = 0,
        /// TTCM [7:7]
        /// TTCM
        TTCM: u1 = 0,
        /// unused [8:14]
        _unused8: u7 = 0,
        /// RESET [15:15]
        /// RESET
        RESET: u1 = 0,
        /// DBF [16:16]
        /// DBF
        DBF: u1 = 0,
        /// unused [17:31]
        _unused17: u7 = 0,
        _unused24: u8 = 0,
    };
    /// CAN_MCR
    pub const CAN_MCR = Register(CAN_MCR_val).init(base_address + 0x0);

    /// CAN_MSR
    const CAN_MSR_val = packed struct {
        /// INAK [0:0]
        /// INAK
        INAK: u1 = 0,
        /// SLAK [1:1]
        /// SLAK
        SLAK: u1 = 0,
        /// ERRI [2:2]
        /// ERRI
        ERRI: u1 = 0,
        /// WKUI [3:3]
        /// WKUI
        WKUI: u1 = 0,
        /// SLAKI [4:4]
        /// SLAKI
        SLAKI: u1 = 0,
        /// unused [5:7]
        _unused5: u3 = 0,
        /// TXM [8:8]
        /// TXM
        TXM: u1 = 0,
        /// RXM [9:9]
        /// RXM
        RXM: u1 = 0,
        /// SAMP [10:10]
        /// SAMP
        SAMP: u1 = 0,
        /// RX [11:11]
        /// RX
        RX: u1 = 0,
        /// unused [12:31]
        _unused12: u4 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// CAN_MSR
    pub const CAN_MSR = Register(CAN_MSR_val).init(base_address + 0x4);

    /// CAN_TSR
    const CAN_TSR_val = packed struct {
        /// RQCP0 [0:0]
        /// RQCP0
        RQCP0: u1 = 0,
        /// TXOK0 [1:1]
        /// TXOK0
        TXOK0: u1 = 0,
        /// ALST0 [2:2]
        /// ALST0
        ALST0: u1 = 0,
        /// TERR0 [3:3]
        /// TERR0
        TERR0: u1 = 0,
        /// unused [4:6]
        _unused4: u3 = 0,
        /// ABRQ0 [7:7]
        /// ABRQ0
        ABRQ0: u1 = 0,
        /// RQCP1 [8:8]
        /// RQCP1
        RQCP1: u1 = 0,
        /// TXOK1 [9:9]
        /// TXOK1
        TXOK1: u1 = 0,
        /// ALST1 [10:10]
        /// ALST1
        ALST1: u1 = 0,
        /// TERR1 [11:11]
        /// TERR1
        TERR1: u1 = 0,
        /// unused [12:14]
        _unused12: u3 = 0,
        /// ABRQ1 [15:15]
        /// ABRQ1
        ABRQ1: u1 = 0,
        /// RQCP2 [16:16]
        /// RQCP2
        RQCP2: u1 = 0,
        /// TXOK2 [17:17]
        /// TXOK2
        TXOK2: u1 = 0,
        /// ALST2 [18:18]
        /// ALST2
        ALST2: u1 = 0,
        /// TERR2 [19:19]
        /// TERR2
        TERR2: u1 = 0,
        /// unused [20:22]
        _unused20: u3 = 0,
        /// ABRQ2 [23:23]
        /// ABRQ2
        ABRQ2: u1 = 0,
        /// CODE [24:25]
        /// CODE
        CODE: u2 = 0,
        /// TME0 [26:26]
        /// Lowest priority flag for mailbox
        TME0: u1 = 0,
        /// TME1 [27:27]
        /// Lowest priority flag for mailbox
        TME1: u1 = 0,
        /// TME2 [28:28]
        /// Lowest priority flag for mailbox
        TME2: u1 = 0,
        /// LOW0 [29:29]
        /// Lowest priority flag for mailbox
        LOW0: u1 = 0,
        /// LOW1 [30:30]
        /// Lowest priority flag for mailbox
        LOW1: u1 = 0,
        /// LOW2 [31:31]
        /// Lowest priority flag for mailbox
        LOW2: u1 = 0,
    };
    /// CAN_TSR
    pub const CAN_TSR = Register(CAN_TSR_val).init(base_address + 0x8);

    /// CAN_RF0R
    const CAN_RF0R_val = packed struct {
        /// FMP0 [0:1]
        /// FMP0
        FMP0: u2 = 0,
        /// unused [2:2]
        _unused2: u1 = 0,
        /// FULL0 [3:3]
        /// FULL0
        FULL0: u1 = 0,
        /// FOVR0 [4:4]
        /// FOVR0
        FOVR0: u1 = 0,
        /// RFOM0 [5:5]
        /// RFOM0
        RFOM0: u1 = 0,
        /// unused [6:31]
        _unused6: u2 = 0,
        _unused8: u8 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// CAN_RF0R
    pub const CAN_RF0R = Register(CAN_RF0R_val).init(base_address + 0xc);

    /// CAN_RF1R
    const CAN_RF1R_val = packed struct {
        /// FMP1 [0:1]
        /// FMP1
        FMP1: u2 = 0,
        /// unused [2:2]
        _unused2: u1 = 0,
        /// FULL1 [3:3]
        /// FULL1
        FULL1: u1 = 0,
        /// FOVR1 [4:4]
        /// FOVR1
        FOVR1: u1 = 0,
        /// RFOM1 [5:5]
        /// RFOM1
        RFOM1: u1 = 0,
        /// unused [6:31]
        _unused6: u2 = 0,
        _unused8: u8 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// CAN_RF1R
    pub const CAN_RF1R = Register(CAN_RF1R_val).init(base_address + 0x10);

    /// CAN_IER
    const CAN_IER_val = packed struct {
        /// TMEIE [0:0]
        /// TMEIE
        TMEIE: u1 = 0,
        /// FMPIE0 [1:1]
        /// FMPIE0
        FMPIE0: u1 = 0,
        /// FFIE0 [2:2]
        /// FFIE0
        FFIE0: u1 = 0,
        /// FOVIE0 [3:3]
        /// FOVIE0
        FOVIE0: u1 = 0,
        /// FMPIE1 [4:4]
        /// FMPIE1
        FMPIE1: u1 = 0,
        /// FFIE1 [5:5]
        /// FFIE1
        FFIE1: u1 = 0,
        /// FOVIE1 [6:6]
        /// FOVIE1
        FOVIE1: u1 = 0,
        /// unused [7:7]
        _unused7: u1 = 0,
        /// EWGIE [8:8]
        /// EWGIE
        EWGIE: u1 = 0,
        /// EPVIE [9:9]
        /// EPVIE
        EPVIE: u1 = 0,
        /// BOFIE [10:10]
        /// BOFIE
        BOFIE: u1 = 0,
        /// LECIE [11:11]
        /// LECIE
        LECIE: u1 = 0,
        /// unused [12:14]
        _unused12: u3 = 0,
        /// ERRIE [15:15]
        /// ERRIE
        ERRIE: u1 = 0,
        /// WKUIE [16:16]
        /// WKUIE
        WKUIE: u1 = 0,
        /// SLKIE [17:17]
        /// SLKIE
        SLKIE: u1 = 0,
        /// unused [18:31]
        _unused18: u6 = 0,
        _unused24: u8 = 0,
    };
    /// CAN_IER
    pub const CAN_IER = Register(CAN_IER_val).init(base_address + 0x14);

    /// CAN_ESR
    const CAN_ESR_val = packed struct {
        /// EWGF [0:0]
        /// EWGF
        EWGF: u1 = 0,
        /// EPVF [1:1]
        /// EPVF
        EPVF: u1 = 0,
        /// BOFF [2:2]
        /// BOFF
        BOFF: u1 = 0,
        /// unused [3:3]
        _unused3: u1 = 0,
        /// LEC [4:6]
        /// LEC
        LEC: u3 = 0,
        /// unused [7:15]
        _unused7: u1 = 0,
        _unused8: u8 = 0,
        /// TEC [16:23]
        /// TEC
        TEC: u8 = 0,
        /// REC [24:31]
        /// REC
        REC: u8 = 0,
    };
    /// CAN_ESR
    pub const CAN_ESR = Register(CAN_ESR_val).init(base_address + 0x18);

    /// CAN_BTR
    const CAN_BTR_val = packed struct {
        /// BRP [0:9]
        /// BRP
        BRP: u10 = 0,
        /// unused [10:15]
        _unused10: u6 = 0,
        /// TS1 [16:19]
        /// TS1
        TS1: u4 = 0,
        /// TS2 [20:22]
        /// TS2
        TS2: u3 = 0,
        /// unused [23:23]
        _unused23: u1 = 0,
        /// SJW [24:25]
        /// SJW
        SJW: u2 = 0,
        /// unused [26:29]
        _unused26: u4 = 0,
        /// LBKM [30:30]
        /// LBKM
        LBKM: u1 = 0,
        /// SILM [31:31]
        /// SILM
        SILM: u1 = 0,
    };
    /// CAN_BTR
    pub const CAN_BTR = Register(CAN_BTR_val).init(base_address + 0x1c);

    /// CAN_TI0R
    const CAN_TI0R_val = packed struct {
        /// TXRQ [0:0]
        /// TXRQ
        TXRQ: u1 = 0,
        /// RTR [1:1]
        /// RTR
        RTR: u1 = 0,
        /// IDE [2:2]
        /// IDE
        IDE: u1 = 0,
        /// EXID [3:20]
        /// EXID
        EXID: u18 = 0,
        /// STID [21:31]
        /// STID
        STID: u11 = 0,
    };
    /// CAN_TI0R
    pub const CAN_TI0R = Register(CAN_TI0R_val).init(base_address + 0x180);

    /// CAN_TDT0R
    const CAN_TDT0R_val = packed struct {
        /// DLC [0:3]
        /// DLC
        DLC: u4 = 0,
        /// unused [4:7]
        _unused4: u4 = 0,
        /// TGT [8:8]
        /// TGT
        TGT: u1 = 0,
        /// unused [9:15]
        _unused9: u7 = 0,
        /// TIME [16:31]
        /// TIME
        TIME: u16 = 0,
    };
    /// CAN_TDT0R
    pub const CAN_TDT0R = Register(CAN_TDT0R_val).init(base_address + 0x184);

    /// CAN_TDL0R
    const CAN_TDL0R_val = packed struct {
        /// DATA0 [0:7]
        /// DATA0
        DATA0: u8 = 0,
        /// DATA1 [8:15]
        /// DATA1
        DATA1: u8 = 0,
        /// DATA2 [16:23]
        /// DATA2
        DATA2: u8 = 0,
        /// DATA3 [24:31]
        /// DATA3
        DATA3: u8 = 0,
    };
    /// CAN_TDL0R
    pub const CAN_TDL0R = Register(CAN_TDL0R_val).init(base_address + 0x188);

    /// CAN_TDH0R
    const CAN_TDH0R_val = packed struct {
        /// DATA4 [0:7]
        /// DATA4
        DATA4: u8 = 0,
        /// DATA5 [8:15]
        /// DATA5
        DATA5: u8 = 0,
        /// DATA6 [16:23]
        /// DATA6
        DATA6: u8 = 0,
        /// DATA7 [24:31]
        /// DATA7
        DATA7: u8 = 0,
    };
    /// CAN_TDH0R
    pub const CAN_TDH0R = Register(CAN_TDH0R_val).init(base_address + 0x18c);

    /// CAN_TI1R
    const CAN_TI1R_val = packed struct {
        /// TXRQ [0:0]
        /// TXRQ
        TXRQ: u1 = 0,
        /// RTR [1:1]
        /// RTR
        RTR: u1 = 0,
        /// IDE [2:2]
        /// IDE
        IDE: u1 = 0,
        /// EXID [3:20]
        /// EXID
        EXID: u18 = 0,
        /// STID [21:31]
        /// STID
        STID: u11 = 0,
    };
    /// CAN_TI1R
    pub const CAN_TI1R = Register(CAN_TI1R_val).init(base_address + 0x190);

    /// CAN_TDT1R
    const CAN_TDT1R_val = packed struct {
        /// DLC [0:3]
        /// DLC
        DLC: u4 = 0,
        /// unused [4:7]
        _unused4: u4 = 0,
        /// TGT [8:8]
        /// TGT
        TGT: u1 = 0,
        /// unused [9:15]
        _unused9: u7 = 0,
        /// TIME [16:31]
        /// TIME
        TIME: u16 = 0,
    };
    /// CAN_TDT1R
    pub const CAN_TDT1R = Register(CAN_TDT1R_val).init(base_address + 0x194);

    /// CAN_TDL1R
    const CAN_TDL1R_val = packed struct {
        /// DATA0 [0:7]
        /// DATA0
        DATA0: u8 = 0,
        /// DATA1 [8:15]
        /// DATA1
        DATA1: u8 = 0,
        /// DATA2 [16:23]
        /// DATA2
        DATA2: u8 = 0,
        /// DATA3 [24:31]
        /// DATA3
        DATA3: u8 = 0,
    };
    /// CAN_TDL1R
    pub const CAN_TDL1R = Register(CAN_TDL1R_val).init(base_address + 0x198);

    /// CAN_TDH1R
    const CAN_TDH1R_val = packed struct {
        /// DATA4 [0:7]
        /// DATA4
        DATA4: u8 = 0,
        /// DATA5 [8:15]
        /// DATA5
        DATA5: u8 = 0,
        /// DATA6 [16:23]
        /// DATA6
        DATA6: u8 = 0,
        /// DATA7 [24:31]
        /// DATA7
        DATA7: u8 = 0,
    };
    /// CAN_TDH1R
    pub const CAN_TDH1R = Register(CAN_TDH1R_val).init(base_address + 0x19c);

    /// CAN_TI2R
    const CAN_TI2R_val = packed struct {
        /// TXRQ [0:0]
        /// TXRQ
        TXRQ: u1 = 0,
        /// RTR [1:1]
        /// RTR
        RTR: u1 = 0,
        /// IDE [2:2]
        /// IDE
        IDE: u1 = 0,
        /// EXID [3:20]
        /// EXID
        EXID: u18 = 0,
        /// STID [21:31]
        /// STID
        STID: u11 = 0,
    };
    /// CAN_TI2R
    pub const CAN_TI2R = Register(CAN_TI2R_val).init(base_address + 0x1a0);

    /// CAN_TDT2R
    const CAN_TDT2R_val = packed struct {
        /// DLC [0:3]
        /// DLC
        DLC: u4 = 0,
        /// unused [4:7]
        _unused4: u4 = 0,
        /// TGT [8:8]
        /// TGT
        TGT: u1 = 0,
        /// unused [9:15]
        _unused9: u7 = 0,
        /// TIME [16:31]
        /// TIME
        TIME: u16 = 0,
    };
    /// CAN_TDT2R
    pub const CAN_TDT2R = Register(CAN_TDT2R_val).init(base_address + 0x1a4);

    /// CAN_TDL2R
    const CAN_TDL2R_val = packed struct {
        /// DATA0 [0:7]
        /// DATA0
        DATA0: u8 = 0,
        /// DATA1 [8:15]
        /// DATA1
        DATA1: u8 = 0,
        /// DATA2 [16:23]
        /// DATA2
        DATA2: u8 = 0,
        /// DATA3 [24:31]
        /// DATA3
        DATA3: u8 = 0,
    };
    /// CAN_TDL2R
    pub const CAN_TDL2R = Register(CAN_TDL2R_val).init(base_address + 0x1a8);

    /// CAN_TDH2R
    const CAN_TDH2R_val = packed struct {
        /// DATA4 [0:7]
        /// DATA4
        DATA4: u8 = 0,
        /// DATA5 [8:15]
        /// DATA5
        DATA5: u8 = 0,
        /// DATA6 [16:23]
        /// DATA6
        DATA6: u8 = 0,
        /// DATA7 [24:31]
        /// DATA7
        DATA7: u8 = 0,
    };
    /// CAN_TDH2R
    pub const CAN_TDH2R = Register(CAN_TDH2R_val).init(base_address + 0x1ac);

    /// CAN_RI0R
    const CAN_RI0R_val = packed struct {
        /// unused [0:0]
        _unused0: u1 = 0,
        /// RTR [1:1]
        /// RTR
        RTR: u1 = 0,
        /// IDE [2:2]
        /// IDE
        IDE: u1 = 0,
        /// EXID [3:20]
        /// EXID
        EXID: u18 = 0,
        /// STID [21:31]
        /// STID
        STID: u11 = 0,
    };
    /// CAN_RI0R
    pub const CAN_RI0R = Register(CAN_RI0R_val).init(base_address + 0x1b0);

    /// CAN_RDT0R
    const CAN_RDT0R_val = packed struct {
        /// DLC [0:3]
        /// DLC
        DLC: u4 = 0,
        /// unused [4:7]
        _unused4: u4 = 0,
        /// FMI [8:15]
        /// FMI
        FMI: u8 = 0,
        /// TIME [16:31]
        /// TIME
        TIME: u16 = 0,
    };
    /// CAN_RDT0R
    pub const CAN_RDT0R = Register(CAN_RDT0R_val).init(base_address + 0x1b4);

    /// CAN_RDL0R
    const CAN_RDL0R_val = packed struct {
        /// DATA0 [0:7]
        /// DATA0
        DATA0: u8 = 0,
        /// DATA1 [8:15]
        /// DATA1
        DATA1: u8 = 0,
        /// DATA2 [16:23]
        /// DATA2
        DATA2: u8 = 0,
        /// DATA3 [24:31]
        /// DATA3
        DATA3: u8 = 0,
    };
    /// CAN_RDL0R
    pub const CAN_RDL0R = Register(CAN_RDL0R_val).init(base_address + 0x1b8);

    /// CAN_RDH0R
    const CAN_RDH0R_val = packed struct {
        /// DATA4 [0:7]
        /// DATA4
        DATA4: u8 = 0,
        /// DATA5 [8:15]
        /// DATA5
        DATA5: u8 = 0,
        /// DATA6 [16:23]
        /// DATA6
        DATA6: u8 = 0,
        /// DATA7 [24:31]
        /// DATA7
        DATA7: u8 = 0,
    };
    /// CAN_RDH0R
    pub const CAN_RDH0R = Register(CAN_RDH0R_val).init(base_address + 0x1bc);

    /// CAN_RI1R
    const CAN_RI1R_val = packed struct {
        /// unused [0:0]
        _unused0: u1 = 0,
        /// RTR [1:1]
        /// RTR
        RTR: u1 = 0,
        /// IDE [2:2]
        /// IDE
        IDE: u1 = 0,
        /// EXID [3:20]
        /// EXID
        EXID: u18 = 0,
        /// STID [21:31]
        /// STID
        STID: u11 = 0,
    };
    /// CAN_RI1R
    pub const CAN_RI1R = Register(CAN_RI1R_val).init(base_address + 0x1c0);

    /// CAN_RDT1R
    const CAN_RDT1R_val = packed struct {
        /// DLC [0:3]
        /// DLC
        DLC: u4 = 0,
        /// unused [4:7]
        _unused4: u4 = 0,
        /// FMI [8:15]
        /// FMI
        FMI: u8 = 0,
        /// TIME [16:31]
        /// TIME
        TIME: u16 = 0,
    };
    /// CAN_RDT1R
    pub const CAN_RDT1R = Register(CAN_RDT1R_val).init(base_address + 0x1c4);

    /// CAN_RDL1R
    const CAN_RDL1R_val = packed struct {
        /// DATA0 [0:7]
        /// DATA0
        DATA0: u8 = 0,
        /// DATA1 [8:15]
        /// DATA1
        DATA1: u8 = 0,
        /// DATA2 [16:23]
        /// DATA2
        DATA2: u8 = 0,
        /// DATA3 [24:31]
        /// DATA3
        DATA3: u8 = 0,
    };
    /// CAN_RDL1R
    pub const CAN_RDL1R = Register(CAN_RDL1R_val).init(base_address + 0x1c8);

    /// CAN_RDH1R
    const CAN_RDH1R_val = packed struct {
        /// DATA4 [0:7]
        /// DATA4
        DATA4: u8 = 0,
        /// DATA5 [8:15]
        /// DATA5
        DATA5: u8 = 0,
        /// DATA6 [16:23]
        /// DATA6
        DATA6: u8 = 0,
        /// DATA7 [24:31]
        /// DATA7
        DATA7: u8 = 0,
    };
    /// CAN_RDH1R
    pub const CAN_RDH1R = Register(CAN_RDH1R_val).init(base_address + 0x1cc);

    /// CAN_FMR
    const CAN_FMR_val = packed struct {
        /// FINIT [0:0]
        /// FINIT
        FINIT: u1 = 0,
        /// unused [1:31]
        _unused1: u7 = 0,
        _unused8: u8 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// CAN_FMR
    pub const CAN_FMR = Register(CAN_FMR_val).init(base_address + 0x200);

    /// CAN_FM1R
    const CAN_FM1R_val = packed struct {
        /// FBM0 [0:0]
        /// Filter mode
        FBM0: u1 = 0,
        /// FBM1 [1:1]
        /// Filter mode
        FBM1: u1 = 0,
        /// FBM2 [2:2]
        /// Filter mode
        FBM2: u1 = 0,
        /// FBM3 [3:3]
        /// Filter mode
        FBM3: u1 = 0,
        /// FBM4 [4:4]
        /// Filter mode
        FBM4: u1 = 0,
        /// FBM5 [5:5]
        /// Filter mode
        FBM5: u1 = 0,
        /// FBM6 [6:6]
        /// Filter mode
        FBM6: u1 = 0,
        /// FBM7 [7:7]
        /// Filter mode
        FBM7: u1 = 0,
        /// FBM8 [8:8]
        /// Filter mode
        FBM8: u1 = 0,
        /// FBM9 [9:9]
        /// Filter mode
        FBM9: u1 = 0,
        /// FBM10 [10:10]
        /// Filter mode
        FBM10: u1 = 0,
        /// FBM11 [11:11]
        /// Filter mode
        FBM11: u1 = 0,
        /// FBM12 [12:12]
        /// Filter mode
        FBM12: u1 = 0,
        /// FBM13 [13:13]
        /// Filter mode
        FBM13: u1 = 0,
        /// unused [14:31]
        _unused14: u2 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// CAN_FM1R
    pub const CAN_FM1R = Register(CAN_FM1R_val).init(base_address + 0x204);

    /// CAN_FS1R
    const CAN_FS1R_val = packed struct {
        /// FSC0 [0:0]
        /// Filter scale configuration
        FSC0: u1 = 0,
        /// FSC1 [1:1]
        /// Filter scale configuration
        FSC1: u1 = 0,
        /// FSC2 [2:2]
        /// Filter scale configuration
        FSC2: u1 = 0,
        /// FSC3 [3:3]
        /// Filter scale configuration
        FSC3: u1 = 0,
        /// FSC4 [4:4]
        /// Filter scale configuration
        FSC4: u1 = 0,
        /// FSC5 [5:5]
        /// Filter scale configuration
        FSC5: u1 = 0,
        /// FSC6 [6:6]
        /// Filter scale configuration
        FSC6: u1 = 0,
        /// FSC7 [7:7]
        /// Filter scale configuration
        FSC7: u1 = 0,
        /// FSC8 [8:8]
        /// Filter scale configuration
        FSC8: u1 = 0,
        /// FSC9 [9:9]
        /// Filter scale configuration
        FSC9: u1 = 0,
        /// FSC10 [10:10]
        /// Filter scale configuration
        FSC10: u1 = 0,
        /// FSC11 [11:11]
        /// Filter scale configuration
        FSC11: u1 = 0,
        /// FSC12 [12:12]
        /// Filter scale configuration
        FSC12: u1 = 0,
        /// FSC13 [13:13]
        /// Filter scale configuration
        FSC13: u1 = 0,
        /// unused [14:31]
        _unused14: u2 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// CAN_FS1R
    pub const CAN_FS1R = Register(CAN_FS1R_val).init(base_address + 0x20c);

    /// CAN_FFA1R
    const CAN_FFA1R_val = packed struct {
        /// FFA0 [0:0]
        /// Filter FIFO assignment for filter
        FFA0: u1 = 0,
        /// FFA1 [1:1]
        /// Filter FIFO assignment for filter
        FFA1: u1 = 0,
        /// FFA2 [2:2]
        /// Filter FIFO assignment for filter
        FFA2: u1 = 0,
        /// FFA3 [3:3]
        /// Filter FIFO assignment for filter
        FFA3: u1 = 0,
        /// FFA4 [4:4]
        /// Filter FIFO assignment for filter
        FFA4: u1 = 0,
        /// FFA5 [5:5]
        /// Filter FIFO assignment for filter
        FFA5: u1 = 0,
        /// FFA6 [6:6]
        /// Filter FIFO assignment for filter
        FFA6: u1 = 0,
        /// FFA7 [7:7]
        /// Filter FIFO assignment for filter
        FFA7: u1 = 0,
        /// FFA8 [8:8]
        /// Filter FIFO assignment for filter
        FFA8: u1 = 0,
        /// FFA9 [9:9]
        /// Filter FIFO assignment for filter
        FFA9: u1 = 0,
        /// FFA10 [10:10]
        /// Filter FIFO assignment for filter
        FFA10: u1 = 0,
        /// FFA11 [11:11]
        /// Filter FIFO assignment for filter
        FFA11: u1 = 0,
        /// FFA12 [12:12]
        /// Filter FIFO assignment for filter
        FFA12: u1 = 0,
        /// FFA13 [13:13]
        /// Filter FIFO assignment for filter
        FFA13: u1 = 0,
        /// unused [14:31]
        _unused14: u2 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// CAN_FFA1R
    pub const CAN_FFA1R = Register(CAN_FFA1R_val).init(base_address + 0x214);

    /// CAN_FA1R
    const CAN_FA1R_val = packed struct {
        /// FACT0 [0:0]
        /// Filter active
        FACT0: u1 = 0,
        /// FACT1 [1:1]
        /// Filter active
        FACT1: u1 = 0,
        /// FACT2 [2:2]
        /// Filter active
        FACT2: u1 = 0,
        /// FACT3 [3:3]
        /// Filter active
        FACT3: u1 = 0,
        /// FACT4 [4:4]
        /// Filter active
        FACT4: u1 = 0,
        /// FACT5 [5:5]
        /// Filter active
        FACT5: u1 = 0,
        /// FACT6 [6:6]
        /// Filter active
        FACT6: u1 = 0,
        /// FACT7 [7:7]
        /// Filter active
        FACT7: u1 = 0,
        /// FACT8 [8:8]
        /// Filter active
        FACT8: u1 = 0,
        /// FACT9 [9:9]
        /// Filter active
        FACT9: u1 = 0,
        /// FACT10 [10:10]
        /// Filter active
        FACT10: u1 = 0,
        /// FACT11 [11:11]
        /// Filter active
        FACT11: u1 = 0,
        /// FACT12 [12:12]
        /// Filter active
        FACT12: u1 = 0,
        /// FACT13 [13:13]
        /// Filter active
        FACT13: u1 = 0,
        /// unused [14:31]
        _unused14: u2 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// CAN_FA1R
    pub const CAN_FA1R = Register(CAN_FA1R_val).init(base_address + 0x21c);

    /// F0R1
    const F0R1_val = packed struct {
        /// FB0 [0:0]
        /// Filter bits
        FB0: u1 = 0,
        /// FB1 [1:1]
        /// Filter bits
        FB1: u1 = 0,
        /// FB2 [2:2]
        /// Filter bits
        FB2: u1 = 0,
        /// FB3 [3:3]
        /// Filter bits
        FB3: u1 = 0,
        /// FB4 [4:4]
        /// Filter bits
        FB4: u1 = 0,
        /// FB5 [5:5]
        /// Filter bits
        FB5: u1 = 0,
        /// FB6 [6:6]
        /// Filter bits
        FB6: u1 = 0,
        /// FB7 [7:7]
        /// Filter bits
        FB7: u1 = 0,
        /// FB8 [8:8]
        /// Filter bits
        FB8: u1 = 0,
        /// FB9 [9:9]
        /// Filter bits
        FB9: u1 = 0,
        /// FB10 [10:10]
        /// Filter bits
        FB10: u1 = 0,
        /// FB11 [11:11]
        /// Filter bits
        FB11: u1 = 0,
        /// FB12 [12:12]
        /// Filter bits
        FB12: u1 = 0,
        /// FB13 [13:13]
        /// Filter bits
        FB13: u1 = 0,
        /// FB14 [14:14]
        /// Filter bits
        FB14: u1 = 0,
        /// FB15 [15:15]
        /// Filter bits
        FB15: u1 = 0,
        /// FB16 [16:16]
        /// Filter bits
        FB16: u1 = 0,
        /// FB17 [17:17]
        /// Filter bits
        FB17: u1 = 0,
        /// FB18 [18:18]
        /// Filter bits
        FB18: u1 = 0,
        /// FB19 [19:19]
        /// Filter bits
        FB19: u1 = 0,
        /// FB20 [20:20]
        /// Filter bits
        FB20: u1 = 0,
        /// FB21 [21:21]
        /// Filter bits
        FB21: u1 = 0,
        /// FB22 [22:22]
        /// Filter bits
        FB22: u1 = 0,
        /// FB23 [23:23]
        /// Filter bits
        FB23: u1 = 0,
        /// FB24 [24:24]
        /// Filter bits
        FB24: u1 = 0,
        /// FB25 [25:25]
        /// Filter bits
        FB25: u1 = 0,
        /// FB26 [26:26]
        /// Filter bits
        FB26: u1 = 0,
        /// FB27 [27:27]
        /// Filter bits
        FB27: u1 = 0,
        /// FB28 [28:28]
        /// Filter bits
        FB28: u1 = 0,
        /// FB29 [29:29]
        /// Filter bits
        FB29: u1 = 0,
        /// FB30 [30:30]
        /// Filter bits
        FB30: u1 = 0,
        /// FB31 [31:31]
        /// Filter bits
        FB31: u1 = 0,
    };
    /// Filter bank 0 register 1
    pub const F0R1 = Register(F0R1_val).init(base_address + 0x240);

    /// F0R2
    const F0R2_val = packed struct {
        /// FB0 [0:0]
        /// Filter bits
        FB0: u1 = 0,
        /// FB1 [1:1]
        /// Filter bits
        FB1: u1 = 0,
        /// FB2 [2:2]
        /// Filter bits
        FB2: u1 = 0,
        /// FB3 [3:3]
        /// Filter bits
        FB3: u1 = 0,
        /// FB4 [4:4]
        /// Filter bits
        FB4: u1 = 0,
        /// FB5 [5:5]
        /// Filter bits
        FB5: u1 = 0,
        /// FB6 [6:6]
        /// Filter bits
        FB6: u1 = 0,
        /// FB7 [7:7]
        /// Filter bits
        FB7: u1 = 0,
        /// FB8 [8:8]
        /// Filter bits
        FB8: u1 = 0,
        /// FB9 [9:9]
        /// Filter bits
        FB9: u1 = 0,
        /// FB10 [10:10]
        /// Filter bits
        FB10: u1 = 0,
        /// FB11 [11:11]
        /// Filter bits
        FB11: u1 = 0,
        /// FB12 [12:12]
        /// Filter bits
        FB12: u1 = 0,
        /// FB13 [13:13]
        /// Filter bits
        FB13: u1 = 0,
        /// FB14 [14:14]
        /// Filter bits
        FB14: u1 = 0,
        /// FB15 [15:15]
        /// Filter bits
        FB15: u1 = 0,
        /// FB16 [16:16]
        /// Filter bits
        FB16: u1 = 0,
        /// FB17 [17:17]
        /// Filter bits
        FB17: u1 = 0,
        /// FB18 [18:18]
        /// Filter bits
        FB18: u1 = 0,
        /// FB19 [19:19]
        /// Filter bits
        FB19: u1 = 0,
        /// FB20 [20:20]
        /// Filter bits
        FB20: u1 = 0,
        /// FB21 [21:21]
        /// Filter bits
        FB21: u1 = 0,
        /// FB22 [22:22]
        /// Filter bits
        FB22: u1 = 0,
        /// FB23 [23:23]
        /// Filter bits
        FB23: u1 = 0,
        /// FB24 [24:24]
        /// Filter bits
        FB24: u1 = 0,
        /// FB25 [25:25]
        /// Filter bits
        FB25: u1 = 0,
        /// FB26 [26:26]
        /// Filter bits
        FB26: u1 = 0,
        /// FB27 [27:27]
        /// Filter bits
        FB27: u1 = 0,
        /// FB28 [28:28]
        /// Filter bits
        FB28: u1 = 0,
        /// FB29 [29:29]
        /// Filter bits
        FB29: u1 = 0,
        /// FB30 [30:30]
        /// Filter bits
        FB30: u1 = 0,
        /// FB31 [31:31]
        /// Filter bits
        FB31: u1 = 0,
    };
    /// Filter bank 0 register 2
    pub const F0R2 = Register(F0R2_val).init(base_address + 0x244);

    /// F1R1
    const F1R1_val = packed struct {
        /// FB0 [0:0]
        /// Filter bits
        FB0: u1 = 0,
        /// FB1 [1:1]
        /// Filter bits
        FB1: u1 = 0,
        /// FB2 [2:2]
        /// Filter bits
        FB2: u1 = 0,
        /// FB3 [3:3]
        /// Filter bits
        FB3: u1 = 0,
        /// FB4 [4:4]
        /// Filter bits
        FB4: u1 = 0,
        /// FB5 [5:5]
        /// Filter bits
        FB5: u1 = 0,
        /// FB6 [6:6]
        /// Filter bits
        FB6: u1 = 0,
        /// FB7 [7:7]
        /// Filter bits
        FB7: u1 = 0,
        /// FB8 [8:8]
        /// Filter bits
        FB8: u1 = 0,
        /// FB9 [9:9]
        /// Filter bits
        FB9: u1 = 0,
        /// FB10 [10:10]
        /// Filter bits
        FB10: u1 = 0,
        /// FB11 [11:11]
        /// Filter bits
        FB11: u1 = 0,
        /// FB12 [12:12]
        /// Filter bits
        FB12: u1 = 0,
        /// FB13 [13:13]
        /// Filter bits
        FB13: u1 = 0,
        /// FB14 [14:14]
        /// Filter bits
        FB14: u1 = 0,
        /// FB15 [15:15]
        /// Filter bits
        FB15: u1 = 0,
        /// FB16 [16:16]
        /// Filter bits
        FB16: u1 = 0,
        /// FB17 [17:17]
        /// Filter bits
        FB17: u1 = 0,
        /// FB18 [18:18]
        /// Filter bits
        FB18: u1 = 0,
        /// FB19 [19:19]
        /// Filter bits
        FB19: u1 = 0,
        /// FB20 [20:20]
        /// Filter bits
        FB20: u1 = 0,
        /// FB21 [21:21]
        /// Filter bits
        FB21: u1 = 0,
        /// FB22 [22:22]
        /// Filter bits
        FB22: u1 = 0,
        /// FB23 [23:23]
        /// Filter bits
        FB23: u1 = 0,
        /// FB24 [24:24]
        /// Filter bits
        FB24: u1 = 0,
        /// FB25 [25:25]
        /// Filter bits
        FB25: u1 = 0,
        /// FB26 [26:26]
        /// Filter bits
        FB26: u1 = 0,
        /// FB27 [27:27]
        /// Filter bits
        FB27: u1 = 0,
        /// FB28 [28:28]
        /// Filter bits
        FB28: u1 = 0,
        /// FB29 [29:29]
        /// Filter bits
        FB29: u1 = 0,
        /// FB30 [30:30]
        /// Filter bits
        FB30: u1 = 0,
        /// FB31 [31:31]
        /// Filter bits
        FB31: u1 = 0,
    };
    /// Filter bank 1 register 1
    pub const F1R1 = Register(F1R1_val).init(base_address + 0x248);

    /// F1R2
    const F1R2_val = packed struct {
        /// FB0 [0:0]
        /// Filter bits
        FB0: u1 = 0,
        /// FB1 [1:1]
        /// Filter bits
        FB1: u1 = 0,
        /// FB2 [2:2]
        /// Filter bits
        FB2: u1 = 0,
        /// FB3 [3:3]
        /// Filter bits
        FB3: u1 = 0,
        /// FB4 [4:4]
        /// Filter bits
        FB4: u1 = 0,
        /// FB5 [5:5]
        /// Filter bits
        FB5: u1 = 0,
        /// FB6 [6:6]
        /// Filter bits
        FB6: u1 = 0,
        /// FB7 [7:7]
        /// Filter bits
        FB7: u1 = 0,
        /// FB8 [8:8]
        /// Filter bits
        FB8: u1 = 0,
        /// FB9 [9:9]
        /// Filter bits
        FB9: u1 = 0,
        /// FB10 [10:10]
        /// Filter bits
        FB10: u1 = 0,
        /// FB11 [11:11]
        /// Filter bits
        FB11: u1 = 0,
        /// FB12 [12:12]
        /// Filter bits
        FB12: u1 = 0,
        /// FB13 [13:13]
        /// Filter bits
        FB13: u1 = 0,
        /// FB14 [14:14]
        /// Filter bits
        FB14: u1 = 0,
        /// FB15 [15:15]
        /// Filter bits
        FB15: u1 = 0,
        /// FB16 [16:16]
        /// Filter bits
        FB16: u1 = 0,
        /// FB17 [17:17]
        /// Filter bits
        FB17: u1 = 0,
        /// FB18 [18:18]
        /// Filter bits
        FB18: u1 = 0,
        /// FB19 [19:19]
        /// Filter bits
        FB19: u1 = 0,
        /// FB20 [20:20]
        /// Filter bits
        FB20: u1 = 0,
        /// FB21 [21:21]
        /// Filter bits
        FB21: u1 = 0,
        /// FB22 [22:22]
        /// Filter bits
        FB22: u1 = 0,
        /// FB23 [23:23]
        /// Filter bits
        FB23: u1 = 0,
        /// FB24 [24:24]
        /// Filter bits
        FB24: u1 = 0,
        /// FB25 [25:25]
        /// Filter bits
        FB25: u1 = 0,
        /// FB26 [26:26]
        /// Filter bits
        FB26: u1 = 0,
        /// FB27 [27:27]
        /// Filter bits
        FB27: u1 = 0,
        /// FB28 [28:28]
        /// Filter bits
        FB28: u1 = 0,
        /// FB29 [29:29]
        /// Filter bits
        FB29: u1 = 0,
        /// FB30 [30:30]
        /// Filter bits
        FB30: u1 = 0,
        /// FB31 [31:31]
        /// Filter bits
        FB31: u1 = 0,
    };
    /// Filter bank 1 register 2
    pub const F1R2 = Register(F1R2_val).init(base_address + 0x24c);

    /// F2R1
    const F2R1_val = packed struct {
        /// FB0 [0:0]
        /// Filter bits
        FB0: u1 = 0,
        /// FB1 [1:1]
        /// Filter bits
        FB1: u1 = 0,
        /// FB2 [2:2]
        /// Filter bits
        FB2: u1 = 0,
        /// FB3 [3:3]
        /// Filter bits
        FB3: u1 = 0,
        /// FB4 [4:4]
        /// Filter bits
        FB4: u1 = 0,
        /// FB5 [5:5]
        /// Filter bits
        FB5: u1 = 0,
        /// FB6 [6:6]
        /// Filter bits
        FB6: u1 = 0,
        /// FB7 [7:7]
        /// Filter bits
        FB7: u1 = 0,
        /// FB8 [8:8]
        /// Filter bits
        FB8: u1 = 0,
        /// FB9 [9:9]
        /// Filter bits
        FB9: u1 = 0,
        /// FB10 [10:10]
        /// Filter bits
        FB10: u1 = 0,
        /// FB11 [11:11]
        /// Filter bits
        FB11: u1 = 0,
        /// FB12 [12:12]
        /// Filter bits
        FB12: u1 = 0,
        /// FB13 [13:13]
        /// Filter bits
        FB13: u1 = 0,
        /// FB14 [14:14]
        /// Filter bits
        FB14: u1 = 0,
        /// FB15 [15:15]
        /// Filter bits
        FB15: u1 = 0,
        /// FB16 [16:16]
        /// Filter bits
        FB16: u1 = 0,
        /// FB17 [17:17]
        /// Filter bits
        FB17: u1 = 0,
        /// FB18 [18:18]
        /// Filter bits
        FB18: u1 = 0,
        /// FB19 [19:19]
        /// Filter bits
        FB19: u1 = 0,
        /// FB20 [20:20]
        /// Filter bits
        FB20: u1 = 0,
        /// FB21 [21:21]
        /// Filter bits
        FB21: u1 = 0,
        /// FB22 [22:22]
        /// Filter bits
        FB22: u1 = 0,
        /// FB23 [23:23]
        /// Filter bits
        FB23: u1 = 0,
        /// FB24 [24:24]
        /// Filter bits
        FB24: u1 = 0,
        /// FB25 [25:25]
        /// Filter bits
        FB25: u1 = 0,
        /// FB26 [26:26]
        /// Filter bits
        FB26: u1 = 0,
        /// FB27 [27:27]
        /// Filter bits
        FB27: u1 = 0,
        /// FB28 [28:28]
        /// Filter bits
        FB28: u1 = 0,
        /// FB29 [29:29]
        /// Filter bits
        FB29: u1 = 0,
        /// FB30 [30:30]
        /// Filter bits
        FB30: u1 = 0,
        /// FB31 [31:31]
        /// Filter bits
        FB31: u1 = 0,
    };
    /// Filter bank 2 register 1
    pub const F2R1 = Register(F2R1_val).init(base_address + 0x250);

    /// F2R2
    const F2R2_val = packed struct {
        /// FB0 [0:0]
        /// Filter bits
        FB0: u1 = 0,
        /// FB1 [1:1]
        /// Filter bits
        FB1: u1 = 0,
        /// FB2 [2:2]
        /// Filter bits
        FB2: u1 = 0,
        /// FB3 [3:3]
        /// Filter bits
        FB3: u1 = 0,
        /// FB4 [4:4]
        /// Filter bits
        FB4: u1 = 0,
        /// FB5 [5:5]
        /// Filter bits
        FB5: u1 = 0,
        /// FB6 [6:6]
        /// Filter bits
        FB6: u1 = 0,
        /// FB7 [7:7]
        /// Filter bits
        FB7: u1 = 0,
        /// FB8 [8:8]
        /// Filter bits
        FB8: u1 = 0,
        /// FB9 [9:9]
        /// Filter bits
        FB9: u1 = 0,
        /// FB10 [10:10]
        /// Filter bits
        FB10: u1 = 0,
        /// FB11 [11:11]
        /// Filter bits
        FB11: u1 = 0,
        /// FB12 [12:12]
        /// Filter bits
        FB12: u1 = 0,
        /// FB13 [13:13]
        /// Filter bits
        FB13: u1 = 0,
        /// FB14 [14:14]
        /// Filter bits
        FB14: u1 = 0,
        /// FB15 [15:15]
        /// Filter bits
        FB15: u1 = 0,
        /// FB16 [16:16]
        /// Filter bits
        FB16: u1 = 0,
        /// FB17 [17:17]
        /// Filter bits
        FB17: u1 = 0,
        /// FB18 [18:18]
        /// Filter bits
        FB18: u1 = 0,
        /// FB19 [19:19]
        /// Filter bits
        FB19: u1 = 0,
        /// FB20 [20:20]
        /// Filter bits
        FB20: u1 = 0,
        /// FB21 [21:21]
        /// Filter bits
        FB21: u1 = 0,
        /// FB22 [22:22]
        /// Filter bits
        FB22: u1 = 0,
        /// FB23 [23:23]
        /// Filter bits
        FB23: u1 = 0,
        /// FB24 [24:24]
        /// Filter bits
        FB24: u1 = 0,
        /// FB25 [25:25]
        /// Filter bits
        FB25: u1 = 0,
        /// FB26 [26:26]
        /// Filter bits
        FB26: u1 = 0,
        /// FB27 [27:27]
        /// Filter bits
        FB27: u1 = 0,
        /// FB28 [28:28]
        /// Filter bits
        FB28: u1 = 0,
        /// FB29 [29:29]
        /// Filter bits
        FB29: u1 = 0,
        /// FB30 [30:30]
        /// Filter bits
        FB30: u1 = 0,
        /// FB31 [31:31]
        /// Filter bits
        FB31: u1 = 0,
    };
    /// Filter bank 2 register 2
    pub const F2R2 = Register(F2R2_val).init(base_address + 0x254);
};

/// Digital to analog converter
pub const DAC = struct {
    const base_address = 0x40007400;
    /// CR
    const CR_val = packed struct {
        /// EN1 [0:0]
        /// DAC channel1 enable
        EN1: u1 = 0,
        /// BOFF1 [1:1]
        /// DAC channel1 output buffer
        BOFF1: u1 = 0,
        /// TEN1 [2:2]
        /// DAC channel1 trigger
        TEN1: u1 = 0,
        /// TSEL1 [3:5]
        /// DAC channel1 trigger
        TSEL1: u3 = 0,
        /// WAVE1 [6:7]
        /// DAC channel1 noise/triangle wave
        WAVE1: u2 = 0,
        /// MAMP1 [8:11]
        /// DAC channel1 mask/amplitude
        MAMP1: u4 = 0,
        /// DMAEN1 [12:12]
        /// DAC channel1 DMA enable
        DMAEN1: u1 = 0,
        /// unused [13:15]
        _unused13: u3 = 0,
        /// EN2 [16:16]
        /// DAC channel2 enable
        EN2: u1 = 0,
        /// BOFF2 [17:17]
        /// DAC channel2 output buffer
        BOFF2: u1 = 0,
        /// TEN2 [18:18]
        /// DAC channel2 trigger
        TEN2: u1 = 0,
        /// TSEL2 [19:21]
        /// DAC channel2 trigger
        TSEL2: u3 = 0,
        /// WAVE2 [22:23]
        /// DAC channel2 noise/triangle wave
        WAVE2: u2 = 0,
        /// MAMP2 [24:27]
        /// DAC channel2 mask/amplitude
        MAMP2: u4 = 0,
        /// DMAEN2 [28:28]
        /// DAC channel2 DMA enable
        DMAEN2: u1 = 0,
        /// unused [29:31]
        _unused29: u3 = 0,
    };
    /// Control register (DAC_CR)
    pub const CR = Register(CR_val).init(base_address + 0x0);

    /// SWTRIGR
    const SWTRIGR_val = packed struct {
        /// SWTRIG1 [0:0]
        /// DAC channel1 software
        SWTRIG1: u1 = 0,
        /// SWTRIG2 [1:1]
        /// DAC channel2 software
        SWTRIG2: u1 = 0,
        /// unused [2:31]
        _unused2: u6 = 0,
        _unused8: u8 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// DAC software trigger register
    pub const SWTRIGR = Register(SWTRIGR_val).init(base_address + 0x4);

    /// DHR12R1
    const DHR12R1_val = packed struct {
        /// DACC1DHR [0:11]
        /// DAC channel1 12-bit right-aligned
        DACC1DHR: u12 = 0,
        /// unused [12:31]
        _unused12: u4 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// DAC channel1 12-bit right-aligned data
    pub const DHR12R1 = Register(DHR12R1_val).init(base_address + 0x8);

    /// DHR12L1
    const DHR12L1_val = packed struct {
        /// unused [0:3]
        _unused0: u4 = 0,
        /// DACC1DHR [4:15]
        /// DAC channel1 12-bit left-aligned
        DACC1DHR: u12 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// DAC channel1 12-bit left aligned data
    pub const DHR12L1 = Register(DHR12L1_val).init(base_address + 0xc);

    /// DHR8R1
    const DHR8R1_val = packed struct {
        /// DACC1DHR [0:7]
        /// DAC channel1 8-bit right-aligned
        DACC1DHR: u8 = 0,
        /// unused [8:31]
        _unused8: u8 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// DAC channel1 8-bit right aligned data
    pub const DHR8R1 = Register(DHR8R1_val).init(base_address + 0x10);

    /// DHR12R2
    const DHR12R2_val = packed struct {
        /// DACC2DHR [0:11]
        /// DAC channel2 12-bit right-aligned
        DACC2DHR: u12 = 0,
        /// unused [12:31]
        _unused12: u4 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// DAC channel2 12-bit right aligned data
    pub const DHR12R2 = Register(DHR12R2_val).init(base_address + 0x14);

    /// DHR12L2
    const DHR12L2_val = packed struct {
        /// unused [0:3]
        _unused0: u4 = 0,
        /// DACC2DHR [4:15]
        /// DAC channel2 12-bit left-aligned
        DACC2DHR: u12 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// DAC channel2 12-bit left aligned data
    pub const DHR12L2 = Register(DHR12L2_val).init(base_address + 0x18);

    /// DHR8R2
    const DHR8R2_val = packed struct {
        /// DACC2DHR [0:7]
        /// DAC channel2 8-bit right-aligned
        DACC2DHR: u8 = 0,
        /// unused [8:31]
        _unused8: u8 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// DAC channel2 8-bit right-aligned data
    pub const DHR8R2 = Register(DHR8R2_val).init(base_address + 0x1c);

    /// DHR12RD
    const DHR12RD_val = packed struct {
        /// DACC1DHR [0:11]
        /// DAC channel1 12-bit right-aligned
        DACC1DHR: u12 = 0,
        /// unused [12:15]
        _unused12: u4 = 0,
        /// DACC2DHR [16:27]
        /// DAC channel2 12-bit right-aligned
        DACC2DHR: u12 = 0,
        /// unused [28:31]
        _unused28: u4 = 0,
    };
    /// Dual DAC 12-bit right-aligned data holding
    pub const DHR12RD = Register(DHR12RD_val).init(base_address + 0x20);

    /// DHR12LD
    const DHR12LD_val = packed struct {
        /// unused [0:3]
        _unused0: u4 = 0,
        /// DACC1DHR [4:15]
        /// DAC channel1 12-bit left-aligned
        DACC1DHR: u12 = 0,
        /// unused [16:19]
        _unused16: u4 = 0,
        /// DACC2DHR [20:31]
        /// DAC channel2 12-bit right-aligned
        DACC2DHR: u12 = 0,
    };
    /// DUAL DAC 12-bit left aligned data holding
    pub const DHR12LD = Register(DHR12LD_val).init(base_address + 0x24);

    /// DHR8RD
    const DHR8RD_val = packed struct {
        /// DACC1DHR [0:7]
        /// DAC channel1 8-bit right-aligned
        DACC1DHR: u8 = 0,
        /// DACC2DHR [8:15]
        /// DAC channel2 8-bit right-aligned
        DACC2DHR: u8 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// DUAL DAC 8-bit right aligned data holding
    pub const DHR8RD = Register(DHR8RD_val).init(base_address + 0x28);

    /// DOR1
    const DOR1_val = packed struct {
        /// DACC1DOR [0:11]
        /// DAC channel1 data output
        DACC1DOR: u12 = 0,
        /// unused [12:31]
        _unused12: u4 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// DAC channel1 data output register
    pub const DOR1 = Register(DOR1_val).init(base_address + 0x2c);

    /// DOR2
    const DOR2_val = packed struct {
        /// DACC2DOR [0:11]
        /// DAC channel2 data output
        DACC2DOR: u12 = 0,
        /// unused [12:31]
        _unused12: u4 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// DAC channel2 data output register
    pub const DOR2 = Register(DOR2_val).init(base_address + 0x30);
};

/// Debug support
pub const DBG = struct {
    const base_address = 0xe0042000;
    /// IDCODE
    const IDCODE_val = packed struct {
        /// DEV_ID [0:11]
        /// DEV_ID
        DEV_ID: u12 = 0,
        /// unused [12:15]
        _unused12: u4 = 0,
        /// REV_ID [16:31]
        /// REV_ID
        REV_ID: u16 = 0,
    };
    /// DBGMCU_IDCODE
    pub const IDCODE = Register(IDCODE_val).init(base_address + 0x0);

    /// CR
    const CR_val = packed struct {
        /// DBG_SLEEP [0:0]
        /// DBG_SLEEP
        DBG_SLEEP: u1 = 0,
        /// DBG_STOP [1:1]
        /// DBG_STOP
        DBG_STOP: u1 = 0,
        /// DBG_STANDBY [2:2]
        /// DBG_STANDBY
        DBG_STANDBY: u1 = 0,
        /// unused [3:4]
        _unused3: u2 = 0,
        /// TRACE_IOEN [5:5]
        /// TRACE_IOEN
        TRACE_IOEN: u1 = 0,
        /// TRACE_MODE [6:7]
        /// TRACE_MODE
        TRACE_MODE: u2 = 0,
        /// DBG_IWDG_STOP [8:8]
        /// DBG_IWDG_STOP
        DBG_IWDG_STOP: u1 = 0,
        /// DBG_WWDG_STOP [9:9]
        /// DBG_WWDG_STOP
        DBG_WWDG_STOP: u1 = 0,
        /// DBG_TIM1_STOP [10:10]
        /// DBG_TIM1_STOP
        DBG_TIM1_STOP: u1 = 0,
        /// DBG_TIM2_STOP [11:11]
        /// DBG_TIM2_STOP
        DBG_TIM2_STOP: u1 = 0,
        /// DBG_TIM3_STOP [12:12]
        /// DBG_TIM3_STOP
        DBG_TIM3_STOP: u1 = 0,
        /// DBG_TIM4_STOP [13:13]
        /// DBG_TIM4_STOP
        DBG_TIM4_STOP: u1 = 0,
        /// DBG_CAN1_STOP [14:14]
        /// DBG_CAN1_STOP
        DBG_CAN1_STOP: u1 = 0,
        /// DBG_I2C1_SMBUS_TIMEOUT [15:15]
        /// DBG_I2C1_SMBUS_TIMEOUT
        DBG_I2C1_SMBUS_TIMEOUT: u1 = 0,
        /// DBG_I2C2_SMBUS_TIMEOUT [16:16]
        /// DBG_I2C2_SMBUS_TIMEOUT
        DBG_I2C2_SMBUS_TIMEOUT: u1 = 0,
        /// DBG_TIM8_STOP [17:17]
        /// DBG_TIM8_STOP
        DBG_TIM8_STOP: u1 = 0,
        /// DBG_TIM5_STOP [18:18]
        /// DBG_TIM5_STOP
        DBG_TIM5_STOP: u1 = 0,
        /// DBG_TIM6_STOP [19:19]
        /// DBG_TIM6_STOP
        DBG_TIM6_STOP: u1 = 0,
        /// DBG_TIM7_STOP [20:20]
        /// DBG_TIM7_STOP
        DBG_TIM7_STOP: u1 = 0,
        /// DBG_CAN2_STOP [21:21]
        /// DBG_CAN2_STOP
        DBG_CAN2_STOP: u1 = 0,
        /// unused [22:31]
        _unused22: u2 = 0,
        _unused24: u8 = 0,
    };
    /// DBGMCU_CR
    pub const CR = Register(CR_val).init(base_address + 0x4);
};

/// Universal asynchronous receiver
pub const UART4 = struct {
    const base_address = 0x40004c00;
    /// SR
    const SR_val = packed struct {
        /// PE [0:0]
        /// Parity error
        PE: u1 = 0,
        /// FE [1:1]
        /// Framing error
        FE: u1 = 0,
        /// NE [2:2]
        /// Noise error flag
        NE: u1 = 0,
        /// ORE [3:3]
        /// Overrun error
        ORE: u1 = 0,
        /// IDLE [4:4]
        /// IDLE line detected
        IDLE: u1 = 0,
        /// RXNE [5:5]
        /// Read data register not
        RXNE: u1 = 0,
        /// TC [6:6]
        /// Transmission complete
        TC: u1 = 0,
        /// TXE [7:7]
        /// Transmit data register
        TXE: u1 = 0,
        /// LBD [8:8]
        /// LIN break detection flag
        LBD: u1 = 0,
        /// unused [9:31]
        _unused9: u7 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// UART4_SR
    pub const SR = Register(SR_val).init(base_address + 0x0);

    /// DR
    const DR_val = packed struct {
        /// DR [0:8]
        /// DR
        DR: u9 = 0,
        /// unused [9:31]
        _unused9: u7 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// UART4_DR
    pub const DR = Register(DR_val).init(base_address + 0x4);

    /// BRR
    const BRR_val = packed struct {
        /// DIV_Fraction [0:3]
        /// DIV_Fraction
        DIV_Fraction: u4 = 0,
        /// DIV_Mantissa [4:15]
        /// DIV_Mantissa
        DIV_Mantissa: u12 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// UART4_BRR
    pub const BRR = Register(BRR_val).init(base_address + 0x8);

    /// CR1
    const CR1_val = packed struct {
        /// SBK [0:0]
        /// Send break
        SBK: u1 = 0,
        /// RWU [1:1]
        /// Receiver wakeup
        RWU: u1 = 0,
        /// RE [2:2]
        /// Receiver enable
        RE: u1 = 0,
        /// TE [3:3]
        /// Transmitter enable
        TE: u1 = 0,
        /// IDLEIE [4:4]
        /// IDLE interrupt enable
        IDLEIE: u1 = 0,
        /// RXNEIE [5:5]
        /// RXNE interrupt enable
        RXNEIE: u1 = 0,
        /// TCIE [6:6]
        /// Transmission complete interrupt
        TCIE: u1 = 0,
        /// TXEIE [7:7]
        /// TXE interrupt enable
        TXEIE: u1 = 0,
        /// PEIE [8:8]
        /// PE interrupt enable
        PEIE: u1 = 0,
        /// PS [9:9]
        /// Parity selection
        PS: u1 = 0,
        /// PCE [10:10]
        /// Parity control enable
        PCE: u1 = 0,
        /// WAKE [11:11]
        /// Wakeup method
        WAKE: u1 = 0,
        /// M [12:12]
        /// Word length
        M: u1 = 0,
        /// UE [13:13]
        /// USART enable
        UE: u1 = 0,
        /// unused [14:31]
        _unused14: u2 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// UART4_CR1
    pub const CR1 = Register(CR1_val).init(base_address + 0xc);

    /// CR2
    const CR2_val = packed struct {
        /// ADD [0:3]
        /// Address of the USART node
        ADD: u4 = 0,
        /// unused [4:4]
        _unused4: u1 = 0,
        /// LBDL [5:5]
        /// lin break detection length
        LBDL: u1 = 0,
        /// LBDIE [6:6]
        /// LIN break detection interrupt
        LBDIE: u1 = 0,
        /// unused [7:11]
        _unused7: u1 = 0,
        _unused8: u4 = 0,
        /// STOP [12:13]
        /// STOP bits
        STOP: u2 = 0,
        /// LINEN [14:14]
        /// LIN mode enable
        LINEN: u1 = 0,
        /// unused [15:31]
        _unused15: u1 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// UART4_CR2
    pub const CR2 = Register(CR2_val).init(base_address + 0x10);

    /// CR3
    const CR3_val = packed struct {
        /// EIE [0:0]
        /// Error interrupt enable
        EIE: u1 = 0,
        /// IREN [1:1]
        /// IrDA mode enable
        IREN: u1 = 0,
        /// IRLP [2:2]
        /// IrDA low-power
        IRLP: u1 = 0,
        /// HDSEL [3:3]
        /// Half-duplex selection
        HDSEL: u1 = 0,
        /// unused [4:5]
        _unused4: u2 = 0,
        /// DMAR [6:6]
        /// DMA enable receiver
        DMAR: u1 = 0,
        /// DMAT [7:7]
        /// DMA enable transmitter
        DMAT: u1 = 0,
        /// unused [8:31]
        _unused8: u8 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// UART4_CR3
    pub const CR3 = Register(CR3_val).init(base_address + 0x14);
};

/// Universal asynchronous receiver
pub const UART5 = struct {
    const base_address = 0x40005000;
    /// SR
    const SR_val = packed struct {
        /// PE [0:0]
        /// PE
        PE: u1 = 0,
        /// FE [1:1]
        /// FE
        FE: u1 = 0,
        /// NE [2:2]
        /// NE
        NE: u1 = 0,
        /// ORE [3:3]
        /// ORE
        ORE: u1 = 0,
        /// IDLE [4:4]
        /// IDLE
        IDLE: u1 = 0,
        /// RXNE [5:5]
        /// RXNE
        RXNE: u1 = 0,
        /// TC [6:6]
        /// TC
        TC: u1 = 0,
        /// TXE [7:7]
        /// TXE
        TXE: u1 = 0,
        /// LBD [8:8]
        /// LBD
        LBD: u1 = 0,
        /// unused [9:31]
        _unused9: u7 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// UART4_SR
    pub const SR = Register(SR_val).init(base_address + 0x0);

    /// DR
    const DR_val = packed struct {
        /// DR [0:8]
        /// DR
        DR: u9 = 0,
        /// unused [9:31]
        _unused9: u7 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// UART4_DR
    pub const DR = Register(DR_val).init(base_address + 0x4);

    /// BRR
    const BRR_val = packed struct {
        /// DIV_Fraction [0:3]
        /// DIV_Fraction
        DIV_Fraction: u4 = 0,
        /// DIV_Mantissa [4:15]
        /// DIV_Mantissa
        DIV_Mantissa: u12 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// UART4_BRR
    pub const BRR = Register(BRR_val).init(base_address + 0x8);

    /// CR1
    const CR1_val = packed struct {
        /// SBK [0:0]
        /// SBK
        SBK: u1 = 0,
        /// RWU [1:1]
        /// RWU
        RWU: u1 = 0,
        /// RE [2:2]
        /// RE
        RE: u1 = 0,
        /// TE [3:3]
        /// TE
        TE: u1 = 0,
        /// IDLEIE [4:4]
        /// IDLEIE
        IDLEIE: u1 = 0,
        /// RXNEIE [5:5]
        /// RXNEIE
        RXNEIE: u1 = 0,
        /// TCIE [6:6]
        /// TCIE
        TCIE: u1 = 0,
        /// TXEIE [7:7]
        /// TXEIE
        TXEIE: u1 = 0,
        /// PEIE [8:8]
        /// PEIE
        PEIE: u1 = 0,
        /// PS [9:9]
        /// PS
        PS: u1 = 0,
        /// PCE [10:10]
        /// PCE
        PCE: u1 = 0,
        /// WAKE [11:11]
        /// WAKE
        WAKE: u1 = 0,
        /// M [12:12]
        /// M
        M: u1 = 0,
        /// UE [13:13]
        /// UE
        UE: u1 = 0,
        /// unused [14:31]
        _unused14: u2 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// UART4_CR1
    pub const CR1 = Register(CR1_val).init(base_address + 0xc);

    /// CR2
    const CR2_val = packed struct {
        /// ADD [0:3]
        /// ADD
        ADD: u4 = 0,
        /// unused [4:4]
        _unused4: u1 = 0,
        /// LBDL [5:5]
        /// LBDL
        LBDL: u1 = 0,
        /// LBDIE [6:6]
        /// LBDIE
        LBDIE: u1 = 0,
        /// unused [7:11]
        _unused7: u1 = 0,
        _unused8: u4 = 0,
        /// STOP [12:13]
        /// STOP
        STOP: u2 = 0,
        /// LINEN [14:14]
        /// LINEN
        LINEN: u1 = 0,
        /// unused [15:31]
        _unused15: u1 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// UART4_CR2
    pub const CR2 = Register(CR2_val).init(base_address + 0x10);

    /// CR3
    const CR3_val = packed struct {
        /// EIE [0:0]
        /// Error interrupt enable
        EIE: u1 = 0,
        /// IREN [1:1]
        /// IrDA mode enable
        IREN: u1 = 0,
        /// IRLP [2:2]
        /// IrDA low-power
        IRLP: u1 = 0,
        /// HDSEL [3:3]
        /// Half-duplex selection
        HDSEL: u1 = 0,
        /// unused [4:6]
        _unused4: u3 = 0,
        /// DMAT [7:7]
        /// DMA enable transmitter
        DMAT: u1 = 0,
        /// unused [8:31]
        _unused8: u8 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// UART4_CR3
    pub const CR3 = Register(CR3_val).init(base_address + 0x14);
};

/// CRC calculation unit
pub const CRC = struct {
    const base_address = 0x40023000;
    /// DR
    const DR_val = packed struct {
        /// DR [0:31]
        /// Data Register
        DR: u32 = 4294967295,
    };
    /// Data register
    pub const DR = Register(DR_val).init(base_address + 0x0);

    /// IDR
    const IDR_val = packed struct {
        /// IDR [0:7]
        /// Independent Data register
        IDR: u8 = 0,
        /// unused [8:31]
        _unused8: u8 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Independent Data register
    pub const IDR = Register(IDR_val).init(base_address + 0x4);

    /// CR
    const CR_val = packed struct {
        /// RESET [0:0]
        /// Reset bit
        RESET: u1 = 0,
        /// unused [1:31]
        _unused1: u7 = 0,
        _unused8: u8 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Control register
    pub const CR = Register(CR_val).init(base_address + 0x8);
};

/// FLASH
pub const FLASH = struct {
    const base_address = 0x40022000;
    /// ACR
    const ACR_val = packed struct {
        /// LATENCY [0:2]
        /// Latency
        LATENCY: u3 = 0,
        /// HLFCYA [3:3]
        /// Flash half cycle access
        HLFCYA: u1 = 0,
        /// PRFTBE [4:4]
        /// Prefetch buffer enable
        PRFTBE: u1 = 1,
        /// PRFTBS [5:5]
        /// Prefetch buffer status
        PRFTBS: u1 = 1,
        /// unused [6:31]
        _unused6: u2 = 0,
        _unused8: u8 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Flash access control register
    pub const ACR = Register(ACR_val).init(base_address + 0x0);

    /// KEYR
    const KEYR_val = packed struct {
        /// KEY [0:31]
        /// FPEC key
        KEY: u32 = 0,
    };
    /// Flash key register
    pub const KEYR = Register(KEYR_val).init(base_address + 0x4);

    /// OPTKEYR
    const OPTKEYR_val = packed struct {
        /// OPTKEY [0:31]
        /// Option byte key
        OPTKEY: u32 = 0,
    };
    /// Flash option key register
    pub const OPTKEYR = Register(OPTKEYR_val).init(base_address + 0x8);

    /// SR
    const SR_val = packed struct {
        /// BSY [0:0]
        /// Busy
        BSY: u1 = 0,
        /// unused [1:1]
        _unused1: u1 = 0,
        /// PGERR [2:2]
        /// Programming error
        PGERR: u1 = 0,
        /// unused [3:3]
        _unused3: u1 = 0,
        /// WRPRTERR [4:4]
        /// Write protection error
        WRPRTERR: u1 = 0,
        /// EOP [5:5]
        /// End of operation
        EOP: u1 = 0,
        /// unused [6:31]
        _unused6: u2 = 0,
        _unused8: u8 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Status register
    pub const SR = Register(SR_val).init(base_address + 0xc);

    /// CR
    const CR_val = packed struct {
        /// PG [0:0]
        /// Programming
        PG: u1 = 0,
        /// PER [1:1]
        /// Page Erase
        PER: u1 = 0,
        /// MER [2:2]
        /// Mass Erase
        MER: u1 = 0,
        /// unused [3:3]
        _unused3: u1 = 0,
        /// OPTPG [4:4]
        /// Option byte programming
        OPTPG: u1 = 0,
        /// OPTER [5:5]
        /// Option byte erase
        OPTER: u1 = 0,
        /// STRT [6:6]
        /// Start
        STRT: u1 = 0,
        /// LOCK [7:7]
        /// Lock
        LOCK: u1 = 1,
        /// unused [8:8]
        _unused8: u1 = 0,
        /// OPTWRE [9:9]
        /// Option bytes write enable
        OPTWRE: u1 = 0,
        /// ERRIE [10:10]
        /// Error interrupt enable
        ERRIE: u1 = 0,
        /// unused [11:11]
        _unused11: u1 = 0,
        /// EOPIE [12:12]
        /// End of operation interrupt
        EOPIE: u1 = 0,
        /// unused [13:31]
        _unused13: u3 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Control register
    pub const CR = Register(CR_val).init(base_address + 0x10);

    /// AR
    const AR_val = packed struct {
        /// FAR [0:31]
        /// Flash Address
        FAR: u32 = 0,
    };
    /// Flash address register
    pub const AR = Register(AR_val).init(base_address + 0x14);

    /// OBR
    const OBR_val = packed struct {
        /// OPTERR [0:0]
        /// Option byte error
        OPTERR: u1 = 0,
        /// RDPRT [1:1]
        /// Read protection
        RDPRT: u1 = 0,
        /// WDG_SW [2:2]
        /// WDG_SW
        WDG_SW: u1 = 1,
        /// nRST_STOP [3:3]
        /// nRST_STOP
        nRST_STOP: u1 = 1,
        /// nRST_STDBY [4:4]
        /// nRST_STDBY
        nRST_STDBY: u1 = 1,
        /// unused [5:9]
        _unused5: u3 = 7,
        _unused8: u2 = 3,
        /// Data0 [10:17]
        /// Data0
        Data0: u8 = 255,
        /// Data1 [18:25]
        /// Data1
        Data1: u8 = 255,
        /// unused [26:31]
        _unused26: u6 = 0,
    };
    /// Option byte register
    pub const OBR = Register(OBR_val).init(base_address + 0x1c);

    /// WRPR
    const WRPR_val = packed struct {
        /// WRP [0:31]
        /// Write protect
        WRP: u32 = 4294967295,
    };
    /// Write protection register
    pub const WRPR = Register(WRPR_val).init(base_address + 0x20);
};

/// Nested Vectored Interrupt
pub const NVIC = struct {
    const base_address = 0xe000e000;
    /// ICTR
    const ICTR_val = packed struct {
        /// INTLINESNUM [0:3]
        /// Total number of interrupt lines in
        INTLINESNUM: u4 = 0,
        /// unused [4:31]
        _unused4: u4 = 0,
        _unused8: u8 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Interrupt Controller Type
    pub const ICTR = Register(ICTR_val).init(base_address + 0x4);

    /// STIR
    const STIR_val = packed struct {
        /// INTID [0:8]
        /// interrupt to be triggered
        INTID: u9 = 0,
        /// unused [9:31]
        _unused9: u7 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Software Triggered Interrupt
    pub const STIR = Register(STIR_val).init(base_address + 0xf00);

    /// ISER0
    const ISER0_val = packed struct {
        /// SETENA [0:31]
        /// SETENA
        SETENA: u32 = 0,
    };
    /// Interrupt Set-Enable Register
    pub const ISER0 = Register(ISER0_val).init(base_address + 0x100);

    /// ISER1
    const ISER1_val = packed struct {
        /// SETENA [0:31]
        /// SETENA
        SETENA: u32 = 0,
    };
    /// Interrupt Set-Enable Register
    pub const ISER1 = Register(ISER1_val).init(base_address + 0x104);

    /// ICER0
    const ICER0_val = packed struct {
        /// CLRENA [0:31]
        /// CLRENA
        CLRENA: u32 = 0,
    };
    /// Interrupt Clear-Enable
    pub const ICER0 = Register(ICER0_val).init(base_address + 0x180);

    /// ICER1
    const ICER1_val = packed struct {
        /// CLRENA [0:31]
        /// CLRENA
        CLRENA: u32 = 0,
    };
    /// Interrupt Clear-Enable
    pub const ICER1 = Register(ICER1_val).init(base_address + 0x184);

    /// ISPR0
    const ISPR0_val = packed struct {
        /// SETPEND [0:31]
        /// SETPEND
        SETPEND: u32 = 0,
    };
    /// Interrupt Set-Pending Register
    pub const ISPR0 = Register(ISPR0_val).init(base_address + 0x200);

    /// ISPR1
    const ISPR1_val = packed struct {
        /// SETPEND [0:31]
        /// SETPEND
        SETPEND: u32 = 0,
    };
    /// Interrupt Set-Pending Register
    pub const ISPR1 = Register(ISPR1_val).init(base_address + 0x204);

    /// ICPR0
    const ICPR0_val = packed struct {
        /// CLRPEND [0:31]
        /// CLRPEND
        CLRPEND: u32 = 0,
    };
    /// Interrupt Clear-Pending
    pub const ICPR0 = Register(ICPR0_val).init(base_address + 0x280);

    /// ICPR1
    const ICPR1_val = packed struct {
        /// CLRPEND [0:31]
        /// CLRPEND
        CLRPEND: u32 = 0,
    };
    /// Interrupt Clear-Pending
    pub const ICPR1 = Register(ICPR1_val).init(base_address + 0x284);

    /// IABR0
    const IABR0_val = packed struct {
        /// ACTIVE [0:31]
        /// ACTIVE
        ACTIVE: u32 = 0,
    };
    /// Interrupt Active Bit Register
    pub const IABR0 = Register(IABR0_val).init(base_address + 0x300);

    /// IABR1
    const IABR1_val = packed struct {
        /// ACTIVE [0:31]
        /// ACTIVE
        ACTIVE: u32 = 0,
    };
    /// Interrupt Active Bit Register
    pub const IABR1 = Register(IABR1_val).init(base_address + 0x304);

    /// IPR0
    const IPR0_val = packed struct {
        /// IPR_N0 [0:7]
        /// IPR_N0
        IPR_N0: u8 = 0,
        /// IPR_N1 [8:15]
        /// IPR_N1
        IPR_N1: u8 = 0,
        /// IPR_N2 [16:23]
        /// IPR_N2
        IPR_N2: u8 = 0,
        /// IPR_N3 [24:31]
        /// IPR_N3
        IPR_N3: u8 = 0,
    };
    /// Interrupt Priority Register
    pub const IPR0 = Register(IPR0_val).init(base_address + 0x400);

    /// IPR1
    const IPR1_val = packed struct {
        /// IPR_N0 [0:7]
        /// IPR_N0
        IPR_N0: u8 = 0,
        /// IPR_N1 [8:15]
        /// IPR_N1
        IPR_N1: u8 = 0,
        /// IPR_N2 [16:23]
        /// IPR_N2
        IPR_N2: u8 = 0,
        /// IPR_N3 [24:31]
        /// IPR_N3
        IPR_N3: u8 = 0,
    };
    /// Interrupt Priority Register
    pub const IPR1 = Register(IPR1_val).init(base_address + 0x404);

    /// IPR2
    const IPR2_val = packed struct {
        /// IPR_N0 [0:7]
        /// IPR_N0
        IPR_N0: u8 = 0,
        /// IPR_N1 [8:15]
        /// IPR_N1
        IPR_N1: u8 = 0,
        /// IPR_N2 [16:23]
        /// IPR_N2
        IPR_N2: u8 = 0,
        /// IPR_N3 [24:31]
        /// IPR_N3
        IPR_N3: u8 = 0,
    };
    /// Interrupt Priority Register
    pub const IPR2 = Register(IPR2_val).init(base_address + 0x408);

    /// IPR3
    const IPR3_val = packed struct {
        /// IPR_N0 [0:7]
        /// IPR_N0
        IPR_N0: u8 = 0,
        /// IPR_N1 [8:15]
        /// IPR_N1
        IPR_N1: u8 = 0,
        /// IPR_N2 [16:23]
        /// IPR_N2
        IPR_N2: u8 = 0,
        /// IPR_N3 [24:31]
        /// IPR_N3
        IPR_N3: u8 = 0,
    };
    /// Interrupt Priority Register
    pub const IPR3 = Register(IPR3_val).init(base_address + 0x40c);

    /// IPR4
    const IPR4_val = packed struct {
        /// IPR_N0 [0:7]
        /// IPR_N0
        IPR_N0: u8 = 0,
        /// IPR_N1 [8:15]
        /// IPR_N1
        IPR_N1: u8 = 0,
        /// IPR_N2 [16:23]
        /// IPR_N2
        IPR_N2: u8 = 0,
        /// IPR_N3 [24:31]
        /// IPR_N3
        IPR_N3: u8 = 0,
    };
    /// Interrupt Priority Register
    pub const IPR4 = Register(IPR4_val).init(base_address + 0x410);

    /// IPR5
    const IPR5_val = packed struct {
        /// IPR_N0 [0:7]
        /// IPR_N0
        IPR_N0: u8 = 0,
        /// IPR_N1 [8:15]
        /// IPR_N1
        IPR_N1: u8 = 0,
        /// IPR_N2 [16:23]
        /// IPR_N2
        IPR_N2: u8 = 0,
        /// IPR_N3 [24:31]
        /// IPR_N3
        IPR_N3: u8 = 0,
    };
    /// Interrupt Priority Register
    pub const IPR5 = Register(IPR5_val).init(base_address + 0x414);

    /// IPR6
    const IPR6_val = packed struct {
        /// IPR_N0 [0:7]
        /// IPR_N0
        IPR_N0: u8 = 0,
        /// IPR_N1 [8:15]
        /// IPR_N1
        IPR_N1: u8 = 0,
        /// IPR_N2 [16:23]
        /// IPR_N2
        IPR_N2: u8 = 0,
        /// IPR_N3 [24:31]
        /// IPR_N3
        IPR_N3: u8 = 0,
    };
    /// Interrupt Priority Register
    pub const IPR6 = Register(IPR6_val).init(base_address + 0x418);

    /// IPR7
    const IPR7_val = packed struct {
        /// IPR_N0 [0:7]
        /// IPR_N0
        IPR_N0: u8 = 0,
        /// IPR_N1 [8:15]
        /// IPR_N1
        IPR_N1: u8 = 0,
        /// IPR_N2 [16:23]
        /// IPR_N2
        IPR_N2: u8 = 0,
        /// IPR_N3 [24:31]
        /// IPR_N3
        IPR_N3: u8 = 0,
    };
    /// Interrupt Priority Register
    pub const IPR7 = Register(IPR7_val).init(base_address + 0x41c);

    /// IPR8
    const IPR8_val = packed struct {
        /// IPR_N0 [0:7]
        /// IPR_N0
        IPR_N0: u8 = 0,
        /// IPR_N1 [8:15]
        /// IPR_N1
        IPR_N1: u8 = 0,
        /// IPR_N2 [16:23]
        /// IPR_N2
        IPR_N2: u8 = 0,
        /// IPR_N3 [24:31]
        /// IPR_N3
        IPR_N3: u8 = 0,
    };
    /// Interrupt Priority Register
    pub const IPR8 = Register(IPR8_val).init(base_address + 0x420);

    /// IPR9
    const IPR9_val = packed struct {
        /// IPR_N0 [0:7]
        /// IPR_N0
        IPR_N0: u8 = 0,
        /// IPR_N1 [8:15]
        /// IPR_N1
        IPR_N1: u8 = 0,
        /// IPR_N2 [16:23]
        /// IPR_N2
        IPR_N2: u8 = 0,
        /// IPR_N3 [24:31]
        /// IPR_N3
        IPR_N3: u8 = 0,
    };
    /// Interrupt Priority Register
    pub const IPR9 = Register(IPR9_val).init(base_address + 0x424);

    /// IPR10
    const IPR10_val = packed struct {
        /// IPR_N0 [0:7]
        /// IPR_N0
        IPR_N0: u8 = 0,
        /// IPR_N1 [8:15]
        /// IPR_N1
        IPR_N1: u8 = 0,
        /// IPR_N2 [16:23]
        /// IPR_N2
        IPR_N2: u8 = 0,
        /// IPR_N3 [24:31]
        /// IPR_N3
        IPR_N3: u8 = 0,
    };
    /// Interrupt Priority Register
    pub const IPR10 = Register(IPR10_val).init(base_address + 0x428);

    /// IPR11
    const IPR11_val = packed struct {
        /// IPR_N0 [0:7]
        /// IPR_N0
        IPR_N0: u8 = 0,
        /// IPR_N1 [8:15]
        /// IPR_N1
        IPR_N1: u8 = 0,
        /// IPR_N2 [16:23]
        /// IPR_N2
        IPR_N2: u8 = 0,
        /// IPR_N3 [24:31]
        /// IPR_N3
        IPR_N3: u8 = 0,
    };
    /// Interrupt Priority Register
    pub const IPR11 = Register(IPR11_val).init(base_address + 0x42c);

    /// IPR12
    const IPR12_val = packed struct {
        /// IPR_N0 [0:7]
        /// IPR_N0
        IPR_N0: u8 = 0,
        /// IPR_N1 [8:15]
        /// IPR_N1
        IPR_N1: u8 = 0,
        /// IPR_N2 [16:23]
        /// IPR_N2
        IPR_N2: u8 = 0,
        /// IPR_N3 [24:31]
        /// IPR_N3
        IPR_N3: u8 = 0,
    };
    /// Interrupt Priority Register
    pub const IPR12 = Register(IPR12_val).init(base_address + 0x430);

    /// IPR13
    const IPR13_val = packed struct {
        /// IPR_N0 [0:7]
        /// IPR_N0
        IPR_N0: u8 = 0,
        /// IPR_N1 [8:15]
        /// IPR_N1
        IPR_N1: u8 = 0,
        /// IPR_N2 [16:23]
        /// IPR_N2
        IPR_N2: u8 = 0,
        /// IPR_N3 [24:31]
        /// IPR_N3
        IPR_N3: u8 = 0,
    };
    /// Interrupt Priority Register
    pub const IPR13 = Register(IPR13_val).init(base_address + 0x434);

    /// IPR14
    const IPR14_val = packed struct {
        /// IPR_N0 [0:7]
        /// IPR_N0
        IPR_N0: u8 = 0,
        /// IPR_N1 [8:15]
        /// IPR_N1
        IPR_N1: u8 = 0,
        /// IPR_N2 [16:23]
        /// IPR_N2
        IPR_N2: u8 = 0,
        /// IPR_N3 [24:31]
        /// IPR_N3
        IPR_N3: u8 = 0,
    };
    /// Interrupt Priority Register
    pub const IPR14 = Register(IPR14_val).init(base_address + 0x438);
};

/// Universal serial bus full-speed device
pub const USB = struct {
    const base_address = 0x40005c00;
    /// EP0R
    const EP0R_val = packed struct {
        /// EA [0:3]
        /// Endpoint address
        EA: u4 = 0,
        /// STAT_TX [4:5]
        /// Status bits, for transmission
        STAT_TX: u2 = 0,
        /// DTOG_TX [6:6]
        /// Data Toggle, for transmission
        DTOG_TX: u1 = 0,
        /// CTR_TX [7:7]
        /// Correct Transfer for
        CTR_TX: u1 = 0,
        /// EP_KIND [8:8]
        /// Endpoint kind
        EP_KIND: u1 = 0,
        /// EP_TYPE [9:10]
        /// Endpoint type
        EP_TYPE: u2 = 0,
        /// SETUP [11:11]
        /// Setup transaction
        SETUP: u1 = 0,
        /// STAT_RX [12:13]
        /// Status bits, for reception
        STAT_RX: u2 = 0,
        /// DTOG_RX [14:14]
        /// Data Toggle, for reception
        DTOG_RX: u1 = 0,
        /// CTR_RX [15:15]
        /// Correct transfer for
        CTR_RX: u1 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// endpoint 0 register
    pub const EP0R = Register(EP0R_val).init(base_address + 0x0);

    /// EP1R
    const EP1R_val = packed struct {
        /// EA [0:3]
        /// Endpoint address
        EA: u4 = 0,
        /// STAT_TX [4:5]
        /// Status bits, for transmission
        STAT_TX: u2 = 0,
        /// DTOG_TX [6:6]
        /// Data Toggle, for transmission
        DTOG_TX: u1 = 0,
        /// CTR_TX [7:7]
        /// Correct Transfer for
        CTR_TX: u1 = 0,
        /// EP_KIND [8:8]
        /// Endpoint kind
        EP_KIND: u1 = 0,
        /// EP_TYPE [9:10]
        /// Endpoint type
        EP_TYPE: u2 = 0,
        /// SETUP [11:11]
        /// Setup transaction
        SETUP: u1 = 0,
        /// STAT_RX [12:13]
        /// Status bits, for reception
        STAT_RX: u2 = 0,
        /// DTOG_RX [14:14]
        /// Data Toggle, for reception
        DTOG_RX: u1 = 0,
        /// CTR_RX [15:15]
        /// Correct transfer for
        CTR_RX: u1 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// endpoint 1 register
    pub const EP1R = Register(EP1R_val).init(base_address + 0x4);

    /// EP2R
    const EP2R_val = packed struct {
        /// EA [0:3]
        /// Endpoint address
        EA: u4 = 0,
        /// STAT_TX [4:5]
        /// Status bits, for transmission
        STAT_TX: u2 = 0,
        /// DTOG_TX [6:6]
        /// Data Toggle, for transmission
        DTOG_TX: u1 = 0,
        /// CTR_TX [7:7]
        /// Correct Transfer for
        CTR_TX: u1 = 0,
        /// EP_KIND [8:8]
        /// Endpoint kind
        EP_KIND: u1 = 0,
        /// EP_TYPE [9:10]
        /// Endpoint type
        EP_TYPE: u2 = 0,
        /// SETUP [11:11]
        /// Setup transaction
        SETUP: u1 = 0,
        /// STAT_RX [12:13]
        /// Status bits, for reception
        STAT_RX: u2 = 0,
        /// DTOG_RX [14:14]
        /// Data Toggle, for reception
        DTOG_RX: u1 = 0,
        /// CTR_RX [15:15]
        /// Correct transfer for
        CTR_RX: u1 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// endpoint 2 register
    pub const EP2R = Register(EP2R_val).init(base_address + 0x8);

    /// EP3R
    const EP3R_val = packed struct {
        /// EA [0:3]
        /// Endpoint address
        EA: u4 = 0,
        /// STAT_TX [4:5]
        /// Status bits, for transmission
        STAT_TX: u2 = 0,
        /// DTOG_TX [6:6]
        /// Data Toggle, for transmission
        DTOG_TX: u1 = 0,
        /// CTR_TX [7:7]
        /// Correct Transfer for
        CTR_TX: u1 = 0,
        /// EP_KIND [8:8]
        /// Endpoint kind
        EP_KIND: u1 = 0,
        /// EP_TYPE [9:10]
        /// Endpoint type
        EP_TYPE: u2 = 0,
        /// SETUP [11:11]
        /// Setup transaction
        SETUP: u1 = 0,
        /// STAT_RX [12:13]
        /// Status bits, for reception
        STAT_RX: u2 = 0,
        /// DTOG_RX [14:14]
        /// Data Toggle, for reception
        DTOG_RX: u1 = 0,
        /// CTR_RX [15:15]
        /// Correct transfer for
        CTR_RX: u1 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// endpoint 3 register
    pub const EP3R = Register(EP3R_val).init(base_address + 0xc);

    /// EP4R
    const EP4R_val = packed struct {
        /// EA [0:3]
        /// Endpoint address
        EA: u4 = 0,
        /// STAT_TX [4:5]
        /// Status bits, for transmission
        STAT_TX: u2 = 0,
        /// DTOG_TX [6:6]
        /// Data Toggle, for transmission
        DTOG_TX: u1 = 0,
        /// CTR_TX [7:7]
        /// Correct Transfer for
        CTR_TX: u1 = 0,
        /// EP_KIND [8:8]
        /// Endpoint kind
        EP_KIND: u1 = 0,
        /// EP_TYPE [9:10]
        /// Endpoint type
        EP_TYPE: u2 = 0,
        /// SETUP [11:11]
        /// Setup transaction
        SETUP: u1 = 0,
        /// STAT_RX [12:13]
        /// Status bits, for reception
        STAT_RX: u2 = 0,
        /// DTOG_RX [14:14]
        /// Data Toggle, for reception
        DTOG_RX: u1 = 0,
        /// CTR_RX [15:15]
        /// Correct transfer for
        CTR_RX: u1 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// endpoint 4 register
    pub const EP4R = Register(EP4R_val).init(base_address + 0x10);

    /// EP5R
    const EP5R_val = packed struct {
        /// EA [0:3]
        /// Endpoint address
        EA: u4 = 0,
        /// STAT_TX [4:5]
        /// Status bits, for transmission
        STAT_TX: u2 = 0,
        /// DTOG_TX [6:6]
        /// Data Toggle, for transmission
        DTOG_TX: u1 = 0,
        /// CTR_TX [7:7]
        /// Correct Transfer for
        CTR_TX: u1 = 0,
        /// EP_KIND [8:8]
        /// Endpoint kind
        EP_KIND: u1 = 0,
        /// EP_TYPE [9:10]
        /// Endpoint type
        EP_TYPE: u2 = 0,
        /// SETUP [11:11]
        /// Setup transaction
        SETUP: u1 = 0,
        /// STAT_RX [12:13]
        /// Status bits, for reception
        STAT_RX: u2 = 0,
        /// DTOG_RX [14:14]
        /// Data Toggle, for reception
        DTOG_RX: u1 = 0,
        /// CTR_RX [15:15]
        /// Correct transfer for
        CTR_RX: u1 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// endpoint 5 register
    pub const EP5R = Register(EP5R_val).init(base_address + 0x14);

    /// EP6R
    const EP6R_val = packed struct {
        /// EA [0:3]
        /// Endpoint address
        EA: u4 = 0,
        /// STAT_TX [4:5]
        /// Status bits, for transmission
        STAT_TX: u2 = 0,
        /// DTOG_TX [6:6]
        /// Data Toggle, for transmission
        DTOG_TX: u1 = 0,
        /// CTR_TX [7:7]
        /// Correct Transfer for
        CTR_TX: u1 = 0,
        /// EP_KIND [8:8]
        /// Endpoint kind
        EP_KIND: u1 = 0,
        /// EP_TYPE [9:10]
        /// Endpoint type
        EP_TYPE: u2 = 0,
        /// SETUP [11:11]
        /// Setup transaction
        SETUP: u1 = 0,
        /// STAT_RX [12:13]
        /// Status bits, for reception
        STAT_RX: u2 = 0,
        /// DTOG_RX [14:14]
        /// Data Toggle, for reception
        DTOG_RX: u1 = 0,
        /// CTR_RX [15:15]
        /// Correct transfer for
        CTR_RX: u1 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// endpoint 6 register
    pub const EP6R = Register(EP6R_val).init(base_address + 0x18);

    /// EP7R
    const EP7R_val = packed struct {
        /// EA [0:3]
        /// Endpoint address
        EA: u4 = 0,
        /// STAT_TX [4:5]
        /// Status bits, for transmission
        STAT_TX: u2 = 0,
        /// DTOG_TX [6:6]
        /// Data Toggle, for transmission
        DTOG_TX: u1 = 0,
        /// CTR_TX [7:7]
        /// Correct Transfer for
        CTR_TX: u1 = 0,
        /// EP_KIND [8:8]
        /// Endpoint kind
        EP_KIND: u1 = 0,
        /// EP_TYPE [9:10]
        /// Endpoint type
        EP_TYPE: u2 = 0,
        /// SETUP [11:11]
        /// Setup transaction
        SETUP: u1 = 0,
        /// STAT_RX [12:13]
        /// Status bits, for reception
        STAT_RX: u2 = 0,
        /// DTOG_RX [14:14]
        /// Data Toggle, for reception
        DTOG_RX: u1 = 0,
        /// CTR_RX [15:15]
        /// Correct transfer for
        CTR_RX: u1 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// endpoint 7 register
    pub const EP7R = Register(EP7R_val).init(base_address + 0x1c);

    /// CNTR
    const CNTR_val = packed struct {
        /// FRES [0:0]
        /// Force USB Reset
        FRES: u1 = 1,
        /// PDWN [1:1]
        /// Power down
        PDWN: u1 = 1,
        /// LPMODE [2:2]
        /// Low-power mode
        LPMODE: u1 = 0,
        /// FSUSP [3:3]
        /// Force suspend
        FSUSP: u1 = 0,
        /// RESUME [4:4]
        /// Resume request
        RESUME: u1 = 0,
        /// unused [5:7]
        _unused5: u3 = 0,
        /// ESOFM [8:8]
        /// Expected start of frame interrupt
        ESOFM: u1 = 0,
        /// SOFM [9:9]
        /// Start of frame interrupt
        SOFM: u1 = 0,
        /// RESETM [10:10]
        /// USB reset interrupt mask
        RESETM: u1 = 0,
        /// SUSPM [11:11]
        /// Suspend mode interrupt
        SUSPM: u1 = 0,
        /// WKUPM [12:12]
        /// Wakeup interrupt mask
        WKUPM: u1 = 0,
        /// ERRM [13:13]
        /// Error interrupt mask
        ERRM: u1 = 0,
        /// PMAOVRM [14:14]
        /// Packet memory area over / underrun
        PMAOVRM: u1 = 0,
        /// CTRM [15:15]
        /// Correct transfer interrupt
        CTRM: u1 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// control register
    pub const CNTR = Register(CNTR_val).init(base_address + 0x40);

    /// ISTR
    const ISTR_val = packed struct {
        /// EP_ID [0:3]
        /// Endpoint Identifier
        EP_ID: u4 = 0,
        /// DIR [4:4]
        /// Direction of transaction
        DIR: u1 = 0,
        /// unused [5:7]
        _unused5: u3 = 0,
        /// ESOF [8:8]
        /// Expected start frame
        ESOF: u1 = 0,
        /// SOF [9:9]
        /// start of frame
        SOF: u1 = 0,
        /// RESET [10:10]
        /// reset request
        RESET: u1 = 0,
        /// SUSP [11:11]
        /// Suspend mode request
        SUSP: u1 = 0,
        /// WKUP [12:12]
        /// Wakeup
        WKUP: u1 = 0,
        /// ERR [13:13]
        /// Error
        ERR: u1 = 0,
        /// PMAOVR [14:14]
        /// Packet memory area over /
        PMAOVR: u1 = 0,
        /// CTR [15:15]
        /// Correct transfer
        CTR: u1 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// interrupt status register
    pub const ISTR = Register(ISTR_val).init(base_address + 0x44);

    /// FNR
    const FNR_val = packed struct {
        /// FN [0:10]
        /// Frame number
        FN: u11 = 0,
        /// LSOF [11:12]
        /// Lost SOF
        LSOF: u2 = 0,
        /// LCK [13:13]
        /// Locked
        LCK: u1 = 0,
        /// RXDM [14:14]
        /// Receive data - line status
        RXDM: u1 = 0,
        /// RXDP [15:15]
        /// Receive data + line status
        RXDP: u1 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// frame number register
    pub const FNR = Register(FNR_val).init(base_address + 0x48);

    /// DADDR
    const DADDR_val = packed struct {
        /// ADD [0:6]
        /// Device address
        ADD: u7 = 0,
        /// EF [7:7]
        /// Enable function
        EF: u1 = 0,
        /// unused [8:31]
        _unused8: u8 = 0,
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// device address
    pub const DADDR = Register(DADDR_val).init(base_address + 0x4c);

    /// BTABLE
    const BTABLE_val = packed struct {
        /// unused [0:2]
        _unused0: u3 = 0,
        /// BTABLE [3:15]
        /// Buffer table
        BTABLE: u13 = 0,
        /// unused [16:31]
        _unused16: u8 = 0,
        _unused24: u8 = 0,
    };
    /// Buffer table address
    pub const BTABLE = Register(BTABLE_val).init(base_address + 0x50);
};
pub const interrupts = struct {
    pub const TIM1_TRG_COM_TIM11 = 26;
    pub const TIM6 = 54;
    pub const CAN1_SCE = 22;
    pub const I2C2_ER = 34;
    pub const DMA2_Channel1 = 56;
    pub const EXTI3 = 9;
    pub const RTCAlarm = 41;
    pub const TIM5 = 50;
    pub const SPI2 = 36;
    pub const USART2 = 38;
    pub const EXTI0 = 6;
    pub const I2C2_EV = 33;
    pub const TAMPER = 2;
    pub const CAN1_RX1 = 21;
    pub const EXTI1 = 7;
    pub const TIM8_BRK_TIM12 = 43;
    pub const TIM2 = 28;
    pub const EXTI15_10 = 40;
    pub const RCC = 5;
    pub const USART1 = 37;
    pub const DMA1_Channel6 = 16;
    pub const DMA2_Channel3 = 58;
    pub const CAN1_RX0 = 20;
    pub const TIM7 = 55;
    pub const DMA1_Channel3 = 13;
    pub const TIM1_BRK_TIM9 = 24;
    pub const DMA1_Channel1 = 11;
    pub const SDIO = 49;
    pub const ADC3 = 47;
    pub const DMA2_Channel4_5 = 59;
    pub const RTC = 3;
    pub const DMA1_Channel7 = 17;
    pub const TIM8_TRG_COM_TIM14 = 45;
    pub const SPI3 = 51;
    pub const EXTI9_5 = 23;
    pub const TIM1_CC = 27;
    pub const I2C1_EV = 31;
    pub const TIM4 = 30;
    pub const DMA1_Channel2 = 12;
    pub const WWDG = 0;
    pub const DMA1_Channel4 = 14;
    pub const EXTI2 = 8;
    pub const TIM8_UP_TIM13 = 44;
    pub const TIM8_CC = 46;
    pub const ADC = 18;
    pub const TIM1_UP_TIM10 = 25;
    pub const USART3 = 39;
    pub const UART4 = 52;
    pub const USB_FS_WKUP = 42;
    pub const DMA2_Channel2 = 57;
    pub const I2C1_ER = 32;
    pub const CAN1_TX = 19;
    pub const PVD = 1;
    pub const TIM3 = 29;
    pub const FLASH = 4;
    pub const SPI1 = 35;
    pub const DMA1_Channel5 = 15;
    pub const UART5 = 53;
    pub const EXTI4 = 10;
    pub const FSMC = 48;
};
