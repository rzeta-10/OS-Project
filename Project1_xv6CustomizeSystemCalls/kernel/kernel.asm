
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	0000a117          	auipc	sp,0xa
    80000004:	36013103          	ld	sp,864(sp) # 8000a360 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	04a000ef          	jal	80000060 <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
}

// ask each hart to generate timer interrupts.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
#define MIE_STIE (1L << 5)  // supervisor timer
static inline uint64
r_mie()
{
  uint64 x;
  asm volatile("csrr %0, mie" : "=r" (x) );
    80000022:	304027f3          	csrr	a5,mie
  // enable supervisor-mode timer interrupts.
  w_mie(r_mie() | MIE_STIE);
    80000026:	0207e793          	ori	a5,a5,32
}

static inline void 
w_mie(uint64 x)
{
  asm volatile("csrw mie, %0" : : "r" (x));
    8000002a:	30479073          	csrw	mie,a5
static inline uint64
r_menvcfg()
{
  uint64 x;
  // asm volatile("csrr %0, menvcfg" : "=r" (x) );
  asm volatile("csrr %0, 0x30a" : "=r" (x) );
    8000002e:	30a027f3          	csrr	a5,0x30a
  
  // enable the sstc extension (i.e. stimecmp).
  w_menvcfg(r_menvcfg() | (1L << 63)); 
    80000032:	577d                	li	a4,-1
    80000034:	177e                	slli	a4,a4,0x3f
    80000036:	8fd9                	or	a5,a5,a4

static inline void 
w_menvcfg(uint64 x)
{
  // asm volatile("csrw menvcfg, %0" : : "r" (x));
  asm volatile("csrw 0x30a, %0" : : "r" (x));
    80000038:	30a79073          	csrw	0x30a,a5

static inline uint64
r_mcounteren()
{
  uint64 x;
  asm volatile("csrr %0, mcounteren" : "=r" (x) );
    8000003c:	306027f3          	csrr	a5,mcounteren
  
  // allow supervisor to use stimecmp and time.
  w_mcounteren(r_mcounteren() | 2);
    80000040:	0027e793          	ori	a5,a5,2
  asm volatile("csrw mcounteren, %0" : : "r" (x));
    80000044:	30679073          	csrw	mcounteren,a5
// machine-mode cycle counter
static inline uint64
r_time()
{
  uint64 x;
  asm volatile("csrr %0, time" : "=r" (x) );
    80000048:	c01027f3          	rdtime	a5
  
  // ask for the very first timer interrupt.
  w_stimecmp(r_time() + 1000000);
    8000004c:	000f4737          	lui	a4,0xf4
    80000050:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80000054:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80000056:	14d79073          	csrw	stimecmp,a5
}
    8000005a:	6422                	ld	s0,8(sp)
    8000005c:	0141                	addi	sp,sp,16
    8000005e:	8082                	ret

0000000080000060 <start>:
{
    80000060:	1141                	addi	sp,sp,-16
    80000062:	e406                	sd	ra,8(sp)
    80000064:	e022                	sd	s0,0(sp)
    80000066:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000068:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    8000006c:	7779                	lui	a4,0xffffe
    8000006e:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd52f7>
    80000072:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    80000074:	6705                	lui	a4,0x1
    80000076:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    8000007a:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    8000007c:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    80000080:	00001797          	auipc	a5,0x1
    80000084:	de278793          	addi	a5,a5,-542 # 80000e62 <main>
    80000088:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    8000008c:	4781                	li	a5,0
    8000008e:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    80000092:	67c1                	lui	a5,0x10
    80000094:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    80000096:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    8000009a:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    8000009e:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000a2:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000a6:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000aa:	57fd                	li	a5,-1
    800000ac:	83a9                	srli	a5,a5,0xa
    800000ae:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000b2:	47bd                	li	a5,15
    800000b4:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000b8:	f65ff0ef          	jal	8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000bc:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000c0:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000c2:	823e                	mv	tp,a5
  asm volatile("mret");
    800000c4:	30200073          	mret
}
    800000c8:	60a2                	ld	ra,8(sp)
    800000ca:	6402                	ld	s0,0(sp)
    800000cc:	0141                	addi	sp,sp,16
    800000ce:	8082                	ret

00000000800000d0 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800000d0:	715d                	addi	sp,sp,-80
    800000d2:	e486                	sd	ra,72(sp)
    800000d4:	e0a2                	sd	s0,64(sp)
    800000d6:	f84a                	sd	s2,48(sp)
    800000d8:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    800000da:	04c05263          	blez	a2,8000011e <consolewrite+0x4e>
    800000de:	fc26                	sd	s1,56(sp)
    800000e0:	f44e                	sd	s3,40(sp)
    800000e2:	f052                	sd	s4,32(sp)
    800000e4:	ec56                	sd	s5,24(sp)
    800000e6:	8a2a                	mv	s4,a0
    800000e8:	84ae                	mv	s1,a1
    800000ea:	89b2                	mv	s3,a2
    800000ec:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    800000ee:	5afd                	li	s5,-1
    800000f0:	4685                	li	a3,1
    800000f2:	8626                	mv	a2,s1
    800000f4:	85d2                	mv	a1,s4
    800000f6:	fbf40513          	addi	a0,s0,-65
    800000fa:	15a020ef          	jal	80002254 <either_copyin>
    800000fe:	03550263          	beq	a0,s5,80000122 <consolewrite+0x52>
      break;
    uartputc(c);
    80000102:	fbf44503          	lbu	a0,-65(s0)
    80000106:	035000ef          	jal	8000093a <uartputc>
  for(i = 0; i < n; i++){
    8000010a:	2905                	addiw	s2,s2,1
    8000010c:	0485                	addi	s1,s1,1
    8000010e:	ff2991e3          	bne	s3,s2,800000f0 <consolewrite+0x20>
    80000112:	894e                	mv	s2,s3
    80000114:	74e2                	ld	s1,56(sp)
    80000116:	79a2                	ld	s3,40(sp)
    80000118:	7a02                	ld	s4,32(sp)
    8000011a:	6ae2                	ld	s5,24(sp)
    8000011c:	a039                	j	8000012a <consolewrite+0x5a>
    8000011e:	4901                	li	s2,0
    80000120:	a029                	j	8000012a <consolewrite+0x5a>
    80000122:	74e2                	ld	s1,56(sp)
    80000124:	79a2                	ld	s3,40(sp)
    80000126:	7a02                	ld	s4,32(sp)
    80000128:	6ae2                	ld	s5,24(sp)
  }

  return i;
}
    8000012a:	854a                	mv	a0,s2
    8000012c:	60a6                	ld	ra,72(sp)
    8000012e:	6406                	ld	s0,64(sp)
    80000130:	7942                	ld	s2,48(sp)
    80000132:	6161                	addi	sp,sp,80
    80000134:	8082                	ret

0000000080000136 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000136:	711d                	addi	sp,sp,-96
    80000138:	ec86                	sd	ra,88(sp)
    8000013a:	e8a2                	sd	s0,80(sp)
    8000013c:	e4a6                	sd	s1,72(sp)
    8000013e:	e0ca                	sd	s2,64(sp)
    80000140:	fc4e                	sd	s3,56(sp)
    80000142:	f852                	sd	s4,48(sp)
    80000144:	f456                	sd	s5,40(sp)
    80000146:	f05a                	sd	s6,32(sp)
    80000148:	1080                	addi	s0,sp,96
    8000014a:	8aaa                	mv	s5,a0
    8000014c:	8a2e                	mv	s4,a1
    8000014e:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000150:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    80000154:	00012517          	auipc	a0,0x12
    80000158:	26c50513          	addi	a0,a0,620 # 800123c0 <cons>
    8000015c:	299000ef          	jal	80000bf4 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80000160:	00012497          	auipc	s1,0x12
    80000164:	26048493          	addi	s1,s1,608 # 800123c0 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    80000168:	00012917          	auipc	s2,0x12
    8000016c:	2f090913          	addi	s2,s2,752 # 80012458 <cons+0x98>
  while(n > 0){
    80000170:	0b305d63          	blez	s3,8000022a <consoleread+0xf4>
    while(cons.r == cons.w){
    80000174:	0984a783          	lw	a5,152(s1)
    80000178:	09c4a703          	lw	a4,156(s1)
    8000017c:	0af71263          	bne	a4,a5,80000220 <consoleread+0xea>
      if(killed(myproc())){
    80000180:	760010ef          	jal	800018e0 <myproc>
    80000184:	763010ef          	jal	800020e6 <killed>
    80000188:	e12d                	bnez	a0,800001ea <consoleread+0xb4>
      sleep(&cons.r, &cons.lock);
    8000018a:	85a6                	mv	a1,s1
    8000018c:	854a                	mv	a0,s2
    8000018e:	521010ef          	jal	80001eae <sleep>
    while(cons.r == cons.w){
    80000192:	0984a783          	lw	a5,152(s1)
    80000196:	09c4a703          	lw	a4,156(s1)
    8000019a:	fef703e3          	beq	a4,a5,80000180 <consoleread+0x4a>
    8000019e:	ec5e                	sd	s7,24(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001a0:	00012717          	auipc	a4,0x12
    800001a4:	22070713          	addi	a4,a4,544 # 800123c0 <cons>
    800001a8:	0017869b          	addiw	a3,a5,1
    800001ac:	08d72c23          	sw	a3,152(a4)
    800001b0:	07f7f693          	andi	a3,a5,127
    800001b4:	9736                	add	a4,a4,a3
    800001b6:	01874703          	lbu	a4,24(a4)
    800001ba:	00070b9b          	sext.w	s7,a4

    if(c == C('D')){  // end-of-file
    800001be:	4691                	li	a3,4
    800001c0:	04db8663          	beq	s7,a3,8000020c <consoleread+0xd6>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    800001c4:	fae407a3          	sb	a4,-81(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001c8:	4685                	li	a3,1
    800001ca:	faf40613          	addi	a2,s0,-81
    800001ce:	85d2                	mv	a1,s4
    800001d0:	8556                	mv	a0,s5
    800001d2:	038020ef          	jal	8000220a <either_copyout>
    800001d6:	57fd                	li	a5,-1
    800001d8:	04f50863          	beq	a0,a5,80000228 <consoleread+0xf2>
      break;

    dst++;
    800001dc:	0a05                	addi	s4,s4,1
    --n;
    800001de:	39fd                	addiw	s3,s3,-1

    if(c == '\n'){
    800001e0:	47a9                	li	a5,10
    800001e2:	04fb8d63          	beq	s7,a5,8000023c <consoleread+0x106>
    800001e6:	6be2                	ld	s7,24(sp)
    800001e8:	b761                	j	80000170 <consoleread+0x3a>
        release(&cons.lock);
    800001ea:	00012517          	auipc	a0,0x12
    800001ee:	1d650513          	addi	a0,a0,470 # 800123c0 <cons>
    800001f2:	29b000ef          	jal	80000c8c <release>
        return -1;
    800001f6:	557d                	li	a0,-1
    }
  }
  release(&cons.lock);

  return target - n;
}
    800001f8:	60e6                	ld	ra,88(sp)
    800001fa:	6446                	ld	s0,80(sp)
    800001fc:	64a6                	ld	s1,72(sp)
    800001fe:	6906                	ld	s2,64(sp)
    80000200:	79e2                	ld	s3,56(sp)
    80000202:	7a42                	ld	s4,48(sp)
    80000204:	7aa2                	ld	s5,40(sp)
    80000206:	7b02                	ld	s6,32(sp)
    80000208:	6125                	addi	sp,sp,96
    8000020a:	8082                	ret
      if(n < target){
    8000020c:	0009871b          	sext.w	a4,s3
    80000210:	01677a63          	bgeu	a4,s6,80000224 <consoleread+0xee>
        cons.r--;
    80000214:	00012717          	auipc	a4,0x12
    80000218:	24f72223          	sw	a5,580(a4) # 80012458 <cons+0x98>
    8000021c:	6be2                	ld	s7,24(sp)
    8000021e:	a031                	j	8000022a <consoleread+0xf4>
    80000220:	ec5e                	sd	s7,24(sp)
    80000222:	bfbd                	j	800001a0 <consoleread+0x6a>
    80000224:	6be2                	ld	s7,24(sp)
    80000226:	a011                	j	8000022a <consoleread+0xf4>
    80000228:	6be2                	ld	s7,24(sp)
  release(&cons.lock);
    8000022a:	00012517          	auipc	a0,0x12
    8000022e:	19650513          	addi	a0,a0,406 # 800123c0 <cons>
    80000232:	25b000ef          	jal	80000c8c <release>
  return target - n;
    80000236:	413b053b          	subw	a0,s6,s3
    8000023a:	bf7d                	j	800001f8 <consoleread+0xc2>
    8000023c:	6be2                	ld	s7,24(sp)
    8000023e:	b7f5                	j	8000022a <consoleread+0xf4>

0000000080000240 <consputc>:
{
    80000240:	1141                	addi	sp,sp,-16
    80000242:	e406                	sd	ra,8(sp)
    80000244:	e022                	sd	s0,0(sp)
    80000246:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000248:	10000793          	li	a5,256
    8000024c:	00f50863          	beq	a0,a5,8000025c <consputc+0x1c>
    uartputc_sync(c);
    80000250:	604000ef          	jal	80000854 <uartputc_sync>
}
    80000254:	60a2                	ld	ra,8(sp)
    80000256:	6402                	ld	s0,0(sp)
    80000258:	0141                	addi	sp,sp,16
    8000025a:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    8000025c:	4521                	li	a0,8
    8000025e:	5f6000ef          	jal	80000854 <uartputc_sync>
    80000262:	02000513          	li	a0,32
    80000266:	5ee000ef          	jal	80000854 <uartputc_sync>
    8000026a:	4521                	li	a0,8
    8000026c:	5e8000ef          	jal	80000854 <uartputc_sync>
    80000270:	b7d5                	j	80000254 <consputc+0x14>

0000000080000272 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    80000272:	1101                	addi	sp,sp,-32
    80000274:	ec06                	sd	ra,24(sp)
    80000276:	e822                	sd	s0,16(sp)
    80000278:	e426                	sd	s1,8(sp)
    8000027a:	1000                	addi	s0,sp,32
    8000027c:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    8000027e:	00012517          	auipc	a0,0x12
    80000282:	14250513          	addi	a0,a0,322 # 800123c0 <cons>
    80000286:	16f000ef          	jal	80000bf4 <acquire>

  switch(c){
    8000028a:	47d5                	li	a5,21
    8000028c:	08f48f63          	beq	s1,a5,8000032a <consoleintr+0xb8>
    80000290:	0297c563          	blt	a5,s1,800002ba <consoleintr+0x48>
    80000294:	47a1                	li	a5,8
    80000296:	0ef48463          	beq	s1,a5,8000037e <consoleintr+0x10c>
    8000029a:	47c1                	li	a5,16
    8000029c:	10f49563          	bne	s1,a5,800003a6 <consoleintr+0x134>
  case C('P'):  // Print process list.
    procdump();
    800002a0:	7ff010ef          	jal	8000229e <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002a4:	00012517          	auipc	a0,0x12
    800002a8:	11c50513          	addi	a0,a0,284 # 800123c0 <cons>
    800002ac:	1e1000ef          	jal	80000c8c <release>
}
    800002b0:	60e2                	ld	ra,24(sp)
    800002b2:	6442                	ld	s0,16(sp)
    800002b4:	64a2                	ld	s1,8(sp)
    800002b6:	6105                	addi	sp,sp,32
    800002b8:	8082                	ret
  switch(c){
    800002ba:	07f00793          	li	a5,127
    800002be:	0cf48063          	beq	s1,a5,8000037e <consoleintr+0x10c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800002c2:	00012717          	auipc	a4,0x12
    800002c6:	0fe70713          	addi	a4,a4,254 # 800123c0 <cons>
    800002ca:	0a072783          	lw	a5,160(a4)
    800002ce:	09872703          	lw	a4,152(a4)
    800002d2:	9f99                	subw	a5,a5,a4
    800002d4:	07f00713          	li	a4,127
    800002d8:	fcf766e3          	bltu	a4,a5,800002a4 <consoleintr+0x32>
      c = (c == '\r') ? '\n' : c;
    800002dc:	47b5                	li	a5,13
    800002de:	0cf48763          	beq	s1,a5,800003ac <consoleintr+0x13a>
      consputc(c);
    800002e2:	8526                	mv	a0,s1
    800002e4:	f5dff0ef          	jal	80000240 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800002e8:	00012797          	auipc	a5,0x12
    800002ec:	0d878793          	addi	a5,a5,216 # 800123c0 <cons>
    800002f0:	0a07a683          	lw	a3,160(a5)
    800002f4:	0016871b          	addiw	a4,a3,1
    800002f8:	0007061b          	sext.w	a2,a4
    800002fc:	0ae7a023          	sw	a4,160(a5)
    80000300:	07f6f693          	andi	a3,a3,127
    80000304:	97b6                	add	a5,a5,a3
    80000306:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    8000030a:	47a9                	li	a5,10
    8000030c:	0cf48563          	beq	s1,a5,800003d6 <consoleintr+0x164>
    80000310:	4791                	li	a5,4
    80000312:	0cf48263          	beq	s1,a5,800003d6 <consoleintr+0x164>
    80000316:	00012797          	auipc	a5,0x12
    8000031a:	1427a783          	lw	a5,322(a5) # 80012458 <cons+0x98>
    8000031e:	9f1d                	subw	a4,a4,a5
    80000320:	08000793          	li	a5,128
    80000324:	f8f710e3          	bne	a4,a5,800002a4 <consoleintr+0x32>
    80000328:	a07d                	j	800003d6 <consoleintr+0x164>
    8000032a:	e04a                	sd	s2,0(sp)
    while(cons.e != cons.w &&
    8000032c:	00012717          	auipc	a4,0x12
    80000330:	09470713          	addi	a4,a4,148 # 800123c0 <cons>
    80000334:	0a072783          	lw	a5,160(a4)
    80000338:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    8000033c:	00012497          	auipc	s1,0x12
    80000340:	08448493          	addi	s1,s1,132 # 800123c0 <cons>
    while(cons.e != cons.w &&
    80000344:	4929                	li	s2,10
    80000346:	02f70863          	beq	a4,a5,80000376 <consoleintr+0x104>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    8000034a:	37fd                	addiw	a5,a5,-1
    8000034c:	07f7f713          	andi	a4,a5,127
    80000350:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    80000352:	01874703          	lbu	a4,24(a4)
    80000356:	03270263          	beq	a4,s2,8000037a <consoleintr+0x108>
      cons.e--;
    8000035a:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    8000035e:	10000513          	li	a0,256
    80000362:	edfff0ef          	jal	80000240 <consputc>
    while(cons.e != cons.w &&
    80000366:	0a04a783          	lw	a5,160(s1)
    8000036a:	09c4a703          	lw	a4,156(s1)
    8000036e:	fcf71ee3          	bne	a4,a5,8000034a <consoleintr+0xd8>
    80000372:	6902                	ld	s2,0(sp)
    80000374:	bf05                	j	800002a4 <consoleintr+0x32>
    80000376:	6902                	ld	s2,0(sp)
    80000378:	b735                	j	800002a4 <consoleintr+0x32>
    8000037a:	6902                	ld	s2,0(sp)
    8000037c:	b725                	j	800002a4 <consoleintr+0x32>
    if(cons.e != cons.w){
    8000037e:	00012717          	auipc	a4,0x12
    80000382:	04270713          	addi	a4,a4,66 # 800123c0 <cons>
    80000386:	0a072783          	lw	a5,160(a4)
    8000038a:	09c72703          	lw	a4,156(a4)
    8000038e:	f0f70be3          	beq	a4,a5,800002a4 <consoleintr+0x32>
      cons.e--;
    80000392:	37fd                	addiw	a5,a5,-1
    80000394:	00012717          	auipc	a4,0x12
    80000398:	0cf72623          	sw	a5,204(a4) # 80012460 <cons+0xa0>
      consputc(BACKSPACE);
    8000039c:	10000513          	li	a0,256
    800003a0:	ea1ff0ef          	jal	80000240 <consputc>
    800003a4:	b701                	j	800002a4 <consoleintr+0x32>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800003a6:	ee048fe3          	beqz	s1,800002a4 <consoleintr+0x32>
    800003aa:	bf21                	j	800002c2 <consoleintr+0x50>
      consputc(c);
    800003ac:	4529                	li	a0,10
    800003ae:	e93ff0ef          	jal	80000240 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800003b2:	00012797          	auipc	a5,0x12
    800003b6:	00e78793          	addi	a5,a5,14 # 800123c0 <cons>
    800003ba:	0a07a703          	lw	a4,160(a5)
    800003be:	0017069b          	addiw	a3,a4,1
    800003c2:	0006861b          	sext.w	a2,a3
    800003c6:	0ad7a023          	sw	a3,160(a5)
    800003ca:	07f77713          	andi	a4,a4,127
    800003ce:	97ba                	add	a5,a5,a4
    800003d0:	4729                	li	a4,10
    800003d2:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    800003d6:	00012797          	auipc	a5,0x12
    800003da:	08c7a323          	sw	a2,134(a5) # 8001245c <cons+0x9c>
        wakeup(&cons.r);
    800003de:	00012517          	auipc	a0,0x12
    800003e2:	07a50513          	addi	a0,a0,122 # 80012458 <cons+0x98>
    800003e6:	315010ef          	jal	80001efa <wakeup>
    800003ea:	bd6d                	j	800002a4 <consoleintr+0x32>

00000000800003ec <consoleinit>:

void
consoleinit(void)
{
    800003ec:	1141                	addi	sp,sp,-16
    800003ee:	e406                	sd	ra,8(sp)
    800003f0:	e022                	sd	s0,0(sp)
    800003f2:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    800003f4:	00007597          	auipc	a1,0x7
    800003f8:	c0c58593          	addi	a1,a1,-1012 # 80007000 <etext>
    800003fc:	00012517          	auipc	a0,0x12
    80000400:	fc450513          	addi	a0,a0,-60 # 800123c0 <cons>
    80000404:	770000ef          	jal	80000b74 <initlock>

  uartinit();
    80000408:	3f4000ef          	jal	800007fc <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    8000040c:	00028797          	auipc	a5,0x28
    80000410:	f6478793          	addi	a5,a5,-156 # 80028370 <devsw>
    80000414:	00000717          	auipc	a4,0x0
    80000418:	d2270713          	addi	a4,a4,-734 # 80000136 <consoleread>
    8000041c:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    8000041e:	00000717          	auipc	a4,0x0
    80000422:	cb270713          	addi	a4,a4,-846 # 800000d0 <consolewrite>
    80000426:	ef98                	sd	a4,24(a5)
}
    80000428:	60a2                	ld	ra,8(sp)
    8000042a:	6402                	ld	s0,0(sp)
    8000042c:	0141                	addi	sp,sp,16
    8000042e:	8082                	ret

0000000080000430 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(long long xx, int base, int sign)
{
    80000430:	7179                	addi	sp,sp,-48
    80000432:	f406                	sd	ra,40(sp)
    80000434:	f022                	sd	s0,32(sp)
    80000436:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  unsigned long long x;

  if(sign && (sign = (xx < 0)))
    80000438:	c219                	beqz	a2,8000043e <printint+0xe>
    8000043a:	08054063          	bltz	a0,800004ba <printint+0x8a>
    x = -xx;
  else
    x = xx;
    8000043e:	4881                	li	a7,0
    80000440:	fd040693          	addi	a3,s0,-48

  i = 0;
    80000444:	4781                	li	a5,0
  do {
    buf[i++] = digits[x % base];
    80000446:	00007617          	auipc	a2,0x7
    8000044a:	3b260613          	addi	a2,a2,946 # 800077f8 <digits>
    8000044e:	883e                	mv	a6,a5
    80000450:	2785                	addiw	a5,a5,1
    80000452:	02b57733          	remu	a4,a0,a1
    80000456:	9732                	add	a4,a4,a2
    80000458:	00074703          	lbu	a4,0(a4)
    8000045c:	00e68023          	sb	a4,0(a3)
  } while((x /= base) != 0);
    80000460:	872a                	mv	a4,a0
    80000462:	02b55533          	divu	a0,a0,a1
    80000466:	0685                	addi	a3,a3,1
    80000468:	feb773e3          	bgeu	a4,a1,8000044e <printint+0x1e>

  if(sign)
    8000046c:	00088a63          	beqz	a7,80000480 <printint+0x50>
    buf[i++] = '-';
    80000470:	1781                	addi	a5,a5,-32
    80000472:	97a2                	add	a5,a5,s0
    80000474:	02d00713          	li	a4,45
    80000478:	fee78823          	sb	a4,-16(a5)
    8000047c:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
    80000480:	02f05963          	blez	a5,800004b2 <printint+0x82>
    80000484:	ec26                	sd	s1,24(sp)
    80000486:	e84a                	sd	s2,16(sp)
    80000488:	fd040713          	addi	a4,s0,-48
    8000048c:	00f704b3          	add	s1,a4,a5
    80000490:	fff70913          	addi	s2,a4,-1
    80000494:	993e                	add	s2,s2,a5
    80000496:	37fd                	addiw	a5,a5,-1
    80000498:	1782                	slli	a5,a5,0x20
    8000049a:	9381                	srli	a5,a5,0x20
    8000049c:	40f90933          	sub	s2,s2,a5
    consputc(buf[i]);
    800004a0:	fff4c503          	lbu	a0,-1(s1)
    800004a4:	d9dff0ef          	jal	80000240 <consputc>
  while(--i >= 0)
    800004a8:	14fd                	addi	s1,s1,-1
    800004aa:	ff249be3          	bne	s1,s2,800004a0 <printint+0x70>
    800004ae:	64e2                	ld	s1,24(sp)
    800004b0:	6942                	ld	s2,16(sp)
}
    800004b2:	70a2                	ld	ra,40(sp)
    800004b4:	7402                	ld	s0,32(sp)
    800004b6:	6145                	addi	sp,sp,48
    800004b8:	8082                	ret
    x = -xx;
    800004ba:	40a00533          	neg	a0,a0
  if(sign && (sign = (xx < 0)))
    800004be:	4885                	li	a7,1
    x = -xx;
    800004c0:	b741                	j	80000440 <printint+0x10>

00000000800004c2 <printf>:
}

// Print to the console.
int
printf(char *fmt, ...)
{
    800004c2:	7155                	addi	sp,sp,-208
    800004c4:	e506                	sd	ra,136(sp)
    800004c6:	e122                	sd	s0,128(sp)
    800004c8:	f0d2                	sd	s4,96(sp)
    800004ca:	0900                	addi	s0,sp,144
    800004cc:	8a2a                	mv	s4,a0
    800004ce:	e40c                	sd	a1,8(s0)
    800004d0:	e810                	sd	a2,16(s0)
    800004d2:	ec14                	sd	a3,24(s0)
    800004d4:	f018                	sd	a4,32(s0)
    800004d6:	f41c                	sd	a5,40(s0)
    800004d8:	03043823          	sd	a6,48(s0)
    800004dc:	03143c23          	sd	a7,56(s0)
  va_list ap;
  int i, cx, c0, c1, c2, locking;
  char *s;

  locking = pr.locking;
    800004e0:	00012797          	auipc	a5,0x12
    800004e4:	fa07a783          	lw	a5,-96(a5) # 80012480 <pr+0x18>
    800004e8:	f6f43c23          	sd	a5,-136(s0)
  if(locking)
    800004ec:	e3a1                	bnez	a5,8000052c <printf+0x6a>
    acquire(&pr.lock);

  va_start(ap, fmt);
    800004ee:	00840793          	addi	a5,s0,8
    800004f2:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    800004f6:	00054503          	lbu	a0,0(a0)
    800004fa:	26050763          	beqz	a0,80000768 <printf+0x2a6>
    800004fe:	fca6                	sd	s1,120(sp)
    80000500:	f8ca                	sd	s2,112(sp)
    80000502:	f4ce                	sd	s3,104(sp)
    80000504:	ecd6                	sd	s5,88(sp)
    80000506:	e8da                	sd	s6,80(sp)
    80000508:	e0e2                	sd	s8,64(sp)
    8000050a:	fc66                	sd	s9,56(sp)
    8000050c:	f86a                	sd	s10,48(sp)
    8000050e:	f46e                	sd	s11,40(sp)
    80000510:	4981                	li	s3,0
    if(cx != '%'){
    80000512:	02500a93          	li	s5,37
    i++;
    c0 = fmt[i+0] & 0xff;
    c1 = c2 = 0;
    if(c0) c1 = fmt[i+1] & 0xff;
    if(c1) c2 = fmt[i+2] & 0xff;
    if(c0 == 'd'){
    80000516:	06400b13          	li	s6,100
      printint(va_arg(ap, int), 10, 1);
    } else if(c0 == 'l' && c1 == 'd'){
    8000051a:	06c00c13          	li	s8,108
      printint(va_arg(ap, uint64), 10, 1);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
      printint(va_arg(ap, uint64), 10, 1);
      i += 2;
    } else if(c0 == 'u'){
    8000051e:	07500c93          	li	s9,117
      printint(va_arg(ap, uint64), 10, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
      printint(va_arg(ap, uint64), 10, 0);
      i += 2;
    } else if(c0 == 'x'){
    80000522:	07800d13          	li	s10,120
      printint(va_arg(ap, uint64), 16, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
      printint(va_arg(ap, uint64), 16, 0);
      i += 2;
    } else if(c0 == 'p'){
    80000526:	07000d93          	li	s11,112
    8000052a:	a815                	j	8000055e <printf+0x9c>
    acquire(&pr.lock);
    8000052c:	00012517          	auipc	a0,0x12
    80000530:	f3c50513          	addi	a0,a0,-196 # 80012468 <pr>
    80000534:	6c0000ef          	jal	80000bf4 <acquire>
  va_start(ap, fmt);
    80000538:	00840793          	addi	a5,s0,8
    8000053c:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    80000540:	000a4503          	lbu	a0,0(s4)
    80000544:	fd4d                	bnez	a0,800004fe <printf+0x3c>
    80000546:	a481                	j	80000786 <printf+0x2c4>
      consputc(cx);
    80000548:	cf9ff0ef          	jal	80000240 <consputc>
      continue;
    8000054c:	84ce                	mv	s1,s3
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    8000054e:	0014899b          	addiw	s3,s1,1
    80000552:	013a07b3          	add	a5,s4,s3
    80000556:	0007c503          	lbu	a0,0(a5)
    8000055a:	1e050b63          	beqz	a0,80000750 <printf+0x28e>
    if(cx != '%'){
    8000055e:	ff5515e3          	bne	a0,s5,80000548 <printf+0x86>
    i++;
    80000562:	0019849b          	addiw	s1,s3,1
    c0 = fmt[i+0] & 0xff;
    80000566:	009a07b3          	add	a5,s4,s1
    8000056a:	0007c903          	lbu	s2,0(a5)
    if(c0) c1 = fmt[i+1] & 0xff;
    8000056e:	1e090163          	beqz	s2,80000750 <printf+0x28e>
    80000572:	0017c783          	lbu	a5,1(a5)
    c1 = c2 = 0;
    80000576:	86be                	mv	a3,a5
    if(c1) c2 = fmt[i+2] & 0xff;
    80000578:	c789                	beqz	a5,80000582 <printf+0xc0>
    8000057a:	009a0733          	add	a4,s4,s1
    8000057e:	00274683          	lbu	a3,2(a4)
    if(c0 == 'd'){
    80000582:	03690763          	beq	s2,s6,800005b0 <printf+0xee>
    } else if(c0 == 'l' && c1 == 'd'){
    80000586:	05890163          	beq	s2,s8,800005c8 <printf+0x106>
    } else if(c0 == 'u'){
    8000058a:	0d990b63          	beq	s2,s9,80000660 <printf+0x19e>
    } else if(c0 == 'x'){
    8000058e:	13a90163          	beq	s2,s10,800006b0 <printf+0x1ee>
    } else if(c0 == 'p'){
    80000592:	13b90b63          	beq	s2,s11,800006c8 <printf+0x206>
      printptr(va_arg(ap, uint64));
    } else if(c0 == 's'){
    80000596:	07300793          	li	a5,115
    8000059a:	16f90a63          	beq	s2,a5,8000070e <printf+0x24c>
      if((s = va_arg(ap, char*)) == 0)
        s = "(null)";
      for(; *s; s++)
        consputc(*s);
    } else if(c0 == '%'){
    8000059e:	1b590463          	beq	s2,s5,80000746 <printf+0x284>
      consputc('%');
    } else if(c0 == 0){
      break;
    } else {
      // Print unknown % sequence to draw attention.
      consputc('%');
    800005a2:	8556                	mv	a0,s5
    800005a4:	c9dff0ef          	jal	80000240 <consputc>
      consputc(c0);
    800005a8:	854a                	mv	a0,s2
    800005aa:	c97ff0ef          	jal	80000240 <consputc>
    800005ae:	b745                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, int), 10, 1);
    800005b0:	f8843783          	ld	a5,-120(s0)
    800005b4:	00878713          	addi	a4,a5,8
    800005b8:	f8e43423          	sd	a4,-120(s0)
    800005bc:	4605                	li	a2,1
    800005be:	45a9                	li	a1,10
    800005c0:	4388                	lw	a0,0(a5)
    800005c2:	e6fff0ef          	jal	80000430 <printint>
    800005c6:	b761                	j	8000054e <printf+0x8c>
    } else if(c0 == 'l' && c1 == 'd'){
    800005c8:	03678663          	beq	a5,s6,800005f4 <printf+0x132>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    800005cc:	05878263          	beq	a5,s8,80000610 <printf+0x14e>
    } else if(c0 == 'l' && c1 == 'u'){
    800005d0:	0b978463          	beq	a5,s9,80000678 <printf+0x1b6>
    } else if(c0 == 'l' && c1 == 'x'){
    800005d4:	fda797e3          	bne	a5,s10,800005a2 <printf+0xe0>
      printint(va_arg(ap, uint64), 16, 0);
    800005d8:	f8843783          	ld	a5,-120(s0)
    800005dc:	00878713          	addi	a4,a5,8
    800005e0:	f8e43423          	sd	a4,-120(s0)
    800005e4:	4601                	li	a2,0
    800005e6:	45c1                	li	a1,16
    800005e8:	6388                	ld	a0,0(a5)
    800005ea:	e47ff0ef          	jal	80000430 <printint>
      i += 1;
    800005ee:	0029849b          	addiw	s1,s3,2
    800005f2:	bfb1                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 1);
    800005f4:	f8843783          	ld	a5,-120(s0)
    800005f8:	00878713          	addi	a4,a5,8
    800005fc:	f8e43423          	sd	a4,-120(s0)
    80000600:	4605                	li	a2,1
    80000602:	45a9                	li	a1,10
    80000604:	6388                	ld	a0,0(a5)
    80000606:	e2bff0ef          	jal	80000430 <printint>
      i += 1;
    8000060a:	0029849b          	addiw	s1,s3,2
    8000060e:	b781                	j	8000054e <printf+0x8c>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    80000610:	06400793          	li	a5,100
    80000614:	02f68863          	beq	a3,a5,80000644 <printf+0x182>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    80000618:	07500793          	li	a5,117
    8000061c:	06f68c63          	beq	a3,a5,80000694 <printf+0x1d2>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
    80000620:	07800793          	li	a5,120
    80000624:	f6f69fe3          	bne	a3,a5,800005a2 <printf+0xe0>
      printint(va_arg(ap, uint64), 16, 0);
    80000628:	f8843783          	ld	a5,-120(s0)
    8000062c:	00878713          	addi	a4,a5,8
    80000630:	f8e43423          	sd	a4,-120(s0)
    80000634:	4601                	li	a2,0
    80000636:	45c1                	li	a1,16
    80000638:	6388                	ld	a0,0(a5)
    8000063a:	df7ff0ef          	jal	80000430 <printint>
      i += 2;
    8000063e:	0039849b          	addiw	s1,s3,3
    80000642:	b731                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 1);
    80000644:	f8843783          	ld	a5,-120(s0)
    80000648:	00878713          	addi	a4,a5,8
    8000064c:	f8e43423          	sd	a4,-120(s0)
    80000650:	4605                	li	a2,1
    80000652:	45a9                	li	a1,10
    80000654:	6388                	ld	a0,0(a5)
    80000656:	ddbff0ef          	jal	80000430 <printint>
      i += 2;
    8000065a:	0039849b          	addiw	s1,s3,3
    8000065e:	bdc5                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, int), 10, 0);
    80000660:	f8843783          	ld	a5,-120(s0)
    80000664:	00878713          	addi	a4,a5,8
    80000668:	f8e43423          	sd	a4,-120(s0)
    8000066c:	4601                	li	a2,0
    8000066e:	45a9                	li	a1,10
    80000670:	4388                	lw	a0,0(a5)
    80000672:	dbfff0ef          	jal	80000430 <printint>
    80000676:	bde1                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 0);
    80000678:	f8843783          	ld	a5,-120(s0)
    8000067c:	00878713          	addi	a4,a5,8
    80000680:	f8e43423          	sd	a4,-120(s0)
    80000684:	4601                	li	a2,0
    80000686:	45a9                	li	a1,10
    80000688:	6388                	ld	a0,0(a5)
    8000068a:	da7ff0ef          	jal	80000430 <printint>
      i += 1;
    8000068e:	0029849b          	addiw	s1,s3,2
    80000692:	bd75                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 0);
    80000694:	f8843783          	ld	a5,-120(s0)
    80000698:	00878713          	addi	a4,a5,8
    8000069c:	f8e43423          	sd	a4,-120(s0)
    800006a0:	4601                	li	a2,0
    800006a2:	45a9                	li	a1,10
    800006a4:	6388                	ld	a0,0(a5)
    800006a6:	d8bff0ef          	jal	80000430 <printint>
      i += 2;
    800006aa:	0039849b          	addiw	s1,s3,3
    800006ae:	b545                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, int), 16, 0);
    800006b0:	f8843783          	ld	a5,-120(s0)
    800006b4:	00878713          	addi	a4,a5,8
    800006b8:	f8e43423          	sd	a4,-120(s0)
    800006bc:	4601                	li	a2,0
    800006be:	45c1                	li	a1,16
    800006c0:	4388                	lw	a0,0(a5)
    800006c2:	d6fff0ef          	jal	80000430 <printint>
    800006c6:	b561                	j	8000054e <printf+0x8c>
    800006c8:	e4de                	sd	s7,72(sp)
      printptr(va_arg(ap, uint64));
    800006ca:	f8843783          	ld	a5,-120(s0)
    800006ce:	00878713          	addi	a4,a5,8
    800006d2:	f8e43423          	sd	a4,-120(s0)
    800006d6:	0007b983          	ld	s3,0(a5)
  consputc('0');
    800006da:	03000513          	li	a0,48
    800006de:	b63ff0ef          	jal	80000240 <consputc>
  consputc('x');
    800006e2:	07800513          	li	a0,120
    800006e6:	b5bff0ef          	jal	80000240 <consputc>
    800006ea:	4941                	li	s2,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006ec:	00007b97          	auipc	s7,0x7
    800006f0:	10cb8b93          	addi	s7,s7,268 # 800077f8 <digits>
    800006f4:	03c9d793          	srli	a5,s3,0x3c
    800006f8:	97de                	add	a5,a5,s7
    800006fa:	0007c503          	lbu	a0,0(a5)
    800006fe:	b43ff0ef          	jal	80000240 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    80000702:	0992                	slli	s3,s3,0x4
    80000704:	397d                	addiw	s2,s2,-1
    80000706:	fe0917e3          	bnez	s2,800006f4 <printf+0x232>
    8000070a:	6ba6                	ld	s7,72(sp)
    8000070c:	b589                	j	8000054e <printf+0x8c>
      if((s = va_arg(ap, char*)) == 0)
    8000070e:	f8843783          	ld	a5,-120(s0)
    80000712:	00878713          	addi	a4,a5,8
    80000716:	f8e43423          	sd	a4,-120(s0)
    8000071a:	0007b903          	ld	s2,0(a5)
    8000071e:	00090d63          	beqz	s2,80000738 <printf+0x276>
      for(; *s; s++)
    80000722:	00094503          	lbu	a0,0(s2)
    80000726:	e20504e3          	beqz	a0,8000054e <printf+0x8c>
        consputc(*s);
    8000072a:	b17ff0ef          	jal	80000240 <consputc>
      for(; *s; s++)
    8000072e:	0905                	addi	s2,s2,1
    80000730:	00094503          	lbu	a0,0(s2)
    80000734:	f97d                	bnez	a0,8000072a <printf+0x268>
    80000736:	bd21                	j	8000054e <printf+0x8c>
        s = "(null)";
    80000738:	00007917          	auipc	s2,0x7
    8000073c:	8d090913          	addi	s2,s2,-1840 # 80007008 <etext+0x8>
      for(; *s; s++)
    80000740:	02800513          	li	a0,40
    80000744:	b7dd                	j	8000072a <printf+0x268>
      consputc('%');
    80000746:	02500513          	li	a0,37
    8000074a:	af7ff0ef          	jal	80000240 <consputc>
    8000074e:	b501                	j	8000054e <printf+0x8c>
    }
#endif
  }
  va_end(ap);

  if(locking)
    80000750:	f7843783          	ld	a5,-136(s0)
    80000754:	e385                	bnez	a5,80000774 <printf+0x2b2>
    80000756:	74e6                	ld	s1,120(sp)
    80000758:	7946                	ld	s2,112(sp)
    8000075a:	79a6                	ld	s3,104(sp)
    8000075c:	6ae6                	ld	s5,88(sp)
    8000075e:	6b46                	ld	s6,80(sp)
    80000760:	6c06                	ld	s8,64(sp)
    80000762:	7ce2                	ld	s9,56(sp)
    80000764:	7d42                	ld	s10,48(sp)
    80000766:	7da2                	ld	s11,40(sp)
    release(&pr.lock);

  return 0;
}
    80000768:	4501                	li	a0,0
    8000076a:	60aa                	ld	ra,136(sp)
    8000076c:	640a                	ld	s0,128(sp)
    8000076e:	7a06                	ld	s4,96(sp)
    80000770:	6169                	addi	sp,sp,208
    80000772:	8082                	ret
    80000774:	74e6                	ld	s1,120(sp)
    80000776:	7946                	ld	s2,112(sp)
    80000778:	79a6                	ld	s3,104(sp)
    8000077a:	6ae6                	ld	s5,88(sp)
    8000077c:	6b46                	ld	s6,80(sp)
    8000077e:	6c06                	ld	s8,64(sp)
    80000780:	7ce2                	ld	s9,56(sp)
    80000782:	7d42                	ld	s10,48(sp)
    80000784:	7da2                	ld	s11,40(sp)
    release(&pr.lock);
    80000786:	00012517          	auipc	a0,0x12
    8000078a:	ce250513          	addi	a0,a0,-798 # 80012468 <pr>
    8000078e:	4fe000ef          	jal	80000c8c <release>
    80000792:	bfd9                	j	80000768 <printf+0x2a6>

0000000080000794 <panic>:

void
panic(char *s)
{
    80000794:	1101                	addi	sp,sp,-32
    80000796:	ec06                	sd	ra,24(sp)
    80000798:	e822                	sd	s0,16(sp)
    8000079a:	e426                	sd	s1,8(sp)
    8000079c:	1000                	addi	s0,sp,32
    8000079e:	84aa                	mv	s1,a0
  pr.locking = 0;
    800007a0:	00012797          	auipc	a5,0x12
    800007a4:	ce07a023          	sw	zero,-800(a5) # 80012480 <pr+0x18>
  printf("panic: ");
    800007a8:	00007517          	auipc	a0,0x7
    800007ac:	87050513          	addi	a0,a0,-1936 # 80007018 <etext+0x18>
    800007b0:	d13ff0ef          	jal	800004c2 <printf>
  printf("%s\n", s);
    800007b4:	85a6                	mv	a1,s1
    800007b6:	00007517          	auipc	a0,0x7
    800007ba:	86a50513          	addi	a0,a0,-1942 # 80007020 <etext+0x20>
    800007be:	d05ff0ef          	jal	800004c2 <printf>
  panicked = 1; // freeze uart output from other CPUs
    800007c2:	4785                	li	a5,1
    800007c4:	0000a717          	auipc	a4,0xa
    800007c8:	baf72e23          	sw	a5,-1092(a4) # 8000a380 <panicked>
  for(;;)
    800007cc:	a001                	j	800007cc <panic+0x38>

00000000800007ce <printfinit>:
    ;
}

void
printfinit(void)
{
    800007ce:	1101                	addi	sp,sp,-32
    800007d0:	ec06                	sd	ra,24(sp)
    800007d2:	e822                	sd	s0,16(sp)
    800007d4:	e426                	sd	s1,8(sp)
    800007d6:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    800007d8:	00012497          	auipc	s1,0x12
    800007dc:	c9048493          	addi	s1,s1,-880 # 80012468 <pr>
    800007e0:	00007597          	auipc	a1,0x7
    800007e4:	84858593          	addi	a1,a1,-1976 # 80007028 <etext+0x28>
    800007e8:	8526                	mv	a0,s1
    800007ea:	38a000ef          	jal	80000b74 <initlock>
  pr.locking = 1;
    800007ee:	4785                	li	a5,1
    800007f0:	cc9c                	sw	a5,24(s1)
}
    800007f2:	60e2                	ld	ra,24(sp)
    800007f4:	6442                	ld	s0,16(sp)
    800007f6:	64a2                	ld	s1,8(sp)
    800007f8:	6105                	addi	sp,sp,32
    800007fa:	8082                	ret

00000000800007fc <uartinit>:

void uartstart();

void
uartinit(void)
{
    800007fc:	1141                	addi	sp,sp,-16
    800007fe:	e406                	sd	ra,8(sp)
    80000800:	e022                	sd	s0,0(sp)
    80000802:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    80000804:	100007b7          	lui	a5,0x10000
    80000808:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    8000080c:	10000737          	lui	a4,0x10000
    80000810:	f8000693          	li	a3,-128
    80000814:	00d701a3          	sb	a3,3(a4) # 10000003 <_entry-0x6ffffffd>

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    80000818:	468d                	li	a3,3
    8000081a:	10000637          	lui	a2,0x10000
    8000081e:	00d60023          	sb	a3,0(a2) # 10000000 <_entry-0x70000000>

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    80000822:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    80000826:	00d701a3          	sb	a3,3(a4)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    8000082a:	10000737          	lui	a4,0x10000
    8000082e:	461d                	li	a2,7
    80000830:	00c70123          	sb	a2,2(a4) # 10000002 <_entry-0x6ffffffe>

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    80000834:	00d780a3          	sb	a3,1(a5)

  initlock(&uart_tx_lock, "uart");
    80000838:	00006597          	auipc	a1,0x6
    8000083c:	7f858593          	addi	a1,a1,2040 # 80007030 <etext+0x30>
    80000840:	00012517          	auipc	a0,0x12
    80000844:	c4850513          	addi	a0,a0,-952 # 80012488 <uart_tx_lock>
    80000848:	32c000ef          	jal	80000b74 <initlock>
}
    8000084c:	60a2                	ld	ra,8(sp)
    8000084e:	6402                	ld	s0,0(sp)
    80000850:	0141                	addi	sp,sp,16
    80000852:	8082                	ret

0000000080000854 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    80000854:	1101                	addi	sp,sp,-32
    80000856:	ec06                	sd	ra,24(sp)
    80000858:	e822                	sd	s0,16(sp)
    8000085a:	e426                	sd	s1,8(sp)
    8000085c:	1000                	addi	s0,sp,32
    8000085e:	84aa                	mv	s1,a0
  push_off();
    80000860:	354000ef          	jal	80000bb4 <push_off>

  if(panicked){
    80000864:	0000a797          	auipc	a5,0xa
    80000868:	b1c7a783          	lw	a5,-1252(a5) # 8000a380 <panicked>
    8000086c:	e795                	bnez	a5,80000898 <uartputc_sync+0x44>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000086e:	10000737          	lui	a4,0x10000
    80000872:	0715                	addi	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    80000874:	00074783          	lbu	a5,0(a4)
    80000878:	0207f793          	andi	a5,a5,32
    8000087c:	dfe5                	beqz	a5,80000874 <uartputc_sync+0x20>
    ;
  WriteReg(THR, c);
    8000087e:	0ff4f513          	zext.b	a0,s1
    80000882:	100007b7          	lui	a5,0x10000
    80000886:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    8000088a:	3ae000ef          	jal	80000c38 <pop_off>
}
    8000088e:	60e2                	ld	ra,24(sp)
    80000890:	6442                	ld	s0,16(sp)
    80000892:	64a2                	ld	s1,8(sp)
    80000894:	6105                	addi	sp,sp,32
    80000896:	8082                	ret
    for(;;)
    80000898:	a001                	j	80000898 <uartputc_sync+0x44>

000000008000089a <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    8000089a:	0000a797          	auipc	a5,0xa
    8000089e:	aee7b783          	ld	a5,-1298(a5) # 8000a388 <uart_tx_r>
    800008a2:	0000a717          	auipc	a4,0xa
    800008a6:	aee73703          	ld	a4,-1298(a4) # 8000a390 <uart_tx_w>
    800008aa:	08f70263          	beq	a4,a5,8000092e <uartstart+0x94>
{
    800008ae:	7139                	addi	sp,sp,-64
    800008b0:	fc06                	sd	ra,56(sp)
    800008b2:	f822                	sd	s0,48(sp)
    800008b4:	f426                	sd	s1,40(sp)
    800008b6:	f04a                	sd	s2,32(sp)
    800008b8:	ec4e                	sd	s3,24(sp)
    800008ba:	e852                	sd	s4,16(sp)
    800008bc:	e456                	sd	s5,8(sp)
    800008be:	e05a                	sd	s6,0(sp)
    800008c0:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      ReadReg(ISR);
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800008c2:	10000937          	lui	s2,0x10000
    800008c6:	0915                	addi	s2,s2,5 # 10000005 <_entry-0x6ffffffb>
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800008c8:	00012a97          	auipc	s5,0x12
    800008cc:	bc0a8a93          	addi	s5,s5,-1088 # 80012488 <uart_tx_lock>
    uart_tx_r += 1;
    800008d0:	0000a497          	auipc	s1,0xa
    800008d4:	ab848493          	addi	s1,s1,-1352 # 8000a388 <uart_tx_r>
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    
    WriteReg(THR, c);
    800008d8:	10000a37          	lui	s4,0x10000
    if(uart_tx_w == uart_tx_r){
    800008dc:	0000a997          	auipc	s3,0xa
    800008e0:	ab498993          	addi	s3,s3,-1356 # 8000a390 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800008e4:	00094703          	lbu	a4,0(s2)
    800008e8:	02077713          	andi	a4,a4,32
    800008ec:	c71d                	beqz	a4,8000091a <uartstart+0x80>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800008ee:	01f7f713          	andi	a4,a5,31
    800008f2:	9756                	add	a4,a4,s5
    800008f4:	01874b03          	lbu	s6,24(a4)
    uart_tx_r += 1;
    800008f8:	0785                	addi	a5,a5,1
    800008fa:	e09c                	sd	a5,0(s1)
    wakeup(&uart_tx_r);
    800008fc:	8526                	mv	a0,s1
    800008fe:	5fc010ef          	jal	80001efa <wakeup>
    WriteReg(THR, c);
    80000902:	016a0023          	sb	s6,0(s4) # 10000000 <_entry-0x70000000>
    if(uart_tx_w == uart_tx_r){
    80000906:	609c                	ld	a5,0(s1)
    80000908:	0009b703          	ld	a4,0(s3)
    8000090c:	fcf71ce3          	bne	a4,a5,800008e4 <uartstart+0x4a>
      ReadReg(ISR);
    80000910:	100007b7          	lui	a5,0x10000
    80000914:	0789                	addi	a5,a5,2 # 10000002 <_entry-0x6ffffffe>
    80000916:	0007c783          	lbu	a5,0(a5)
  }
}
    8000091a:	70e2                	ld	ra,56(sp)
    8000091c:	7442                	ld	s0,48(sp)
    8000091e:	74a2                	ld	s1,40(sp)
    80000920:	7902                	ld	s2,32(sp)
    80000922:	69e2                	ld	s3,24(sp)
    80000924:	6a42                	ld	s4,16(sp)
    80000926:	6aa2                	ld	s5,8(sp)
    80000928:	6b02                	ld	s6,0(sp)
    8000092a:	6121                	addi	sp,sp,64
    8000092c:	8082                	ret
      ReadReg(ISR);
    8000092e:	100007b7          	lui	a5,0x10000
    80000932:	0789                	addi	a5,a5,2 # 10000002 <_entry-0x6ffffffe>
    80000934:	0007c783          	lbu	a5,0(a5)
      return;
    80000938:	8082                	ret

000000008000093a <uartputc>:
{
    8000093a:	7179                	addi	sp,sp,-48
    8000093c:	f406                	sd	ra,40(sp)
    8000093e:	f022                	sd	s0,32(sp)
    80000940:	ec26                	sd	s1,24(sp)
    80000942:	e84a                	sd	s2,16(sp)
    80000944:	e44e                	sd	s3,8(sp)
    80000946:	e052                	sd	s4,0(sp)
    80000948:	1800                	addi	s0,sp,48
    8000094a:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    8000094c:	00012517          	auipc	a0,0x12
    80000950:	b3c50513          	addi	a0,a0,-1220 # 80012488 <uart_tx_lock>
    80000954:	2a0000ef          	jal	80000bf4 <acquire>
  if(panicked){
    80000958:	0000a797          	auipc	a5,0xa
    8000095c:	a287a783          	lw	a5,-1496(a5) # 8000a380 <panicked>
    80000960:	efbd                	bnez	a5,800009de <uartputc+0xa4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000962:	0000a717          	auipc	a4,0xa
    80000966:	a2e73703          	ld	a4,-1490(a4) # 8000a390 <uart_tx_w>
    8000096a:	0000a797          	auipc	a5,0xa
    8000096e:	a1e7b783          	ld	a5,-1506(a5) # 8000a388 <uart_tx_r>
    80000972:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    80000976:	00012997          	auipc	s3,0x12
    8000097a:	b1298993          	addi	s3,s3,-1262 # 80012488 <uart_tx_lock>
    8000097e:	0000a497          	auipc	s1,0xa
    80000982:	a0a48493          	addi	s1,s1,-1526 # 8000a388 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000986:	0000a917          	auipc	s2,0xa
    8000098a:	a0a90913          	addi	s2,s2,-1526 # 8000a390 <uart_tx_w>
    8000098e:	00e79d63          	bne	a5,a4,800009a8 <uartputc+0x6e>
    sleep(&uart_tx_r, &uart_tx_lock);
    80000992:	85ce                	mv	a1,s3
    80000994:	8526                	mv	a0,s1
    80000996:	518010ef          	jal	80001eae <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000099a:	00093703          	ld	a4,0(s2)
    8000099e:	609c                	ld	a5,0(s1)
    800009a0:	02078793          	addi	a5,a5,32
    800009a4:	fee787e3          	beq	a5,a4,80000992 <uartputc+0x58>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    800009a8:	00012497          	auipc	s1,0x12
    800009ac:	ae048493          	addi	s1,s1,-1312 # 80012488 <uart_tx_lock>
    800009b0:	01f77793          	andi	a5,a4,31
    800009b4:	97a6                	add	a5,a5,s1
    800009b6:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    800009ba:	0705                	addi	a4,a4,1
    800009bc:	0000a797          	auipc	a5,0xa
    800009c0:	9ce7ba23          	sd	a4,-1580(a5) # 8000a390 <uart_tx_w>
  uartstart();
    800009c4:	ed7ff0ef          	jal	8000089a <uartstart>
  release(&uart_tx_lock);
    800009c8:	8526                	mv	a0,s1
    800009ca:	2c2000ef          	jal	80000c8c <release>
}
    800009ce:	70a2                	ld	ra,40(sp)
    800009d0:	7402                	ld	s0,32(sp)
    800009d2:	64e2                	ld	s1,24(sp)
    800009d4:	6942                	ld	s2,16(sp)
    800009d6:	69a2                	ld	s3,8(sp)
    800009d8:	6a02                	ld	s4,0(sp)
    800009da:	6145                	addi	sp,sp,48
    800009dc:	8082                	ret
    for(;;)
    800009de:	a001                	j	800009de <uartputc+0xa4>

00000000800009e0 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    800009e0:	1141                	addi	sp,sp,-16
    800009e2:	e422                	sd	s0,8(sp)
    800009e4:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    800009e6:	100007b7          	lui	a5,0x10000
    800009ea:	0795                	addi	a5,a5,5 # 10000005 <_entry-0x6ffffffb>
    800009ec:	0007c783          	lbu	a5,0(a5)
    800009f0:	8b85                	andi	a5,a5,1
    800009f2:	cb81                	beqz	a5,80000a02 <uartgetc+0x22>
    // input data is ready.
    return ReadReg(RHR);
    800009f4:	100007b7          	lui	a5,0x10000
    800009f8:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    800009fc:	6422                	ld	s0,8(sp)
    800009fe:	0141                	addi	sp,sp,16
    80000a00:	8082                	ret
    return -1;
    80000a02:	557d                	li	a0,-1
    80000a04:	bfe5                	j	800009fc <uartgetc+0x1c>

0000000080000a06 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    80000a06:	1101                	addi	sp,sp,-32
    80000a08:	ec06                	sd	ra,24(sp)
    80000a0a:	e822                	sd	s0,16(sp)
    80000a0c:	e426                	sd	s1,8(sp)
    80000a0e:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    80000a10:	54fd                	li	s1,-1
    80000a12:	a019                	j	80000a18 <uartintr+0x12>
      break;
    consoleintr(c);
    80000a14:	85fff0ef          	jal	80000272 <consoleintr>
    int c = uartgetc();
    80000a18:	fc9ff0ef          	jal	800009e0 <uartgetc>
    if(c == -1)
    80000a1c:	fe951ce3          	bne	a0,s1,80000a14 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    80000a20:	00012497          	auipc	s1,0x12
    80000a24:	a6848493          	addi	s1,s1,-1432 # 80012488 <uart_tx_lock>
    80000a28:	8526                	mv	a0,s1
    80000a2a:	1ca000ef          	jal	80000bf4 <acquire>
  uartstart();
    80000a2e:	e6dff0ef          	jal	8000089a <uartstart>
  release(&uart_tx_lock);
    80000a32:	8526                	mv	a0,s1
    80000a34:	258000ef          	jal	80000c8c <release>
}
    80000a38:	60e2                	ld	ra,24(sp)
    80000a3a:	6442                	ld	s0,16(sp)
    80000a3c:	64a2                	ld	s1,8(sp)
    80000a3e:	6105                	addi	sp,sp,32
    80000a40:	8082                	ret

0000000080000a42 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000a42:	1101                	addi	sp,sp,-32
    80000a44:	ec06                	sd	ra,24(sp)
    80000a46:	e822                	sd	s0,16(sp)
    80000a48:	e426                	sd	s1,8(sp)
    80000a4a:	e04a                	sd	s2,0(sp)
    80000a4c:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a4e:	03451793          	slli	a5,a0,0x34
    80000a52:	e7a9                	bnez	a5,80000a9c <kfree+0x5a>
    80000a54:	84aa                	mv	s1,a0
    80000a56:	00029797          	auipc	a5,0x29
    80000a5a:	ab278793          	addi	a5,a5,-1358 # 80029508 <end>
    80000a5e:	02f56f63          	bltu	a0,a5,80000a9c <kfree+0x5a>
    80000a62:	47c5                	li	a5,17
    80000a64:	07ee                	slli	a5,a5,0x1b
    80000a66:	02f57b63          	bgeu	a0,a5,80000a9c <kfree+0x5a>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a6a:	6605                	lui	a2,0x1
    80000a6c:	4585                	li	a1,1
    80000a6e:	25a000ef          	jal	80000cc8 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a72:	00012917          	auipc	s2,0x12
    80000a76:	a4e90913          	addi	s2,s2,-1458 # 800124c0 <kmem>
    80000a7a:	854a                	mv	a0,s2
    80000a7c:	178000ef          	jal	80000bf4 <acquire>
  r->next = kmem.freelist;
    80000a80:	01893783          	ld	a5,24(s2)
    80000a84:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a86:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a8a:	854a                	mv	a0,s2
    80000a8c:	200000ef          	jal	80000c8c <release>
}
    80000a90:	60e2                	ld	ra,24(sp)
    80000a92:	6442                	ld	s0,16(sp)
    80000a94:	64a2                	ld	s1,8(sp)
    80000a96:	6902                	ld	s2,0(sp)
    80000a98:	6105                	addi	sp,sp,32
    80000a9a:	8082                	ret
    panic("kfree");
    80000a9c:	00006517          	auipc	a0,0x6
    80000aa0:	59c50513          	addi	a0,a0,1436 # 80007038 <etext+0x38>
    80000aa4:	cf1ff0ef          	jal	80000794 <panic>

0000000080000aa8 <freerange>:
{
    80000aa8:	7179                	addi	sp,sp,-48
    80000aaa:	f406                	sd	ra,40(sp)
    80000aac:	f022                	sd	s0,32(sp)
    80000aae:	ec26                	sd	s1,24(sp)
    80000ab0:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000ab2:	6785                	lui	a5,0x1
    80000ab4:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000ab8:	00e504b3          	add	s1,a0,a4
    80000abc:	777d                	lui	a4,0xfffff
    80000abe:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ac0:	94be                	add	s1,s1,a5
    80000ac2:	0295e263          	bltu	a1,s1,80000ae6 <freerange+0x3e>
    80000ac6:	e84a                	sd	s2,16(sp)
    80000ac8:	e44e                	sd	s3,8(sp)
    80000aca:	e052                	sd	s4,0(sp)
    80000acc:	892e                	mv	s2,a1
    kfree(p);
    80000ace:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ad0:	6985                	lui	s3,0x1
    kfree(p);
    80000ad2:	01448533          	add	a0,s1,s4
    80000ad6:	f6dff0ef          	jal	80000a42 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ada:	94ce                	add	s1,s1,s3
    80000adc:	fe997be3          	bgeu	s2,s1,80000ad2 <freerange+0x2a>
    80000ae0:	6942                	ld	s2,16(sp)
    80000ae2:	69a2                	ld	s3,8(sp)
    80000ae4:	6a02                	ld	s4,0(sp)
}
    80000ae6:	70a2                	ld	ra,40(sp)
    80000ae8:	7402                	ld	s0,32(sp)
    80000aea:	64e2                	ld	s1,24(sp)
    80000aec:	6145                	addi	sp,sp,48
    80000aee:	8082                	ret

0000000080000af0 <kinit>:
{
    80000af0:	1141                	addi	sp,sp,-16
    80000af2:	e406                	sd	ra,8(sp)
    80000af4:	e022                	sd	s0,0(sp)
    80000af6:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000af8:	00006597          	auipc	a1,0x6
    80000afc:	54858593          	addi	a1,a1,1352 # 80007040 <etext+0x40>
    80000b00:	00012517          	auipc	a0,0x12
    80000b04:	9c050513          	addi	a0,a0,-1600 # 800124c0 <kmem>
    80000b08:	06c000ef          	jal	80000b74 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b0c:	45c5                	li	a1,17
    80000b0e:	05ee                	slli	a1,a1,0x1b
    80000b10:	00029517          	auipc	a0,0x29
    80000b14:	9f850513          	addi	a0,a0,-1544 # 80029508 <end>
    80000b18:	f91ff0ef          	jal	80000aa8 <freerange>
}
    80000b1c:	60a2                	ld	ra,8(sp)
    80000b1e:	6402                	ld	s0,0(sp)
    80000b20:	0141                	addi	sp,sp,16
    80000b22:	8082                	ret

0000000080000b24 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000b24:	1101                	addi	sp,sp,-32
    80000b26:	ec06                	sd	ra,24(sp)
    80000b28:	e822                	sd	s0,16(sp)
    80000b2a:	e426                	sd	s1,8(sp)
    80000b2c:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000b2e:	00012497          	auipc	s1,0x12
    80000b32:	99248493          	addi	s1,s1,-1646 # 800124c0 <kmem>
    80000b36:	8526                	mv	a0,s1
    80000b38:	0bc000ef          	jal	80000bf4 <acquire>
  r = kmem.freelist;
    80000b3c:	6c84                	ld	s1,24(s1)
  if(r)
    80000b3e:	c485                	beqz	s1,80000b66 <kalloc+0x42>
    kmem.freelist = r->next;
    80000b40:	609c                	ld	a5,0(s1)
    80000b42:	00012517          	auipc	a0,0x12
    80000b46:	97e50513          	addi	a0,a0,-1666 # 800124c0 <kmem>
    80000b4a:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b4c:	140000ef          	jal	80000c8c <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b50:	6605                	lui	a2,0x1
    80000b52:	4595                	li	a1,5
    80000b54:	8526                	mv	a0,s1
    80000b56:	172000ef          	jal	80000cc8 <memset>
  return (void*)r;
}
    80000b5a:	8526                	mv	a0,s1
    80000b5c:	60e2                	ld	ra,24(sp)
    80000b5e:	6442                	ld	s0,16(sp)
    80000b60:	64a2                	ld	s1,8(sp)
    80000b62:	6105                	addi	sp,sp,32
    80000b64:	8082                	ret
  release(&kmem.lock);
    80000b66:	00012517          	auipc	a0,0x12
    80000b6a:	95a50513          	addi	a0,a0,-1702 # 800124c0 <kmem>
    80000b6e:	11e000ef          	jal	80000c8c <release>
  if(r)
    80000b72:	b7e5                	j	80000b5a <kalloc+0x36>

0000000080000b74 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b74:	1141                	addi	sp,sp,-16
    80000b76:	e422                	sd	s0,8(sp)
    80000b78:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b7a:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b7c:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b80:	00053823          	sd	zero,16(a0)
}
    80000b84:	6422                	ld	s0,8(sp)
    80000b86:	0141                	addi	sp,sp,16
    80000b88:	8082                	ret

0000000080000b8a <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b8a:	411c                	lw	a5,0(a0)
    80000b8c:	e399                	bnez	a5,80000b92 <holding+0x8>
    80000b8e:	4501                	li	a0,0
  return r;
}
    80000b90:	8082                	ret
{
    80000b92:	1101                	addi	sp,sp,-32
    80000b94:	ec06                	sd	ra,24(sp)
    80000b96:	e822                	sd	s0,16(sp)
    80000b98:	e426                	sd	s1,8(sp)
    80000b9a:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b9c:	6904                	ld	s1,16(a0)
    80000b9e:	527000ef          	jal	800018c4 <mycpu>
    80000ba2:	40a48533          	sub	a0,s1,a0
    80000ba6:	00153513          	seqz	a0,a0
}
    80000baa:	60e2                	ld	ra,24(sp)
    80000bac:	6442                	ld	s0,16(sp)
    80000bae:	64a2                	ld	s1,8(sp)
    80000bb0:	6105                	addi	sp,sp,32
    80000bb2:	8082                	ret

0000000080000bb4 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000bb4:	1101                	addi	sp,sp,-32
    80000bb6:	ec06                	sd	ra,24(sp)
    80000bb8:	e822                	sd	s0,16(sp)
    80000bba:	e426                	sd	s1,8(sp)
    80000bbc:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000bbe:	100024f3          	csrr	s1,sstatus
    80000bc2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000bc6:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000bc8:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000bcc:	4f9000ef          	jal	800018c4 <mycpu>
    80000bd0:	5d3c                	lw	a5,120(a0)
    80000bd2:	cb99                	beqz	a5,80000be8 <push_off+0x34>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bd4:	4f1000ef          	jal	800018c4 <mycpu>
    80000bd8:	5d3c                	lw	a5,120(a0)
    80000bda:	2785                	addiw	a5,a5,1
    80000bdc:	dd3c                	sw	a5,120(a0)
}
    80000bde:	60e2                	ld	ra,24(sp)
    80000be0:	6442                	ld	s0,16(sp)
    80000be2:	64a2                	ld	s1,8(sp)
    80000be4:	6105                	addi	sp,sp,32
    80000be6:	8082                	ret
    mycpu()->intena = old;
    80000be8:	4dd000ef          	jal	800018c4 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bec:	8085                	srli	s1,s1,0x1
    80000bee:	8885                	andi	s1,s1,1
    80000bf0:	dd64                	sw	s1,124(a0)
    80000bf2:	b7cd                	j	80000bd4 <push_off+0x20>

0000000080000bf4 <acquire>:
{
    80000bf4:	1101                	addi	sp,sp,-32
    80000bf6:	ec06                	sd	ra,24(sp)
    80000bf8:	e822                	sd	s0,16(sp)
    80000bfa:	e426                	sd	s1,8(sp)
    80000bfc:	1000                	addi	s0,sp,32
    80000bfe:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000c00:	fb5ff0ef          	jal	80000bb4 <push_off>
  if(holding(lk))
    80000c04:	8526                	mv	a0,s1
    80000c06:	f85ff0ef          	jal	80000b8a <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c0a:	4705                	li	a4,1
  if(holding(lk))
    80000c0c:	e105                	bnez	a0,80000c2c <acquire+0x38>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c0e:	87ba                	mv	a5,a4
    80000c10:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000c14:	2781                	sext.w	a5,a5
    80000c16:	ffe5                	bnez	a5,80000c0e <acquire+0x1a>
  __sync_synchronize();
    80000c18:	0330000f          	fence	rw,rw
  lk->cpu = mycpu();
    80000c1c:	4a9000ef          	jal	800018c4 <mycpu>
    80000c20:	e888                	sd	a0,16(s1)
}
    80000c22:	60e2                	ld	ra,24(sp)
    80000c24:	6442                	ld	s0,16(sp)
    80000c26:	64a2                	ld	s1,8(sp)
    80000c28:	6105                	addi	sp,sp,32
    80000c2a:	8082                	ret
    panic("acquire");
    80000c2c:	00006517          	auipc	a0,0x6
    80000c30:	41c50513          	addi	a0,a0,1052 # 80007048 <etext+0x48>
    80000c34:	b61ff0ef          	jal	80000794 <panic>

0000000080000c38 <pop_off>:

void
pop_off(void)
{
    80000c38:	1141                	addi	sp,sp,-16
    80000c3a:	e406                	sd	ra,8(sp)
    80000c3c:	e022                	sd	s0,0(sp)
    80000c3e:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c40:	485000ef          	jal	800018c4 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c44:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c48:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c4a:	e78d                	bnez	a5,80000c74 <pop_off+0x3c>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c4c:	5d3c                	lw	a5,120(a0)
    80000c4e:	02f05963          	blez	a5,80000c80 <pop_off+0x48>
    panic("pop_off");
  c->noff -= 1;
    80000c52:	37fd                	addiw	a5,a5,-1
    80000c54:	0007871b          	sext.w	a4,a5
    80000c58:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c5a:	eb09                	bnez	a4,80000c6c <pop_off+0x34>
    80000c5c:	5d7c                	lw	a5,124(a0)
    80000c5e:	c799                	beqz	a5,80000c6c <pop_off+0x34>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c60:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c64:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c68:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c6c:	60a2                	ld	ra,8(sp)
    80000c6e:	6402                	ld	s0,0(sp)
    80000c70:	0141                	addi	sp,sp,16
    80000c72:	8082                	ret
    panic("pop_off - interruptible");
    80000c74:	00006517          	auipc	a0,0x6
    80000c78:	3dc50513          	addi	a0,a0,988 # 80007050 <etext+0x50>
    80000c7c:	b19ff0ef          	jal	80000794 <panic>
    panic("pop_off");
    80000c80:	00006517          	auipc	a0,0x6
    80000c84:	3e850513          	addi	a0,a0,1000 # 80007068 <etext+0x68>
    80000c88:	b0dff0ef          	jal	80000794 <panic>

0000000080000c8c <release>:
{
    80000c8c:	1101                	addi	sp,sp,-32
    80000c8e:	ec06                	sd	ra,24(sp)
    80000c90:	e822                	sd	s0,16(sp)
    80000c92:	e426                	sd	s1,8(sp)
    80000c94:	1000                	addi	s0,sp,32
    80000c96:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000c98:	ef3ff0ef          	jal	80000b8a <holding>
    80000c9c:	c105                	beqz	a0,80000cbc <release+0x30>
  lk->cpu = 0;
    80000c9e:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000ca2:	0330000f          	fence	rw,rw
  __sync_lock_release(&lk->locked);
    80000ca6:	0310000f          	fence	rw,w
    80000caa:	0004a023          	sw	zero,0(s1)
  pop_off();
    80000cae:	f8bff0ef          	jal	80000c38 <pop_off>
}
    80000cb2:	60e2                	ld	ra,24(sp)
    80000cb4:	6442                	ld	s0,16(sp)
    80000cb6:	64a2                	ld	s1,8(sp)
    80000cb8:	6105                	addi	sp,sp,32
    80000cba:	8082                	ret
    panic("release");
    80000cbc:	00006517          	auipc	a0,0x6
    80000cc0:	3b450513          	addi	a0,a0,948 # 80007070 <etext+0x70>
    80000cc4:	ad1ff0ef          	jal	80000794 <panic>

0000000080000cc8 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000cc8:	1141                	addi	sp,sp,-16
    80000cca:	e422                	sd	s0,8(sp)
    80000ccc:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000cce:	ca19                	beqz	a2,80000ce4 <memset+0x1c>
    80000cd0:	87aa                	mv	a5,a0
    80000cd2:	1602                	slli	a2,a2,0x20
    80000cd4:	9201                	srli	a2,a2,0x20
    80000cd6:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000cda:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000cde:	0785                	addi	a5,a5,1
    80000ce0:	fee79de3          	bne	a5,a4,80000cda <memset+0x12>
  }
  return dst;
}
    80000ce4:	6422                	ld	s0,8(sp)
    80000ce6:	0141                	addi	sp,sp,16
    80000ce8:	8082                	ret

0000000080000cea <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000cea:	1141                	addi	sp,sp,-16
    80000cec:	e422                	sd	s0,8(sp)
    80000cee:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000cf0:	ca05                	beqz	a2,80000d20 <memcmp+0x36>
    80000cf2:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000cf6:	1682                	slli	a3,a3,0x20
    80000cf8:	9281                	srli	a3,a3,0x20
    80000cfa:	0685                	addi	a3,a3,1
    80000cfc:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000cfe:	00054783          	lbu	a5,0(a0)
    80000d02:	0005c703          	lbu	a4,0(a1)
    80000d06:	00e79863          	bne	a5,a4,80000d16 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d0a:	0505                	addi	a0,a0,1
    80000d0c:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d0e:	fed518e3          	bne	a0,a3,80000cfe <memcmp+0x14>
  }

  return 0;
    80000d12:	4501                	li	a0,0
    80000d14:	a019                	j	80000d1a <memcmp+0x30>
      return *s1 - *s2;
    80000d16:	40e7853b          	subw	a0,a5,a4
}
    80000d1a:	6422                	ld	s0,8(sp)
    80000d1c:	0141                	addi	sp,sp,16
    80000d1e:	8082                	ret
  return 0;
    80000d20:	4501                	li	a0,0
    80000d22:	bfe5                	j	80000d1a <memcmp+0x30>

0000000080000d24 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d24:	1141                	addi	sp,sp,-16
    80000d26:	e422                	sd	s0,8(sp)
    80000d28:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d2a:	c205                	beqz	a2,80000d4a <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d2c:	02a5e263          	bltu	a1,a0,80000d50 <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d30:	1602                	slli	a2,a2,0x20
    80000d32:	9201                	srli	a2,a2,0x20
    80000d34:	00c587b3          	add	a5,a1,a2
{
    80000d38:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d3a:	0585                	addi	a1,a1,1
    80000d3c:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffd5af9>
    80000d3e:	fff5c683          	lbu	a3,-1(a1)
    80000d42:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d46:	feb79ae3          	bne	a5,a1,80000d3a <memmove+0x16>

  return dst;
}
    80000d4a:	6422                	ld	s0,8(sp)
    80000d4c:	0141                	addi	sp,sp,16
    80000d4e:	8082                	ret
  if(s < d && s + n > d){
    80000d50:	02061693          	slli	a3,a2,0x20
    80000d54:	9281                	srli	a3,a3,0x20
    80000d56:	00d58733          	add	a4,a1,a3
    80000d5a:	fce57be3          	bgeu	a0,a4,80000d30 <memmove+0xc>
    d += n;
    80000d5e:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d60:	fff6079b          	addiw	a5,a2,-1
    80000d64:	1782                	slli	a5,a5,0x20
    80000d66:	9381                	srli	a5,a5,0x20
    80000d68:	fff7c793          	not	a5,a5
    80000d6c:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d6e:	177d                	addi	a4,a4,-1
    80000d70:	16fd                	addi	a3,a3,-1
    80000d72:	00074603          	lbu	a2,0(a4)
    80000d76:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000d7a:	fef71ae3          	bne	a4,a5,80000d6e <memmove+0x4a>
    80000d7e:	b7f1                	j	80000d4a <memmove+0x26>

0000000080000d80 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000d80:	1141                	addi	sp,sp,-16
    80000d82:	e406                	sd	ra,8(sp)
    80000d84:	e022                	sd	s0,0(sp)
    80000d86:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000d88:	f9dff0ef          	jal	80000d24 <memmove>
}
    80000d8c:	60a2                	ld	ra,8(sp)
    80000d8e:	6402                	ld	s0,0(sp)
    80000d90:	0141                	addi	sp,sp,16
    80000d92:	8082                	ret

0000000080000d94 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000d94:	1141                	addi	sp,sp,-16
    80000d96:	e422                	sd	s0,8(sp)
    80000d98:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000d9a:	ce11                	beqz	a2,80000db6 <strncmp+0x22>
    80000d9c:	00054783          	lbu	a5,0(a0)
    80000da0:	cf89                	beqz	a5,80000dba <strncmp+0x26>
    80000da2:	0005c703          	lbu	a4,0(a1)
    80000da6:	00f71a63          	bne	a4,a5,80000dba <strncmp+0x26>
    n--, p++, q++;
    80000daa:	367d                	addiw	a2,a2,-1
    80000dac:	0505                	addi	a0,a0,1
    80000dae:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000db0:	f675                	bnez	a2,80000d9c <strncmp+0x8>
  if(n == 0)
    return 0;
    80000db2:	4501                	li	a0,0
    80000db4:	a801                	j	80000dc4 <strncmp+0x30>
    80000db6:	4501                	li	a0,0
    80000db8:	a031                	j	80000dc4 <strncmp+0x30>
  return (uchar)*p - (uchar)*q;
    80000dba:	00054503          	lbu	a0,0(a0)
    80000dbe:	0005c783          	lbu	a5,0(a1)
    80000dc2:	9d1d                	subw	a0,a0,a5
}
    80000dc4:	6422                	ld	s0,8(sp)
    80000dc6:	0141                	addi	sp,sp,16
    80000dc8:	8082                	ret

0000000080000dca <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000dca:	1141                	addi	sp,sp,-16
    80000dcc:	e422                	sd	s0,8(sp)
    80000dce:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000dd0:	87aa                	mv	a5,a0
    80000dd2:	86b2                	mv	a3,a2
    80000dd4:	367d                	addiw	a2,a2,-1
    80000dd6:	02d05563          	blez	a3,80000e00 <strncpy+0x36>
    80000dda:	0785                	addi	a5,a5,1
    80000ddc:	0005c703          	lbu	a4,0(a1)
    80000de0:	fee78fa3          	sb	a4,-1(a5)
    80000de4:	0585                	addi	a1,a1,1
    80000de6:	f775                	bnez	a4,80000dd2 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000de8:	873e                	mv	a4,a5
    80000dea:	9fb5                	addw	a5,a5,a3
    80000dec:	37fd                	addiw	a5,a5,-1
    80000dee:	00c05963          	blez	a2,80000e00 <strncpy+0x36>
    *s++ = 0;
    80000df2:	0705                	addi	a4,a4,1
    80000df4:	fe070fa3          	sb	zero,-1(a4)
  while(n-- > 0)
    80000df8:	40e786bb          	subw	a3,a5,a4
    80000dfc:	fed04be3          	bgtz	a3,80000df2 <strncpy+0x28>
  return os;
}
    80000e00:	6422                	ld	s0,8(sp)
    80000e02:	0141                	addi	sp,sp,16
    80000e04:	8082                	ret

0000000080000e06 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e06:	1141                	addi	sp,sp,-16
    80000e08:	e422                	sd	s0,8(sp)
    80000e0a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e0c:	02c05363          	blez	a2,80000e32 <safestrcpy+0x2c>
    80000e10:	fff6069b          	addiw	a3,a2,-1
    80000e14:	1682                	slli	a3,a3,0x20
    80000e16:	9281                	srli	a3,a3,0x20
    80000e18:	96ae                	add	a3,a3,a1
    80000e1a:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e1c:	00d58963          	beq	a1,a3,80000e2e <safestrcpy+0x28>
    80000e20:	0585                	addi	a1,a1,1
    80000e22:	0785                	addi	a5,a5,1
    80000e24:	fff5c703          	lbu	a4,-1(a1)
    80000e28:	fee78fa3          	sb	a4,-1(a5)
    80000e2c:	fb65                	bnez	a4,80000e1c <safestrcpy+0x16>
    ;
  *s = 0;
    80000e2e:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e32:	6422                	ld	s0,8(sp)
    80000e34:	0141                	addi	sp,sp,16
    80000e36:	8082                	ret

0000000080000e38 <strlen>:

int
strlen(const char *s)
{
    80000e38:	1141                	addi	sp,sp,-16
    80000e3a:	e422                	sd	s0,8(sp)
    80000e3c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e3e:	00054783          	lbu	a5,0(a0)
    80000e42:	cf91                	beqz	a5,80000e5e <strlen+0x26>
    80000e44:	0505                	addi	a0,a0,1
    80000e46:	87aa                	mv	a5,a0
    80000e48:	86be                	mv	a3,a5
    80000e4a:	0785                	addi	a5,a5,1
    80000e4c:	fff7c703          	lbu	a4,-1(a5)
    80000e50:	ff65                	bnez	a4,80000e48 <strlen+0x10>
    80000e52:	40a6853b          	subw	a0,a3,a0
    80000e56:	2505                	addiw	a0,a0,1
    ;
  return n;
}
    80000e58:	6422                	ld	s0,8(sp)
    80000e5a:	0141                	addi	sp,sp,16
    80000e5c:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e5e:	4501                	li	a0,0
    80000e60:	bfe5                	j	80000e58 <strlen+0x20>

0000000080000e62 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e62:	1141                	addi	sp,sp,-16
    80000e64:	e406                	sd	ra,8(sp)
    80000e66:	e022                	sd	s0,0(sp)
    80000e68:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e6a:	24b000ef          	jal	800018b4 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e6e:	00009717          	auipc	a4,0x9
    80000e72:	52a70713          	addi	a4,a4,1322 # 8000a398 <started>
  if(cpuid() == 0){
    80000e76:	c51d                	beqz	a0,80000ea4 <main+0x42>
    while(started == 0)
    80000e78:	431c                	lw	a5,0(a4)
    80000e7a:	2781                	sext.w	a5,a5
    80000e7c:	dff5                	beqz	a5,80000e78 <main+0x16>
      ;
    __sync_synchronize();
    80000e7e:	0330000f          	fence	rw,rw
    printf("hart %d starting\n", cpuid());
    80000e82:	233000ef          	jal	800018b4 <cpuid>
    80000e86:	85aa                	mv	a1,a0
    80000e88:	00006517          	auipc	a0,0x6
    80000e8c:	20850513          	addi	a0,a0,520 # 80007090 <etext+0x90>
    80000e90:	e32ff0ef          	jal	800004c2 <printf>
    kvminithart();    // turn on paging
    80000e94:	080000ef          	jal	80000f14 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000e98:	71c010ef          	jal	800025b4 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000e9c:	5dc040ef          	jal	80005478 <plicinithart>
  }

  scheduler();        
    80000ea0:	675000ef          	jal	80001d14 <scheduler>
    consoleinit();
    80000ea4:	d48ff0ef          	jal	800003ec <consoleinit>
    printfinit();
    80000ea8:	927ff0ef          	jal	800007ce <printfinit>
    printf("\n");
    80000eac:	00006517          	auipc	a0,0x6
    80000eb0:	48c50513          	addi	a0,a0,1164 # 80007338 <etext+0x338>
    80000eb4:	e0eff0ef          	jal	800004c2 <printf>
    printf("xv6 kernel is booting\n");
    80000eb8:	00006517          	auipc	a0,0x6
    80000ebc:	1c050513          	addi	a0,a0,448 # 80007078 <etext+0x78>
    80000ec0:	e02ff0ef          	jal	800004c2 <printf>
    printf("\n");
    80000ec4:	00006517          	auipc	a0,0x6
    80000ec8:	47450513          	addi	a0,a0,1140 # 80007338 <etext+0x338>
    80000ecc:	df6ff0ef          	jal	800004c2 <printf>
    kinit();         // physical page allocator
    80000ed0:	c21ff0ef          	jal	80000af0 <kinit>
    kvminit();       // create kernel page table
    80000ed4:	2ca000ef          	jal	8000119e <kvminit>
    kvminithart();   // turn on paging
    80000ed8:	03c000ef          	jal	80000f14 <kvminithart>
    procinit();      // process table
    80000edc:	123000ef          	jal	800017fe <procinit>
    trapinit();      // trap vectors
    80000ee0:	6b0010ef          	jal	80002590 <trapinit>
    trapinithart();  // install kernel trap vector
    80000ee4:	6d0010ef          	jal	800025b4 <trapinithart>
    plicinit();      // set up interrupt controller
    80000ee8:	576040ef          	jal	8000545e <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000eec:	58c040ef          	jal	80005478 <plicinithart>
    binit();         // buffer cache
    80000ef0:	52d010ef          	jal	80002c1c <binit>
    iinit();         // inode table
    80000ef4:	31e020ef          	jal	80003212 <iinit>
    fileinit();      // file table
    80000ef8:	0ca030ef          	jal	80003fc2 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000efc:	66c040ef          	jal	80005568 <virtio_disk_init>
    userinit();      // first user process
    80000f00:	449000ef          	jal	80001b48 <userinit>
    __sync_synchronize();
    80000f04:	0330000f          	fence	rw,rw
    started = 1;
    80000f08:	4785                	li	a5,1
    80000f0a:	00009717          	auipc	a4,0x9
    80000f0e:	48f72723          	sw	a5,1166(a4) # 8000a398 <started>
    80000f12:	b779                	j	80000ea0 <main+0x3e>

0000000080000f14 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000f14:	1141                	addi	sp,sp,-16
    80000f16:	e422                	sd	s0,8(sp)
    80000f18:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000f1a:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000f1e:	00009797          	auipc	a5,0x9
    80000f22:	4827b783          	ld	a5,1154(a5) # 8000a3a0 <kernel_pagetable>
    80000f26:	83b1                	srli	a5,a5,0xc
    80000f28:	577d                	li	a4,-1
    80000f2a:	177e                	slli	a4,a4,0x3f
    80000f2c:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000f2e:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000f32:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000f36:	6422                	ld	s0,8(sp)
    80000f38:	0141                	addi	sp,sp,16
    80000f3a:	8082                	ret

0000000080000f3c <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000f3c:	7139                	addi	sp,sp,-64
    80000f3e:	fc06                	sd	ra,56(sp)
    80000f40:	f822                	sd	s0,48(sp)
    80000f42:	f426                	sd	s1,40(sp)
    80000f44:	f04a                	sd	s2,32(sp)
    80000f46:	ec4e                	sd	s3,24(sp)
    80000f48:	e852                	sd	s4,16(sp)
    80000f4a:	e456                	sd	s5,8(sp)
    80000f4c:	e05a                	sd	s6,0(sp)
    80000f4e:	0080                	addi	s0,sp,64
    80000f50:	84aa                	mv	s1,a0
    80000f52:	89ae                	mv	s3,a1
    80000f54:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000f56:	57fd                	li	a5,-1
    80000f58:	83e9                	srli	a5,a5,0x1a
    80000f5a:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000f5c:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000f5e:	02b7fc63          	bgeu	a5,a1,80000f96 <walk+0x5a>
    panic("walk");
    80000f62:	00006517          	auipc	a0,0x6
    80000f66:	14650513          	addi	a0,a0,326 # 800070a8 <etext+0xa8>
    80000f6a:	82bff0ef          	jal	80000794 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000f6e:	060a8263          	beqz	s5,80000fd2 <walk+0x96>
    80000f72:	bb3ff0ef          	jal	80000b24 <kalloc>
    80000f76:	84aa                	mv	s1,a0
    80000f78:	c139                	beqz	a0,80000fbe <walk+0x82>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000f7a:	6605                	lui	a2,0x1
    80000f7c:	4581                	li	a1,0
    80000f7e:	d4bff0ef          	jal	80000cc8 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80000f82:	00c4d793          	srli	a5,s1,0xc
    80000f86:	07aa                	slli	a5,a5,0xa
    80000f88:	0017e793          	ori	a5,a5,1
    80000f8c:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80000f90:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffd5aef>
    80000f92:	036a0063          	beq	s4,s6,80000fb2 <walk+0x76>
    pte_t *pte = &pagetable[PX(level, va)];
    80000f96:	0149d933          	srl	s2,s3,s4
    80000f9a:	1ff97913          	andi	s2,s2,511
    80000f9e:	090e                	slli	s2,s2,0x3
    80000fa0:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80000fa2:	00093483          	ld	s1,0(s2)
    80000fa6:	0014f793          	andi	a5,s1,1
    80000faa:	d3f1                	beqz	a5,80000f6e <walk+0x32>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80000fac:	80a9                	srli	s1,s1,0xa
    80000fae:	04b2                	slli	s1,s1,0xc
    80000fb0:	b7c5                	j	80000f90 <walk+0x54>
    }
  }
  return &pagetable[PX(0, va)];
    80000fb2:	00c9d513          	srli	a0,s3,0xc
    80000fb6:	1ff57513          	andi	a0,a0,511
    80000fba:	050e                	slli	a0,a0,0x3
    80000fbc:	9526                	add	a0,a0,s1
}
    80000fbe:	70e2                	ld	ra,56(sp)
    80000fc0:	7442                	ld	s0,48(sp)
    80000fc2:	74a2                	ld	s1,40(sp)
    80000fc4:	7902                	ld	s2,32(sp)
    80000fc6:	69e2                	ld	s3,24(sp)
    80000fc8:	6a42                	ld	s4,16(sp)
    80000fca:	6aa2                	ld	s5,8(sp)
    80000fcc:	6b02                	ld	s6,0(sp)
    80000fce:	6121                	addi	sp,sp,64
    80000fd0:	8082                	ret
        return 0;
    80000fd2:	4501                	li	a0,0
    80000fd4:	b7ed                	j	80000fbe <walk+0x82>

0000000080000fd6 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80000fd6:	57fd                	li	a5,-1
    80000fd8:	83e9                	srli	a5,a5,0x1a
    80000fda:	00b7f463          	bgeu	a5,a1,80000fe2 <walkaddr+0xc>
    return 0;
    80000fde:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80000fe0:	8082                	ret
{
    80000fe2:	1141                	addi	sp,sp,-16
    80000fe4:	e406                	sd	ra,8(sp)
    80000fe6:	e022                	sd	s0,0(sp)
    80000fe8:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80000fea:	4601                	li	a2,0
    80000fec:	f51ff0ef          	jal	80000f3c <walk>
  if(pte == 0)
    80000ff0:	c105                	beqz	a0,80001010 <walkaddr+0x3a>
  if((*pte & PTE_V) == 0)
    80000ff2:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80000ff4:	0117f693          	andi	a3,a5,17
    80000ff8:	4745                	li	a4,17
    return 0;
    80000ffa:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80000ffc:	00e68663          	beq	a3,a4,80001008 <walkaddr+0x32>
}
    80001000:	60a2                	ld	ra,8(sp)
    80001002:	6402                	ld	s0,0(sp)
    80001004:	0141                	addi	sp,sp,16
    80001006:	8082                	ret
  pa = PTE2PA(*pte);
    80001008:	83a9                	srli	a5,a5,0xa
    8000100a:	00c79513          	slli	a0,a5,0xc
  return pa;
    8000100e:	bfcd                	j	80001000 <walkaddr+0x2a>
    return 0;
    80001010:	4501                	li	a0,0
    80001012:	b7fd                	j	80001000 <walkaddr+0x2a>

0000000080001014 <mappages>:
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80001014:	715d                	addi	sp,sp,-80
    80001016:	e486                	sd	ra,72(sp)
    80001018:	e0a2                	sd	s0,64(sp)
    8000101a:	fc26                	sd	s1,56(sp)
    8000101c:	f84a                	sd	s2,48(sp)
    8000101e:	f44e                	sd	s3,40(sp)
    80001020:	f052                	sd	s4,32(sp)
    80001022:	ec56                	sd	s5,24(sp)
    80001024:	e85a                	sd	s6,16(sp)
    80001026:	e45e                	sd	s7,8(sp)
    80001028:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    8000102a:	03459793          	slli	a5,a1,0x34
    8000102e:	e7a9                	bnez	a5,80001078 <mappages+0x64>
    80001030:	8aaa                	mv	s5,a0
    80001032:	8b3a                	mv	s6,a4
    panic("mappages: va not aligned");

  if((size % PGSIZE) != 0)
    80001034:	03461793          	slli	a5,a2,0x34
    80001038:	e7b1                	bnez	a5,80001084 <mappages+0x70>
    panic("mappages: size not aligned");

  if(size == 0)
    8000103a:	ca39                	beqz	a2,80001090 <mappages+0x7c>
    panic("mappages: size");
  
  a = va;
  last = va + size - PGSIZE;
    8000103c:	77fd                	lui	a5,0xfffff
    8000103e:	963e                	add	a2,a2,a5
    80001040:	00b609b3          	add	s3,a2,a1
  a = va;
    80001044:	892e                	mv	s2,a1
    80001046:	40b68a33          	sub	s4,a3,a1
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    8000104a:	6b85                	lui	s7,0x1
    8000104c:	014904b3          	add	s1,s2,s4
    if((pte = walk(pagetable, a, 1)) == 0)
    80001050:	4605                	li	a2,1
    80001052:	85ca                	mv	a1,s2
    80001054:	8556                	mv	a0,s5
    80001056:	ee7ff0ef          	jal	80000f3c <walk>
    8000105a:	c539                	beqz	a0,800010a8 <mappages+0x94>
    if(*pte & PTE_V)
    8000105c:	611c                	ld	a5,0(a0)
    8000105e:	8b85                	andi	a5,a5,1
    80001060:	ef95                	bnez	a5,8000109c <mappages+0x88>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001062:	80b1                	srli	s1,s1,0xc
    80001064:	04aa                	slli	s1,s1,0xa
    80001066:	0164e4b3          	or	s1,s1,s6
    8000106a:	0014e493          	ori	s1,s1,1
    8000106e:	e104                	sd	s1,0(a0)
    if(a == last)
    80001070:	05390863          	beq	s2,s3,800010c0 <mappages+0xac>
    a += PGSIZE;
    80001074:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001076:	bfd9                	j	8000104c <mappages+0x38>
    panic("mappages: va not aligned");
    80001078:	00006517          	auipc	a0,0x6
    8000107c:	03850513          	addi	a0,a0,56 # 800070b0 <etext+0xb0>
    80001080:	f14ff0ef          	jal	80000794 <panic>
    panic("mappages: size not aligned");
    80001084:	00006517          	auipc	a0,0x6
    80001088:	04c50513          	addi	a0,a0,76 # 800070d0 <etext+0xd0>
    8000108c:	f08ff0ef          	jal	80000794 <panic>
    panic("mappages: size");
    80001090:	00006517          	auipc	a0,0x6
    80001094:	06050513          	addi	a0,a0,96 # 800070f0 <etext+0xf0>
    80001098:	efcff0ef          	jal	80000794 <panic>
      panic("mappages: remap");
    8000109c:	00006517          	auipc	a0,0x6
    800010a0:	06450513          	addi	a0,a0,100 # 80007100 <etext+0x100>
    800010a4:	ef0ff0ef          	jal	80000794 <panic>
      return -1;
    800010a8:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    800010aa:	60a6                	ld	ra,72(sp)
    800010ac:	6406                	ld	s0,64(sp)
    800010ae:	74e2                	ld	s1,56(sp)
    800010b0:	7942                	ld	s2,48(sp)
    800010b2:	79a2                	ld	s3,40(sp)
    800010b4:	7a02                	ld	s4,32(sp)
    800010b6:	6ae2                	ld	s5,24(sp)
    800010b8:	6b42                	ld	s6,16(sp)
    800010ba:	6ba2                	ld	s7,8(sp)
    800010bc:	6161                	addi	sp,sp,80
    800010be:	8082                	ret
  return 0;
    800010c0:	4501                	li	a0,0
    800010c2:	b7e5                	j	800010aa <mappages+0x96>

00000000800010c4 <kvmmap>:
{
    800010c4:	1141                	addi	sp,sp,-16
    800010c6:	e406                	sd	ra,8(sp)
    800010c8:	e022                	sd	s0,0(sp)
    800010ca:	0800                	addi	s0,sp,16
    800010cc:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    800010ce:	86b2                	mv	a3,a2
    800010d0:	863e                	mv	a2,a5
    800010d2:	f43ff0ef          	jal	80001014 <mappages>
    800010d6:	e509                	bnez	a0,800010e0 <kvmmap+0x1c>
}
    800010d8:	60a2                	ld	ra,8(sp)
    800010da:	6402                	ld	s0,0(sp)
    800010dc:	0141                	addi	sp,sp,16
    800010de:	8082                	ret
    panic("kvmmap");
    800010e0:	00006517          	auipc	a0,0x6
    800010e4:	03050513          	addi	a0,a0,48 # 80007110 <etext+0x110>
    800010e8:	eacff0ef          	jal	80000794 <panic>

00000000800010ec <kvmmake>:
{
    800010ec:	1101                	addi	sp,sp,-32
    800010ee:	ec06                	sd	ra,24(sp)
    800010f0:	e822                	sd	s0,16(sp)
    800010f2:	e426                	sd	s1,8(sp)
    800010f4:	e04a                	sd	s2,0(sp)
    800010f6:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    800010f8:	a2dff0ef          	jal	80000b24 <kalloc>
    800010fc:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    800010fe:	6605                	lui	a2,0x1
    80001100:	4581                	li	a1,0
    80001102:	bc7ff0ef          	jal	80000cc8 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001106:	4719                	li	a4,6
    80001108:	6685                	lui	a3,0x1
    8000110a:	10000637          	lui	a2,0x10000
    8000110e:	100005b7          	lui	a1,0x10000
    80001112:	8526                	mv	a0,s1
    80001114:	fb1ff0ef          	jal	800010c4 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80001118:	4719                	li	a4,6
    8000111a:	6685                	lui	a3,0x1
    8000111c:	10001637          	lui	a2,0x10001
    80001120:	100015b7          	lui	a1,0x10001
    80001124:	8526                	mv	a0,s1
    80001126:	f9fff0ef          	jal	800010c4 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    8000112a:	4719                	li	a4,6
    8000112c:	040006b7          	lui	a3,0x4000
    80001130:	0c000637          	lui	a2,0xc000
    80001134:	0c0005b7          	lui	a1,0xc000
    80001138:	8526                	mv	a0,s1
    8000113a:	f8bff0ef          	jal	800010c4 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    8000113e:	00006917          	auipc	s2,0x6
    80001142:	ec290913          	addi	s2,s2,-318 # 80007000 <etext>
    80001146:	4729                	li	a4,10
    80001148:	80006697          	auipc	a3,0x80006
    8000114c:	eb868693          	addi	a3,a3,-328 # 7000 <_entry-0x7fff9000>
    80001150:	4605                	li	a2,1
    80001152:	067e                	slli	a2,a2,0x1f
    80001154:	85b2                	mv	a1,a2
    80001156:	8526                	mv	a0,s1
    80001158:	f6dff0ef          	jal	800010c4 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    8000115c:	46c5                	li	a3,17
    8000115e:	06ee                	slli	a3,a3,0x1b
    80001160:	4719                	li	a4,6
    80001162:	412686b3          	sub	a3,a3,s2
    80001166:	864a                	mv	a2,s2
    80001168:	85ca                	mv	a1,s2
    8000116a:	8526                	mv	a0,s1
    8000116c:	f59ff0ef          	jal	800010c4 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001170:	4729                	li	a4,10
    80001172:	6685                	lui	a3,0x1
    80001174:	00005617          	auipc	a2,0x5
    80001178:	e8c60613          	addi	a2,a2,-372 # 80006000 <_trampoline>
    8000117c:	040005b7          	lui	a1,0x4000
    80001180:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001182:	05b2                	slli	a1,a1,0xc
    80001184:	8526                	mv	a0,s1
    80001186:	f3fff0ef          	jal	800010c4 <kvmmap>
  proc_mapstacks(kpgtbl);
    8000118a:	8526                	mv	a0,s1
    8000118c:	5da000ef          	jal	80001766 <proc_mapstacks>
}
    80001190:	8526                	mv	a0,s1
    80001192:	60e2                	ld	ra,24(sp)
    80001194:	6442                	ld	s0,16(sp)
    80001196:	64a2                	ld	s1,8(sp)
    80001198:	6902                	ld	s2,0(sp)
    8000119a:	6105                	addi	sp,sp,32
    8000119c:	8082                	ret

000000008000119e <kvminit>:
{
    8000119e:	1141                	addi	sp,sp,-16
    800011a0:	e406                	sd	ra,8(sp)
    800011a2:	e022                	sd	s0,0(sp)
    800011a4:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    800011a6:	f47ff0ef          	jal	800010ec <kvmmake>
    800011aa:	00009797          	auipc	a5,0x9
    800011ae:	1ea7bb23          	sd	a0,502(a5) # 8000a3a0 <kernel_pagetable>
}
    800011b2:	60a2                	ld	ra,8(sp)
    800011b4:	6402                	ld	s0,0(sp)
    800011b6:	0141                	addi	sp,sp,16
    800011b8:	8082                	ret

00000000800011ba <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    800011ba:	715d                	addi	sp,sp,-80
    800011bc:	e486                	sd	ra,72(sp)
    800011be:	e0a2                	sd	s0,64(sp)
    800011c0:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800011c2:	03459793          	slli	a5,a1,0x34
    800011c6:	e39d                	bnez	a5,800011ec <uvmunmap+0x32>
    800011c8:	f84a                	sd	s2,48(sp)
    800011ca:	f44e                	sd	s3,40(sp)
    800011cc:	f052                	sd	s4,32(sp)
    800011ce:	ec56                	sd	s5,24(sp)
    800011d0:	e85a                	sd	s6,16(sp)
    800011d2:	e45e                	sd	s7,8(sp)
    800011d4:	8a2a                	mv	s4,a0
    800011d6:	892e                	mv	s2,a1
    800011d8:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800011da:	0632                	slli	a2,a2,0xc
    800011dc:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    800011e0:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800011e2:	6b05                	lui	s6,0x1
    800011e4:	0735ff63          	bgeu	a1,s3,80001262 <uvmunmap+0xa8>
    800011e8:	fc26                	sd	s1,56(sp)
    800011ea:	a0a9                	j	80001234 <uvmunmap+0x7a>
    800011ec:	fc26                	sd	s1,56(sp)
    800011ee:	f84a                	sd	s2,48(sp)
    800011f0:	f44e                	sd	s3,40(sp)
    800011f2:	f052                	sd	s4,32(sp)
    800011f4:	ec56                	sd	s5,24(sp)
    800011f6:	e85a                	sd	s6,16(sp)
    800011f8:	e45e                	sd	s7,8(sp)
    panic("uvmunmap: not aligned");
    800011fa:	00006517          	auipc	a0,0x6
    800011fe:	f1e50513          	addi	a0,a0,-226 # 80007118 <etext+0x118>
    80001202:	d92ff0ef          	jal	80000794 <panic>
      panic("uvmunmap: walk");
    80001206:	00006517          	auipc	a0,0x6
    8000120a:	f2a50513          	addi	a0,a0,-214 # 80007130 <etext+0x130>
    8000120e:	d86ff0ef          	jal	80000794 <panic>
      panic("uvmunmap: not mapped");
    80001212:	00006517          	auipc	a0,0x6
    80001216:	f2e50513          	addi	a0,a0,-210 # 80007140 <etext+0x140>
    8000121a:	d7aff0ef          	jal	80000794 <panic>
      panic("uvmunmap: not a leaf");
    8000121e:	00006517          	auipc	a0,0x6
    80001222:	f3a50513          	addi	a0,a0,-198 # 80007158 <etext+0x158>
    80001226:	d6eff0ef          	jal	80000794 <panic>
    if(do_free){
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
    8000122a:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000122e:	995a                	add	s2,s2,s6
    80001230:	03397863          	bgeu	s2,s3,80001260 <uvmunmap+0xa6>
    if((pte = walk(pagetable, a, 0)) == 0)
    80001234:	4601                	li	a2,0
    80001236:	85ca                	mv	a1,s2
    80001238:	8552                	mv	a0,s4
    8000123a:	d03ff0ef          	jal	80000f3c <walk>
    8000123e:	84aa                	mv	s1,a0
    80001240:	d179                	beqz	a0,80001206 <uvmunmap+0x4c>
    if((*pte & PTE_V) == 0)
    80001242:	6108                	ld	a0,0(a0)
    80001244:	00157793          	andi	a5,a0,1
    80001248:	d7e9                	beqz	a5,80001212 <uvmunmap+0x58>
    if(PTE_FLAGS(*pte) == PTE_V)
    8000124a:	3ff57793          	andi	a5,a0,1023
    8000124e:	fd7788e3          	beq	a5,s7,8000121e <uvmunmap+0x64>
    if(do_free){
    80001252:	fc0a8ce3          	beqz	s5,8000122a <uvmunmap+0x70>
      uint64 pa = PTE2PA(*pte);
    80001256:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    80001258:	0532                	slli	a0,a0,0xc
    8000125a:	fe8ff0ef          	jal	80000a42 <kfree>
    8000125e:	b7f1                	j	8000122a <uvmunmap+0x70>
    80001260:	74e2                	ld	s1,56(sp)
    80001262:	7942                	ld	s2,48(sp)
    80001264:	79a2                	ld	s3,40(sp)
    80001266:	7a02                	ld	s4,32(sp)
    80001268:	6ae2                	ld	s5,24(sp)
    8000126a:	6b42                	ld	s6,16(sp)
    8000126c:	6ba2                	ld	s7,8(sp)
  }
}
    8000126e:	60a6                	ld	ra,72(sp)
    80001270:	6406                	ld	s0,64(sp)
    80001272:	6161                	addi	sp,sp,80
    80001274:	8082                	ret

0000000080001276 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001276:	1101                	addi	sp,sp,-32
    80001278:	ec06                	sd	ra,24(sp)
    8000127a:	e822                	sd	s0,16(sp)
    8000127c:	e426                	sd	s1,8(sp)
    8000127e:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001280:	8a5ff0ef          	jal	80000b24 <kalloc>
    80001284:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001286:	c509                	beqz	a0,80001290 <uvmcreate+0x1a>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001288:	6605                	lui	a2,0x1
    8000128a:	4581                	li	a1,0
    8000128c:	a3dff0ef          	jal	80000cc8 <memset>
  return pagetable;
}
    80001290:	8526                	mv	a0,s1
    80001292:	60e2                	ld	ra,24(sp)
    80001294:	6442                	ld	s0,16(sp)
    80001296:	64a2                	ld	s1,8(sp)
    80001298:	6105                	addi	sp,sp,32
    8000129a:	8082                	ret

000000008000129c <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    8000129c:	7179                	addi	sp,sp,-48
    8000129e:	f406                	sd	ra,40(sp)
    800012a0:	f022                	sd	s0,32(sp)
    800012a2:	ec26                	sd	s1,24(sp)
    800012a4:	e84a                	sd	s2,16(sp)
    800012a6:	e44e                	sd	s3,8(sp)
    800012a8:	e052                	sd	s4,0(sp)
    800012aa:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    800012ac:	6785                	lui	a5,0x1
    800012ae:	04f67063          	bgeu	a2,a5,800012ee <uvmfirst+0x52>
    800012b2:	8a2a                	mv	s4,a0
    800012b4:	89ae                	mv	s3,a1
    800012b6:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    800012b8:	86dff0ef          	jal	80000b24 <kalloc>
    800012bc:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    800012be:	6605                	lui	a2,0x1
    800012c0:	4581                	li	a1,0
    800012c2:	a07ff0ef          	jal	80000cc8 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    800012c6:	4779                	li	a4,30
    800012c8:	86ca                	mv	a3,s2
    800012ca:	6605                	lui	a2,0x1
    800012cc:	4581                	li	a1,0
    800012ce:	8552                	mv	a0,s4
    800012d0:	d45ff0ef          	jal	80001014 <mappages>
  memmove(mem, src, sz);
    800012d4:	8626                	mv	a2,s1
    800012d6:	85ce                	mv	a1,s3
    800012d8:	854a                	mv	a0,s2
    800012da:	a4bff0ef          	jal	80000d24 <memmove>
}
    800012de:	70a2                	ld	ra,40(sp)
    800012e0:	7402                	ld	s0,32(sp)
    800012e2:	64e2                	ld	s1,24(sp)
    800012e4:	6942                	ld	s2,16(sp)
    800012e6:	69a2                	ld	s3,8(sp)
    800012e8:	6a02                	ld	s4,0(sp)
    800012ea:	6145                	addi	sp,sp,48
    800012ec:	8082                	ret
    panic("uvmfirst: more than a page");
    800012ee:	00006517          	auipc	a0,0x6
    800012f2:	e8250513          	addi	a0,a0,-382 # 80007170 <etext+0x170>
    800012f6:	c9eff0ef          	jal	80000794 <panic>

00000000800012fa <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800012fa:	1101                	addi	sp,sp,-32
    800012fc:	ec06                	sd	ra,24(sp)
    800012fe:	e822                	sd	s0,16(sp)
    80001300:	e426                	sd	s1,8(sp)
    80001302:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    80001304:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    80001306:	00b67d63          	bgeu	a2,a1,80001320 <uvmdealloc+0x26>
    8000130a:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    8000130c:	6785                	lui	a5,0x1
    8000130e:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001310:	00f60733          	add	a4,a2,a5
    80001314:	76fd                	lui	a3,0xfffff
    80001316:	8f75                	and	a4,a4,a3
    80001318:	97ae                	add	a5,a5,a1
    8000131a:	8ff5                	and	a5,a5,a3
    8000131c:	00f76863          	bltu	a4,a5,8000132c <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80001320:	8526                	mv	a0,s1
    80001322:	60e2                	ld	ra,24(sp)
    80001324:	6442                	ld	s0,16(sp)
    80001326:	64a2                	ld	s1,8(sp)
    80001328:	6105                	addi	sp,sp,32
    8000132a:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    8000132c:	8f99                	sub	a5,a5,a4
    8000132e:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001330:	4685                	li	a3,1
    80001332:	0007861b          	sext.w	a2,a5
    80001336:	85ba                	mv	a1,a4
    80001338:	e83ff0ef          	jal	800011ba <uvmunmap>
    8000133c:	b7d5                	j	80001320 <uvmdealloc+0x26>

000000008000133e <uvmalloc>:
  if(newsz < oldsz)
    8000133e:	08b66f63          	bltu	a2,a1,800013dc <uvmalloc+0x9e>
{
    80001342:	7139                	addi	sp,sp,-64
    80001344:	fc06                	sd	ra,56(sp)
    80001346:	f822                	sd	s0,48(sp)
    80001348:	ec4e                	sd	s3,24(sp)
    8000134a:	e852                	sd	s4,16(sp)
    8000134c:	e456                	sd	s5,8(sp)
    8000134e:	0080                	addi	s0,sp,64
    80001350:	8aaa                	mv	s5,a0
    80001352:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001354:	6785                	lui	a5,0x1
    80001356:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001358:	95be                	add	a1,a1,a5
    8000135a:	77fd                	lui	a5,0xfffff
    8000135c:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001360:	08c9f063          	bgeu	s3,a2,800013e0 <uvmalloc+0xa2>
    80001364:	f426                	sd	s1,40(sp)
    80001366:	f04a                	sd	s2,32(sp)
    80001368:	e05a                	sd	s6,0(sp)
    8000136a:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000136c:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    80001370:	fb4ff0ef          	jal	80000b24 <kalloc>
    80001374:	84aa                	mv	s1,a0
    if(mem == 0){
    80001376:	c515                	beqz	a0,800013a2 <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    80001378:	6605                	lui	a2,0x1
    8000137a:	4581                	li	a1,0
    8000137c:	94dff0ef          	jal	80000cc8 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001380:	875a                	mv	a4,s6
    80001382:	86a6                	mv	a3,s1
    80001384:	6605                	lui	a2,0x1
    80001386:	85ca                	mv	a1,s2
    80001388:	8556                	mv	a0,s5
    8000138a:	c8bff0ef          	jal	80001014 <mappages>
    8000138e:	e915                	bnez	a0,800013c2 <uvmalloc+0x84>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001390:	6785                	lui	a5,0x1
    80001392:	993e                	add	s2,s2,a5
    80001394:	fd496ee3          	bltu	s2,s4,80001370 <uvmalloc+0x32>
  return newsz;
    80001398:	8552                	mv	a0,s4
    8000139a:	74a2                	ld	s1,40(sp)
    8000139c:	7902                	ld	s2,32(sp)
    8000139e:	6b02                	ld	s6,0(sp)
    800013a0:	a811                	j	800013b4 <uvmalloc+0x76>
      uvmdealloc(pagetable, a, oldsz);
    800013a2:	864e                	mv	a2,s3
    800013a4:	85ca                	mv	a1,s2
    800013a6:	8556                	mv	a0,s5
    800013a8:	f53ff0ef          	jal	800012fa <uvmdealloc>
      return 0;
    800013ac:	4501                	li	a0,0
    800013ae:	74a2                	ld	s1,40(sp)
    800013b0:	7902                	ld	s2,32(sp)
    800013b2:	6b02                	ld	s6,0(sp)
}
    800013b4:	70e2                	ld	ra,56(sp)
    800013b6:	7442                	ld	s0,48(sp)
    800013b8:	69e2                	ld	s3,24(sp)
    800013ba:	6a42                	ld	s4,16(sp)
    800013bc:	6aa2                	ld	s5,8(sp)
    800013be:	6121                	addi	sp,sp,64
    800013c0:	8082                	ret
      kfree(mem);
    800013c2:	8526                	mv	a0,s1
    800013c4:	e7eff0ef          	jal	80000a42 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800013c8:	864e                	mv	a2,s3
    800013ca:	85ca                	mv	a1,s2
    800013cc:	8556                	mv	a0,s5
    800013ce:	f2dff0ef          	jal	800012fa <uvmdealloc>
      return 0;
    800013d2:	4501                	li	a0,0
    800013d4:	74a2                	ld	s1,40(sp)
    800013d6:	7902                	ld	s2,32(sp)
    800013d8:	6b02                	ld	s6,0(sp)
    800013da:	bfe9                	j	800013b4 <uvmalloc+0x76>
    return oldsz;
    800013dc:	852e                	mv	a0,a1
}
    800013de:	8082                	ret
  return newsz;
    800013e0:	8532                	mv	a0,a2
    800013e2:	bfc9                	j	800013b4 <uvmalloc+0x76>

00000000800013e4 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800013e4:	7179                	addi	sp,sp,-48
    800013e6:	f406                	sd	ra,40(sp)
    800013e8:	f022                	sd	s0,32(sp)
    800013ea:	ec26                	sd	s1,24(sp)
    800013ec:	e84a                	sd	s2,16(sp)
    800013ee:	e44e                	sd	s3,8(sp)
    800013f0:	e052                	sd	s4,0(sp)
    800013f2:	1800                	addi	s0,sp,48
    800013f4:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800013f6:	84aa                	mv	s1,a0
    800013f8:	6905                	lui	s2,0x1
    800013fa:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800013fc:	4985                	li	s3,1
    800013fe:	a819                	j	80001414 <freewalk+0x30>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    80001400:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    80001402:	00c79513          	slli	a0,a5,0xc
    80001406:	fdfff0ef          	jal	800013e4 <freewalk>
      pagetable[i] = 0;
    8000140a:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    8000140e:	04a1                	addi	s1,s1,8
    80001410:	01248f63          	beq	s1,s2,8000142e <freewalk+0x4a>
    pte_t pte = pagetable[i];
    80001414:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001416:	00f7f713          	andi	a4,a5,15
    8000141a:	ff3703e3          	beq	a4,s3,80001400 <freewalk+0x1c>
    } else if(pte & PTE_V){
    8000141e:	8b85                	andi	a5,a5,1
    80001420:	d7fd                	beqz	a5,8000140e <freewalk+0x2a>
      panic("freewalk: leaf");
    80001422:	00006517          	auipc	a0,0x6
    80001426:	d6e50513          	addi	a0,a0,-658 # 80007190 <etext+0x190>
    8000142a:	b6aff0ef          	jal	80000794 <panic>
    }
  }
  kfree((void*)pagetable);
    8000142e:	8552                	mv	a0,s4
    80001430:	e12ff0ef          	jal	80000a42 <kfree>
}
    80001434:	70a2                	ld	ra,40(sp)
    80001436:	7402                	ld	s0,32(sp)
    80001438:	64e2                	ld	s1,24(sp)
    8000143a:	6942                	ld	s2,16(sp)
    8000143c:	69a2                	ld	s3,8(sp)
    8000143e:	6a02                	ld	s4,0(sp)
    80001440:	6145                	addi	sp,sp,48
    80001442:	8082                	ret

0000000080001444 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001444:	1101                	addi	sp,sp,-32
    80001446:	ec06                	sd	ra,24(sp)
    80001448:	e822                	sd	s0,16(sp)
    8000144a:	e426                	sd	s1,8(sp)
    8000144c:	1000                	addi	s0,sp,32
    8000144e:	84aa                	mv	s1,a0
  if(sz > 0)
    80001450:	e989                	bnez	a1,80001462 <uvmfree+0x1e>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001452:	8526                	mv	a0,s1
    80001454:	f91ff0ef          	jal	800013e4 <freewalk>
}
    80001458:	60e2                	ld	ra,24(sp)
    8000145a:	6442                	ld	s0,16(sp)
    8000145c:	64a2                	ld	s1,8(sp)
    8000145e:	6105                	addi	sp,sp,32
    80001460:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001462:	6785                	lui	a5,0x1
    80001464:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001466:	95be                	add	a1,a1,a5
    80001468:	4685                	li	a3,1
    8000146a:	00c5d613          	srli	a2,a1,0xc
    8000146e:	4581                	li	a1,0
    80001470:	d4bff0ef          	jal	800011ba <uvmunmap>
    80001474:	bff9                	j	80001452 <uvmfree+0xe>

0000000080001476 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001476:	c65d                	beqz	a2,80001524 <uvmcopy+0xae>
{
    80001478:	715d                	addi	sp,sp,-80
    8000147a:	e486                	sd	ra,72(sp)
    8000147c:	e0a2                	sd	s0,64(sp)
    8000147e:	fc26                	sd	s1,56(sp)
    80001480:	f84a                	sd	s2,48(sp)
    80001482:	f44e                	sd	s3,40(sp)
    80001484:	f052                	sd	s4,32(sp)
    80001486:	ec56                	sd	s5,24(sp)
    80001488:	e85a                	sd	s6,16(sp)
    8000148a:	e45e                	sd	s7,8(sp)
    8000148c:	0880                	addi	s0,sp,80
    8000148e:	8b2a                	mv	s6,a0
    80001490:	8aae                	mv	s5,a1
    80001492:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001494:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    80001496:	4601                	li	a2,0
    80001498:	85ce                	mv	a1,s3
    8000149a:	855a                	mv	a0,s6
    8000149c:	aa1ff0ef          	jal	80000f3c <walk>
    800014a0:	c121                	beqz	a0,800014e0 <uvmcopy+0x6a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    800014a2:	6118                	ld	a4,0(a0)
    800014a4:	00177793          	andi	a5,a4,1
    800014a8:	c3b1                	beqz	a5,800014ec <uvmcopy+0x76>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    800014aa:	00a75593          	srli	a1,a4,0xa
    800014ae:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800014b2:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    800014b6:	e6eff0ef          	jal	80000b24 <kalloc>
    800014ba:	892a                	mv	s2,a0
    800014bc:	c129                	beqz	a0,800014fe <uvmcopy+0x88>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800014be:	6605                	lui	a2,0x1
    800014c0:	85de                	mv	a1,s7
    800014c2:	863ff0ef          	jal	80000d24 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800014c6:	8726                	mv	a4,s1
    800014c8:	86ca                	mv	a3,s2
    800014ca:	6605                	lui	a2,0x1
    800014cc:	85ce                	mv	a1,s3
    800014ce:	8556                	mv	a0,s5
    800014d0:	b45ff0ef          	jal	80001014 <mappages>
    800014d4:	e115                	bnez	a0,800014f8 <uvmcopy+0x82>
  for(i = 0; i < sz; i += PGSIZE){
    800014d6:	6785                	lui	a5,0x1
    800014d8:	99be                	add	s3,s3,a5
    800014da:	fb49eee3          	bltu	s3,s4,80001496 <uvmcopy+0x20>
    800014de:	a805                	j	8000150e <uvmcopy+0x98>
      panic("uvmcopy: pte should exist");
    800014e0:	00006517          	auipc	a0,0x6
    800014e4:	cc050513          	addi	a0,a0,-832 # 800071a0 <etext+0x1a0>
    800014e8:	aacff0ef          	jal	80000794 <panic>
      panic("uvmcopy: page not present");
    800014ec:	00006517          	auipc	a0,0x6
    800014f0:	cd450513          	addi	a0,a0,-812 # 800071c0 <etext+0x1c0>
    800014f4:	aa0ff0ef          	jal	80000794 <panic>
      kfree(mem);
    800014f8:	854a                	mv	a0,s2
    800014fa:	d48ff0ef          	jal	80000a42 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    800014fe:	4685                	li	a3,1
    80001500:	00c9d613          	srli	a2,s3,0xc
    80001504:	4581                	li	a1,0
    80001506:	8556                	mv	a0,s5
    80001508:	cb3ff0ef          	jal	800011ba <uvmunmap>
  return -1;
    8000150c:	557d                	li	a0,-1
}
    8000150e:	60a6                	ld	ra,72(sp)
    80001510:	6406                	ld	s0,64(sp)
    80001512:	74e2                	ld	s1,56(sp)
    80001514:	7942                	ld	s2,48(sp)
    80001516:	79a2                	ld	s3,40(sp)
    80001518:	7a02                	ld	s4,32(sp)
    8000151a:	6ae2                	ld	s5,24(sp)
    8000151c:	6b42                	ld	s6,16(sp)
    8000151e:	6ba2                	ld	s7,8(sp)
    80001520:	6161                	addi	sp,sp,80
    80001522:	8082                	ret
  return 0;
    80001524:	4501                	li	a0,0
}
    80001526:	8082                	ret

0000000080001528 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001528:	1141                	addi	sp,sp,-16
    8000152a:	e406                	sd	ra,8(sp)
    8000152c:	e022                	sd	s0,0(sp)
    8000152e:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001530:	4601                	li	a2,0
    80001532:	a0bff0ef          	jal	80000f3c <walk>
  if(pte == 0)
    80001536:	c901                	beqz	a0,80001546 <uvmclear+0x1e>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001538:	611c                	ld	a5,0(a0)
    8000153a:	9bbd                	andi	a5,a5,-17
    8000153c:	e11c                	sd	a5,0(a0)
}
    8000153e:	60a2                	ld	ra,8(sp)
    80001540:	6402                	ld	s0,0(sp)
    80001542:	0141                	addi	sp,sp,16
    80001544:	8082                	ret
    panic("uvmclear");
    80001546:	00006517          	auipc	a0,0x6
    8000154a:	c9a50513          	addi	a0,a0,-870 # 800071e0 <etext+0x1e0>
    8000154e:	a46ff0ef          	jal	80000794 <panic>

0000000080001552 <copyout>:
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;
  pte_t *pte;

  while(len > 0){
    80001552:	cad1                	beqz	a3,800015e6 <copyout+0x94>
{
    80001554:	711d                	addi	sp,sp,-96
    80001556:	ec86                	sd	ra,88(sp)
    80001558:	e8a2                	sd	s0,80(sp)
    8000155a:	e4a6                	sd	s1,72(sp)
    8000155c:	fc4e                	sd	s3,56(sp)
    8000155e:	f456                	sd	s5,40(sp)
    80001560:	f05a                	sd	s6,32(sp)
    80001562:	ec5e                	sd	s7,24(sp)
    80001564:	1080                	addi	s0,sp,96
    80001566:	8baa                	mv	s7,a0
    80001568:	8aae                	mv	s5,a1
    8000156a:	8b32                	mv	s6,a2
    8000156c:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    8000156e:	74fd                	lui	s1,0xfffff
    80001570:	8ced                	and	s1,s1,a1
    if(va0 >= MAXVA)
    80001572:	57fd                	li	a5,-1
    80001574:	83e9                	srli	a5,a5,0x1a
    80001576:	0697ea63          	bltu	a5,s1,800015ea <copyout+0x98>
    8000157a:	e0ca                	sd	s2,64(sp)
    8000157c:	f852                	sd	s4,48(sp)
    8000157e:	e862                	sd	s8,16(sp)
    80001580:	e466                	sd	s9,8(sp)
    80001582:	e06a                	sd	s10,0(sp)
      return -1;
    pte = walk(pagetable, va0, 0);
    if(pte == 0 || (*pte & PTE_V) == 0 || (*pte & PTE_U) == 0 ||
    80001584:	4cd5                	li	s9,21
    80001586:	6d05                	lui	s10,0x1
    if(va0 >= MAXVA)
    80001588:	8c3e                	mv	s8,a5
    8000158a:	a025                	j	800015b2 <copyout+0x60>
       (*pte & PTE_W) == 0)
      return -1;
    pa0 = PTE2PA(*pte);
    8000158c:	83a9                	srli	a5,a5,0xa
    8000158e:	07b2                	slli	a5,a5,0xc
    n = PGSIZE - (dstva - va0);
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001590:	409a8533          	sub	a0,s5,s1
    80001594:	0009061b          	sext.w	a2,s2
    80001598:	85da                	mv	a1,s6
    8000159a:	953e                	add	a0,a0,a5
    8000159c:	f88ff0ef          	jal	80000d24 <memmove>

    len -= n;
    800015a0:	412989b3          	sub	s3,s3,s2
    src += n;
    800015a4:	9b4a                	add	s6,s6,s2
  while(len > 0){
    800015a6:	02098963          	beqz	s3,800015d8 <copyout+0x86>
    if(va0 >= MAXVA)
    800015aa:	054c6263          	bltu	s8,s4,800015ee <copyout+0x9c>
    800015ae:	84d2                	mv	s1,s4
    800015b0:	8ad2                	mv	s5,s4
    pte = walk(pagetable, va0, 0);
    800015b2:	4601                	li	a2,0
    800015b4:	85a6                	mv	a1,s1
    800015b6:	855e                	mv	a0,s7
    800015b8:	985ff0ef          	jal	80000f3c <walk>
    if(pte == 0 || (*pte & PTE_V) == 0 || (*pte & PTE_U) == 0 ||
    800015bc:	c121                	beqz	a0,800015fc <copyout+0xaa>
    800015be:	611c                	ld	a5,0(a0)
    800015c0:	0157f713          	andi	a4,a5,21
    800015c4:	05971b63          	bne	a4,s9,8000161a <copyout+0xc8>
    n = PGSIZE - (dstva - va0);
    800015c8:	01a48a33          	add	s4,s1,s10
    800015cc:	415a0933          	sub	s2,s4,s5
    if(n > len)
    800015d0:	fb29fee3          	bgeu	s3,s2,8000158c <copyout+0x3a>
    800015d4:	894e                	mv	s2,s3
    800015d6:	bf5d                	j	8000158c <copyout+0x3a>
    dstva = va0 + PGSIZE;
  }
  return 0;
    800015d8:	4501                	li	a0,0
    800015da:	6906                	ld	s2,64(sp)
    800015dc:	7a42                	ld	s4,48(sp)
    800015de:	6c42                	ld	s8,16(sp)
    800015e0:	6ca2                	ld	s9,8(sp)
    800015e2:	6d02                	ld	s10,0(sp)
    800015e4:	a015                	j	80001608 <copyout+0xb6>
    800015e6:	4501                	li	a0,0
}
    800015e8:	8082                	ret
      return -1;
    800015ea:	557d                	li	a0,-1
    800015ec:	a831                	j	80001608 <copyout+0xb6>
    800015ee:	557d                	li	a0,-1
    800015f0:	6906                	ld	s2,64(sp)
    800015f2:	7a42                	ld	s4,48(sp)
    800015f4:	6c42                	ld	s8,16(sp)
    800015f6:	6ca2                	ld	s9,8(sp)
    800015f8:	6d02                	ld	s10,0(sp)
    800015fa:	a039                	j	80001608 <copyout+0xb6>
      return -1;
    800015fc:	557d                	li	a0,-1
    800015fe:	6906                	ld	s2,64(sp)
    80001600:	7a42                	ld	s4,48(sp)
    80001602:	6c42                	ld	s8,16(sp)
    80001604:	6ca2                	ld	s9,8(sp)
    80001606:	6d02                	ld	s10,0(sp)
}
    80001608:	60e6                	ld	ra,88(sp)
    8000160a:	6446                	ld	s0,80(sp)
    8000160c:	64a6                	ld	s1,72(sp)
    8000160e:	79e2                	ld	s3,56(sp)
    80001610:	7aa2                	ld	s5,40(sp)
    80001612:	7b02                	ld	s6,32(sp)
    80001614:	6be2                	ld	s7,24(sp)
    80001616:	6125                	addi	sp,sp,96
    80001618:	8082                	ret
      return -1;
    8000161a:	557d                	li	a0,-1
    8000161c:	6906                	ld	s2,64(sp)
    8000161e:	7a42                	ld	s4,48(sp)
    80001620:	6c42                	ld	s8,16(sp)
    80001622:	6ca2                	ld	s9,8(sp)
    80001624:	6d02                	ld	s10,0(sp)
    80001626:	b7cd                	j	80001608 <copyout+0xb6>

0000000080001628 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001628:	c6a5                	beqz	a3,80001690 <copyin+0x68>
{
    8000162a:	715d                	addi	sp,sp,-80
    8000162c:	e486                	sd	ra,72(sp)
    8000162e:	e0a2                	sd	s0,64(sp)
    80001630:	fc26                	sd	s1,56(sp)
    80001632:	f84a                	sd	s2,48(sp)
    80001634:	f44e                	sd	s3,40(sp)
    80001636:	f052                	sd	s4,32(sp)
    80001638:	ec56                	sd	s5,24(sp)
    8000163a:	e85a                	sd	s6,16(sp)
    8000163c:	e45e                	sd	s7,8(sp)
    8000163e:	e062                	sd	s8,0(sp)
    80001640:	0880                	addi	s0,sp,80
    80001642:	8b2a                	mv	s6,a0
    80001644:	8a2e                	mv	s4,a1
    80001646:	8c32                	mv	s8,a2
    80001648:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    8000164a:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000164c:	6a85                	lui	s5,0x1
    8000164e:	a00d                	j	80001670 <copyin+0x48>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001650:	018505b3          	add	a1,a0,s8
    80001654:	0004861b          	sext.w	a2,s1
    80001658:	412585b3          	sub	a1,a1,s2
    8000165c:	8552                	mv	a0,s4
    8000165e:	ec6ff0ef          	jal	80000d24 <memmove>

    len -= n;
    80001662:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001666:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001668:	01590c33          	add	s8,s2,s5
  while(len > 0){
    8000166c:	02098063          	beqz	s3,8000168c <copyin+0x64>
    va0 = PGROUNDDOWN(srcva);
    80001670:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001674:	85ca                	mv	a1,s2
    80001676:	855a                	mv	a0,s6
    80001678:	95fff0ef          	jal	80000fd6 <walkaddr>
    if(pa0 == 0)
    8000167c:	cd01                	beqz	a0,80001694 <copyin+0x6c>
    n = PGSIZE - (srcva - va0);
    8000167e:	418904b3          	sub	s1,s2,s8
    80001682:	94d6                	add	s1,s1,s5
    if(n > len)
    80001684:	fc99f6e3          	bgeu	s3,s1,80001650 <copyin+0x28>
    80001688:	84ce                	mv	s1,s3
    8000168a:	b7d9                	j	80001650 <copyin+0x28>
  }
  return 0;
    8000168c:	4501                	li	a0,0
    8000168e:	a021                	j	80001696 <copyin+0x6e>
    80001690:	4501                	li	a0,0
}
    80001692:	8082                	ret
      return -1;
    80001694:	557d                	li	a0,-1
}
    80001696:	60a6                	ld	ra,72(sp)
    80001698:	6406                	ld	s0,64(sp)
    8000169a:	74e2                	ld	s1,56(sp)
    8000169c:	7942                	ld	s2,48(sp)
    8000169e:	79a2                	ld	s3,40(sp)
    800016a0:	7a02                	ld	s4,32(sp)
    800016a2:	6ae2                	ld	s5,24(sp)
    800016a4:	6b42                	ld	s6,16(sp)
    800016a6:	6ba2                	ld	s7,8(sp)
    800016a8:	6c02                	ld	s8,0(sp)
    800016aa:	6161                	addi	sp,sp,80
    800016ac:	8082                	ret

00000000800016ae <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    800016ae:	c6dd                	beqz	a3,8000175c <copyinstr+0xae>
{
    800016b0:	715d                	addi	sp,sp,-80
    800016b2:	e486                	sd	ra,72(sp)
    800016b4:	e0a2                	sd	s0,64(sp)
    800016b6:	fc26                	sd	s1,56(sp)
    800016b8:	f84a                	sd	s2,48(sp)
    800016ba:	f44e                	sd	s3,40(sp)
    800016bc:	f052                	sd	s4,32(sp)
    800016be:	ec56                	sd	s5,24(sp)
    800016c0:	e85a                	sd	s6,16(sp)
    800016c2:	e45e                	sd	s7,8(sp)
    800016c4:	0880                	addi	s0,sp,80
    800016c6:	8a2a                	mv	s4,a0
    800016c8:	8b2e                	mv	s6,a1
    800016ca:	8bb2                	mv	s7,a2
    800016cc:	8936                	mv	s2,a3
    va0 = PGROUNDDOWN(srcva);
    800016ce:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800016d0:	6985                	lui	s3,0x1
    800016d2:	a825                	j	8000170a <copyinstr+0x5c>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800016d4:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800016d8:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800016da:	37fd                	addiw	a5,a5,-1
    800016dc:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800016e0:	60a6                	ld	ra,72(sp)
    800016e2:	6406                	ld	s0,64(sp)
    800016e4:	74e2                	ld	s1,56(sp)
    800016e6:	7942                	ld	s2,48(sp)
    800016e8:	79a2                	ld	s3,40(sp)
    800016ea:	7a02                	ld	s4,32(sp)
    800016ec:	6ae2                	ld	s5,24(sp)
    800016ee:	6b42                	ld	s6,16(sp)
    800016f0:	6ba2                	ld	s7,8(sp)
    800016f2:	6161                	addi	sp,sp,80
    800016f4:	8082                	ret
    800016f6:	fff90713          	addi	a4,s2,-1 # fff <_entry-0x7ffff001>
    800016fa:	9742                	add	a4,a4,a6
      --max;
    800016fc:	40b70933          	sub	s2,a4,a1
    srcva = va0 + PGSIZE;
    80001700:	01348bb3          	add	s7,s1,s3
  while(got_null == 0 && max > 0){
    80001704:	04e58463          	beq	a1,a4,8000174c <copyinstr+0x9e>
{
    80001708:	8b3e                	mv	s6,a5
    va0 = PGROUNDDOWN(srcva);
    8000170a:	015bf4b3          	and	s1,s7,s5
    pa0 = walkaddr(pagetable, va0);
    8000170e:	85a6                	mv	a1,s1
    80001710:	8552                	mv	a0,s4
    80001712:	8c5ff0ef          	jal	80000fd6 <walkaddr>
    if(pa0 == 0)
    80001716:	cd0d                	beqz	a0,80001750 <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    80001718:	417486b3          	sub	a3,s1,s7
    8000171c:	96ce                	add	a3,a3,s3
    if(n > max)
    8000171e:	00d97363          	bgeu	s2,a3,80001724 <copyinstr+0x76>
    80001722:	86ca                	mv	a3,s2
    char *p = (char *) (pa0 + (srcva - va0));
    80001724:	955e                	add	a0,a0,s7
    80001726:	8d05                	sub	a0,a0,s1
    while(n > 0){
    80001728:	c695                	beqz	a3,80001754 <copyinstr+0xa6>
    8000172a:	87da                	mv	a5,s6
    8000172c:	885a                	mv	a6,s6
      if(*p == '\0'){
    8000172e:	41650633          	sub	a2,a0,s6
    while(n > 0){
    80001732:	96da                	add	a3,a3,s6
    80001734:	85be                	mv	a1,a5
      if(*p == '\0'){
    80001736:	00f60733          	add	a4,a2,a5
    8000173a:	00074703          	lbu	a4,0(a4)
    8000173e:	db59                	beqz	a4,800016d4 <copyinstr+0x26>
        *dst = *p;
    80001740:	00e78023          	sb	a4,0(a5)
      dst++;
    80001744:	0785                	addi	a5,a5,1
    while(n > 0){
    80001746:	fed797e3          	bne	a5,a3,80001734 <copyinstr+0x86>
    8000174a:	b775                	j	800016f6 <copyinstr+0x48>
    8000174c:	4781                	li	a5,0
    8000174e:	b771                	j	800016da <copyinstr+0x2c>
      return -1;
    80001750:	557d                	li	a0,-1
    80001752:	b779                	j	800016e0 <copyinstr+0x32>
    srcva = va0 + PGSIZE;
    80001754:	6b85                	lui	s7,0x1
    80001756:	9ba6                	add	s7,s7,s1
    80001758:	87da                	mv	a5,s6
    8000175a:	b77d                	j	80001708 <copyinstr+0x5a>
  int got_null = 0;
    8000175c:	4781                	li	a5,0
  if(got_null){
    8000175e:	37fd                	addiw	a5,a5,-1
    80001760:	0007851b          	sext.w	a0,a5
}
    80001764:	8082                	ret

0000000080001766 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    80001766:	7139                	addi	sp,sp,-64
    80001768:	fc06                	sd	ra,56(sp)
    8000176a:	f822                	sd	s0,48(sp)
    8000176c:	f426                	sd	s1,40(sp)
    8000176e:	f04a                	sd	s2,32(sp)
    80001770:	ec4e                	sd	s3,24(sp)
    80001772:	e852                	sd	s4,16(sp)
    80001774:	e456                	sd	s5,8(sp)
    80001776:	e05a                	sd	s6,0(sp)
    80001778:	0080                	addi	s0,sp,64
    8000177a:	8a2a                	mv	s4,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    8000177c:	00011497          	auipc	s1,0x11
    80001780:	19448493          	addi	s1,s1,404 # 80012910 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80001784:	8b26                	mv	s6,s1
    80001786:	ff4df937          	lui	s2,0xff4df
    8000178a:	9bd90913          	addi	s2,s2,-1603 # ffffffffff4de9bd <end+0xffffffff7f4b54b5>
    8000178e:	0936                	slli	s2,s2,0xd
    80001790:	6f590913          	addi	s2,s2,1781
    80001794:	0936                	slli	s2,s2,0xd
    80001796:	bd390913          	addi	s2,s2,-1069
    8000179a:	0932                	slli	s2,s2,0xc
    8000179c:	7a790913          	addi	s2,s2,1959
    800017a0:	040009b7          	lui	s3,0x4000
    800017a4:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    800017a6:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    800017a8:	00017a97          	auipc	s5,0x17
    800017ac:	d68a8a93          	addi	s5,s5,-664 # 80018510 <ptable>
    char *pa = kalloc();
    800017b0:	b74ff0ef          	jal	80000b24 <kalloc>
    800017b4:	862a                	mv	a2,a0
    if(pa == 0)
    800017b6:	cd15                	beqz	a0,800017f2 <proc_mapstacks+0x8c>
    uint64 va = KSTACK((int) (p - proc));
    800017b8:	416485b3          	sub	a1,s1,s6
    800017bc:	8591                	srai	a1,a1,0x4
    800017be:	032585b3          	mul	a1,a1,s2
    800017c2:	2585                	addiw	a1,a1,1
    800017c4:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800017c8:	4719                	li	a4,6
    800017ca:	6685                	lui	a3,0x1
    800017cc:	40b985b3          	sub	a1,s3,a1
    800017d0:	8552                	mv	a0,s4
    800017d2:	8f3ff0ef          	jal	800010c4 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    800017d6:	17048493          	addi	s1,s1,368
    800017da:	fd549be3          	bne	s1,s5,800017b0 <proc_mapstacks+0x4a>
  }
}
    800017de:	70e2                	ld	ra,56(sp)
    800017e0:	7442                	ld	s0,48(sp)
    800017e2:	74a2                	ld	s1,40(sp)
    800017e4:	7902                	ld	s2,32(sp)
    800017e6:	69e2                	ld	s3,24(sp)
    800017e8:	6a42                	ld	s4,16(sp)
    800017ea:	6aa2                	ld	s5,8(sp)
    800017ec:	6b02                	ld	s6,0(sp)
    800017ee:	6121                	addi	sp,sp,64
    800017f0:	8082                	ret
      panic("kalloc");
    800017f2:	00006517          	auipc	a0,0x6
    800017f6:	9fe50513          	addi	a0,a0,-1538 # 800071f0 <etext+0x1f0>
    800017fa:	f9bfe0ef          	jal	80000794 <panic>

00000000800017fe <procinit>:

// initialize the proc table.
void
procinit(void)
{
    800017fe:	7139                	addi	sp,sp,-64
    80001800:	fc06                	sd	ra,56(sp)
    80001802:	f822                	sd	s0,48(sp)
    80001804:	f426                	sd	s1,40(sp)
    80001806:	f04a                	sd	s2,32(sp)
    80001808:	ec4e                	sd	s3,24(sp)
    8000180a:	e852                	sd	s4,16(sp)
    8000180c:	e456                	sd	s5,8(sp)
    8000180e:	e05a                	sd	s6,0(sp)
    80001810:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    80001812:	00006597          	auipc	a1,0x6
    80001816:	9e658593          	addi	a1,a1,-1562 # 800071f8 <etext+0x1f8>
    8000181a:	00011517          	auipc	a0,0x11
    8000181e:	cc650513          	addi	a0,a0,-826 # 800124e0 <pid_lock>
    80001822:	b52ff0ef          	jal	80000b74 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001826:	00006597          	auipc	a1,0x6
    8000182a:	9da58593          	addi	a1,a1,-1574 # 80007200 <etext+0x200>
    8000182e:	00011517          	auipc	a0,0x11
    80001832:	cca50513          	addi	a0,a0,-822 # 800124f8 <wait_lock>
    80001836:	b3eff0ef          	jal	80000b74 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000183a:	00011497          	auipc	s1,0x11
    8000183e:	0d648493          	addi	s1,s1,214 # 80012910 <proc>
      initlock(&p->lock, "proc");
    80001842:	00006b17          	auipc	s6,0x6
    80001846:	9ceb0b13          	addi	s6,s6,-1586 # 80007210 <etext+0x210>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    8000184a:	8aa6                	mv	s5,s1
    8000184c:	ff4df937          	lui	s2,0xff4df
    80001850:	9bd90913          	addi	s2,s2,-1603 # ffffffffff4de9bd <end+0xffffffff7f4b54b5>
    80001854:	0936                	slli	s2,s2,0xd
    80001856:	6f590913          	addi	s2,s2,1781
    8000185a:	0936                	slli	s2,s2,0xd
    8000185c:	bd390913          	addi	s2,s2,-1069
    80001860:	0932                	slli	s2,s2,0xc
    80001862:	7a790913          	addi	s2,s2,1959
    80001866:	040009b7          	lui	s3,0x4000
    8000186a:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    8000186c:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    8000186e:	00017a17          	auipc	s4,0x17
    80001872:	ca2a0a13          	addi	s4,s4,-862 # 80018510 <ptable>
      initlock(&p->lock, "proc");
    80001876:	85da                	mv	a1,s6
    80001878:	8526                	mv	a0,s1
    8000187a:	afaff0ef          	jal	80000b74 <initlock>
      p->state = UNUSED;
    8000187e:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80001882:	415487b3          	sub	a5,s1,s5
    80001886:	8791                	srai	a5,a5,0x4
    80001888:	032787b3          	mul	a5,a5,s2
    8000188c:	2785                	addiw	a5,a5,1
    8000188e:	00d7979b          	slliw	a5,a5,0xd
    80001892:	40f987b3          	sub	a5,s3,a5
    80001896:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001898:	17048493          	addi	s1,s1,368
    8000189c:	fd449de3          	bne	s1,s4,80001876 <procinit+0x78>
  }
}
    800018a0:	70e2                	ld	ra,56(sp)
    800018a2:	7442                	ld	s0,48(sp)
    800018a4:	74a2                	ld	s1,40(sp)
    800018a6:	7902                	ld	s2,32(sp)
    800018a8:	69e2                	ld	s3,24(sp)
    800018aa:	6a42                	ld	s4,16(sp)
    800018ac:	6aa2                	ld	s5,8(sp)
    800018ae:	6b02                	ld	s6,0(sp)
    800018b0:	6121                	addi	sp,sp,64
    800018b2:	8082                	ret

00000000800018b4 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    800018b4:	1141                	addi	sp,sp,-16
    800018b6:	e422                	sd	s0,8(sp)
    800018b8:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    800018ba:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    800018bc:	2501                	sext.w	a0,a0
    800018be:	6422                	ld	s0,8(sp)
    800018c0:	0141                	addi	sp,sp,16
    800018c2:	8082                	ret

00000000800018c4 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    800018c4:	1141                	addi	sp,sp,-16
    800018c6:	e422                	sd	s0,8(sp)
    800018c8:	0800                	addi	s0,sp,16
    800018ca:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    800018cc:	2781                	sext.w	a5,a5
    800018ce:	079e                	slli	a5,a5,0x7
  return c;
}
    800018d0:	00011517          	auipc	a0,0x11
    800018d4:	c4050513          	addi	a0,a0,-960 # 80012510 <cpus>
    800018d8:	953e                	add	a0,a0,a5
    800018da:	6422                	ld	s0,8(sp)
    800018dc:	0141                	addi	sp,sp,16
    800018de:	8082                	ret

00000000800018e0 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    800018e0:	1101                	addi	sp,sp,-32
    800018e2:	ec06                	sd	ra,24(sp)
    800018e4:	e822                	sd	s0,16(sp)
    800018e6:	e426                	sd	s1,8(sp)
    800018e8:	1000                	addi	s0,sp,32
  push_off();
    800018ea:	acaff0ef          	jal	80000bb4 <push_off>
    800018ee:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    800018f0:	2781                	sext.w	a5,a5
    800018f2:	079e                	slli	a5,a5,0x7
    800018f4:	00011717          	auipc	a4,0x11
    800018f8:	bec70713          	addi	a4,a4,-1044 # 800124e0 <pid_lock>
    800018fc:	97ba                	add	a5,a5,a4
    800018fe:	7b84                	ld	s1,48(a5)
  pop_off();
    80001900:	b38ff0ef          	jal	80000c38 <pop_off>
  return p;
}
    80001904:	8526                	mv	a0,s1
    80001906:	60e2                	ld	ra,24(sp)
    80001908:	6442                	ld	s0,16(sp)
    8000190a:	64a2                	ld	s1,8(sp)
    8000190c:	6105                	addi	sp,sp,32
    8000190e:	8082                	ret

0000000080001910 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001910:	1141                	addi	sp,sp,-16
    80001912:	e406                	sd	ra,8(sp)
    80001914:	e022                	sd	s0,0(sp)
    80001916:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80001918:	fc9ff0ef          	jal	800018e0 <myproc>
    8000191c:	b70ff0ef          	jal	80000c8c <release>

  if (first) {
    80001920:	00009797          	auipc	a5,0x9
    80001924:	9f07a783          	lw	a5,-1552(a5) # 8000a310 <first.1>
    80001928:	e799                	bnez	a5,80001936 <forkret+0x26>
    first = 0;
    // ensure other cores see first=0.
    __sync_synchronize();
  }

  usertrapret();
    8000192a:	4a3000ef          	jal	800025cc <usertrapret>
}
    8000192e:	60a2                	ld	ra,8(sp)
    80001930:	6402                	ld	s0,0(sp)
    80001932:	0141                	addi	sp,sp,16
    80001934:	8082                	ret
    fsinit(ROOTDEV);
    80001936:	4505                	li	a0,1
    80001938:	06f010ef          	jal	800031a6 <fsinit>
    first = 0;
    8000193c:	00009797          	auipc	a5,0x9
    80001940:	9c07aa23          	sw	zero,-1580(a5) # 8000a310 <first.1>
    __sync_synchronize();
    80001944:	0330000f          	fence	rw,rw
    80001948:	b7cd                	j	8000192a <forkret+0x1a>

000000008000194a <allocpid>:
{
    8000194a:	1101                	addi	sp,sp,-32
    8000194c:	ec06                	sd	ra,24(sp)
    8000194e:	e822                	sd	s0,16(sp)
    80001950:	e426                	sd	s1,8(sp)
    80001952:	e04a                	sd	s2,0(sp)
    80001954:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001956:	00011917          	auipc	s2,0x11
    8000195a:	b8a90913          	addi	s2,s2,-1142 # 800124e0 <pid_lock>
    8000195e:	854a                	mv	a0,s2
    80001960:	a94ff0ef          	jal	80000bf4 <acquire>
  pid = nextpid;
    80001964:	00009797          	auipc	a5,0x9
    80001968:	9b078793          	addi	a5,a5,-1616 # 8000a314 <nextpid>
    8000196c:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    8000196e:	0014871b          	addiw	a4,s1,1
    80001972:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001974:	854a                	mv	a0,s2
    80001976:	b16ff0ef          	jal	80000c8c <release>
}
    8000197a:	8526                	mv	a0,s1
    8000197c:	60e2                	ld	ra,24(sp)
    8000197e:	6442                	ld	s0,16(sp)
    80001980:	64a2                	ld	s1,8(sp)
    80001982:	6902                	ld	s2,0(sp)
    80001984:	6105                	addi	sp,sp,32
    80001986:	8082                	ret

0000000080001988 <proc_pagetable>:
{
    80001988:	1101                	addi	sp,sp,-32
    8000198a:	ec06                	sd	ra,24(sp)
    8000198c:	e822                	sd	s0,16(sp)
    8000198e:	e426                	sd	s1,8(sp)
    80001990:	e04a                	sd	s2,0(sp)
    80001992:	1000                	addi	s0,sp,32
    80001994:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001996:	8e1ff0ef          	jal	80001276 <uvmcreate>
    8000199a:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000199c:	cd05                	beqz	a0,800019d4 <proc_pagetable+0x4c>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    8000199e:	4729                	li	a4,10
    800019a0:	00004697          	auipc	a3,0x4
    800019a4:	66068693          	addi	a3,a3,1632 # 80006000 <_trampoline>
    800019a8:	6605                	lui	a2,0x1
    800019aa:	040005b7          	lui	a1,0x4000
    800019ae:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800019b0:	05b2                	slli	a1,a1,0xc
    800019b2:	e62ff0ef          	jal	80001014 <mappages>
    800019b6:	02054663          	bltz	a0,800019e2 <proc_pagetable+0x5a>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    800019ba:	4719                	li	a4,6
    800019bc:	05893683          	ld	a3,88(s2)
    800019c0:	6605                	lui	a2,0x1
    800019c2:	020005b7          	lui	a1,0x2000
    800019c6:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    800019c8:	05b6                	slli	a1,a1,0xd
    800019ca:	8526                	mv	a0,s1
    800019cc:	e48ff0ef          	jal	80001014 <mappages>
    800019d0:	00054f63          	bltz	a0,800019ee <proc_pagetable+0x66>
}
    800019d4:	8526                	mv	a0,s1
    800019d6:	60e2                	ld	ra,24(sp)
    800019d8:	6442                	ld	s0,16(sp)
    800019da:	64a2                	ld	s1,8(sp)
    800019dc:	6902                	ld	s2,0(sp)
    800019de:	6105                	addi	sp,sp,32
    800019e0:	8082                	ret
    uvmfree(pagetable, 0);
    800019e2:	4581                	li	a1,0
    800019e4:	8526                	mv	a0,s1
    800019e6:	a5fff0ef          	jal	80001444 <uvmfree>
    return 0;
    800019ea:	4481                	li	s1,0
    800019ec:	b7e5                	j	800019d4 <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    800019ee:	4681                	li	a3,0
    800019f0:	4605                	li	a2,1
    800019f2:	040005b7          	lui	a1,0x4000
    800019f6:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800019f8:	05b2                	slli	a1,a1,0xc
    800019fa:	8526                	mv	a0,s1
    800019fc:	fbeff0ef          	jal	800011ba <uvmunmap>
    uvmfree(pagetable, 0);
    80001a00:	4581                	li	a1,0
    80001a02:	8526                	mv	a0,s1
    80001a04:	a41ff0ef          	jal	80001444 <uvmfree>
    return 0;
    80001a08:	4481                	li	s1,0
    80001a0a:	b7e9                	j	800019d4 <proc_pagetable+0x4c>

0000000080001a0c <proc_freepagetable>:
{
    80001a0c:	1101                	addi	sp,sp,-32
    80001a0e:	ec06                	sd	ra,24(sp)
    80001a10:	e822                	sd	s0,16(sp)
    80001a12:	e426                	sd	s1,8(sp)
    80001a14:	e04a                	sd	s2,0(sp)
    80001a16:	1000                	addi	s0,sp,32
    80001a18:	84aa                	mv	s1,a0
    80001a1a:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001a1c:	4681                	li	a3,0
    80001a1e:	4605                	li	a2,1
    80001a20:	040005b7          	lui	a1,0x4000
    80001a24:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001a26:	05b2                	slli	a1,a1,0xc
    80001a28:	f92ff0ef          	jal	800011ba <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001a2c:	4681                	li	a3,0
    80001a2e:	4605                	li	a2,1
    80001a30:	020005b7          	lui	a1,0x2000
    80001a34:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001a36:	05b6                	slli	a1,a1,0xd
    80001a38:	8526                	mv	a0,s1
    80001a3a:	f80ff0ef          	jal	800011ba <uvmunmap>
  uvmfree(pagetable, sz);
    80001a3e:	85ca                	mv	a1,s2
    80001a40:	8526                	mv	a0,s1
    80001a42:	a03ff0ef          	jal	80001444 <uvmfree>
}
    80001a46:	60e2                	ld	ra,24(sp)
    80001a48:	6442                	ld	s0,16(sp)
    80001a4a:	64a2                	ld	s1,8(sp)
    80001a4c:	6902                	ld	s2,0(sp)
    80001a4e:	6105                	addi	sp,sp,32
    80001a50:	8082                	ret

0000000080001a52 <freeproc>:
{
    80001a52:	1101                	addi	sp,sp,-32
    80001a54:	ec06                	sd	ra,24(sp)
    80001a56:	e822                	sd	s0,16(sp)
    80001a58:	e426                	sd	s1,8(sp)
    80001a5a:	1000                	addi	s0,sp,32
    80001a5c:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001a5e:	6d28                	ld	a0,88(a0)
    80001a60:	c119                	beqz	a0,80001a66 <freeproc+0x14>
    kfree((void*)p->trapframe);
    80001a62:	fe1fe0ef          	jal	80000a42 <kfree>
  p->trapframe = 0;
    80001a66:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001a6a:	68a8                	ld	a0,80(s1)
    80001a6c:	c501                	beqz	a0,80001a74 <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80001a6e:	64ac                	ld	a1,72(s1)
    80001a70:	f9dff0ef          	jal	80001a0c <proc_freepagetable>
  p->pagetable = 0;
    80001a74:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001a78:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001a7c:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001a80:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001a84:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001a88:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001a8c:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001a90:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001a94:	0004ac23          	sw	zero,24(s1)
}
    80001a98:	60e2                	ld	ra,24(sp)
    80001a9a:	6442                	ld	s0,16(sp)
    80001a9c:	64a2                	ld	s1,8(sp)
    80001a9e:	6105                	addi	sp,sp,32
    80001aa0:	8082                	ret

0000000080001aa2 <allocproc>:
{
    80001aa2:	1101                	addi	sp,sp,-32
    80001aa4:	ec06                	sd	ra,24(sp)
    80001aa6:	e822                	sd	s0,16(sp)
    80001aa8:	e426                	sd	s1,8(sp)
    80001aaa:	e04a                	sd	s2,0(sp)
    80001aac:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001aae:	00011497          	auipc	s1,0x11
    80001ab2:	e6248493          	addi	s1,s1,-414 # 80012910 <proc>
    80001ab6:	00017917          	auipc	s2,0x17
    80001aba:	a5a90913          	addi	s2,s2,-1446 # 80018510 <ptable>
    acquire(&p->lock);
    80001abe:	8526                	mv	a0,s1
    80001ac0:	934ff0ef          	jal	80000bf4 <acquire>
    if(p->state == UNUSED) {
    80001ac4:	4c9c                	lw	a5,24(s1)
    80001ac6:	cb91                	beqz	a5,80001ada <allocproc+0x38>
      release(&p->lock);
    80001ac8:	8526                	mv	a0,s1
    80001aca:	9c2ff0ef          	jal	80000c8c <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001ace:	17048493          	addi	s1,s1,368
    80001ad2:	ff2496e3          	bne	s1,s2,80001abe <allocproc+0x1c>
  return 0;
    80001ad6:	4481                	li	s1,0
    80001ad8:	a089                	j	80001b1a <allocproc+0x78>
  p->pid = allocpid();
    80001ada:	e71ff0ef          	jal	8000194a <allocpid>
    80001ade:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001ae0:	4785                	li	a5,1
    80001ae2:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001ae4:	840ff0ef          	jal	80000b24 <kalloc>
    80001ae8:	892a                	mv	s2,a0
    80001aea:	eca8                	sd	a0,88(s1)
    80001aec:	cd15                	beqz	a0,80001b28 <allocproc+0x86>
  p->pagetable = proc_pagetable(p);
    80001aee:	8526                	mv	a0,s1
    80001af0:	e99ff0ef          	jal	80001988 <proc_pagetable>
    80001af4:	892a                	mv	s2,a0
    80001af6:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001af8:	c121                	beqz	a0,80001b38 <allocproc+0x96>
  memset(&p->context, 0, sizeof(p->context));
    80001afa:	07000613          	li	a2,112
    80001afe:	4581                	li	a1,0
    80001b00:	06048513          	addi	a0,s1,96
    80001b04:	9c4ff0ef          	jal	80000cc8 <memset>
  p->context.ra = (uint64)forkret;
    80001b08:	00000797          	auipc	a5,0x0
    80001b0c:	e0878793          	addi	a5,a5,-504 # 80001910 <forkret>
    80001b10:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001b12:	60bc                	ld	a5,64(s1)
    80001b14:	6705                	lui	a4,0x1
    80001b16:	97ba                	add	a5,a5,a4
    80001b18:	f4bc                	sd	a5,104(s1)
}
    80001b1a:	8526                	mv	a0,s1
    80001b1c:	60e2                	ld	ra,24(sp)
    80001b1e:	6442                	ld	s0,16(sp)
    80001b20:	64a2                	ld	s1,8(sp)
    80001b22:	6902                	ld	s2,0(sp)
    80001b24:	6105                	addi	sp,sp,32
    80001b26:	8082                	ret
    freeproc(p);
    80001b28:	8526                	mv	a0,s1
    80001b2a:	f29ff0ef          	jal	80001a52 <freeproc>
    release(&p->lock);
    80001b2e:	8526                	mv	a0,s1
    80001b30:	95cff0ef          	jal	80000c8c <release>
    return 0;
    80001b34:	84ca                	mv	s1,s2
    80001b36:	b7d5                	j	80001b1a <allocproc+0x78>
    freeproc(p);
    80001b38:	8526                	mv	a0,s1
    80001b3a:	f19ff0ef          	jal	80001a52 <freeproc>
    release(&p->lock);
    80001b3e:	8526                	mv	a0,s1
    80001b40:	94cff0ef          	jal	80000c8c <release>
    return 0;
    80001b44:	84ca                	mv	s1,s2
    80001b46:	bfd1                	j	80001b1a <allocproc+0x78>

0000000080001b48 <userinit>:
{
    80001b48:	1101                	addi	sp,sp,-32
    80001b4a:	ec06                	sd	ra,24(sp)
    80001b4c:	e822                	sd	s0,16(sp)
    80001b4e:	e426                	sd	s1,8(sp)
    80001b50:	1000                	addi	s0,sp,32
  p = allocproc();
    80001b52:	f51ff0ef          	jal	80001aa2 <allocproc>
    80001b56:	84aa                	mv	s1,a0
  initproc = p;
    80001b58:	00009797          	auipc	a5,0x9
    80001b5c:	84a7b823          	sd	a0,-1968(a5) # 8000a3a8 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001b60:	03400613          	li	a2,52
    80001b64:	00008597          	auipc	a1,0x8
    80001b68:	7bc58593          	addi	a1,a1,1980 # 8000a320 <initcode>
    80001b6c:	6928                	ld	a0,80(a0)
    80001b6e:	f2eff0ef          	jal	8000129c <uvmfirst>
  p->sz = PGSIZE;
    80001b72:	6785                	lui	a5,0x1
    80001b74:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001b76:	6cb8                	ld	a4,88(s1)
    80001b78:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001b7c:	6cb8                	ld	a4,88(s1)
    80001b7e:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001b80:	4641                	li	a2,16
    80001b82:	00005597          	auipc	a1,0x5
    80001b86:	69658593          	addi	a1,a1,1686 # 80007218 <etext+0x218>
    80001b8a:	15848513          	addi	a0,s1,344
    80001b8e:	a78ff0ef          	jal	80000e06 <safestrcpy>
  p->cwd = namei("/");
    80001b92:	00005517          	auipc	a0,0x5
    80001b96:	69650513          	addi	a0,a0,1686 # 80007228 <etext+0x228>
    80001b9a:	71b010ef          	jal	80003ab4 <namei>
    80001b9e:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001ba2:	478d                	li	a5,3
    80001ba4:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001ba6:	8526                	mv	a0,s1
    80001ba8:	8e4ff0ef          	jal	80000c8c <release>
}
    80001bac:	60e2                	ld	ra,24(sp)
    80001bae:	6442                	ld	s0,16(sp)
    80001bb0:	64a2                	ld	s1,8(sp)
    80001bb2:	6105                	addi	sp,sp,32
    80001bb4:	8082                	ret

0000000080001bb6 <growproc>:
{
    80001bb6:	1101                	addi	sp,sp,-32
    80001bb8:	ec06                	sd	ra,24(sp)
    80001bba:	e822                	sd	s0,16(sp)
    80001bbc:	e426                	sd	s1,8(sp)
    80001bbe:	e04a                	sd	s2,0(sp)
    80001bc0:	1000                	addi	s0,sp,32
    80001bc2:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001bc4:	d1dff0ef          	jal	800018e0 <myproc>
    80001bc8:	84aa                	mv	s1,a0
  sz = p->sz;
    80001bca:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001bcc:	01204c63          	bgtz	s2,80001be4 <growproc+0x2e>
  } else if(n < 0){
    80001bd0:	02094463          	bltz	s2,80001bf8 <growproc+0x42>
  p->sz = sz;
    80001bd4:	e4ac                	sd	a1,72(s1)
  return 0;
    80001bd6:	4501                	li	a0,0
}
    80001bd8:	60e2                	ld	ra,24(sp)
    80001bda:	6442                	ld	s0,16(sp)
    80001bdc:	64a2                	ld	s1,8(sp)
    80001bde:	6902                	ld	s2,0(sp)
    80001be0:	6105                	addi	sp,sp,32
    80001be2:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001be4:	4691                	li	a3,4
    80001be6:	00b90633          	add	a2,s2,a1
    80001bea:	6928                	ld	a0,80(a0)
    80001bec:	f52ff0ef          	jal	8000133e <uvmalloc>
    80001bf0:	85aa                	mv	a1,a0
    80001bf2:	f16d                	bnez	a0,80001bd4 <growproc+0x1e>
      return -1;
    80001bf4:	557d                	li	a0,-1
    80001bf6:	b7cd                	j	80001bd8 <growproc+0x22>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001bf8:	00b90633          	add	a2,s2,a1
    80001bfc:	6928                	ld	a0,80(a0)
    80001bfe:	efcff0ef          	jal	800012fa <uvmdealloc>
    80001c02:	85aa                	mv	a1,a0
    80001c04:	bfc1                	j	80001bd4 <growproc+0x1e>

0000000080001c06 <fork>:
{
    80001c06:	7139                	addi	sp,sp,-64
    80001c08:	fc06                	sd	ra,56(sp)
    80001c0a:	f822                	sd	s0,48(sp)
    80001c0c:	f04a                	sd	s2,32(sp)
    80001c0e:	e456                	sd	s5,8(sp)
    80001c10:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001c12:	ccfff0ef          	jal	800018e0 <myproc>
    80001c16:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001c18:	e8bff0ef          	jal	80001aa2 <allocproc>
    80001c1c:	0e050a63          	beqz	a0,80001d10 <fork+0x10a>
    80001c20:	e852                	sd	s4,16(sp)
    80001c22:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001c24:	048ab603          	ld	a2,72(s5)
    80001c28:	692c                	ld	a1,80(a0)
    80001c2a:	050ab503          	ld	a0,80(s5)
    80001c2e:	849ff0ef          	jal	80001476 <uvmcopy>
    80001c32:	04054a63          	bltz	a0,80001c86 <fork+0x80>
    80001c36:	f426                	sd	s1,40(sp)
    80001c38:	ec4e                	sd	s3,24(sp)
  np->sz = p->sz;
    80001c3a:	048ab783          	ld	a5,72(s5)
    80001c3e:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001c42:	058ab683          	ld	a3,88(s5)
    80001c46:	87b6                	mv	a5,a3
    80001c48:	058a3703          	ld	a4,88(s4)
    80001c4c:	12068693          	addi	a3,a3,288
    80001c50:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001c54:	6788                	ld	a0,8(a5)
    80001c56:	6b8c                	ld	a1,16(a5)
    80001c58:	6f90                	ld	a2,24(a5)
    80001c5a:	01073023          	sd	a6,0(a4)
    80001c5e:	e708                	sd	a0,8(a4)
    80001c60:	eb0c                	sd	a1,16(a4)
    80001c62:	ef10                	sd	a2,24(a4)
    80001c64:	02078793          	addi	a5,a5,32
    80001c68:	02070713          	addi	a4,a4,32
    80001c6c:	fed792e3          	bne	a5,a3,80001c50 <fork+0x4a>
  np->trapframe->a0 = 0;
    80001c70:	058a3783          	ld	a5,88(s4)
    80001c74:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001c78:	0d0a8493          	addi	s1,s5,208
    80001c7c:	0d0a0913          	addi	s2,s4,208
    80001c80:	150a8993          	addi	s3,s5,336
    80001c84:	a831                	j	80001ca0 <fork+0x9a>
    freeproc(np);
    80001c86:	8552                	mv	a0,s4
    80001c88:	dcbff0ef          	jal	80001a52 <freeproc>
    release(&np->lock);
    80001c8c:	8552                	mv	a0,s4
    80001c8e:	ffffe0ef          	jal	80000c8c <release>
    return -1;
    80001c92:	597d                	li	s2,-1
    80001c94:	6a42                	ld	s4,16(sp)
    80001c96:	a0b5                	j	80001d02 <fork+0xfc>
  for(i = 0; i < NOFILE; i++)
    80001c98:	04a1                	addi	s1,s1,8
    80001c9a:	0921                	addi	s2,s2,8
    80001c9c:	01348963          	beq	s1,s3,80001cae <fork+0xa8>
    if(p->ofile[i])
    80001ca0:	6088                	ld	a0,0(s1)
    80001ca2:	d97d                	beqz	a0,80001c98 <fork+0x92>
      np->ofile[i] = filedup(p->ofile[i]);
    80001ca4:	3a0020ef          	jal	80004044 <filedup>
    80001ca8:	00a93023          	sd	a0,0(s2)
    80001cac:	b7f5                	j	80001c98 <fork+0x92>
  np->cwd = idup(p->cwd);
    80001cae:	150ab503          	ld	a0,336(s5)
    80001cb2:	6f2010ef          	jal	800033a4 <idup>
    80001cb6:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001cba:	4641                	li	a2,16
    80001cbc:	158a8593          	addi	a1,s5,344
    80001cc0:	158a0513          	addi	a0,s4,344
    80001cc4:	942ff0ef          	jal	80000e06 <safestrcpy>
  pid = np->pid;
    80001cc8:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001ccc:	8552                	mv	a0,s4
    80001cce:	fbffe0ef          	jal	80000c8c <release>
  acquire(&wait_lock);
    80001cd2:	00011497          	auipc	s1,0x11
    80001cd6:	82648493          	addi	s1,s1,-2010 # 800124f8 <wait_lock>
    80001cda:	8526                	mv	a0,s1
    80001cdc:	f19fe0ef          	jal	80000bf4 <acquire>
  np->parent = p;
    80001ce0:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001ce4:	8526                	mv	a0,s1
    80001ce6:	fa7fe0ef          	jal	80000c8c <release>
  acquire(&np->lock);
    80001cea:	8552                	mv	a0,s4
    80001cec:	f09fe0ef          	jal	80000bf4 <acquire>
  np->state = RUNNABLE;
    80001cf0:	478d                	li	a5,3
    80001cf2:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001cf6:	8552                	mv	a0,s4
    80001cf8:	f95fe0ef          	jal	80000c8c <release>
  return pid;
    80001cfc:	74a2                	ld	s1,40(sp)
    80001cfe:	69e2                	ld	s3,24(sp)
    80001d00:	6a42                	ld	s4,16(sp)
}
    80001d02:	854a                	mv	a0,s2
    80001d04:	70e2                	ld	ra,56(sp)
    80001d06:	7442                	ld	s0,48(sp)
    80001d08:	7902                	ld	s2,32(sp)
    80001d0a:	6aa2                	ld	s5,8(sp)
    80001d0c:	6121                	addi	sp,sp,64
    80001d0e:	8082                	ret
    return -1;
    80001d10:	597d                	li	s2,-1
    80001d12:	bfc5                	j	80001d02 <fork+0xfc>

0000000080001d14 <scheduler>:
{
    80001d14:	715d                	addi	sp,sp,-80
    80001d16:	e486                	sd	ra,72(sp)
    80001d18:	e0a2                	sd	s0,64(sp)
    80001d1a:	fc26                	sd	s1,56(sp)
    80001d1c:	f84a                	sd	s2,48(sp)
    80001d1e:	f44e                	sd	s3,40(sp)
    80001d20:	f052                	sd	s4,32(sp)
    80001d22:	ec56                	sd	s5,24(sp)
    80001d24:	e85a                	sd	s6,16(sp)
    80001d26:	e45e                	sd	s7,8(sp)
    80001d28:	e062                	sd	s8,0(sp)
    80001d2a:	0880                	addi	s0,sp,80
    80001d2c:	8792                	mv	a5,tp
  int id = r_tp();
    80001d2e:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001d30:	00779b13          	slli	s6,a5,0x7
    80001d34:	00010717          	auipc	a4,0x10
    80001d38:	7ac70713          	addi	a4,a4,1964 # 800124e0 <pid_lock>
    80001d3c:	975a                	add	a4,a4,s6
    80001d3e:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001d42:	00010717          	auipc	a4,0x10
    80001d46:	7d670713          	addi	a4,a4,2006 # 80012518 <cpus+0x8>
    80001d4a:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80001d4c:	4c11                	li	s8,4
        c->proc = p;
    80001d4e:	079e                	slli	a5,a5,0x7
    80001d50:	00010a17          	auipc	s4,0x10
    80001d54:	790a0a13          	addi	s4,s4,1936 # 800124e0 <pid_lock>
    80001d58:	9a3e                	add	s4,s4,a5
        found = 1;
    80001d5a:	4b85                	li	s7,1
    for(p = proc; p < &proc[NPROC]; p++) {
    80001d5c:	00016997          	auipc	s3,0x16
    80001d60:	7b498993          	addi	s3,s3,1972 # 80018510 <ptable>
    80001d64:	a0a9                	j	80001dae <scheduler+0x9a>
      release(&p->lock);
    80001d66:	8526                	mv	a0,s1
    80001d68:	f25fe0ef          	jal	80000c8c <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001d6c:	17048493          	addi	s1,s1,368
    80001d70:	03348563          	beq	s1,s3,80001d9a <scheduler+0x86>
      acquire(&p->lock);
    80001d74:	8526                	mv	a0,s1
    80001d76:	e7ffe0ef          	jal	80000bf4 <acquire>
      if(p->state == RUNNABLE) {
    80001d7a:	4c9c                	lw	a5,24(s1)
    80001d7c:	ff2795e3          	bne	a5,s2,80001d66 <scheduler+0x52>
        p->state = RUNNING;
    80001d80:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    80001d84:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001d88:	06048593          	addi	a1,s1,96
    80001d8c:	855a                	mv	a0,s6
    80001d8e:	798000ef          	jal	80002526 <swtch>
        c->proc = 0;
    80001d92:	020a3823          	sd	zero,48(s4)
        found = 1;
    80001d96:	8ade                	mv	s5,s7
    80001d98:	b7f9                	j	80001d66 <scheduler+0x52>
    if(found == 0) {
    80001d9a:	000a9a63          	bnez	s5,80001dae <scheduler+0x9a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001d9e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001da2:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001da6:	10079073          	csrw	sstatus,a5
      asm volatile("wfi");
    80001daa:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001dae:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001db2:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001db6:	10079073          	csrw	sstatus,a5
    int found = 0;
    80001dba:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    80001dbc:	00011497          	auipc	s1,0x11
    80001dc0:	b5448493          	addi	s1,s1,-1196 # 80012910 <proc>
      if(p->state == RUNNABLE) {
    80001dc4:	490d                	li	s2,3
    80001dc6:	b77d                	j	80001d74 <scheduler+0x60>

0000000080001dc8 <sched>:
{
    80001dc8:	7179                	addi	sp,sp,-48
    80001dca:	f406                	sd	ra,40(sp)
    80001dcc:	f022                	sd	s0,32(sp)
    80001dce:	ec26                	sd	s1,24(sp)
    80001dd0:	e84a                	sd	s2,16(sp)
    80001dd2:	e44e                	sd	s3,8(sp)
    80001dd4:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001dd6:	b0bff0ef          	jal	800018e0 <myproc>
    80001dda:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001ddc:	daffe0ef          	jal	80000b8a <holding>
    80001de0:	c92d                	beqz	a0,80001e52 <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001de2:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001de4:	2781                	sext.w	a5,a5
    80001de6:	079e                	slli	a5,a5,0x7
    80001de8:	00010717          	auipc	a4,0x10
    80001dec:	6f870713          	addi	a4,a4,1784 # 800124e0 <pid_lock>
    80001df0:	97ba                	add	a5,a5,a4
    80001df2:	0a87a703          	lw	a4,168(a5)
    80001df6:	4785                	li	a5,1
    80001df8:	06f71363          	bne	a4,a5,80001e5e <sched+0x96>
  if(p->state == RUNNING)
    80001dfc:	4c98                	lw	a4,24(s1)
    80001dfe:	4791                	li	a5,4
    80001e00:	06f70563          	beq	a4,a5,80001e6a <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001e04:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001e08:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001e0a:	e7b5                	bnez	a5,80001e76 <sched+0xae>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001e0c:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001e0e:	00010917          	auipc	s2,0x10
    80001e12:	6d290913          	addi	s2,s2,1746 # 800124e0 <pid_lock>
    80001e16:	2781                	sext.w	a5,a5
    80001e18:	079e                	slli	a5,a5,0x7
    80001e1a:	97ca                	add	a5,a5,s2
    80001e1c:	0ac7a983          	lw	s3,172(a5)
    80001e20:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001e22:	2781                	sext.w	a5,a5
    80001e24:	079e                	slli	a5,a5,0x7
    80001e26:	00010597          	auipc	a1,0x10
    80001e2a:	6f258593          	addi	a1,a1,1778 # 80012518 <cpus+0x8>
    80001e2e:	95be                	add	a1,a1,a5
    80001e30:	06048513          	addi	a0,s1,96
    80001e34:	6f2000ef          	jal	80002526 <swtch>
    80001e38:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001e3a:	2781                	sext.w	a5,a5
    80001e3c:	079e                	slli	a5,a5,0x7
    80001e3e:	993e                	add	s2,s2,a5
    80001e40:	0b392623          	sw	s3,172(s2)
}
    80001e44:	70a2                	ld	ra,40(sp)
    80001e46:	7402                	ld	s0,32(sp)
    80001e48:	64e2                	ld	s1,24(sp)
    80001e4a:	6942                	ld	s2,16(sp)
    80001e4c:	69a2                	ld	s3,8(sp)
    80001e4e:	6145                	addi	sp,sp,48
    80001e50:	8082                	ret
    panic("sched p->lock");
    80001e52:	00005517          	auipc	a0,0x5
    80001e56:	3de50513          	addi	a0,a0,990 # 80007230 <etext+0x230>
    80001e5a:	93bfe0ef          	jal	80000794 <panic>
    panic("sched locks");
    80001e5e:	00005517          	auipc	a0,0x5
    80001e62:	3e250513          	addi	a0,a0,994 # 80007240 <etext+0x240>
    80001e66:	92ffe0ef          	jal	80000794 <panic>
    panic("sched running");
    80001e6a:	00005517          	auipc	a0,0x5
    80001e6e:	3e650513          	addi	a0,a0,998 # 80007250 <etext+0x250>
    80001e72:	923fe0ef          	jal	80000794 <panic>
    panic("sched interruptible");
    80001e76:	00005517          	auipc	a0,0x5
    80001e7a:	3ea50513          	addi	a0,a0,1002 # 80007260 <etext+0x260>
    80001e7e:	917fe0ef          	jal	80000794 <panic>

0000000080001e82 <yield>:
{
    80001e82:	1101                	addi	sp,sp,-32
    80001e84:	ec06                	sd	ra,24(sp)
    80001e86:	e822                	sd	s0,16(sp)
    80001e88:	e426                	sd	s1,8(sp)
    80001e8a:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001e8c:	a55ff0ef          	jal	800018e0 <myproc>
    80001e90:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001e92:	d63fe0ef          	jal	80000bf4 <acquire>
  p->state = RUNNABLE;
    80001e96:	478d                	li	a5,3
    80001e98:	cc9c                	sw	a5,24(s1)
  sched();
    80001e9a:	f2fff0ef          	jal	80001dc8 <sched>
  release(&p->lock);
    80001e9e:	8526                	mv	a0,s1
    80001ea0:	dedfe0ef          	jal	80000c8c <release>
}
    80001ea4:	60e2                	ld	ra,24(sp)
    80001ea6:	6442                	ld	s0,16(sp)
    80001ea8:	64a2                	ld	s1,8(sp)
    80001eaa:	6105                	addi	sp,sp,32
    80001eac:	8082                	ret

0000000080001eae <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80001eae:	7179                	addi	sp,sp,-48
    80001eb0:	f406                	sd	ra,40(sp)
    80001eb2:	f022                	sd	s0,32(sp)
    80001eb4:	ec26                	sd	s1,24(sp)
    80001eb6:	e84a                	sd	s2,16(sp)
    80001eb8:	e44e                	sd	s3,8(sp)
    80001eba:	1800                	addi	s0,sp,48
    80001ebc:	89aa                	mv	s3,a0
    80001ebe:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001ec0:	a21ff0ef          	jal	800018e0 <myproc>
    80001ec4:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80001ec6:	d2ffe0ef          	jal	80000bf4 <acquire>
  release(lk);
    80001eca:	854a                	mv	a0,s2
    80001ecc:	dc1fe0ef          	jal	80000c8c <release>

  // Go to sleep.
  p->chan = chan;
    80001ed0:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80001ed4:	4789                	li	a5,2
    80001ed6:	cc9c                	sw	a5,24(s1)

  sched();
    80001ed8:	ef1ff0ef          	jal	80001dc8 <sched>

  // Tidy up.
  p->chan = 0;
    80001edc:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80001ee0:	8526                	mv	a0,s1
    80001ee2:	dabfe0ef          	jal	80000c8c <release>
  acquire(lk);
    80001ee6:	854a                	mv	a0,s2
    80001ee8:	d0dfe0ef          	jal	80000bf4 <acquire>
}
    80001eec:	70a2                	ld	ra,40(sp)
    80001eee:	7402                	ld	s0,32(sp)
    80001ef0:	64e2                	ld	s1,24(sp)
    80001ef2:	6942                	ld	s2,16(sp)
    80001ef4:	69a2                	ld	s3,8(sp)
    80001ef6:	6145                	addi	sp,sp,48
    80001ef8:	8082                	ret

0000000080001efa <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    80001efa:	7139                	addi	sp,sp,-64
    80001efc:	fc06                	sd	ra,56(sp)
    80001efe:	f822                	sd	s0,48(sp)
    80001f00:	f426                	sd	s1,40(sp)
    80001f02:	f04a                	sd	s2,32(sp)
    80001f04:	ec4e                	sd	s3,24(sp)
    80001f06:	e852                	sd	s4,16(sp)
    80001f08:	e456                	sd	s5,8(sp)
    80001f0a:	0080                	addi	s0,sp,64
    80001f0c:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80001f0e:	00011497          	auipc	s1,0x11
    80001f12:	a0248493          	addi	s1,s1,-1534 # 80012910 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80001f16:	4989                	li	s3,2
        p->state = RUNNABLE;
    80001f18:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80001f1a:	00016917          	auipc	s2,0x16
    80001f1e:	5f690913          	addi	s2,s2,1526 # 80018510 <ptable>
    80001f22:	a801                	j	80001f32 <wakeup+0x38>
      }
      release(&p->lock);
    80001f24:	8526                	mv	a0,s1
    80001f26:	d67fe0ef          	jal	80000c8c <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001f2a:	17048493          	addi	s1,s1,368
    80001f2e:	03248263          	beq	s1,s2,80001f52 <wakeup+0x58>
    if(p != myproc()){
    80001f32:	9afff0ef          	jal	800018e0 <myproc>
    80001f36:	fea48ae3          	beq	s1,a0,80001f2a <wakeup+0x30>
      acquire(&p->lock);
    80001f3a:	8526                	mv	a0,s1
    80001f3c:	cb9fe0ef          	jal	80000bf4 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80001f40:	4c9c                	lw	a5,24(s1)
    80001f42:	ff3791e3          	bne	a5,s3,80001f24 <wakeup+0x2a>
    80001f46:	709c                	ld	a5,32(s1)
    80001f48:	fd479ee3          	bne	a5,s4,80001f24 <wakeup+0x2a>
        p->state = RUNNABLE;
    80001f4c:	0154ac23          	sw	s5,24(s1)
    80001f50:	bfd1                	j	80001f24 <wakeup+0x2a>
    }
  }
}
    80001f52:	70e2                	ld	ra,56(sp)
    80001f54:	7442                	ld	s0,48(sp)
    80001f56:	74a2                	ld	s1,40(sp)
    80001f58:	7902                	ld	s2,32(sp)
    80001f5a:	69e2                	ld	s3,24(sp)
    80001f5c:	6a42                	ld	s4,16(sp)
    80001f5e:	6aa2                	ld	s5,8(sp)
    80001f60:	6121                	addi	sp,sp,64
    80001f62:	8082                	ret

0000000080001f64 <reparent>:
{
    80001f64:	7179                	addi	sp,sp,-48
    80001f66:	f406                	sd	ra,40(sp)
    80001f68:	f022                	sd	s0,32(sp)
    80001f6a:	ec26                	sd	s1,24(sp)
    80001f6c:	e84a                	sd	s2,16(sp)
    80001f6e:	e44e                	sd	s3,8(sp)
    80001f70:	e052                	sd	s4,0(sp)
    80001f72:	1800                	addi	s0,sp,48
    80001f74:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001f76:	00011497          	auipc	s1,0x11
    80001f7a:	99a48493          	addi	s1,s1,-1638 # 80012910 <proc>
      pp->parent = initproc;
    80001f7e:	00008a17          	auipc	s4,0x8
    80001f82:	42aa0a13          	addi	s4,s4,1066 # 8000a3a8 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001f86:	00016997          	auipc	s3,0x16
    80001f8a:	58a98993          	addi	s3,s3,1418 # 80018510 <ptable>
    80001f8e:	a029                	j	80001f98 <reparent+0x34>
    80001f90:	17048493          	addi	s1,s1,368
    80001f94:	01348b63          	beq	s1,s3,80001faa <reparent+0x46>
    if(pp->parent == p){
    80001f98:	7c9c                	ld	a5,56(s1)
    80001f9a:	ff279be3          	bne	a5,s2,80001f90 <reparent+0x2c>
      pp->parent = initproc;
    80001f9e:	000a3503          	ld	a0,0(s4)
    80001fa2:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80001fa4:	f57ff0ef          	jal	80001efa <wakeup>
    80001fa8:	b7e5                	j	80001f90 <reparent+0x2c>
}
    80001faa:	70a2                	ld	ra,40(sp)
    80001fac:	7402                	ld	s0,32(sp)
    80001fae:	64e2                	ld	s1,24(sp)
    80001fb0:	6942                	ld	s2,16(sp)
    80001fb2:	69a2                	ld	s3,8(sp)
    80001fb4:	6a02                	ld	s4,0(sp)
    80001fb6:	6145                	addi	sp,sp,48
    80001fb8:	8082                	ret

0000000080001fba <exit>:
{
    80001fba:	7179                	addi	sp,sp,-48
    80001fbc:	f406                	sd	ra,40(sp)
    80001fbe:	f022                	sd	s0,32(sp)
    80001fc0:	ec26                	sd	s1,24(sp)
    80001fc2:	e84a                	sd	s2,16(sp)
    80001fc4:	e44e                	sd	s3,8(sp)
    80001fc6:	e052                	sd	s4,0(sp)
    80001fc8:	1800                	addi	s0,sp,48
    80001fca:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80001fcc:	915ff0ef          	jal	800018e0 <myproc>
    80001fd0:	89aa                	mv	s3,a0
  if(p == initproc)
    80001fd2:	00008797          	auipc	a5,0x8
    80001fd6:	3d67b783          	ld	a5,982(a5) # 8000a3a8 <initproc>
    80001fda:	0d050493          	addi	s1,a0,208
    80001fde:	15050913          	addi	s2,a0,336
    80001fe2:	00a79f63          	bne	a5,a0,80002000 <exit+0x46>
    panic("init exiting");
    80001fe6:	00005517          	auipc	a0,0x5
    80001fea:	29250513          	addi	a0,a0,658 # 80007278 <etext+0x278>
    80001fee:	fa6fe0ef          	jal	80000794 <panic>
      fileclose(f);
    80001ff2:	098020ef          	jal	8000408a <fileclose>
      p->ofile[fd] = 0;
    80001ff6:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80001ffa:	04a1                	addi	s1,s1,8
    80001ffc:	01248563          	beq	s1,s2,80002006 <exit+0x4c>
    if(p->ofile[fd]){
    80002000:	6088                	ld	a0,0(s1)
    80002002:	f965                	bnez	a0,80001ff2 <exit+0x38>
    80002004:	bfdd                	j	80001ffa <exit+0x40>
  begin_op();
    80002006:	46b010ef          	jal	80003c70 <begin_op>
  iput(p->cwd);
    8000200a:	1509b503          	ld	a0,336(s3)
    8000200e:	54e010ef          	jal	8000355c <iput>
  end_op();
    80002012:	4c9010ef          	jal	80003cda <end_op>
  p->cwd = 0;
    80002016:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    8000201a:	00010497          	auipc	s1,0x10
    8000201e:	4de48493          	addi	s1,s1,1246 # 800124f8 <wait_lock>
    80002022:	8526                	mv	a0,s1
    80002024:	bd1fe0ef          	jal	80000bf4 <acquire>
  reparent(p);
    80002028:	854e                	mv	a0,s3
    8000202a:	f3bff0ef          	jal	80001f64 <reparent>
  wakeup(p->parent);
    8000202e:	0389b503          	ld	a0,56(s3)
    80002032:	ec9ff0ef          	jal	80001efa <wakeup>
  acquire(&p->lock);
    80002036:	854e                	mv	a0,s3
    80002038:	bbdfe0ef          	jal	80000bf4 <acquire>
  p->xstate = status;
    8000203c:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002040:	4795                	li	a5,5
    80002042:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80002046:	8526                	mv	a0,s1
    80002048:	c45fe0ef          	jal	80000c8c <release>
  sched();
    8000204c:	d7dff0ef          	jal	80001dc8 <sched>
  panic("zombie exit");
    80002050:	00005517          	auipc	a0,0x5
    80002054:	23850513          	addi	a0,a0,568 # 80007288 <etext+0x288>
    80002058:	f3cfe0ef          	jal	80000794 <panic>

000000008000205c <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    8000205c:	7179                	addi	sp,sp,-48
    8000205e:	f406                	sd	ra,40(sp)
    80002060:	f022                	sd	s0,32(sp)
    80002062:	ec26                	sd	s1,24(sp)
    80002064:	e84a                	sd	s2,16(sp)
    80002066:	e44e                	sd	s3,8(sp)
    80002068:	1800                	addi	s0,sp,48
    8000206a:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    8000206c:	00011497          	auipc	s1,0x11
    80002070:	8a448493          	addi	s1,s1,-1884 # 80012910 <proc>
    80002074:	00016997          	auipc	s3,0x16
    80002078:	49c98993          	addi	s3,s3,1180 # 80018510 <ptable>
    acquire(&p->lock);
    8000207c:	8526                	mv	a0,s1
    8000207e:	b77fe0ef          	jal	80000bf4 <acquire>
    if(p->pid == pid){
    80002082:	589c                	lw	a5,48(s1)
    80002084:	01278b63          	beq	a5,s2,8000209a <kill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002088:	8526                	mv	a0,s1
    8000208a:	c03fe0ef          	jal	80000c8c <release>
  for(p = proc; p < &proc[NPROC]; p++){
    8000208e:	17048493          	addi	s1,s1,368
    80002092:	ff3495e3          	bne	s1,s3,8000207c <kill+0x20>
  }
  return -1;
    80002096:	557d                	li	a0,-1
    80002098:	a819                	j	800020ae <kill+0x52>
      p->killed = 1;
    8000209a:	4785                	li	a5,1
    8000209c:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    8000209e:	4c98                	lw	a4,24(s1)
    800020a0:	4789                	li	a5,2
    800020a2:	00f70d63          	beq	a4,a5,800020bc <kill+0x60>
      release(&p->lock);
    800020a6:	8526                	mv	a0,s1
    800020a8:	be5fe0ef          	jal	80000c8c <release>
      return 0;
    800020ac:	4501                	li	a0,0
}
    800020ae:	70a2                	ld	ra,40(sp)
    800020b0:	7402                	ld	s0,32(sp)
    800020b2:	64e2                	ld	s1,24(sp)
    800020b4:	6942                	ld	s2,16(sp)
    800020b6:	69a2                	ld	s3,8(sp)
    800020b8:	6145                	addi	sp,sp,48
    800020ba:	8082                	ret
        p->state = RUNNABLE;
    800020bc:	478d                	li	a5,3
    800020be:	cc9c                	sw	a5,24(s1)
    800020c0:	b7dd                	j	800020a6 <kill+0x4a>

00000000800020c2 <setkilled>:

void
setkilled(struct proc *p)
{
    800020c2:	1101                	addi	sp,sp,-32
    800020c4:	ec06                	sd	ra,24(sp)
    800020c6:	e822                	sd	s0,16(sp)
    800020c8:	e426                	sd	s1,8(sp)
    800020ca:	1000                	addi	s0,sp,32
    800020cc:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800020ce:	b27fe0ef          	jal	80000bf4 <acquire>
  p->killed = 1;
    800020d2:	4785                	li	a5,1
    800020d4:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    800020d6:	8526                	mv	a0,s1
    800020d8:	bb5fe0ef          	jal	80000c8c <release>
}
    800020dc:	60e2                	ld	ra,24(sp)
    800020de:	6442                	ld	s0,16(sp)
    800020e0:	64a2                	ld	s1,8(sp)
    800020e2:	6105                	addi	sp,sp,32
    800020e4:	8082                	ret

00000000800020e6 <killed>:

int
killed(struct proc *p)
{
    800020e6:	1101                	addi	sp,sp,-32
    800020e8:	ec06                	sd	ra,24(sp)
    800020ea:	e822                	sd	s0,16(sp)
    800020ec:	e426                	sd	s1,8(sp)
    800020ee:	e04a                	sd	s2,0(sp)
    800020f0:	1000                	addi	s0,sp,32
    800020f2:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    800020f4:	b01fe0ef          	jal	80000bf4 <acquire>
  k = p->killed;
    800020f8:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    800020fc:	8526                	mv	a0,s1
    800020fe:	b8ffe0ef          	jal	80000c8c <release>
  return k;
}
    80002102:	854a                	mv	a0,s2
    80002104:	60e2                	ld	ra,24(sp)
    80002106:	6442                	ld	s0,16(sp)
    80002108:	64a2                	ld	s1,8(sp)
    8000210a:	6902                	ld	s2,0(sp)
    8000210c:	6105                	addi	sp,sp,32
    8000210e:	8082                	ret

0000000080002110 <wait>:
{
    80002110:	715d                	addi	sp,sp,-80
    80002112:	e486                	sd	ra,72(sp)
    80002114:	e0a2                	sd	s0,64(sp)
    80002116:	fc26                	sd	s1,56(sp)
    80002118:	f84a                	sd	s2,48(sp)
    8000211a:	f44e                	sd	s3,40(sp)
    8000211c:	f052                	sd	s4,32(sp)
    8000211e:	ec56                	sd	s5,24(sp)
    80002120:	e85a                	sd	s6,16(sp)
    80002122:	e45e                	sd	s7,8(sp)
    80002124:	e062                	sd	s8,0(sp)
    80002126:	0880                	addi	s0,sp,80
    80002128:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    8000212a:	fb6ff0ef          	jal	800018e0 <myproc>
    8000212e:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002130:	00010517          	auipc	a0,0x10
    80002134:	3c850513          	addi	a0,a0,968 # 800124f8 <wait_lock>
    80002138:	abdfe0ef          	jal	80000bf4 <acquire>
    havekids = 0;
    8000213c:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    8000213e:	4a15                	li	s4,5
        havekids = 1;
    80002140:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002142:	00016997          	auipc	s3,0x16
    80002146:	3ce98993          	addi	s3,s3,974 # 80018510 <ptable>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000214a:	00010c17          	auipc	s8,0x10
    8000214e:	3aec0c13          	addi	s8,s8,942 # 800124f8 <wait_lock>
    80002152:	a871                	j	800021ee <wait+0xde>
          pid = pp->pid;
    80002154:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80002158:	000b0c63          	beqz	s6,80002170 <wait+0x60>
    8000215c:	4691                	li	a3,4
    8000215e:	02c48613          	addi	a2,s1,44
    80002162:	85da                	mv	a1,s6
    80002164:	05093503          	ld	a0,80(s2)
    80002168:	beaff0ef          	jal	80001552 <copyout>
    8000216c:	02054b63          	bltz	a0,800021a2 <wait+0x92>
          freeproc(pp);
    80002170:	8526                	mv	a0,s1
    80002172:	8e1ff0ef          	jal	80001a52 <freeproc>
          release(&pp->lock);
    80002176:	8526                	mv	a0,s1
    80002178:	b15fe0ef          	jal	80000c8c <release>
          release(&wait_lock);
    8000217c:	00010517          	auipc	a0,0x10
    80002180:	37c50513          	addi	a0,a0,892 # 800124f8 <wait_lock>
    80002184:	b09fe0ef          	jal	80000c8c <release>
}
    80002188:	854e                	mv	a0,s3
    8000218a:	60a6                	ld	ra,72(sp)
    8000218c:	6406                	ld	s0,64(sp)
    8000218e:	74e2                	ld	s1,56(sp)
    80002190:	7942                	ld	s2,48(sp)
    80002192:	79a2                	ld	s3,40(sp)
    80002194:	7a02                	ld	s4,32(sp)
    80002196:	6ae2                	ld	s5,24(sp)
    80002198:	6b42                	ld	s6,16(sp)
    8000219a:	6ba2                	ld	s7,8(sp)
    8000219c:	6c02                	ld	s8,0(sp)
    8000219e:	6161                	addi	sp,sp,80
    800021a0:	8082                	ret
            release(&pp->lock);
    800021a2:	8526                	mv	a0,s1
    800021a4:	ae9fe0ef          	jal	80000c8c <release>
            release(&wait_lock);
    800021a8:	00010517          	auipc	a0,0x10
    800021ac:	35050513          	addi	a0,a0,848 # 800124f8 <wait_lock>
    800021b0:	addfe0ef          	jal	80000c8c <release>
            return -1;
    800021b4:	59fd                	li	s3,-1
    800021b6:	bfc9                	j	80002188 <wait+0x78>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800021b8:	17048493          	addi	s1,s1,368
    800021bc:	03348063          	beq	s1,s3,800021dc <wait+0xcc>
      if(pp->parent == p){
    800021c0:	7c9c                	ld	a5,56(s1)
    800021c2:	ff279be3          	bne	a5,s2,800021b8 <wait+0xa8>
        acquire(&pp->lock);
    800021c6:	8526                	mv	a0,s1
    800021c8:	a2dfe0ef          	jal	80000bf4 <acquire>
        if(pp->state == ZOMBIE){
    800021cc:	4c9c                	lw	a5,24(s1)
    800021ce:	f94783e3          	beq	a5,s4,80002154 <wait+0x44>
        release(&pp->lock);
    800021d2:	8526                	mv	a0,s1
    800021d4:	ab9fe0ef          	jal	80000c8c <release>
        havekids = 1;
    800021d8:	8756                	mv	a4,s5
    800021da:	bff9                	j	800021b8 <wait+0xa8>
    if(!havekids || killed(p)){
    800021dc:	cf19                	beqz	a4,800021fa <wait+0xea>
    800021de:	854a                	mv	a0,s2
    800021e0:	f07ff0ef          	jal	800020e6 <killed>
    800021e4:	e919                	bnez	a0,800021fa <wait+0xea>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800021e6:	85e2                	mv	a1,s8
    800021e8:	854a                	mv	a0,s2
    800021ea:	cc5ff0ef          	jal	80001eae <sleep>
    havekids = 0;
    800021ee:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800021f0:	00010497          	auipc	s1,0x10
    800021f4:	72048493          	addi	s1,s1,1824 # 80012910 <proc>
    800021f8:	b7e1                	j	800021c0 <wait+0xb0>
      release(&wait_lock);
    800021fa:	00010517          	auipc	a0,0x10
    800021fe:	2fe50513          	addi	a0,a0,766 # 800124f8 <wait_lock>
    80002202:	a8bfe0ef          	jal	80000c8c <release>
      return -1;
    80002206:	59fd                	li	s3,-1
    80002208:	b741                	j	80002188 <wait+0x78>

000000008000220a <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    8000220a:	7179                	addi	sp,sp,-48
    8000220c:	f406                	sd	ra,40(sp)
    8000220e:	f022                	sd	s0,32(sp)
    80002210:	ec26                	sd	s1,24(sp)
    80002212:	e84a                	sd	s2,16(sp)
    80002214:	e44e                	sd	s3,8(sp)
    80002216:	e052                	sd	s4,0(sp)
    80002218:	1800                	addi	s0,sp,48
    8000221a:	84aa                	mv	s1,a0
    8000221c:	892e                	mv	s2,a1
    8000221e:	89b2                	mv	s3,a2
    80002220:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002222:	ebeff0ef          	jal	800018e0 <myproc>
  if(user_dst){
    80002226:	cc99                	beqz	s1,80002244 <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    80002228:	86d2                	mv	a3,s4
    8000222a:	864e                	mv	a2,s3
    8000222c:	85ca                	mv	a1,s2
    8000222e:	6928                	ld	a0,80(a0)
    80002230:	b22ff0ef          	jal	80001552 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002234:	70a2                	ld	ra,40(sp)
    80002236:	7402                	ld	s0,32(sp)
    80002238:	64e2                	ld	s1,24(sp)
    8000223a:	6942                	ld	s2,16(sp)
    8000223c:	69a2                	ld	s3,8(sp)
    8000223e:	6a02                	ld	s4,0(sp)
    80002240:	6145                	addi	sp,sp,48
    80002242:	8082                	ret
    memmove((char *)dst, src, len);
    80002244:	000a061b          	sext.w	a2,s4
    80002248:	85ce                	mv	a1,s3
    8000224a:	854a                	mv	a0,s2
    8000224c:	ad9fe0ef          	jal	80000d24 <memmove>
    return 0;
    80002250:	8526                	mv	a0,s1
    80002252:	b7cd                	j	80002234 <either_copyout+0x2a>

0000000080002254 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002254:	7179                	addi	sp,sp,-48
    80002256:	f406                	sd	ra,40(sp)
    80002258:	f022                	sd	s0,32(sp)
    8000225a:	ec26                	sd	s1,24(sp)
    8000225c:	e84a                	sd	s2,16(sp)
    8000225e:	e44e                	sd	s3,8(sp)
    80002260:	e052                	sd	s4,0(sp)
    80002262:	1800                	addi	s0,sp,48
    80002264:	892a                	mv	s2,a0
    80002266:	84ae                	mv	s1,a1
    80002268:	89b2                	mv	s3,a2
    8000226a:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000226c:	e74ff0ef          	jal	800018e0 <myproc>
  if(user_src){
    80002270:	cc99                	beqz	s1,8000228e <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    80002272:	86d2                	mv	a3,s4
    80002274:	864e                	mv	a2,s3
    80002276:	85ca                	mv	a1,s2
    80002278:	6928                	ld	a0,80(a0)
    8000227a:	baeff0ef          	jal	80001628 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    8000227e:	70a2                	ld	ra,40(sp)
    80002280:	7402                	ld	s0,32(sp)
    80002282:	64e2                	ld	s1,24(sp)
    80002284:	6942                	ld	s2,16(sp)
    80002286:	69a2                	ld	s3,8(sp)
    80002288:	6a02                	ld	s4,0(sp)
    8000228a:	6145                	addi	sp,sp,48
    8000228c:	8082                	ret
    memmove(dst, (char*)src, len);
    8000228e:	000a061b          	sext.w	a2,s4
    80002292:	85ce                	mv	a1,s3
    80002294:	854a                	mv	a0,s2
    80002296:	a8ffe0ef          	jal	80000d24 <memmove>
    return 0;
    8000229a:	8526                	mv	a0,s1
    8000229c:	b7cd                	j	8000227e <either_copyin+0x2a>

000000008000229e <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    8000229e:	715d                	addi	sp,sp,-80
    800022a0:	e486                	sd	ra,72(sp)
    800022a2:	e0a2                	sd	s0,64(sp)
    800022a4:	fc26                	sd	s1,56(sp)
    800022a6:	f84a                	sd	s2,48(sp)
    800022a8:	f44e                	sd	s3,40(sp)
    800022aa:	f052                	sd	s4,32(sp)
    800022ac:	ec56                	sd	s5,24(sp)
    800022ae:	e85a                	sd	s6,16(sp)
    800022b0:	e45e                	sd	s7,8(sp)
    800022b2:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    800022b4:	00005517          	auipc	a0,0x5
    800022b8:	08450513          	addi	a0,a0,132 # 80007338 <etext+0x338>
    800022bc:	a06fe0ef          	jal	800004c2 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800022c0:	00010497          	auipc	s1,0x10
    800022c4:	7a848493          	addi	s1,s1,1960 # 80012a68 <proc+0x158>
    800022c8:	00016917          	auipc	s2,0x16
    800022cc:	3a090913          	addi	s2,s2,928 # 80018668 <ptable+0x158>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800022d0:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    800022d2:	00005997          	auipc	s3,0x5
    800022d6:	fc698993          	addi	s3,s3,-58 # 80007298 <etext+0x298>
    printf("%d %s %s", p->pid, state, p->name);
    800022da:	00005a97          	auipc	s5,0x5
    800022de:	fc6a8a93          	addi	s5,s5,-58 # 800072a0 <etext+0x2a0>
    printf("\n");
    800022e2:	00005a17          	auipc	s4,0x5
    800022e6:	056a0a13          	addi	s4,s4,86 # 80007338 <etext+0x338>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800022ea:	00005b97          	auipc	s7,0x5
    800022ee:	53eb8b93          	addi	s7,s7,1342 # 80007828 <states.0>
    800022f2:	a829                	j	8000230c <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    800022f4:	ed86a583          	lw	a1,-296(a3)
    800022f8:	8556                	mv	a0,s5
    800022fa:	9c8fe0ef          	jal	800004c2 <printf>
    printf("\n");
    800022fe:	8552                	mv	a0,s4
    80002300:	9c2fe0ef          	jal	800004c2 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002304:	17048493          	addi	s1,s1,368
    80002308:	03248263          	beq	s1,s2,8000232c <procdump+0x8e>
    if(p->state == UNUSED)
    8000230c:	86a6                	mv	a3,s1
    8000230e:	ec04a783          	lw	a5,-320(s1)
    80002312:	dbed                	beqz	a5,80002304 <procdump+0x66>
      state = "???";
    80002314:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002316:	fcfb6fe3          	bltu	s6,a5,800022f4 <procdump+0x56>
    8000231a:	02079713          	slli	a4,a5,0x20
    8000231e:	01d75793          	srli	a5,a4,0x1d
    80002322:	97de                	add	a5,a5,s7
    80002324:	6390                	ld	a2,0(a5)
    80002326:	f679                	bnez	a2,800022f4 <procdump+0x56>
      state = "???";
    80002328:	864e                	mv	a2,s3
    8000232a:	b7e9                	j	800022f4 <procdump+0x56>
  }
}
    8000232c:	60a6                	ld	ra,72(sp)
    8000232e:	6406                	ld	s0,64(sp)
    80002330:	74e2                	ld	s1,56(sp)
    80002332:	7942                	ld	s2,48(sp)
    80002334:	79a2                	ld	s3,40(sp)
    80002336:	7a02                	ld	s4,32(sp)
    80002338:	6ae2                	ld	s5,24(sp)
    8000233a:	6b42                	ld	s6,16(sp)
    8000233c:	6ba2                	ld	s7,8(sp)
    8000233e:	6161                	addi	sp,sp,80
    80002340:	8082                	ret

0000000080002342 <ps>:

 //current process status
int
ps()
{
    80002342:	711d                	addi	sp,sp,-96
    80002344:	ec86                	sd	ra,88(sp)
    80002346:	e8a2                	sd	s0,80(sp)
    80002348:	e4a6                	sd	s1,72(sp)
    8000234a:	e0ca                	sd	s2,64(sp)
    8000234c:	fc4e                	sd	s3,56(sp)
    8000234e:	f852                	sd	s4,48(sp)
    80002350:	f456                	sd	s5,40(sp)
    80002352:	f05a                	sd	s6,32(sp)
    80002354:	ec5e                	sd	s7,24(sp)
    80002356:	e862                	sd	s8,16(sp)
    80002358:	e466                	sd	s9,8(sp)
    8000235a:	1080                	addi	s0,sp,96
}

static inline void sti(void) {
  asm volatile("csrsi sstatus, 1 << 1");
    8000235c:	10016073          	csrsi	sstatus,2

// Enable interrupts on this processor.
sti();

 // Loop over process table looking for process with pid.
acquire(&wait_lock);
    80002360:	00010517          	auipc	a0,0x10
    80002364:	19850513          	addi	a0,a0,408 # 800124f8 <wait_lock>
    80002368:	88dfe0ef          	jal	80000bf4 <acquire>
printf("name \t pid \t state \n");
    8000236c:	00005517          	auipc	a0,0x5
    80002370:	f4450513          	addi	a0,a0,-188 # 800072b0 <etext+0x2b0>
    80002374:	94efe0ef          	jal	800004c2 <printf>
for(p = proc; p < &proc[NPROC]; p++){
    80002378:	00010497          	auipc	s1,0x10
    8000237c:	6f048493          	addi	s1,s1,1776 # 80012a68 <proc+0x158>
    80002380:	00016a17          	auipc	s4,0x16
    80002384:	2e8a0a13          	addi	s4,s4,744 # 80018668 <ptable+0x158>
    80002388:	4995                	li	s3,5
    8000238a:	00005917          	auipc	s2,0x5
    8000238e:	48690913          	addi	s2,s2,1158 # 80007810 <digits+0x18>
    else if ( p->state == RUNNABLE )
      printf("%s \t %d  \t RUNNABLE \n", p->name, p->pid );
      else if ( p->state == ZOMBIE )
      printf("%s \t %d  \t ZOMBIE \n", p->name, p->pid );
      else if ( p->state == USED )
      printf("%s \t %d  \t USED \n", p->name, p->pid );
    80002392:	00005c97          	auipc	s9,0x5
    80002396:	f96c8c93          	addi	s9,s9,-106 # 80007328 <etext+0x328>
      printf("%s \t %d  \t ZOMBIE \n", p->name, p->pid );
    8000239a:	00005c17          	auipc	s8,0x5
    8000239e:	f76c0c13          	addi	s8,s8,-138 # 80007310 <etext+0x310>
      printf("%s \t %d  \t RUNNABLE \n", p->name, p->pid );
    800023a2:	00005b97          	auipc	s7,0x5
    800023a6:	f56b8b93          	addi	s7,s7,-170 # 800072f8 <etext+0x2f8>
     printf("%s \t %d  \t RUNNING \n", p->name, p->pid );
    800023aa:	00005b17          	auipc	s6,0x5
    800023ae:	f36b0b13          	addi	s6,s6,-202 # 800072e0 <etext+0x2e0>
     printf("%s \t %d  \t SLEEPING \n ", p->name, p->pid );
    800023b2:	00005a97          	auipc	s5,0x5
    800023b6:	f16a8a93          	addi	s5,s5,-234 # 800072c8 <etext+0x2c8>
    800023ba:	a811                	j	800023ce <ps+0x8c>
    800023bc:	ed84a603          	lw	a2,-296(s1)
    800023c0:	8556                	mv	a0,s5
    800023c2:	900fe0ef          	jal	800004c2 <printf>
for(p = proc; p < &proc[NPROC]; p++){
    800023c6:	17048493          	addi	s1,s1,368
    800023ca:	05448663          	beq	s1,s4,80002416 <ps+0xd4>
   if ( p->state == SLEEPING )
    800023ce:	85a6                	mv	a1,s1
    800023d0:	ec04a783          	lw	a5,-320(s1)
    800023d4:	fef9e9e3          	bltu	s3,a5,800023c6 <ps+0x84>
    800023d8:	ec04e783          	lwu	a5,-320(s1)
    800023dc:	078a                	slli	a5,a5,0x2
    800023de:	97ca                	add	a5,a5,s2
    800023e0:	439c                	lw	a5,0(a5)
    800023e2:	97ca                	add	a5,a5,s2
    800023e4:	8782                	jr	a5
     printf("%s \t %d  \t RUNNING \n", p->name, p->pid );
    800023e6:	ed84a603          	lw	a2,-296(s1)
    800023ea:	855a                	mv	a0,s6
    800023ec:	8d6fe0ef          	jal	800004c2 <printf>
    800023f0:	bfd9                	j	800023c6 <ps+0x84>
      printf("%s \t %d  \t RUNNABLE \n", p->name, p->pid );
    800023f2:	ed84a603          	lw	a2,-296(s1)
    800023f6:	855e                	mv	a0,s7
    800023f8:	8cafe0ef          	jal	800004c2 <printf>
    800023fc:	b7e9                	j	800023c6 <ps+0x84>
      printf("%s \t %d  \t ZOMBIE \n", p->name, p->pid );
    800023fe:	ed84a603          	lw	a2,-296(s1)
    80002402:	8562                	mv	a0,s8
    80002404:	8befe0ef          	jal	800004c2 <printf>
    80002408:	bf7d                	j	800023c6 <ps+0x84>
      printf("%s \t %d  \t USED \n", p->name, p->pid );
    8000240a:	ed84a603          	lw	a2,-296(s1)
    8000240e:	8566                	mv	a0,s9
    80002410:	8b2fe0ef          	jal	800004c2 <printf>
    80002414:	bf4d                	j	800023c6 <ps+0x84>
}

release(&wait_lock);
    80002416:	00010517          	auipc	a0,0x10
    8000241a:	0e250513          	addi	a0,a0,226 # 800124f8 <wait_lock>
    8000241e:	86ffe0ef          	jal	80000c8c <release>

return 22;
}
    80002422:	4559                	li	a0,22
    80002424:	60e6                	ld	ra,88(sp)
    80002426:	6446                	ld	s0,80(sp)
    80002428:	64a6                	ld	s1,72(sp)
    8000242a:	6906                	ld	s2,64(sp)
    8000242c:	79e2                	ld	s3,56(sp)
    8000242e:	7a42                	ld	s4,48(sp)
    80002430:	7aa2                	ld	s5,40(sp)
    80002432:	7b02                	ld	s6,32(sp)
    80002434:	6be2                	ld	s7,24(sp)
    80002436:	6c42                	ld	s8,16(sp)
    80002438:	6ca2                	ld	s9,8(sp)
    8000243a:	6125                	addi	sp,sp,96
    8000243c:	8082                	ret

000000008000243e <fork_with_priority>:

int fork_with_priority(int priority) {
    8000243e:	7139                	addi	sp,sp,-64
    80002440:	fc06                	sd	ra,56(sp)
    80002442:	f822                	sd	s0,48(sp)
    80002444:	f426                	sd	s1,40(sp)
    80002446:	e456                	sd	s5,8(sp)
    80002448:	0080                	addi	s0,sp,64
    8000244a:	84aa                	mv	s1,a0
    struct proc *np;
    struct proc *curproc = myproc();
    8000244c:	c94ff0ef          	jal	800018e0 <myproc>
    80002450:	8aaa                	mv	s5,a0

    // Allocate a new process. This function acquires the process lock.
    if ((np = allocproc()) == 0)
    80002452:	e50ff0ef          	jal	80001aa2 <allocproc>
    80002456:	c571                	beqz	a0,80002522 <fork_with_priority+0xe4>
    80002458:	e852                	sd	s4,16(sp)
    8000245a:	8a2a                	mv	s4,a0
        return -1;

    // Copy the parent process's address space to the child.
    if (uvmcopy(curproc->pagetable, np->pagetable, curproc->sz) < 0) {
    8000245c:	048ab603          	ld	a2,72(s5)
    80002460:	692c                	ld	a1,80(a0)
    80002462:	050ab503          	ld	a0,80(s5)
    80002466:	810ff0ef          	jal	80001476 <uvmcopy>
    8000246a:	04054c63          	bltz	a0,800024c2 <fork_with_priority+0x84>
    8000246e:	f04a                	sd	s2,32(sp)
    80002470:	ec4e                	sd	s3,24(sp)
        freeproc(np);
        return -1;
    }

    // Set up the new process's state based on the parent process.
    np->sz = curproc->sz;
    80002472:	048ab783          	ld	a5,72(s5)
    80002476:	04fa3423          	sd	a5,72(s4)
    np->parent = curproc;
    8000247a:	035a3c23          	sd	s5,56(s4)
    *np->trapframe = *curproc->trapframe; // Copy the trapframe
    8000247e:	058ab683          	ld	a3,88(s5)
    80002482:	87b6                	mv	a5,a3
    80002484:	058a3703          	ld	a4,88(s4)
    80002488:	12068693          	addi	a3,a3,288
    8000248c:	0007b883          	ld	a7,0(a5)
    80002490:	0087b803          	ld	a6,8(a5)
    80002494:	6b8c                	ld	a1,16(a5)
    80002496:	6f90                	ld	a2,24(a5)
    80002498:	01173023          	sd	a7,0(a4)
    8000249c:	01073423          	sd	a6,8(a4)
    800024a0:	eb0c                	sd	a1,16(a4)
    800024a2:	ef10                	sd	a2,24(a4)
    800024a4:	02078793          	addi	a5,a5,32
    800024a8:	02070713          	addi	a4,a4,32
    800024ac:	fed790e3          	bne	a5,a3,8000248c <fork_with_priority+0x4e>

    // Set the priority for the new process.
    np->priority = priority;
    800024b0:	169a2423          	sw	s1,360(s4)

    // Copy file descriptors from parent to child.
    for (int i = 0; i < NOFILE; i++) {
    800024b4:	0d0a8493          	addi	s1,s5,208
    800024b8:	0d0a0913          	addi	s2,s4,208
    800024bc:	150a8993          	addi	s3,s5,336
    800024c0:	a819                	j	800024d6 <fork_with_priority+0x98>
        freeproc(np);
    800024c2:	8552                	mv	a0,s4
    800024c4:	d8eff0ef          	jal	80001a52 <freeproc>
        return -1;
    800024c8:	54fd                	li	s1,-1
    800024ca:	6a42                	ld	s4,16(sp)
    800024cc:	a0a1                	j	80002514 <fork_with_priority+0xd6>
    for (int i = 0; i < NOFILE; i++) {
    800024ce:	04a1                	addi	s1,s1,8
    800024d0:	0921                	addi	s2,s2,8
    800024d2:	01348963          	beq	s1,s3,800024e4 <fork_with_priority+0xa6>
        if (curproc->ofile[i])
    800024d6:	6088                	ld	a0,0(s1)
    800024d8:	d97d                	beqz	a0,800024ce <fork_with_priority+0x90>
            np->ofile[i] = filedup(curproc->ofile[i]);
    800024da:	36b010ef          	jal	80004044 <filedup>
    800024de:	00a93023          	sd	a0,0(s2)
    800024e2:	b7f5                	j	800024ce <fork_with_priority+0x90>
    }

    // Copy the current working directory.
    np->cwd = idup(curproc->cwd);
    800024e4:	150ab503          	ld	a0,336(s5)
    800024e8:	6bd000ef          	jal	800033a4 <idup>
    800024ec:	14aa3823          	sd	a0,336(s4)
    safestrcpy(np->name, curproc->name, sizeof(curproc->name));
    800024f0:	4641                	li	a2,16
    800024f2:	158a8593          	addi	a1,s5,344
    800024f6:	158a0513          	addi	a0,s4,344
    800024fa:	90dfe0ef          	jal	80000e06 <safestrcpy>

    int pid = np->pid;
    800024fe:	030a2483          	lw	s1,48(s4)

    // The process lock is already held here (from allocproc), so we just set the state.
    np->state = RUNNABLE;
    80002502:	478d                	li	a5,3
    80002504:	00fa2c23          	sw	a5,24(s4)

    // Release the lock before returning.
    release(&np->lock);
    80002508:	8552                	mv	a0,s4
    8000250a:	f82fe0ef          	jal	80000c8c <release>

    return pid;
    8000250e:	7902                	ld	s2,32(sp)
    80002510:	69e2                	ld	s3,24(sp)
    80002512:	6a42                	ld	s4,16(sp)
}
    80002514:	8526                	mv	a0,s1
    80002516:	70e2                	ld	ra,56(sp)
    80002518:	7442                	ld	s0,48(sp)
    8000251a:	74a2                	ld	s1,40(sp)
    8000251c:	6aa2                	ld	s5,8(sp)
    8000251e:	6121                	addi	sp,sp,64
    80002520:	8082                	ret
        return -1;
    80002522:	54fd                	li	s1,-1
    80002524:	bfc5                	j	80002514 <fork_with_priority+0xd6>

0000000080002526 <swtch>:
    80002526:	00153023          	sd	ra,0(a0)
    8000252a:	00253423          	sd	sp,8(a0)
    8000252e:	e900                	sd	s0,16(a0)
    80002530:	ed04                	sd	s1,24(a0)
    80002532:	03253023          	sd	s2,32(a0)
    80002536:	03353423          	sd	s3,40(a0)
    8000253a:	03453823          	sd	s4,48(a0)
    8000253e:	03553c23          	sd	s5,56(a0)
    80002542:	05653023          	sd	s6,64(a0)
    80002546:	05753423          	sd	s7,72(a0)
    8000254a:	05853823          	sd	s8,80(a0)
    8000254e:	05953c23          	sd	s9,88(a0)
    80002552:	07a53023          	sd	s10,96(a0)
    80002556:	07b53423          	sd	s11,104(a0)
    8000255a:	0005b083          	ld	ra,0(a1)
    8000255e:	0085b103          	ld	sp,8(a1)
    80002562:	6980                	ld	s0,16(a1)
    80002564:	6d84                	ld	s1,24(a1)
    80002566:	0205b903          	ld	s2,32(a1)
    8000256a:	0285b983          	ld	s3,40(a1)
    8000256e:	0305ba03          	ld	s4,48(a1)
    80002572:	0385ba83          	ld	s5,56(a1)
    80002576:	0405bb03          	ld	s6,64(a1)
    8000257a:	0485bb83          	ld	s7,72(a1)
    8000257e:	0505bc03          	ld	s8,80(a1)
    80002582:	0585bc83          	ld	s9,88(a1)
    80002586:	0605bd03          	ld	s10,96(a1)
    8000258a:	0685bd83          	ld	s11,104(a1)
    8000258e:	8082                	ret

0000000080002590 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002590:	1141                	addi	sp,sp,-16
    80002592:	e406                	sd	ra,8(sp)
    80002594:	e022                	sd	s0,0(sp)
    80002596:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002598:	00005597          	auipc	a1,0x5
    8000259c:	dd858593          	addi	a1,a1,-552 # 80007370 <etext+0x370>
    800025a0:	0001c517          	auipc	a0,0x1c
    800025a4:	b8850513          	addi	a0,a0,-1144 # 8001e128 <tickslock>
    800025a8:	dccfe0ef          	jal	80000b74 <initlock>
}
    800025ac:	60a2                	ld	ra,8(sp)
    800025ae:	6402                	ld	s0,0(sp)
    800025b0:	0141                	addi	sp,sp,16
    800025b2:	8082                	ret

00000000800025b4 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800025b4:	1141                	addi	sp,sp,-16
    800025b6:	e422                	sd	s0,8(sp)
    800025b8:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800025ba:	00003797          	auipc	a5,0x3
    800025be:	e4678793          	addi	a5,a5,-442 # 80005400 <kernelvec>
    800025c2:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800025c6:	6422                	ld	s0,8(sp)
    800025c8:	0141                	addi	sp,sp,16
    800025ca:	8082                	ret

00000000800025cc <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    800025cc:	1141                	addi	sp,sp,-16
    800025ce:	e406                	sd	ra,8(sp)
    800025d0:	e022                	sd	s0,0(sp)
    800025d2:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800025d4:	b0cff0ef          	jal	800018e0 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800025d8:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800025dc:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800025de:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    800025e2:	00004697          	auipc	a3,0x4
    800025e6:	a1e68693          	addi	a3,a3,-1506 # 80006000 <_trampoline>
    800025ea:	00004717          	auipc	a4,0x4
    800025ee:	a1670713          	addi	a4,a4,-1514 # 80006000 <_trampoline>
    800025f2:	8f15                	sub	a4,a4,a3
    800025f4:	040007b7          	lui	a5,0x4000
    800025f8:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    800025fa:	07b2                	slli	a5,a5,0xc
    800025fc:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    800025fe:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002602:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002604:	18002673          	csrr	a2,satp
    80002608:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    8000260a:	6d30                	ld	a2,88(a0)
    8000260c:	6138                	ld	a4,64(a0)
    8000260e:	6585                	lui	a1,0x1
    80002610:	972e                	add	a4,a4,a1
    80002612:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002614:	6d38                	ld	a4,88(a0)
    80002616:	00000617          	auipc	a2,0x0
    8000261a:	11060613          	addi	a2,a2,272 # 80002726 <usertrap>
    8000261e:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002620:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002622:	8612                	mv	a2,tp
    80002624:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002626:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    8000262a:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    8000262e:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002632:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002636:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002638:	6f18                	ld	a4,24(a4)
    8000263a:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    8000263e:	6928                	ld	a0,80(a0)
    80002640:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002642:	00004717          	auipc	a4,0x4
    80002646:	a5a70713          	addi	a4,a4,-1446 # 8000609c <userret>
    8000264a:	8f15                	sub	a4,a4,a3
    8000264c:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    8000264e:	577d                	li	a4,-1
    80002650:	177e                	slli	a4,a4,0x3f
    80002652:	8d59                	or	a0,a0,a4
    80002654:	9782                	jalr	a5
}
    80002656:	60a2                	ld	ra,8(sp)
    80002658:	6402                	ld	s0,0(sp)
    8000265a:	0141                	addi	sp,sp,16
    8000265c:	8082                	ret

000000008000265e <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    8000265e:	1101                	addi	sp,sp,-32
    80002660:	ec06                	sd	ra,24(sp)
    80002662:	e822                	sd	s0,16(sp)
    80002664:	1000                	addi	s0,sp,32
  if(cpuid() == 0){
    80002666:	a4eff0ef          	jal	800018b4 <cpuid>
    8000266a:	cd11                	beqz	a0,80002686 <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r" (x) );
    8000266c:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    80002670:	000f4737          	lui	a4,0xf4
    80002674:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80002678:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    8000267a:	14d79073          	csrw	stimecmp,a5
}
    8000267e:	60e2                	ld	ra,24(sp)
    80002680:	6442                	ld	s0,16(sp)
    80002682:	6105                	addi	sp,sp,32
    80002684:	8082                	ret
    80002686:	e426                	sd	s1,8(sp)
    acquire(&tickslock);
    80002688:	0001c497          	auipc	s1,0x1c
    8000268c:	aa048493          	addi	s1,s1,-1376 # 8001e128 <tickslock>
    80002690:	8526                	mv	a0,s1
    80002692:	d62fe0ef          	jal	80000bf4 <acquire>
    ticks++;
    80002696:	00008517          	auipc	a0,0x8
    8000269a:	d1a50513          	addi	a0,a0,-742 # 8000a3b0 <ticks>
    8000269e:	411c                	lw	a5,0(a0)
    800026a0:	2785                	addiw	a5,a5,1
    800026a2:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    800026a4:	857ff0ef          	jal	80001efa <wakeup>
    release(&tickslock);
    800026a8:	8526                	mv	a0,s1
    800026aa:	de2fe0ef          	jal	80000c8c <release>
    800026ae:	64a2                	ld	s1,8(sp)
    800026b0:	bf75                	j	8000266c <clockintr+0xe>

00000000800026b2 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    800026b2:	1101                	addi	sp,sp,-32
    800026b4:	ec06                	sd	ra,24(sp)
    800026b6:	e822                	sd	s0,16(sp)
    800026b8:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    800026ba:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    800026be:	57fd                	li	a5,-1
    800026c0:	17fe                	slli	a5,a5,0x3f
    800026c2:	07a5                	addi	a5,a5,9
    800026c4:	00f70c63          	beq	a4,a5,800026dc <devintr+0x2a>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    800026c8:	57fd                	li	a5,-1
    800026ca:	17fe                	slli	a5,a5,0x3f
    800026cc:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    800026ce:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    800026d0:	04f70763          	beq	a4,a5,8000271e <devintr+0x6c>
  }
}
    800026d4:	60e2                	ld	ra,24(sp)
    800026d6:	6442                	ld	s0,16(sp)
    800026d8:	6105                	addi	sp,sp,32
    800026da:	8082                	ret
    800026dc:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    800026de:	5cf020ef          	jal	800054ac <plic_claim>
    800026e2:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    800026e4:	47a9                	li	a5,10
    800026e6:	00f50963          	beq	a0,a5,800026f8 <devintr+0x46>
    } else if(irq == VIRTIO0_IRQ){
    800026ea:	4785                	li	a5,1
    800026ec:	00f50963          	beq	a0,a5,800026fe <devintr+0x4c>
    return 1;
    800026f0:	4505                	li	a0,1
    } else if(irq){
    800026f2:	e889                	bnez	s1,80002704 <devintr+0x52>
    800026f4:	64a2                	ld	s1,8(sp)
    800026f6:	bff9                	j	800026d4 <devintr+0x22>
      uartintr();
    800026f8:	b0efe0ef          	jal	80000a06 <uartintr>
    if(irq)
    800026fc:	a819                	j	80002712 <devintr+0x60>
      virtio_disk_intr();
    800026fe:	274030ef          	jal	80005972 <virtio_disk_intr>
    if(irq)
    80002702:	a801                	j	80002712 <devintr+0x60>
      printf("unexpected interrupt irq=%d\n", irq);
    80002704:	85a6                	mv	a1,s1
    80002706:	00005517          	auipc	a0,0x5
    8000270a:	c7250513          	addi	a0,a0,-910 # 80007378 <etext+0x378>
    8000270e:	db5fd0ef          	jal	800004c2 <printf>
      plic_complete(irq);
    80002712:	8526                	mv	a0,s1
    80002714:	5b9020ef          	jal	800054cc <plic_complete>
    return 1;
    80002718:	4505                	li	a0,1
    8000271a:	64a2                	ld	s1,8(sp)
    8000271c:	bf65                	j	800026d4 <devintr+0x22>
    clockintr();
    8000271e:	f41ff0ef          	jal	8000265e <clockintr>
    return 2;
    80002722:	4509                	li	a0,2
    80002724:	bf45                	j	800026d4 <devintr+0x22>

0000000080002726 <usertrap>:
{
    80002726:	1101                	addi	sp,sp,-32
    80002728:	ec06                	sd	ra,24(sp)
    8000272a:	e822                	sd	s0,16(sp)
    8000272c:	e426                	sd	s1,8(sp)
    8000272e:	e04a                	sd	s2,0(sp)
    80002730:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002732:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002736:	1007f793          	andi	a5,a5,256
    8000273a:	ef85                	bnez	a5,80002772 <usertrap+0x4c>
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000273c:	00003797          	auipc	a5,0x3
    80002740:	cc478793          	addi	a5,a5,-828 # 80005400 <kernelvec>
    80002744:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002748:	998ff0ef          	jal	800018e0 <myproc>
    8000274c:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    8000274e:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002750:	14102773          	csrr	a4,sepc
    80002754:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002756:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    8000275a:	47a1                	li	a5,8
    8000275c:	02f70163          	beq	a4,a5,8000277e <usertrap+0x58>
  } else if((which_dev = devintr()) != 0){
    80002760:	f53ff0ef          	jal	800026b2 <devintr>
    80002764:	892a                	mv	s2,a0
    80002766:	c135                	beqz	a0,800027ca <usertrap+0xa4>
  if(killed(p))
    80002768:	8526                	mv	a0,s1
    8000276a:	97dff0ef          	jal	800020e6 <killed>
    8000276e:	cd1d                	beqz	a0,800027ac <usertrap+0x86>
    80002770:	a81d                	j	800027a6 <usertrap+0x80>
    panic("usertrap: not from user mode");
    80002772:	00005517          	auipc	a0,0x5
    80002776:	c2650513          	addi	a0,a0,-986 # 80007398 <etext+0x398>
    8000277a:	81afe0ef          	jal	80000794 <panic>
    if(killed(p))
    8000277e:	969ff0ef          	jal	800020e6 <killed>
    80002782:	e121                	bnez	a0,800027c2 <usertrap+0x9c>
    p->trapframe->epc += 4;
    80002784:	6cb8                	ld	a4,88(s1)
    80002786:	6f1c                	ld	a5,24(a4)
    80002788:	0791                	addi	a5,a5,4
    8000278a:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000278c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002790:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002794:	10079073          	csrw	sstatus,a5
    syscall();
    80002798:	248000ef          	jal	800029e0 <syscall>
  if(killed(p))
    8000279c:	8526                	mv	a0,s1
    8000279e:	949ff0ef          	jal	800020e6 <killed>
    800027a2:	c901                	beqz	a0,800027b2 <usertrap+0x8c>
    800027a4:	4901                	li	s2,0
    exit(-1);
    800027a6:	557d                	li	a0,-1
    800027a8:	813ff0ef          	jal	80001fba <exit>
  if(which_dev == 2)
    800027ac:	4789                	li	a5,2
    800027ae:	04f90563          	beq	s2,a5,800027f8 <usertrap+0xd2>
  usertrapret();
    800027b2:	e1bff0ef          	jal	800025cc <usertrapret>
}
    800027b6:	60e2                	ld	ra,24(sp)
    800027b8:	6442                	ld	s0,16(sp)
    800027ba:	64a2                	ld	s1,8(sp)
    800027bc:	6902                	ld	s2,0(sp)
    800027be:	6105                	addi	sp,sp,32
    800027c0:	8082                	ret
      exit(-1);
    800027c2:	557d                	li	a0,-1
    800027c4:	ff6ff0ef          	jal	80001fba <exit>
    800027c8:	bf75                	j	80002784 <usertrap+0x5e>
  asm volatile("csrr %0, scause" : "=r" (x) );
    800027ca:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    800027ce:	5890                	lw	a2,48(s1)
    800027d0:	00005517          	auipc	a0,0x5
    800027d4:	be850513          	addi	a0,a0,-1048 # 800073b8 <etext+0x3b8>
    800027d8:	cebfd0ef          	jal	800004c2 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800027dc:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800027e0:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    800027e4:	00005517          	auipc	a0,0x5
    800027e8:	c0450513          	addi	a0,a0,-1020 # 800073e8 <etext+0x3e8>
    800027ec:	cd7fd0ef          	jal	800004c2 <printf>
    setkilled(p);
    800027f0:	8526                	mv	a0,s1
    800027f2:	8d1ff0ef          	jal	800020c2 <setkilled>
    800027f6:	b75d                	j	8000279c <usertrap+0x76>
    yield();
    800027f8:	e8aff0ef          	jal	80001e82 <yield>
    800027fc:	bf5d                	j	800027b2 <usertrap+0x8c>

00000000800027fe <kerneltrap>:
{
    800027fe:	7179                	addi	sp,sp,-48
    80002800:	f406                	sd	ra,40(sp)
    80002802:	f022                	sd	s0,32(sp)
    80002804:	ec26                	sd	s1,24(sp)
    80002806:	e84a                	sd	s2,16(sp)
    80002808:	e44e                	sd	s3,8(sp)
    8000280a:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000280c:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002810:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002814:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002818:	1004f793          	andi	a5,s1,256
    8000281c:	c795                	beqz	a5,80002848 <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000281e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002822:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002824:	eb85                	bnez	a5,80002854 <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    80002826:	e8dff0ef          	jal	800026b2 <devintr>
    8000282a:	c91d                	beqz	a0,80002860 <kerneltrap+0x62>
  if(which_dev == 2 && myproc() != 0)
    8000282c:	4789                	li	a5,2
    8000282e:	04f50a63          	beq	a0,a5,80002882 <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002832:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002836:	10049073          	csrw	sstatus,s1
}
    8000283a:	70a2                	ld	ra,40(sp)
    8000283c:	7402                	ld	s0,32(sp)
    8000283e:	64e2                	ld	s1,24(sp)
    80002840:	6942                	ld	s2,16(sp)
    80002842:	69a2                	ld	s3,8(sp)
    80002844:	6145                	addi	sp,sp,48
    80002846:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002848:	00005517          	auipc	a0,0x5
    8000284c:	bc850513          	addi	a0,a0,-1080 # 80007410 <etext+0x410>
    80002850:	f45fd0ef          	jal	80000794 <panic>
    panic("kerneltrap: interrupts enabled");
    80002854:	00005517          	auipc	a0,0x5
    80002858:	be450513          	addi	a0,a0,-1052 # 80007438 <etext+0x438>
    8000285c:	f39fd0ef          	jal	80000794 <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002860:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002864:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    80002868:	85ce                	mv	a1,s3
    8000286a:	00005517          	auipc	a0,0x5
    8000286e:	bee50513          	addi	a0,a0,-1042 # 80007458 <etext+0x458>
    80002872:	c51fd0ef          	jal	800004c2 <printf>
    panic("kerneltrap");
    80002876:	00005517          	auipc	a0,0x5
    8000287a:	c0a50513          	addi	a0,a0,-1014 # 80007480 <etext+0x480>
    8000287e:	f17fd0ef          	jal	80000794 <panic>
  if(which_dev == 2 && myproc() != 0)
    80002882:	85eff0ef          	jal	800018e0 <myproc>
    80002886:	d555                	beqz	a0,80002832 <kerneltrap+0x34>
    yield();
    80002888:	dfaff0ef          	jal	80001e82 <yield>
    8000288c:	b75d                	j	80002832 <kerneltrap+0x34>

000000008000288e <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    8000288e:	1101                	addi	sp,sp,-32
    80002890:	ec06                	sd	ra,24(sp)
    80002892:	e822                	sd	s0,16(sp)
    80002894:	e426                	sd	s1,8(sp)
    80002896:	1000                	addi	s0,sp,32
    80002898:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    8000289a:	846ff0ef          	jal	800018e0 <myproc>
  switch (n) {
    8000289e:	4795                	li	a5,5
    800028a0:	0497e163          	bltu	a5,s1,800028e2 <argraw+0x54>
    800028a4:	048a                	slli	s1,s1,0x2
    800028a6:	00005717          	auipc	a4,0x5
    800028aa:	fb270713          	addi	a4,a4,-78 # 80007858 <states.0+0x30>
    800028ae:	94ba                	add	s1,s1,a4
    800028b0:	409c                	lw	a5,0(s1)
    800028b2:	97ba                	add	a5,a5,a4
    800028b4:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    800028b6:	6d3c                	ld	a5,88(a0)
    800028b8:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    800028ba:	60e2                	ld	ra,24(sp)
    800028bc:	6442                	ld	s0,16(sp)
    800028be:	64a2                	ld	s1,8(sp)
    800028c0:	6105                	addi	sp,sp,32
    800028c2:	8082                	ret
    return p->trapframe->a1;
    800028c4:	6d3c                	ld	a5,88(a0)
    800028c6:	7fa8                	ld	a0,120(a5)
    800028c8:	bfcd                	j	800028ba <argraw+0x2c>
    return p->trapframe->a2;
    800028ca:	6d3c                	ld	a5,88(a0)
    800028cc:	63c8                	ld	a0,128(a5)
    800028ce:	b7f5                	j	800028ba <argraw+0x2c>
    return p->trapframe->a3;
    800028d0:	6d3c                	ld	a5,88(a0)
    800028d2:	67c8                	ld	a0,136(a5)
    800028d4:	b7dd                	j	800028ba <argraw+0x2c>
    return p->trapframe->a4;
    800028d6:	6d3c                	ld	a5,88(a0)
    800028d8:	6bc8                	ld	a0,144(a5)
    800028da:	b7c5                	j	800028ba <argraw+0x2c>
    return p->trapframe->a5;
    800028dc:	6d3c                	ld	a5,88(a0)
    800028de:	6fc8                	ld	a0,152(a5)
    800028e0:	bfe9                	j	800028ba <argraw+0x2c>
  panic("argraw");
    800028e2:	00005517          	auipc	a0,0x5
    800028e6:	bae50513          	addi	a0,a0,-1106 # 80007490 <etext+0x490>
    800028ea:	eabfd0ef          	jal	80000794 <panic>

00000000800028ee <fetchaddr>:
{
    800028ee:	1101                	addi	sp,sp,-32
    800028f0:	ec06                	sd	ra,24(sp)
    800028f2:	e822                	sd	s0,16(sp)
    800028f4:	e426                	sd	s1,8(sp)
    800028f6:	e04a                	sd	s2,0(sp)
    800028f8:	1000                	addi	s0,sp,32
    800028fa:	84aa                	mv	s1,a0
    800028fc:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800028fe:	fe3fe0ef          	jal	800018e0 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002902:	653c                	ld	a5,72(a0)
    80002904:	02f4f663          	bgeu	s1,a5,80002930 <fetchaddr+0x42>
    80002908:	00848713          	addi	a4,s1,8
    8000290c:	02e7e463          	bltu	a5,a4,80002934 <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002910:	46a1                	li	a3,8
    80002912:	8626                	mv	a2,s1
    80002914:	85ca                	mv	a1,s2
    80002916:	6928                	ld	a0,80(a0)
    80002918:	d11fe0ef          	jal	80001628 <copyin>
    8000291c:	00a03533          	snez	a0,a0
    80002920:	40a00533          	neg	a0,a0
}
    80002924:	60e2                	ld	ra,24(sp)
    80002926:	6442                	ld	s0,16(sp)
    80002928:	64a2                	ld	s1,8(sp)
    8000292a:	6902                	ld	s2,0(sp)
    8000292c:	6105                	addi	sp,sp,32
    8000292e:	8082                	ret
    return -1;
    80002930:	557d                	li	a0,-1
    80002932:	bfcd                	j	80002924 <fetchaddr+0x36>
    80002934:	557d                	li	a0,-1
    80002936:	b7fd                	j	80002924 <fetchaddr+0x36>

0000000080002938 <fetchstr>:
{
    80002938:	7179                	addi	sp,sp,-48
    8000293a:	f406                	sd	ra,40(sp)
    8000293c:	f022                	sd	s0,32(sp)
    8000293e:	ec26                	sd	s1,24(sp)
    80002940:	e84a                	sd	s2,16(sp)
    80002942:	e44e                	sd	s3,8(sp)
    80002944:	1800                	addi	s0,sp,48
    80002946:	892a                	mv	s2,a0
    80002948:	84ae                	mv	s1,a1
    8000294a:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    8000294c:	f95fe0ef          	jal	800018e0 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002950:	86ce                	mv	a3,s3
    80002952:	864a                	mv	a2,s2
    80002954:	85a6                	mv	a1,s1
    80002956:	6928                	ld	a0,80(a0)
    80002958:	d57fe0ef          	jal	800016ae <copyinstr>
    8000295c:	00054c63          	bltz	a0,80002974 <fetchstr+0x3c>
  return strlen(buf);
    80002960:	8526                	mv	a0,s1
    80002962:	cd6fe0ef          	jal	80000e38 <strlen>
}
    80002966:	70a2                	ld	ra,40(sp)
    80002968:	7402                	ld	s0,32(sp)
    8000296a:	64e2                	ld	s1,24(sp)
    8000296c:	6942                	ld	s2,16(sp)
    8000296e:	69a2                	ld	s3,8(sp)
    80002970:	6145                	addi	sp,sp,48
    80002972:	8082                	ret
    return -1;
    80002974:	557d                	li	a0,-1
    80002976:	bfc5                	j	80002966 <fetchstr+0x2e>

0000000080002978 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002978:	1101                	addi	sp,sp,-32
    8000297a:	ec06                	sd	ra,24(sp)
    8000297c:	e822                	sd	s0,16(sp)
    8000297e:	e426                	sd	s1,8(sp)
    80002980:	1000                	addi	s0,sp,32
    80002982:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002984:	f0bff0ef          	jal	8000288e <argraw>
    80002988:	c088                	sw	a0,0(s1)
}
    8000298a:	60e2                	ld	ra,24(sp)
    8000298c:	6442                	ld	s0,16(sp)
    8000298e:	64a2                	ld	s1,8(sp)
    80002990:	6105                	addi	sp,sp,32
    80002992:	8082                	ret

0000000080002994 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002994:	1101                	addi	sp,sp,-32
    80002996:	ec06                	sd	ra,24(sp)
    80002998:	e822                	sd	s0,16(sp)
    8000299a:	e426                	sd	s1,8(sp)
    8000299c:	1000                	addi	s0,sp,32
    8000299e:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800029a0:	eefff0ef          	jal	8000288e <argraw>
    800029a4:	e088                	sd	a0,0(s1)
}
    800029a6:	60e2                	ld	ra,24(sp)
    800029a8:	6442                	ld	s0,16(sp)
    800029aa:	64a2                	ld	s1,8(sp)
    800029ac:	6105                	addi	sp,sp,32
    800029ae:	8082                	ret

00000000800029b0 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    800029b0:	7179                	addi	sp,sp,-48
    800029b2:	f406                	sd	ra,40(sp)
    800029b4:	f022                	sd	s0,32(sp)
    800029b6:	ec26                	sd	s1,24(sp)
    800029b8:	e84a                	sd	s2,16(sp)
    800029ba:	1800                	addi	s0,sp,48
    800029bc:	84ae                	mv	s1,a1
    800029be:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    800029c0:	fd840593          	addi	a1,s0,-40
    800029c4:	fd1ff0ef          	jal	80002994 <argaddr>
  return fetchstr(addr, buf, max);
    800029c8:	864a                	mv	a2,s2
    800029ca:	85a6                	mv	a1,s1
    800029cc:	fd843503          	ld	a0,-40(s0)
    800029d0:	f69ff0ef          	jal	80002938 <fetchstr>
}
    800029d4:	70a2                	ld	ra,40(sp)
    800029d6:	7402                	ld	s0,32(sp)
    800029d8:	64e2                	ld	s1,24(sp)
    800029da:	6942                	ld	s2,16(sp)
    800029dc:	6145                	addi	sp,sp,48
    800029de:	8082                	ret

00000000800029e0 <syscall>:
[SYS_fork2]    sys_fork2,
};

void
syscall(void)
{
    800029e0:	1101                	addi	sp,sp,-32
    800029e2:	ec06                	sd	ra,24(sp)
    800029e4:	e822                	sd	s0,16(sp)
    800029e6:	e426                	sd	s1,8(sp)
    800029e8:	e04a                	sd	s2,0(sp)
    800029ea:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    800029ec:	ef5fe0ef          	jal	800018e0 <myproc>
    800029f0:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    800029f2:	05853903          	ld	s2,88(a0)
    800029f6:	0a893783          	ld	a5,168(s2)
    800029fa:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    800029fe:	37fd                	addiw	a5,a5,-1
    80002a00:	4759                	li	a4,22
    80002a02:	00f76f63          	bltu	a4,a5,80002a20 <syscall+0x40>
    80002a06:	00369713          	slli	a4,a3,0x3
    80002a0a:	00005797          	auipc	a5,0x5
    80002a0e:	e6678793          	addi	a5,a5,-410 # 80007870 <syscalls>
    80002a12:	97ba                	add	a5,a5,a4
    80002a14:	639c                	ld	a5,0(a5)
    80002a16:	c789                	beqz	a5,80002a20 <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002a18:	9782                	jalr	a5
    80002a1a:	06a93823          	sd	a0,112(s2)
    80002a1e:	a829                	j	80002a38 <syscall+0x58>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002a20:	15848613          	addi	a2,s1,344
    80002a24:	588c                	lw	a1,48(s1)
    80002a26:	00005517          	auipc	a0,0x5
    80002a2a:	a7250513          	addi	a0,a0,-1422 # 80007498 <etext+0x498>
    80002a2e:	a95fd0ef          	jal	800004c2 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002a32:	6cbc                	ld	a5,88(s1)
    80002a34:	577d                	li	a4,-1
    80002a36:	fbb8                	sd	a4,112(a5)
  }
}
    80002a38:	60e2                	ld	ra,24(sp)
    80002a3a:	6442                	ld	s0,16(sp)
    80002a3c:	64a2                	ld	s1,8(sp)
    80002a3e:	6902                	ld	s2,0(sp)
    80002a40:	6105                	addi	sp,sp,32
    80002a42:	8082                	ret

0000000080002a44 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002a44:	1101                	addi	sp,sp,-32
    80002a46:	ec06                	sd	ra,24(sp)
    80002a48:	e822                	sd	s0,16(sp)
    80002a4a:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002a4c:	fec40593          	addi	a1,s0,-20
    80002a50:	4501                	li	a0,0
    80002a52:	f27ff0ef          	jal	80002978 <argint>
  exit(n);
    80002a56:	fec42503          	lw	a0,-20(s0)
    80002a5a:	d60ff0ef          	jal	80001fba <exit>
  return 0;  // not reached
}
    80002a5e:	4501                	li	a0,0
    80002a60:	60e2                	ld	ra,24(sp)
    80002a62:	6442                	ld	s0,16(sp)
    80002a64:	6105                	addi	sp,sp,32
    80002a66:	8082                	ret

0000000080002a68 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002a68:	1141                	addi	sp,sp,-16
    80002a6a:	e406                	sd	ra,8(sp)
    80002a6c:	e022                	sd	s0,0(sp)
    80002a6e:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002a70:	e71fe0ef          	jal	800018e0 <myproc>
}
    80002a74:	5908                	lw	a0,48(a0)
    80002a76:	60a2                	ld	ra,8(sp)
    80002a78:	6402                	ld	s0,0(sp)
    80002a7a:	0141                	addi	sp,sp,16
    80002a7c:	8082                	ret

0000000080002a7e <sys_fork>:

uint64
sys_fork(void)
{
    80002a7e:	1141                	addi	sp,sp,-16
    80002a80:	e406                	sd	ra,8(sp)
    80002a82:	e022                	sd	s0,0(sp)
    80002a84:	0800                	addi	s0,sp,16
  return fork();
    80002a86:	980ff0ef          	jal	80001c06 <fork>
}
    80002a8a:	60a2                	ld	ra,8(sp)
    80002a8c:	6402                	ld	s0,0(sp)
    80002a8e:	0141                	addi	sp,sp,16
    80002a90:	8082                	ret

0000000080002a92 <sys_wait>:

uint64
sys_wait(void)
{
    80002a92:	1101                	addi	sp,sp,-32
    80002a94:	ec06                	sd	ra,24(sp)
    80002a96:	e822                	sd	s0,16(sp)
    80002a98:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002a9a:	fe840593          	addi	a1,s0,-24
    80002a9e:	4501                	li	a0,0
    80002aa0:	ef5ff0ef          	jal	80002994 <argaddr>
  return wait(p);
    80002aa4:	fe843503          	ld	a0,-24(s0)
    80002aa8:	e68ff0ef          	jal	80002110 <wait>
}
    80002aac:	60e2                	ld	ra,24(sp)
    80002aae:	6442                	ld	s0,16(sp)
    80002ab0:	6105                	addi	sp,sp,32
    80002ab2:	8082                	ret

0000000080002ab4 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002ab4:	7179                	addi	sp,sp,-48
    80002ab6:	f406                	sd	ra,40(sp)
    80002ab8:	f022                	sd	s0,32(sp)
    80002aba:	ec26                	sd	s1,24(sp)
    80002abc:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80002abe:	fdc40593          	addi	a1,s0,-36
    80002ac2:	4501                	li	a0,0
    80002ac4:	eb5ff0ef          	jal	80002978 <argint>
  addr = myproc()->sz;
    80002ac8:	e19fe0ef          	jal	800018e0 <myproc>
    80002acc:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    80002ace:	fdc42503          	lw	a0,-36(s0)
    80002ad2:	8e4ff0ef          	jal	80001bb6 <growproc>
    80002ad6:	00054863          	bltz	a0,80002ae6 <sys_sbrk+0x32>
    return -1;
  return addr;
}
    80002ada:	8526                	mv	a0,s1
    80002adc:	70a2                	ld	ra,40(sp)
    80002ade:	7402                	ld	s0,32(sp)
    80002ae0:	64e2                	ld	s1,24(sp)
    80002ae2:	6145                	addi	sp,sp,48
    80002ae4:	8082                	ret
    return -1;
    80002ae6:	54fd                	li	s1,-1
    80002ae8:	bfcd                	j	80002ada <sys_sbrk+0x26>

0000000080002aea <sys_sleep>:

uint64
sys_sleep(void)
{
    80002aea:	7139                	addi	sp,sp,-64
    80002aec:	fc06                	sd	ra,56(sp)
    80002aee:	f822                	sd	s0,48(sp)
    80002af0:	f04a                	sd	s2,32(sp)
    80002af2:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002af4:	fcc40593          	addi	a1,s0,-52
    80002af8:	4501                	li	a0,0
    80002afa:	e7fff0ef          	jal	80002978 <argint>
  if(n < 0)
    80002afe:	fcc42783          	lw	a5,-52(s0)
    80002b02:	0607c763          	bltz	a5,80002b70 <sys_sleep+0x86>
    n = 0;
  acquire(&tickslock);
    80002b06:	0001b517          	auipc	a0,0x1b
    80002b0a:	62250513          	addi	a0,a0,1570 # 8001e128 <tickslock>
    80002b0e:	8e6fe0ef          	jal	80000bf4 <acquire>
  ticks0 = ticks;
    80002b12:	00008917          	auipc	s2,0x8
    80002b16:	89e92903          	lw	s2,-1890(s2) # 8000a3b0 <ticks>
  while(ticks - ticks0 < n){
    80002b1a:	fcc42783          	lw	a5,-52(s0)
    80002b1e:	cf8d                	beqz	a5,80002b58 <sys_sleep+0x6e>
    80002b20:	f426                	sd	s1,40(sp)
    80002b22:	ec4e                	sd	s3,24(sp)
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002b24:	0001b997          	auipc	s3,0x1b
    80002b28:	60498993          	addi	s3,s3,1540 # 8001e128 <tickslock>
    80002b2c:	00008497          	auipc	s1,0x8
    80002b30:	88448493          	addi	s1,s1,-1916 # 8000a3b0 <ticks>
    if(killed(myproc())){
    80002b34:	dadfe0ef          	jal	800018e0 <myproc>
    80002b38:	daeff0ef          	jal	800020e6 <killed>
    80002b3c:	ed0d                	bnez	a0,80002b76 <sys_sleep+0x8c>
    sleep(&ticks, &tickslock);
    80002b3e:	85ce                	mv	a1,s3
    80002b40:	8526                	mv	a0,s1
    80002b42:	b6cff0ef          	jal	80001eae <sleep>
  while(ticks - ticks0 < n){
    80002b46:	409c                	lw	a5,0(s1)
    80002b48:	412787bb          	subw	a5,a5,s2
    80002b4c:	fcc42703          	lw	a4,-52(s0)
    80002b50:	fee7e2e3          	bltu	a5,a4,80002b34 <sys_sleep+0x4a>
    80002b54:	74a2                	ld	s1,40(sp)
    80002b56:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80002b58:	0001b517          	auipc	a0,0x1b
    80002b5c:	5d050513          	addi	a0,a0,1488 # 8001e128 <tickslock>
    80002b60:	92cfe0ef          	jal	80000c8c <release>
  return 0;
    80002b64:	4501                	li	a0,0
}
    80002b66:	70e2                	ld	ra,56(sp)
    80002b68:	7442                	ld	s0,48(sp)
    80002b6a:	7902                	ld	s2,32(sp)
    80002b6c:	6121                	addi	sp,sp,64
    80002b6e:	8082                	ret
    n = 0;
    80002b70:	fc042623          	sw	zero,-52(s0)
    80002b74:	bf49                	j	80002b06 <sys_sleep+0x1c>
      release(&tickslock);
    80002b76:	0001b517          	auipc	a0,0x1b
    80002b7a:	5b250513          	addi	a0,a0,1458 # 8001e128 <tickslock>
    80002b7e:	90efe0ef          	jal	80000c8c <release>
      return -1;
    80002b82:	557d                	li	a0,-1
    80002b84:	74a2                	ld	s1,40(sp)
    80002b86:	69e2                	ld	s3,24(sp)
    80002b88:	bff9                	j	80002b66 <sys_sleep+0x7c>

0000000080002b8a <sys_kill>:

uint64
sys_kill(void)
{
    80002b8a:	1101                	addi	sp,sp,-32
    80002b8c:	ec06                	sd	ra,24(sp)
    80002b8e:	e822                	sd	s0,16(sp)
    80002b90:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002b92:	fec40593          	addi	a1,s0,-20
    80002b96:	4501                	li	a0,0
    80002b98:	de1ff0ef          	jal	80002978 <argint>
  return kill(pid);
    80002b9c:	fec42503          	lw	a0,-20(s0)
    80002ba0:	cbcff0ef          	jal	8000205c <kill>
}
    80002ba4:	60e2                	ld	ra,24(sp)
    80002ba6:	6442                	ld	s0,16(sp)
    80002ba8:	6105                	addi	sp,sp,32
    80002baa:	8082                	ret

0000000080002bac <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002bac:	1101                	addi	sp,sp,-32
    80002bae:	ec06                	sd	ra,24(sp)
    80002bb0:	e822                	sd	s0,16(sp)
    80002bb2:	e426                	sd	s1,8(sp)
    80002bb4:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002bb6:	0001b517          	auipc	a0,0x1b
    80002bba:	57250513          	addi	a0,a0,1394 # 8001e128 <tickslock>
    80002bbe:	836fe0ef          	jal	80000bf4 <acquire>
  xticks = ticks;
    80002bc2:	00007497          	auipc	s1,0x7
    80002bc6:	7ee4a483          	lw	s1,2030(s1) # 8000a3b0 <ticks>
  release(&tickslock);
    80002bca:	0001b517          	auipc	a0,0x1b
    80002bce:	55e50513          	addi	a0,a0,1374 # 8001e128 <tickslock>
    80002bd2:	8bafe0ef          	jal	80000c8c <release>
  return xticks;
}
    80002bd6:	02049513          	slli	a0,s1,0x20
    80002bda:	9101                	srli	a0,a0,0x20
    80002bdc:	60e2                	ld	ra,24(sp)
    80002bde:	6442                	ld	s0,16(sp)
    80002be0:	64a2                	ld	s1,8(sp)
    80002be2:	6105                	addi	sp,sp,32
    80002be4:	8082                	ret

0000000080002be6 <sys_ps>:

uint64
sys_ps ( void )
{
    80002be6:	1141                	addi	sp,sp,-16
    80002be8:	e406                	sd	ra,8(sp)
    80002bea:	e022                	sd	s0,0(sp)
    80002bec:	0800                	addi	s0,sp,16
return ps ();
    80002bee:	f54ff0ef          	jal	80002342 <ps>
}  
    80002bf2:	60a2                	ld	ra,8(sp)
    80002bf4:	6402                	ld	s0,0(sp)
    80002bf6:	0141                	addi	sp,sp,16
    80002bf8:	8082                	ret

0000000080002bfa <sys_fork2>:

uint64
sys_fork2(void)
{
    80002bfa:	1101                	addi	sp,sp,-32
    80002bfc:	ec06                	sd	ra,24(sp)
    80002bfe:	e822                	sd	s0,16(sp)
    80002c00:	1000                	addi	s0,sp,32
    int priority;

    // Fetch the priority argument from the user space
    argint(0, &priority); // No return value check needed
    80002c02:	fec40593          	addi	a1,s0,-20
    80002c06:	4501                	li	a0,0
    80002c08:	d71ff0ef          	jal	80002978 <argint>

    // Call the new fork function with the given priority
    return fork_with_priority(priority);
    80002c0c:	fec42503          	lw	a0,-20(s0)
    80002c10:	82fff0ef          	jal	8000243e <fork_with_priority>
    80002c14:	60e2                	ld	ra,24(sp)
    80002c16:	6442                	ld	s0,16(sp)
    80002c18:	6105                	addi	sp,sp,32
    80002c1a:	8082                	ret

0000000080002c1c <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002c1c:	7179                	addi	sp,sp,-48
    80002c1e:	f406                	sd	ra,40(sp)
    80002c20:	f022                	sd	s0,32(sp)
    80002c22:	ec26                	sd	s1,24(sp)
    80002c24:	e84a                	sd	s2,16(sp)
    80002c26:	e44e                	sd	s3,8(sp)
    80002c28:	e052                	sd	s4,0(sp)
    80002c2a:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002c2c:	00005597          	auipc	a1,0x5
    80002c30:	88c58593          	addi	a1,a1,-1908 # 800074b8 <etext+0x4b8>
    80002c34:	0001b517          	auipc	a0,0x1b
    80002c38:	50c50513          	addi	a0,a0,1292 # 8001e140 <bcache>
    80002c3c:	f39fd0ef          	jal	80000b74 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002c40:	00023797          	auipc	a5,0x23
    80002c44:	50078793          	addi	a5,a5,1280 # 80026140 <bcache+0x8000>
    80002c48:	00023717          	auipc	a4,0x23
    80002c4c:	76070713          	addi	a4,a4,1888 # 800263a8 <bcache+0x8268>
    80002c50:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002c54:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002c58:	0001b497          	auipc	s1,0x1b
    80002c5c:	50048493          	addi	s1,s1,1280 # 8001e158 <bcache+0x18>
    b->next = bcache.head.next;
    80002c60:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002c62:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002c64:	00005a17          	auipc	s4,0x5
    80002c68:	85ca0a13          	addi	s4,s4,-1956 # 800074c0 <etext+0x4c0>
    b->next = bcache.head.next;
    80002c6c:	2b893783          	ld	a5,696(s2)
    80002c70:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002c72:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002c76:	85d2                	mv	a1,s4
    80002c78:	01048513          	addi	a0,s1,16
    80002c7c:	248010ef          	jal	80003ec4 <initsleeplock>
    bcache.head.next->prev = b;
    80002c80:	2b893783          	ld	a5,696(s2)
    80002c84:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002c86:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002c8a:	45848493          	addi	s1,s1,1112
    80002c8e:	fd349fe3          	bne	s1,s3,80002c6c <binit+0x50>
  }
}
    80002c92:	70a2                	ld	ra,40(sp)
    80002c94:	7402                	ld	s0,32(sp)
    80002c96:	64e2                	ld	s1,24(sp)
    80002c98:	6942                	ld	s2,16(sp)
    80002c9a:	69a2                	ld	s3,8(sp)
    80002c9c:	6a02                	ld	s4,0(sp)
    80002c9e:	6145                	addi	sp,sp,48
    80002ca0:	8082                	ret

0000000080002ca2 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002ca2:	7179                	addi	sp,sp,-48
    80002ca4:	f406                	sd	ra,40(sp)
    80002ca6:	f022                	sd	s0,32(sp)
    80002ca8:	ec26                	sd	s1,24(sp)
    80002caa:	e84a                	sd	s2,16(sp)
    80002cac:	e44e                	sd	s3,8(sp)
    80002cae:	1800                	addi	s0,sp,48
    80002cb0:	892a                	mv	s2,a0
    80002cb2:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002cb4:	0001b517          	auipc	a0,0x1b
    80002cb8:	48c50513          	addi	a0,a0,1164 # 8001e140 <bcache>
    80002cbc:	f39fd0ef          	jal	80000bf4 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002cc0:	00023497          	auipc	s1,0x23
    80002cc4:	7384b483          	ld	s1,1848(s1) # 800263f8 <bcache+0x82b8>
    80002cc8:	00023797          	auipc	a5,0x23
    80002ccc:	6e078793          	addi	a5,a5,1760 # 800263a8 <bcache+0x8268>
    80002cd0:	02f48b63          	beq	s1,a5,80002d06 <bread+0x64>
    80002cd4:	873e                	mv	a4,a5
    80002cd6:	a021                	j	80002cde <bread+0x3c>
    80002cd8:	68a4                	ld	s1,80(s1)
    80002cda:	02e48663          	beq	s1,a4,80002d06 <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    80002cde:	449c                	lw	a5,8(s1)
    80002ce0:	ff279ce3          	bne	a5,s2,80002cd8 <bread+0x36>
    80002ce4:	44dc                	lw	a5,12(s1)
    80002ce6:	ff3799e3          	bne	a5,s3,80002cd8 <bread+0x36>
      b->refcnt++;
    80002cea:	40bc                	lw	a5,64(s1)
    80002cec:	2785                	addiw	a5,a5,1
    80002cee:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002cf0:	0001b517          	auipc	a0,0x1b
    80002cf4:	45050513          	addi	a0,a0,1104 # 8001e140 <bcache>
    80002cf8:	f95fd0ef          	jal	80000c8c <release>
      acquiresleep(&b->lock);
    80002cfc:	01048513          	addi	a0,s1,16
    80002d00:	1fa010ef          	jal	80003efa <acquiresleep>
      return b;
    80002d04:	a889                	j	80002d56 <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002d06:	00023497          	auipc	s1,0x23
    80002d0a:	6ea4b483          	ld	s1,1770(s1) # 800263f0 <bcache+0x82b0>
    80002d0e:	00023797          	auipc	a5,0x23
    80002d12:	69a78793          	addi	a5,a5,1690 # 800263a8 <bcache+0x8268>
    80002d16:	00f48863          	beq	s1,a5,80002d26 <bread+0x84>
    80002d1a:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002d1c:	40bc                	lw	a5,64(s1)
    80002d1e:	cb91                	beqz	a5,80002d32 <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002d20:	64a4                	ld	s1,72(s1)
    80002d22:	fee49de3          	bne	s1,a4,80002d1c <bread+0x7a>
  panic("bget: no buffers");
    80002d26:	00004517          	auipc	a0,0x4
    80002d2a:	7a250513          	addi	a0,a0,1954 # 800074c8 <etext+0x4c8>
    80002d2e:	a67fd0ef          	jal	80000794 <panic>
      b->dev = dev;
    80002d32:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002d36:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002d3a:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002d3e:	4785                	li	a5,1
    80002d40:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002d42:	0001b517          	auipc	a0,0x1b
    80002d46:	3fe50513          	addi	a0,a0,1022 # 8001e140 <bcache>
    80002d4a:	f43fd0ef          	jal	80000c8c <release>
      acquiresleep(&b->lock);
    80002d4e:	01048513          	addi	a0,s1,16
    80002d52:	1a8010ef          	jal	80003efa <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002d56:	409c                	lw	a5,0(s1)
    80002d58:	cb89                	beqz	a5,80002d6a <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002d5a:	8526                	mv	a0,s1
    80002d5c:	70a2                	ld	ra,40(sp)
    80002d5e:	7402                	ld	s0,32(sp)
    80002d60:	64e2                	ld	s1,24(sp)
    80002d62:	6942                	ld	s2,16(sp)
    80002d64:	69a2                	ld	s3,8(sp)
    80002d66:	6145                	addi	sp,sp,48
    80002d68:	8082                	ret
    virtio_disk_rw(b, 0);
    80002d6a:	4581                	li	a1,0
    80002d6c:	8526                	mv	a0,s1
    80002d6e:	1f3020ef          	jal	80005760 <virtio_disk_rw>
    b->valid = 1;
    80002d72:	4785                	li	a5,1
    80002d74:	c09c                	sw	a5,0(s1)
  return b;
    80002d76:	b7d5                	j	80002d5a <bread+0xb8>

0000000080002d78 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002d78:	1101                	addi	sp,sp,-32
    80002d7a:	ec06                	sd	ra,24(sp)
    80002d7c:	e822                	sd	s0,16(sp)
    80002d7e:	e426                	sd	s1,8(sp)
    80002d80:	1000                	addi	s0,sp,32
    80002d82:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002d84:	0541                	addi	a0,a0,16
    80002d86:	1f2010ef          	jal	80003f78 <holdingsleep>
    80002d8a:	c911                	beqz	a0,80002d9e <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002d8c:	4585                	li	a1,1
    80002d8e:	8526                	mv	a0,s1
    80002d90:	1d1020ef          	jal	80005760 <virtio_disk_rw>
}
    80002d94:	60e2                	ld	ra,24(sp)
    80002d96:	6442                	ld	s0,16(sp)
    80002d98:	64a2                	ld	s1,8(sp)
    80002d9a:	6105                	addi	sp,sp,32
    80002d9c:	8082                	ret
    panic("bwrite");
    80002d9e:	00004517          	auipc	a0,0x4
    80002da2:	74250513          	addi	a0,a0,1858 # 800074e0 <etext+0x4e0>
    80002da6:	9effd0ef          	jal	80000794 <panic>

0000000080002daa <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002daa:	1101                	addi	sp,sp,-32
    80002dac:	ec06                	sd	ra,24(sp)
    80002dae:	e822                	sd	s0,16(sp)
    80002db0:	e426                	sd	s1,8(sp)
    80002db2:	e04a                	sd	s2,0(sp)
    80002db4:	1000                	addi	s0,sp,32
    80002db6:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002db8:	01050913          	addi	s2,a0,16
    80002dbc:	854a                	mv	a0,s2
    80002dbe:	1ba010ef          	jal	80003f78 <holdingsleep>
    80002dc2:	c135                	beqz	a0,80002e26 <brelse+0x7c>
    panic("brelse");

  releasesleep(&b->lock);
    80002dc4:	854a                	mv	a0,s2
    80002dc6:	17a010ef          	jal	80003f40 <releasesleep>

  acquire(&bcache.lock);
    80002dca:	0001b517          	auipc	a0,0x1b
    80002dce:	37650513          	addi	a0,a0,886 # 8001e140 <bcache>
    80002dd2:	e23fd0ef          	jal	80000bf4 <acquire>
  b->refcnt--;
    80002dd6:	40bc                	lw	a5,64(s1)
    80002dd8:	37fd                	addiw	a5,a5,-1
    80002dda:	0007871b          	sext.w	a4,a5
    80002dde:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002de0:	e71d                	bnez	a4,80002e0e <brelse+0x64>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002de2:	68b8                	ld	a4,80(s1)
    80002de4:	64bc                	ld	a5,72(s1)
    80002de6:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80002de8:	68b8                	ld	a4,80(s1)
    80002dea:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002dec:	00023797          	auipc	a5,0x23
    80002df0:	35478793          	addi	a5,a5,852 # 80026140 <bcache+0x8000>
    80002df4:	2b87b703          	ld	a4,696(a5)
    80002df8:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002dfa:	00023717          	auipc	a4,0x23
    80002dfe:	5ae70713          	addi	a4,a4,1454 # 800263a8 <bcache+0x8268>
    80002e02:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002e04:	2b87b703          	ld	a4,696(a5)
    80002e08:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002e0a:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80002e0e:	0001b517          	auipc	a0,0x1b
    80002e12:	33250513          	addi	a0,a0,818 # 8001e140 <bcache>
    80002e16:	e77fd0ef          	jal	80000c8c <release>
}
    80002e1a:	60e2                	ld	ra,24(sp)
    80002e1c:	6442                	ld	s0,16(sp)
    80002e1e:	64a2                	ld	s1,8(sp)
    80002e20:	6902                	ld	s2,0(sp)
    80002e22:	6105                	addi	sp,sp,32
    80002e24:	8082                	ret
    panic("brelse");
    80002e26:	00004517          	auipc	a0,0x4
    80002e2a:	6c250513          	addi	a0,a0,1730 # 800074e8 <etext+0x4e8>
    80002e2e:	967fd0ef          	jal	80000794 <panic>

0000000080002e32 <bpin>:

void
bpin(struct buf *b) {
    80002e32:	1101                	addi	sp,sp,-32
    80002e34:	ec06                	sd	ra,24(sp)
    80002e36:	e822                	sd	s0,16(sp)
    80002e38:	e426                	sd	s1,8(sp)
    80002e3a:	1000                	addi	s0,sp,32
    80002e3c:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002e3e:	0001b517          	auipc	a0,0x1b
    80002e42:	30250513          	addi	a0,a0,770 # 8001e140 <bcache>
    80002e46:	daffd0ef          	jal	80000bf4 <acquire>
  b->refcnt++;
    80002e4a:	40bc                	lw	a5,64(s1)
    80002e4c:	2785                	addiw	a5,a5,1
    80002e4e:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002e50:	0001b517          	auipc	a0,0x1b
    80002e54:	2f050513          	addi	a0,a0,752 # 8001e140 <bcache>
    80002e58:	e35fd0ef          	jal	80000c8c <release>
}
    80002e5c:	60e2                	ld	ra,24(sp)
    80002e5e:	6442                	ld	s0,16(sp)
    80002e60:	64a2                	ld	s1,8(sp)
    80002e62:	6105                	addi	sp,sp,32
    80002e64:	8082                	ret

0000000080002e66 <bunpin>:

void
bunpin(struct buf *b) {
    80002e66:	1101                	addi	sp,sp,-32
    80002e68:	ec06                	sd	ra,24(sp)
    80002e6a:	e822                	sd	s0,16(sp)
    80002e6c:	e426                	sd	s1,8(sp)
    80002e6e:	1000                	addi	s0,sp,32
    80002e70:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002e72:	0001b517          	auipc	a0,0x1b
    80002e76:	2ce50513          	addi	a0,a0,718 # 8001e140 <bcache>
    80002e7a:	d7bfd0ef          	jal	80000bf4 <acquire>
  b->refcnt--;
    80002e7e:	40bc                	lw	a5,64(s1)
    80002e80:	37fd                	addiw	a5,a5,-1
    80002e82:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002e84:	0001b517          	auipc	a0,0x1b
    80002e88:	2bc50513          	addi	a0,a0,700 # 8001e140 <bcache>
    80002e8c:	e01fd0ef          	jal	80000c8c <release>
}
    80002e90:	60e2                	ld	ra,24(sp)
    80002e92:	6442                	ld	s0,16(sp)
    80002e94:	64a2                	ld	s1,8(sp)
    80002e96:	6105                	addi	sp,sp,32
    80002e98:	8082                	ret

0000000080002e9a <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80002e9a:	1101                	addi	sp,sp,-32
    80002e9c:	ec06                	sd	ra,24(sp)
    80002e9e:	e822                	sd	s0,16(sp)
    80002ea0:	e426                	sd	s1,8(sp)
    80002ea2:	e04a                	sd	s2,0(sp)
    80002ea4:	1000                	addi	s0,sp,32
    80002ea6:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80002ea8:	00d5d59b          	srliw	a1,a1,0xd
    80002eac:	00024797          	auipc	a5,0x24
    80002eb0:	9707a783          	lw	a5,-1680(a5) # 8002681c <sb+0x1c>
    80002eb4:	9dbd                	addw	a1,a1,a5
    80002eb6:	dedff0ef          	jal	80002ca2 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80002eba:	0074f713          	andi	a4,s1,7
    80002ebe:	4785                	li	a5,1
    80002ec0:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80002ec4:	14ce                	slli	s1,s1,0x33
    80002ec6:	90d9                	srli	s1,s1,0x36
    80002ec8:	00950733          	add	a4,a0,s1
    80002ecc:	05874703          	lbu	a4,88(a4)
    80002ed0:	00e7f6b3          	and	a3,a5,a4
    80002ed4:	c29d                	beqz	a3,80002efa <bfree+0x60>
    80002ed6:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80002ed8:	94aa                	add	s1,s1,a0
    80002eda:	fff7c793          	not	a5,a5
    80002ede:	8f7d                	and	a4,a4,a5
    80002ee0:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80002ee4:	711000ef          	jal	80003df4 <log_write>
  brelse(bp);
    80002ee8:	854a                	mv	a0,s2
    80002eea:	ec1ff0ef          	jal	80002daa <brelse>
}
    80002eee:	60e2                	ld	ra,24(sp)
    80002ef0:	6442                	ld	s0,16(sp)
    80002ef2:	64a2                	ld	s1,8(sp)
    80002ef4:	6902                	ld	s2,0(sp)
    80002ef6:	6105                	addi	sp,sp,32
    80002ef8:	8082                	ret
    panic("freeing free block");
    80002efa:	00004517          	auipc	a0,0x4
    80002efe:	5f650513          	addi	a0,a0,1526 # 800074f0 <etext+0x4f0>
    80002f02:	893fd0ef          	jal	80000794 <panic>

0000000080002f06 <balloc>:
{
    80002f06:	711d                	addi	sp,sp,-96
    80002f08:	ec86                	sd	ra,88(sp)
    80002f0a:	e8a2                	sd	s0,80(sp)
    80002f0c:	e4a6                	sd	s1,72(sp)
    80002f0e:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80002f10:	00024797          	auipc	a5,0x24
    80002f14:	8f47a783          	lw	a5,-1804(a5) # 80026804 <sb+0x4>
    80002f18:	0e078f63          	beqz	a5,80003016 <balloc+0x110>
    80002f1c:	e0ca                	sd	s2,64(sp)
    80002f1e:	fc4e                	sd	s3,56(sp)
    80002f20:	f852                	sd	s4,48(sp)
    80002f22:	f456                	sd	s5,40(sp)
    80002f24:	f05a                	sd	s6,32(sp)
    80002f26:	ec5e                	sd	s7,24(sp)
    80002f28:	e862                	sd	s8,16(sp)
    80002f2a:	e466                	sd	s9,8(sp)
    80002f2c:	8baa                	mv	s7,a0
    80002f2e:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80002f30:	00024b17          	auipc	s6,0x24
    80002f34:	8d0b0b13          	addi	s6,s6,-1840 # 80026800 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002f38:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80002f3a:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002f3c:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80002f3e:	6c89                	lui	s9,0x2
    80002f40:	a0b5                	j	80002fac <balloc+0xa6>
        bp->data[bi/8] |= m;  // Mark block in use.
    80002f42:	97ca                	add	a5,a5,s2
    80002f44:	8e55                	or	a2,a2,a3
    80002f46:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80002f4a:	854a                	mv	a0,s2
    80002f4c:	6a9000ef          	jal	80003df4 <log_write>
        brelse(bp);
    80002f50:	854a                	mv	a0,s2
    80002f52:	e59ff0ef          	jal	80002daa <brelse>
  bp = bread(dev, bno);
    80002f56:	85a6                	mv	a1,s1
    80002f58:	855e                	mv	a0,s7
    80002f5a:	d49ff0ef          	jal	80002ca2 <bread>
    80002f5e:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80002f60:	40000613          	li	a2,1024
    80002f64:	4581                	li	a1,0
    80002f66:	05850513          	addi	a0,a0,88
    80002f6a:	d5ffd0ef          	jal	80000cc8 <memset>
  log_write(bp);
    80002f6e:	854a                	mv	a0,s2
    80002f70:	685000ef          	jal	80003df4 <log_write>
  brelse(bp);
    80002f74:	854a                	mv	a0,s2
    80002f76:	e35ff0ef          	jal	80002daa <brelse>
}
    80002f7a:	6906                	ld	s2,64(sp)
    80002f7c:	79e2                	ld	s3,56(sp)
    80002f7e:	7a42                	ld	s4,48(sp)
    80002f80:	7aa2                	ld	s5,40(sp)
    80002f82:	7b02                	ld	s6,32(sp)
    80002f84:	6be2                	ld	s7,24(sp)
    80002f86:	6c42                	ld	s8,16(sp)
    80002f88:	6ca2                	ld	s9,8(sp)
}
    80002f8a:	8526                	mv	a0,s1
    80002f8c:	60e6                	ld	ra,88(sp)
    80002f8e:	6446                	ld	s0,80(sp)
    80002f90:	64a6                	ld	s1,72(sp)
    80002f92:	6125                	addi	sp,sp,96
    80002f94:	8082                	ret
    brelse(bp);
    80002f96:	854a                	mv	a0,s2
    80002f98:	e13ff0ef          	jal	80002daa <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80002f9c:	015c87bb          	addw	a5,s9,s5
    80002fa0:	00078a9b          	sext.w	s5,a5
    80002fa4:	004b2703          	lw	a4,4(s6)
    80002fa8:	04eaff63          	bgeu	s5,a4,80003006 <balloc+0x100>
    bp = bread(dev, BBLOCK(b, sb));
    80002fac:	41fad79b          	sraiw	a5,s5,0x1f
    80002fb0:	0137d79b          	srliw	a5,a5,0x13
    80002fb4:	015787bb          	addw	a5,a5,s5
    80002fb8:	40d7d79b          	sraiw	a5,a5,0xd
    80002fbc:	01cb2583          	lw	a1,28(s6)
    80002fc0:	9dbd                	addw	a1,a1,a5
    80002fc2:	855e                	mv	a0,s7
    80002fc4:	cdfff0ef          	jal	80002ca2 <bread>
    80002fc8:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002fca:	004b2503          	lw	a0,4(s6)
    80002fce:	000a849b          	sext.w	s1,s5
    80002fd2:	8762                	mv	a4,s8
    80002fd4:	fca4f1e3          	bgeu	s1,a0,80002f96 <balloc+0x90>
      m = 1 << (bi % 8);
    80002fd8:	00777693          	andi	a3,a4,7
    80002fdc:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80002fe0:	41f7579b          	sraiw	a5,a4,0x1f
    80002fe4:	01d7d79b          	srliw	a5,a5,0x1d
    80002fe8:	9fb9                	addw	a5,a5,a4
    80002fea:	4037d79b          	sraiw	a5,a5,0x3
    80002fee:	00f90633          	add	a2,s2,a5
    80002ff2:	05864603          	lbu	a2,88(a2)
    80002ff6:	00c6f5b3          	and	a1,a3,a2
    80002ffa:	d5a1                	beqz	a1,80002f42 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002ffc:	2705                	addiw	a4,a4,1
    80002ffe:	2485                	addiw	s1,s1,1
    80003000:	fd471ae3          	bne	a4,s4,80002fd4 <balloc+0xce>
    80003004:	bf49                	j	80002f96 <balloc+0x90>
    80003006:	6906                	ld	s2,64(sp)
    80003008:	79e2                	ld	s3,56(sp)
    8000300a:	7a42                	ld	s4,48(sp)
    8000300c:	7aa2                	ld	s5,40(sp)
    8000300e:	7b02                	ld	s6,32(sp)
    80003010:	6be2                	ld	s7,24(sp)
    80003012:	6c42                	ld	s8,16(sp)
    80003014:	6ca2                	ld	s9,8(sp)
  printf("balloc: out of blocks\n");
    80003016:	00004517          	auipc	a0,0x4
    8000301a:	4f250513          	addi	a0,a0,1266 # 80007508 <etext+0x508>
    8000301e:	ca4fd0ef          	jal	800004c2 <printf>
  return 0;
    80003022:	4481                	li	s1,0
    80003024:	b79d                	j	80002f8a <balloc+0x84>

0000000080003026 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003026:	7179                	addi	sp,sp,-48
    80003028:	f406                	sd	ra,40(sp)
    8000302a:	f022                	sd	s0,32(sp)
    8000302c:	ec26                	sd	s1,24(sp)
    8000302e:	e84a                	sd	s2,16(sp)
    80003030:	e44e                	sd	s3,8(sp)
    80003032:	1800                	addi	s0,sp,48
    80003034:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003036:	47ad                	li	a5,11
    80003038:	02b7e663          	bltu	a5,a1,80003064 <bmap+0x3e>
    if((addr = ip->addrs[bn]) == 0){
    8000303c:	02059793          	slli	a5,a1,0x20
    80003040:	01e7d593          	srli	a1,a5,0x1e
    80003044:	00b504b3          	add	s1,a0,a1
    80003048:	0504a903          	lw	s2,80(s1)
    8000304c:	06091a63          	bnez	s2,800030c0 <bmap+0x9a>
      addr = balloc(ip->dev);
    80003050:	4108                	lw	a0,0(a0)
    80003052:	eb5ff0ef          	jal	80002f06 <balloc>
    80003056:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    8000305a:	06090363          	beqz	s2,800030c0 <bmap+0x9a>
        return 0;
      ip->addrs[bn] = addr;
    8000305e:	0524a823          	sw	s2,80(s1)
    80003062:	a8b9                	j	800030c0 <bmap+0x9a>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003064:	ff45849b          	addiw	s1,a1,-12
    80003068:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    8000306c:	0ff00793          	li	a5,255
    80003070:	06e7ee63          	bltu	a5,a4,800030ec <bmap+0xc6>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003074:	08052903          	lw	s2,128(a0)
    80003078:	00091d63          	bnez	s2,80003092 <bmap+0x6c>
      addr = balloc(ip->dev);
    8000307c:	4108                	lw	a0,0(a0)
    8000307e:	e89ff0ef          	jal	80002f06 <balloc>
    80003082:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003086:	02090d63          	beqz	s2,800030c0 <bmap+0x9a>
    8000308a:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    8000308c:	0929a023          	sw	s2,128(s3)
    80003090:	a011                	j	80003094 <bmap+0x6e>
    80003092:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    80003094:	85ca                	mv	a1,s2
    80003096:	0009a503          	lw	a0,0(s3)
    8000309a:	c09ff0ef          	jal	80002ca2 <bread>
    8000309e:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800030a0:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800030a4:	02049713          	slli	a4,s1,0x20
    800030a8:	01e75593          	srli	a1,a4,0x1e
    800030ac:	00b784b3          	add	s1,a5,a1
    800030b0:	0004a903          	lw	s2,0(s1)
    800030b4:	00090e63          	beqz	s2,800030d0 <bmap+0xaa>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    800030b8:	8552                	mv	a0,s4
    800030ba:	cf1ff0ef          	jal	80002daa <brelse>
    return addr;
    800030be:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    800030c0:	854a                	mv	a0,s2
    800030c2:	70a2                	ld	ra,40(sp)
    800030c4:	7402                	ld	s0,32(sp)
    800030c6:	64e2                	ld	s1,24(sp)
    800030c8:	6942                	ld	s2,16(sp)
    800030ca:	69a2                	ld	s3,8(sp)
    800030cc:	6145                	addi	sp,sp,48
    800030ce:	8082                	ret
      addr = balloc(ip->dev);
    800030d0:	0009a503          	lw	a0,0(s3)
    800030d4:	e33ff0ef          	jal	80002f06 <balloc>
    800030d8:	0005091b          	sext.w	s2,a0
      if(addr){
    800030dc:	fc090ee3          	beqz	s2,800030b8 <bmap+0x92>
        a[bn] = addr;
    800030e0:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    800030e4:	8552                	mv	a0,s4
    800030e6:	50f000ef          	jal	80003df4 <log_write>
    800030ea:	b7f9                	j	800030b8 <bmap+0x92>
    800030ec:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    800030ee:	00004517          	auipc	a0,0x4
    800030f2:	43250513          	addi	a0,a0,1074 # 80007520 <etext+0x520>
    800030f6:	e9efd0ef          	jal	80000794 <panic>

00000000800030fa <iget>:
{
    800030fa:	7179                	addi	sp,sp,-48
    800030fc:	f406                	sd	ra,40(sp)
    800030fe:	f022                	sd	s0,32(sp)
    80003100:	ec26                	sd	s1,24(sp)
    80003102:	e84a                	sd	s2,16(sp)
    80003104:	e44e                	sd	s3,8(sp)
    80003106:	e052                	sd	s4,0(sp)
    80003108:	1800                	addi	s0,sp,48
    8000310a:	89aa                	mv	s3,a0
    8000310c:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    8000310e:	00023517          	auipc	a0,0x23
    80003112:	71250513          	addi	a0,a0,1810 # 80026820 <itable>
    80003116:	adffd0ef          	jal	80000bf4 <acquire>
  empty = 0;
    8000311a:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000311c:	00023497          	auipc	s1,0x23
    80003120:	71c48493          	addi	s1,s1,1820 # 80026838 <itable+0x18>
    80003124:	00025697          	auipc	a3,0x25
    80003128:	1a468693          	addi	a3,a3,420 # 800282c8 <log>
    8000312c:	a039                	j	8000313a <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000312e:	02090963          	beqz	s2,80003160 <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003132:	08848493          	addi	s1,s1,136
    80003136:	02d48863          	beq	s1,a3,80003166 <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    8000313a:	449c                	lw	a5,8(s1)
    8000313c:	fef059e3          	blez	a5,8000312e <iget+0x34>
    80003140:	4098                	lw	a4,0(s1)
    80003142:	ff3716e3          	bne	a4,s3,8000312e <iget+0x34>
    80003146:	40d8                	lw	a4,4(s1)
    80003148:	ff4713e3          	bne	a4,s4,8000312e <iget+0x34>
      ip->ref++;
    8000314c:	2785                	addiw	a5,a5,1
    8000314e:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003150:	00023517          	auipc	a0,0x23
    80003154:	6d050513          	addi	a0,a0,1744 # 80026820 <itable>
    80003158:	b35fd0ef          	jal	80000c8c <release>
      return ip;
    8000315c:	8926                	mv	s2,s1
    8000315e:	a02d                	j	80003188 <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003160:	fbe9                	bnez	a5,80003132 <iget+0x38>
      empty = ip;
    80003162:	8926                	mv	s2,s1
    80003164:	b7f9                	j	80003132 <iget+0x38>
  if(empty == 0)
    80003166:	02090a63          	beqz	s2,8000319a <iget+0xa0>
  ip->dev = dev;
    8000316a:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    8000316e:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003172:	4785                	li	a5,1
    80003174:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003178:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    8000317c:	00023517          	auipc	a0,0x23
    80003180:	6a450513          	addi	a0,a0,1700 # 80026820 <itable>
    80003184:	b09fd0ef          	jal	80000c8c <release>
}
    80003188:	854a                	mv	a0,s2
    8000318a:	70a2                	ld	ra,40(sp)
    8000318c:	7402                	ld	s0,32(sp)
    8000318e:	64e2                	ld	s1,24(sp)
    80003190:	6942                	ld	s2,16(sp)
    80003192:	69a2                	ld	s3,8(sp)
    80003194:	6a02                	ld	s4,0(sp)
    80003196:	6145                	addi	sp,sp,48
    80003198:	8082                	ret
    panic("iget: no inodes");
    8000319a:	00004517          	auipc	a0,0x4
    8000319e:	39e50513          	addi	a0,a0,926 # 80007538 <etext+0x538>
    800031a2:	df2fd0ef          	jal	80000794 <panic>

00000000800031a6 <fsinit>:
fsinit(int dev) {
    800031a6:	7179                	addi	sp,sp,-48
    800031a8:	f406                	sd	ra,40(sp)
    800031aa:	f022                	sd	s0,32(sp)
    800031ac:	ec26                	sd	s1,24(sp)
    800031ae:	e84a                	sd	s2,16(sp)
    800031b0:	e44e                	sd	s3,8(sp)
    800031b2:	1800                	addi	s0,sp,48
    800031b4:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800031b6:	4585                	li	a1,1
    800031b8:	aebff0ef          	jal	80002ca2 <bread>
    800031bc:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800031be:	00023997          	auipc	s3,0x23
    800031c2:	64298993          	addi	s3,s3,1602 # 80026800 <sb>
    800031c6:	02000613          	li	a2,32
    800031ca:	05850593          	addi	a1,a0,88
    800031ce:	854e                	mv	a0,s3
    800031d0:	b55fd0ef          	jal	80000d24 <memmove>
  brelse(bp);
    800031d4:	8526                	mv	a0,s1
    800031d6:	bd5ff0ef          	jal	80002daa <brelse>
  if(sb.magic != FSMAGIC)
    800031da:	0009a703          	lw	a4,0(s3)
    800031de:	102037b7          	lui	a5,0x10203
    800031e2:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800031e6:	02f71063          	bne	a4,a5,80003206 <fsinit+0x60>
  initlog(dev, &sb);
    800031ea:	00023597          	auipc	a1,0x23
    800031ee:	61658593          	addi	a1,a1,1558 # 80026800 <sb>
    800031f2:	854a                	mv	a0,s2
    800031f4:	1f9000ef          	jal	80003bec <initlog>
}
    800031f8:	70a2                	ld	ra,40(sp)
    800031fa:	7402                	ld	s0,32(sp)
    800031fc:	64e2                	ld	s1,24(sp)
    800031fe:	6942                	ld	s2,16(sp)
    80003200:	69a2                	ld	s3,8(sp)
    80003202:	6145                	addi	sp,sp,48
    80003204:	8082                	ret
    panic("invalid file system");
    80003206:	00004517          	auipc	a0,0x4
    8000320a:	34250513          	addi	a0,a0,834 # 80007548 <etext+0x548>
    8000320e:	d86fd0ef          	jal	80000794 <panic>

0000000080003212 <iinit>:
{
    80003212:	7179                	addi	sp,sp,-48
    80003214:	f406                	sd	ra,40(sp)
    80003216:	f022                	sd	s0,32(sp)
    80003218:	ec26                	sd	s1,24(sp)
    8000321a:	e84a                	sd	s2,16(sp)
    8000321c:	e44e                	sd	s3,8(sp)
    8000321e:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003220:	00004597          	auipc	a1,0x4
    80003224:	34058593          	addi	a1,a1,832 # 80007560 <etext+0x560>
    80003228:	00023517          	auipc	a0,0x23
    8000322c:	5f850513          	addi	a0,a0,1528 # 80026820 <itable>
    80003230:	945fd0ef          	jal	80000b74 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003234:	00023497          	auipc	s1,0x23
    80003238:	61448493          	addi	s1,s1,1556 # 80026848 <itable+0x28>
    8000323c:	00025997          	auipc	s3,0x25
    80003240:	09c98993          	addi	s3,s3,156 # 800282d8 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003244:	00004917          	auipc	s2,0x4
    80003248:	32490913          	addi	s2,s2,804 # 80007568 <etext+0x568>
    8000324c:	85ca                	mv	a1,s2
    8000324e:	8526                	mv	a0,s1
    80003250:	475000ef          	jal	80003ec4 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003254:	08848493          	addi	s1,s1,136
    80003258:	ff349ae3          	bne	s1,s3,8000324c <iinit+0x3a>
}
    8000325c:	70a2                	ld	ra,40(sp)
    8000325e:	7402                	ld	s0,32(sp)
    80003260:	64e2                	ld	s1,24(sp)
    80003262:	6942                	ld	s2,16(sp)
    80003264:	69a2                	ld	s3,8(sp)
    80003266:	6145                	addi	sp,sp,48
    80003268:	8082                	ret

000000008000326a <ialloc>:
{
    8000326a:	7139                	addi	sp,sp,-64
    8000326c:	fc06                	sd	ra,56(sp)
    8000326e:	f822                	sd	s0,48(sp)
    80003270:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    80003272:	00023717          	auipc	a4,0x23
    80003276:	59a72703          	lw	a4,1434(a4) # 8002680c <sb+0xc>
    8000327a:	4785                	li	a5,1
    8000327c:	06e7f063          	bgeu	a5,a4,800032dc <ialloc+0x72>
    80003280:	f426                	sd	s1,40(sp)
    80003282:	f04a                	sd	s2,32(sp)
    80003284:	ec4e                	sd	s3,24(sp)
    80003286:	e852                	sd	s4,16(sp)
    80003288:	e456                	sd	s5,8(sp)
    8000328a:	e05a                	sd	s6,0(sp)
    8000328c:	8aaa                	mv	s5,a0
    8000328e:	8b2e                	mv	s6,a1
    80003290:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003292:	00023a17          	auipc	s4,0x23
    80003296:	56ea0a13          	addi	s4,s4,1390 # 80026800 <sb>
    8000329a:	00495593          	srli	a1,s2,0x4
    8000329e:	018a2783          	lw	a5,24(s4)
    800032a2:	9dbd                	addw	a1,a1,a5
    800032a4:	8556                	mv	a0,s5
    800032a6:	9fdff0ef          	jal	80002ca2 <bread>
    800032aa:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800032ac:	05850993          	addi	s3,a0,88
    800032b0:	00f97793          	andi	a5,s2,15
    800032b4:	079a                	slli	a5,a5,0x6
    800032b6:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800032b8:	00099783          	lh	a5,0(s3)
    800032bc:	cb9d                	beqz	a5,800032f2 <ialloc+0x88>
    brelse(bp);
    800032be:	aedff0ef          	jal	80002daa <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800032c2:	0905                	addi	s2,s2,1
    800032c4:	00ca2703          	lw	a4,12(s4)
    800032c8:	0009079b          	sext.w	a5,s2
    800032cc:	fce7e7e3          	bltu	a5,a4,8000329a <ialloc+0x30>
    800032d0:	74a2                	ld	s1,40(sp)
    800032d2:	7902                	ld	s2,32(sp)
    800032d4:	69e2                	ld	s3,24(sp)
    800032d6:	6a42                	ld	s4,16(sp)
    800032d8:	6aa2                	ld	s5,8(sp)
    800032da:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    800032dc:	00004517          	auipc	a0,0x4
    800032e0:	29450513          	addi	a0,a0,660 # 80007570 <etext+0x570>
    800032e4:	9defd0ef          	jal	800004c2 <printf>
  return 0;
    800032e8:	4501                	li	a0,0
}
    800032ea:	70e2                	ld	ra,56(sp)
    800032ec:	7442                	ld	s0,48(sp)
    800032ee:	6121                	addi	sp,sp,64
    800032f0:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    800032f2:	04000613          	li	a2,64
    800032f6:	4581                	li	a1,0
    800032f8:	854e                	mv	a0,s3
    800032fa:	9cffd0ef          	jal	80000cc8 <memset>
      dip->type = type;
    800032fe:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003302:	8526                	mv	a0,s1
    80003304:	2f1000ef          	jal	80003df4 <log_write>
      brelse(bp);
    80003308:	8526                	mv	a0,s1
    8000330a:	aa1ff0ef          	jal	80002daa <brelse>
      return iget(dev, inum);
    8000330e:	0009059b          	sext.w	a1,s2
    80003312:	8556                	mv	a0,s5
    80003314:	de7ff0ef          	jal	800030fa <iget>
    80003318:	74a2                	ld	s1,40(sp)
    8000331a:	7902                	ld	s2,32(sp)
    8000331c:	69e2                	ld	s3,24(sp)
    8000331e:	6a42                	ld	s4,16(sp)
    80003320:	6aa2                	ld	s5,8(sp)
    80003322:	6b02                	ld	s6,0(sp)
    80003324:	b7d9                	j	800032ea <ialloc+0x80>

0000000080003326 <iupdate>:
{
    80003326:	1101                	addi	sp,sp,-32
    80003328:	ec06                	sd	ra,24(sp)
    8000332a:	e822                	sd	s0,16(sp)
    8000332c:	e426                	sd	s1,8(sp)
    8000332e:	e04a                	sd	s2,0(sp)
    80003330:	1000                	addi	s0,sp,32
    80003332:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003334:	415c                	lw	a5,4(a0)
    80003336:	0047d79b          	srliw	a5,a5,0x4
    8000333a:	00023597          	auipc	a1,0x23
    8000333e:	4de5a583          	lw	a1,1246(a1) # 80026818 <sb+0x18>
    80003342:	9dbd                	addw	a1,a1,a5
    80003344:	4108                	lw	a0,0(a0)
    80003346:	95dff0ef          	jal	80002ca2 <bread>
    8000334a:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000334c:	05850793          	addi	a5,a0,88
    80003350:	40d8                	lw	a4,4(s1)
    80003352:	8b3d                	andi	a4,a4,15
    80003354:	071a                	slli	a4,a4,0x6
    80003356:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003358:	04449703          	lh	a4,68(s1)
    8000335c:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003360:	04649703          	lh	a4,70(s1)
    80003364:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003368:	04849703          	lh	a4,72(s1)
    8000336c:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003370:	04a49703          	lh	a4,74(s1)
    80003374:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003378:	44f8                	lw	a4,76(s1)
    8000337a:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    8000337c:	03400613          	li	a2,52
    80003380:	05048593          	addi	a1,s1,80
    80003384:	00c78513          	addi	a0,a5,12
    80003388:	99dfd0ef          	jal	80000d24 <memmove>
  log_write(bp);
    8000338c:	854a                	mv	a0,s2
    8000338e:	267000ef          	jal	80003df4 <log_write>
  brelse(bp);
    80003392:	854a                	mv	a0,s2
    80003394:	a17ff0ef          	jal	80002daa <brelse>
}
    80003398:	60e2                	ld	ra,24(sp)
    8000339a:	6442                	ld	s0,16(sp)
    8000339c:	64a2                	ld	s1,8(sp)
    8000339e:	6902                	ld	s2,0(sp)
    800033a0:	6105                	addi	sp,sp,32
    800033a2:	8082                	ret

00000000800033a4 <idup>:
{
    800033a4:	1101                	addi	sp,sp,-32
    800033a6:	ec06                	sd	ra,24(sp)
    800033a8:	e822                	sd	s0,16(sp)
    800033aa:	e426                	sd	s1,8(sp)
    800033ac:	1000                	addi	s0,sp,32
    800033ae:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800033b0:	00023517          	auipc	a0,0x23
    800033b4:	47050513          	addi	a0,a0,1136 # 80026820 <itable>
    800033b8:	83dfd0ef          	jal	80000bf4 <acquire>
  ip->ref++;
    800033bc:	449c                	lw	a5,8(s1)
    800033be:	2785                	addiw	a5,a5,1
    800033c0:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800033c2:	00023517          	auipc	a0,0x23
    800033c6:	45e50513          	addi	a0,a0,1118 # 80026820 <itable>
    800033ca:	8c3fd0ef          	jal	80000c8c <release>
}
    800033ce:	8526                	mv	a0,s1
    800033d0:	60e2                	ld	ra,24(sp)
    800033d2:	6442                	ld	s0,16(sp)
    800033d4:	64a2                	ld	s1,8(sp)
    800033d6:	6105                	addi	sp,sp,32
    800033d8:	8082                	ret

00000000800033da <ilock>:
{
    800033da:	1101                	addi	sp,sp,-32
    800033dc:	ec06                	sd	ra,24(sp)
    800033de:	e822                	sd	s0,16(sp)
    800033e0:	e426                	sd	s1,8(sp)
    800033e2:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800033e4:	cd19                	beqz	a0,80003402 <ilock+0x28>
    800033e6:	84aa                	mv	s1,a0
    800033e8:	451c                	lw	a5,8(a0)
    800033ea:	00f05c63          	blez	a5,80003402 <ilock+0x28>
  acquiresleep(&ip->lock);
    800033ee:	0541                	addi	a0,a0,16
    800033f0:	30b000ef          	jal	80003efa <acquiresleep>
  if(ip->valid == 0){
    800033f4:	40bc                	lw	a5,64(s1)
    800033f6:	cf89                	beqz	a5,80003410 <ilock+0x36>
}
    800033f8:	60e2                	ld	ra,24(sp)
    800033fa:	6442                	ld	s0,16(sp)
    800033fc:	64a2                	ld	s1,8(sp)
    800033fe:	6105                	addi	sp,sp,32
    80003400:	8082                	ret
    80003402:	e04a                	sd	s2,0(sp)
    panic("ilock");
    80003404:	00004517          	auipc	a0,0x4
    80003408:	18450513          	addi	a0,a0,388 # 80007588 <etext+0x588>
    8000340c:	b88fd0ef          	jal	80000794 <panic>
    80003410:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003412:	40dc                	lw	a5,4(s1)
    80003414:	0047d79b          	srliw	a5,a5,0x4
    80003418:	00023597          	auipc	a1,0x23
    8000341c:	4005a583          	lw	a1,1024(a1) # 80026818 <sb+0x18>
    80003420:	9dbd                	addw	a1,a1,a5
    80003422:	4088                	lw	a0,0(s1)
    80003424:	87fff0ef          	jal	80002ca2 <bread>
    80003428:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000342a:	05850593          	addi	a1,a0,88
    8000342e:	40dc                	lw	a5,4(s1)
    80003430:	8bbd                	andi	a5,a5,15
    80003432:	079a                	slli	a5,a5,0x6
    80003434:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003436:	00059783          	lh	a5,0(a1)
    8000343a:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    8000343e:	00259783          	lh	a5,2(a1)
    80003442:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003446:	00459783          	lh	a5,4(a1)
    8000344a:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    8000344e:	00659783          	lh	a5,6(a1)
    80003452:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003456:	459c                	lw	a5,8(a1)
    80003458:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    8000345a:	03400613          	li	a2,52
    8000345e:	05b1                	addi	a1,a1,12
    80003460:	05048513          	addi	a0,s1,80
    80003464:	8c1fd0ef          	jal	80000d24 <memmove>
    brelse(bp);
    80003468:	854a                	mv	a0,s2
    8000346a:	941ff0ef          	jal	80002daa <brelse>
    ip->valid = 1;
    8000346e:	4785                	li	a5,1
    80003470:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003472:	04449783          	lh	a5,68(s1)
    80003476:	c399                	beqz	a5,8000347c <ilock+0xa2>
    80003478:	6902                	ld	s2,0(sp)
    8000347a:	bfbd                	j	800033f8 <ilock+0x1e>
      panic("ilock: no type");
    8000347c:	00004517          	auipc	a0,0x4
    80003480:	11450513          	addi	a0,a0,276 # 80007590 <etext+0x590>
    80003484:	b10fd0ef          	jal	80000794 <panic>

0000000080003488 <iunlock>:
{
    80003488:	1101                	addi	sp,sp,-32
    8000348a:	ec06                	sd	ra,24(sp)
    8000348c:	e822                	sd	s0,16(sp)
    8000348e:	e426                	sd	s1,8(sp)
    80003490:	e04a                	sd	s2,0(sp)
    80003492:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003494:	c505                	beqz	a0,800034bc <iunlock+0x34>
    80003496:	84aa                	mv	s1,a0
    80003498:	01050913          	addi	s2,a0,16
    8000349c:	854a                	mv	a0,s2
    8000349e:	2db000ef          	jal	80003f78 <holdingsleep>
    800034a2:	cd09                	beqz	a0,800034bc <iunlock+0x34>
    800034a4:	449c                	lw	a5,8(s1)
    800034a6:	00f05b63          	blez	a5,800034bc <iunlock+0x34>
  releasesleep(&ip->lock);
    800034aa:	854a                	mv	a0,s2
    800034ac:	295000ef          	jal	80003f40 <releasesleep>
}
    800034b0:	60e2                	ld	ra,24(sp)
    800034b2:	6442                	ld	s0,16(sp)
    800034b4:	64a2                	ld	s1,8(sp)
    800034b6:	6902                	ld	s2,0(sp)
    800034b8:	6105                	addi	sp,sp,32
    800034ba:	8082                	ret
    panic("iunlock");
    800034bc:	00004517          	auipc	a0,0x4
    800034c0:	0e450513          	addi	a0,a0,228 # 800075a0 <etext+0x5a0>
    800034c4:	ad0fd0ef          	jal	80000794 <panic>

00000000800034c8 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800034c8:	7179                	addi	sp,sp,-48
    800034ca:	f406                	sd	ra,40(sp)
    800034cc:	f022                	sd	s0,32(sp)
    800034ce:	ec26                	sd	s1,24(sp)
    800034d0:	e84a                	sd	s2,16(sp)
    800034d2:	e44e                	sd	s3,8(sp)
    800034d4:	1800                	addi	s0,sp,48
    800034d6:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800034d8:	05050493          	addi	s1,a0,80
    800034dc:	08050913          	addi	s2,a0,128
    800034e0:	a021                	j	800034e8 <itrunc+0x20>
    800034e2:	0491                	addi	s1,s1,4
    800034e4:	01248b63          	beq	s1,s2,800034fa <itrunc+0x32>
    if(ip->addrs[i]){
    800034e8:	408c                	lw	a1,0(s1)
    800034ea:	dde5                	beqz	a1,800034e2 <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    800034ec:	0009a503          	lw	a0,0(s3)
    800034f0:	9abff0ef          	jal	80002e9a <bfree>
      ip->addrs[i] = 0;
    800034f4:	0004a023          	sw	zero,0(s1)
    800034f8:	b7ed                	j	800034e2 <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    800034fa:	0809a583          	lw	a1,128(s3)
    800034fe:	ed89                	bnez	a1,80003518 <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003500:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003504:	854e                	mv	a0,s3
    80003506:	e21ff0ef          	jal	80003326 <iupdate>
}
    8000350a:	70a2                	ld	ra,40(sp)
    8000350c:	7402                	ld	s0,32(sp)
    8000350e:	64e2                	ld	s1,24(sp)
    80003510:	6942                	ld	s2,16(sp)
    80003512:	69a2                	ld	s3,8(sp)
    80003514:	6145                	addi	sp,sp,48
    80003516:	8082                	ret
    80003518:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    8000351a:	0009a503          	lw	a0,0(s3)
    8000351e:	f84ff0ef          	jal	80002ca2 <bread>
    80003522:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003524:	05850493          	addi	s1,a0,88
    80003528:	45850913          	addi	s2,a0,1112
    8000352c:	a021                	j	80003534 <itrunc+0x6c>
    8000352e:	0491                	addi	s1,s1,4
    80003530:	01248963          	beq	s1,s2,80003542 <itrunc+0x7a>
      if(a[j])
    80003534:	408c                	lw	a1,0(s1)
    80003536:	dde5                	beqz	a1,8000352e <itrunc+0x66>
        bfree(ip->dev, a[j]);
    80003538:	0009a503          	lw	a0,0(s3)
    8000353c:	95fff0ef          	jal	80002e9a <bfree>
    80003540:	b7fd                	j	8000352e <itrunc+0x66>
    brelse(bp);
    80003542:	8552                	mv	a0,s4
    80003544:	867ff0ef          	jal	80002daa <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003548:	0809a583          	lw	a1,128(s3)
    8000354c:	0009a503          	lw	a0,0(s3)
    80003550:	94bff0ef          	jal	80002e9a <bfree>
    ip->addrs[NDIRECT] = 0;
    80003554:	0809a023          	sw	zero,128(s3)
    80003558:	6a02                	ld	s4,0(sp)
    8000355a:	b75d                	j	80003500 <itrunc+0x38>

000000008000355c <iput>:
{
    8000355c:	1101                	addi	sp,sp,-32
    8000355e:	ec06                	sd	ra,24(sp)
    80003560:	e822                	sd	s0,16(sp)
    80003562:	e426                	sd	s1,8(sp)
    80003564:	1000                	addi	s0,sp,32
    80003566:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003568:	00023517          	auipc	a0,0x23
    8000356c:	2b850513          	addi	a0,a0,696 # 80026820 <itable>
    80003570:	e84fd0ef          	jal	80000bf4 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003574:	4498                	lw	a4,8(s1)
    80003576:	4785                	li	a5,1
    80003578:	02f70063          	beq	a4,a5,80003598 <iput+0x3c>
  ip->ref--;
    8000357c:	449c                	lw	a5,8(s1)
    8000357e:	37fd                	addiw	a5,a5,-1
    80003580:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003582:	00023517          	auipc	a0,0x23
    80003586:	29e50513          	addi	a0,a0,670 # 80026820 <itable>
    8000358a:	f02fd0ef          	jal	80000c8c <release>
}
    8000358e:	60e2                	ld	ra,24(sp)
    80003590:	6442                	ld	s0,16(sp)
    80003592:	64a2                	ld	s1,8(sp)
    80003594:	6105                	addi	sp,sp,32
    80003596:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003598:	40bc                	lw	a5,64(s1)
    8000359a:	d3ed                	beqz	a5,8000357c <iput+0x20>
    8000359c:	04a49783          	lh	a5,74(s1)
    800035a0:	fff1                	bnez	a5,8000357c <iput+0x20>
    800035a2:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    800035a4:	01048913          	addi	s2,s1,16
    800035a8:	854a                	mv	a0,s2
    800035aa:	151000ef          	jal	80003efa <acquiresleep>
    release(&itable.lock);
    800035ae:	00023517          	auipc	a0,0x23
    800035b2:	27250513          	addi	a0,a0,626 # 80026820 <itable>
    800035b6:	ed6fd0ef          	jal	80000c8c <release>
    itrunc(ip);
    800035ba:	8526                	mv	a0,s1
    800035bc:	f0dff0ef          	jal	800034c8 <itrunc>
    ip->type = 0;
    800035c0:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    800035c4:	8526                	mv	a0,s1
    800035c6:	d61ff0ef          	jal	80003326 <iupdate>
    ip->valid = 0;
    800035ca:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800035ce:	854a                	mv	a0,s2
    800035d0:	171000ef          	jal	80003f40 <releasesleep>
    acquire(&itable.lock);
    800035d4:	00023517          	auipc	a0,0x23
    800035d8:	24c50513          	addi	a0,a0,588 # 80026820 <itable>
    800035dc:	e18fd0ef          	jal	80000bf4 <acquire>
    800035e0:	6902                	ld	s2,0(sp)
    800035e2:	bf69                	j	8000357c <iput+0x20>

00000000800035e4 <iunlockput>:
{
    800035e4:	1101                	addi	sp,sp,-32
    800035e6:	ec06                	sd	ra,24(sp)
    800035e8:	e822                	sd	s0,16(sp)
    800035ea:	e426                	sd	s1,8(sp)
    800035ec:	1000                	addi	s0,sp,32
    800035ee:	84aa                	mv	s1,a0
  iunlock(ip);
    800035f0:	e99ff0ef          	jal	80003488 <iunlock>
  iput(ip);
    800035f4:	8526                	mv	a0,s1
    800035f6:	f67ff0ef          	jal	8000355c <iput>
}
    800035fa:	60e2                	ld	ra,24(sp)
    800035fc:	6442                	ld	s0,16(sp)
    800035fe:	64a2                	ld	s1,8(sp)
    80003600:	6105                	addi	sp,sp,32
    80003602:	8082                	ret

0000000080003604 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003604:	1141                	addi	sp,sp,-16
    80003606:	e422                	sd	s0,8(sp)
    80003608:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    8000360a:	411c                	lw	a5,0(a0)
    8000360c:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    8000360e:	415c                	lw	a5,4(a0)
    80003610:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003612:	04451783          	lh	a5,68(a0)
    80003616:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    8000361a:	04a51783          	lh	a5,74(a0)
    8000361e:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003622:	04c56783          	lwu	a5,76(a0)
    80003626:	e99c                	sd	a5,16(a1)
}
    80003628:	6422                	ld	s0,8(sp)
    8000362a:	0141                	addi	sp,sp,16
    8000362c:	8082                	ret

000000008000362e <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    8000362e:	457c                	lw	a5,76(a0)
    80003630:	0ed7eb63          	bltu	a5,a3,80003726 <readi+0xf8>
{
    80003634:	7159                	addi	sp,sp,-112
    80003636:	f486                	sd	ra,104(sp)
    80003638:	f0a2                	sd	s0,96(sp)
    8000363a:	eca6                	sd	s1,88(sp)
    8000363c:	e0d2                	sd	s4,64(sp)
    8000363e:	fc56                	sd	s5,56(sp)
    80003640:	f85a                	sd	s6,48(sp)
    80003642:	f45e                	sd	s7,40(sp)
    80003644:	1880                	addi	s0,sp,112
    80003646:	8b2a                	mv	s6,a0
    80003648:	8bae                	mv	s7,a1
    8000364a:	8a32                	mv	s4,a2
    8000364c:	84b6                	mv	s1,a3
    8000364e:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003650:	9f35                	addw	a4,a4,a3
    return 0;
    80003652:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003654:	0cd76063          	bltu	a4,a3,80003714 <readi+0xe6>
    80003658:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    8000365a:	00e7f463          	bgeu	a5,a4,80003662 <readi+0x34>
    n = ip->size - off;
    8000365e:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003662:	080a8f63          	beqz	s5,80003700 <readi+0xd2>
    80003666:	e8ca                	sd	s2,80(sp)
    80003668:	f062                	sd	s8,32(sp)
    8000366a:	ec66                	sd	s9,24(sp)
    8000366c:	e86a                	sd	s10,16(sp)
    8000366e:	e46e                	sd	s11,8(sp)
    80003670:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003672:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003676:	5c7d                	li	s8,-1
    80003678:	a80d                	j	800036aa <readi+0x7c>
    8000367a:	020d1d93          	slli	s11,s10,0x20
    8000367e:	020ddd93          	srli	s11,s11,0x20
    80003682:	05890613          	addi	a2,s2,88
    80003686:	86ee                	mv	a3,s11
    80003688:	963a                	add	a2,a2,a4
    8000368a:	85d2                	mv	a1,s4
    8000368c:	855e                	mv	a0,s7
    8000368e:	b7dfe0ef          	jal	8000220a <either_copyout>
    80003692:	05850763          	beq	a0,s8,800036e0 <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003696:	854a                	mv	a0,s2
    80003698:	f12ff0ef          	jal	80002daa <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000369c:	013d09bb          	addw	s3,s10,s3
    800036a0:	009d04bb          	addw	s1,s10,s1
    800036a4:	9a6e                	add	s4,s4,s11
    800036a6:	0559f763          	bgeu	s3,s5,800036f4 <readi+0xc6>
    uint addr = bmap(ip, off/BSIZE);
    800036aa:	00a4d59b          	srliw	a1,s1,0xa
    800036ae:	855a                	mv	a0,s6
    800036b0:	977ff0ef          	jal	80003026 <bmap>
    800036b4:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    800036b8:	c5b1                	beqz	a1,80003704 <readi+0xd6>
    bp = bread(ip->dev, addr);
    800036ba:	000b2503          	lw	a0,0(s6)
    800036be:	de4ff0ef          	jal	80002ca2 <bread>
    800036c2:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800036c4:	3ff4f713          	andi	a4,s1,1023
    800036c8:	40ec87bb          	subw	a5,s9,a4
    800036cc:	413a86bb          	subw	a3,s5,s3
    800036d0:	8d3e                	mv	s10,a5
    800036d2:	2781                	sext.w	a5,a5
    800036d4:	0006861b          	sext.w	a2,a3
    800036d8:	faf671e3          	bgeu	a2,a5,8000367a <readi+0x4c>
    800036dc:	8d36                	mv	s10,a3
    800036de:	bf71                	j	8000367a <readi+0x4c>
      brelse(bp);
    800036e0:	854a                	mv	a0,s2
    800036e2:	ec8ff0ef          	jal	80002daa <brelse>
      tot = -1;
    800036e6:	59fd                	li	s3,-1
      break;
    800036e8:	6946                	ld	s2,80(sp)
    800036ea:	7c02                	ld	s8,32(sp)
    800036ec:	6ce2                	ld	s9,24(sp)
    800036ee:	6d42                	ld	s10,16(sp)
    800036f0:	6da2                	ld	s11,8(sp)
    800036f2:	a831                	j	8000370e <readi+0xe0>
    800036f4:	6946                	ld	s2,80(sp)
    800036f6:	7c02                	ld	s8,32(sp)
    800036f8:	6ce2                	ld	s9,24(sp)
    800036fa:	6d42                	ld	s10,16(sp)
    800036fc:	6da2                	ld	s11,8(sp)
    800036fe:	a801                	j	8000370e <readi+0xe0>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003700:	89d6                	mv	s3,s5
    80003702:	a031                	j	8000370e <readi+0xe0>
    80003704:	6946                	ld	s2,80(sp)
    80003706:	7c02                	ld	s8,32(sp)
    80003708:	6ce2                	ld	s9,24(sp)
    8000370a:	6d42                	ld	s10,16(sp)
    8000370c:	6da2                	ld	s11,8(sp)
  }
  return tot;
    8000370e:	0009851b          	sext.w	a0,s3
    80003712:	69a6                	ld	s3,72(sp)
}
    80003714:	70a6                	ld	ra,104(sp)
    80003716:	7406                	ld	s0,96(sp)
    80003718:	64e6                	ld	s1,88(sp)
    8000371a:	6a06                	ld	s4,64(sp)
    8000371c:	7ae2                	ld	s5,56(sp)
    8000371e:	7b42                	ld	s6,48(sp)
    80003720:	7ba2                	ld	s7,40(sp)
    80003722:	6165                	addi	sp,sp,112
    80003724:	8082                	ret
    return 0;
    80003726:	4501                	li	a0,0
}
    80003728:	8082                	ret

000000008000372a <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    8000372a:	457c                	lw	a5,76(a0)
    8000372c:	10d7e063          	bltu	a5,a3,8000382c <writei+0x102>
{
    80003730:	7159                	addi	sp,sp,-112
    80003732:	f486                	sd	ra,104(sp)
    80003734:	f0a2                	sd	s0,96(sp)
    80003736:	e8ca                	sd	s2,80(sp)
    80003738:	e0d2                	sd	s4,64(sp)
    8000373a:	fc56                	sd	s5,56(sp)
    8000373c:	f85a                	sd	s6,48(sp)
    8000373e:	f45e                	sd	s7,40(sp)
    80003740:	1880                	addi	s0,sp,112
    80003742:	8aaa                	mv	s5,a0
    80003744:	8bae                	mv	s7,a1
    80003746:	8a32                	mv	s4,a2
    80003748:	8936                	mv	s2,a3
    8000374a:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    8000374c:	00e687bb          	addw	a5,a3,a4
    80003750:	0ed7e063          	bltu	a5,a3,80003830 <writei+0x106>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003754:	00043737          	lui	a4,0x43
    80003758:	0cf76e63          	bltu	a4,a5,80003834 <writei+0x10a>
    8000375c:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000375e:	0a0b0f63          	beqz	s6,8000381c <writei+0xf2>
    80003762:	eca6                	sd	s1,88(sp)
    80003764:	f062                	sd	s8,32(sp)
    80003766:	ec66                	sd	s9,24(sp)
    80003768:	e86a                	sd	s10,16(sp)
    8000376a:	e46e                	sd	s11,8(sp)
    8000376c:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    8000376e:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003772:	5c7d                	li	s8,-1
    80003774:	a825                	j	800037ac <writei+0x82>
    80003776:	020d1d93          	slli	s11,s10,0x20
    8000377a:	020ddd93          	srli	s11,s11,0x20
    8000377e:	05848513          	addi	a0,s1,88
    80003782:	86ee                	mv	a3,s11
    80003784:	8652                	mv	a2,s4
    80003786:	85de                	mv	a1,s7
    80003788:	953a                	add	a0,a0,a4
    8000378a:	acbfe0ef          	jal	80002254 <either_copyin>
    8000378e:	05850a63          	beq	a0,s8,800037e2 <writei+0xb8>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003792:	8526                	mv	a0,s1
    80003794:	660000ef          	jal	80003df4 <log_write>
    brelse(bp);
    80003798:	8526                	mv	a0,s1
    8000379a:	e10ff0ef          	jal	80002daa <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000379e:	013d09bb          	addw	s3,s10,s3
    800037a2:	012d093b          	addw	s2,s10,s2
    800037a6:	9a6e                	add	s4,s4,s11
    800037a8:	0569f063          	bgeu	s3,s6,800037e8 <writei+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    800037ac:	00a9559b          	srliw	a1,s2,0xa
    800037b0:	8556                	mv	a0,s5
    800037b2:	875ff0ef          	jal	80003026 <bmap>
    800037b6:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    800037ba:	c59d                	beqz	a1,800037e8 <writei+0xbe>
    bp = bread(ip->dev, addr);
    800037bc:	000aa503          	lw	a0,0(s5)
    800037c0:	ce2ff0ef          	jal	80002ca2 <bread>
    800037c4:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800037c6:	3ff97713          	andi	a4,s2,1023
    800037ca:	40ec87bb          	subw	a5,s9,a4
    800037ce:	413b06bb          	subw	a3,s6,s3
    800037d2:	8d3e                	mv	s10,a5
    800037d4:	2781                	sext.w	a5,a5
    800037d6:	0006861b          	sext.w	a2,a3
    800037da:	f8f67ee3          	bgeu	a2,a5,80003776 <writei+0x4c>
    800037de:	8d36                	mv	s10,a3
    800037e0:	bf59                	j	80003776 <writei+0x4c>
      brelse(bp);
    800037e2:	8526                	mv	a0,s1
    800037e4:	dc6ff0ef          	jal	80002daa <brelse>
  }

  if(off > ip->size)
    800037e8:	04caa783          	lw	a5,76(s5)
    800037ec:	0327fa63          	bgeu	a5,s2,80003820 <writei+0xf6>
    ip->size = off;
    800037f0:	052aa623          	sw	s2,76(s5)
    800037f4:	64e6                	ld	s1,88(sp)
    800037f6:	7c02                	ld	s8,32(sp)
    800037f8:	6ce2                	ld	s9,24(sp)
    800037fa:	6d42                	ld	s10,16(sp)
    800037fc:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    800037fe:	8556                	mv	a0,s5
    80003800:	b27ff0ef          	jal	80003326 <iupdate>

  return tot;
    80003804:	0009851b          	sext.w	a0,s3
    80003808:	69a6                	ld	s3,72(sp)
}
    8000380a:	70a6                	ld	ra,104(sp)
    8000380c:	7406                	ld	s0,96(sp)
    8000380e:	6946                	ld	s2,80(sp)
    80003810:	6a06                	ld	s4,64(sp)
    80003812:	7ae2                	ld	s5,56(sp)
    80003814:	7b42                	ld	s6,48(sp)
    80003816:	7ba2                	ld	s7,40(sp)
    80003818:	6165                	addi	sp,sp,112
    8000381a:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000381c:	89da                	mv	s3,s6
    8000381e:	b7c5                	j	800037fe <writei+0xd4>
    80003820:	64e6                	ld	s1,88(sp)
    80003822:	7c02                	ld	s8,32(sp)
    80003824:	6ce2                	ld	s9,24(sp)
    80003826:	6d42                	ld	s10,16(sp)
    80003828:	6da2                	ld	s11,8(sp)
    8000382a:	bfd1                	j	800037fe <writei+0xd4>
    return -1;
    8000382c:	557d                	li	a0,-1
}
    8000382e:	8082                	ret
    return -1;
    80003830:	557d                	li	a0,-1
    80003832:	bfe1                	j	8000380a <writei+0xe0>
    return -1;
    80003834:	557d                	li	a0,-1
    80003836:	bfd1                	j	8000380a <writei+0xe0>

0000000080003838 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003838:	1141                	addi	sp,sp,-16
    8000383a:	e406                	sd	ra,8(sp)
    8000383c:	e022                	sd	s0,0(sp)
    8000383e:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003840:	4639                	li	a2,14
    80003842:	d52fd0ef          	jal	80000d94 <strncmp>
}
    80003846:	60a2                	ld	ra,8(sp)
    80003848:	6402                	ld	s0,0(sp)
    8000384a:	0141                	addi	sp,sp,16
    8000384c:	8082                	ret

000000008000384e <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    8000384e:	7139                	addi	sp,sp,-64
    80003850:	fc06                	sd	ra,56(sp)
    80003852:	f822                	sd	s0,48(sp)
    80003854:	f426                	sd	s1,40(sp)
    80003856:	f04a                	sd	s2,32(sp)
    80003858:	ec4e                	sd	s3,24(sp)
    8000385a:	e852                	sd	s4,16(sp)
    8000385c:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    8000385e:	04451703          	lh	a4,68(a0)
    80003862:	4785                	li	a5,1
    80003864:	00f71a63          	bne	a4,a5,80003878 <dirlookup+0x2a>
    80003868:	892a                	mv	s2,a0
    8000386a:	89ae                	mv	s3,a1
    8000386c:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    8000386e:	457c                	lw	a5,76(a0)
    80003870:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003872:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003874:	e39d                	bnez	a5,8000389a <dirlookup+0x4c>
    80003876:	a095                	j	800038da <dirlookup+0x8c>
    panic("dirlookup not DIR");
    80003878:	00004517          	auipc	a0,0x4
    8000387c:	d3050513          	addi	a0,a0,-720 # 800075a8 <etext+0x5a8>
    80003880:	f15fc0ef          	jal	80000794 <panic>
      panic("dirlookup read");
    80003884:	00004517          	auipc	a0,0x4
    80003888:	d3c50513          	addi	a0,a0,-708 # 800075c0 <etext+0x5c0>
    8000388c:	f09fc0ef          	jal	80000794 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003890:	24c1                	addiw	s1,s1,16
    80003892:	04c92783          	lw	a5,76(s2)
    80003896:	04f4f163          	bgeu	s1,a5,800038d8 <dirlookup+0x8a>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000389a:	4741                	li	a4,16
    8000389c:	86a6                	mv	a3,s1
    8000389e:	fc040613          	addi	a2,s0,-64
    800038a2:	4581                	li	a1,0
    800038a4:	854a                	mv	a0,s2
    800038a6:	d89ff0ef          	jal	8000362e <readi>
    800038aa:	47c1                	li	a5,16
    800038ac:	fcf51ce3          	bne	a0,a5,80003884 <dirlookup+0x36>
    if(de.inum == 0)
    800038b0:	fc045783          	lhu	a5,-64(s0)
    800038b4:	dff1                	beqz	a5,80003890 <dirlookup+0x42>
    if(namecmp(name, de.name) == 0){
    800038b6:	fc240593          	addi	a1,s0,-62
    800038ba:	854e                	mv	a0,s3
    800038bc:	f7dff0ef          	jal	80003838 <namecmp>
    800038c0:	f961                	bnez	a0,80003890 <dirlookup+0x42>
      if(poff)
    800038c2:	000a0463          	beqz	s4,800038ca <dirlookup+0x7c>
        *poff = off;
    800038c6:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    800038ca:	fc045583          	lhu	a1,-64(s0)
    800038ce:	00092503          	lw	a0,0(s2)
    800038d2:	829ff0ef          	jal	800030fa <iget>
    800038d6:	a011                	j	800038da <dirlookup+0x8c>
  return 0;
    800038d8:	4501                	li	a0,0
}
    800038da:	70e2                	ld	ra,56(sp)
    800038dc:	7442                	ld	s0,48(sp)
    800038de:	74a2                	ld	s1,40(sp)
    800038e0:	7902                	ld	s2,32(sp)
    800038e2:	69e2                	ld	s3,24(sp)
    800038e4:	6a42                	ld	s4,16(sp)
    800038e6:	6121                	addi	sp,sp,64
    800038e8:	8082                	ret

00000000800038ea <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    800038ea:	711d                	addi	sp,sp,-96
    800038ec:	ec86                	sd	ra,88(sp)
    800038ee:	e8a2                	sd	s0,80(sp)
    800038f0:	e4a6                	sd	s1,72(sp)
    800038f2:	e0ca                	sd	s2,64(sp)
    800038f4:	fc4e                	sd	s3,56(sp)
    800038f6:	f852                	sd	s4,48(sp)
    800038f8:	f456                	sd	s5,40(sp)
    800038fa:	f05a                	sd	s6,32(sp)
    800038fc:	ec5e                	sd	s7,24(sp)
    800038fe:	e862                	sd	s8,16(sp)
    80003900:	e466                	sd	s9,8(sp)
    80003902:	1080                	addi	s0,sp,96
    80003904:	84aa                	mv	s1,a0
    80003906:	8b2e                	mv	s6,a1
    80003908:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    8000390a:	00054703          	lbu	a4,0(a0)
    8000390e:	02f00793          	li	a5,47
    80003912:	00f70e63          	beq	a4,a5,8000392e <namex+0x44>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003916:	fcbfd0ef          	jal	800018e0 <myproc>
    8000391a:	15053503          	ld	a0,336(a0)
    8000391e:	a87ff0ef          	jal	800033a4 <idup>
    80003922:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003924:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80003928:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    8000392a:	4b85                	li	s7,1
    8000392c:	a871                	j	800039c8 <namex+0xde>
    ip = iget(ROOTDEV, ROOTINO);
    8000392e:	4585                	li	a1,1
    80003930:	4505                	li	a0,1
    80003932:	fc8ff0ef          	jal	800030fa <iget>
    80003936:	8a2a                	mv	s4,a0
    80003938:	b7f5                	j	80003924 <namex+0x3a>
      iunlockput(ip);
    8000393a:	8552                	mv	a0,s4
    8000393c:	ca9ff0ef          	jal	800035e4 <iunlockput>
      return 0;
    80003940:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003942:	8552                	mv	a0,s4
    80003944:	60e6                	ld	ra,88(sp)
    80003946:	6446                	ld	s0,80(sp)
    80003948:	64a6                	ld	s1,72(sp)
    8000394a:	6906                	ld	s2,64(sp)
    8000394c:	79e2                	ld	s3,56(sp)
    8000394e:	7a42                	ld	s4,48(sp)
    80003950:	7aa2                	ld	s5,40(sp)
    80003952:	7b02                	ld	s6,32(sp)
    80003954:	6be2                	ld	s7,24(sp)
    80003956:	6c42                	ld	s8,16(sp)
    80003958:	6ca2                	ld	s9,8(sp)
    8000395a:	6125                	addi	sp,sp,96
    8000395c:	8082                	ret
      iunlock(ip);
    8000395e:	8552                	mv	a0,s4
    80003960:	b29ff0ef          	jal	80003488 <iunlock>
      return ip;
    80003964:	bff9                	j	80003942 <namex+0x58>
      iunlockput(ip);
    80003966:	8552                	mv	a0,s4
    80003968:	c7dff0ef          	jal	800035e4 <iunlockput>
      return 0;
    8000396c:	8a4e                	mv	s4,s3
    8000396e:	bfd1                	j	80003942 <namex+0x58>
  len = path - s;
    80003970:	40998633          	sub	a2,s3,s1
    80003974:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003978:	099c5063          	bge	s8,s9,800039f8 <namex+0x10e>
    memmove(name, s, DIRSIZ);
    8000397c:	4639                	li	a2,14
    8000397e:	85a6                	mv	a1,s1
    80003980:	8556                	mv	a0,s5
    80003982:	ba2fd0ef          	jal	80000d24 <memmove>
    80003986:	84ce                	mv	s1,s3
  while(*path == '/')
    80003988:	0004c783          	lbu	a5,0(s1)
    8000398c:	01279763          	bne	a5,s2,8000399a <namex+0xb0>
    path++;
    80003990:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003992:	0004c783          	lbu	a5,0(s1)
    80003996:	ff278de3          	beq	a5,s2,80003990 <namex+0xa6>
    ilock(ip);
    8000399a:	8552                	mv	a0,s4
    8000399c:	a3fff0ef          	jal	800033da <ilock>
    if(ip->type != T_DIR){
    800039a0:	044a1783          	lh	a5,68(s4)
    800039a4:	f9779be3          	bne	a5,s7,8000393a <namex+0x50>
    if(nameiparent && *path == '\0'){
    800039a8:	000b0563          	beqz	s6,800039b2 <namex+0xc8>
    800039ac:	0004c783          	lbu	a5,0(s1)
    800039b0:	d7dd                	beqz	a5,8000395e <namex+0x74>
    if((next = dirlookup(ip, name, 0)) == 0){
    800039b2:	4601                	li	a2,0
    800039b4:	85d6                	mv	a1,s5
    800039b6:	8552                	mv	a0,s4
    800039b8:	e97ff0ef          	jal	8000384e <dirlookup>
    800039bc:	89aa                	mv	s3,a0
    800039be:	d545                	beqz	a0,80003966 <namex+0x7c>
    iunlockput(ip);
    800039c0:	8552                	mv	a0,s4
    800039c2:	c23ff0ef          	jal	800035e4 <iunlockput>
    ip = next;
    800039c6:	8a4e                	mv	s4,s3
  while(*path == '/')
    800039c8:	0004c783          	lbu	a5,0(s1)
    800039cc:	01279763          	bne	a5,s2,800039da <namex+0xf0>
    path++;
    800039d0:	0485                	addi	s1,s1,1
  while(*path == '/')
    800039d2:	0004c783          	lbu	a5,0(s1)
    800039d6:	ff278de3          	beq	a5,s2,800039d0 <namex+0xe6>
  if(*path == 0)
    800039da:	cb8d                	beqz	a5,80003a0c <namex+0x122>
  while(*path != '/' && *path != 0)
    800039dc:	0004c783          	lbu	a5,0(s1)
    800039e0:	89a6                	mv	s3,s1
  len = path - s;
    800039e2:	4c81                	li	s9,0
    800039e4:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    800039e6:	01278963          	beq	a5,s2,800039f8 <namex+0x10e>
    800039ea:	d3d9                	beqz	a5,80003970 <namex+0x86>
    path++;
    800039ec:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    800039ee:	0009c783          	lbu	a5,0(s3)
    800039f2:	ff279ce3          	bne	a5,s2,800039ea <namex+0x100>
    800039f6:	bfad                	j	80003970 <namex+0x86>
    memmove(name, s, len);
    800039f8:	2601                	sext.w	a2,a2
    800039fa:	85a6                	mv	a1,s1
    800039fc:	8556                	mv	a0,s5
    800039fe:	b26fd0ef          	jal	80000d24 <memmove>
    name[len] = 0;
    80003a02:	9cd6                	add	s9,s9,s5
    80003a04:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80003a08:	84ce                	mv	s1,s3
    80003a0a:	bfbd                	j	80003988 <namex+0x9e>
  if(nameiparent){
    80003a0c:	f20b0be3          	beqz	s6,80003942 <namex+0x58>
    iput(ip);
    80003a10:	8552                	mv	a0,s4
    80003a12:	b4bff0ef          	jal	8000355c <iput>
    return 0;
    80003a16:	4a01                	li	s4,0
    80003a18:	b72d                	j	80003942 <namex+0x58>

0000000080003a1a <dirlink>:
{
    80003a1a:	7139                	addi	sp,sp,-64
    80003a1c:	fc06                	sd	ra,56(sp)
    80003a1e:	f822                	sd	s0,48(sp)
    80003a20:	f04a                	sd	s2,32(sp)
    80003a22:	ec4e                	sd	s3,24(sp)
    80003a24:	e852                	sd	s4,16(sp)
    80003a26:	0080                	addi	s0,sp,64
    80003a28:	892a                	mv	s2,a0
    80003a2a:	8a2e                	mv	s4,a1
    80003a2c:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003a2e:	4601                	li	a2,0
    80003a30:	e1fff0ef          	jal	8000384e <dirlookup>
    80003a34:	e535                	bnez	a0,80003aa0 <dirlink+0x86>
    80003a36:	f426                	sd	s1,40(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003a38:	04c92483          	lw	s1,76(s2)
    80003a3c:	c48d                	beqz	s1,80003a66 <dirlink+0x4c>
    80003a3e:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003a40:	4741                	li	a4,16
    80003a42:	86a6                	mv	a3,s1
    80003a44:	fc040613          	addi	a2,s0,-64
    80003a48:	4581                	li	a1,0
    80003a4a:	854a                	mv	a0,s2
    80003a4c:	be3ff0ef          	jal	8000362e <readi>
    80003a50:	47c1                	li	a5,16
    80003a52:	04f51b63          	bne	a0,a5,80003aa8 <dirlink+0x8e>
    if(de.inum == 0)
    80003a56:	fc045783          	lhu	a5,-64(s0)
    80003a5a:	c791                	beqz	a5,80003a66 <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003a5c:	24c1                	addiw	s1,s1,16
    80003a5e:	04c92783          	lw	a5,76(s2)
    80003a62:	fcf4efe3          	bltu	s1,a5,80003a40 <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    80003a66:	4639                	li	a2,14
    80003a68:	85d2                	mv	a1,s4
    80003a6a:	fc240513          	addi	a0,s0,-62
    80003a6e:	b5cfd0ef          	jal	80000dca <strncpy>
  de.inum = inum;
    80003a72:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003a76:	4741                	li	a4,16
    80003a78:	86a6                	mv	a3,s1
    80003a7a:	fc040613          	addi	a2,s0,-64
    80003a7e:	4581                	li	a1,0
    80003a80:	854a                	mv	a0,s2
    80003a82:	ca9ff0ef          	jal	8000372a <writei>
    80003a86:	1541                	addi	a0,a0,-16
    80003a88:	00a03533          	snez	a0,a0
    80003a8c:	40a00533          	neg	a0,a0
    80003a90:	74a2                	ld	s1,40(sp)
}
    80003a92:	70e2                	ld	ra,56(sp)
    80003a94:	7442                	ld	s0,48(sp)
    80003a96:	7902                	ld	s2,32(sp)
    80003a98:	69e2                	ld	s3,24(sp)
    80003a9a:	6a42                	ld	s4,16(sp)
    80003a9c:	6121                	addi	sp,sp,64
    80003a9e:	8082                	ret
    iput(ip);
    80003aa0:	abdff0ef          	jal	8000355c <iput>
    return -1;
    80003aa4:	557d                	li	a0,-1
    80003aa6:	b7f5                	j	80003a92 <dirlink+0x78>
      panic("dirlink read");
    80003aa8:	00004517          	auipc	a0,0x4
    80003aac:	b2850513          	addi	a0,a0,-1240 # 800075d0 <etext+0x5d0>
    80003ab0:	ce5fc0ef          	jal	80000794 <panic>

0000000080003ab4 <namei>:

struct inode*
namei(char *path)
{
    80003ab4:	1101                	addi	sp,sp,-32
    80003ab6:	ec06                	sd	ra,24(sp)
    80003ab8:	e822                	sd	s0,16(sp)
    80003aba:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003abc:	fe040613          	addi	a2,s0,-32
    80003ac0:	4581                	li	a1,0
    80003ac2:	e29ff0ef          	jal	800038ea <namex>
}
    80003ac6:	60e2                	ld	ra,24(sp)
    80003ac8:	6442                	ld	s0,16(sp)
    80003aca:	6105                	addi	sp,sp,32
    80003acc:	8082                	ret

0000000080003ace <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003ace:	1141                	addi	sp,sp,-16
    80003ad0:	e406                	sd	ra,8(sp)
    80003ad2:	e022                	sd	s0,0(sp)
    80003ad4:	0800                	addi	s0,sp,16
    80003ad6:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003ad8:	4585                	li	a1,1
    80003ada:	e11ff0ef          	jal	800038ea <namex>
}
    80003ade:	60a2                	ld	ra,8(sp)
    80003ae0:	6402                	ld	s0,0(sp)
    80003ae2:	0141                	addi	sp,sp,16
    80003ae4:	8082                	ret

0000000080003ae6 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003ae6:	1101                	addi	sp,sp,-32
    80003ae8:	ec06                	sd	ra,24(sp)
    80003aea:	e822                	sd	s0,16(sp)
    80003aec:	e426                	sd	s1,8(sp)
    80003aee:	e04a                	sd	s2,0(sp)
    80003af0:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003af2:	00024917          	auipc	s2,0x24
    80003af6:	7d690913          	addi	s2,s2,2006 # 800282c8 <log>
    80003afa:	01892583          	lw	a1,24(s2)
    80003afe:	02892503          	lw	a0,40(s2)
    80003b02:	9a0ff0ef          	jal	80002ca2 <bread>
    80003b06:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003b08:	02c92603          	lw	a2,44(s2)
    80003b0c:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003b0e:	00c05f63          	blez	a2,80003b2c <write_head+0x46>
    80003b12:	00024717          	auipc	a4,0x24
    80003b16:	7e670713          	addi	a4,a4,2022 # 800282f8 <log+0x30>
    80003b1a:	87aa                	mv	a5,a0
    80003b1c:	060a                	slli	a2,a2,0x2
    80003b1e:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003b20:	4314                	lw	a3,0(a4)
    80003b22:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003b24:	0711                	addi	a4,a4,4
    80003b26:	0791                	addi	a5,a5,4
    80003b28:	fec79ce3          	bne	a5,a2,80003b20 <write_head+0x3a>
  }
  bwrite(buf);
    80003b2c:	8526                	mv	a0,s1
    80003b2e:	a4aff0ef          	jal	80002d78 <bwrite>
  brelse(buf);
    80003b32:	8526                	mv	a0,s1
    80003b34:	a76ff0ef          	jal	80002daa <brelse>
}
    80003b38:	60e2                	ld	ra,24(sp)
    80003b3a:	6442                	ld	s0,16(sp)
    80003b3c:	64a2                	ld	s1,8(sp)
    80003b3e:	6902                	ld	s2,0(sp)
    80003b40:	6105                	addi	sp,sp,32
    80003b42:	8082                	ret

0000000080003b44 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003b44:	00024797          	auipc	a5,0x24
    80003b48:	7b07a783          	lw	a5,1968(a5) # 800282f4 <log+0x2c>
    80003b4c:	08f05f63          	blez	a5,80003bea <install_trans+0xa6>
{
    80003b50:	7139                	addi	sp,sp,-64
    80003b52:	fc06                	sd	ra,56(sp)
    80003b54:	f822                	sd	s0,48(sp)
    80003b56:	f426                	sd	s1,40(sp)
    80003b58:	f04a                	sd	s2,32(sp)
    80003b5a:	ec4e                	sd	s3,24(sp)
    80003b5c:	e852                	sd	s4,16(sp)
    80003b5e:	e456                	sd	s5,8(sp)
    80003b60:	e05a                	sd	s6,0(sp)
    80003b62:	0080                	addi	s0,sp,64
    80003b64:	8b2a                	mv	s6,a0
    80003b66:	00024a97          	auipc	s5,0x24
    80003b6a:	792a8a93          	addi	s5,s5,1938 # 800282f8 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003b6e:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003b70:	00024997          	auipc	s3,0x24
    80003b74:	75898993          	addi	s3,s3,1880 # 800282c8 <log>
    80003b78:	a829                	j	80003b92 <install_trans+0x4e>
    brelse(lbuf);
    80003b7a:	854a                	mv	a0,s2
    80003b7c:	a2eff0ef          	jal	80002daa <brelse>
    brelse(dbuf);
    80003b80:	8526                	mv	a0,s1
    80003b82:	a28ff0ef          	jal	80002daa <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003b86:	2a05                	addiw	s4,s4,1
    80003b88:	0a91                	addi	s5,s5,4
    80003b8a:	02c9a783          	lw	a5,44(s3)
    80003b8e:	04fa5463          	bge	s4,a5,80003bd6 <install_trans+0x92>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003b92:	0189a583          	lw	a1,24(s3)
    80003b96:	014585bb          	addw	a1,a1,s4
    80003b9a:	2585                	addiw	a1,a1,1
    80003b9c:	0289a503          	lw	a0,40(s3)
    80003ba0:	902ff0ef          	jal	80002ca2 <bread>
    80003ba4:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003ba6:	000aa583          	lw	a1,0(s5)
    80003baa:	0289a503          	lw	a0,40(s3)
    80003bae:	8f4ff0ef          	jal	80002ca2 <bread>
    80003bb2:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003bb4:	40000613          	li	a2,1024
    80003bb8:	05890593          	addi	a1,s2,88
    80003bbc:	05850513          	addi	a0,a0,88
    80003bc0:	964fd0ef          	jal	80000d24 <memmove>
    bwrite(dbuf);  // write dst to disk
    80003bc4:	8526                	mv	a0,s1
    80003bc6:	9b2ff0ef          	jal	80002d78 <bwrite>
    if(recovering == 0)
    80003bca:	fa0b18e3          	bnez	s6,80003b7a <install_trans+0x36>
      bunpin(dbuf);
    80003bce:	8526                	mv	a0,s1
    80003bd0:	a96ff0ef          	jal	80002e66 <bunpin>
    80003bd4:	b75d                	j	80003b7a <install_trans+0x36>
}
    80003bd6:	70e2                	ld	ra,56(sp)
    80003bd8:	7442                	ld	s0,48(sp)
    80003bda:	74a2                	ld	s1,40(sp)
    80003bdc:	7902                	ld	s2,32(sp)
    80003bde:	69e2                	ld	s3,24(sp)
    80003be0:	6a42                	ld	s4,16(sp)
    80003be2:	6aa2                	ld	s5,8(sp)
    80003be4:	6b02                	ld	s6,0(sp)
    80003be6:	6121                	addi	sp,sp,64
    80003be8:	8082                	ret
    80003bea:	8082                	ret

0000000080003bec <initlog>:
{
    80003bec:	7179                	addi	sp,sp,-48
    80003bee:	f406                	sd	ra,40(sp)
    80003bf0:	f022                	sd	s0,32(sp)
    80003bf2:	ec26                	sd	s1,24(sp)
    80003bf4:	e84a                	sd	s2,16(sp)
    80003bf6:	e44e                	sd	s3,8(sp)
    80003bf8:	1800                	addi	s0,sp,48
    80003bfa:	892a                	mv	s2,a0
    80003bfc:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003bfe:	00024497          	auipc	s1,0x24
    80003c02:	6ca48493          	addi	s1,s1,1738 # 800282c8 <log>
    80003c06:	00004597          	auipc	a1,0x4
    80003c0a:	9da58593          	addi	a1,a1,-1574 # 800075e0 <etext+0x5e0>
    80003c0e:	8526                	mv	a0,s1
    80003c10:	f65fc0ef          	jal	80000b74 <initlock>
  log.start = sb->logstart;
    80003c14:	0149a583          	lw	a1,20(s3)
    80003c18:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80003c1a:	0109a783          	lw	a5,16(s3)
    80003c1e:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80003c20:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003c24:	854a                	mv	a0,s2
    80003c26:	87cff0ef          	jal	80002ca2 <bread>
  log.lh.n = lh->n;
    80003c2a:	4d30                	lw	a2,88(a0)
    80003c2c:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80003c2e:	00c05f63          	blez	a2,80003c4c <initlog+0x60>
    80003c32:	87aa                	mv	a5,a0
    80003c34:	00024717          	auipc	a4,0x24
    80003c38:	6c470713          	addi	a4,a4,1732 # 800282f8 <log+0x30>
    80003c3c:	060a                	slli	a2,a2,0x2
    80003c3e:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80003c40:	4ff4                	lw	a3,92(a5)
    80003c42:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003c44:	0791                	addi	a5,a5,4
    80003c46:	0711                	addi	a4,a4,4
    80003c48:	fec79ce3          	bne	a5,a2,80003c40 <initlog+0x54>
  brelse(buf);
    80003c4c:	95eff0ef          	jal	80002daa <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003c50:	4505                	li	a0,1
    80003c52:	ef3ff0ef          	jal	80003b44 <install_trans>
  log.lh.n = 0;
    80003c56:	00024797          	auipc	a5,0x24
    80003c5a:	6807af23          	sw	zero,1694(a5) # 800282f4 <log+0x2c>
  write_head(); // clear the log
    80003c5e:	e89ff0ef          	jal	80003ae6 <write_head>
}
    80003c62:	70a2                	ld	ra,40(sp)
    80003c64:	7402                	ld	s0,32(sp)
    80003c66:	64e2                	ld	s1,24(sp)
    80003c68:	6942                	ld	s2,16(sp)
    80003c6a:	69a2                	ld	s3,8(sp)
    80003c6c:	6145                	addi	sp,sp,48
    80003c6e:	8082                	ret

0000000080003c70 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003c70:	1101                	addi	sp,sp,-32
    80003c72:	ec06                	sd	ra,24(sp)
    80003c74:	e822                	sd	s0,16(sp)
    80003c76:	e426                	sd	s1,8(sp)
    80003c78:	e04a                	sd	s2,0(sp)
    80003c7a:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003c7c:	00024517          	auipc	a0,0x24
    80003c80:	64c50513          	addi	a0,a0,1612 # 800282c8 <log>
    80003c84:	f71fc0ef          	jal	80000bf4 <acquire>
  while(1){
    if(log.committing){
    80003c88:	00024497          	auipc	s1,0x24
    80003c8c:	64048493          	addi	s1,s1,1600 # 800282c8 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80003c90:	4979                	li	s2,30
    80003c92:	a029                	j	80003c9c <begin_op+0x2c>
      sleep(&log, &log.lock);
    80003c94:	85a6                	mv	a1,s1
    80003c96:	8526                	mv	a0,s1
    80003c98:	a16fe0ef          	jal	80001eae <sleep>
    if(log.committing){
    80003c9c:	50dc                	lw	a5,36(s1)
    80003c9e:	fbfd                	bnez	a5,80003c94 <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80003ca0:	5098                	lw	a4,32(s1)
    80003ca2:	2705                	addiw	a4,a4,1
    80003ca4:	0027179b          	slliw	a5,a4,0x2
    80003ca8:	9fb9                	addw	a5,a5,a4
    80003caa:	0017979b          	slliw	a5,a5,0x1
    80003cae:	54d4                	lw	a3,44(s1)
    80003cb0:	9fb5                	addw	a5,a5,a3
    80003cb2:	00f95763          	bge	s2,a5,80003cc0 <begin_op+0x50>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80003cb6:	85a6                	mv	a1,s1
    80003cb8:	8526                	mv	a0,s1
    80003cba:	9f4fe0ef          	jal	80001eae <sleep>
    80003cbe:	bff9                	j	80003c9c <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    80003cc0:	00024517          	auipc	a0,0x24
    80003cc4:	60850513          	addi	a0,a0,1544 # 800282c8 <log>
    80003cc8:	d118                	sw	a4,32(a0)
      release(&log.lock);
    80003cca:	fc3fc0ef          	jal	80000c8c <release>
      break;
    }
  }
}
    80003cce:	60e2                	ld	ra,24(sp)
    80003cd0:	6442                	ld	s0,16(sp)
    80003cd2:	64a2                	ld	s1,8(sp)
    80003cd4:	6902                	ld	s2,0(sp)
    80003cd6:	6105                	addi	sp,sp,32
    80003cd8:	8082                	ret

0000000080003cda <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003cda:	7139                	addi	sp,sp,-64
    80003cdc:	fc06                	sd	ra,56(sp)
    80003cde:	f822                	sd	s0,48(sp)
    80003ce0:	f426                	sd	s1,40(sp)
    80003ce2:	f04a                	sd	s2,32(sp)
    80003ce4:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003ce6:	00024497          	auipc	s1,0x24
    80003cea:	5e248493          	addi	s1,s1,1506 # 800282c8 <log>
    80003cee:	8526                	mv	a0,s1
    80003cf0:	f05fc0ef          	jal	80000bf4 <acquire>
  log.outstanding -= 1;
    80003cf4:	509c                	lw	a5,32(s1)
    80003cf6:	37fd                	addiw	a5,a5,-1
    80003cf8:	0007891b          	sext.w	s2,a5
    80003cfc:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80003cfe:	50dc                	lw	a5,36(s1)
    80003d00:	ef9d                	bnez	a5,80003d3e <end_op+0x64>
    panic("log.committing");
  if(log.outstanding == 0){
    80003d02:	04091763          	bnez	s2,80003d50 <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    80003d06:	00024497          	auipc	s1,0x24
    80003d0a:	5c248493          	addi	s1,s1,1474 # 800282c8 <log>
    80003d0e:	4785                	li	a5,1
    80003d10:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003d12:	8526                	mv	a0,s1
    80003d14:	f79fc0ef          	jal	80000c8c <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003d18:	54dc                	lw	a5,44(s1)
    80003d1a:	04f04b63          	bgtz	a5,80003d70 <end_op+0x96>
    acquire(&log.lock);
    80003d1e:	00024497          	auipc	s1,0x24
    80003d22:	5aa48493          	addi	s1,s1,1450 # 800282c8 <log>
    80003d26:	8526                	mv	a0,s1
    80003d28:	ecdfc0ef          	jal	80000bf4 <acquire>
    log.committing = 0;
    80003d2c:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80003d30:	8526                	mv	a0,s1
    80003d32:	9c8fe0ef          	jal	80001efa <wakeup>
    release(&log.lock);
    80003d36:	8526                	mv	a0,s1
    80003d38:	f55fc0ef          	jal	80000c8c <release>
}
    80003d3c:	a025                	j	80003d64 <end_op+0x8a>
    80003d3e:	ec4e                	sd	s3,24(sp)
    80003d40:	e852                	sd	s4,16(sp)
    80003d42:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80003d44:	00004517          	auipc	a0,0x4
    80003d48:	8a450513          	addi	a0,a0,-1884 # 800075e8 <etext+0x5e8>
    80003d4c:	a49fc0ef          	jal	80000794 <panic>
    wakeup(&log);
    80003d50:	00024497          	auipc	s1,0x24
    80003d54:	57848493          	addi	s1,s1,1400 # 800282c8 <log>
    80003d58:	8526                	mv	a0,s1
    80003d5a:	9a0fe0ef          	jal	80001efa <wakeup>
  release(&log.lock);
    80003d5e:	8526                	mv	a0,s1
    80003d60:	f2dfc0ef          	jal	80000c8c <release>
}
    80003d64:	70e2                	ld	ra,56(sp)
    80003d66:	7442                	ld	s0,48(sp)
    80003d68:	74a2                	ld	s1,40(sp)
    80003d6a:	7902                	ld	s2,32(sp)
    80003d6c:	6121                	addi	sp,sp,64
    80003d6e:	8082                	ret
    80003d70:	ec4e                	sd	s3,24(sp)
    80003d72:	e852                	sd	s4,16(sp)
    80003d74:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80003d76:	00024a97          	auipc	s5,0x24
    80003d7a:	582a8a93          	addi	s5,s5,1410 # 800282f8 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80003d7e:	00024a17          	auipc	s4,0x24
    80003d82:	54aa0a13          	addi	s4,s4,1354 # 800282c8 <log>
    80003d86:	018a2583          	lw	a1,24(s4)
    80003d8a:	012585bb          	addw	a1,a1,s2
    80003d8e:	2585                	addiw	a1,a1,1
    80003d90:	028a2503          	lw	a0,40(s4)
    80003d94:	f0ffe0ef          	jal	80002ca2 <bread>
    80003d98:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80003d9a:	000aa583          	lw	a1,0(s5)
    80003d9e:	028a2503          	lw	a0,40(s4)
    80003da2:	f01fe0ef          	jal	80002ca2 <bread>
    80003da6:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80003da8:	40000613          	li	a2,1024
    80003dac:	05850593          	addi	a1,a0,88
    80003db0:	05848513          	addi	a0,s1,88
    80003db4:	f71fc0ef          	jal	80000d24 <memmove>
    bwrite(to);  // write the log
    80003db8:	8526                	mv	a0,s1
    80003dba:	fbffe0ef          	jal	80002d78 <bwrite>
    brelse(from);
    80003dbe:	854e                	mv	a0,s3
    80003dc0:	febfe0ef          	jal	80002daa <brelse>
    brelse(to);
    80003dc4:	8526                	mv	a0,s1
    80003dc6:	fe5fe0ef          	jal	80002daa <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003dca:	2905                	addiw	s2,s2,1
    80003dcc:	0a91                	addi	s5,s5,4
    80003dce:	02ca2783          	lw	a5,44(s4)
    80003dd2:	faf94ae3          	blt	s2,a5,80003d86 <end_op+0xac>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80003dd6:	d11ff0ef          	jal	80003ae6 <write_head>
    install_trans(0); // Now install writes to home locations
    80003dda:	4501                	li	a0,0
    80003ddc:	d69ff0ef          	jal	80003b44 <install_trans>
    log.lh.n = 0;
    80003de0:	00024797          	auipc	a5,0x24
    80003de4:	5007aa23          	sw	zero,1300(a5) # 800282f4 <log+0x2c>
    write_head();    // Erase the transaction from the log
    80003de8:	cffff0ef          	jal	80003ae6 <write_head>
    80003dec:	69e2                	ld	s3,24(sp)
    80003dee:	6a42                	ld	s4,16(sp)
    80003df0:	6aa2                	ld	s5,8(sp)
    80003df2:	b735                	j	80003d1e <end_op+0x44>

0000000080003df4 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80003df4:	1101                	addi	sp,sp,-32
    80003df6:	ec06                	sd	ra,24(sp)
    80003df8:	e822                	sd	s0,16(sp)
    80003dfa:	e426                	sd	s1,8(sp)
    80003dfc:	e04a                	sd	s2,0(sp)
    80003dfe:	1000                	addi	s0,sp,32
    80003e00:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80003e02:	00024917          	auipc	s2,0x24
    80003e06:	4c690913          	addi	s2,s2,1222 # 800282c8 <log>
    80003e0a:	854a                	mv	a0,s2
    80003e0c:	de9fc0ef          	jal	80000bf4 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80003e10:	02c92603          	lw	a2,44(s2)
    80003e14:	47f5                	li	a5,29
    80003e16:	06c7c363          	blt	a5,a2,80003e7c <log_write+0x88>
    80003e1a:	00024797          	auipc	a5,0x24
    80003e1e:	4ca7a783          	lw	a5,1226(a5) # 800282e4 <log+0x1c>
    80003e22:	37fd                	addiw	a5,a5,-1
    80003e24:	04f65c63          	bge	a2,a5,80003e7c <log_write+0x88>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80003e28:	00024797          	auipc	a5,0x24
    80003e2c:	4c07a783          	lw	a5,1216(a5) # 800282e8 <log+0x20>
    80003e30:	04f05c63          	blez	a5,80003e88 <log_write+0x94>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80003e34:	4781                	li	a5,0
    80003e36:	04c05f63          	blez	a2,80003e94 <log_write+0xa0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003e3a:	44cc                	lw	a1,12(s1)
    80003e3c:	00024717          	auipc	a4,0x24
    80003e40:	4bc70713          	addi	a4,a4,1212 # 800282f8 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80003e44:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003e46:	4314                	lw	a3,0(a4)
    80003e48:	04b68663          	beq	a3,a1,80003e94 <log_write+0xa0>
  for (i = 0; i < log.lh.n; i++) {
    80003e4c:	2785                	addiw	a5,a5,1
    80003e4e:	0711                	addi	a4,a4,4
    80003e50:	fef61be3          	bne	a2,a5,80003e46 <log_write+0x52>
      break;
  }
  log.lh.block[i] = b->blockno;
    80003e54:	0621                	addi	a2,a2,8
    80003e56:	060a                	slli	a2,a2,0x2
    80003e58:	00024797          	auipc	a5,0x24
    80003e5c:	47078793          	addi	a5,a5,1136 # 800282c8 <log>
    80003e60:	97b2                	add	a5,a5,a2
    80003e62:	44d8                	lw	a4,12(s1)
    80003e64:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80003e66:	8526                	mv	a0,s1
    80003e68:	fcbfe0ef          	jal	80002e32 <bpin>
    log.lh.n++;
    80003e6c:	00024717          	auipc	a4,0x24
    80003e70:	45c70713          	addi	a4,a4,1116 # 800282c8 <log>
    80003e74:	575c                	lw	a5,44(a4)
    80003e76:	2785                	addiw	a5,a5,1
    80003e78:	d75c                	sw	a5,44(a4)
    80003e7a:	a80d                	j	80003eac <log_write+0xb8>
    panic("too big a transaction");
    80003e7c:	00003517          	auipc	a0,0x3
    80003e80:	77c50513          	addi	a0,a0,1916 # 800075f8 <etext+0x5f8>
    80003e84:	911fc0ef          	jal	80000794 <panic>
    panic("log_write outside of trans");
    80003e88:	00003517          	auipc	a0,0x3
    80003e8c:	78850513          	addi	a0,a0,1928 # 80007610 <etext+0x610>
    80003e90:	905fc0ef          	jal	80000794 <panic>
  log.lh.block[i] = b->blockno;
    80003e94:	00878693          	addi	a3,a5,8
    80003e98:	068a                	slli	a3,a3,0x2
    80003e9a:	00024717          	auipc	a4,0x24
    80003e9e:	42e70713          	addi	a4,a4,1070 # 800282c8 <log>
    80003ea2:	9736                	add	a4,a4,a3
    80003ea4:	44d4                	lw	a3,12(s1)
    80003ea6:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80003ea8:	faf60fe3          	beq	a2,a5,80003e66 <log_write+0x72>
  }
  release(&log.lock);
    80003eac:	00024517          	auipc	a0,0x24
    80003eb0:	41c50513          	addi	a0,a0,1052 # 800282c8 <log>
    80003eb4:	dd9fc0ef          	jal	80000c8c <release>
}
    80003eb8:	60e2                	ld	ra,24(sp)
    80003eba:	6442                	ld	s0,16(sp)
    80003ebc:	64a2                	ld	s1,8(sp)
    80003ebe:	6902                	ld	s2,0(sp)
    80003ec0:	6105                	addi	sp,sp,32
    80003ec2:	8082                	ret

0000000080003ec4 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80003ec4:	1101                	addi	sp,sp,-32
    80003ec6:	ec06                	sd	ra,24(sp)
    80003ec8:	e822                	sd	s0,16(sp)
    80003eca:	e426                	sd	s1,8(sp)
    80003ecc:	e04a                	sd	s2,0(sp)
    80003ece:	1000                	addi	s0,sp,32
    80003ed0:	84aa                	mv	s1,a0
    80003ed2:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80003ed4:	00003597          	auipc	a1,0x3
    80003ed8:	75c58593          	addi	a1,a1,1884 # 80007630 <etext+0x630>
    80003edc:	0521                	addi	a0,a0,8
    80003ede:	c97fc0ef          	jal	80000b74 <initlock>
  lk->name = name;
    80003ee2:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80003ee6:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003eea:	0204a423          	sw	zero,40(s1)
}
    80003eee:	60e2                	ld	ra,24(sp)
    80003ef0:	6442                	ld	s0,16(sp)
    80003ef2:	64a2                	ld	s1,8(sp)
    80003ef4:	6902                	ld	s2,0(sp)
    80003ef6:	6105                	addi	sp,sp,32
    80003ef8:	8082                	ret

0000000080003efa <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80003efa:	1101                	addi	sp,sp,-32
    80003efc:	ec06                	sd	ra,24(sp)
    80003efe:	e822                	sd	s0,16(sp)
    80003f00:	e426                	sd	s1,8(sp)
    80003f02:	e04a                	sd	s2,0(sp)
    80003f04:	1000                	addi	s0,sp,32
    80003f06:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003f08:	00850913          	addi	s2,a0,8
    80003f0c:	854a                	mv	a0,s2
    80003f0e:	ce7fc0ef          	jal	80000bf4 <acquire>
  while (lk->locked) {
    80003f12:	409c                	lw	a5,0(s1)
    80003f14:	c799                	beqz	a5,80003f22 <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    80003f16:	85ca                	mv	a1,s2
    80003f18:	8526                	mv	a0,s1
    80003f1a:	f95fd0ef          	jal	80001eae <sleep>
  while (lk->locked) {
    80003f1e:	409c                	lw	a5,0(s1)
    80003f20:	fbfd                	bnez	a5,80003f16 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80003f22:	4785                	li	a5,1
    80003f24:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80003f26:	9bbfd0ef          	jal	800018e0 <myproc>
    80003f2a:	591c                	lw	a5,48(a0)
    80003f2c:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80003f2e:	854a                	mv	a0,s2
    80003f30:	d5dfc0ef          	jal	80000c8c <release>
}
    80003f34:	60e2                	ld	ra,24(sp)
    80003f36:	6442                	ld	s0,16(sp)
    80003f38:	64a2                	ld	s1,8(sp)
    80003f3a:	6902                	ld	s2,0(sp)
    80003f3c:	6105                	addi	sp,sp,32
    80003f3e:	8082                	ret

0000000080003f40 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80003f40:	1101                	addi	sp,sp,-32
    80003f42:	ec06                	sd	ra,24(sp)
    80003f44:	e822                	sd	s0,16(sp)
    80003f46:	e426                	sd	s1,8(sp)
    80003f48:	e04a                	sd	s2,0(sp)
    80003f4a:	1000                	addi	s0,sp,32
    80003f4c:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003f4e:	00850913          	addi	s2,a0,8
    80003f52:	854a                	mv	a0,s2
    80003f54:	ca1fc0ef          	jal	80000bf4 <acquire>
  lk->locked = 0;
    80003f58:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003f5c:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80003f60:	8526                	mv	a0,s1
    80003f62:	f99fd0ef          	jal	80001efa <wakeup>
  release(&lk->lk);
    80003f66:	854a                	mv	a0,s2
    80003f68:	d25fc0ef          	jal	80000c8c <release>
}
    80003f6c:	60e2                	ld	ra,24(sp)
    80003f6e:	6442                	ld	s0,16(sp)
    80003f70:	64a2                	ld	s1,8(sp)
    80003f72:	6902                	ld	s2,0(sp)
    80003f74:	6105                	addi	sp,sp,32
    80003f76:	8082                	ret

0000000080003f78 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80003f78:	7179                	addi	sp,sp,-48
    80003f7a:	f406                	sd	ra,40(sp)
    80003f7c:	f022                	sd	s0,32(sp)
    80003f7e:	ec26                	sd	s1,24(sp)
    80003f80:	e84a                	sd	s2,16(sp)
    80003f82:	1800                	addi	s0,sp,48
    80003f84:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80003f86:	00850913          	addi	s2,a0,8
    80003f8a:	854a                	mv	a0,s2
    80003f8c:	c69fc0ef          	jal	80000bf4 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80003f90:	409c                	lw	a5,0(s1)
    80003f92:	ef81                	bnez	a5,80003faa <holdingsleep+0x32>
    80003f94:	4481                	li	s1,0
  release(&lk->lk);
    80003f96:	854a                	mv	a0,s2
    80003f98:	cf5fc0ef          	jal	80000c8c <release>
  return r;
}
    80003f9c:	8526                	mv	a0,s1
    80003f9e:	70a2                	ld	ra,40(sp)
    80003fa0:	7402                	ld	s0,32(sp)
    80003fa2:	64e2                	ld	s1,24(sp)
    80003fa4:	6942                	ld	s2,16(sp)
    80003fa6:	6145                	addi	sp,sp,48
    80003fa8:	8082                	ret
    80003faa:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    80003fac:	0284a983          	lw	s3,40(s1)
    80003fb0:	931fd0ef          	jal	800018e0 <myproc>
    80003fb4:	5904                	lw	s1,48(a0)
    80003fb6:	413484b3          	sub	s1,s1,s3
    80003fba:	0014b493          	seqz	s1,s1
    80003fbe:	69a2                	ld	s3,8(sp)
    80003fc0:	bfd9                	j	80003f96 <holdingsleep+0x1e>

0000000080003fc2 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80003fc2:	1141                	addi	sp,sp,-16
    80003fc4:	e406                	sd	ra,8(sp)
    80003fc6:	e022                	sd	s0,0(sp)
    80003fc8:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80003fca:	00003597          	auipc	a1,0x3
    80003fce:	67658593          	addi	a1,a1,1654 # 80007640 <etext+0x640>
    80003fd2:	00024517          	auipc	a0,0x24
    80003fd6:	43e50513          	addi	a0,a0,1086 # 80028410 <ftable>
    80003fda:	b9bfc0ef          	jal	80000b74 <initlock>
}
    80003fde:	60a2                	ld	ra,8(sp)
    80003fe0:	6402                	ld	s0,0(sp)
    80003fe2:	0141                	addi	sp,sp,16
    80003fe4:	8082                	ret

0000000080003fe6 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80003fe6:	1101                	addi	sp,sp,-32
    80003fe8:	ec06                	sd	ra,24(sp)
    80003fea:	e822                	sd	s0,16(sp)
    80003fec:	e426                	sd	s1,8(sp)
    80003fee:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80003ff0:	00024517          	auipc	a0,0x24
    80003ff4:	42050513          	addi	a0,a0,1056 # 80028410 <ftable>
    80003ff8:	bfdfc0ef          	jal	80000bf4 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80003ffc:	00024497          	auipc	s1,0x24
    80004000:	42c48493          	addi	s1,s1,1068 # 80028428 <ftable+0x18>
    80004004:	00025717          	auipc	a4,0x25
    80004008:	3c470713          	addi	a4,a4,964 # 800293c8 <disk>
    if(f->ref == 0){
    8000400c:	40dc                	lw	a5,4(s1)
    8000400e:	cf89                	beqz	a5,80004028 <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004010:	02848493          	addi	s1,s1,40
    80004014:	fee49ce3          	bne	s1,a4,8000400c <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004018:	00024517          	auipc	a0,0x24
    8000401c:	3f850513          	addi	a0,a0,1016 # 80028410 <ftable>
    80004020:	c6dfc0ef          	jal	80000c8c <release>
  return 0;
    80004024:	4481                	li	s1,0
    80004026:	a809                	j	80004038 <filealloc+0x52>
      f->ref = 1;
    80004028:	4785                	li	a5,1
    8000402a:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    8000402c:	00024517          	auipc	a0,0x24
    80004030:	3e450513          	addi	a0,a0,996 # 80028410 <ftable>
    80004034:	c59fc0ef          	jal	80000c8c <release>
}
    80004038:	8526                	mv	a0,s1
    8000403a:	60e2                	ld	ra,24(sp)
    8000403c:	6442                	ld	s0,16(sp)
    8000403e:	64a2                	ld	s1,8(sp)
    80004040:	6105                	addi	sp,sp,32
    80004042:	8082                	ret

0000000080004044 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004044:	1101                	addi	sp,sp,-32
    80004046:	ec06                	sd	ra,24(sp)
    80004048:	e822                	sd	s0,16(sp)
    8000404a:	e426                	sd	s1,8(sp)
    8000404c:	1000                	addi	s0,sp,32
    8000404e:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004050:	00024517          	auipc	a0,0x24
    80004054:	3c050513          	addi	a0,a0,960 # 80028410 <ftable>
    80004058:	b9dfc0ef          	jal	80000bf4 <acquire>
  if(f->ref < 1)
    8000405c:	40dc                	lw	a5,4(s1)
    8000405e:	02f05063          	blez	a5,8000407e <filedup+0x3a>
    panic("filedup");
  f->ref++;
    80004062:	2785                	addiw	a5,a5,1
    80004064:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004066:	00024517          	auipc	a0,0x24
    8000406a:	3aa50513          	addi	a0,a0,938 # 80028410 <ftable>
    8000406e:	c1ffc0ef          	jal	80000c8c <release>
  return f;
}
    80004072:	8526                	mv	a0,s1
    80004074:	60e2                	ld	ra,24(sp)
    80004076:	6442                	ld	s0,16(sp)
    80004078:	64a2                	ld	s1,8(sp)
    8000407a:	6105                	addi	sp,sp,32
    8000407c:	8082                	ret
    panic("filedup");
    8000407e:	00003517          	auipc	a0,0x3
    80004082:	5ca50513          	addi	a0,a0,1482 # 80007648 <etext+0x648>
    80004086:	f0efc0ef          	jal	80000794 <panic>

000000008000408a <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    8000408a:	7139                	addi	sp,sp,-64
    8000408c:	fc06                	sd	ra,56(sp)
    8000408e:	f822                	sd	s0,48(sp)
    80004090:	f426                	sd	s1,40(sp)
    80004092:	0080                	addi	s0,sp,64
    80004094:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004096:	00024517          	auipc	a0,0x24
    8000409a:	37a50513          	addi	a0,a0,890 # 80028410 <ftable>
    8000409e:	b57fc0ef          	jal	80000bf4 <acquire>
  if(f->ref < 1)
    800040a2:	40dc                	lw	a5,4(s1)
    800040a4:	04f05a63          	blez	a5,800040f8 <fileclose+0x6e>
    panic("fileclose");
  if(--f->ref > 0){
    800040a8:	37fd                	addiw	a5,a5,-1
    800040aa:	0007871b          	sext.w	a4,a5
    800040ae:	c0dc                	sw	a5,4(s1)
    800040b0:	04e04e63          	bgtz	a4,8000410c <fileclose+0x82>
    800040b4:	f04a                	sd	s2,32(sp)
    800040b6:	ec4e                	sd	s3,24(sp)
    800040b8:	e852                	sd	s4,16(sp)
    800040ba:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800040bc:	0004a903          	lw	s2,0(s1)
    800040c0:	0094ca83          	lbu	s5,9(s1)
    800040c4:	0104ba03          	ld	s4,16(s1)
    800040c8:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800040cc:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800040d0:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800040d4:	00024517          	auipc	a0,0x24
    800040d8:	33c50513          	addi	a0,a0,828 # 80028410 <ftable>
    800040dc:	bb1fc0ef          	jal	80000c8c <release>

  if(ff.type == FD_PIPE){
    800040e0:	4785                	li	a5,1
    800040e2:	04f90063          	beq	s2,a5,80004122 <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800040e6:	3979                	addiw	s2,s2,-2
    800040e8:	4785                	li	a5,1
    800040ea:	0527f563          	bgeu	a5,s2,80004134 <fileclose+0xaa>
    800040ee:	7902                	ld	s2,32(sp)
    800040f0:	69e2                	ld	s3,24(sp)
    800040f2:	6a42                	ld	s4,16(sp)
    800040f4:	6aa2                	ld	s5,8(sp)
    800040f6:	a00d                	j	80004118 <fileclose+0x8e>
    800040f8:	f04a                	sd	s2,32(sp)
    800040fa:	ec4e                	sd	s3,24(sp)
    800040fc:	e852                	sd	s4,16(sp)
    800040fe:	e456                	sd	s5,8(sp)
    panic("fileclose");
    80004100:	00003517          	auipc	a0,0x3
    80004104:	55050513          	addi	a0,a0,1360 # 80007650 <etext+0x650>
    80004108:	e8cfc0ef          	jal	80000794 <panic>
    release(&ftable.lock);
    8000410c:	00024517          	auipc	a0,0x24
    80004110:	30450513          	addi	a0,a0,772 # 80028410 <ftable>
    80004114:	b79fc0ef          	jal	80000c8c <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    80004118:	70e2                	ld	ra,56(sp)
    8000411a:	7442                	ld	s0,48(sp)
    8000411c:	74a2                	ld	s1,40(sp)
    8000411e:	6121                	addi	sp,sp,64
    80004120:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004122:	85d6                	mv	a1,s5
    80004124:	8552                	mv	a0,s4
    80004126:	336000ef          	jal	8000445c <pipeclose>
    8000412a:	7902                	ld	s2,32(sp)
    8000412c:	69e2                	ld	s3,24(sp)
    8000412e:	6a42                	ld	s4,16(sp)
    80004130:	6aa2                	ld	s5,8(sp)
    80004132:	b7dd                	j	80004118 <fileclose+0x8e>
    begin_op();
    80004134:	b3dff0ef          	jal	80003c70 <begin_op>
    iput(ff.ip);
    80004138:	854e                	mv	a0,s3
    8000413a:	c22ff0ef          	jal	8000355c <iput>
    end_op();
    8000413e:	b9dff0ef          	jal	80003cda <end_op>
    80004142:	7902                	ld	s2,32(sp)
    80004144:	69e2                	ld	s3,24(sp)
    80004146:	6a42                	ld	s4,16(sp)
    80004148:	6aa2                	ld	s5,8(sp)
    8000414a:	b7f9                	j	80004118 <fileclose+0x8e>

000000008000414c <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    8000414c:	715d                	addi	sp,sp,-80
    8000414e:	e486                	sd	ra,72(sp)
    80004150:	e0a2                	sd	s0,64(sp)
    80004152:	fc26                	sd	s1,56(sp)
    80004154:	f44e                	sd	s3,40(sp)
    80004156:	0880                	addi	s0,sp,80
    80004158:	84aa                	mv	s1,a0
    8000415a:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    8000415c:	f84fd0ef          	jal	800018e0 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004160:	409c                	lw	a5,0(s1)
    80004162:	37f9                	addiw	a5,a5,-2
    80004164:	4705                	li	a4,1
    80004166:	04f76063          	bltu	a4,a5,800041a6 <filestat+0x5a>
    8000416a:	f84a                	sd	s2,48(sp)
    8000416c:	892a                	mv	s2,a0
    ilock(f->ip);
    8000416e:	6c88                	ld	a0,24(s1)
    80004170:	a6aff0ef          	jal	800033da <ilock>
    stati(f->ip, &st);
    80004174:	fb840593          	addi	a1,s0,-72
    80004178:	6c88                	ld	a0,24(s1)
    8000417a:	c8aff0ef          	jal	80003604 <stati>
    iunlock(f->ip);
    8000417e:	6c88                	ld	a0,24(s1)
    80004180:	b08ff0ef          	jal	80003488 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004184:	46e1                	li	a3,24
    80004186:	fb840613          	addi	a2,s0,-72
    8000418a:	85ce                	mv	a1,s3
    8000418c:	05093503          	ld	a0,80(s2)
    80004190:	bc2fd0ef          	jal	80001552 <copyout>
    80004194:	41f5551b          	sraiw	a0,a0,0x1f
    80004198:	7942                	ld	s2,48(sp)
      return -1;
    return 0;
  }
  return -1;
}
    8000419a:	60a6                	ld	ra,72(sp)
    8000419c:	6406                	ld	s0,64(sp)
    8000419e:	74e2                	ld	s1,56(sp)
    800041a0:	79a2                	ld	s3,40(sp)
    800041a2:	6161                	addi	sp,sp,80
    800041a4:	8082                	ret
  return -1;
    800041a6:	557d                	li	a0,-1
    800041a8:	bfcd                	j	8000419a <filestat+0x4e>

00000000800041aa <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800041aa:	7179                	addi	sp,sp,-48
    800041ac:	f406                	sd	ra,40(sp)
    800041ae:	f022                	sd	s0,32(sp)
    800041b0:	e84a                	sd	s2,16(sp)
    800041b2:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800041b4:	00854783          	lbu	a5,8(a0)
    800041b8:	cfd1                	beqz	a5,80004254 <fileread+0xaa>
    800041ba:	ec26                	sd	s1,24(sp)
    800041bc:	e44e                	sd	s3,8(sp)
    800041be:	84aa                	mv	s1,a0
    800041c0:	89ae                	mv	s3,a1
    800041c2:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    800041c4:	411c                	lw	a5,0(a0)
    800041c6:	4705                	li	a4,1
    800041c8:	04e78363          	beq	a5,a4,8000420e <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800041cc:	470d                	li	a4,3
    800041ce:	04e78763          	beq	a5,a4,8000421c <fileread+0x72>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    800041d2:	4709                	li	a4,2
    800041d4:	06e79a63          	bne	a5,a4,80004248 <fileread+0x9e>
    ilock(f->ip);
    800041d8:	6d08                	ld	a0,24(a0)
    800041da:	a00ff0ef          	jal	800033da <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800041de:	874a                	mv	a4,s2
    800041e0:	5094                	lw	a3,32(s1)
    800041e2:	864e                	mv	a2,s3
    800041e4:	4585                	li	a1,1
    800041e6:	6c88                	ld	a0,24(s1)
    800041e8:	c46ff0ef          	jal	8000362e <readi>
    800041ec:	892a                	mv	s2,a0
    800041ee:	00a05563          	blez	a0,800041f8 <fileread+0x4e>
      f->off += r;
    800041f2:	509c                	lw	a5,32(s1)
    800041f4:	9fa9                	addw	a5,a5,a0
    800041f6:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800041f8:	6c88                	ld	a0,24(s1)
    800041fa:	a8eff0ef          	jal	80003488 <iunlock>
    800041fe:	64e2                	ld	s1,24(sp)
    80004200:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    80004202:	854a                	mv	a0,s2
    80004204:	70a2                	ld	ra,40(sp)
    80004206:	7402                	ld	s0,32(sp)
    80004208:	6942                	ld	s2,16(sp)
    8000420a:	6145                	addi	sp,sp,48
    8000420c:	8082                	ret
    r = piperead(f->pipe, addr, n);
    8000420e:	6908                	ld	a0,16(a0)
    80004210:	388000ef          	jal	80004598 <piperead>
    80004214:	892a                	mv	s2,a0
    80004216:	64e2                	ld	s1,24(sp)
    80004218:	69a2                	ld	s3,8(sp)
    8000421a:	b7e5                	j	80004202 <fileread+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    8000421c:	02451783          	lh	a5,36(a0)
    80004220:	03079693          	slli	a3,a5,0x30
    80004224:	92c1                	srli	a3,a3,0x30
    80004226:	4725                	li	a4,9
    80004228:	02d76863          	bltu	a4,a3,80004258 <fileread+0xae>
    8000422c:	0792                	slli	a5,a5,0x4
    8000422e:	00024717          	auipc	a4,0x24
    80004232:	14270713          	addi	a4,a4,322 # 80028370 <devsw>
    80004236:	97ba                	add	a5,a5,a4
    80004238:	639c                	ld	a5,0(a5)
    8000423a:	c39d                	beqz	a5,80004260 <fileread+0xb6>
    r = devsw[f->major].read(1, addr, n);
    8000423c:	4505                	li	a0,1
    8000423e:	9782                	jalr	a5
    80004240:	892a                	mv	s2,a0
    80004242:	64e2                	ld	s1,24(sp)
    80004244:	69a2                	ld	s3,8(sp)
    80004246:	bf75                	j	80004202 <fileread+0x58>
    panic("fileread");
    80004248:	00003517          	auipc	a0,0x3
    8000424c:	41850513          	addi	a0,a0,1048 # 80007660 <etext+0x660>
    80004250:	d44fc0ef          	jal	80000794 <panic>
    return -1;
    80004254:	597d                	li	s2,-1
    80004256:	b775                	j	80004202 <fileread+0x58>
      return -1;
    80004258:	597d                	li	s2,-1
    8000425a:	64e2                	ld	s1,24(sp)
    8000425c:	69a2                	ld	s3,8(sp)
    8000425e:	b755                	j	80004202 <fileread+0x58>
    80004260:	597d                	li	s2,-1
    80004262:	64e2                	ld	s1,24(sp)
    80004264:	69a2                	ld	s3,8(sp)
    80004266:	bf71                	j	80004202 <fileread+0x58>

0000000080004268 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80004268:	00954783          	lbu	a5,9(a0)
    8000426c:	10078b63          	beqz	a5,80004382 <filewrite+0x11a>
{
    80004270:	715d                	addi	sp,sp,-80
    80004272:	e486                	sd	ra,72(sp)
    80004274:	e0a2                	sd	s0,64(sp)
    80004276:	f84a                	sd	s2,48(sp)
    80004278:	f052                	sd	s4,32(sp)
    8000427a:	e85a                	sd	s6,16(sp)
    8000427c:	0880                	addi	s0,sp,80
    8000427e:	892a                	mv	s2,a0
    80004280:	8b2e                	mv	s6,a1
    80004282:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004284:	411c                	lw	a5,0(a0)
    80004286:	4705                	li	a4,1
    80004288:	02e78763          	beq	a5,a4,800042b6 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000428c:	470d                	li	a4,3
    8000428e:	02e78863          	beq	a5,a4,800042be <filewrite+0x56>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004292:	4709                	li	a4,2
    80004294:	0ce79c63          	bne	a5,a4,8000436c <filewrite+0x104>
    80004298:	f44e                	sd	s3,40(sp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    8000429a:	0ac05863          	blez	a2,8000434a <filewrite+0xe2>
    8000429e:	fc26                	sd	s1,56(sp)
    800042a0:	ec56                	sd	s5,24(sp)
    800042a2:	e45e                	sd	s7,8(sp)
    800042a4:	e062                	sd	s8,0(sp)
    int i = 0;
    800042a6:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    800042a8:	6b85                	lui	s7,0x1
    800042aa:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    800042ae:	6c05                	lui	s8,0x1
    800042b0:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    800042b4:	a8b5                	j	80004330 <filewrite+0xc8>
    ret = pipewrite(f->pipe, addr, n);
    800042b6:	6908                	ld	a0,16(a0)
    800042b8:	1fc000ef          	jal	800044b4 <pipewrite>
    800042bc:	a04d                	j	8000435e <filewrite+0xf6>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800042be:	02451783          	lh	a5,36(a0)
    800042c2:	03079693          	slli	a3,a5,0x30
    800042c6:	92c1                	srli	a3,a3,0x30
    800042c8:	4725                	li	a4,9
    800042ca:	0ad76e63          	bltu	a4,a3,80004386 <filewrite+0x11e>
    800042ce:	0792                	slli	a5,a5,0x4
    800042d0:	00024717          	auipc	a4,0x24
    800042d4:	0a070713          	addi	a4,a4,160 # 80028370 <devsw>
    800042d8:	97ba                	add	a5,a5,a4
    800042da:	679c                	ld	a5,8(a5)
    800042dc:	c7dd                	beqz	a5,8000438a <filewrite+0x122>
    ret = devsw[f->major].write(1, addr, n);
    800042de:	4505                	li	a0,1
    800042e0:	9782                	jalr	a5
    800042e2:	a8b5                	j	8000435e <filewrite+0xf6>
      if(n1 > max)
    800042e4:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    800042e8:	989ff0ef          	jal	80003c70 <begin_op>
      ilock(f->ip);
    800042ec:	01893503          	ld	a0,24(s2)
    800042f0:	8eaff0ef          	jal	800033da <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800042f4:	8756                	mv	a4,s5
    800042f6:	02092683          	lw	a3,32(s2)
    800042fa:	01698633          	add	a2,s3,s6
    800042fe:	4585                	li	a1,1
    80004300:	01893503          	ld	a0,24(s2)
    80004304:	c26ff0ef          	jal	8000372a <writei>
    80004308:	84aa                	mv	s1,a0
    8000430a:	00a05763          	blez	a0,80004318 <filewrite+0xb0>
        f->off += r;
    8000430e:	02092783          	lw	a5,32(s2)
    80004312:	9fa9                	addw	a5,a5,a0
    80004314:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004318:	01893503          	ld	a0,24(s2)
    8000431c:	96cff0ef          	jal	80003488 <iunlock>
      end_op();
    80004320:	9bbff0ef          	jal	80003cda <end_op>

      if(r != n1){
    80004324:	029a9563          	bne	s5,s1,8000434e <filewrite+0xe6>
        // error from writei
        break;
      }
      i += r;
    80004328:	013489bb          	addw	s3,s1,s3
    while(i < n){
    8000432c:	0149da63          	bge	s3,s4,80004340 <filewrite+0xd8>
      int n1 = n - i;
    80004330:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    80004334:	0004879b          	sext.w	a5,s1
    80004338:	fafbd6e3          	bge	s7,a5,800042e4 <filewrite+0x7c>
    8000433c:	84e2                	mv	s1,s8
    8000433e:	b75d                	j	800042e4 <filewrite+0x7c>
    80004340:	74e2                	ld	s1,56(sp)
    80004342:	6ae2                	ld	s5,24(sp)
    80004344:	6ba2                	ld	s7,8(sp)
    80004346:	6c02                	ld	s8,0(sp)
    80004348:	a039                	j	80004356 <filewrite+0xee>
    int i = 0;
    8000434a:	4981                	li	s3,0
    8000434c:	a029                	j	80004356 <filewrite+0xee>
    8000434e:	74e2                	ld	s1,56(sp)
    80004350:	6ae2                	ld	s5,24(sp)
    80004352:	6ba2                	ld	s7,8(sp)
    80004354:	6c02                	ld	s8,0(sp)
    }
    ret = (i == n ? n : -1);
    80004356:	033a1c63          	bne	s4,s3,8000438e <filewrite+0x126>
    8000435a:	8552                	mv	a0,s4
    8000435c:	79a2                	ld	s3,40(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    8000435e:	60a6                	ld	ra,72(sp)
    80004360:	6406                	ld	s0,64(sp)
    80004362:	7942                	ld	s2,48(sp)
    80004364:	7a02                	ld	s4,32(sp)
    80004366:	6b42                	ld	s6,16(sp)
    80004368:	6161                	addi	sp,sp,80
    8000436a:	8082                	ret
    8000436c:	fc26                	sd	s1,56(sp)
    8000436e:	f44e                	sd	s3,40(sp)
    80004370:	ec56                	sd	s5,24(sp)
    80004372:	e45e                	sd	s7,8(sp)
    80004374:	e062                	sd	s8,0(sp)
    panic("filewrite");
    80004376:	00003517          	auipc	a0,0x3
    8000437a:	2fa50513          	addi	a0,a0,762 # 80007670 <etext+0x670>
    8000437e:	c16fc0ef          	jal	80000794 <panic>
    return -1;
    80004382:	557d                	li	a0,-1
}
    80004384:	8082                	ret
      return -1;
    80004386:	557d                	li	a0,-1
    80004388:	bfd9                	j	8000435e <filewrite+0xf6>
    8000438a:	557d                	li	a0,-1
    8000438c:	bfc9                	j	8000435e <filewrite+0xf6>
    ret = (i == n ? n : -1);
    8000438e:	557d                	li	a0,-1
    80004390:	79a2                	ld	s3,40(sp)
    80004392:	b7f1                	j	8000435e <filewrite+0xf6>

0000000080004394 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004394:	7179                	addi	sp,sp,-48
    80004396:	f406                	sd	ra,40(sp)
    80004398:	f022                	sd	s0,32(sp)
    8000439a:	ec26                	sd	s1,24(sp)
    8000439c:	e052                	sd	s4,0(sp)
    8000439e:	1800                	addi	s0,sp,48
    800043a0:	84aa                	mv	s1,a0
    800043a2:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800043a4:	0005b023          	sd	zero,0(a1)
    800043a8:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800043ac:	c3bff0ef          	jal	80003fe6 <filealloc>
    800043b0:	e088                	sd	a0,0(s1)
    800043b2:	c549                	beqz	a0,8000443c <pipealloc+0xa8>
    800043b4:	c33ff0ef          	jal	80003fe6 <filealloc>
    800043b8:	00aa3023          	sd	a0,0(s4)
    800043bc:	cd25                	beqz	a0,80004434 <pipealloc+0xa0>
    800043be:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    800043c0:	f64fc0ef          	jal	80000b24 <kalloc>
    800043c4:	892a                	mv	s2,a0
    800043c6:	c12d                	beqz	a0,80004428 <pipealloc+0x94>
    800043c8:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    800043ca:	4985                	li	s3,1
    800043cc:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800043d0:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    800043d4:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    800043d8:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    800043dc:	00003597          	auipc	a1,0x3
    800043e0:	2a458593          	addi	a1,a1,676 # 80007680 <etext+0x680>
    800043e4:	f90fc0ef          	jal	80000b74 <initlock>
  (*f0)->type = FD_PIPE;
    800043e8:	609c                	ld	a5,0(s1)
    800043ea:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800043ee:	609c                	ld	a5,0(s1)
    800043f0:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800043f4:	609c                	ld	a5,0(s1)
    800043f6:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800043fa:	609c                	ld	a5,0(s1)
    800043fc:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004400:	000a3783          	ld	a5,0(s4)
    80004404:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004408:	000a3783          	ld	a5,0(s4)
    8000440c:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004410:	000a3783          	ld	a5,0(s4)
    80004414:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004418:	000a3783          	ld	a5,0(s4)
    8000441c:	0127b823          	sd	s2,16(a5)
  return 0;
    80004420:	4501                	li	a0,0
    80004422:	6942                	ld	s2,16(sp)
    80004424:	69a2                	ld	s3,8(sp)
    80004426:	a01d                	j	8000444c <pipealloc+0xb8>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004428:	6088                	ld	a0,0(s1)
    8000442a:	c119                	beqz	a0,80004430 <pipealloc+0x9c>
    8000442c:	6942                	ld	s2,16(sp)
    8000442e:	a029                	j	80004438 <pipealloc+0xa4>
    80004430:	6942                	ld	s2,16(sp)
    80004432:	a029                	j	8000443c <pipealloc+0xa8>
    80004434:	6088                	ld	a0,0(s1)
    80004436:	c10d                	beqz	a0,80004458 <pipealloc+0xc4>
    fileclose(*f0);
    80004438:	c53ff0ef          	jal	8000408a <fileclose>
  if(*f1)
    8000443c:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004440:	557d                	li	a0,-1
  if(*f1)
    80004442:	c789                	beqz	a5,8000444c <pipealloc+0xb8>
    fileclose(*f1);
    80004444:	853e                	mv	a0,a5
    80004446:	c45ff0ef          	jal	8000408a <fileclose>
  return -1;
    8000444a:	557d                	li	a0,-1
}
    8000444c:	70a2                	ld	ra,40(sp)
    8000444e:	7402                	ld	s0,32(sp)
    80004450:	64e2                	ld	s1,24(sp)
    80004452:	6a02                	ld	s4,0(sp)
    80004454:	6145                	addi	sp,sp,48
    80004456:	8082                	ret
  return -1;
    80004458:	557d                	li	a0,-1
    8000445a:	bfcd                	j	8000444c <pipealloc+0xb8>

000000008000445c <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    8000445c:	1101                	addi	sp,sp,-32
    8000445e:	ec06                	sd	ra,24(sp)
    80004460:	e822                	sd	s0,16(sp)
    80004462:	e426                	sd	s1,8(sp)
    80004464:	e04a                	sd	s2,0(sp)
    80004466:	1000                	addi	s0,sp,32
    80004468:	84aa                	mv	s1,a0
    8000446a:	892e                	mv	s2,a1
  acquire(&pi->lock);
    8000446c:	f88fc0ef          	jal	80000bf4 <acquire>
  if(writable){
    80004470:	02090763          	beqz	s2,8000449e <pipeclose+0x42>
    pi->writeopen = 0;
    80004474:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004478:	21848513          	addi	a0,s1,536
    8000447c:	a7ffd0ef          	jal	80001efa <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004480:	2204b783          	ld	a5,544(s1)
    80004484:	e785                	bnez	a5,800044ac <pipeclose+0x50>
    release(&pi->lock);
    80004486:	8526                	mv	a0,s1
    80004488:	805fc0ef          	jal	80000c8c <release>
    kfree((char*)pi);
    8000448c:	8526                	mv	a0,s1
    8000448e:	db4fc0ef          	jal	80000a42 <kfree>
  } else
    release(&pi->lock);
}
    80004492:	60e2                	ld	ra,24(sp)
    80004494:	6442                	ld	s0,16(sp)
    80004496:	64a2                	ld	s1,8(sp)
    80004498:	6902                	ld	s2,0(sp)
    8000449a:	6105                	addi	sp,sp,32
    8000449c:	8082                	ret
    pi->readopen = 0;
    8000449e:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    800044a2:	21c48513          	addi	a0,s1,540
    800044a6:	a55fd0ef          	jal	80001efa <wakeup>
    800044aa:	bfd9                	j	80004480 <pipeclose+0x24>
    release(&pi->lock);
    800044ac:	8526                	mv	a0,s1
    800044ae:	fdefc0ef          	jal	80000c8c <release>
}
    800044b2:	b7c5                	j	80004492 <pipeclose+0x36>

00000000800044b4 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800044b4:	711d                	addi	sp,sp,-96
    800044b6:	ec86                	sd	ra,88(sp)
    800044b8:	e8a2                	sd	s0,80(sp)
    800044ba:	e4a6                	sd	s1,72(sp)
    800044bc:	e0ca                	sd	s2,64(sp)
    800044be:	fc4e                	sd	s3,56(sp)
    800044c0:	f852                	sd	s4,48(sp)
    800044c2:	f456                	sd	s5,40(sp)
    800044c4:	1080                	addi	s0,sp,96
    800044c6:	84aa                	mv	s1,a0
    800044c8:	8aae                	mv	s5,a1
    800044ca:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    800044cc:	c14fd0ef          	jal	800018e0 <myproc>
    800044d0:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    800044d2:	8526                	mv	a0,s1
    800044d4:	f20fc0ef          	jal	80000bf4 <acquire>
  while(i < n){
    800044d8:	0b405a63          	blez	s4,8000458c <pipewrite+0xd8>
    800044dc:	f05a                	sd	s6,32(sp)
    800044de:	ec5e                	sd	s7,24(sp)
    800044e0:	e862                	sd	s8,16(sp)
  int i = 0;
    800044e2:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800044e4:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    800044e6:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    800044ea:	21c48b93          	addi	s7,s1,540
    800044ee:	a81d                	j	80004524 <pipewrite+0x70>
      release(&pi->lock);
    800044f0:	8526                	mv	a0,s1
    800044f2:	f9afc0ef          	jal	80000c8c <release>
      return -1;
    800044f6:	597d                	li	s2,-1
    800044f8:	7b02                	ld	s6,32(sp)
    800044fa:	6be2                	ld	s7,24(sp)
    800044fc:	6c42                	ld	s8,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    800044fe:	854a                	mv	a0,s2
    80004500:	60e6                	ld	ra,88(sp)
    80004502:	6446                	ld	s0,80(sp)
    80004504:	64a6                	ld	s1,72(sp)
    80004506:	6906                	ld	s2,64(sp)
    80004508:	79e2                	ld	s3,56(sp)
    8000450a:	7a42                	ld	s4,48(sp)
    8000450c:	7aa2                	ld	s5,40(sp)
    8000450e:	6125                	addi	sp,sp,96
    80004510:	8082                	ret
      wakeup(&pi->nread);
    80004512:	8562                	mv	a0,s8
    80004514:	9e7fd0ef          	jal	80001efa <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004518:	85a6                	mv	a1,s1
    8000451a:	855e                	mv	a0,s7
    8000451c:	993fd0ef          	jal	80001eae <sleep>
  while(i < n){
    80004520:	05495b63          	bge	s2,s4,80004576 <pipewrite+0xc2>
    if(pi->readopen == 0 || killed(pr)){
    80004524:	2204a783          	lw	a5,544(s1)
    80004528:	d7e1                	beqz	a5,800044f0 <pipewrite+0x3c>
    8000452a:	854e                	mv	a0,s3
    8000452c:	bbbfd0ef          	jal	800020e6 <killed>
    80004530:	f161                	bnez	a0,800044f0 <pipewrite+0x3c>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004532:	2184a783          	lw	a5,536(s1)
    80004536:	21c4a703          	lw	a4,540(s1)
    8000453a:	2007879b          	addiw	a5,a5,512
    8000453e:	fcf70ae3          	beq	a4,a5,80004512 <pipewrite+0x5e>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004542:	4685                	li	a3,1
    80004544:	01590633          	add	a2,s2,s5
    80004548:	faf40593          	addi	a1,s0,-81
    8000454c:	0509b503          	ld	a0,80(s3)
    80004550:	8d8fd0ef          	jal	80001628 <copyin>
    80004554:	03650e63          	beq	a0,s6,80004590 <pipewrite+0xdc>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004558:	21c4a783          	lw	a5,540(s1)
    8000455c:	0017871b          	addiw	a4,a5,1
    80004560:	20e4ae23          	sw	a4,540(s1)
    80004564:	1ff7f793          	andi	a5,a5,511
    80004568:	97a6                	add	a5,a5,s1
    8000456a:	faf44703          	lbu	a4,-81(s0)
    8000456e:	00e78c23          	sb	a4,24(a5)
      i++;
    80004572:	2905                	addiw	s2,s2,1
    80004574:	b775                	j	80004520 <pipewrite+0x6c>
    80004576:	7b02                	ld	s6,32(sp)
    80004578:	6be2                	ld	s7,24(sp)
    8000457a:	6c42                	ld	s8,16(sp)
  wakeup(&pi->nread);
    8000457c:	21848513          	addi	a0,s1,536
    80004580:	97bfd0ef          	jal	80001efa <wakeup>
  release(&pi->lock);
    80004584:	8526                	mv	a0,s1
    80004586:	f06fc0ef          	jal	80000c8c <release>
  return i;
    8000458a:	bf95                	j	800044fe <pipewrite+0x4a>
  int i = 0;
    8000458c:	4901                	li	s2,0
    8000458e:	b7fd                	j	8000457c <pipewrite+0xc8>
    80004590:	7b02                	ld	s6,32(sp)
    80004592:	6be2                	ld	s7,24(sp)
    80004594:	6c42                	ld	s8,16(sp)
    80004596:	b7dd                	j	8000457c <pipewrite+0xc8>

0000000080004598 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004598:	715d                	addi	sp,sp,-80
    8000459a:	e486                	sd	ra,72(sp)
    8000459c:	e0a2                	sd	s0,64(sp)
    8000459e:	fc26                	sd	s1,56(sp)
    800045a0:	f84a                	sd	s2,48(sp)
    800045a2:	f44e                	sd	s3,40(sp)
    800045a4:	f052                	sd	s4,32(sp)
    800045a6:	ec56                	sd	s5,24(sp)
    800045a8:	0880                	addi	s0,sp,80
    800045aa:	84aa                	mv	s1,a0
    800045ac:	892e                	mv	s2,a1
    800045ae:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    800045b0:	b30fd0ef          	jal	800018e0 <myproc>
    800045b4:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    800045b6:	8526                	mv	a0,s1
    800045b8:	e3cfc0ef          	jal	80000bf4 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800045bc:	2184a703          	lw	a4,536(s1)
    800045c0:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800045c4:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800045c8:	02f71563          	bne	a4,a5,800045f2 <piperead+0x5a>
    800045cc:	2244a783          	lw	a5,548(s1)
    800045d0:	cb85                	beqz	a5,80004600 <piperead+0x68>
    if(killed(pr)){
    800045d2:	8552                	mv	a0,s4
    800045d4:	b13fd0ef          	jal	800020e6 <killed>
    800045d8:	ed19                	bnez	a0,800045f6 <piperead+0x5e>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800045da:	85a6                	mv	a1,s1
    800045dc:	854e                	mv	a0,s3
    800045de:	8d1fd0ef          	jal	80001eae <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800045e2:	2184a703          	lw	a4,536(s1)
    800045e6:	21c4a783          	lw	a5,540(s1)
    800045ea:	fef701e3          	beq	a4,a5,800045cc <piperead+0x34>
    800045ee:	e85a                	sd	s6,16(sp)
    800045f0:	a809                	j	80004602 <piperead+0x6a>
    800045f2:	e85a                	sd	s6,16(sp)
    800045f4:	a039                	j	80004602 <piperead+0x6a>
      release(&pi->lock);
    800045f6:	8526                	mv	a0,s1
    800045f8:	e94fc0ef          	jal	80000c8c <release>
      return -1;
    800045fc:	59fd                	li	s3,-1
    800045fe:	a8b1                	j	8000465a <piperead+0xc2>
    80004600:	e85a                	sd	s6,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004602:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004604:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004606:	05505263          	blez	s5,8000464a <piperead+0xb2>
    if(pi->nread == pi->nwrite)
    8000460a:	2184a783          	lw	a5,536(s1)
    8000460e:	21c4a703          	lw	a4,540(s1)
    80004612:	02f70c63          	beq	a4,a5,8000464a <piperead+0xb2>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004616:	0017871b          	addiw	a4,a5,1
    8000461a:	20e4ac23          	sw	a4,536(s1)
    8000461e:	1ff7f793          	andi	a5,a5,511
    80004622:	97a6                	add	a5,a5,s1
    80004624:	0187c783          	lbu	a5,24(a5)
    80004628:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    8000462c:	4685                	li	a3,1
    8000462e:	fbf40613          	addi	a2,s0,-65
    80004632:	85ca                	mv	a1,s2
    80004634:	050a3503          	ld	a0,80(s4)
    80004638:	f1bfc0ef          	jal	80001552 <copyout>
    8000463c:	01650763          	beq	a0,s6,8000464a <piperead+0xb2>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004640:	2985                	addiw	s3,s3,1
    80004642:	0905                	addi	s2,s2,1
    80004644:	fd3a93e3          	bne	s5,s3,8000460a <piperead+0x72>
    80004648:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    8000464a:	21c48513          	addi	a0,s1,540
    8000464e:	8adfd0ef          	jal	80001efa <wakeup>
  release(&pi->lock);
    80004652:	8526                	mv	a0,s1
    80004654:	e38fc0ef          	jal	80000c8c <release>
    80004658:	6b42                	ld	s6,16(sp)
  return i;
}
    8000465a:	854e                	mv	a0,s3
    8000465c:	60a6                	ld	ra,72(sp)
    8000465e:	6406                	ld	s0,64(sp)
    80004660:	74e2                	ld	s1,56(sp)
    80004662:	7942                	ld	s2,48(sp)
    80004664:	79a2                	ld	s3,40(sp)
    80004666:	7a02                	ld	s4,32(sp)
    80004668:	6ae2                	ld	s5,24(sp)
    8000466a:	6161                	addi	sp,sp,80
    8000466c:	8082                	ret

000000008000466e <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    8000466e:	1141                	addi	sp,sp,-16
    80004670:	e422                	sd	s0,8(sp)
    80004672:	0800                	addi	s0,sp,16
    80004674:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004676:	8905                	andi	a0,a0,1
    80004678:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    8000467a:	8b89                	andi	a5,a5,2
    8000467c:	c399                	beqz	a5,80004682 <flags2perm+0x14>
      perm |= PTE_W;
    8000467e:	00456513          	ori	a0,a0,4
    return perm;
}
    80004682:	6422                	ld	s0,8(sp)
    80004684:	0141                	addi	sp,sp,16
    80004686:	8082                	ret

0000000080004688 <exec>:

int
exec(char *path, char **argv)
{
    80004688:	df010113          	addi	sp,sp,-528
    8000468c:	20113423          	sd	ra,520(sp)
    80004690:	20813023          	sd	s0,512(sp)
    80004694:	ffa6                	sd	s1,504(sp)
    80004696:	fbca                	sd	s2,496(sp)
    80004698:	0c00                	addi	s0,sp,528
    8000469a:	892a                	mv	s2,a0
    8000469c:	dea43c23          	sd	a0,-520(s0)
    800046a0:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    800046a4:	a3cfd0ef          	jal	800018e0 <myproc>
    800046a8:	84aa                	mv	s1,a0

  begin_op();
    800046aa:	dc6ff0ef          	jal	80003c70 <begin_op>

  if((ip = namei(path)) == 0){
    800046ae:	854a                	mv	a0,s2
    800046b0:	c04ff0ef          	jal	80003ab4 <namei>
    800046b4:	c931                	beqz	a0,80004708 <exec+0x80>
    800046b6:	f3d2                	sd	s4,480(sp)
    800046b8:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    800046ba:	d21fe0ef          	jal	800033da <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    800046be:	04000713          	li	a4,64
    800046c2:	4681                	li	a3,0
    800046c4:	e5040613          	addi	a2,s0,-432
    800046c8:	4581                	li	a1,0
    800046ca:	8552                	mv	a0,s4
    800046cc:	f63fe0ef          	jal	8000362e <readi>
    800046d0:	04000793          	li	a5,64
    800046d4:	00f51a63          	bne	a0,a5,800046e8 <exec+0x60>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    800046d8:	e5042703          	lw	a4,-432(s0)
    800046dc:	464c47b7          	lui	a5,0x464c4
    800046e0:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    800046e4:	02f70663          	beq	a4,a5,80004710 <exec+0x88>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    800046e8:	8552                	mv	a0,s4
    800046ea:	efbfe0ef          	jal	800035e4 <iunlockput>
    end_op();
    800046ee:	decff0ef          	jal	80003cda <end_op>
  }
  return -1;
    800046f2:	557d                	li	a0,-1
    800046f4:	7a1e                	ld	s4,480(sp)
}
    800046f6:	20813083          	ld	ra,520(sp)
    800046fa:	20013403          	ld	s0,512(sp)
    800046fe:	74fe                	ld	s1,504(sp)
    80004700:	795e                	ld	s2,496(sp)
    80004702:	21010113          	addi	sp,sp,528
    80004706:	8082                	ret
    end_op();
    80004708:	dd2ff0ef          	jal	80003cda <end_op>
    return -1;
    8000470c:	557d                	li	a0,-1
    8000470e:	b7e5                	j	800046f6 <exec+0x6e>
    80004710:	ebda                	sd	s6,464(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    80004712:	8526                	mv	a0,s1
    80004714:	a74fd0ef          	jal	80001988 <proc_pagetable>
    80004718:	8b2a                	mv	s6,a0
    8000471a:	2c050b63          	beqz	a0,800049f0 <exec+0x368>
    8000471e:	f7ce                	sd	s3,488(sp)
    80004720:	efd6                	sd	s5,472(sp)
    80004722:	e7de                	sd	s7,456(sp)
    80004724:	e3e2                	sd	s8,448(sp)
    80004726:	ff66                	sd	s9,440(sp)
    80004728:	fb6a                	sd	s10,432(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000472a:	e7042d03          	lw	s10,-400(s0)
    8000472e:	e8845783          	lhu	a5,-376(s0)
    80004732:	12078963          	beqz	a5,80004864 <exec+0x1dc>
    80004736:	f76e                	sd	s11,424(sp)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004738:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000473a:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    8000473c:	6c85                	lui	s9,0x1
    8000473e:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004742:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    80004746:	6a85                	lui	s5,0x1
    80004748:	a085                	j	800047a8 <exec+0x120>
      panic("loadseg: address should exist");
    8000474a:	00003517          	auipc	a0,0x3
    8000474e:	f3e50513          	addi	a0,a0,-194 # 80007688 <etext+0x688>
    80004752:	842fc0ef          	jal	80000794 <panic>
    if(sz - i < PGSIZE)
    80004756:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004758:	8726                	mv	a4,s1
    8000475a:	012c06bb          	addw	a3,s8,s2
    8000475e:	4581                	li	a1,0
    80004760:	8552                	mv	a0,s4
    80004762:	ecdfe0ef          	jal	8000362e <readi>
    80004766:	2501                	sext.w	a0,a0
    80004768:	24a49a63          	bne	s1,a0,800049bc <exec+0x334>
  for(i = 0; i < sz; i += PGSIZE){
    8000476c:	012a893b          	addw	s2,s5,s2
    80004770:	03397363          	bgeu	s2,s3,80004796 <exec+0x10e>
    pa = walkaddr(pagetable, va + i);
    80004774:	02091593          	slli	a1,s2,0x20
    80004778:	9181                	srli	a1,a1,0x20
    8000477a:	95de                	add	a1,a1,s7
    8000477c:	855a                	mv	a0,s6
    8000477e:	859fc0ef          	jal	80000fd6 <walkaddr>
    80004782:	862a                	mv	a2,a0
    if(pa == 0)
    80004784:	d179                	beqz	a0,8000474a <exec+0xc2>
    if(sz - i < PGSIZE)
    80004786:	412984bb          	subw	s1,s3,s2
    8000478a:	0004879b          	sext.w	a5,s1
    8000478e:	fcfcf4e3          	bgeu	s9,a5,80004756 <exec+0xce>
    80004792:	84d6                	mv	s1,s5
    80004794:	b7c9                	j	80004756 <exec+0xce>
    sz = sz1;
    80004796:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000479a:	2d85                	addiw	s11,s11,1
    8000479c:	038d0d1b          	addiw	s10,s10,56 # 1038 <_entry-0x7fffefc8>
    800047a0:	e8845783          	lhu	a5,-376(s0)
    800047a4:	08fdd063          	bge	s11,a5,80004824 <exec+0x19c>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800047a8:	2d01                	sext.w	s10,s10
    800047aa:	03800713          	li	a4,56
    800047ae:	86ea                	mv	a3,s10
    800047b0:	e1840613          	addi	a2,s0,-488
    800047b4:	4581                	li	a1,0
    800047b6:	8552                	mv	a0,s4
    800047b8:	e77fe0ef          	jal	8000362e <readi>
    800047bc:	03800793          	li	a5,56
    800047c0:	1cf51663          	bne	a0,a5,8000498c <exec+0x304>
    if(ph.type != ELF_PROG_LOAD)
    800047c4:	e1842783          	lw	a5,-488(s0)
    800047c8:	4705                	li	a4,1
    800047ca:	fce798e3          	bne	a5,a4,8000479a <exec+0x112>
    if(ph.memsz < ph.filesz)
    800047ce:	e4043483          	ld	s1,-448(s0)
    800047d2:	e3843783          	ld	a5,-456(s0)
    800047d6:	1af4ef63          	bltu	s1,a5,80004994 <exec+0x30c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    800047da:	e2843783          	ld	a5,-472(s0)
    800047de:	94be                	add	s1,s1,a5
    800047e0:	1af4ee63          	bltu	s1,a5,8000499c <exec+0x314>
    if(ph.vaddr % PGSIZE != 0)
    800047e4:	df043703          	ld	a4,-528(s0)
    800047e8:	8ff9                	and	a5,a5,a4
    800047ea:	1a079d63          	bnez	a5,800049a4 <exec+0x31c>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800047ee:	e1c42503          	lw	a0,-484(s0)
    800047f2:	e7dff0ef          	jal	8000466e <flags2perm>
    800047f6:	86aa                	mv	a3,a0
    800047f8:	8626                	mv	a2,s1
    800047fa:	85ca                	mv	a1,s2
    800047fc:	855a                	mv	a0,s6
    800047fe:	b41fc0ef          	jal	8000133e <uvmalloc>
    80004802:	e0a43423          	sd	a0,-504(s0)
    80004806:	1a050363          	beqz	a0,800049ac <exec+0x324>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    8000480a:	e2843b83          	ld	s7,-472(s0)
    8000480e:	e2042c03          	lw	s8,-480(s0)
    80004812:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004816:	00098463          	beqz	s3,8000481e <exec+0x196>
    8000481a:	4901                	li	s2,0
    8000481c:	bfa1                	j	80004774 <exec+0xec>
    sz = sz1;
    8000481e:	e0843903          	ld	s2,-504(s0)
    80004822:	bfa5                	j	8000479a <exec+0x112>
    80004824:	7dba                	ld	s11,424(sp)
  iunlockput(ip);
    80004826:	8552                	mv	a0,s4
    80004828:	dbdfe0ef          	jal	800035e4 <iunlockput>
  end_op();
    8000482c:	caeff0ef          	jal	80003cda <end_op>
  p = myproc();
    80004830:	8b0fd0ef          	jal	800018e0 <myproc>
    80004834:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80004836:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    8000483a:	6985                	lui	s3,0x1
    8000483c:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    8000483e:	99ca                	add	s3,s3,s2
    80004840:	77fd                	lui	a5,0xfffff
    80004842:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80004846:	4691                	li	a3,4
    80004848:	6609                	lui	a2,0x2
    8000484a:	964e                	add	a2,a2,s3
    8000484c:	85ce                	mv	a1,s3
    8000484e:	855a                	mv	a0,s6
    80004850:	aeffc0ef          	jal	8000133e <uvmalloc>
    80004854:	892a                	mv	s2,a0
    80004856:	e0a43423          	sd	a0,-504(s0)
    8000485a:	e519                	bnez	a0,80004868 <exec+0x1e0>
  if(pagetable)
    8000485c:	e1343423          	sd	s3,-504(s0)
    80004860:	4a01                	li	s4,0
    80004862:	aab1                	j	800049be <exec+0x336>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004864:	4901                	li	s2,0
    80004866:	b7c1                	j	80004826 <exec+0x19e>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    80004868:	75f9                	lui	a1,0xffffe
    8000486a:	95aa                	add	a1,a1,a0
    8000486c:	855a                	mv	a0,s6
    8000486e:	cbbfc0ef          	jal	80001528 <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    80004872:	7bfd                	lui	s7,0xfffff
    80004874:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    80004876:	e0043783          	ld	a5,-512(s0)
    8000487a:	6388                	ld	a0,0(a5)
    8000487c:	cd39                	beqz	a0,800048da <exec+0x252>
    8000487e:	e9040993          	addi	s3,s0,-368
    80004882:	f9040c13          	addi	s8,s0,-112
    80004886:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004888:	db0fc0ef          	jal	80000e38 <strlen>
    8000488c:	0015079b          	addiw	a5,a0,1
    80004890:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004894:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80004898:	11796e63          	bltu	s2,s7,800049b4 <exec+0x32c>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    8000489c:	e0043d03          	ld	s10,-512(s0)
    800048a0:	000d3a03          	ld	s4,0(s10)
    800048a4:	8552                	mv	a0,s4
    800048a6:	d92fc0ef          	jal	80000e38 <strlen>
    800048aa:	0015069b          	addiw	a3,a0,1
    800048ae:	8652                	mv	a2,s4
    800048b0:	85ca                	mv	a1,s2
    800048b2:	855a                	mv	a0,s6
    800048b4:	c9ffc0ef          	jal	80001552 <copyout>
    800048b8:	10054063          	bltz	a0,800049b8 <exec+0x330>
    ustack[argc] = sp;
    800048bc:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    800048c0:	0485                	addi	s1,s1,1
    800048c2:	008d0793          	addi	a5,s10,8
    800048c6:	e0f43023          	sd	a5,-512(s0)
    800048ca:	008d3503          	ld	a0,8(s10)
    800048ce:	c909                	beqz	a0,800048e0 <exec+0x258>
    if(argc >= MAXARG)
    800048d0:	09a1                	addi	s3,s3,8
    800048d2:	fb899be3          	bne	s3,s8,80004888 <exec+0x200>
  ip = 0;
    800048d6:	4a01                	li	s4,0
    800048d8:	a0dd                	j	800049be <exec+0x336>
  sp = sz;
    800048da:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    800048de:	4481                	li	s1,0
  ustack[argc] = 0;
    800048e0:	00349793          	slli	a5,s1,0x3
    800048e4:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffd5a88>
    800048e8:	97a2                	add	a5,a5,s0
    800048ea:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    800048ee:	00148693          	addi	a3,s1,1
    800048f2:	068e                	slli	a3,a3,0x3
    800048f4:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    800048f8:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    800048fc:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    80004900:	f5796ee3          	bltu	s2,s7,8000485c <exec+0x1d4>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004904:	e9040613          	addi	a2,s0,-368
    80004908:	85ca                	mv	a1,s2
    8000490a:	855a                	mv	a0,s6
    8000490c:	c47fc0ef          	jal	80001552 <copyout>
    80004910:	0e054263          	bltz	a0,800049f4 <exec+0x36c>
  p->trapframe->a1 = sp;
    80004914:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    80004918:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    8000491c:	df843783          	ld	a5,-520(s0)
    80004920:	0007c703          	lbu	a4,0(a5)
    80004924:	cf11                	beqz	a4,80004940 <exec+0x2b8>
    80004926:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004928:	02f00693          	li	a3,47
    8000492c:	a039                	j	8000493a <exec+0x2b2>
      last = s+1;
    8000492e:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    80004932:	0785                	addi	a5,a5,1
    80004934:	fff7c703          	lbu	a4,-1(a5)
    80004938:	c701                	beqz	a4,80004940 <exec+0x2b8>
    if(*s == '/')
    8000493a:	fed71ce3          	bne	a4,a3,80004932 <exec+0x2aa>
    8000493e:	bfc5                	j	8000492e <exec+0x2a6>
  safestrcpy(p->name, last, sizeof(p->name));
    80004940:	4641                	li	a2,16
    80004942:	df843583          	ld	a1,-520(s0)
    80004946:	158a8513          	addi	a0,s5,344
    8000494a:	cbcfc0ef          	jal	80000e06 <safestrcpy>
  oldpagetable = p->pagetable;
    8000494e:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80004952:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    80004956:	e0843783          	ld	a5,-504(s0)
    8000495a:	04fab423          	sd	a5,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    8000495e:	058ab783          	ld	a5,88(s5)
    80004962:	e6843703          	ld	a4,-408(s0)
    80004966:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004968:	058ab783          	ld	a5,88(s5)
    8000496c:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004970:	85e6                	mv	a1,s9
    80004972:	89afd0ef          	jal	80001a0c <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004976:	0004851b          	sext.w	a0,s1
    8000497a:	79be                	ld	s3,488(sp)
    8000497c:	7a1e                	ld	s4,480(sp)
    8000497e:	6afe                	ld	s5,472(sp)
    80004980:	6b5e                	ld	s6,464(sp)
    80004982:	6bbe                	ld	s7,456(sp)
    80004984:	6c1e                	ld	s8,448(sp)
    80004986:	7cfa                	ld	s9,440(sp)
    80004988:	7d5a                	ld	s10,432(sp)
    8000498a:	b3b5                	j	800046f6 <exec+0x6e>
    8000498c:	e1243423          	sd	s2,-504(s0)
    80004990:	7dba                	ld	s11,424(sp)
    80004992:	a035                	j	800049be <exec+0x336>
    80004994:	e1243423          	sd	s2,-504(s0)
    80004998:	7dba                	ld	s11,424(sp)
    8000499a:	a015                	j	800049be <exec+0x336>
    8000499c:	e1243423          	sd	s2,-504(s0)
    800049a0:	7dba                	ld	s11,424(sp)
    800049a2:	a831                	j	800049be <exec+0x336>
    800049a4:	e1243423          	sd	s2,-504(s0)
    800049a8:	7dba                	ld	s11,424(sp)
    800049aa:	a811                	j	800049be <exec+0x336>
    800049ac:	e1243423          	sd	s2,-504(s0)
    800049b0:	7dba                	ld	s11,424(sp)
    800049b2:	a031                	j	800049be <exec+0x336>
  ip = 0;
    800049b4:	4a01                	li	s4,0
    800049b6:	a021                	j	800049be <exec+0x336>
    800049b8:	4a01                	li	s4,0
  if(pagetable)
    800049ba:	a011                	j	800049be <exec+0x336>
    800049bc:	7dba                	ld	s11,424(sp)
    proc_freepagetable(pagetable, sz);
    800049be:	e0843583          	ld	a1,-504(s0)
    800049c2:	855a                	mv	a0,s6
    800049c4:	848fd0ef          	jal	80001a0c <proc_freepagetable>
  return -1;
    800049c8:	557d                	li	a0,-1
  if(ip){
    800049ca:	000a1b63          	bnez	s4,800049e0 <exec+0x358>
    800049ce:	79be                	ld	s3,488(sp)
    800049d0:	7a1e                	ld	s4,480(sp)
    800049d2:	6afe                	ld	s5,472(sp)
    800049d4:	6b5e                	ld	s6,464(sp)
    800049d6:	6bbe                	ld	s7,456(sp)
    800049d8:	6c1e                	ld	s8,448(sp)
    800049da:	7cfa                	ld	s9,440(sp)
    800049dc:	7d5a                	ld	s10,432(sp)
    800049de:	bb21                	j	800046f6 <exec+0x6e>
    800049e0:	79be                	ld	s3,488(sp)
    800049e2:	6afe                	ld	s5,472(sp)
    800049e4:	6b5e                	ld	s6,464(sp)
    800049e6:	6bbe                	ld	s7,456(sp)
    800049e8:	6c1e                	ld	s8,448(sp)
    800049ea:	7cfa                	ld	s9,440(sp)
    800049ec:	7d5a                	ld	s10,432(sp)
    800049ee:	b9ed                	j	800046e8 <exec+0x60>
    800049f0:	6b5e                	ld	s6,464(sp)
    800049f2:	b9dd                	j	800046e8 <exec+0x60>
  sz = sz1;
    800049f4:	e0843983          	ld	s3,-504(s0)
    800049f8:	b595                	j	8000485c <exec+0x1d4>

00000000800049fa <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    800049fa:	7179                	addi	sp,sp,-48
    800049fc:	f406                	sd	ra,40(sp)
    800049fe:	f022                	sd	s0,32(sp)
    80004a00:	ec26                	sd	s1,24(sp)
    80004a02:	e84a                	sd	s2,16(sp)
    80004a04:	1800                	addi	s0,sp,48
    80004a06:	892e                	mv	s2,a1
    80004a08:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004a0a:	fdc40593          	addi	a1,s0,-36
    80004a0e:	f6bfd0ef          	jal	80002978 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004a12:	fdc42703          	lw	a4,-36(s0)
    80004a16:	47bd                	li	a5,15
    80004a18:	02e7e963          	bltu	a5,a4,80004a4a <argfd+0x50>
    80004a1c:	ec5fc0ef          	jal	800018e0 <myproc>
    80004a20:	fdc42703          	lw	a4,-36(s0)
    80004a24:	01a70793          	addi	a5,a4,26
    80004a28:	078e                	slli	a5,a5,0x3
    80004a2a:	953e                	add	a0,a0,a5
    80004a2c:	611c                	ld	a5,0(a0)
    80004a2e:	c385                	beqz	a5,80004a4e <argfd+0x54>
    return -1;
  if(pfd)
    80004a30:	00090463          	beqz	s2,80004a38 <argfd+0x3e>
    *pfd = fd;
    80004a34:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004a38:	4501                	li	a0,0
  if(pf)
    80004a3a:	c091                	beqz	s1,80004a3e <argfd+0x44>
    *pf = f;
    80004a3c:	e09c                	sd	a5,0(s1)
}
    80004a3e:	70a2                	ld	ra,40(sp)
    80004a40:	7402                	ld	s0,32(sp)
    80004a42:	64e2                	ld	s1,24(sp)
    80004a44:	6942                	ld	s2,16(sp)
    80004a46:	6145                	addi	sp,sp,48
    80004a48:	8082                	ret
    return -1;
    80004a4a:	557d                	li	a0,-1
    80004a4c:	bfcd                	j	80004a3e <argfd+0x44>
    80004a4e:	557d                	li	a0,-1
    80004a50:	b7fd                	j	80004a3e <argfd+0x44>

0000000080004a52 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004a52:	1101                	addi	sp,sp,-32
    80004a54:	ec06                	sd	ra,24(sp)
    80004a56:	e822                	sd	s0,16(sp)
    80004a58:	e426                	sd	s1,8(sp)
    80004a5a:	1000                	addi	s0,sp,32
    80004a5c:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004a5e:	e83fc0ef          	jal	800018e0 <myproc>
    80004a62:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80004a64:	0d050793          	addi	a5,a0,208
    80004a68:	4501                	li	a0,0
    80004a6a:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80004a6c:	6398                	ld	a4,0(a5)
    80004a6e:	cb19                	beqz	a4,80004a84 <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    80004a70:	2505                	addiw	a0,a0,1
    80004a72:	07a1                	addi	a5,a5,8
    80004a74:	fed51ce3          	bne	a0,a3,80004a6c <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004a78:	557d                	li	a0,-1
}
    80004a7a:	60e2                	ld	ra,24(sp)
    80004a7c:	6442                	ld	s0,16(sp)
    80004a7e:	64a2                	ld	s1,8(sp)
    80004a80:	6105                	addi	sp,sp,32
    80004a82:	8082                	ret
      p->ofile[fd] = f;
    80004a84:	01a50793          	addi	a5,a0,26
    80004a88:	078e                	slli	a5,a5,0x3
    80004a8a:	963e                	add	a2,a2,a5
    80004a8c:	e204                	sd	s1,0(a2)
      return fd;
    80004a8e:	b7f5                	j	80004a7a <fdalloc+0x28>

0000000080004a90 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80004a90:	715d                	addi	sp,sp,-80
    80004a92:	e486                	sd	ra,72(sp)
    80004a94:	e0a2                	sd	s0,64(sp)
    80004a96:	fc26                	sd	s1,56(sp)
    80004a98:	f84a                	sd	s2,48(sp)
    80004a9a:	f44e                	sd	s3,40(sp)
    80004a9c:	ec56                	sd	s5,24(sp)
    80004a9e:	e85a                	sd	s6,16(sp)
    80004aa0:	0880                	addi	s0,sp,80
    80004aa2:	8b2e                	mv	s6,a1
    80004aa4:	89b2                	mv	s3,a2
    80004aa6:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80004aa8:	fb040593          	addi	a1,s0,-80
    80004aac:	822ff0ef          	jal	80003ace <nameiparent>
    80004ab0:	84aa                	mv	s1,a0
    80004ab2:	10050a63          	beqz	a0,80004bc6 <create+0x136>
    return 0;

  ilock(dp);
    80004ab6:	925fe0ef          	jal	800033da <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80004aba:	4601                	li	a2,0
    80004abc:	fb040593          	addi	a1,s0,-80
    80004ac0:	8526                	mv	a0,s1
    80004ac2:	d8dfe0ef          	jal	8000384e <dirlookup>
    80004ac6:	8aaa                	mv	s5,a0
    80004ac8:	c129                	beqz	a0,80004b0a <create+0x7a>
    iunlockput(dp);
    80004aca:	8526                	mv	a0,s1
    80004acc:	b19fe0ef          	jal	800035e4 <iunlockput>
    ilock(ip);
    80004ad0:	8556                	mv	a0,s5
    80004ad2:	909fe0ef          	jal	800033da <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004ad6:	4789                	li	a5,2
    80004ad8:	02fb1463          	bne	s6,a5,80004b00 <create+0x70>
    80004adc:	044ad783          	lhu	a5,68(s5)
    80004ae0:	37f9                	addiw	a5,a5,-2
    80004ae2:	17c2                	slli	a5,a5,0x30
    80004ae4:	93c1                	srli	a5,a5,0x30
    80004ae6:	4705                	li	a4,1
    80004ae8:	00f76c63          	bltu	a4,a5,80004b00 <create+0x70>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80004aec:	8556                	mv	a0,s5
    80004aee:	60a6                	ld	ra,72(sp)
    80004af0:	6406                	ld	s0,64(sp)
    80004af2:	74e2                	ld	s1,56(sp)
    80004af4:	7942                	ld	s2,48(sp)
    80004af6:	79a2                	ld	s3,40(sp)
    80004af8:	6ae2                	ld	s5,24(sp)
    80004afa:	6b42                	ld	s6,16(sp)
    80004afc:	6161                	addi	sp,sp,80
    80004afe:	8082                	ret
    iunlockput(ip);
    80004b00:	8556                	mv	a0,s5
    80004b02:	ae3fe0ef          	jal	800035e4 <iunlockput>
    return 0;
    80004b06:	4a81                	li	s5,0
    80004b08:	b7d5                	j	80004aec <create+0x5c>
    80004b0a:	f052                	sd	s4,32(sp)
  if((ip = ialloc(dp->dev, type)) == 0){
    80004b0c:	85da                	mv	a1,s6
    80004b0e:	4088                	lw	a0,0(s1)
    80004b10:	f5afe0ef          	jal	8000326a <ialloc>
    80004b14:	8a2a                	mv	s4,a0
    80004b16:	cd15                	beqz	a0,80004b52 <create+0xc2>
  ilock(ip);
    80004b18:	8c3fe0ef          	jal	800033da <ilock>
  ip->major = major;
    80004b1c:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80004b20:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80004b24:	4905                	li	s2,1
    80004b26:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80004b2a:	8552                	mv	a0,s4
    80004b2c:	ffafe0ef          	jal	80003326 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80004b30:	032b0763          	beq	s6,s2,80004b5e <create+0xce>
  if(dirlink(dp, name, ip->inum) < 0)
    80004b34:	004a2603          	lw	a2,4(s4)
    80004b38:	fb040593          	addi	a1,s0,-80
    80004b3c:	8526                	mv	a0,s1
    80004b3e:	eddfe0ef          	jal	80003a1a <dirlink>
    80004b42:	06054563          	bltz	a0,80004bac <create+0x11c>
  iunlockput(dp);
    80004b46:	8526                	mv	a0,s1
    80004b48:	a9dfe0ef          	jal	800035e4 <iunlockput>
  return ip;
    80004b4c:	8ad2                	mv	s5,s4
    80004b4e:	7a02                	ld	s4,32(sp)
    80004b50:	bf71                	j	80004aec <create+0x5c>
    iunlockput(dp);
    80004b52:	8526                	mv	a0,s1
    80004b54:	a91fe0ef          	jal	800035e4 <iunlockput>
    return 0;
    80004b58:	8ad2                	mv	s5,s4
    80004b5a:	7a02                	ld	s4,32(sp)
    80004b5c:	bf41                	j	80004aec <create+0x5c>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80004b5e:	004a2603          	lw	a2,4(s4)
    80004b62:	00003597          	auipc	a1,0x3
    80004b66:	b4658593          	addi	a1,a1,-1210 # 800076a8 <etext+0x6a8>
    80004b6a:	8552                	mv	a0,s4
    80004b6c:	eaffe0ef          	jal	80003a1a <dirlink>
    80004b70:	02054e63          	bltz	a0,80004bac <create+0x11c>
    80004b74:	40d0                	lw	a2,4(s1)
    80004b76:	00003597          	auipc	a1,0x3
    80004b7a:	b3a58593          	addi	a1,a1,-1222 # 800076b0 <etext+0x6b0>
    80004b7e:	8552                	mv	a0,s4
    80004b80:	e9bfe0ef          	jal	80003a1a <dirlink>
    80004b84:	02054463          	bltz	a0,80004bac <create+0x11c>
  if(dirlink(dp, name, ip->inum) < 0)
    80004b88:	004a2603          	lw	a2,4(s4)
    80004b8c:	fb040593          	addi	a1,s0,-80
    80004b90:	8526                	mv	a0,s1
    80004b92:	e89fe0ef          	jal	80003a1a <dirlink>
    80004b96:	00054b63          	bltz	a0,80004bac <create+0x11c>
    dp->nlink++;  // for ".."
    80004b9a:	04a4d783          	lhu	a5,74(s1)
    80004b9e:	2785                	addiw	a5,a5,1
    80004ba0:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004ba4:	8526                	mv	a0,s1
    80004ba6:	f80fe0ef          	jal	80003326 <iupdate>
    80004baa:	bf71                	j	80004b46 <create+0xb6>
  ip->nlink = 0;
    80004bac:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80004bb0:	8552                	mv	a0,s4
    80004bb2:	f74fe0ef          	jal	80003326 <iupdate>
  iunlockput(ip);
    80004bb6:	8552                	mv	a0,s4
    80004bb8:	a2dfe0ef          	jal	800035e4 <iunlockput>
  iunlockput(dp);
    80004bbc:	8526                	mv	a0,s1
    80004bbe:	a27fe0ef          	jal	800035e4 <iunlockput>
  return 0;
    80004bc2:	7a02                	ld	s4,32(sp)
    80004bc4:	b725                	j	80004aec <create+0x5c>
    return 0;
    80004bc6:	8aaa                	mv	s5,a0
    80004bc8:	b715                	j	80004aec <create+0x5c>

0000000080004bca <sys_dup>:
{
    80004bca:	7179                	addi	sp,sp,-48
    80004bcc:	f406                	sd	ra,40(sp)
    80004bce:	f022                	sd	s0,32(sp)
    80004bd0:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80004bd2:	fd840613          	addi	a2,s0,-40
    80004bd6:	4581                	li	a1,0
    80004bd8:	4501                	li	a0,0
    80004bda:	e21ff0ef          	jal	800049fa <argfd>
    return -1;
    80004bde:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80004be0:	02054363          	bltz	a0,80004c06 <sys_dup+0x3c>
    80004be4:	ec26                	sd	s1,24(sp)
    80004be6:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    80004be8:	fd843903          	ld	s2,-40(s0)
    80004bec:	854a                	mv	a0,s2
    80004bee:	e65ff0ef          	jal	80004a52 <fdalloc>
    80004bf2:	84aa                	mv	s1,a0
    return -1;
    80004bf4:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80004bf6:	00054d63          	bltz	a0,80004c10 <sys_dup+0x46>
  filedup(f);
    80004bfa:	854a                	mv	a0,s2
    80004bfc:	c48ff0ef          	jal	80004044 <filedup>
  return fd;
    80004c00:	87a6                	mv	a5,s1
    80004c02:	64e2                	ld	s1,24(sp)
    80004c04:	6942                	ld	s2,16(sp)
}
    80004c06:	853e                	mv	a0,a5
    80004c08:	70a2                	ld	ra,40(sp)
    80004c0a:	7402                	ld	s0,32(sp)
    80004c0c:	6145                	addi	sp,sp,48
    80004c0e:	8082                	ret
    80004c10:	64e2                	ld	s1,24(sp)
    80004c12:	6942                	ld	s2,16(sp)
    80004c14:	bfcd                	j	80004c06 <sys_dup+0x3c>

0000000080004c16 <sys_read>:
{
    80004c16:	7179                	addi	sp,sp,-48
    80004c18:	f406                	sd	ra,40(sp)
    80004c1a:	f022                	sd	s0,32(sp)
    80004c1c:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004c1e:	fd840593          	addi	a1,s0,-40
    80004c22:	4505                	li	a0,1
    80004c24:	d71fd0ef          	jal	80002994 <argaddr>
  argint(2, &n);
    80004c28:	fe440593          	addi	a1,s0,-28
    80004c2c:	4509                	li	a0,2
    80004c2e:	d4bfd0ef          	jal	80002978 <argint>
  if(argfd(0, 0, &f) < 0)
    80004c32:	fe840613          	addi	a2,s0,-24
    80004c36:	4581                	li	a1,0
    80004c38:	4501                	li	a0,0
    80004c3a:	dc1ff0ef          	jal	800049fa <argfd>
    80004c3e:	87aa                	mv	a5,a0
    return -1;
    80004c40:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004c42:	0007ca63          	bltz	a5,80004c56 <sys_read+0x40>
  return fileread(f, p, n);
    80004c46:	fe442603          	lw	a2,-28(s0)
    80004c4a:	fd843583          	ld	a1,-40(s0)
    80004c4e:	fe843503          	ld	a0,-24(s0)
    80004c52:	d58ff0ef          	jal	800041aa <fileread>
}
    80004c56:	70a2                	ld	ra,40(sp)
    80004c58:	7402                	ld	s0,32(sp)
    80004c5a:	6145                	addi	sp,sp,48
    80004c5c:	8082                	ret

0000000080004c5e <sys_write>:
{
    80004c5e:	7179                	addi	sp,sp,-48
    80004c60:	f406                	sd	ra,40(sp)
    80004c62:	f022                	sd	s0,32(sp)
    80004c64:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004c66:	fd840593          	addi	a1,s0,-40
    80004c6a:	4505                	li	a0,1
    80004c6c:	d29fd0ef          	jal	80002994 <argaddr>
  argint(2, &n);
    80004c70:	fe440593          	addi	a1,s0,-28
    80004c74:	4509                	li	a0,2
    80004c76:	d03fd0ef          	jal	80002978 <argint>
  if(argfd(0, 0, &f) < 0)
    80004c7a:	fe840613          	addi	a2,s0,-24
    80004c7e:	4581                	li	a1,0
    80004c80:	4501                	li	a0,0
    80004c82:	d79ff0ef          	jal	800049fa <argfd>
    80004c86:	87aa                	mv	a5,a0
    return -1;
    80004c88:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004c8a:	0007ca63          	bltz	a5,80004c9e <sys_write+0x40>
  return filewrite(f, p, n);
    80004c8e:	fe442603          	lw	a2,-28(s0)
    80004c92:	fd843583          	ld	a1,-40(s0)
    80004c96:	fe843503          	ld	a0,-24(s0)
    80004c9a:	dceff0ef          	jal	80004268 <filewrite>
}
    80004c9e:	70a2                	ld	ra,40(sp)
    80004ca0:	7402                	ld	s0,32(sp)
    80004ca2:	6145                	addi	sp,sp,48
    80004ca4:	8082                	ret

0000000080004ca6 <sys_close>:
{
    80004ca6:	1101                	addi	sp,sp,-32
    80004ca8:	ec06                	sd	ra,24(sp)
    80004caa:	e822                	sd	s0,16(sp)
    80004cac:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80004cae:	fe040613          	addi	a2,s0,-32
    80004cb2:	fec40593          	addi	a1,s0,-20
    80004cb6:	4501                	li	a0,0
    80004cb8:	d43ff0ef          	jal	800049fa <argfd>
    return -1;
    80004cbc:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80004cbe:	02054063          	bltz	a0,80004cde <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    80004cc2:	c1ffc0ef          	jal	800018e0 <myproc>
    80004cc6:	fec42783          	lw	a5,-20(s0)
    80004cca:	07e9                	addi	a5,a5,26
    80004ccc:	078e                	slli	a5,a5,0x3
    80004cce:	953e                	add	a0,a0,a5
    80004cd0:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80004cd4:	fe043503          	ld	a0,-32(s0)
    80004cd8:	bb2ff0ef          	jal	8000408a <fileclose>
  return 0;
    80004cdc:	4781                	li	a5,0
}
    80004cde:	853e                	mv	a0,a5
    80004ce0:	60e2                	ld	ra,24(sp)
    80004ce2:	6442                	ld	s0,16(sp)
    80004ce4:	6105                	addi	sp,sp,32
    80004ce6:	8082                	ret

0000000080004ce8 <sys_fstat>:
{
    80004ce8:	1101                	addi	sp,sp,-32
    80004cea:	ec06                	sd	ra,24(sp)
    80004cec:	e822                	sd	s0,16(sp)
    80004cee:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80004cf0:	fe040593          	addi	a1,s0,-32
    80004cf4:	4505                	li	a0,1
    80004cf6:	c9ffd0ef          	jal	80002994 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80004cfa:	fe840613          	addi	a2,s0,-24
    80004cfe:	4581                	li	a1,0
    80004d00:	4501                	li	a0,0
    80004d02:	cf9ff0ef          	jal	800049fa <argfd>
    80004d06:	87aa                	mv	a5,a0
    return -1;
    80004d08:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004d0a:	0007c863          	bltz	a5,80004d1a <sys_fstat+0x32>
  return filestat(f, st);
    80004d0e:	fe043583          	ld	a1,-32(s0)
    80004d12:	fe843503          	ld	a0,-24(s0)
    80004d16:	c36ff0ef          	jal	8000414c <filestat>
}
    80004d1a:	60e2                	ld	ra,24(sp)
    80004d1c:	6442                	ld	s0,16(sp)
    80004d1e:	6105                	addi	sp,sp,32
    80004d20:	8082                	ret

0000000080004d22 <sys_link>:
{
    80004d22:	7169                	addi	sp,sp,-304
    80004d24:	f606                	sd	ra,296(sp)
    80004d26:	f222                	sd	s0,288(sp)
    80004d28:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004d2a:	08000613          	li	a2,128
    80004d2e:	ed040593          	addi	a1,s0,-304
    80004d32:	4501                	li	a0,0
    80004d34:	c7dfd0ef          	jal	800029b0 <argstr>
    return -1;
    80004d38:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004d3a:	0c054e63          	bltz	a0,80004e16 <sys_link+0xf4>
    80004d3e:	08000613          	li	a2,128
    80004d42:	f5040593          	addi	a1,s0,-176
    80004d46:	4505                	li	a0,1
    80004d48:	c69fd0ef          	jal	800029b0 <argstr>
    return -1;
    80004d4c:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004d4e:	0c054463          	bltz	a0,80004e16 <sys_link+0xf4>
    80004d52:	ee26                	sd	s1,280(sp)
  begin_op();
    80004d54:	f1dfe0ef          	jal	80003c70 <begin_op>
  if((ip = namei(old)) == 0){
    80004d58:	ed040513          	addi	a0,s0,-304
    80004d5c:	d59fe0ef          	jal	80003ab4 <namei>
    80004d60:	84aa                	mv	s1,a0
    80004d62:	c53d                	beqz	a0,80004dd0 <sys_link+0xae>
  ilock(ip);
    80004d64:	e76fe0ef          	jal	800033da <ilock>
  if(ip->type == T_DIR){
    80004d68:	04449703          	lh	a4,68(s1)
    80004d6c:	4785                	li	a5,1
    80004d6e:	06f70663          	beq	a4,a5,80004dda <sys_link+0xb8>
    80004d72:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80004d74:	04a4d783          	lhu	a5,74(s1)
    80004d78:	2785                	addiw	a5,a5,1
    80004d7a:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004d7e:	8526                	mv	a0,s1
    80004d80:	da6fe0ef          	jal	80003326 <iupdate>
  iunlock(ip);
    80004d84:	8526                	mv	a0,s1
    80004d86:	f02fe0ef          	jal	80003488 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80004d8a:	fd040593          	addi	a1,s0,-48
    80004d8e:	f5040513          	addi	a0,s0,-176
    80004d92:	d3dfe0ef          	jal	80003ace <nameiparent>
    80004d96:	892a                	mv	s2,a0
    80004d98:	cd21                	beqz	a0,80004df0 <sys_link+0xce>
  ilock(dp);
    80004d9a:	e40fe0ef          	jal	800033da <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80004d9e:	00092703          	lw	a4,0(s2)
    80004da2:	409c                	lw	a5,0(s1)
    80004da4:	04f71363          	bne	a4,a5,80004dea <sys_link+0xc8>
    80004da8:	40d0                	lw	a2,4(s1)
    80004daa:	fd040593          	addi	a1,s0,-48
    80004dae:	854a                	mv	a0,s2
    80004db0:	c6bfe0ef          	jal	80003a1a <dirlink>
    80004db4:	02054b63          	bltz	a0,80004dea <sys_link+0xc8>
  iunlockput(dp);
    80004db8:	854a                	mv	a0,s2
    80004dba:	82bfe0ef          	jal	800035e4 <iunlockput>
  iput(ip);
    80004dbe:	8526                	mv	a0,s1
    80004dc0:	f9cfe0ef          	jal	8000355c <iput>
  end_op();
    80004dc4:	f17fe0ef          	jal	80003cda <end_op>
  return 0;
    80004dc8:	4781                	li	a5,0
    80004dca:	64f2                	ld	s1,280(sp)
    80004dcc:	6952                	ld	s2,272(sp)
    80004dce:	a0a1                	j	80004e16 <sys_link+0xf4>
    end_op();
    80004dd0:	f0bfe0ef          	jal	80003cda <end_op>
    return -1;
    80004dd4:	57fd                	li	a5,-1
    80004dd6:	64f2                	ld	s1,280(sp)
    80004dd8:	a83d                	j	80004e16 <sys_link+0xf4>
    iunlockput(ip);
    80004dda:	8526                	mv	a0,s1
    80004ddc:	809fe0ef          	jal	800035e4 <iunlockput>
    end_op();
    80004de0:	efbfe0ef          	jal	80003cda <end_op>
    return -1;
    80004de4:	57fd                	li	a5,-1
    80004de6:	64f2                	ld	s1,280(sp)
    80004de8:	a03d                	j	80004e16 <sys_link+0xf4>
    iunlockput(dp);
    80004dea:	854a                	mv	a0,s2
    80004dec:	ff8fe0ef          	jal	800035e4 <iunlockput>
  ilock(ip);
    80004df0:	8526                	mv	a0,s1
    80004df2:	de8fe0ef          	jal	800033da <ilock>
  ip->nlink--;
    80004df6:	04a4d783          	lhu	a5,74(s1)
    80004dfa:	37fd                	addiw	a5,a5,-1
    80004dfc:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004e00:	8526                	mv	a0,s1
    80004e02:	d24fe0ef          	jal	80003326 <iupdate>
  iunlockput(ip);
    80004e06:	8526                	mv	a0,s1
    80004e08:	fdcfe0ef          	jal	800035e4 <iunlockput>
  end_op();
    80004e0c:	ecffe0ef          	jal	80003cda <end_op>
  return -1;
    80004e10:	57fd                	li	a5,-1
    80004e12:	64f2                	ld	s1,280(sp)
    80004e14:	6952                	ld	s2,272(sp)
}
    80004e16:	853e                	mv	a0,a5
    80004e18:	70b2                	ld	ra,296(sp)
    80004e1a:	7412                	ld	s0,288(sp)
    80004e1c:	6155                	addi	sp,sp,304
    80004e1e:	8082                	ret

0000000080004e20 <sys_unlink>:
{
    80004e20:	7151                	addi	sp,sp,-240
    80004e22:	f586                	sd	ra,232(sp)
    80004e24:	f1a2                	sd	s0,224(sp)
    80004e26:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80004e28:	08000613          	li	a2,128
    80004e2c:	f3040593          	addi	a1,s0,-208
    80004e30:	4501                	li	a0,0
    80004e32:	b7ffd0ef          	jal	800029b0 <argstr>
    80004e36:	16054063          	bltz	a0,80004f96 <sys_unlink+0x176>
    80004e3a:	eda6                	sd	s1,216(sp)
  begin_op();
    80004e3c:	e35fe0ef          	jal	80003c70 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80004e40:	fb040593          	addi	a1,s0,-80
    80004e44:	f3040513          	addi	a0,s0,-208
    80004e48:	c87fe0ef          	jal	80003ace <nameiparent>
    80004e4c:	84aa                	mv	s1,a0
    80004e4e:	c945                	beqz	a0,80004efe <sys_unlink+0xde>
  ilock(dp);
    80004e50:	d8afe0ef          	jal	800033da <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80004e54:	00003597          	auipc	a1,0x3
    80004e58:	85458593          	addi	a1,a1,-1964 # 800076a8 <etext+0x6a8>
    80004e5c:	fb040513          	addi	a0,s0,-80
    80004e60:	9d9fe0ef          	jal	80003838 <namecmp>
    80004e64:	10050e63          	beqz	a0,80004f80 <sys_unlink+0x160>
    80004e68:	00003597          	auipc	a1,0x3
    80004e6c:	84858593          	addi	a1,a1,-1976 # 800076b0 <etext+0x6b0>
    80004e70:	fb040513          	addi	a0,s0,-80
    80004e74:	9c5fe0ef          	jal	80003838 <namecmp>
    80004e78:	10050463          	beqz	a0,80004f80 <sys_unlink+0x160>
    80004e7c:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    80004e7e:	f2c40613          	addi	a2,s0,-212
    80004e82:	fb040593          	addi	a1,s0,-80
    80004e86:	8526                	mv	a0,s1
    80004e88:	9c7fe0ef          	jal	8000384e <dirlookup>
    80004e8c:	892a                	mv	s2,a0
    80004e8e:	0e050863          	beqz	a0,80004f7e <sys_unlink+0x15e>
  ilock(ip);
    80004e92:	d48fe0ef          	jal	800033da <ilock>
  if(ip->nlink < 1)
    80004e96:	04a91783          	lh	a5,74(s2)
    80004e9a:	06f05763          	blez	a5,80004f08 <sys_unlink+0xe8>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80004e9e:	04491703          	lh	a4,68(s2)
    80004ea2:	4785                	li	a5,1
    80004ea4:	06f70963          	beq	a4,a5,80004f16 <sys_unlink+0xf6>
  memset(&de, 0, sizeof(de));
    80004ea8:	4641                	li	a2,16
    80004eaa:	4581                	li	a1,0
    80004eac:	fc040513          	addi	a0,s0,-64
    80004eb0:	e19fb0ef          	jal	80000cc8 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004eb4:	4741                	li	a4,16
    80004eb6:	f2c42683          	lw	a3,-212(s0)
    80004eba:	fc040613          	addi	a2,s0,-64
    80004ebe:	4581                	li	a1,0
    80004ec0:	8526                	mv	a0,s1
    80004ec2:	869fe0ef          	jal	8000372a <writei>
    80004ec6:	47c1                	li	a5,16
    80004ec8:	08f51b63          	bne	a0,a5,80004f5e <sys_unlink+0x13e>
  if(ip->type == T_DIR){
    80004ecc:	04491703          	lh	a4,68(s2)
    80004ed0:	4785                	li	a5,1
    80004ed2:	08f70d63          	beq	a4,a5,80004f6c <sys_unlink+0x14c>
  iunlockput(dp);
    80004ed6:	8526                	mv	a0,s1
    80004ed8:	f0cfe0ef          	jal	800035e4 <iunlockput>
  ip->nlink--;
    80004edc:	04a95783          	lhu	a5,74(s2)
    80004ee0:	37fd                	addiw	a5,a5,-1
    80004ee2:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80004ee6:	854a                	mv	a0,s2
    80004ee8:	c3efe0ef          	jal	80003326 <iupdate>
  iunlockput(ip);
    80004eec:	854a                	mv	a0,s2
    80004eee:	ef6fe0ef          	jal	800035e4 <iunlockput>
  end_op();
    80004ef2:	de9fe0ef          	jal	80003cda <end_op>
  return 0;
    80004ef6:	4501                	li	a0,0
    80004ef8:	64ee                	ld	s1,216(sp)
    80004efa:	694e                	ld	s2,208(sp)
    80004efc:	a849                	j	80004f8e <sys_unlink+0x16e>
    end_op();
    80004efe:	dddfe0ef          	jal	80003cda <end_op>
    return -1;
    80004f02:	557d                	li	a0,-1
    80004f04:	64ee                	ld	s1,216(sp)
    80004f06:	a061                	j	80004f8e <sys_unlink+0x16e>
    80004f08:	e5ce                	sd	s3,200(sp)
    panic("unlink: nlink < 1");
    80004f0a:	00002517          	auipc	a0,0x2
    80004f0e:	7ae50513          	addi	a0,a0,1966 # 800076b8 <etext+0x6b8>
    80004f12:	883fb0ef          	jal	80000794 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004f16:	04c92703          	lw	a4,76(s2)
    80004f1a:	02000793          	li	a5,32
    80004f1e:	f8e7f5e3          	bgeu	a5,a4,80004ea8 <sys_unlink+0x88>
    80004f22:	e5ce                	sd	s3,200(sp)
    80004f24:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004f28:	4741                	li	a4,16
    80004f2a:	86ce                	mv	a3,s3
    80004f2c:	f1840613          	addi	a2,s0,-232
    80004f30:	4581                	li	a1,0
    80004f32:	854a                	mv	a0,s2
    80004f34:	efafe0ef          	jal	8000362e <readi>
    80004f38:	47c1                	li	a5,16
    80004f3a:	00f51c63          	bne	a0,a5,80004f52 <sys_unlink+0x132>
    if(de.inum != 0)
    80004f3e:	f1845783          	lhu	a5,-232(s0)
    80004f42:	efa1                	bnez	a5,80004f9a <sys_unlink+0x17a>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004f44:	29c1                	addiw	s3,s3,16
    80004f46:	04c92783          	lw	a5,76(s2)
    80004f4a:	fcf9efe3          	bltu	s3,a5,80004f28 <sys_unlink+0x108>
    80004f4e:	69ae                	ld	s3,200(sp)
    80004f50:	bfa1                	j	80004ea8 <sys_unlink+0x88>
      panic("isdirempty: readi");
    80004f52:	00002517          	auipc	a0,0x2
    80004f56:	77e50513          	addi	a0,a0,1918 # 800076d0 <etext+0x6d0>
    80004f5a:	83bfb0ef          	jal	80000794 <panic>
    80004f5e:	e5ce                	sd	s3,200(sp)
    panic("unlink: writei");
    80004f60:	00002517          	auipc	a0,0x2
    80004f64:	78850513          	addi	a0,a0,1928 # 800076e8 <etext+0x6e8>
    80004f68:	82dfb0ef          	jal	80000794 <panic>
    dp->nlink--;
    80004f6c:	04a4d783          	lhu	a5,74(s1)
    80004f70:	37fd                	addiw	a5,a5,-1
    80004f72:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004f76:	8526                	mv	a0,s1
    80004f78:	baefe0ef          	jal	80003326 <iupdate>
    80004f7c:	bfa9                	j	80004ed6 <sys_unlink+0xb6>
    80004f7e:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    80004f80:	8526                	mv	a0,s1
    80004f82:	e62fe0ef          	jal	800035e4 <iunlockput>
  end_op();
    80004f86:	d55fe0ef          	jal	80003cda <end_op>
  return -1;
    80004f8a:	557d                	li	a0,-1
    80004f8c:	64ee                	ld	s1,216(sp)
}
    80004f8e:	70ae                	ld	ra,232(sp)
    80004f90:	740e                	ld	s0,224(sp)
    80004f92:	616d                	addi	sp,sp,240
    80004f94:	8082                	ret
    return -1;
    80004f96:	557d                	li	a0,-1
    80004f98:	bfdd                	j	80004f8e <sys_unlink+0x16e>
    iunlockput(ip);
    80004f9a:	854a                	mv	a0,s2
    80004f9c:	e48fe0ef          	jal	800035e4 <iunlockput>
    goto bad;
    80004fa0:	694e                	ld	s2,208(sp)
    80004fa2:	69ae                	ld	s3,200(sp)
    80004fa4:	bff1                	j	80004f80 <sys_unlink+0x160>

0000000080004fa6 <sys_open>:

uint64
sys_open(void)
{
    80004fa6:	7131                	addi	sp,sp,-192
    80004fa8:	fd06                	sd	ra,184(sp)
    80004faa:	f922                	sd	s0,176(sp)
    80004fac:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80004fae:	f4c40593          	addi	a1,s0,-180
    80004fb2:	4505                	li	a0,1
    80004fb4:	9c5fd0ef          	jal	80002978 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80004fb8:	08000613          	li	a2,128
    80004fbc:	f5040593          	addi	a1,s0,-176
    80004fc0:	4501                	li	a0,0
    80004fc2:	9effd0ef          	jal	800029b0 <argstr>
    80004fc6:	87aa                	mv	a5,a0
    return -1;
    80004fc8:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80004fca:	0a07c263          	bltz	a5,8000506e <sys_open+0xc8>
    80004fce:	f526                	sd	s1,168(sp)

  begin_op();
    80004fd0:	ca1fe0ef          	jal	80003c70 <begin_op>

  if(omode & O_CREATE){
    80004fd4:	f4c42783          	lw	a5,-180(s0)
    80004fd8:	2007f793          	andi	a5,a5,512
    80004fdc:	c3d5                	beqz	a5,80005080 <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    80004fde:	4681                	li	a3,0
    80004fe0:	4601                	li	a2,0
    80004fe2:	4589                	li	a1,2
    80004fe4:	f5040513          	addi	a0,s0,-176
    80004fe8:	aa9ff0ef          	jal	80004a90 <create>
    80004fec:	84aa                	mv	s1,a0
    if(ip == 0){
    80004fee:	c541                	beqz	a0,80005076 <sys_open+0xd0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80004ff0:	04449703          	lh	a4,68(s1)
    80004ff4:	478d                	li	a5,3
    80004ff6:	00f71763          	bne	a4,a5,80005004 <sys_open+0x5e>
    80004ffa:	0464d703          	lhu	a4,70(s1)
    80004ffe:	47a5                	li	a5,9
    80005000:	0ae7ed63          	bltu	a5,a4,800050ba <sys_open+0x114>
    80005004:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005006:	fe1fe0ef          	jal	80003fe6 <filealloc>
    8000500a:	892a                	mv	s2,a0
    8000500c:	c179                	beqz	a0,800050d2 <sys_open+0x12c>
    8000500e:	ed4e                	sd	s3,152(sp)
    80005010:	a43ff0ef          	jal	80004a52 <fdalloc>
    80005014:	89aa                	mv	s3,a0
    80005016:	0a054a63          	bltz	a0,800050ca <sys_open+0x124>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    8000501a:	04449703          	lh	a4,68(s1)
    8000501e:	478d                	li	a5,3
    80005020:	0cf70263          	beq	a4,a5,800050e4 <sys_open+0x13e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005024:	4789                	li	a5,2
    80005026:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    8000502a:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    8000502e:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    80005032:	f4c42783          	lw	a5,-180(s0)
    80005036:	0017c713          	xori	a4,a5,1
    8000503a:	8b05                	andi	a4,a4,1
    8000503c:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005040:	0037f713          	andi	a4,a5,3
    80005044:	00e03733          	snez	a4,a4
    80005048:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    8000504c:	4007f793          	andi	a5,a5,1024
    80005050:	c791                	beqz	a5,8000505c <sys_open+0xb6>
    80005052:	04449703          	lh	a4,68(s1)
    80005056:	4789                	li	a5,2
    80005058:	08f70d63          	beq	a4,a5,800050f2 <sys_open+0x14c>
    itrunc(ip);
  }

  iunlock(ip);
    8000505c:	8526                	mv	a0,s1
    8000505e:	c2afe0ef          	jal	80003488 <iunlock>
  end_op();
    80005062:	c79fe0ef          	jal	80003cda <end_op>

  return fd;
    80005066:	854e                	mv	a0,s3
    80005068:	74aa                	ld	s1,168(sp)
    8000506a:	790a                	ld	s2,160(sp)
    8000506c:	69ea                	ld	s3,152(sp)
}
    8000506e:	70ea                	ld	ra,184(sp)
    80005070:	744a                	ld	s0,176(sp)
    80005072:	6129                	addi	sp,sp,192
    80005074:	8082                	ret
      end_op();
    80005076:	c65fe0ef          	jal	80003cda <end_op>
      return -1;
    8000507a:	557d                	li	a0,-1
    8000507c:	74aa                	ld	s1,168(sp)
    8000507e:	bfc5                	j	8000506e <sys_open+0xc8>
    if((ip = namei(path)) == 0){
    80005080:	f5040513          	addi	a0,s0,-176
    80005084:	a31fe0ef          	jal	80003ab4 <namei>
    80005088:	84aa                	mv	s1,a0
    8000508a:	c11d                	beqz	a0,800050b0 <sys_open+0x10a>
    ilock(ip);
    8000508c:	b4efe0ef          	jal	800033da <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005090:	04449703          	lh	a4,68(s1)
    80005094:	4785                	li	a5,1
    80005096:	f4f71de3          	bne	a4,a5,80004ff0 <sys_open+0x4a>
    8000509a:	f4c42783          	lw	a5,-180(s0)
    8000509e:	d3bd                	beqz	a5,80005004 <sys_open+0x5e>
      iunlockput(ip);
    800050a0:	8526                	mv	a0,s1
    800050a2:	d42fe0ef          	jal	800035e4 <iunlockput>
      end_op();
    800050a6:	c35fe0ef          	jal	80003cda <end_op>
      return -1;
    800050aa:	557d                	li	a0,-1
    800050ac:	74aa                	ld	s1,168(sp)
    800050ae:	b7c1                	j	8000506e <sys_open+0xc8>
      end_op();
    800050b0:	c2bfe0ef          	jal	80003cda <end_op>
      return -1;
    800050b4:	557d                	li	a0,-1
    800050b6:	74aa                	ld	s1,168(sp)
    800050b8:	bf5d                	j	8000506e <sys_open+0xc8>
    iunlockput(ip);
    800050ba:	8526                	mv	a0,s1
    800050bc:	d28fe0ef          	jal	800035e4 <iunlockput>
    end_op();
    800050c0:	c1bfe0ef          	jal	80003cda <end_op>
    return -1;
    800050c4:	557d                	li	a0,-1
    800050c6:	74aa                	ld	s1,168(sp)
    800050c8:	b75d                	j	8000506e <sys_open+0xc8>
      fileclose(f);
    800050ca:	854a                	mv	a0,s2
    800050cc:	fbffe0ef          	jal	8000408a <fileclose>
    800050d0:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    800050d2:	8526                	mv	a0,s1
    800050d4:	d10fe0ef          	jal	800035e4 <iunlockput>
    end_op();
    800050d8:	c03fe0ef          	jal	80003cda <end_op>
    return -1;
    800050dc:	557d                	li	a0,-1
    800050de:	74aa                	ld	s1,168(sp)
    800050e0:	790a                	ld	s2,160(sp)
    800050e2:	b771                	j	8000506e <sys_open+0xc8>
    f->type = FD_DEVICE;
    800050e4:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    800050e8:	04649783          	lh	a5,70(s1)
    800050ec:	02f91223          	sh	a5,36(s2)
    800050f0:	bf3d                	j	8000502e <sys_open+0x88>
    itrunc(ip);
    800050f2:	8526                	mv	a0,s1
    800050f4:	bd4fe0ef          	jal	800034c8 <itrunc>
    800050f8:	b795                	j	8000505c <sys_open+0xb6>

00000000800050fa <sys_mkdir>:

uint64
sys_mkdir(void)
{
    800050fa:	7175                	addi	sp,sp,-144
    800050fc:	e506                	sd	ra,136(sp)
    800050fe:	e122                	sd	s0,128(sp)
    80005100:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005102:	b6ffe0ef          	jal	80003c70 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005106:	08000613          	li	a2,128
    8000510a:	f7040593          	addi	a1,s0,-144
    8000510e:	4501                	li	a0,0
    80005110:	8a1fd0ef          	jal	800029b0 <argstr>
    80005114:	02054363          	bltz	a0,8000513a <sys_mkdir+0x40>
    80005118:	4681                	li	a3,0
    8000511a:	4601                	li	a2,0
    8000511c:	4585                	li	a1,1
    8000511e:	f7040513          	addi	a0,s0,-144
    80005122:	96fff0ef          	jal	80004a90 <create>
    80005126:	c911                	beqz	a0,8000513a <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005128:	cbcfe0ef          	jal	800035e4 <iunlockput>
  end_op();
    8000512c:	baffe0ef          	jal	80003cda <end_op>
  return 0;
    80005130:	4501                	li	a0,0
}
    80005132:	60aa                	ld	ra,136(sp)
    80005134:	640a                	ld	s0,128(sp)
    80005136:	6149                	addi	sp,sp,144
    80005138:	8082                	ret
    end_op();
    8000513a:	ba1fe0ef          	jal	80003cda <end_op>
    return -1;
    8000513e:	557d                	li	a0,-1
    80005140:	bfcd                	j	80005132 <sys_mkdir+0x38>

0000000080005142 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005142:	7135                	addi	sp,sp,-160
    80005144:	ed06                	sd	ra,152(sp)
    80005146:	e922                	sd	s0,144(sp)
    80005148:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    8000514a:	b27fe0ef          	jal	80003c70 <begin_op>
  argint(1, &major);
    8000514e:	f6c40593          	addi	a1,s0,-148
    80005152:	4505                	li	a0,1
    80005154:	825fd0ef          	jal	80002978 <argint>
  argint(2, &minor);
    80005158:	f6840593          	addi	a1,s0,-152
    8000515c:	4509                	li	a0,2
    8000515e:	81bfd0ef          	jal	80002978 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005162:	08000613          	li	a2,128
    80005166:	f7040593          	addi	a1,s0,-144
    8000516a:	4501                	li	a0,0
    8000516c:	845fd0ef          	jal	800029b0 <argstr>
    80005170:	02054563          	bltz	a0,8000519a <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005174:	f6841683          	lh	a3,-152(s0)
    80005178:	f6c41603          	lh	a2,-148(s0)
    8000517c:	458d                	li	a1,3
    8000517e:	f7040513          	addi	a0,s0,-144
    80005182:	90fff0ef          	jal	80004a90 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005186:	c911                	beqz	a0,8000519a <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005188:	c5cfe0ef          	jal	800035e4 <iunlockput>
  end_op();
    8000518c:	b4ffe0ef          	jal	80003cda <end_op>
  return 0;
    80005190:	4501                	li	a0,0
}
    80005192:	60ea                	ld	ra,152(sp)
    80005194:	644a                	ld	s0,144(sp)
    80005196:	610d                	addi	sp,sp,160
    80005198:	8082                	ret
    end_op();
    8000519a:	b41fe0ef          	jal	80003cda <end_op>
    return -1;
    8000519e:	557d                	li	a0,-1
    800051a0:	bfcd                	j	80005192 <sys_mknod+0x50>

00000000800051a2 <sys_chdir>:

uint64
sys_chdir(void)
{
    800051a2:	7135                	addi	sp,sp,-160
    800051a4:	ed06                	sd	ra,152(sp)
    800051a6:	e922                	sd	s0,144(sp)
    800051a8:	e14a                	sd	s2,128(sp)
    800051aa:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800051ac:	f34fc0ef          	jal	800018e0 <myproc>
    800051b0:	892a                	mv	s2,a0
  
  begin_op();
    800051b2:	abffe0ef          	jal	80003c70 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    800051b6:	08000613          	li	a2,128
    800051ba:	f6040593          	addi	a1,s0,-160
    800051be:	4501                	li	a0,0
    800051c0:	ff0fd0ef          	jal	800029b0 <argstr>
    800051c4:	04054363          	bltz	a0,8000520a <sys_chdir+0x68>
    800051c8:	e526                	sd	s1,136(sp)
    800051ca:	f6040513          	addi	a0,s0,-160
    800051ce:	8e7fe0ef          	jal	80003ab4 <namei>
    800051d2:	84aa                	mv	s1,a0
    800051d4:	c915                	beqz	a0,80005208 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    800051d6:	a04fe0ef          	jal	800033da <ilock>
  if(ip->type != T_DIR){
    800051da:	04449703          	lh	a4,68(s1)
    800051de:	4785                	li	a5,1
    800051e0:	02f71963          	bne	a4,a5,80005212 <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    800051e4:	8526                	mv	a0,s1
    800051e6:	aa2fe0ef          	jal	80003488 <iunlock>
  iput(p->cwd);
    800051ea:	15093503          	ld	a0,336(s2)
    800051ee:	b6efe0ef          	jal	8000355c <iput>
  end_op();
    800051f2:	ae9fe0ef          	jal	80003cda <end_op>
  p->cwd = ip;
    800051f6:	14993823          	sd	s1,336(s2)
  return 0;
    800051fa:	4501                	li	a0,0
    800051fc:	64aa                	ld	s1,136(sp)
}
    800051fe:	60ea                	ld	ra,152(sp)
    80005200:	644a                	ld	s0,144(sp)
    80005202:	690a                	ld	s2,128(sp)
    80005204:	610d                	addi	sp,sp,160
    80005206:	8082                	ret
    80005208:	64aa                	ld	s1,136(sp)
    end_op();
    8000520a:	ad1fe0ef          	jal	80003cda <end_op>
    return -1;
    8000520e:	557d                	li	a0,-1
    80005210:	b7fd                	j	800051fe <sys_chdir+0x5c>
    iunlockput(ip);
    80005212:	8526                	mv	a0,s1
    80005214:	bd0fe0ef          	jal	800035e4 <iunlockput>
    end_op();
    80005218:	ac3fe0ef          	jal	80003cda <end_op>
    return -1;
    8000521c:	557d                	li	a0,-1
    8000521e:	64aa                	ld	s1,136(sp)
    80005220:	bff9                	j	800051fe <sys_chdir+0x5c>

0000000080005222 <sys_exec>:

uint64
sys_exec(void)
{
    80005222:	7121                	addi	sp,sp,-448
    80005224:	ff06                	sd	ra,440(sp)
    80005226:	fb22                	sd	s0,432(sp)
    80005228:	0380                	addi	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    8000522a:	e4840593          	addi	a1,s0,-440
    8000522e:	4505                	li	a0,1
    80005230:	f64fd0ef          	jal	80002994 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005234:	08000613          	li	a2,128
    80005238:	f5040593          	addi	a1,s0,-176
    8000523c:	4501                	li	a0,0
    8000523e:	f72fd0ef          	jal	800029b0 <argstr>
    80005242:	87aa                	mv	a5,a0
    return -1;
    80005244:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005246:	0c07c463          	bltz	a5,8000530e <sys_exec+0xec>
    8000524a:	f726                	sd	s1,424(sp)
    8000524c:	f34a                	sd	s2,416(sp)
    8000524e:	ef4e                	sd	s3,408(sp)
    80005250:	eb52                	sd	s4,400(sp)
  }
  memset(argv, 0, sizeof(argv));
    80005252:	10000613          	li	a2,256
    80005256:	4581                	li	a1,0
    80005258:	e5040513          	addi	a0,s0,-432
    8000525c:	a6dfb0ef          	jal	80000cc8 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005260:	e5040493          	addi	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    80005264:	89a6                	mv	s3,s1
    80005266:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005268:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    8000526c:	00391513          	slli	a0,s2,0x3
    80005270:	e4040593          	addi	a1,s0,-448
    80005274:	e4843783          	ld	a5,-440(s0)
    80005278:	953e                	add	a0,a0,a5
    8000527a:	e74fd0ef          	jal	800028ee <fetchaddr>
    8000527e:	02054663          	bltz	a0,800052aa <sys_exec+0x88>
      goto bad;
    }
    if(uarg == 0){
    80005282:	e4043783          	ld	a5,-448(s0)
    80005286:	c3a9                	beqz	a5,800052c8 <sys_exec+0xa6>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005288:	89dfb0ef          	jal	80000b24 <kalloc>
    8000528c:	85aa                	mv	a1,a0
    8000528e:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005292:	cd01                	beqz	a0,800052aa <sys_exec+0x88>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005294:	6605                	lui	a2,0x1
    80005296:	e4043503          	ld	a0,-448(s0)
    8000529a:	e9efd0ef          	jal	80002938 <fetchstr>
    8000529e:	00054663          	bltz	a0,800052aa <sys_exec+0x88>
    if(i >= NELEM(argv)){
    800052a2:	0905                	addi	s2,s2,1
    800052a4:	09a1                	addi	s3,s3,8
    800052a6:	fd4913e3          	bne	s2,s4,8000526c <sys_exec+0x4a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800052aa:	f5040913          	addi	s2,s0,-176
    800052ae:	6088                	ld	a0,0(s1)
    800052b0:	c931                	beqz	a0,80005304 <sys_exec+0xe2>
    kfree(argv[i]);
    800052b2:	f90fb0ef          	jal	80000a42 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800052b6:	04a1                	addi	s1,s1,8
    800052b8:	ff249be3          	bne	s1,s2,800052ae <sys_exec+0x8c>
  return -1;
    800052bc:	557d                	li	a0,-1
    800052be:	74ba                	ld	s1,424(sp)
    800052c0:	791a                	ld	s2,416(sp)
    800052c2:	69fa                	ld	s3,408(sp)
    800052c4:	6a5a                	ld	s4,400(sp)
    800052c6:	a0a1                	j	8000530e <sys_exec+0xec>
      argv[i] = 0;
    800052c8:	0009079b          	sext.w	a5,s2
    800052cc:	078e                	slli	a5,a5,0x3
    800052ce:	fd078793          	addi	a5,a5,-48
    800052d2:	97a2                	add	a5,a5,s0
    800052d4:	e807b023          	sd	zero,-384(a5)
  int ret = exec(path, argv);
    800052d8:	e5040593          	addi	a1,s0,-432
    800052dc:	f5040513          	addi	a0,s0,-176
    800052e0:	ba8ff0ef          	jal	80004688 <exec>
    800052e4:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800052e6:	f5040993          	addi	s3,s0,-176
    800052ea:	6088                	ld	a0,0(s1)
    800052ec:	c511                	beqz	a0,800052f8 <sys_exec+0xd6>
    kfree(argv[i]);
    800052ee:	f54fb0ef          	jal	80000a42 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800052f2:	04a1                	addi	s1,s1,8
    800052f4:	ff349be3          	bne	s1,s3,800052ea <sys_exec+0xc8>
  return ret;
    800052f8:	854a                	mv	a0,s2
    800052fa:	74ba                	ld	s1,424(sp)
    800052fc:	791a                	ld	s2,416(sp)
    800052fe:	69fa                	ld	s3,408(sp)
    80005300:	6a5a                	ld	s4,400(sp)
    80005302:	a031                	j	8000530e <sys_exec+0xec>
  return -1;
    80005304:	557d                	li	a0,-1
    80005306:	74ba                	ld	s1,424(sp)
    80005308:	791a                	ld	s2,416(sp)
    8000530a:	69fa                	ld	s3,408(sp)
    8000530c:	6a5a                	ld	s4,400(sp)
}
    8000530e:	70fa                	ld	ra,440(sp)
    80005310:	745a                	ld	s0,432(sp)
    80005312:	6139                	addi	sp,sp,448
    80005314:	8082                	ret

0000000080005316 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005316:	7139                	addi	sp,sp,-64
    80005318:	fc06                	sd	ra,56(sp)
    8000531a:	f822                	sd	s0,48(sp)
    8000531c:	f426                	sd	s1,40(sp)
    8000531e:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005320:	dc0fc0ef          	jal	800018e0 <myproc>
    80005324:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005326:	fd840593          	addi	a1,s0,-40
    8000532a:	4501                	li	a0,0
    8000532c:	e68fd0ef          	jal	80002994 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005330:	fc840593          	addi	a1,s0,-56
    80005334:	fd040513          	addi	a0,s0,-48
    80005338:	85cff0ef          	jal	80004394 <pipealloc>
    return -1;
    8000533c:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    8000533e:	0a054463          	bltz	a0,800053e6 <sys_pipe+0xd0>
  fd0 = -1;
    80005342:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005346:	fd043503          	ld	a0,-48(s0)
    8000534a:	f08ff0ef          	jal	80004a52 <fdalloc>
    8000534e:	fca42223          	sw	a0,-60(s0)
    80005352:	08054163          	bltz	a0,800053d4 <sys_pipe+0xbe>
    80005356:	fc843503          	ld	a0,-56(s0)
    8000535a:	ef8ff0ef          	jal	80004a52 <fdalloc>
    8000535e:	fca42023          	sw	a0,-64(s0)
    80005362:	06054063          	bltz	a0,800053c2 <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005366:	4691                	li	a3,4
    80005368:	fc440613          	addi	a2,s0,-60
    8000536c:	fd843583          	ld	a1,-40(s0)
    80005370:	68a8                	ld	a0,80(s1)
    80005372:	9e0fc0ef          	jal	80001552 <copyout>
    80005376:	00054e63          	bltz	a0,80005392 <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    8000537a:	4691                	li	a3,4
    8000537c:	fc040613          	addi	a2,s0,-64
    80005380:	fd843583          	ld	a1,-40(s0)
    80005384:	0591                	addi	a1,a1,4
    80005386:	68a8                	ld	a0,80(s1)
    80005388:	9cafc0ef          	jal	80001552 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    8000538c:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000538e:	04055c63          	bgez	a0,800053e6 <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    80005392:	fc442783          	lw	a5,-60(s0)
    80005396:	07e9                	addi	a5,a5,26
    80005398:	078e                	slli	a5,a5,0x3
    8000539a:	97a6                	add	a5,a5,s1
    8000539c:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    800053a0:	fc042783          	lw	a5,-64(s0)
    800053a4:	07e9                	addi	a5,a5,26
    800053a6:	078e                	slli	a5,a5,0x3
    800053a8:	94be                	add	s1,s1,a5
    800053aa:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    800053ae:	fd043503          	ld	a0,-48(s0)
    800053b2:	cd9fe0ef          	jal	8000408a <fileclose>
    fileclose(wf);
    800053b6:	fc843503          	ld	a0,-56(s0)
    800053ba:	cd1fe0ef          	jal	8000408a <fileclose>
    return -1;
    800053be:	57fd                	li	a5,-1
    800053c0:	a01d                	j	800053e6 <sys_pipe+0xd0>
    if(fd0 >= 0)
    800053c2:	fc442783          	lw	a5,-60(s0)
    800053c6:	0007c763          	bltz	a5,800053d4 <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    800053ca:	07e9                	addi	a5,a5,26
    800053cc:	078e                	slli	a5,a5,0x3
    800053ce:	97a6                	add	a5,a5,s1
    800053d0:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    800053d4:	fd043503          	ld	a0,-48(s0)
    800053d8:	cb3fe0ef          	jal	8000408a <fileclose>
    fileclose(wf);
    800053dc:	fc843503          	ld	a0,-56(s0)
    800053e0:	cabfe0ef          	jal	8000408a <fileclose>
    return -1;
    800053e4:	57fd                	li	a5,-1
}
    800053e6:	853e                	mv	a0,a5
    800053e8:	70e2                	ld	ra,56(sp)
    800053ea:	7442                	ld	s0,48(sp)
    800053ec:	74a2                	ld	s1,40(sp)
    800053ee:	6121                	addi	sp,sp,64
    800053f0:	8082                	ret
	...

0000000080005400 <kernelvec>:
    80005400:	7111                	addi	sp,sp,-256
    80005402:	e006                	sd	ra,0(sp)
    80005404:	e40a                	sd	sp,8(sp)
    80005406:	e80e                	sd	gp,16(sp)
    80005408:	ec12                	sd	tp,24(sp)
    8000540a:	f016                	sd	t0,32(sp)
    8000540c:	f41a                	sd	t1,40(sp)
    8000540e:	f81e                	sd	t2,48(sp)
    80005410:	e4aa                	sd	a0,72(sp)
    80005412:	e8ae                	sd	a1,80(sp)
    80005414:	ecb2                	sd	a2,88(sp)
    80005416:	f0b6                	sd	a3,96(sp)
    80005418:	f4ba                	sd	a4,104(sp)
    8000541a:	f8be                	sd	a5,112(sp)
    8000541c:	fcc2                	sd	a6,120(sp)
    8000541e:	e146                	sd	a7,128(sp)
    80005420:	edf2                	sd	t3,216(sp)
    80005422:	f1f6                	sd	t4,224(sp)
    80005424:	f5fa                	sd	t5,232(sp)
    80005426:	f9fe                	sd	t6,240(sp)
    80005428:	bd6fd0ef          	jal	800027fe <kerneltrap>
    8000542c:	6082                	ld	ra,0(sp)
    8000542e:	6122                	ld	sp,8(sp)
    80005430:	61c2                	ld	gp,16(sp)
    80005432:	7282                	ld	t0,32(sp)
    80005434:	7322                	ld	t1,40(sp)
    80005436:	73c2                	ld	t2,48(sp)
    80005438:	6526                	ld	a0,72(sp)
    8000543a:	65c6                	ld	a1,80(sp)
    8000543c:	6666                	ld	a2,88(sp)
    8000543e:	7686                	ld	a3,96(sp)
    80005440:	7726                	ld	a4,104(sp)
    80005442:	77c6                	ld	a5,112(sp)
    80005444:	7866                	ld	a6,120(sp)
    80005446:	688a                	ld	a7,128(sp)
    80005448:	6e6e                	ld	t3,216(sp)
    8000544a:	7e8e                	ld	t4,224(sp)
    8000544c:	7f2e                	ld	t5,232(sp)
    8000544e:	7fce                	ld	t6,240(sp)
    80005450:	6111                	addi	sp,sp,256
    80005452:	10200073          	sret
	...

000000008000545e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000545e:	1141                	addi	sp,sp,-16
    80005460:	e422                	sd	s0,8(sp)
    80005462:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005464:	0c0007b7          	lui	a5,0xc000
    80005468:	4705                	li	a4,1
    8000546a:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    8000546c:	0c0007b7          	lui	a5,0xc000
    80005470:	c3d8                	sw	a4,4(a5)
}
    80005472:	6422                	ld	s0,8(sp)
    80005474:	0141                	addi	sp,sp,16
    80005476:	8082                	ret

0000000080005478 <plicinithart>:

void
plicinithart(void)
{
    80005478:	1141                	addi	sp,sp,-16
    8000547a:	e406                	sd	ra,8(sp)
    8000547c:	e022                	sd	s0,0(sp)
    8000547e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005480:	c34fc0ef          	jal	800018b4 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005484:	0085171b          	slliw	a4,a0,0x8
    80005488:	0c0027b7          	lui	a5,0xc002
    8000548c:	97ba                	add	a5,a5,a4
    8000548e:	40200713          	li	a4,1026
    80005492:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005496:	00d5151b          	slliw	a0,a0,0xd
    8000549a:	0c2017b7          	lui	a5,0xc201
    8000549e:	97aa                	add	a5,a5,a0
    800054a0:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    800054a4:	60a2                	ld	ra,8(sp)
    800054a6:	6402                	ld	s0,0(sp)
    800054a8:	0141                	addi	sp,sp,16
    800054aa:	8082                	ret

00000000800054ac <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800054ac:	1141                	addi	sp,sp,-16
    800054ae:	e406                	sd	ra,8(sp)
    800054b0:	e022                	sd	s0,0(sp)
    800054b2:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800054b4:	c00fc0ef          	jal	800018b4 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    800054b8:	00d5151b          	slliw	a0,a0,0xd
    800054bc:	0c2017b7          	lui	a5,0xc201
    800054c0:	97aa                	add	a5,a5,a0
  return irq;
}
    800054c2:	43c8                	lw	a0,4(a5)
    800054c4:	60a2                	ld	ra,8(sp)
    800054c6:	6402                	ld	s0,0(sp)
    800054c8:	0141                	addi	sp,sp,16
    800054ca:	8082                	ret

00000000800054cc <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800054cc:	1101                	addi	sp,sp,-32
    800054ce:	ec06                	sd	ra,24(sp)
    800054d0:	e822                	sd	s0,16(sp)
    800054d2:	e426                	sd	s1,8(sp)
    800054d4:	1000                	addi	s0,sp,32
    800054d6:	84aa                	mv	s1,a0
  int hart = cpuid();
    800054d8:	bdcfc0ef          	jal	800018b4 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800054dc:	00d5151b          	slliw	a0,a0,0xd
    800054e0:	0c2017b7          	lui	a5,0xc201
    800054e4:	97aa                	add	a5,a5,a0
    800054e6:	c3c4                	sw	s1,4(a5)
}
    800054e8:	60e2                	ld	ra,24(sp)
    800054ea:	6442                	ld	s0,16(sp)
    800054ec:	64a2                	ld	s1,8(sp)
    800054ee:	6105                	addi	sp,sp,32
    800054f0:	8082                	ret

00000000800054f2 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800054f2:	1141                	addi	sp,sp,-16
    800054f4:	e406                	sd	ra,8(sp)
    800054f6:	e022                	sd	s0,0(sp)
    800054f8:	0800                	addi	s0,sp,16
  if(i >= NUM)
    800054fa:	479d                	li	a5,7
    800054fc:	04a7ca63          	blt	a5,a0,80005550 <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    80005500:	00024797          	auipc	a5,0x24
    80005504:	ec878793          	addi	a5,a5,-312 # 800293c8 <disk>
    80005508:	97aa                	add	a5,a5,a0
    8000550a:	0187c783          	lbu	a5,24(a5)
    8000550e:	e7b9                	bnez	a5,8000555c <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005510:	00451693          	slli	a3,a0,0x4
    80005514:	00024797          	auipc	a5,0x24
    80005518:	eb478793          	addi	a5,a5,-332 # 800293c8 <disk>
    8000551c:	6398                	ld	a4,0(a5)
    8000551e:	9736                	add	a4,a4,a3
    80005520:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80005524:	6398                	ld	a4,0(a5)
    80005526:	9736                	add	a4,a4,a3
    80005528:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    8000552c:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005530:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005534:	97aa                	add	a5,a5,a0
    80005536:	4705                	li	a4,1
    80005538:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    8000553c:	00024517          	auipc	a0,0x24
    80005540:	ea450513          	addi	a0,a0,-348 # 800293e0 <disk+0x18>
    80005544:	9b7fc0ef          	jal	80001efa <wakeup>
}
    80005548:	60a2                	ld	ra,8(sp)
    8000554a:	6402                	ld	s0,0(sp)
    8000554c:	0141                	addi	sp,sp,16
    8000554e:	8082                	ret
    panic("free_desc 1");
    80005550:	00002517          	auipc	a0,0x2
    80005554:	1a850513          	addi	a0,a0,424 # 800076f8 <etext+0x6f8>
    80005558:	a3cfb0ef          	jal	80000794 <panic>
    panic("free_desc 2");
    8000555c:	00002517          	auipc	a0,0x2
    80005560:	1ac50513          	addi	a0,a0,428 # 80007708 <etext+0x708>
    80005564:	a30fb0ef          	jal	80000794 <panic>

0000000080005568 <virtio_disk_init>:
{
    80005568:	1101                	addi	sp,sp,-32
    8000556a:	ec06                	sd	ra,24(sp)
    8000556c:	e822                	sd	s0,16(sp)
    8000556e:	e426                	sd	s1,8(sp)
    80005570:	e04a                	sd	s2,0(sp)
    80005572:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005574:	00002597          	auipc	a1,0x2
    80005578:	1a458593          	addi	a1,a1,420 # 80007718 <etext+0x718>
    8000557c:	00024517          	auipc	a0,0x24
    80005580:	f7450513          	addi	a0,a0,-140 # 800294f0 <disk+0x128>
    80005584:	df0fb0ef          	jal	80000b74 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005588:	100017b7          	lui	a5,0x10001
    8000558c:	4398                	lw	a4,0(a5)
    8000558e:	2701                	sext.w	a4,a4
    80005590:	747277b7          	lui	a5,0x74727
    80005594:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005598:	18f71063          	bne	a4,a5,80005718 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    8000559c:	100017b7          	lui	a5,0x10001
    800055a0:	0791                	addi	a5,a5,4 # 10001004 <_entry-0x6fffeffc>
    800055a2:	439c                	lw	a5,0(a5)
    800055a4:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800055a6:	4709                	li	a4,2
    800055a8:	16e79863          	bne	a5,a4,80005718 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800055ac:	100017b7          	lui	a5,0x10001
    800055b0:	07a1                	addi	a5,a5,8 # 10001008 <_entry-0x6fffeff8>
    800055b2:	439c                	lw	a5,0(a5)
    800055b4:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800055b6:	16e79163          	bne	a5,a4,80005718 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800055ba:	100017b7          	lui	a5,0x10001
    800055be:	47d8                	lw	a4,12(a5)
    800055c0:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800055c2:	554d47b7          	lui	a5,0x554d4
    800055c6:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800055ca:	14f71763          	bne	a4,a5,80005718 <virtio_disk_init+0x1b0>
  *R(VIRTIO_MMIO_STATUS) = status;
    800055ce:	100017b7          	lui	a5,0x10001
    800055d2:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    800055d6:	4705                	li	a4,1
    800055d8:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800055da:	470d                	li	a4,3
    800055dc:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800055de:	10001737          	lui	a4,0x10001
    800055e2:	4b14                	lw	a3,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800055e4:	c7ffe737          	lui	a4,0xc7ffe
    800055e8:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd5257>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800055ec:	8ef9                	and	a3,a3,a4
    800055ee:	10001737          	lui	a4,0x10001
    800055f2:	d314                	sw	a3,32(a4)
  *R(VIRTIO_MMIO_STATUS) = status;
    800055f4:	472d                	li	a4,11
    800055f6:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800055f8:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    800055fc:	439c                	lw	a5,0(a5)
    800055fe:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005602:	8ba1                	andi	a5,a5,8
    80005604:	12078063          	beqz	a5,80005724 <virtio_disk_init+0x1bc>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005608:	100017b7          	lui	a5,0x10001
    8000560c:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80005610:	100017b7          	lui	a5,0x10001
    80005614:	04478793          	addi	a5,a5,68 # 10001044 <_entry-0x6fffefbc>
    80005618:	439c                	lw	a5,0(a5)
    8000561a:	2781                	sext.w	a5,a5
    8000561c:	10079a63          	bnez	a5,80005730 <virtio_disk_init+0x1c8>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005620:	100017b7          	lui	a5,0x10001
    80005624:	03478793          	addi	a5,a5,52 # 10001034 <_entry-0x6fffefcc>
    80005628:	439c                	lw	a5,0(a5)
    8000562a:	2781                	sext.w	a5,a5
  if(max == 0)
    8000562c:	10078863          	beqz	a5,8000573c <virtio_disk_init+0x1d4>
  if(max < NUM)
    80005630:	471d                	li	a4,7
    80005632:	10f77b63          	bgeu	a4,a5,80005748 <virtio_disk_init+0x1e0>
  disk.desc = kalloc();
    80005636:	ceefb0ef          	jal	80000b24 <kalloc>
    8000563a:	00024497          	auipc	s1,0x24
    8000563e:	d8e48493          	addi	s1,s1,-626 # 800293c8 <disk>
    80005642:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005644:	ce0fb0ef          	jal	80000b24 <kalloc>
    80005648:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000564a:	cdafb0ef          	jal	80000b24 <kalloc>
    8000564e:	87aa                	mv	a5,a0
    80005650:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80005652:	6088                	ld	a0,0(s1)
    80005654:	10050063          	beqz	a0,80005754 <virtio_disk_init+0x1ec>
    80005658:	00024717          	auipc	a4,0x24
    8000565c:	d7873703          	ld	a4,-648(a4) # 800293d0 <disk+0x8>
    80005660:	0e070a63          	beqz	a4,80005754 <virtio_disk_init+0x1ec>
    80005664:	0e078863          	beqz	a5,80005754 <virtio_disk_init+0x1ec>
  memset(disk.desc, 0, PGSIZE);
    80005668:	6605                	lui	a2,0x1
    8000566a:	4581                	li	a1,0
    8000566c:	e5cfb0ef          	jal	80000cc8 <memset>
  memset(disk.avail, 0, PGSIZE);
    80005670:	00024497          	auipc	s1,0x24
    80005674:	d5848493          	addi	s1,s1,-680 # 800293c8 <disk>
    80005678:	6605                	lui	a2,0x1
    8000567a:	4581                	li	a1,0
    8000567c:	6488                	ld	a0,8(s1)
    8000567e:	e4afb0ef          	jal	80000cc8 <memset>
  memset(disk.used, 0, PGSIZE);
    80005682:	6605                	lui	a2,0x1
    80005684:	4581                	li	a1,0
    80005686:	6888                	ld	a0,16(s1)
    80005688:	e40fb0ef          	jal	80000cc8 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    8000568c:	100017b7          	lui	a5,0x10001
    80005690:	4721                	li	a4,8
    80005692:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005694:	4098                	lw	a4,0(s1)
    80005696:	100017b7          	lui	a5,0x10001
    8000569a:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    8000569e:	40d8                	lw	a4,4(s1)
    800056a0:	100017b7          	lui	a5,0x10001
    800056a4:	08e7a223          	sw	a4,132(a5) # 10001084 <_entry-0x6fffef7c>
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    800056a8:	649c                	ld	a5,8(s1)
    800056aa:	0007869b          	sext.w	a3,a5
    800056ae:	10001737          	lui	a4,0x10001
    800056b2:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    800056b6:	9781                	srai	a5,a5,0x20
    800056b8:	10001737          	lui	a4,0x10001
    800056bc:	08f72a23          	sw	a5,148(a4) # 10001094 <_entry-0x6fffef6c>
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    800056c0:	689c                	ld	a5,16(s1)
    800056c2:	0007869b          	sext.w	a3,a5
    800056c6:	10001737          	lui	a4,0x10001
    800056ca:	0ad72023          	sw	a3,160(a4) # 100010a0 <_entry-0x6fffef60>
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    800056ce:	9781                	srai	a5,a5,0x20
    800056d0:	10001737          	lui	a4,0x10001
    800056d4:	0af72223          	sw	a5,164(a4) # 100010a4 <_entry-0x6fffef5c>
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    800056d8:	10001737          	lui	a4,0x10001
    800056dc:	4785                	li	a5,1
    800056de:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    800056e0:	00f48c23          	sb	a5,24(s1)
    800056e4:	00f48ca3          	sb	a5,25(s1)
    800056e8:	00f48d23          	sb	a5,26(s1)
    800056ec:	00f48da3          	sb	a5,27(s1)
    800056f0:	00f48e23          	sb	a5,28(s1)
    800056f4:	00f48ea3          	sb	a5,29(s1)
    800056f8:	00f48f23          	sb	a5,30(s1)
    800056fc:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005700:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005704:	100017b7          	lui	a5,0x10001
    80005708:	0727a823          	sw	s2,112(a5) # 10001070 <_entry-0x6fffef90>
}
    8000570c:	60e2                	ld	ra,24(sp)
    8000570e:	6442                	ld	s0,16(sp)
    80005710:	64a2                	ld	s1,8(sp)
    80005712:	6902                	ld	s2,0(sp)
    80005714:	6105                	addi	sp,sp,32
    80005716:	8082                	ret
    panic("could not find virtio disk");
    80005718:	00002517          	auipc	a0,0x2
    8000571c:	01050513          	addi	a0,a0,16 # 80007728 <etext+0x728>
    80005720:	874fb0ef          	jal	80000794 <panic>
    panic("virtio disk FEATURES_OK unset");
    80005724:	00002517          	auipc	a0,0x2
    80005728:	02450513          	addi	a0,a0,36 # 80007748 <etext+0x748>
    8000572c:	868fb0ef          	jal	80000794 <panic>
    panic("virtio disk should not be ready");
    80005730:	00002517          	auipc	a0,0x2
    80005734:	03850513          	addi	a0,a0,56 # 80007768 <etext+0x768>
    80005738:	85cfb0ef          	jal	80000794 <panic>
    panic("virtio disk has no queue 0");
    8000573c:	00002517          	auipc	a0,0x2
    80005740:	04c50513          	addi	a0,a0,76 # 80007788 <etext+0x788>
    80005744:	850fb0ef          	jal	80000794 <panic>
    panic("virtio disk max queue too short");
    80005748:	00002517          	auipc	a0,0x2
    8000574c:	06050513          	addi	a0,a0,96 # 800077a8 <etext+0x7a8>
    80005750:	844fb0ef          	jal	80000794 <panic>
    panic("virtio disk kalloc");
    80005754:	00002517          	auipc	a0,0x2
    80005758:	07450513          	addi	a0,a0,116 # 800077c8 <etext+0x7c8>
    8000575c:	838fb0ef          	jal	80000794 <panic>

0000000080005760 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005760:	7159                	addi	sp,sp,-112
    80005762:	f486                	sd	ra,104(sp)
    80005764:	f0a2                	sd	s0,96(sp)
    80005766:	eca6                	sd	s1,88(sp)
    80005768:	e8ca                	sd	s2,80(sp)
    8000576a:	e4ce                	sd	s3,72(sp)
    8000576c:	e0d2                	sd	s4,64(sp)
    8000576e:	fc56                	sd	s5,56(sp)
    80005770:	f85a                	sd	s6,48(sp)
    80005772:	f45e                	sd	s7,40(sp)
    80005774:	f062                	sd	s8,32(sp)
    80005776:	ec66                	sd	s9,24(sp)
    80005778:	1880                	addi	s0,sp,112
    8000577a:	8a2a                	mv	s4,a0
    8000577c:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    8000577e:	00c52c83          	lw	s9,12(a0)
    80005782:	001c9c9b          	slliw	s9,s9,0x1
    80005786:	1c82                	slli	s9,s9,0x20
    80005788:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    8000578c:	00024517          	auipc	a0,0x24
    80005790:	d6450513          	addi	a0,a0,-668 # 800294f0 <disk+0x128>
    80005794:	c60fb0ef          	jal	80000bf4 <acquire>
  for(int i = 0; i < 3; i++){
    80005798:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    8000579a:	44a1                	li	s1,8
      disk.free[i] = 0;
    8000579c:	00024b17          	auipc	s6,0x24
    800057a0:	c2cb0b13          	addi	s6,s6,-980 # 800293c8 <disk>
  for(int i = 0; i < 3; i++){
    800057a4:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800057a6:	00024c17          	auipc	s8,0x24
    800057aa:	d4ac0c13          	addi	s8,s8,-694 # 800294f0 <disk+0x128>
    800057ae:	a8b9                	j	8000580c <virtio_disk_rw+0xac>
      disk.free[i] = 0;
    800057b0:	00fb0733          	add	a4,s6,a5
    800057b4:	00070c23          	sb	zero,24(a4) # 10001018 <_entry-0x6fffefe8>
    idx[i] = alloc_desc();
    800057b8:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    800057ba:	0207c563          	bltz	a5,800057e4 <virtio_disk_rw+0x84>
  for(int i = 0; i < 3; i++){
    800057be:	2905                	addiw	s2,s2,1
    800057c0:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    800057c2:	05590963          	beq	s2,s5,80005814 <virtio_disk_rw+0xb4>
    idx[i] = alloc_desc();
    800057c6:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    800057c8:	00024717          	auipc	a4,0x24
    800057cc:	c0070713          	addi	a4,a4,-1024 # 800293c8 <disk>
    800057d0:	87ce                	mv	a5,s3
    if(disk.free[i]){
    800057d2:	01874683          	lbu	a3,24(a4)
    800057d6:	fee9                	bnez	a3,800057b0 <virtio_disk_rw+0x50>
  for(int i = 0; i < NUM; i++){
    800057d8:	2785                	addiw	a5,a5,1
    800057da:	0705                	addi	a4,a4,1
    800057dc:	fe979be3          	bne	a5,s1,800057d2 <virtio_disk_rw+0x72>
    idx[i] = alloc_desc();
    800057e0:	57fd                	li	a5,-1
    800057e2:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    800057e4:	01205d63          	blez	s2,800057fe <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    800057e8:	f9042503          	lw	a0,-112(s0)
    800057ec:	d07ff0ef          	jal	800054f2 <free_desc>
      for(int j = 0; j < i; j++)
    800057f0:	4785                	li	a5,1
    800057f2:	0127d663          	bge	a5,s2,800057fe <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    800057f6:	f9442503          	lw	a0,-108(s0)
    800057fa:	cf9ff0ef          	jal	800054f2 <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    800057fe:	85e2                	mv	a1,s8
    80005800:	00024517          	auipc	a0,0x24
    80005804:	be050513          	addi	a0,a0,-1056 # 800293e0 <disk+0x18>
    80005808:	ea6fc0ef          	jal	80001eae <sleep>
  for(int i = 0; i < 3; i++){
    8000580c:	f9040613          	addi	a2,s0,-112
    80005810:	894e                	mv	s2,s3
    80005812:	bf55                	j	800057c6 <virtio_disk_rw+0x66>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005814:	f9042503          	lw	a0,-112(s0)
    80005818:	00451693          	slli	a3,a0,0x4

  if(write)
    8000581c:	00024797          	auipc	a5,0x24
    80005820:	bac78793          	addi	a5,a5,-1108 # 800293c8 <disk>
    80005824:	00a50713          	addi	a4,a0,10
    80005828:	0712                	slli	a4,a4,0x4
    8000582a:	973e                	add	a4,a4,a5
    8000582c:	01703633          	snez	a2,s7
    80005830:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80005832:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80005836:	01973823          	sd	s9,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    8000583a:	6398                	ld	a4,0(a5)
    8000583c:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    8000583e:	0a868613          	addi	a2,a3,168
    80005842:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80005844:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005846:	6390                	ld	a2,0(a5)
    80005848:	00d605b3          	add	a1,a2,a3
    8000584c:	4741                	li	a4,16
    8000584e:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005850:	4805                	li	a6,1
    80005852:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    80005856:	f9442703          	lw	a4,-108(s0)
    8000585a:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64) b->data;
    8000585e:	0712                	slli	a4,a4,0x4
    80005860:	963a                	add	a2,a2,a4
    80005862:	058a0593          	addi	a1,s4,88
    80005866:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80005868:	0007b883          	ld	a7,0(a5)
    8000586c:	9746                	add	a4,a4,a7
    8000586e:	40000613          	li	a2,1024
    80005872:	c710                	sw	a2,8(a4)
  if(write)
    80005874:	001bb613          	seqz	a2,s7
    80005878:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000587c:	00166613          	ori	a2,a2,1
    80005880:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80005884:	f9842583          	lw	a1,-104(s0)
    80005888:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    8000588c:	00250613          	addi	a2,a0,2
    80005890:	0612                	slli	a2,a2,0x4
    80005892:	963e                	add	a2,a2,a5
    80005894:	577d                	li	a4,-1
    80005896:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    8000589a:	0592                	slli	a1,a1,0x4
    8000589c:	98ae                	add	a7,a7,a1
    8000589e:	03068713          	addi	a4,a3,48
    800058a2:	973e                	add	a4,a4,a5
    800058a4:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    800058a8:	6398                	ld	a4,0(a5)
    800058aa:	972e                	add	a4,a4,a1
    800058ac:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800058b0:	4689                	li	a3,2
    800058b2:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    800058b6:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800058ba:	010a2223          	sw	a6,4(s4)
  disk.info[idx[0]].b = b;
    800058be:	01463423          	sd	s4,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    800058c2:	6794                	ld	a3,8(a5)
    800058c4:	0026d703          	lhu	a4,2(a3)
    800058c8:	8b1d                	andi	a4,a4,7
    800058ca:	0706                	slli	a4,a4,0x1
    800058cc:	96ba                	add	a3,a3,a4
    800058ce:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    800058d2:	0330000f          	fence	rw,rw

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    800058d6:	6798                	ld	a4,8(a5)
    800058d8:	00275783          	lhu	a5,2(a4)
    800058dc:	2785                	addiw	a5,a5,1
    800058de:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    800058e2:	0330000f          	fence	rw,rw

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800058e6:	100017b7          	lui	a5,0x10001
    800058ea:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    800058ee:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    800058f2:	00024917          	auipc	s2,0x24
    800058f6:	bfe90913          	addi	s2,s2,-1026 # 800294f0 <disk+0x128>
  while(b->disk == 1) {
    800058fa:	4485                	li	s1,1
    800058fc:	01079a63          	bne	a5,a6,80005910 <virtio_disk_rw+0x1b0>
    sleep(b, &disk.vdisk_lock);
    80005900:	85ca                	mv	a1,s2
    80005902:	8552                	mv	a0,s4
    80005904:	daafc0ef          	jal	80001eae <sleep>
  while(b->disk == 1) {
    80005908:	004a2783          	lw	a5,4(s4)
    8000590c:	fe978ae3          	beq	a5,s1,80005900 <virtio_disk_rw+0x1a0>
  }

  disk.info[idx[0]].b = 0;
    80005910:	f9042903          	lw	s2,-112(s0)
    80005914:	00290713          	addi	a4,s2,2
    80005918:	0712                	slli	a4,a4,0x4
    8000591a:	00024797          	auipc	a5,0x24
    8000591e:	aae78793          	addi	a5,a5,-1362 # 800293c8 <disk>
    80005922:	97ba                	add	a5,a5,a4
    80005924:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80005928:	00024997          	auipc	s3,0x24
    8000592c:	aa098993          	addi	s3,s3,-1376 # 800293c8 <disk>
    80005930:	00491713          	slli	a4,s2,0x4
    80005934:	0009b783          	ld	a5,0(s3)
    80005938:	97ba                	add	a5,a5,a4
    8000593a:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    8000593e:	854a                	mv	a0,s2
    80005940:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005944:	bafff0ef          	jal	800054f2 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80005948:	8885                	andi	s1,s1,1
    8000594a:	f0fd                	bnez	s1,80005930 <virtio_disk_rw+0x1d0>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    8000594c:	00024517          	auipc	a0,0x24
    80005950:	ba450513          	addi	a0,a0,-1116 # 800294f0 <disk+0x128>
    80005954:	b38fb0ef          	jal	80000c8c <release>
}
    80005958:	70a6                	ld	ra,104(sp)
    8000595a:	7406                	ld	s0,96(sp)
    8000595c:	64e6                	ld	s1,88(sp)
    8000595e:	6946                	ld	s2,80(sp)
    80005960:	69a6                	ld	s3,72(sp)
    80005962:	6a06                	ld	s4,64(sp)
    80005964:	7ae2                	ld	s5,56(sp)
    80005966:	7b42                	ld	s6,48(sp)
    80005968:	7ba2                	ld	s7,40(sp)
    8000596a:	7c02                	ld	s8,32(sp)
    8000596c:	6ce2                	ld	s9,24(sp)
    8000596e:	6165                	addi	sp,sp,112
    80005970:	8082                	ret

0000000080005972 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80005972:	1101                	addi	sp,sp,-32
    80005974:	ec06                	sd	ra,24(sp)
    80005976:	e822                	sd	s0,16(sp)
    80005978:	e426                	sd	s1,8(sp)
    8000597a:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    8000597c:	00024497          	auipc	s1,0x24
    80005980:	a4c48493          	addi	s1,s1,-1460 # 800293c8 <disk>
    80005984:	00024517          	auipc	a0,0x24
    80005988:	b6c50513          	addi	a0,a0,-1172 # 800294f0 <disk+0x128>
    8000598c:	a68fb0ef          	jal	80000bf4 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80005990:	100017b7          	lui	a5,0x10001
    80005994:	53b8                	lw	a4,96(a5)
    80005996:	8b0d                	andi	a4,a4,3
    80005998:	100017b7          	lui	a5,0x10001
    8000599c:	d3f8                	sw	a4,100(a5)

  __sync_synchronize();
    8000599e:	0330000f          	fence	rw,rw

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800059a2:	689c                	ld	a5,16(s1)
    800059a4:	0204d703          	lhu	a4,32(s1)
    800059a8:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    800059ac:	04f70663          	beq	a4,a5,800059f8 <virtio_disk_intr+0x86>
    __sync_synchronize();
    800059b0:	0330000f          	fence	rw,rw
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800059b4:	6898                	ld	a4,16(s1)
    800059b6:	0204d783          	lhu	a5,32(s1)
    800059ba:	8b9d                	andi	a5,a5,7
    800059bc:	078e                	slli	a5,a5,0x3
    800059be:	97ba                	add	a5,a5,a4
    800059c0:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    800059c2:	00278713          	addi	a4,a5,2
    800059c6:	0712                	slli	a4,a4,0x4
    800059c8:	9726                	add	a4,a4,s1
    800059ca:	01074703          	lbu	a4,16(a4)
    800059ce:	e321                	bnez	a4,80005a0e <virtio_disk_intr+0x9c>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    800059d0:	0789                	addi	a5,a5,2
    800059d2:	0792                	slli	a5,a5,0x4
    800059d4:	97a6                	add	a5,a5,s1
    800059d6:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    800059d8:	00052223          	sw	zero,4(a0)
    wakeup(b);
    800059dc:	d1efc0ef          	jal	80001efa <wakeup>

    disk.used_idx += 1;
    800059e0:	0204d783          	lhu	a5,32(s1)
    800059e4:	2785                	addiw	a5,a5,1
    800059e6:	17c2                	slli	a5,a5,0x30
    800059e8:	93c1                	srli	a5,a5,0x30
    800059ea:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    800059ee:	6898                	ld	a4,16(s1)
    800059f0:	00275703          	lhu	a4,2(a4)
    800059f4:	faf71ee3          	bne	a4,a5,800059b0 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    800059f8:	00024517          	auipc	a0,0x24
    800059fc:	af850513          	addi	a0,a0,-1288 # 800294f0 <disk+0x128>
    80005a00:	a8cfb0ef          	jal	80000c8c <release>
}
    80005a04:	60e2                	ld	ra,24(sp)
    80005a06:	6442                	ld	s0,16(sp)
    80005a08:	64a2                	ld	s1,8(sp)
    80005a0a:	6105                	addi	sp,sp,32
    80005a0c:	8082                	ret
      panic("virtio_disk_intr status");
    80005a0e:	00002517          	auipc	a0,0x2
    80005a12:	dd250513          	addi	a0,a0,-558 # 800077e0 <etext+0x7e0>
    80005a16:	d7ffa0ef          	jal	80000794 <panic>
	...

0000000080006000 <_trampoline>:
    80006000:	14051073          	csrw	sscratch,a0
    80006004:	02000537          	lui	a0,0x2000
    80006008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000600a:	0536                	slli	a0,a0,0xd
    8000600c:	02153423          	sd	ra,40(a0)
    80006010:	02253823          	sd	sp,48(a0)
    80006014:	02353c23          	sd	gp,56(a0)
    80006018:	04453023          	sd	tp,64(a0)
    8000601c:	04553423          	sd	t0,72(a0)
    80006020:	04653823          	sd	t1,80(a0)
    80006024:	04753c23          	sd	t2,88(a0)
    80006028:	f120                	sd	s0,96(a0)
    8000602a:	f524                	sd	s1,104(a0)
    8000602c:	fd2c                	sd	a1,120(a0)
    8000602e:	e150                	sd	a2,128(a0)
    80006030:	e554                	sd	a3,136(a0)
    80006032:	e958                	sd	a4,144(a0)
    80006034:	ed5c                	sd	a5,152(a0)
    80006036:	0b053023          	sd	a6,160(a0)
    8000603a:	0b153423          	sd	a7,168(a0)
    8000603e:	0b253823          	sd	s2,176(a0)
    80006042:	0b353c23          	sd	s3,184(a0)
    80006046:	0d453023          	sd	s4,192(a0)
    8000604a:	0d553423          	sd	s5,200(a0)
    8000604e:	0d653823          	sd	s6,208(a0)
    80006052:	0d753c23          	sd	s7,216(a0)
    80006056:	0f853023          	sd	s8,224(a0)
    8000605a:	0f953423          	sd	s9,232(a0)
    8000605e:	0fa53823          	sd	s10,240(a0)
    80006062:	0fb53c23          	sd	s11,248(a0)
    80006066:	11c53023          	sd	t3,256(a0)
    8000606a:	11d53423          	sd	t4,264(a0)
    8000606e:	11e53823          	sd	t5,272(a0)
    80006072:	11f53c23          	sd	t6,280(a0)
    80006076:	140022f3          	csrr	t0,sscratch
    8000607a:	06553823          	sd	t0,112(a0)
    8000607e:	00853103          	ld	sp,8(a0)
    80006082:	02053203          	ld	tp,32(a0)
    80006086:	01053283          	ld	t0,16(a0)
    8000608a:	00053303          	ld	t1,0(a0)
    8000608e:	12000073          	sfence.vma
    80006092:	18031073          	csrw	satp,t1
    80006096:	12000073          	sfence.vma
    8000609a:	8282                	jr	t0

000000008000609c <userret>:
    8000609c:	12000073          	sfence.vma
    800060a0:	18051073          	csrw	satp,a0
    800060a4:	12000073          	sfence.vma
    800060a8:	02000537          	lui	a0,0x2000
    800060ac:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800060ae:	0536                	slli	a0,a0,0xd
    800060b0:	02853083          	ld	ra,40(a0)
    800060b4:	03053103          	ld	sp,48(a0)
    800060b8:	03853183          	ld	gp,56(a0)
    800060bc:	04053203          	ld	tp,64(a0)
    800060c0:	04853283          	ld	t0,72(a0)
    800060c4:	05053303          	ld	t1,80(a0)
    800060c8:	05853383          	ld	t2,88(a0)
    800060cc:	7120                	ld	s0,96(a0)
    800060ce:	7524                	ld	s1,104(a0)
    800060d0:	7d2c                	ld	a1,120(a0)
    800060d2:	6150                	ld	a2,128(a0)
    800060d4:	6554                	ld	a3,136(a0)
    800060d6:	6958                	ld	a4,144(a0)
    800060d8:	6d5c                	ld	a5,152(a0)
    800060da:	0a053803          	ld	a6,160(a0)
    800060de:	0a853883          	ld	a7,168(a0)
    800060e2:	0b053903          	ld	s2,176(a0)
    800060e6:	0b853983          	ld	s3,184(a0)
    800060ea:	0c053a03          	ld	s4,192(a0)
    800060ee:	0c853a83          	ld	s5,200(a0)
    800060f2:	0d053b03          	ld	s6,208(a0)
    800060f6:	0d853b83          	ld	s7,216(a0)
    800060fa:	0e053c03          	ld	s8,224(a0)
    800060fe:	0e853c83          	ld	s9,232(a0)
    80006102:	0f053d03          	ld	s10,240(a0)
    80006106:	0f853d83          	ld	s11,248(a0)
    8000610a:	10053e03          	ld	t3,256(a0)
    8000610e:	10853e83          	ld	t4,264(a0)
    80006112:	11053f03          	ld	t5,272(a0)
    80006116:	11853f83          	ld	t6,280(a0)
    8000611a:	7928                	ld	a0,112(a0)
    8000611c:	10200073          	sret
	...
