
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	0000a117          	auipc	sp,0xa
    80000004:	2e013103          	ld	sp,736(sp) # 8000a2e0 <_GLOBAL_OFFSET_TABLE_+0x8>
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
    8000006e:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdb18f>
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
    80000158:	1ec50513          	addi	a0,a0,492 # 80012340 <cons>
    8000015c:	299000ef          	jal	80000bf4 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80000160:	00012497          	auipc	s1,0x12
    80000164:	1e048493          	addi	s1,s1,480 # 80012340 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    80000168:	00012917          	auipc	s2,0x12
    8000016c:	27090913          	addi	s2,s2,624 # 800123d8 <cons+0x98>
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
    800001a4:	1a070713          	addi	a4,a4,416 # 80012340 <cons>
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
    800001ee:	15650513          	addi	a0,a0,342 # 80012340 <cons>
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
    80000218:	1cf72223          	sw	a5,452(a4) # 800123d8 <cons+0x98>
    8000021c:	6be2                	ld	s7,24(sp)
    8000021e:	a031                	j	8000022a <consoleread+0xf4>
    80000220:	ec5e                	sd	s7,24(sp)
    80000222:	bfbd                	j	800001a0 <consoleread+0x6a>
    80000224:	6be2                	ld	s7,24(sp)
    80000226:	a011                	j	8000022a <consoleread+0xf4>
    80000228:	6be2                	ld	s7,24(sp)
  release(&cons.lock);
    8000022a:	00012517          	auipc	a0,0x12
    8000022e:	11650513          	addi	a0,a0,278 # 80012340 <cons>
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
    80000282:	0c250513          	addi	a0,a0,194 # 80012340 <cons>
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
    800002a8:	09c50513          	addi	a0,a0,156 # 80012340 <cons>
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
    800002c6:	07e70713          	addi	a4,a4,126 # 80012340 <cons>
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
    800002ec:	05878793          	addi	a5,a5,88 # 80012340 <cons>
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
    8000031a:	0c27a783          	lw	a5,194(a5) # 800123d8 <cons+0x98>
    8000031e:	9f1d                	subw	a4,a4,a5
    80000320:	08000793          	li	a5,128
    80000324:	f8f710e3          	bne	a4,a5,800002a4 <consoleintr+0x32>
    80000328:	a07d                	j	800003d6 <consoleintr+0x164>
    8000032a:	e04a                	sd	s2,0(sp)
    while(cons.e != cons.w &&
    8000032c:	00012717          	auipc	a4,0x12
    80000330:	01470713          	addi	a4,a4,20 # 80012340 <cons>
    80000334:	0a072783          	lw	a5,160(a4)
    80000338:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    8000033c:	00012497          	auipc	s1,0x12
    80000340:	00448493          	addi	s1,s1,4 # 80012340 <cons>
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
    80000382:	fc270713          	addi	a4,a4,-62 # 80012340 <cons>
    80000386:	0a072783          	lw	a5,160(a4)
    8000038a:	09c72703          	lw	a4,156(a4)
    8000038e:	f0f70be3          	beq	a4,a5,800002a4 <consoleintr+0x32>
      cons.e--;
    80000392:	37fd                	addiw	a5,a5,-1
    80000394:	00012717          	auipc	a4,0x12
    80000398:	04f72623          	sw	a5,76(a4) # 800123e0 <cons+0xa0>
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
    800003b6:	f8e78793          	addi	a5,a5,-114 # 80012340 <cons>
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
    800003da:	00c7a323          	sw	a2,6(a5) # 800123dc <cons+0x9c>
        wakeup(&cons.r);
    800003de:	00012517          	auipc	a0,0x12
    800003e2:	ffa50513          	addi	a0,a0,-6 # 800123d8 <cons+0x98>
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
    80000400:	f4450513          	addi	a0,a0,-188 # 80012340 <cons>
    80000404:	770000ef          	jal	80000b74 <initlock>

  uartinit();
    80000408:	3f4000ef          	jal	800007fc <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    8000040c:	00022797          	auipc	a5,0x22
    80000410:	0cc78793          	addi	a5,a5,204 # 800224d8 <devsw>
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
    800004e4:	f207a783          	lw	a5,-224(a5) # 80012400 <pr+0x18>
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
    80000530:	ebc50513          	addi	a0,a0,-324 # 800123e8 <pr>
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
    8000078a:	c6250513          	addi	a0,a0,-926 # 800123e8 <pr>
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
    800007a4:	c607a023          	sw	zero,-928(a5) # 80012400 <pr+0x18>
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
    800007c8:	b2f72e23          	sw	a5,-1220(a4) # 8000a300 <panicked>
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
    800007dc:	c1048493          	addi	s1,s1,-1008 # 800123e8 <pr>
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
    80000844:	bc850513          	addi	a0,a0,-1080 # 80012408 <uart_tx_lock>
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
    80000868:	a9c7a783          	lw	a5,-1380(a5) # 8000a300 <panicked>
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
    8000089e:	a6e7b783          	ld	a5,-1426(a5) # 8000a308 <uart_tx_r>
    800008a2:	0000a717          	auipc	a4,0xa
    800008a6:	a6e73703          	ld	a4,-1426(a4) # 8000a310 <uart_tx_w>
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
    800008cc:	b40a8a93          	addi	s5,s5,-1216 # 80012408 <uart_tx_lock>
    uart_tx_r += 1;
    800008d0:	0000a497          	auipc	s1,0xa
    800008d4:	a3848493          	addi	s1,s1,-1480 # 8000a308 <uart_tx_r>
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    
    WriteReg(THR, c);
    800008d8:	10000a37          	lui	s4,0x10000
    if(uart_tx_w == uart_tx_r){
    800008dc:	0000a997          	auipc	s3,0xa
    800008e0:	a3498993          	addi	s3,s3,-1484 # 8000a310 <uart_tx_w>
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
    80000950:	abc50513          	addi	a0,a0,-1348 # 80012408 <uart_tx_lock>
    80000954:	2a0000ef          	jal	80000bf4 <acquire>
  if(panicked){
    80000958:	0000a797          	auipc	a5,0xa
    8000095c:	9a87a783          	lw	a5,-1624(a5) # 8000a300 <panicked>
    80000960:	efbd                	bnez	a5,800009de <uartputc+0xa4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000962:	0000a717          	auipc	a4,0xa
    80000966:	9ae73703          	ld	a4,-1618(a4) # 8000a310 <uart_tx_w>
    8000096a:	0000a797          	auipc	a5,0xa
    8000096e:	99e7b783          	ld	a5,-1634(a5) # 8000a308 <uart_tx_r>
    80000972:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    80000976:	00012997          	auipc	s3,0x12
    8000097a:	a9298993          	addi	s3,s3,-1390 # 80012408 <uart_tx_lock>
    8000097e:	0000a497          	auipc	s1,0xa
    80000982:	98a48493          	addi	s1,s1,-1654 # 8000a308 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000986:	0000a917          	auipc	s2,0xa
    8000098a:	98a90913          	addi	s2,s2,-1654 # 8000a310 <uart_tx_w>
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
    800009ac:	a6048493          	addi	s1,s1,-1440 # 80012408 <uart_tx_lock>
    800009b0:	01f77793          	andi	a5,a4,31
    800009b4:	97a6                	add	a5,a5,s1
    800009b6:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    800009ba:	0705                	addi	a4,a4,1
    800009bc:	0000a797          	auipc	a5,0xa
    800009c0:	94e7ba23          	sd	a4,-1708(a5) # 8000a310 <uart_tx_w>
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
    80000a24:	9e848493          	addi	s1,s1,-1560 # 80012408 <uart_tx_lock>
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
    80000a56:	00023797          	auipc	a5,0x23
    80000a5a:	c1a78793          	addi	a5,a5,-998 # 80023670 <end>
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
    80000a76:	9ce90913          	addi	s2,s2,-1586 # 80012440 <kmem>
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
    80000b04:	94050513          	addi	a0,a0,-1728 # 80012440 <kmem>
    80000b08:	06c000ef          	jal	80000b74 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b0c:	45c5                	li	a1,17
    80000b0e:	05ee                	slli	a1,a1,0x1b
    80000b10:	00023517          	auipc	a0,0x23
    80000b14:	b6050513          	addi	a0,a0,-1184 # 80023670 <end>
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
    80000b32:	91248493          	addi	s1,s1,-1774 # 80012440 <kmem>
    80000b36:	8526                	mv	a0,s1
    80000b38:	0bc000ef          	jal	80000bf4 <acquire>
  r = kmem.freelist;
    80000b3c:	6c84                	ld	s1,24(s1)
  if(r)
    80000b3e:	c485                	beqz	s1,80000b66 <kalloc+0x42>
    kmem.freelist = r->next;
    80000b40:	609c                	ld	a5,0(s1)
    80000b42:	00012517          	auipc	a0,0x12
    80000b46:	8fe50513          	addi	a0,a0,-1794 # 80012440 <kmem>
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
    80000b6a:	8da50513          	addi	a0,a0,-1830 # 80012440 <kmem>
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
    80000d3c:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffdb991>
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
    80000e72:	4aa70713          	addi	a4,a4,1194 # 8000a318 <started>
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
    80000e98:	634010ef          	jal	800024cc <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000e9c:	4cc040ef          	jal	80005368 <plicinithart>
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
    80000ee0:	5c8010ef          	jal	800024a8 <trapinit>
    trapinithart();  // install kernel trap vector
    80000ee4:	5e8010ef          	jal	800024cc <trapinithart>
    plicinit();      // set up interrupt controller
    80000ee8:	466040ef          	jal	8000534e <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000eec:	47c040ef          	jal	80005368 <plicinithart>
    binit();         // buffer cache
    80000ef0:	423010ef          	jal	80002b12 <binit>
    iinit();         // inode table
    80000ef4:	214020ef          	jal	80003108 <iinit>
    fileinit();      // file table
    80000ef8:	7c1020ef          	jal	80003eb8 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000efc:	55c040ef          	jal	80005458 <virtio_disk_init>
    userinit();      // first user process
    80000f00:	449000ef          	jal	80001b48 <userinit>
    __sync_synchronize();
    80000f04:	0330000f          	fence	rw,rw
    started = 1;
    80000f08:	4785                	li	a5,1
    80000f0a:	00009717          	auipc	a4,0x9
    80000f0e:	40f72723          	sw	a5,1038(a4) # 8000a318 <started>
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
    80000f22:	4027b783          	ld	a5,1026(a5) # 8000a320 <kernel_pagetable>
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
    80000f90:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffdb987>
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
    800011ae:	16a7bb23          	sd	a0,374(a5) # 8000a320 <kernel_pagetable>
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
    80001780:	11448493          	addi	s1,s1,276 # 80012890 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80001784:	8b26                	mv	s6,s1
    80001786:	04fa5937          	lui	s2,0x4fa5
    8000178a:	fa590913          	addi	s2,s2,-91 # 4fa4fa5 <_entry-0x7b05b05b>
    8000178e:	0932                	slli	s2,s2,0xc
    80001790:	fa590913          	addi	s2,s2,-91
    80001794:	0932                	slli	s2,s2,0xc
    80001796:	fa590913          	addi	s2,s2,-91
    8000179a:	0932                	slli	s2,s2,0xc
    8000179c:	fa590913          	addi	s2,s2,-91
    800017a0:	040009b7          	lui	s3,0x4000
    800017a4:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    800017a6:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    800017a8:	00017a97          	auipc	s5,0x17
    800017ac:	ae8a8a93          	addi	s5,s5,-1304 # 80018290 <tickslock>
    char *pa = kalloc();
    800017b0:	b74ff0ef          	jal	80000b24 <kalloc>
    800017b4:	862a                	mv	a2,a0
    if(pa == 0)
    800017b6:	cd15                	beqz	a0,800017f2 <proc_mapstacks+0x8c>
    uint64 va = KSTACK((int) (p - proc));
    800017b8:	416485b3          	sub	a1,s1,s6
    800017bc:	858d                	srai	a1,a1,0x3
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
    800017d6:	16848493          	addi	s1,s1,360
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
    8000181e:	c4650513          	addi	a0,a0,-954 # 80012460 <pid_lock>
    80001822:	b52ff0ef          	jal	80000b74 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001826:	00006597          	auipc	a1,0x6
    8000182a:	9da58593          	addi	a1,a1,-1574 # 80007200 <etext+0x200>
    8000182e:	00011517          	auipc	a0,0x11
    80001832:	c4a50513          	addi	a0,a0,-950 # 80012478 <wait_lock>
    80001836:	b3eff0ef          	jal	80000b74 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000183a:	00011497          	auipc	s1,0x11
    8000183e:	05648493          	addi	s1,s1,86 # 80012890 <proc>
      initlock(&p->lock, "proc");
    80001842:	00006b17          	auipc	s6,0x6
    80001846:	9ceb0b13          	addi	s6,s6,-1586 # 80007210 <etext+0x210>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    8000184a:	8aa6                	mv	s5,s1
    8000184c:	04fa5937          	lui	s2,0x4fa5
    80001850:	fa590913          	addi	s2,s2,-91 # 4fa4fa5 <_entry-0x7b05b05b>
    80001854:	0932                	slli	s2,s2,0xc
    80001856:	fa590913          	addi	s2,s2,-91
    8000185a:	0932                	slli	s2,s2,0xc
    8000185c:	fa590913          	addi	s2,s2,-91
    80001860:	0932                	slli	s2,s2,0xc
    80001862:	fa590913          	addi	s2,s2,-91
    80001866:	040009b7          	lui	s3,0x4000
    8000186a:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    8000186c:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    8000186e:	00017a17          	auipc	s4,0x17
    80001872:	a22a0a13          	addi	s4,s4,-1502 # 80018290 <tickslock>
      initlock(&p->lock, "proc");
    80001876:	85da                	mv	a1,s6
    80001878:	8526                	mv	a0,s1
    8000187a:	afaff0ef          	jal	80000b74 <initlock>
      p->state = UNUSED;
    8000187e:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80001882:	415487b3          	sub	a5,s1,s5
    80001886:	878d                	srai	a5,a5,0x3
    80001888:	032787b3          	mul	a5,a5,s2
    8000188c:	2785                	addiw	a5,a5,1
    8000188e:	00d7979b          	slliw	a5,a5,0xd
    80001892:	40f987b3          	sub	a5,s3,a5
    80001896:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001898:	16848493          	addi	s1,s1,360
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
    800018d4:	bc050513          	addi	a0,a0,-1088 # 80012490 <cpus>
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
    800018f8:	b6c70713          	addi	a4,a4,-1172 # 80012460 <pid_lock>
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
    80001924:	9707a783          	lw	a5,-1680(a5) # 8000a290 <first.1>
    80001928:	e799                	bnez	a5,80001936 <forkret+0x26>
    first = 0;
    // ensure other cores see first=0.
    __sync_synchronize();
  }

  usertrapret();
    8000192a:	3bb000ef          	jal	800024e4 <usertrapret>
}
    8000192e:	60a2                	ld	ra,8(sp)
    80001930:	6402                	ld	s0,0(sp)
    80001932:	0141                	addi	sp,sp,16
    80001934:	8082                	ret
    fsinit(ROOTDEV);
    80001936:	4505                	li	a0,1
    80001938:	764010ef          	jal	8000309c <fsinit>
    first = 0;
    8000193c:	00009797          	auipc	a5,0x9
    80001940:	9407aa23          	sw	zero,-1708(a5) # 8000a290 <first.1>
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
    8000195a:	b0a90913          	addi	s2,s2,-1270 # 80012460 <pid_lock>
    8000195e:	854a                	mv	a0,s2
    80001960:	a94ff0ef          	jal	80000bf4 <acquire>
  pid = nextpid;
    80001964:	00009797          	auipc	a5,0x9
    80001968:	93078793          	addi	a5,a5,-1744 # 8000a294 <nextpid>
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
    80001ab2:	de248493          	addi	s1,s1,-542 # 80012890 <proc>
    80001ab6:	00016917          	auipc	s2,0x16
    80001aba:	7da90913          	addi	s2,s2,2010 # 80018290 <tickslock>
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
    80001ace:	16848493          	addi	s1,s1,360
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
    80001b58:	00008797          	auipc	a5,0x8
    80001b5c:	7ca7b823          	sd	a0,2000(a5) # 8000a328 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001b60:	03400613          	li	a2,52
    80001b64:	00008597          	auipc	a1,0x8
    80001b68:	73c58593          	addi	a1,a1,1852 # 8000a2a0 <initcode>
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
    80001b9a:	611010ef          	jal	800039aa <namei>
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
    80001ca4:	296020ef          	jal	80003f3a <filedup>
    80001ca8:	00a93023          	sd	a0,0(s2)
    80001cac:	b7f5                	j	80001c98 <fork+0x92>
  np->cwd = idup(p->cwd);
    80001cae:	150ab503          	ld	a0,336(s5)
    80001cb2:	5e8010ef          	jal	8000329a <idup>
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
    80001cd2:	00010497          	auipc	s1,0x10
    80001cd6:	7a648493          	addi	s1,s1,1958 # 80012478 <wait_lock>
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
    80001d38:	72c70713          	addi	a4,a4,1836 # 80012460 <pid_lock>
    80001d3c:	975a                	add	a4,a4,s6
    80001d3e:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001d42:	00010717          	auipc	a4,0x10
    80001d46:	75670713          	addi	a4,a4,1878 # 80012498 <cpus+0x8>
    80001d4a:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80001d4c:	4c11                	li	s8,4
        c->proc = p;
    80001d4e:	079e                	slli	a5,a5,0x7
    80001d50:	00010a17          	auipc	s4,0x10
    80001d54:	710a0a13          	addi	s4,s4,1808 # 80012460 <pid_lock>
    80001d58:	9a3e                	add	s4,s4,a5
        found = 1;
    80001d5a:	4b85                	li	s7,1
    for(p = proc; p < &proc[NPROC]; p++) {
    80001d5c:	00016997          	auipc	s3,0x16
    80001d60:	53498993          	addi	s3,s3,1332 # 80018290 <tickslock>
    80001d64:	a0a9                	j	80001dae <scheduler+0x9a>
      release(&p->lock);
    80001d66:	8526                	mv	a0,s1
    80001d68:	f25fe0ef          	jal	80000c8c <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001d6c:	16848493          	addi	s1,s1,360
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
    80001d8e:	6b0000ef          	jal	8000243e <swtch>
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
    80001dc0:	ad448493          	addi	s1,s1,-1324 # 80012890 <proc>
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
    80001dec:	67870713          	addi	a4,a4,1656 # 80012460 <pid_lock>
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
    80001e12:	65290913          	addi	s2,s2,1618 # 80012460 <pid_lock>
    80001e16:	2781                	sext.w	a5,a5
    80001e18:	079e                	slli	a5,a5,0x7
    80001e1a:	97ca                	add	a5,a5,s2
    80001e1c:	0ac7a983          	lw	s3,172(a5)
    80001e20:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001e22:	2781                	sext.w	a5,a5
    80001e24:	079e                	slli	a5,a5,0x7
    80001e26:	00010597          	auipc	a1,0x10
    80001e2a:	67258593          	addi	a1,a1,1650 # 80012498 <cpus+0x8>
    80001e2e:	95be                	add	a1,a1,a5
    80001e30:	06048513          	addi	a0,s1,96
    80001e34:	60a000ef          	jal	8000243e <swtch>
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
    80001f12:	98248493          	addi	s1,s1,-1662 # 80012890 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80001f16:	4989                	li	s3,2
        p->state = RUNNABLE;
    80001f18:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80001f1a:	00016917          	auipc	s2,0x16
    80001f1e:	37690913          	addi	s2,s2,886 # 80018290 <tickslock>
    80001f22:	a801                	j	80001f32 <wakeup+0x38>
      }
      release(&p->lock);
    80001f24:	8526                	mv	a0,s1
    80001f26:	d67fe0ef          	jal	80000c8c <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001f2a:	16848493          	addi	s1,s1,360
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
    80001f7a:	91a48493          	addi	s1,s1,-1766 # 80012890 <proc>
      pp->parent = initproc;
    80001f7e:	00008a17          	auipc	s4,0x8
    80001f82:	3aaa0a13          	addi	s4,s4,938 # 8000a328 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001f86:	00016997          	auipc	s3,0x16
    80001f8a:	30a98993          	addi	s3,s3,778 # 80018290 <tickslock>
    80001f8e:	a029                	j	80001f98 <reparent+0x34>
    80001f90:	16848493          	addi	s1,s1,360
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
    80001fd6:	3567b783          	ld	a5,854(a5) # 8000a328 <initproc>
    80001fda:	0d050493          	addi	s1,a0,208
    80001fde:	15050913          	addi	s2,a0,336
    80001fe2:	00a79f63          	bne	a5,a0,80002000 <exit+0x46>
    panic("init exiting");
    80001fe6:	00005517          	auipc	a0,0x5
    80001fea:	29250513          	addi	a0,a0,658 # 80007278 <etext+0x278>
    80001fee:	fa6fe0ef          	jal	80000794 <panic>
      fileclose(f);
    80001ff2:	78f010ef          	jal	80003f80 <fileclose>
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
    80002006:	361010ef          	jal	80003b66 <begin_op>
  iput(p->cwd);
    8000200a:	1509b503          	ld	a0,336(s3)
    8000200e:	444010ef          	jal	80003452 <iput>
  end_op();
    80002012:	3bf010ef          	jal	80003bd0 <end_op>
  p->cwd = 0;
    80002016:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    8000201a:	00010497          	auipc	s1,0x10
    8000201e:	45e48493          	addi	s1,s1,1118 # 80012478 <wait_lock>
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
    80002070:	82448493          	addi	s1,s1,-2012 # 80012890 <proc>
    80002074:	00016997          	auipc	s3,0x16
    80002078:	21c98993          	addi	s3,s3,540 # 80018290 <tickslock>
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
    8000208e:	16848493          	addi	s1,s1,360
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
    80002134:	34850513          	addi	a0,a0,840 # 80012478 <wait_lock>
    80002138:	abdfe0ef          	jal	80000bf4 <acquire>
    havekids = 0;
    8000213c:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    8000213e:	4a15                	li	s4,5
        havekids = 1;
    80002140:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002142:	00016997          	auipc	s3,0x16
    80002146:	14e98993          	addi	s3,s3,334 # 80018290 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000214a:	00010c17          	auipc	s8,0x10
    8000214e:	32ec0c13          	addi	s8,s8,814 # 80012478 <wait_lock>
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
    80002180:	2fc50513          	addi	a0,a0,764 # 80012478 <wait_lock>
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
    800021ac:	2d050513          	addi	a0,a0,720 # 80012478 <wait_lock>
    800021b0:	addfe0ef          	jal	80000c8c <release>
            return -1;
    800021b4:	59fd                	li	s3,-1
    800021b6:	bfc9                	j	80002188 <wait+0x78>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800021b8:	16848493          	addi	s1,s1,360
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
    800021f4:	6a048493          	addi	s1,s1,1696 # 80012890 <proc>
    800021f8:	b7e1                	j	800021c0 <wait+0xb0>
      release(&wait_lock);
    800021fa:	00010517          	auipc	a0,0x10
    800021fe:	27e50513          	addi	a0,a0,638 # 80012478 <wait_lock>
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
    800022c4:	72848493          	addi	s1,s1,1832 # 800129e8 <proc+0x158>
    800022c8:	00016917          	auipc	s2,0x16
    800022cc:	12090913          	addi	s2,s2,288 # 800183e8 <bcache+0x140>
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
    80002304:	16848493          	addi	s1,s1,360
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
    80002364:	11850513          	addi	a0,a0,280 # 80012478 <wait_lock>
    80002368:	88dfe0ef          	jal	80000bf4 <acquire>
printf("name \t pid \t state \n");
    8000236c:	00005517          	auipc	a0,0x5
    80002370:	f4450513          	addi	a0,a0,-188 # 800072b0 <etext+0x2b0>
    80002374:	94efe0ef          	jal	800004c2 <printf>
for(p = proc; p < &proc[NPROC]; p++){
    80002378:	00010497          	auipc	s1,0x10
    8000237c:	67048493          	addi	s1,s1,1648 # 800129e8 <proc+0x158>
    80002380:	00016a17          	auipc	s4,0x16
    80002384:	068a0a13          	addi	s4,s4,104 # 800183e8 <bcache+0x140>
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
    800023c6:	16848493          	addi	s1,s1,360
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
    8000241a:	06250513          	addi	a0,a0,98 # 80012478 <wait_lock>
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

000000008000243e <swtch>:
    8000243e:	00153023          	sd	ra,0(a0)
    80002442:	00253423          	sd	sp,8(a0)
    80002446:	e900                	sd	s0,16(a0)
    80002448:	ed04                	sd	s1,24(a0)
    8000244a:	03253023          	sd	s2,32(a0)
    8000244e:	03353423          	sd	s3,40(a0)
    80002452:	03453823          	sd	s4,48(a0)
    80002456:	03553c23          	sd	s5,56(a0)
    8000245a:	05653023          	sd	s6,64(a0)
    8000245e:	05753423          	sd	s7,72(a0)
    80002462:	05853823          	sd	s8,80(a0)
    80002466:	05953c23          	sd	s9,88(a0)
    8000246a:	07a53023          	sd	s10,96(a0)
    8000246e:	07b53423          	sd	s11,104(a0)
    80002472:	0005b083          	ld	ra,0(a1)
    80002476:	0085b103          	ld	sp,8(a1)
    8000247a:	6980                	ld	s0,16(a1)
    8000247c:	6d84                	ld	s1,24(a1)
    8000247e:	0205b903          	ld	s2,32(a1)
    80002482:	0285b983          	ld	s3,40(a1)
    80002486:	0305ba03          	ld	s4,48(a1)
    8000248a:	0385ba83          	ld	s5,56(a1)
    8000248e:	0405bb03          	ld	s6,64(a1)
    80002492:	0485bb83          	ld	s7,72(a1)
    80002496:	0505bc03          	ld	s8,80(a1)
    8000249a:	0585bc83          	ld	s9,88(a1)
    8000249e:	0605bd03          	ld	s10,96(a1)
    800024a2:	0685bd83          	ld	s11,104(a1)
    800024a6:	8082                	ret

00000000800024a8 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800024a8:	1141                	addi	sp,sp,-16
    800024aa:	e406                	sd	ra,8(sp)
    800024ac:	e022                	sd	s0,0(sp)
    800024ae:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800024b0:	00005597          	auipc	a1,0x5
    800024b4:	ec058593          	addi	a1,a1,-320 # 80007370 <etext+0x370>
    800024b8:	00016517          	auipc	a0,0x16
    800024bc:	dd850513          	addi	a0,a0,-552 # 80018290 <tickslock>
    800024c0:	eb4fe0ef          	jal	80000b74 <initlock>
}
    800024c4:	60a2                	ld	ra,8(sp)
    800024c6:	6402                	ld	s0,0(sp)
    800024c8:	0141                	addi	sp,sp,16
    800024ca:	8082                	ret

00000000800024cc <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800024cc:	1141                	addi	sp,sp,-16
    800024ce:	e422                	sd	s0,8(sp)
    800024d0:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800024d2:	00003797          	auipc	a5,0x3
    800024d6:	e1e78793          	addi	a5,a5,-482 # 800052f0 <kernelvec>
    800024da:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800024de:	6422                	ld	s0,8(sp)
    800024e0:	0141                	addi	sp,sp,16
    800024e2:	8082                	ret

00000000800024e4 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    800024e4:	1141                	addi	sp,sp,-16
    800024e6:	e406                	sd	ra,8(sp)
    800024e8:	e022                	sd	s0,0(sp)
    800024ea:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800024ec:	bf4ff0ef          	jal	800018e0 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800024f0:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800024f4:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800024f6:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    800024fa:	00004697          	auipc	a3,0x4
    800024fe:	b0668693          	addi	a3,a3,-1274 # 80006000 <_trampoline>
    80002502:	00004717          	auipc	a4,0x4
    80002506:	afe70713          	addi	a4,a4,-1282 # 80006000 <_trampoline>
    8000250a:	8f15                	sub	a4,a4,a3
    8000250c:	040007b7          	lui	a5,0x4000
    80002510:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    80002512:	07b2                	slli	a5,a5,0xc
    80002514:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002516:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    8000251a:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    8000251c:	18002673          	csrr	a2,satp
    80002520:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002522:	6d30                	ld	a2,88(a0)
    80002524:	6138                	ld	a4,64(a0)
    80002526:	6585                	lui	a1,0x1
    80002528:	972e                	add	a4,a4,a1
    8000252a:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    8000252c:	6d38                	ld	a4,88(a0)
    8000252e:	00000617          	auipc	a2,0x0
    80002532:	11060613          	addi	a2,a2,272 # 8000263e <usertrap>
    80002536:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002538:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    8000253a:	8612                	mv	a2,tp
    8000253c:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000253e:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002542:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002546:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000254a:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    8000254e:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002550:	6f18                	ld	a4,24(a4)
    80002552:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002556:	6928                	ld	a0,80(a0)
    80002558:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    8000255a:	00004717          	auipc	a4,0x4
    8000255e:	b4270713          	addi	a4,a4,-1214 # 8000609c <userret>
    80002562:	8f15                	sub	a4,a4,a3
    80002564:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80002566:	577d                	li	a4,-1
    80002568:	177e                	slli	a4,a4,0x3f
    8000256a:	8d59                	or	a0,a0,a4
    8000256c:	9782                	jalr	a5
}
    8000256e:	60a2                	ld	ra,8(sp)
    80002570:	6402                	ld	s0,0(sp)
    80002572:	0141                	addi	sp,sp,16
    80002574:	8082                	ret

0000000080002576 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002576:	1101                	addi	sp,sp,-32
    80002578:	ec06                	sd	ra,24(sp)
    8000257a:	e822                	sd	s0,16(sp)
    8000257c:	1000                	addi	s0,sp,32
  if(cpuid() == 0){
    8000257e:	b36ff0ef          	jal	800018b4 <cpuid>
    80002582:	cd11                	beqz	a0,8000259e <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r" (x) );
    80002584:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    80002588:	000f4737          	lui	a4,0xf4
    8000258c:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80002590:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80002592:	14d79073          	csrw	stimecmp,a5
}
    80002596:	60e2                	ld	ra,24(sp)
    80002598:	6442                	ld	s0,16(sp)
    8000259a:	6105                	addi	sp,sp,32
    8000259c:	8082                	ret
    8000259e:	e426                	sd	s1,8(sp)
    acquire(&tickslock);
    800025a0:	00016497          	auipc	s1,0x16
    800025a4:	cf048493          	addi	s1,s1,-784 # 80018290 <tickslock>
    800025a8:	8526                	mv	a0,s1
    800025aa:	e4afe0ef          	jal	80000bf4 <acquire>
    ticks++;
    800025ae:	00008517          	auipc	a0,0x8
    800025b2:	d8250513          	addi	a0,a0,-638 # 8000a330 <ticks>
    800025b6:	411c                	lw	a5,0(a0)
    800025b8:	2785                	addiw	a5,a5,1
    800025ba:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    800025bc:	93fff0ef          	jal	80001efa <wakeup>
    release(&tickslock);
    800025c0:	8526                	mv	a0,s1
    800025c2:	ecafe0ef          	jal	80000c8c <release>
    800025c6:	64a2                	ld	s1,8(sp)
    800025c8:	bf75                	j	80002584 <clockintr+0xe>

00000000800025ca <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    800025ca:	1101                	addi	sp,sp,-32
    800025cc:	ec06                	sd	ra,24(sp)
    800025ce:	e822                	sd	s0,16(sp)
    800025d0:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    800025d2:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    800025d6:	57fd                	li	a5,-1
    800025d8:	17fe                	slli	a5,a5,0x3f
    800025da:	07a5                	addi	a5,a5,9
    800025dc:	00f70c63          	beq	a4,a5,800025f4 <devintr+0x2a>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    800025e0:	57fd                	li	a5,-1
    800025e2:	17fe                	slli	a5,a5,0x3f
    800025e4:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    800025e6:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    800025e8:	04f70763          	beq	a4,a5,80002636 <devintr+0x6c>
  }
}
    800025ec:	60e2                	ld	ra,24(sp)
    800025ee:	6442                	ld	s0,16(sp)
    800025f0:	6105                	addi	sp,sp,32
    800025f2:	8082                	ret
    800025f4:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    800025f6:	5a7020ef          	jal	8000539c <plic_claim>
    800025fa:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    800025fc:	47a9                	li	a5,10
    800025fe:	00f50963          	beq	a0,a5,80002610 <devintr+0x46>
    } else if(irq == VIRTIO0_IRQ){
    80002602:	4785                	li	a5,1
    80002604:	00f50963          	beq	a0,a5,80002616 <devintr+0x4c>
    return 1;
    80002608:	4505                	li	a0,1
    } else if(irq){
    8000260a:	e889                	bnez	s1,8000261c <devintr+0x52>
    8000260c:	64a2                	ld	s1,8(sp)
    8000260e:	bff9                	j	800025ec <devintr+0x22>
      uartintr();
    80002610:	bf6fe0ef          	jal	80000a06 <uartintr>
    if(irq)
    80002614:	a819                	j	8000262a <devintr+0x60>
      virtio_disk_intr();
    80002616:	24c030ef          	jal	80005862 <virtio_disk_intr>
    if(irq)
    8000261a:	a801                	j	8000262a <devintr+0x60>
      printf("unexpected interrupt irq=%d\n", irq);
    8000261c:	85a6                	mv	a1,s1
    8000261e:	00005517          	auipc	a0,0x5
    80002622:	d5a50513          	addi	a0,a0,-678 # 80007378 <etext+0x378>
    80002626:	e9dfd0ef          	jal	800004c2 <printf>
      plic_complete(irq);
    8000262a:	8526                	mv	a0,s1
    8000262c:	591020ef          	jal	800053bc <plic_complete>
    return 1;
    80002630:	4505                	li	a0,1
    80002632:	64a2                	ld	s1,8(sp)
    80002634:	bf65                	j	800025ec <devintr+0x22>
    clockintr();
    80002636:	f41ff0ef          	jal	80002576 <clockintr>
    return 2;
    8000263a:	4509                	li	a0,2
    8000263c:	bf45                	j	800025ec <devintr+0x22>

000000008000263e <usertrap>:
{
    8000263e:	1101                	addi	sp,sp,-32
    80002640:	ec06                	sd	ra,24(sp)
    80002642:	e822                	sd	s0,16(sp)
    80002644:	e426                	sd	s1,8(sp)
    80002646:	e04a                	sd	s2,0(sp)
    80002648:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000264a:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    8000264e:	1007f793          	andi	a5,a5,256
    80002652:	ef85                	bnez	a5,8000268a <usertrap+0x4c>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002654:	00003797          	auipc	a5,0x3
    80002658:	c9c78793          	addi	a5,a5,-868 # 800052f0 <kernelvec>
    8000265c:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002660:	a80ff0ef          	jal	800018e0 <myproc>
    80002664:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002666:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002668:	14102773          	csrr	a4,sepc
    8000266c:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000266e:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002672:	47a1                	li	a5,8
    80002674:	02f70163          	beq	a4,a5,80002696 <usertrap+0x58>
  } else if((which_dev = devintr()) != 0){
    80002678:	f53ff0ef          	jal	800025ca <devintr>
    8000267c:	892a                	mv	s2,a0
    8000267e:	c135                	beqz	a0,800026e2 <usertrap+0xa4>
  if(killed(p))
    80002680:	8526                	mv	a0,s1
    80002682:	a65ff0ef          	jal	800020e6 <killed>
    80002686:	cd1d                	beqz	a0,800026c4 <usertrap+0x86>
    80002688:	a81d                	j	800026be <usertrap+0x80>
    panic("usertrap: not from user mode");
    8000268a:	00005517          	auipc	a0,0x5
    8000268e:	d0e50513          	addi	a0,a0,-754 # 80007398 <etext+0x398>
    80002692:	902fe0ef          	jal	80000794 <panic>
    if(killed(p))
    80002696:	a51ff0ef          	jal	800020e6 <killed>
    8000269a:	e121                	bnez	a0,800026da <usertrap+0x9c>
    p->trapframe->epc += 4;
    8000269c:	6cb8                	ld	a4,88(s1)
    8000269e:	6f1c                	ld	a5,24(a4)
    800026a0:	0791                	addi	a5,a5,4
    800026a2:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800026a4:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800026a8:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800026ac:	10079073          	csrw	sstatus,a5
    syscall();
    800026b0:	248000ef          	jal	800028f8 <syscall>
  if(killed(p))
    800026b4:	8526                	mv	a0,s1
    800026b6:	a31ff0ef          	jal	800020e6 <killed>
    800026ba:	c901                	beqz	a0,800026ca <usertrap+0x8c>
    800026bc:	4901                	li	s2,0
    exit(-1);
    800026be:	557d                	li	a0,-1
    800026c0:	8fbff0ef          	jal	80001fba <exit>
  if(which_dev == 2)
    800026c4:	4789                	li	a5,2
    800026c6:	04f90563          	beq	s2,a5,80002710 <usertrap+0xd2>
  usertrapret();
    800026ca:	e1bff0ef          	jal	800024e4 <usertrapret>
}
    800026ce:	60e2                	ld	ra,24(sp)
    800026d0:	6442                	ld	s0,16(sp)
    800026d2:	64a2                	ld	s1,8(sp)
    800026d4:	6902                	ld	s2,0(sp)
    800026d6:	6105                	addi	sp,sp,32
    800026d8:	8082                	ret
      exit(-1);
    800026da:	557d                	li	a0,-1
    800026dc:	8dfff0ef          	jal	80001fba <exit>
    800026e0:	bf75                	j	8000269c <usertrap+0x5e>
  asm volatile("csrr %0, scause" : "=r" (x) );
    800026e2:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    800026e6:	5890                	lw	a2,48(s1)
    800026e8:	00005517          	auipc	a0,0x5
    800026ec:	cd050513          	addi	a0,a0,-816 # 800073b8 <etext+0x3b8>
    800026f0:	dd3fd0ef          	jal	800004c2 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800026f4:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800026f8:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    800026fc:	00005517          	auipc	a0,0x5
    80002700:	cec50513          	addi	a0,a0,-788 # 800073e8 <etext+0x3e8>
    80002704:	dbffd0ef          	jal	800004c2 <printf>
    setkilled(p);
    80002708:	8526                	mv	a0,s1
    8000270a:	9b9ff0ef          	jal	800020c2 <setkilled>
    8000270e:	b75d                	j	800026b4 <usertrap+0x76>
    yield();
    80002710:	f72ff0ef          	jal	80001e82 <yield>
    80002714:	bf5d                	j	800026ca <usertrap+0x8c>

0000000080002716 <kerneltrap>:
{
    80002716:	7179                	addi	sp,sp,-48
    80002718:	f406                	sd	ra,40(sp)
    8000271a:	f022                	sd	s0,32(sp)
    8000271c:	ec26                	sd	s1,24(sp)
    8000271e:	e84a                	sd	s2,16(sp)
    80002720:	e44e                	sd	s3,8(sp)
    80002722:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002724:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002728:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000272c:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002730:	1004f793          	andi	a5,s1,256
    80002734:	c795                	beqz	a5,80002760 <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002736:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000273a:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    8000273c:	eb85                	bnez	a5,8000276c <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    8000273e:	e8dff0ef          	jal	800025ca <devintr>
    80002742:	c91d                	beqz	a0,80002778 <kerneltrap+0x62>
  if(which_dev == 2 && myproc() != 0)
    80002744:	4789                	li	a5,2
    80002746:	04f50a63          	beq	a0,a5,8000279a <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r" (x));
    8000274a:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000274e:	10049073          	csrw	sstatus,s1
}
    80002752:	70a2                	ld	ra,40(sp)
    80002754:	7402                	ld	s0,32(sp)
    80002756:	64e2                	ld	s1,24(sp)
    80002758:	6942                	ld	s2,16(sp)
    8000275a:	69a2                	ld	s3,8(sp)
    8000275c:	6145                	addi	sp,sp,48
    8000275e:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002760:	00005517          	auipc	a0,0x5
    80002764:	cb050513          	addi	a0,a0,-848 # 80007410 <etext+0x410>
    80002768:	82cfe0ef          	jal	80000794 <panic>
    panic("kerneltrap: interrupts enabled");
    8000276c:	00005517          	auipc	a0,0x5
    80002770:	ccc50513          	addi	a0,a0,-820 # 80007438 <etext+0x438>
    80002774:	820fe0ef          	jal	80000794 <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002778:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000277c:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    80002780:	85ce                	mv	a1,s3
    80002782:	00005517          	auipc	a0,0x5
    80002786:	cd650513          	addi	a0,a0,-810 # 80007458 <etext+0x458>
    8000278a:	d39fd0ef          	jal	800004c2 <printf>
    panic("kerneltrap");
    8000278e:	00005517          	auipc	a0,0x5
    80002792:	cf250513          	addi	a0,a0,-782 # 80007480 <etext+0x480>
    80002796:	ffffd0ef          	jal	80000794 <panic>
  if(which_dev == 2 && myproc() != 0)
    8000279a:	946ff0ef          	jal	800018e0 <myproc>
    8000279e:	d555                	beqz	a0,8000274a <kerneltrap+0x34>
    yield();
    800027a0:	ee2ff0ef          	jal	80001e82 <yield>
    800027a4:	b75d                	j	8000274a <kerneltrap+0x34>

00000000800027a6 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    800027a6:	1101                	addi	sp,sp,-32
    800027a8:	ec06                	sd	ra,24(sp)
    800027aa:	e822                	sd	s0,16(sp)
    800027ac:	e426                	sd	s1,8(sp)
    800027ae:	1000                	addi	s0,sp,32
    800027b0:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800027b2:	92eff0ef          	jal	800018e0 <myproc>
  switch (n) {
    800027b6:	4795                	li	a5,5
    800027b8:	0497e163          	bltu	a5,s1,800027fa <argraw+0x54>
    800027bc:	048a                	slli	s1,s1,0x2
    800027be:	00005717          	auipc	a4,0x5
    800027c2:	09a70713          	addi	a4,a4,154 # 80007858 <states.0+0x30>
    800027c6:	94ba                	add	s1,s1,a4
    800027c8:	409c                	lw	a5,0(s1)
    800027ca:	97ba                	add	a5,a5,a4
    800027cc:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    800027ce:	6d3c                	ld	a5,88(a0)
    800027d0:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    800027d2:	60e2                	ld	ra,24(sp)
    800027d4:	6442                	ld	s0,16(sp)
    800027d6:	64a2                	ld	s1,8(sp)
    800027d8:	6105                	addi	sp,sp,32
    800027da:	8082                	ret
    return p->trapframe->a1;
    800027dc:	6d3c                	ld	a5,88(a0)
    800027de:	7fa8                	ld	a0,120(a5)
    800027e0:	bfcd                	j	800027d2 <argraw+0x2c>
    return p->trapframe->a2;
    800027e2:	6d3c                	ld	a5,88(a0)
    800027e4:	63c8                	ld	a0,128(a5)
    800027e6:	b7f5                	j	800027d2 <argraw+0x2c>
    return p->trapframe->a3;
    800027e8:	6d3c                	ld	a5,88(a0)
    800027ea:	67c8                	ld	a0,136(a5)
    800027ec:	b7dd                	j	800027d2 <argraw+0x2c>
    return p->trapframe->a4;
    800027ee:	6d3c                	ld	a5,88(a0)
    800027f0:	6bc8                	ld	a0,144(a5)
    800027f2:	b7c5                	j	800027d2 <argraw+0x2c>
    return p->trapframe->a5;
    800027f4:	6d3c                	ld	a5,88(a0)
    800027f6:	6fc8                	ld	a0,152(a5)
    800027f8:	bfe9                	j	800027d2 <argraw+0x2c>
  panic("argraw");
    800027fa:	00005517          	auipc	a0,0x5
    800027fe:	c9650513          	addi	a0,a0,-874 # 80007490 <etext+0x490>
    80002802:	f93fd0ef          	jal	80000794 <panic>

0000000080002806 <fetchaddr>:
{
    80002806:	1101                	addi	sp,sp,-32
    80002808:	ec06                	sd	ra,24(sp)
    8000280a:	e822                	sd	s0,16(sp)
    8000280c:	e426                	sd	s1,8(sp)
    8000280e:	e04a                	sd	s2,0(sp)
    80002810:	1000                	addi	s0,sp,32
    80002812:	84aa                	mv	s1,a0
    80002814:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002816:	8caff0ef          	jal	800018e0 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    8000281a:	653c                	ld	a5,72(a0)
    8000281c:	02f4f663          	bgeu	s1,a5,80002848 <fetchaddr+0x42>
    80002820:	00848713          	addi	a4,s1,8
    80002824:	02e7e463          	bltu	a5,a4,8000284c <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002828:	46a1                	li	a3,8
    8000282a:	8626                	mv	a2,s1
    8000282c:	85ca                	mv	a1,s2
    8000282e:	6928                	ld	a0,80(a0)
    80002830:	df9fe0ef          	jal	80001628 <copyin>
    80002834:	00a03533          	snez	a0,a0
    80002838:	40a00533          	neg	a0,a0
}
    8000283c:	60e2                	ld	ra,24(sp)
    8000283e:	6442                	ld	s0,16(sp)
    80002840:	64a2                	ld	s1,8(sp)
    80002842:	6902                	ld	s2,0(sp)
    80002844:	6105                	addi	sp,sp,32
    80002846:	8082                	ret
    return -1;
    80002848:	557d                	li	a0,-1
    8000284a:	bfcd                	j	8000283c <fetchaddr+0x36>
    8000284c:	557d                	li	a0,-1
    8000284e:	b7fd                	j	8000283c <fetchaddr+0x36>

0000000080002850 <fetchstr>:
{
    80002850:	7179                	addi	sp,sp,-48
    80002852:	f406                	sd	ra,40(sp)
    80002854:	f022                	sd	s0,32(sp)
    80002856:	ec26                	sd	s1,24(sp)
    80002858:	e84a                	sd	s2,16(sp)
    8000285a:	e44e                	sd	s3,8(sp)
    8000285c:	1800                	addi	s0,sp,48
    8000285e:	892a                	mv	s2,a0
    80002860:	84ae                	mv	s1,a1
    80002862:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002864:	87cff0ef          	jal	800018e0 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002868:	86ce                	mv	a3,s3
    8000286a:	864a                	mv	a2,s2
    8000286c:	85a6                	mv	a1,s1
    8000286e:	6928                	ld	a0,80(a0)
    80002870:	e3ffe0ef          	jal	800016ae <copyinstr>
    80002874:	00054c63          	bltz	a0,8000288c <fetchstr+0x3c>
  return strlen(buf);
    80002878:	8526                	mv	a0,s1
    8000287a:	dbefe0ef          	jal	80000e38 <strlen>
}
    8000287e:	70a2                	ld	ra,40(sp)
    80002880:	7402                	ld	s0,32(sp)
    80002882:	64e2                	ld	s1,24(sp)
    80002884:	6942                	ld	s2,16(sp)
    80002886:	69a2                	ld	s3,8(sp)
    80002888:	6145                	addi	sp,sp,48
    8000288a:	8082                	ret
    return -1;
    8000288c:	557d                	li	a0,-1
    8000288e:	bfc5                	j	8000287e <fetchstr+0x2e>

0000000080002890 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002890:	1101                	addi	sp,sp,-32
    80002892:	ec06                	sd	ra,24(sp)
    80002894:	e822                	sd	s0,16(sp)
    80002896:	e426                	sd	s1,8(sp)
    80002898:	1000                	addi	s0,sp,32
    8000289a:	84ae                	mv	s1,a1
  *ip = argraw(n);
    8000289c:	f0bff0ef          	jal	800027a6 <argraw>
    800028a0:	c088                	sw	a0,0(s1)
}
    800028a2:	60e2                	ld	ra,24(sp)
    800028a4:	6442                	ld	s0,16(sp)
    800028a6:	64a2                	ld	s1,8(sp)
    800028a8:	6105                	addi	sp,sp,32
    800028aa:	8082                	ret

00000000800028ac <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    800028ac:	1101                	addi	sp,sp,-32
    800028ae:	ec06                	sd	ra,24(sp)
    800028b0:	e822                	sd	s0,16(sp)
    800028b2:	e426                	sd	s1,8(sp)
    800028b4:	1000                	addi	s0,sp,32
    800028b6:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800028b8:	eefff0ef          	jal	800027a6 <argraw>
    800028bc:	e088                	sd	a0,0(s1)
}
    800028be:	60e2                	ld	ra,24(sp)
    800028c0:	6442                	ld	s0,16(sp)
    800028c2:	64a2                	ld	s1,8(sp)
    800028c4:	6105                	addi	sp,sp,32
    800028c6:	8082                	ret

00000000800028c8 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    800028c8:	7179                	addi	sp,sp,-48
    800028ca:	f406                	sd	ra,40(sp)
    800028cc:	f022                	sd	s0,32(sp)
    800028ce:	ec26                	sd	s1,24(sp)
    800028d0:	e84a                	sd	s2,16(sp)
    800028d2:	1800                	addi	s0,sp,48
    800028d4:	84ae                	mv	s1,a1
    800028d6:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    800028d8:	fd840593          	addi	a1,s0,-40
    800028dc:	fd1ff0ef          	jal	800028ac <argaddr>
  return fetchstr(addr, buf, max);
    800028e0:	864a                	mv	a2,s2
    800028e2:	85a6                	mv	a1,s1
    800028e4:	fd843503          	ld	a0,-40(s0)
    800028e8:	f69ff0ef          	jal	80002850 <fetchstr>
}
    800028ec:	70a2                	ld	ra,40(sp)
    800028ee:	7402                	ld	s0,32(sp)
    800028f0:	64e2                	ld	s1,24(sp)
    800028f2:	6942                	ld	s2,16(sp)
    800028f4:	6145                	addi	sp,sp,48
    800028f6:	8082                	ret

00000000800028f8 <syscall>:
[SYS_ps]     sys_ps,
};

void
syscall(void)
{
    800028f8:	1101                	addi	sp,sp,-32
    800028fa:	ec06                	sd	ra,24(sp)
    800028fc:	e822                	sd	s0,16(sp)
    800028fe:	e426                	sd	s1,8(sp)
    80002900:	e04a                	sd	s2,0(sp)
    80002902:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002904:	fddfe0ef          	jal	800018e0 <myproc>
    80002908:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    8000290a:	05853903          	ld	s2,88(a0)
    8000290e:	0a893783          	ld	a5,168(s2)
    80002912:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002916:	37fd                	addiw	a5,a5,-1
    80002918:	4755                	li	a4,21
    8000291a:	00f76f63          	bltu	a4,a5,80002938 <syscall+0x40>
    8000291e:	00369713          	slli	a4,a3,0x3
    80002922:	00005797          	auipc	a5,0x5
    80002926:	f4e78793          	addi	a5,a5,-178 # 80007870 <syscalls>
    8000292a:	97ba                	add	a5,a5,a4
    8000292c:	639c                	ld	a5,0(a5)
    8000292e:	c789                	beqz	a5,80002938 <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002930:	9782                	jalr	a5
    80002932:	06a93823          	sd	a0,112(s2)
    80002936:	a829                	j	80002950 <syscall+0x58>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002938:	15848613          	addi	a2,s1,344
    8000293c:	588c                	lw	a1,48(s1)
    8000293e:	00005517          	auipc	a0,0x5
    80002942:	b5a50513          	addi	a0,a0,-1190 # 80007498 <etext+0x498>
    80002946:	b7dfd0ef          	jal	800004c2 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    8000294a:	6cbc                	ld	a5,88(s1)
    8000294c:	577d                	li	a4,-1
    8000294e:	fbb8                	sd	a4,112(a5)
  }
}
    80002950:	60e2                	ld	ra,24(sp)
    80002952:	6442                	ld	s0,16(sp)
    80002954:	64a2                	ld	s1,8(sp)
    80002956:	6902                	ld	s2,0(sp)
    80002958:	6105                	addi	sp,sp,32
    8000295a:	8082                	ret

000000008000295c <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    8000295c:	1101                	addi	sp,sp,-32
    8000295e:	ec06                	sd	ra,24(sp)
    80002960:	e822                	sd	s0,16(sp)
    80002962:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002964:	fec40593          	addi	a1,s0,-20
    80002968:	4501                	li	a0,0
    8000296a:	f27ff0ef          	jal	80002890 <argint>
  exit(n);
    8000296e:	fec42503          	lw	a0,-20(s0)
    80002972:	e48ff0ef          	jal	80001fba <exit>
  return 0;  // not reached
}
    80002976:	4501                	li	a0,0
    80002978:	60e2                	ld	ra,24(sp)
    8000297a:	6442                	ld	s0,16(sp)
    8000297c:	6105                	addi	sp,sp,32
    8000297e:	8082                	ret

0000000080002980 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002980:	1141                	addi	sp,sp,-16
    80002982:	e406                	sd	ra,8(sp)
    80002984:	e022                	sd	s0,0(sp)
    80002986:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002988:	f59fe0ef          	jal	800018e0 <myproc>
}
    8000298c:	5908                	lw	a0,48(a0)
    8000298e:	60a2                	ld	ra,8(sp)
    80002990:	6402                	ld	s0,0(sp)
    80002992:	0141                	addi	sp,sp,16
    80002994:	8082                	ret

0000000080002996 <sys_fork>:

uint64
sys_fork(void)
{
    80002996:	1141                	addi	sp,sp,-16
    80002998:	e406                	sd	ra,8(sp)
    8000299a:	e022                	sd	s0,0(sp)
    8000299c:	0800                	addi	s0,sp,16
  return fork();
    8000299e:	a68ff0ef          	jal	80001c06 <fork>
}
    800029a2:	60a2                	ld	ra,8(sp)
    800029a4:	6402                	ld	s0,0(sp)
    800029a6:	0141                	addi	sp,sp,16
    800029a8:	8082                	ret

00000000800029aa <sys_wait>:

uint64
sys_wait(void)
{
    800029aa:	1101                	addi	sp,sp,-32
    800029ac:	ec06                	sd	ra,24(sp)
    800029ae:	e822                	sd	s0,16(sp)
    800029b0:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    800029b2:	fe840593          	addi	a1,s0,-24
    800029b6:	4501                	li	a0,0
    800029b8:	ef5ff0ef          	jal	800028ac <argaddr>
  return wait(p);
    800029bc:	fe843503          	ld	a0,-24(s0)
    800029c0:	f50ff0ef          	jal	80002110 <wait>
}
    800029c4:	60e2                	ld	ra,24(sp)
    800029c6:	6442                	ld	s0,16(sp)
    800029c8:	6105                	addi	sp,sp,32
    800029ca:	8082                	ret

00000000800029cc <sys_sbrk>:

uint64
sys_sbrk(void)
{
    800029cc:	7179                	addi	sp,sp,-48
    800029ce:	f406                	sd	ra,40(sp)
    800029d0:	f022                	sd	s0,32(sp)
    800029d2:	ec26                	sd	s1,24(sp)
    800029d4:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    800029d6:	fdc40593          	addi	a1,s0,-36
    800029da:	4501                	li	a0,0
    800029dc:	eb5ff0ef          	jal	80002890 <argint>
  addr = myproc()->sz;
    800029e0:	f01fe0ef          	jal	800018e0 <myproc>
    800029e4:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    800029e6:	fdc42503          	lw	a0,-36(s0)
    800029ea:	9ccff0ef          	jal	80001bb6 <growproc>
    800029ee:	00054863          	bltz	a0,800029fe <sys_sbrk+0x32>
    return -1;
  return addr;
}
    800029f2:	8526                	mv	a0,s1
    800029f4:	70a2                	ld	ra,40(sp)
    800029f6:	7402                	ld	s0,32(sp)
    800029f8:	64e2                	ld	s1,24(sp)
    800029fa:	6145                	addi	sp,sp,48
    800029fc:	8082                	ret
    return -1;
    800029fe:	54fd                	li	s1,-1
    80002a00:	bfcd                	j	800029f2 <sys_sbrk+0x26>

0000000080002a02 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002a02:	7139                	addi	sp,sp,-64
    80002a04:	fc06                	sd	ra,56(sp)
    80002a06:	f822                	sd	s0,48(sp)
    80002a08:	f04a                	sd	s2,32(sp)
    80002a0a:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002a0c:	fcc40593          	addi	a1,s0,-52
    80002a10:	4501                	li	a0,0
    80002a12:	e7fff0ef          	jal	80002890 <argint>
  if(n < 0)
    80002a16:	fcc42783          	lw	a5,-52(s0)
    80002a1a:	0607c763          	bltz	a5,80002a88 <sys_sleep+0x86>
    n = 0;
  acquire(&tickslock);
    80002a1e:	00016517          	auipc	a0,0x16
    80002a22:	87250513          	addi	a0,a0,-1934 # 80018290 <tickslock>
    80002a26:	9cefe0ef          	jal	80000bf4 <acquire>
  ticks0 = ticks;
    80002a2a:	00008917          	auipc	s2,0x8
    80002a2e:	90692903          	lw	s2,-1786(s2) # 8000a330 <ticks>
  while(ticks - ticks0 < n){
    80002a32:	fcc42783          	lw	a5,-52(s0)
    80002a36:	cf8d                	beqz	a5,80002a70 <sys_sleep+0x6e>
    80002a38:	f426                	sd	s1,40(sp)
    80002a3a:	ec4e                	sd	s3,24(sp)
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002a3c:	00016997          	auipc	s3,0x16
    80002a40:	85498993          	addi	s3,s3,-1964 # 80018290 <tickslock>
    80002a44:	00008497          	auipc	s1,0x8
    80002a48:	8ec48493          	addi	s1,s1,-1812 # 8000a330 <ticks>
    if(killed(myproc())){
    80002a4c:	e95fe0ef          	jal	800018e0 <myproc>
    80002a50:	e96ff0ef          	jal	800020e6 <killed>
    80002a54:	ed0d                	bnez	a0,80002a8e <sys_sleep+0x8c>
    sleep(&ticks, &tickslock);
    80002a56:	85ce                	mv	a1,s3
    80002a58:	8526                	mv	a0,s1
    80002a5a:	c54ff0ef          	jal	80001eae <sleep>
  while(ticks - ticks0 < n){
    80002a5e:	409c                	lw	a5,0(s1)
    80002a60:	412787bb          	subw	a5,a5,s2
    80002a64:	fcc42703          	lw	a4,-52(s0)
    80002a68:	fee7e2e3          	bltu	a5,a4,80002a4c <sys_sleep+0x4a>
    80002a6c:	74a2                	ld	s1,40(sp)
    80002a6e:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80002a70:	00016517          	auipc	a0,0x16
    80002a74:	82050513          	addi	a0,a0,-2016 # 80018290 <tickslock>
    80002a78:	a14fe0ef          	jal	80000c8c <release>
  return 0;
    80002a7c:	4501                	li	a0,0
}
    80002a7e:	70e2                	ld	ra,56(sp)
    80002a80:	7442                	ld	s0,48(sp)
    80002a82:	7902                	ld	s2,32(sp)
    80002a84:	6121                	addi	sp,sp,64
    80002a86:	8082                	ret
    n = 0;
    80002a88:	fc042623          	sw	zero,-52(s0)
    80002a8c:	bf49                	j	80002a1e <sys_sleep+0x1c>
      release(&tickslock);
    80002a8e:	00016517          	auipc	a0,0x16
    80002a92:	80250513          	addi	a0,a0,-2046 # 80018290 <tickslock>
    80002a96:	9f6fe0ef          	jal	80000c8c <release>
      return -1;
    80002a9a:	557d                	li	a0,-1
    80002a9c:	74a2                	ld	s1,40(sp)
    80002a9e:	69e2                	ld	s3,24(sp)
    80002aa0:	bff9                	j	80002a7e <sys_sleep+0x7c>

0000000080002aa2 <sys_kill>:

uint64
sys_kill(void)
{
    80002aa2:	1101                	addi	sp,sp,-32
    80002aa4:	ec06                	sd	ra,24(sp)
    80002aa6:	e822                	sd	s0,16(sp)
    80002aa8:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002aaa:	fec40593          	addi	a1,s0,-20
    80002aae:	4501                	li	a0,0
    80002ab0:	de1ff0ef          	jal	80002890 <argint>
  return kill(pid);
    80002ab4:	fec42503          	lw	a0,-20(s0)
    80002ab8:	da4ff0ef          	jal	8000205c <kill>
}
    80002abc:	60e2                	ld	ra,24(sp)
    80002abe:	6442                	ld	s0,16(sp)
    80002ac0:	6105                	addi	sp,sp,32
    80002ac2:	8082                	ret

0000000080002ac4 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002ac4:	1101                	addi	sp,sp,-32
    80002ac6:	ec06                	sd	ra,24(sp)
    80002ac8:	e822                	sd	s0,16(sp)
    80002aca:	e426                	sd	s1,8(sp)
    80002acc:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002ace:	00015517          	auipc	a0,0x15
    80002ad2:	7c250513          	addi	a0,a0,1986 # 80018290 <tickslock>
    80002ad6:	91efe0ef          	jal	80000bf4 <acquire>
  xticks = ticks;
    80002ada:	00008497          	auipc	s1,0x8
    80002ade:	8564a483          	lw	s1,-1962(s1) # 8000a330 <ticks>
  release(&tickslock);
    80002ae2:	00015517          	auipc	a0,0x15
    80002ae6:	7ae50513          	addi	a0,a0,1966 # 80018290 <tickslock>
    80002aea:	9a2fe0ef          	jal	80000c8c <release>
  return xticks;
}
    80002aee:	02049513          	slli	a0,s1,0x20
    80002af2:	9101                	srli	a0,a0,0x20
    80002af4:	60e2                	ld	ra,24(sp)
    80002af6:	6442                	ld	s0,16(sp)
    80002af8:	64a2                	ld	s1,8(sp)
    80002afa:	6105                	addi	sp,sp,32
    80002afc:	8082                	ret

0000000080002afe <sys_ps>:

uint64
sys_ps ( void )
{
    80002afe:	1141                	addi	sp,sp,-16
    80002b00:	e406                	sd	ra,8(sp)
    80002b02:	e022                	sd	s0,0(sp)
    80002b04:	0800                	addi	s0,sp,16
return ps ();
    80002b06:	83dff0ef          	jal	80002342 <ps>
}  
    80002b0a:	60a2                	ld	ra,8(sp)
    80002b0c:	6402                	ld	s0,0(sp)
    80002b0e:	0141                	addi	sp,sp,16
    80002b10:	8082                	ret

0000000080002b12 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002b12:	7179                	addi	sp,sp,-48
    80002b14:	f406                	sd	ra,40(sp)
    80002b16:	f022                	sd	s0,32(sp)
    80002b18:	ec26                	sd	s1,24(sp)
    80002b1a:	e84a                	sd	s2,16(sp)
    80002b1c:	e44e                	sd	s3,8(sp)
    80002b1e:	e052                	sd	s4,0(sp)
    80002b20:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002b22:	00005597          	auipc	a1,0x5
    80002b26:	99658593          	addi	a1,a1,-1642 # 800074b8 <etext+0x4b8>
    80002b2a:	00015517          	auipc	a0,0x15
    80002b2e:	77e50513          	addi	a0,a0,1918 # 800182a8 <bcache>
    80002b32:	842fe0ef          	jal	80000b74 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002b36:	0001d797          	auipc	a5,0x1d
    80002b3a:	77278793          	addi	a5,a5,1906 # 800202a8 <bcache+0x8000>
    80002b3e:	0001e717          	auipc	a4,0x1e
    80002b42:	9d270713          	addi	a4,a4,-1582 # 80020510 <bcache+0x8268>
    80002b46:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002b4a:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002b4e:	00015497          	auipc	s1,0x15
    80002b52:	77248493          	addi	s1,s1,1906 # 800182c0 <bcache+0x18>
    b->next = bcache.head.next;
    80002b56:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002b58:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002b5a:	00005a17          	auipc	s4,0x5
    80002b5e:	966a0a13          	addi	s4,s4,-1690 # 800074c0 <etext+0x4c0>
    b->next = bcache.head.next;
    80002b62:	2b893783          	ld	a5,696(s2)
    80002b66:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002b68:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002b6c:	85d2                	mv	a1,s4
    80002b6e:	01048513          	addi	a0,s1,16
    80002b72:	248010ef          	jal	80003dba <initsleeplock>
    bcache.head.next->prev = b;
    80002b76:	2b893783          	ld	a5,696(s2)
    80002b7a:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002b7c:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002b80:	45848493          	addi	s1,s1,1112
    80002b84:	fd349fe3          	bne	s1,s3,80002b62 <binit+0x50>
  }
}
    80002b88:	70a2                	ld	ra,40(sp)
    80002b8a:	7402                	ld	s0,32(sp)
    80002b8c:	64e2                	ld	s1,24(sp)
    80002b8e:	6942                	ld	s2,16(sp)
    80002b90:	69a2                	ld	s3,8(sp)
    80002b92:	6a02                	ld	s4,0(sp)
    80002b94:	6145                	addi	sp,sp,48
    80002b96:	8082                	ret

0000000080002b98 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002b98:	7179                	addi	sp,sp,-48
    80002b9a:	f406                	sd	ra,40(sp)
    80002b9c:	f022                	sd	s0,32(sp)
    80002b9e:	ec26                	sd	s1,24(sp)
    80002ba0:	e84a                	sd	s2,16(sp)
    80002ba2:	e44e                	sd	s3,8(sp)
    80002ba4:	1800                	addi	s0,sp,48
    80002ba6:	892a                	mv	s2,a0
    80002ba8:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002baa:	00015517          	auipc	a0,0x15
    80002bae:	6fe50513          	addi	a0,a0,1790 # 800182a8 <bcache>
    80002bb2:	842fe0ef          	jal	80000bf4 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002bb6:	0001e497          	auipc	s1,0x1e
    80002bba:	9aa4b483          	ld	s1,-1622(s1) # 80020560 <bcache+0x82b8>
    80002bbe:	0001e797          	auipc	a5,0x1e
    80002bc2:	95278793          	addi	a5,a5,-1710 # 80020510 <bcache+0x8268>
    80002bc6:	02f48b63          	beq	s1,a5,80002bfc <bread+0x64>
    80002bca:	873e                	mv	a4,a5
    80002bcc:	a021                	j	80002bd4 <bread+0x3c>
    80002bce:	68a4                	ld	s1,80(s1)
    80002bd0:	02e48663          	beq	s1,a4,80002bfc <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    80002bd4:	449c                	lw	a5,8(s1)
    80002bd6:	ff279ce3          	bne	a5,s2,80002bce <bread+0x36>
    80002bda:	44dc                	lw	a5,12(s1)
    80002bdc:	ff3799e3          	bne	a5,s3,80002bce <bread+0x36>
      b->refcnt++;
    80002be0:	40bc                	lw	a5,64(s1)
    80002be2:	2785                	addiw	a5,a5,1
    80002be4:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002be6:	00015517          	auipc	a0,0x15
    80002bea:	6c250513          	addi	a0,a0,1730 # 800182a8 <bcache>
    80002bee:	89efe0ef          	jal	80000c8c <release>
      acquiresleep(&b->lock);
    80002bf2:	01048513          	addi	a0,s1,16
    80002bf6:	1fa010ef          	jal	80003df0 <acquiresleep>
      return b;
    80002bfa:	a889                	j	80002c4c <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002bfc:	0001e497          	auipc	s1,0x1e
    80002c00:	95c4b483          	ld	s1,-1700(s1) # 80020558 <bcache+0x82b0>
    80002c04:	0001e797          	auipc	a5,0x1e
    80002c08:	90c78793          	addi	a5,a5,-1780 # 80020510 <bcache+0x8268>
    80002c0c:	00f48863          	beq	s1,a5,80002c1c <bread+0x84>
    80002c10:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002c12:	40bc                	lw	a5,64(s1)
    80002c14:	cb91                	beqz	a5,80002c28 <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002c16:	64a4                	ld	s1,72(s1)
    80002c18:	fee49de3          	bne	s1,a4,80002c12 <bread+0x7a>
  panic("bget: no buffers");
    80002c1c:	00005517          	auipc	a0,0x5
    80002c20:	8ac50513          	addi	a0,a0,-1876 # 800074c8 <etext+0x4c8>
    80002c24:	b71fd0ef          	jal	80000794 <panic>
      b->dev = dev;
    80002c28:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002c2c:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002c30:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002c34:	4785                	li	a5,1
    80002c36:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002c38:	00015517          	auipc	a0,0x15
    80002c3c:	67050513          	addi	a0,a0,1648 # 800182a8 <bcache>
    80002c40:	84cfe0ef          	jal	80000c8c <release>
      acquiresleep(&b->lock);
    80002c44:	01048513          	addi	a0,s1,16
    80002c48:	1a8010ef          	jal	80003df0 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002c4c:	409c                	lw	a5,0(s1)
    80002c4e:	cb89                	beqz	a5,80002c60 <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002c50:	8526                	mv	a0,s1
    80002c52:	70a2                	ld	ra,40(sp)
    80002c54:	7402                	ld	s0,32(sp)
    80002c56:	64e2                	ld	s1,24(sp)
    80002c58:	6942                	ld	s2,16(sp)
    80002c5a:	69a2                	ld	s3,8(sp)
    80002c5c:	6145                	addi	sp,sp,48
    80002c5e:	8082                	ret
    virtio_disk_rw(b, 0);
    80002c60:	4581                	li	a1,0
    80002c62:	8526                	mv	a0,s1
    80002c64:	1ed020ef          	jal	80005650 <virtio_disk_rw>
    b->valid = 1;
    80002c68:	4785                	li	a5,1
    80002c6a:	c09c                	sw	a5,0(s1)
  return b;
    80002c6c:	b7d5                	j	80002c50 <bread+0xb8>

0000000080002c6e <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002c6e:	1101                	addi	sp,sp,-32
    80002c70:	ec06                	sd	ra,24(sp)
    80002c72:	e822                	sd	s0,16(sp)
    80002c74:	e426                	sd	s1,8(sp)
    80002c76:	1000                	addi	s0,sp,32
    80002c78:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002c7a:	0541                	addi	a0,a0,16
    80002c7c:	1f2010ef          	jal	80003e6e <holdingsleep>
    80002c80:	c911                	beqz	a0,80002c94 <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002c82:	4585                	li	a1,1
    80002c84:	8526                	mv	a0,s1
    80002c86:	1cb020ef          	jal	80005650 <virtio_disk_rw>
}
    80002c8a:	60e2                	ld	ra,24(sp)
    80002c8c:	6442                	ld	s0,16(sp)
    80002c8e:	64a2                	ld	s1,8(sp)
    80002c90:	6105                	addi	sp,sp,32
    80002c92:	8082                	ret
    panic("bwrite");
    80002c94:	00005517          	auipc	a0,0x5
    80002c98:	84c50513          	addi	a0,a0,-1972 # 800074e0 <etext+0x4e0>
    80002c9c:	af9fd0ef          	jal	80000794 <panic>

0000000080002ca0 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002ca0:	1101                	addi	sp,sp,-32
    80002ca2:	ec06                	sd	ra,24(sp)
    80002ca4:	e822                	sd	s0,16(sp)
    80002ca6:	e426                	sd	s1,8(sp)
    80002ca8:	e04a                	sd	s2,0(sp)
    80002caa:	1000                	addi	s0,sp,32
    80002cac:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002cae:	01050913          	addi	s2,a0,16
    80002cb2:	854a                	mv	a0,s2
    80002cb4:	1ba010ef          	jal	80003e6e <holdingsleep>
    80002cb8:	c135                	beqz	a0,80002d1c <brelse+0x7c>
    panic("brelse");

  releasesleep(&b->lock);
    80002cba:	854a                	mv	a0,s2
    80002cbc:	17a010ef          	jal	80003e36 <releasesleep>

  acquire(&bcache.lock);
    80002cc0:	00015517          	auipc	a0,0x15
    80002cc4:	5e850513          	addi	a0,a0,1512 # 800182a8 <bcache>
    80002cc8:	f2dfd0ef          	jal	80000bf4 <acquire>
  b->refcnt--;
    80002ccc:	40bc                	lw	a5,64(s1)
    80002cce:	37fd                	addiw	a5,a5,-1
    80002cd0:	0007871b          	sext.w	a4,a5
    80002cd4:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002cd6:	e71d                	bnez	a4,80002d04 <brelse+0x64>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002cd8:	68b8                	ld	a4,80(s1)
    80002cda:	64bc                	ld	a5,72(s1)
    80002cdc:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80002cde:	68b8                	ld	a4,80(s1)
    80002ce0:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002ce2:	0001d797          	auipc	a5,0x1d
    80002ce6:	5c678793          	addi	a5,a5,1478 # 800202a8 <bcache+0x8000>
    80002cea:	2b87b703          	ld	a4,696(a5)
    80002cee:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002cf0:	0001e717          	auipc	a4,0x1e
    80002cf4:	82070713          	addi	a4,a4,-2016 # 80020510 <bcache+0x8268>
    80002cf8:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002cfa:	2b87b703          	ld	a4,696(a5)
    80002cfe:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002d00:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80002d04:	00015517          	auipc	a0,0x15
    80002d08:	5a450513          	addi	a0,a0,1444 # 800182a8 <bcache>
    80002d0c:	f81fd0ef          	jal	80000c8c <release>
}
    80002d10:	60e2                	ld	ra,24(sp)
    80002d12:	6442                	ld	s0,16(sp)
    80002d14:	64a2                	ld	s1,8(sp)
    80002d16:	6902                	ld	s2,0(sp)
    80002d18:	6105                	addi	sp,sp,32
    80002d1a:	8082                	ret
    panic("brelse");
    80002d1c:	00004517          	auipc	a0,0x4
    80002d20:	7cc50513          	addi	a0,a0,1996 # 800074e8 <etext+0x4e8>
    80002d24:	a71fd0ef          	jal	80000794 <panic>

0000000080002d28 <bpin>:

void
bpin(struct buf *b) {
    80002d28:	1101                	addi	sp,sp,-32
    80002d2a:	ec06                	sd	ra,24(sp)
    80002d2c:	e822                	sd	s0,16(sp)
    80002d2e:	e426                	sd	s1,8(sp)
    80002d30:	1000                	addi	s0,sp,32
    80002d32:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002d34:	00015517          	auipc	a0,0x15
    80002d38:	57450513          	addi	a0,a0,1396 # 800182a8 <bcache>
    80002d3c:	eb9fd0ef          	jal	80000bf4 <acquire>
  b->refcnt++;
    80002d40:	40bc                	lw	a5,64(s1)
    80002d42:	2785                	addiw	a5,a5,1
    80002d44:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002d46:	00015517          	auipc	a0,0x15
    80002d4a:	56250513          	addi	a0,a0,1378 # 800182a8 <bcache>
    80002d4e:	f3ffd0ef          	jal	80000c8c <release>
}
    80002d52:	60e2                	ld	ra,24(sp)
    80002d54:	6442                	ld	s0,16(sp)
    80002d56:	64a2                	ld	s1,8(sp)
    80002d58:	6105                	addi	sp,sp,32
    80002d5a:	8082                	ret

0000000080002d5c <bunpin>:

void
bunpin(struct buf *b) {
    80002d5c:	1101                	addi	sp,sp,-32
    80002d5e:	ec06                	sd	ra,24(sp)
    80002d60:	e822                	sd	s0,16(sp)
    80002d62:	e426                	sd	s1,8(sp)
    80002d64:	1000                	addi	s0,sp,32
    80002d66:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002d68:	00015517          	auipc	a0,0x15
    80002d6c:	54050513          	addi	a0,a0,1344 # 800182a8 <bcache>
    80002d70:	e85fd0ef          	jal	80000bf4 <acquire>
  b->refcnt--;
    80002d74:	40bc                	lw	a5,64(s1)
    80002d76:	37fd                	addiw	a5,a5,-1
    80002d78:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002d7a:	00015517          	auipc	a0,0x15
    80002d7e:	52e50513          	addi	a0,a0,1326 # 800182a8 <bcache>
    80002d82:	f0bfd0ef          	jal	80000c8c <release>
}
    80002d86:	60e2                	ld	ra,24(sp)
    80002d88:	6442                	ld	s0,16(sp)
    80002d8a:	64a2                	ld	s1,8(sp)
    80002d8c:	6105                	addi	sp,sp,32
    80002d8e:	8082                	ret

0000000080002d90 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80002d90:	1101                	addi	sp,sp,-32
    80002d92:	ec06                	sd	ra,24(sp)
    80002d94:	e822                	sd	s0,16(sp)
    80002d96:	e426                	sd	s1,8(sp)
    80002d98:	e04a                	sd	s2,0(sp)
    80002d9a:	1000                	addi	s0,sp,32
    80002d9c:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80002d9e:	00d5d59b          	srliw	a1,a1,0xd
    80002da2:	0001e797          	auipc	a5,0x1e
    80002da6:	be27a783          	lw	a5,-1054(a5) # 80020984 <sb+0x1c>
    80002daa:	9dbd                	addw	a1,a1,a5
    80002dac:	dedff0ef          	jal	80002b98 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80002db0:	0074f713          	andi	a4,s1,7
    80002db4:	4785                	li	a5,1
    80002db6:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80002dba:	14ce                	slli	s1,s1,0x33
    80002dbc:	90d9                	srli	s1,s1,0x36
    80002dbe:	00950733          	add	a4,a0,s1
    80002dc2:	05874703          	lbu	a4,88(a4)
    80002dc6:	00e7f6b3          	and	a3,a5,a4
    80002dca:	c29d                	beqz	a3,80002df0 <bfree+0x60>
    80002dcc:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80002dce:	94aa                	add	s1,s1,a0
    80002dd0:	fff7c793          	not	a5,a5
    80002dd4:	8f7d                	and	a4,a4,a5
    80002dd6:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80002dda:	711000ef          	jal	80003cea <log_write>
  brelse(bp);
    80002dde:	854a                	mv	a0,s2
    80002de0:	ec1ff0ef          	jal	80002ca0 <brelse>
}
    80002de4:	60e2                	ld	ra,24(sp)
    80002de6:	6442                	ld	s0,16(sp)
    80002de8:	64a2                	ld	s1,8(sp)
    80002dea:	6902                	ld	s2,0(sp)
    80002dec:	6105                	addi	sp,sp,32
    80002dee:	8082                	ret
    panic("freeing free block");
    80002df0:	00004517          	auipc	a0,0x4
    80002df4:	70050513          	addi	a0,a0,1792 # 800074f0 <etext+0x4f0>
    80002df8:	99dfd0ef          	jal	80000794 <panic>

0000000080002dfc <balloc>:
{
    80002dfc:	711d                	addi	sp,sp,-96
    80002dfe:	ec86                	sd	ra,88(sp)
    80002e00:	e8a2                	sd	s0,80(sp)
    80002e02:	e4a6                	sd	s1,72(sp)
    80002e04:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80002e06:	0001e797          	auipc	a5,0x1e
    80002e0a:	b667a783          	lw	a5,-1178(a5) # 8002096c <sb+0x4>
    80002e0e:	0e078f63          	beqz	a5,80002f0c <balloc+0x110>
    80002e12:	e0ca                	sd	s2,64(sp)
    80002e14:	fc4e                	sd	s3,56(sp)
    80002e16:	f852                	sd	s4,48(sp)
    80002e18:	f456                	sd	s5,40(sp)
    80002e1a:	f05a                	sd	s6,32(sp)
    80002e1c:	ec5e                	sd	s7,24(sp)
    80002e1e:	e862                	sd	s8,16(sp)
    80002e20:	e466                	sd	s9,8(sp)
    80002e22:	8baa                	mv	s7,a0
    80002e24:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80002e26:	0001eb17          	auipc	s6,0x1e
    80002e2a:	b42b0b13          	addi	s6,s6,-1214 # 80020968 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002e2e:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80002e30:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002e32:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80002e34:	6c89                	lui	s9,0x2
    80002e36:	a0b5                	j	80002ea2 <balloc+0xa6>
        bp->data[bi/8] |= m;  // Mark block in use.
    80002e38:	97ca                	add	a5,a5,s2
    80002e3a:	8e55                	or	a2,a2,a3
    80002e3c:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80002e40:	854a                	mv	a0,s2
    80002e42:	6a9000ef          	jal	80003cea <log_write>
        brelse(bp);
    80002e46:	854a                	mv	a0,s2
    80002e48:	e59ff0ef          	jal	80002ca0 <brelse>
  bp = bread(dev, bno);
    80002e4c:	85a6                	mv	a1,s1
    80002e4e:	855e                	mv	a0,s7
    80002e50:	d49ff0ef          	jal	80002b98 <bread>
    80002e54:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80002e56:	40000613          	li	a2,1024
    80002e5a:	4581                	li	a1,0
    80002e5c:	05850513          	addi	a0,a0,88
    80002e60:	e69fd0ef          	jal	80000cc8 <memset>
  log_write(bp);
    80002e64:	854a                	mv	a0,s2
    80002e66:	685000ef          	jal	80003cea <log_write>
  brelse(bp);
    80002e6a:	854a                	mv	a0,s2
    80002e6c:	e35ff0ef          	jal	80002ca0 <brelse>
}
    80002e70:	6906                	ld	s2,64(sp)
    80002e72:	79e2                	ld	s3,56(sp)
    80002e74:	7a42                	ld	s4,48(sp)
    80002e76:	7aa2                	ld	s5,40(sp)
    80002e78:	7b02                	ld	s6,32(sp)
    80002e7a:	6be2                	ld	s7,24(sp)
    80002e7c:	6c42                	ld	s8,16(sp)
    80002e7e:	6ca2                	ld	s9,8(sp)
}
    80002e80:	8526                	mv	a0,s1
    80002e82:	60e6                	ld	ra,88(sp)
    80002e84:	6446                	ld	s0,80(sp)
    80002e86:	64a6                	ld	s1,72(sp)
    80002e88:	6125                	addi	sp,sp,96
    80002e8a:	8082                	ret
    brelse(bp);
    80002e8c:	854a                	mv	a0,s2
    80002e8e:	e13ff0ef          	jal	80002ca0 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80002e92:	015c87bb          	addw	a5,s9,s5
    80002e96:	00078a9b          	sext.w	s5,a5
    80002e9a:	004b2703          	lw	a4,4(s6)
    80002e9e:	04eaff63          	bgeu	s5,a4,80002efc <balloc+0x100>
    bp = bread(dev, BBLOCK(b, sb));
    80002ea2:	41fad79b          	sraiw	a5,s5,0x1f
    80002ea6:	0137d79b          	srliw	a5,a5,0x13
    80002eaa:	015787bb          	addw	a5,a5,s5
    80002eae:	40d7d79b          	sraiw	a5,a5,0xd
    80002eb2:	01cb2583          	lw	a1,28(s6)
    80002eb6:	9dbd                	addw	a1,a1,a5
    80002eb8:	855e                	mv	a0,s7
    80002eba:	cdfff0ef          	jal	80002b98 <bread>
    80002ebe:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002ec0:	004b2503          	lw	a0,4(s6)
    80002ec4:	000a849b          	sext.w	s1,s5
    80002ec8:	8762                	mv	a4,s8
    80002eca:	fca4f1e3          	bgeu	s1,a0,80002e8c <balloc+0x90>
      m = 1 << (bi % 8);
    80002ece:	00777693          	andi	a3,a4,7
    80002ed2:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80002ed6:	41f7579b          	sraiw	a5,a4,0x1f
    80002eda:	01d7d79b          	srliw	a5,a5,0x1d
    80002ede:	9fb9                	addw	a5,a5,a4
    80002ee0:	4037d79b          	sraiw	a5,a5,0x3
    80002ee4:	00f90633          	add	a2,s2,a5
    80002ee8:	05864603          	lbu	a2,88(a2)
    80002eec:	00c6f5b3          	and	a1,a3,a2
    80002ef0:	d5a1                	beqz	a1,80002e38 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002ef2:	2705                	addiw	a4,a4,1
    80002ef4:	2485                	addiw	s1,s1,1
    80002ef6:	fd471ae3          	bne	a4,s4,80002eca <balloc+0xce>
    80002efa:	bf49                	j	80002e8c <balloc+0x90>
    80002efc:	6906                	ld	s2,64(sp)
    80002efe:	79e2                	ld	s3,56(sp)
    80002f00:	7a42                	ld	s4,48(sp)
    80002f02:	7aa2                	ld	s5,40(sp)
    80002f04:	7b02                	ld	s6,32(sp)
    80002f06:	6be2                	ld	s7,24(sp)
    80002f08:	6c42                	ld	s8,16(sp)
    80002f0a:	6ca2                	ld	s9,8(sp)
  printf("balloc: out of blocks\n");
    80002f0c:	00004517          	auipc	a0,0x4
    80002f10:	5fc50513          	addi	a0,a0,1532 # 80007508 <etext+0x508>
    80002f14:	daefd0ef          	jal	800004c2 <printf>
  return 0;
    80002f18:	4481                	li	s1,0
    80002f1a:	b79d                	j	80002e80 <balloc+0x84>

0000000080002f1c <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80002f1c:	7179                	addi	sp,sp,-48
    80002f1e:	f406                	sd	ra,40(sp)
    80002f20:	f022                	sd	s0,32(sp)
    80002f22:	ec26                	sd	s1,24(sp)
    80002f24:	e84a                	sd	s2,16(sp)
    80002f26:	e44e                	sd	s3,8(sp)
    80002f28:	1800                	addi	s0,sp,48
    80002f2a:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80002f2c:	47ad                	li	a5,11
    80002f2e:	02b7e663          	bltu	a5,a1,80002f5a <bmap+0x3e>
    if((addr = ip->addrs[bn]) == 0){
    80002f32:	02059793          	slli	a5,a1,0x20
    80002f36:	01e7d593          	srli	a1,a5,0x1e
    80002f3a:	00b504b3          	add	s1,a0,a1
    80002f3e:	0504a903          	lw	s2,80(s1)
    80002f42:	06091a63          	bnez	s2,80002fb6 <bmap+0x9a>
      addr = balloc(ip->dev);
    80002f46:	4108                	lw	a0,0(a0)
    80002f48:	eb5ff0ef          	jal	80002dfc <balloc>
    80002f4c:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80002f50:	06090363          	beqz	s2,80002fb6 <bmap+0x9a>
        return 0;
      ip->addrs[bn] = addr;
    80002f54:	0524a823          	sw	s2,80(s1)
    80002f58:	a8b9                	j	80002fb6 <bmap+0x9a>
    }
    return addr;
  }
  bn -= NDIRECT;
    80002f5a:	ff45849b          	addiw	s1,a1,-12
    80002f5e:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80002f62:	0ff00793          	li	a5,255
    80002f66:	06e7ee63          	bltu	a5,a4,80002fe2 <bmap+0xc6>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80002f6a:	08052903          	lw	s2,128(a0)
    80002f6e:	00091d63          	bnez	s2,80002f88 <bmap+0x6c>
      addr = balloc(ip->dev);
    80002f72:	4108                	lw	a0,0(a0)
    80002f74:	e89ff0ef          	jal	80002dfc <balloc>
    80002f78:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80002f7c:	02090d63          	beqz	s2,80002fb6 <bmap+0x9a>
    80002f80:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    80002f82:	0929a023          	sw	s2,128(s3)
    80002f86:	a011                	j	80002f8a <bmap+0x6e>
    80002f88:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    80002f8a:	85ca                	mv	a1,s2
    80002f8c:	0009a503          	lw	a0,0(s3)
    80002f90:	c09ff0ef          	jal	80002b98 <bread>
    80002f94:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80002f96:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80002f9a:	02049713          	slli	a4,s1,0x20
    80002f9e:	01e75593          	srli	a1,a4,0x1e
    80002fa2:	00b784b3          	add	s1,a5,a1
    80002fa6:	0004a903          	lw	s2,0(s1)
    80002faa:	00090e63          	beqz	s2,80002fc6 <bmap+0xaa>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80002fae:	8552                	mv	a0,s4
    80002fb0:	cf1ff0ef          	jal	80002ca0 <brelse>
    return addr;
    80002fb4:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    80002fb6:	854a                	mv	a0,s2
    80002fb8:	70a2                	ld	ra,40(sp)
    80002fba:	7402                	ld	s0,32(sp)
    80002fbc:	64e2                	ld	s1,24(sp)
    80002fbe:	6942                	ld	s2,16(sp)
    80002fc0:	69a2                	ld	s3,8(sp)
    80002fc2:	6145                	addi	sp,sp,48
    80002fc4:	8082                	ret
      addr = balloc(ip->dev);
    80002fc6:	0009a503          	lw	a0,0(s3)
    80002fca:	e33ff0ef          	jal	80002dfc <balloc>
    80002fce:	0005091b          	sext.w	s2,a0
      if(addr){
    80002fd2:	fc090ee3          	beqz	s2,80002fae <bmap+0x92>
        a[bn] = addr;
    80002fd6:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80002fda:	8552                	mv	a0,s4
    80002fdc:	50f000ef          	jal	80003cea <log_write>
    80002fe0:	b7f9                	j	80002fae <bmap+0x92>
    80002fe2:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    80002fe4:	00004517          	auipc	a0,0x4
    80002fe8:	53c50513          	addi	a0,a0,1340 # 80007520 <etext+0x520>
    80002fec:	fa8fd0ef          	jal	80000794 <panic>

0000000080002ff0 <iget>:
{
    80002ff0:	7179                	addi	sp,sp,-48
    80002ff2:	f406                	sd	ra,40(sp)
    80002ff4:	f022                	sd	s0,32(sp)
    80002ff6:	ec26                	sd	s1,24(sp)
    80002ff8:	e84a                	sd	s2,16(sp)
    80002ffa:	e44e                	sd	s3,8(sp)
    80002ffc:	e052                	sd	s4,0(sp)
    80002ffe:	1800                	addi	s0,sp,48
    80003000:	89aa                	mv	s3,a0
    80003002:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003004:	0001e517          	auipc	a0,0x1e
    80003008:	98450513          	addi	a0,a0,-1660 # 80020988 <itable>
    8000300c:	be9fd0ef          	jal	80000bf4 <acquire>
  empty = 0;
    80003010:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003012:	0001e497          	auipc	s1,0x1e
    80003016:	98e48493          	addi	s1,s1,-1650 # 800209a0 <itable+0x18>
    8000301a:	0001f697          	auipc	a3,0x1f
    8000301e:	41668693          	addi	a3,a3,1046 # 80022430 <log>
    80003022:	a039                	j	80003030 <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003024:	02090963          	beqz	s2,80003056 <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003028:	08848493          	addi	s1,s1,136
    8000302c:	02d48863          	beq	s1,a3,8000305c <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003030:	449c                	lw	a5,8(s1)
    80003032:	fef059e3          	blez	a5,80003024 <iget+0x34>
    80003036:	4098                	lw	a4,0(s1)
    80003038:	ff3716e3          	bne	a4,s3,80003024 <iget+0x34>
    8000303c:	40d8                	lw	a4,4(s1)
    8000303e:	ff4713e3          	bne	a4,s4,80003024 <iget+0x34>
      ip->ref++;
    80003042:	2785                	addiw	a5,a5,1
    80003044:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003046:	0001e517          	auipc	a0,0x1e
    8000304a:	94250513          	addi	a0,a0,-1726 # 80020988 <itable>
    8000304e:	c3ffd0ef          	jal	80000c8c <release>
      return ip;
    80003052:	8926                	mv	s2,s1
    80003054:	a02d                	j	8000307e <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003056:	fbe9                	bnez	a5,80003028 <iget+0x38>
      empty = ip;
    80003058:	8926                	mv	s2,s1
    8000305a:	b7f9                	j	80003028 <iget+0x38>
  if(empty == 0)
    8000305c:	02090a63          	beqz	s2,80003090 <iget+0xa0>
  ip->dev = dev;
    80003060:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003064:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003068:	4785                	li	a5,1
    8000306a:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    8000306e:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003072:	0001e517          	auipc	a0,0x1e
    80003076:	91650513          	addi	a0,a0,-1770 # 80020988 <itable>
    8000307a:	c13fd0ef          	jal	80000c8c <release>
}
    8000307e:	854a                	mv	a0,s2
    80003080:	70a2                	ld	ra,40(sp)
    80003082:	7402                	ld	s0,32(sp)
    80003084:	64e2                	ld	s1,24(sp)
    80003086:	6942                	ld	s2,16(sp)
    80003088:	69a2                	ld	s3,8(sp)
    8000308a:	6a02                	ld	s4,0(sp)
    8000308c:	6145                	addi	sp,sp,48
    8000308e:	8082                	ret
    panic("iget: no inodes");
    80003090:	00004517          	auipc	a0,0x4
    80003094:	4a850513          	addi	a0,a0,1192 # 80007538 <etext+0x538>
    80003098:	efcfd0ef          	jal	80000794 <panic>

000000008000309c <fsinit>:
fsinit(int dev) {
    8000309c:	7179                	addi	sp,sp,-48
    8000309e:	f406                	sd	ra,40(sp)
    800030a0:	f022                	sd	s0,32(sp)
    800030a2:	ec26                	sd	s1,24(sp)
    800030a4:	e84a                	sd	s2,16(sp)
    800030a6:	e44e                	sd	s3,8(sp)
    800030a8:	1800                	addi	s0,sp,48
    800030aa:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800030ac:	4585                	li	a1,1
    800030ae:	aebff0ef          	jal	80002b98 <bread>
    800030b2:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800030b4:	0001e997          	auipc	s3,0x1e
    800030b8:	8b498993          	addi	s3,s3,-1868 # 80020968 <sb>
    800030bc:	02000613          	li	a2,32
    800030c0:	05850593          	addi	a1,a0,88
    800030c4:	854e                	mv	a0,s3
    800030c6:	c5ffd0ef          	jal	80000d24 <memmove>
  brelse(bp);
    800030ca:	8526                	mv	a0,s1
    800030cc:	bd5ff0ef          	jal	80002ca0 <brelse>
  if(sb.magic != FSMAGIC)
    800030d0:	0009a703          	lw	a4,0(s3)
    800030d4:	102037b7          	lui	a5,0x10203
    800030d8:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800030dc:	02f71063          	bne	a4,a5,800030fc <fsinit+0x60>
  initlog(dev, &sb);
    800030e0:	0001e597          	auipc	a1,0x1e
    800030e4:	88858593          	addi	a1,a1,-1912 # 80020968 <sb>
    800030e8:	854a                	mv	a0,s2
    800030ea:	1f9000ef          	jal	80003ae2 <initlog>
}
    800030ee:	70a2                	ld	ra,40(sp)
    800030f0:	7402                	ld	s0,32(sp)
    800030f2:	64e2                	ld	s1,24(sp)
    800030f4:	6942                	ld	s2,16(sp)
    800030f6:	69a2                	ld	s3,8(sp)
    800030f8:	6145                	addi	sp,sp,48
    800030fa:	8082                	ret
    panic("invalid file system");
    800030fc:	00004517          	auipc	a0,0x4
    80003100:	44c50513          	addi	a0,a0,1100 # 80007548 <etext+0x548>
    80003104:	e90fd0ef          	jal	80000794 <panic>

0000000080003108 <iinit>:
{
    80003108:	7179                	addi	sp,sp,-48
    8000310a:	f406                	sd	ra,40(sp)
    8000310c:	f022                	sd	s0,32(sp)
    8000310e:	ec26                	sd	s1,24(sp)
    80003110:	e84a                	sd	s2,16(sp)
    80003112:	e44e                	sd	s3,8(sp)
    80003114:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003116:	00004597          	auipc	a1,0x4
    8000311a:	44a58593          	addi	a1,a1,1098 # 80007560 <etext+0x560>
    8000311e:	0001e517          	auipc	a0,0x1e
    80003122:	86a50513          	addi	a0,a0,-1942 # 80020988 <itable>
    80003126:	a4ffd0ef          	jal	80000b74 <initlock>
  for(i = 0; i < NINODE; i++) {
    8000312a:	0001e497          	auipc	s1,0x1e
    8000312e:	88648493          	addi	s1,s1,-1914 # 800209b0 <itable+0x28>
    80003132:	0001f997          	auipc	s3,0x1f
    80003136:	30e98993          	addi	s3,s3,782 # 80022440 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    8000313a:	00004917          	auipc	s2,0x4
    8000313e:	42e90913          	addi	s2,s2,1070 # 80007568 <etext+0x568>
    80003142:	85ca                	mv	a1,s2
    80003144:	8526                	mv	a0,s1
    80003146:	475000ef          	jal	80003dba <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    8000314a:	08848493          	addi	s1,s1,136
    8000314e:	ff349ae3          	bne	s1,s3,80003142 <iinit+0x3a>
}
    80003152:	70a2                	ld	ra,40(sp)
    80003154:	7402                	ld	s0,32(sp)
    80003156:	64e2                	ld	s1,24(sp)
    80003158:	6942                	ld	s2,16(sp)
    8000315a:	69a2                	ld	s3,8(sp)
    8000315c:	6145                	addi	sp,sp,48
    8000315e:	8082                	ret

0000000080003160 <ialloc>:
{
    80003160:	7139                	addi	sp,sp,-64
    80003162:	fc06                	sd	ra,56(sp)
    80003164:	f822                	sd	s0,48(sp)
    80003166:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    80003168:	0001e717          	auipc	a4,0x1e
    8000316c:	80c72703          	lw	a4,-2036(a4) # 80020974 <sb+0xc>
    80003170:	4785                	li	a5,1
    80003172:	06e7f063          	bgeu	a5,a4,800031d2 <ialloc+0x72>
    80003176:	f426                	sd	s1,40(sp)
    80003178:	f04a                	sd	s2,32(sp)
    8000317a:	ec4e                	sd	s3,24(sp)
    8000317c:	e852                	sd	s4,16(sp)
    8000317e:	e456                	sd	s5,8(sp)
    80003180:	e05a                	sd	s6,0(sp)
    80003182:	8aaa                	mv	s5,a0
    80003184:	8b2e                	mv	s6,a1
    80003186:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003188:	0001da17          	auipc	s4,0x1d
    8000318c:	7e0a0a13          	addi	s4,s4,2016 # 80020968 <sb>
    80003190:	00495593          	srli	a1,s2,0x4
    80003194:	018a2783          	lw	a5,24(s4)
    80003198:	9dbd                	addw	a1,a1,a5
    8000319a:	8556                	mv	a0,s5
    8000319c:	9fdff0ef          	jal	80002b98 <bread>
    800031a0:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800031a2:	05850993          	addi	s3,a0,88
    800031a6:	00f97793          	andi	a5,s2,15
    800031aa:	079a                	slli	a5,a5,0x6
    800031ac:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800031ae:	00099783          	lh	a5,0(s3)
    800031b2:	cb9d                	beqz	a5,800031e8 <ialloc+0x88>
    brelse(bp);
    800031b4:	aedff0ef          	jal	80002ca0 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800031b8:	0905                	addi	s2,s2,1
    800031ba:	00ca2703          	lw	a4,12(s4)
    800031be:	0009079b          	sext.w	a5,s2
    800031c2:	fce7e7e3          	bltu	a5,a4,80003190 <ialloc+0x30>
    800031c6:	74a2                	ld	s1,40(sp)
    800031c8:	7902                	ld	s2,32(sp)
    800031ca:	69e2                	ld	s3,24(sp)
    800031cc:	6a42                	ld	s4,16(sp)
    800031ce:	6aa2                	ld	s5,8(sp)
    800031d0:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    800031d2:	00004517          	auipc	a0,0x4
    800031d6:	39e50513          	addi	a0,a0,926 # 80007570 <etext+0x570>
    800031da:	ae8fd0ef          	jal	800004c2 <printf>
  return 0;
    800031de:	4501                	li	a0,0
}
    800031e0:	70e2                	ld	ra,56(sp)
    800031e2:	7442                	ld	s0,48(sp)
    800031e4:	6121                	addi	sp,sp,64
    800031e6:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    800031e8:	04000613          	li	a2,64
    800031ec:	4581                	li	a1,0
    800031ee:	854e                	mv	a0,s3
    800031f0:	ad9fd0ef          	jal	80000cc8 <memset>
      dip->type = type;
    800031f4:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800031f8:	8526                	mv	a0,s1
    800031fa:	2f1000ef          	jal	80003cea <log_write>
      brelse(bp);
    800031fe:	8526                	mv	a0,s1
    80003200:	aa1ff0ef          	jal	80002ca0 <brelse>
      return iget(dev, inum);
    80003204:	0009059b          	sext.w	a1,s2
    80003208:	8556                	mv	a0,s5
    8000320a:	de7ff0ef          	jal	80002ff0 <iget>
    8000320e:	74a2                	ld	s1,40(sp)
    80003210:	7902                	ld	s2,32(sp)
    80003212:	69e2                	ld	s3,24(sp)
    80003214:	6a42                	ld	s4,16(sp)
    80003216:	6aa2                	ld	s5,8(sp)
    80003218:	6b02                	ld	s6,0(sp)
    8000321a:	b7d9                	j	800031e0 <ialloc+0x80>

000000008000321c <iupdate>:
{
    8000321c:	1101                	addi	sp,sp,-32
    8000321e:	ec06                	sd	ra,24(sp)
    80003220:	e822                	sd	s0,16(sp)
    80003222:	e426                	sd	s1,8(sp)
    80003224:	e04a                	sd	s2,0(sp)
    80003226:	1000                	addi	s0,sp,32
    80003228:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000322a:	415c                	lw	a5,4(a0)
    8000322c:	0047d79b          	srliw	a5,a5,0x4
    80003230:	0001d597          	auipc	a1,0x1d
    80003234:	7505a583          	lw	a1,1872(a1) # 80020980 <sb+0x18>
    80003238:	9dbd                	addw	a1,a1,a5
    8000323a:	4108                	lw	a0,0(a0)
    8000323c:	95dff0ef          	jal	80002b98 <bread>
    80003240:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003242:	05850793          	addi	a5,a0,88
    80003246:	40d8                	lw	a4,4(s1)
    80003248:	8b3d                	andi	a4,a4,15
    8000324a:	071a                	slli	a4,a4,0x6
    8000324c:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    8000324e:	04449703          	lh	a4,68(s1)
    80003252:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003256:	04649703          	lh	a4,70(s1)
    8000325a:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    8000325e:	04849703          	lh	a4,72(s1)
    80003262:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003266:	04a49703          	lh	a4,74(s1)
    8000326a:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    8000326e:	44f8                	lw	a4,76(s1)
    80003270:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003272:	03400613          	li	a2,52
    80003276:	05048593          	addi	a1,s1,80
    8000327a:	00c78513          	addi	a0,a5,12
    8000327e:	aa7fd0ef          	jal	80000d24 <memmove>
  log_write(bp);
    80003282:	854a                	mv	a0,s2
    80003284:	267000ef          	jal	80003cea <log_write>
  brelse(bp);
    80003288:	854a                	mv	a0,s2
    8000328a:	a17ff0ef          	jal	80002ca0 <brelse>
}
    8000328e:	60e2                	ld	ra,24(sp)
    80003290:	6442                	ld	s0,16(sp)
    80003292:	64a2                	ld	s1,8(sp)
    80003294:	6902                	ld	s2,0(sp)
    80003296:	6105                	addi	sp,sp,32
    80003298:	8082                	ret

000000008000329a <idup>:
{
    8000329a:	1101                	addi	sp,sp,-32
    8000329c:	ec06                	sd	ra,24(sp)
    8000329e:	e822                	sd	s0,16(sp)
    800032a0:	e426                	sd	s1,8(sp)
    800032a2:	1000                	addi	s0,sp,32
    800032a4:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800032a6:	0001d517          	auipc	a0,0x1d
    800032aa:	6e250513          	addi	a0,a0,1762 # 80020988 <itable>
    800032ae:	947fd0ef          	jal	80000bf4 <acquire>
  ip->ref++;
    800032b2:	449c                	lw	a5,8(s1)
    800032b4:	2785                	addiw	a5,a5,1
    800032b6:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800032b8:	0001d517          	auipc	a0,0x1d
    800032bc:	6d050513          	addi	a0,a0,1744 # 80020988 <itable>
    800032c0:	9cdfd0ef          	jal	80000c8c <release>
}
    800032c4:	8526                	mv	a0,s1
    800032c6:	60e2                	ld	ra,24(sp)
    800032c8:	6442                	ld	s0,16(sp)
    800032ca:	64a2                	ld	s1,8(sp)
    800032cc:	6105                	addi	sp,sp,32
    800032ce:	8082                	ret

00000000800032d0 <ilock>:
{
    800032d0:	1101                	addi	sp,sp,-32
    800032d2:	ec06                	sd	ra,24(sp)
    800032d4:	e822                	sd	s0,16(sp)
    800032d6:	e426                	sd	s1,8(sp)
    800032d8:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800032da:	cd19                	beqz	a0,800032f8 <ilock+0x28>
    800032dc:	84aa                	mv	s1,a0
    800032de:	451c                	lw	a5,8(a0)
    800032e0:	00f05c63          	blez	a5,800032f8 <ilock+0x28>
  acquiresleep(&ip->lock);
    800032e4:	0541                	addi	a0,a0,16
    800032e6:	30b000ef          	jal	80003df0 <acquiresleep>
  if(ip->valid == 0){
    800032ea:	40bc                	lw	a5,64(s1)
    800032ec:	cf89                	beqz	a5,80003306 <ilock+0x36>
}
    800032ee:	60e2                	ld	ra,24(sp)
    800032f0:	6442                	ld	s0,16(sp)
    800032f2:	64a2                	ld	s1,8(sp)
    800032f4:	6105                	addi	sp,sp,32
    800032f6:	8082                	ret
    800032f8:	e04a                	sd	s2,0(sp)
    panic("ilock");
    800032fa:	00004517          	auipc	a0,0x4
    800032fe:	28e50513          	addi	a0,a0,654 # 80007588 <etext+0x588>
    80003302:	c92fd0ef          	jal	80000794 <panic>
    80003306:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003308:	40dc                	lw	a5,4(s1)
    8000330a:	0047d79b          	srliw	a5,a5,0x4
    8000330e:	0001d597          	auipc	a1,0x1d
    80003312:	6725a583          	lw	a1,1650(a1) # 80020980 <sb+0x18>
    80003316:	9dbd                	addw	a1,a1,a5
    80003318:	4088                	lw	a0,0(s1)
    8000331a:	87fff0ef          	jal	80002b98 <bread>
    8000331e:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003320:	05850593          	addi	a1,a0,88
    80003324:	40dc                	lw	a5,4(s1)
    80003326:	8bbd                	andi	a5,a5,15
    80003328:	079a                	slli	a5,a5,0x6
    8000332a:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    8000332c:	00059783          	lh	a5,0(a1)
    80003330:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003334:	00259783          	lh	a5,2(a1)
    80003338:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    8000333c:	00459783          	lh	a5,4(a1)
    80003340:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003344:	00659783          	lh	a5,6(a1)
    80003348:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    8000334c:	459c                	lw	a5,8(a1)
    8000334e:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003350:	03400613          	li	a2,52
    80003354:	05b1                	addi	a1,a1,12
    80003356:	05048513          	addi	a0,s1,80
    8000335a:	9cbfd0ef          	jal	80000d24 <memmove>
    brelse(bp);
    8000335e:	854a                	mv	a0,s2
    80003360:	941ff0ef          	jal	80002ca0 <brelse>
    ip->valid = 1;
    80003364:	4785                	li	a5,1
    80003366:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003368:	04449783          	lh	a5,68(s1)
    8000336c:	c399                	beqz	a5,80003372 <ilock+0xa2>
    8000336e:	6902                	ld	s2,0(sp)
    80003370:	bfbd                	j	800032ee <ilock+0x1e>
      panic("ilock: no type");
    80003372:	00004517          	auipc	a0,0x4
    80003376:	21e50513          	addi	a0,a0,542 # 80007590 <etext+0x590>
    8000337a:	c1afd0ef          	jal	80000794 <panic>

000000008000337e <iunlock>:
{
    8000337e:	1101                	addi	sp,sp,-32
    80003380:	ec06                	sd	ra,24(sp)
    80003382:	e822                	sd	s0,16(sp)
    80003384:	e426                	sd	s1,8(sp)
    80003386:	e04a                	sd	s2,0(sp)
    80003388:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    8000338a:	c505                	beqz	a0,800033b2 <iunlock+0x34>
    8000338c:	84aa                	mv	s1,a0
    8000338e:	01050913          	addi	s2,a0,16
    80003392:	854a                	mv	a0,s2
    80003394:	2db000ef          	jal	80003e6e <holdingsleep>
    80003398:	cd09                	beqz	a0,800033b2 <iunlock+0x34>
    8000339a:	449c                	lw	a5,8(s1)
    8000339c:	00f05b63          	blez	a5,800033b2 <iunlock+0x34>
  releasesleep(&ip->lock);
    800033a0:	854a                	mv	a0,s2
    800033a2:	295000ef          	jal	80003e36 <releasesleep>
}
    800033a6:	60e2                	ld	ra,24(sp)
    800033a8:	6442                	ld	s0,16(sp)
    800033aa:	64a2                	ld	s1,8(sp)
    800033ac:	6902                	ld	s2,0(sp)
    800033ae:	6105                	addi	sp,sp,32
    800033b0:	8082                	ret
    panic("iunlock");
    800033b2:	00004517          	auipc	a0,0x4
    800033b6:	1ee50513          	addi	a0,a0,494 # 800075a0 <etext+0x5a0>
    800033ba:	bdafd0ef          	jal	80000794 <panic>

00000000800033be <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800033be:	7179                	addi	sp,sp,-48
    800033c0:	f406                	sd	ra,40(sp)
    800033c2:	f022                	sd	s0,32(sp)
    800033c4:	ec26                	sd	s1,24(sp)
    800033c6:	e84a                	sd	s2,16(sp)
    800033c8:	e44e                	sd	s3,8(sp)
    800033ca:	1800                	addi	s0,sp,48
    800033cc:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800033ce:	05050493          	addi	s1,a0,80
    800033d2:	08050913          	addi	s2,a0,128
    800033d6:	a021                	j	800033de <itrunc+0x20>
    800033d8:	0491                	addi	s1,s1,4
    800033da:	01248b63          	beq	s1,s2,800033f0 <itrunc+0x32>
    if(ip->addrs[i]){
    800033de:	408c                	lw	a1,0(s1)
    800033e0:	dde5                	beqz	a1,800033d8 <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    800033e2:	0009a503          	lw	a0,0(s3)
    800033e6:	9abff0ef          	jal	80002d90 <bfree>
      ip->addrs[i] = 0;
    800033ea:	0004a023          	sw	zero,0(s1)
    800033ee:	b7ed                	j	800033d8 <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    800033f0:	0809a583          	lw	a1,128(s3)
    800033f4:	ed89                	bnez	a1,8000340e <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800033f6:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800033fa:	854e                	mv	a0,s3
    800033fc:	e21ff0ef          	jal	8000321c <iupdate>
}
    80003400:	70a2                	ld	ra,40(sp)
    80003402:	7402                	ld	s0,32(sp)
    80003404:	64e2                	ld	s1,24(sp)
    80003406:	6942                	ld	s2,16(sp)
    80003408:	69a2                	ld	s3,8(sp)
    8000340a:	6145                	addi	sp,sp,48
    8000340c:	8082                	ret
    8000340e:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003410:	0009a503          	lw	a0,0(s3)
    80003414:	f84ff0ef          	jal	80002b98 <bread>
    80003418:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    8000341a:	05850493          	addi	s1,a0,88
    8000341e:	45850913          	addi	s2,a0,1112
    80003422:	a021                	j	8000342a <itrunc+0x6c>
    80003424:	0491                	addi	s1,s1,4
    80003426:	01248963          	beq	s1,s2,80003438 <itrunc+0x7a>
      if(a[j])
    8000342a:	408c                	lw	a1,0(s1)
    8000342c:	dde5                	beqz	a1,80003424 <itrunc+0x66>
        bfree(ip->dev, a[j]);
    8000342e:	0009a503          	lw	a0,0(s3)
    80003432:	95fff0ef          	jal	80002d90 <bfree>
    80003436:	b7fd                	j	80003424 <itrunc+0x66>
    brelse(bp);
    80003438:	8552                	mv	a0,s4
    8000343a:	867ff0ef          	jal	80002ca0 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    8000343e:	0809a583          	lw	a1,128(s3)
    80003442:	0009a503          	lw	a0,0(s3)
    80003446:	94bff0ef          	jal	80002d90 <bfree>
    ip->addrs[NDIRECT] = 0;
    8000344a:	0809a023          	sw	zero,128(s3)
    8000344e:	6a02                	ld	s4,0(sp)
    80003450:	b75d                	j	800033f6 <itrunc+0x38>

0000000080003452 <iput>:
{
    80003452:	1101                	addi	sp,sp,-32
    80003454:	ec06                	sd	ra,24(sp)
    80003456:	e822                	sd	s0,16(sp)
    80003458:	e426                	sd	s1,8(sp)
    8000345a:	1000                	addi	s0,sp,32
    8000345c:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000345e:	0001d517          	auipc	a0,0x1d
    80003462:	52a50513          	addi	a0,a0,1322 # 80020988 <itable>
    80003466:	f8efd0ef          	jal	80000bf4 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000346a:	4498                	lw	a4,8(s1)
    8000346c:	4785                	li	a5,1
    8000346e:	02f70063          	beq	a4,a5,8000348e <iput+0x3c>
  ip->ref--;
    80003472:	449c                	lw	a5,8(s1)
    80003474:	37fd                	addiw	a5,a5,-1
    80003476:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003478:	0001d517          	auipc	a0,0x1d
    8000347c:	51050513          	addi	a0,a0,1296 # 80020988 <itable>
    80003480:	80dfd0ef          	jal	80000c8c <release>
}
    80003484:	60e2                	ld	ra,24(sp)
    80003486:	6442                	ld	s0,16(sp)
    80003488:	64a2                	ld	s1,8(sp)
    8000348a:	6105                	addi	sp,sp,32
    8000348c:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000348e:	40bc                	lw	a5,64(s1)
    80003490:	d3ed                	beqz	a5,80003472 <iput+0x20>
    80003492:	04a49783          	lh	a5,74(s1)
    80003496:	fff1                	bnez	a5,80003472 <iput+0x20>
    80003498:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    8000349a:	01048913          	addi	s2,s1,16
    8000349e:	854a                	mv	a0,s2
    800034a0:	151000ef          	jal	80003df0 <acquiresleep>
    release(&itable.lock);
    800034a4:	0001d517          	auipc	a0,0x1d
    800034a8:	4e450513          	addi	a0,a0,1252 # 80020988 <itable>
    800034ac:	fe0fd0ef          	jal	80000c8c <release>
    itrunc(ip);
    800034b0:	8526                	mv	a0,s1
    800034b2:	f0dff0ef          	jal	800033be <itrunc>
    ip->type = 0;
    800034b6:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    800034ba:	8526                	mv	a0,s1
    800034bc:	d61ff0ef          	jal	8000321c <iupdate>
    ip->valid = 0;
    800034c0:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800034c4:	854a                	mv	a0,s2
    800034c6:	171000ef          	jal	80003e36 <releasesleep>
    acquire(&itable.lock);
    800034ca:	0001d517          	auipc	a0,0x1d
    800034ce:	4be50513          	addi	a0,a0,1214 # 80020988 <itable>
    800034d2:	f22fd0ef          	jal	80000bf4 <acquire>
    800034d6:	6902                	ld	s2,0(sp)
    800034d8:	bf69                	j	80003472 <iput+0x20>

00000000800034da <iunlockput>:
{
    800034da:	1101                	addi	sp,sp,-32
    800034dc:	ec06                	sd	ra,24(sp)
    800034de:	e822                	sd	s0,16(sp)
    800034e0:	e426                	sd	s1,8(sp)
    800034e2:	1000                	addi	s0,sp,32
    800034e4:	84aa                	mv	s1,a0
  iunlock(ip);
    800034e6:	e99ff0ef          	jal	8000337e <iunlock>
  iput(ip);
    800034ea:	8526                	mv	a0,s1
    800034ec:	f67ff0ef          	jal	80003452 <iput>
}
    800034f0:	60e2                	ld	ra,24(sp)
    800034f2:	6442                	ld	s0,16(sp)
    800034f4:	64a2                	ld	s1,8(sp)
    800034f6:	6105                	addi	sp,sp,32
    800034f8:	8082                	ret

00000000800034fa <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    800034fa:	1141                	addi	sp,sp,-16
    800034fc:	e422                	sd	s0,8(sp)
    800034fe:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003500:	411c                	lw	a5,0(a0)
    80003502:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003504:	415c                	lw	a5,4(a0)
    80003506:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003508:	04451783          	lh	a5,68(a0)
    8000350c:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003510:	04a51783          	lh	a5,74(a0)
    80003514:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003518:	04c56783          	lwu	a5,76(a0)
    8000351c:	e99c                	sd	a5,16(a1)
}
    8000351e:	6422                	ld	s0,8(sp)
    80003520:	0141                	addi	sp,sp,16
    80003522:	8082                	ret

0000000080003524 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003524:	457c                	lw	a5,76(a0)
    80003526:	0ed7eb63          	bltu	a5,a3,8000361c <readi+0xf8>
{
    8000352a:	7159                	addi	sp,sp,-112
    8000352c:	f486                	sd	ra,104(sp)
    8000352e:	f0a2                	sd	s0,96(sp)
    80003530:	eca6                	sd	s1,88(sp)
    80003532:	e0d2                	sd	s4,64(sp)
    80003534:	fc56                	sd	s5,56(sp)
    80003536:	f85a                	sd	s6,48(sp)
    80003538:	f45e                	sd	s7,40(sp)
    8000353a:	1880                	addi	s0,sp,112
    8000353c:	8b2a                	mv	s6,a0
    8000353e:	8bae                	mv	s7,a1
    80003540:	8a32                	mv	s4,a2
    80003542:	84b6                	mv	s1,a3
    80003544:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003546:	9f35                	addw	a4,a4,a3
    return 0;
    80003548:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    8000354a:	0cd76063          	bltu	a4,a3,8000360a <readi+0xe6>
    8000354e:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    80003550:	00e7f463          	bgeu	a5,a4,80003558 <readi+0x34>
    n = ip->size - off;
    80003554:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003558:	080a8f63          	beqz	s5,800035f6 <readi+0xd2>
    8000355c:	e8ca                	sd	s2,80(sp)
    8000355e:	f062                	sd	s8,32(sp)
    80003560:	ec66                	sd	s9,24(sp)
    80003562:	e86a                	sd	s10,16(sp)
    80003564:	e46e                	sd	s11,8(sp)
    80003566:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003568:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    8000356c:	5c7d                	li	s8,-1
    8000356e:	a80d                	j	800035a0 <readi+0x7c>
    80003570:	020d1d93          	slli	s11,s10,0x20
    80003574:	020ddd93          	srli	s11,s11,0x20
    80003578:	05890613          	addi	a2,s2,88
    8000357c:	86ee                	mv	a3,s11
    8000357e:	963a                	add	a2,a2,a4
    80003580:	85d2                	mv	a1,s4
    80003582:	855e                	mv	a0,s7
    80003584:	c87fe0ef          	jal	8000220a <either_copyout>
    80003588:	05850763          	beq	a0,s8,800035d6 <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    8000358c:	854a                	mv	a0,s2
    8000358e:	f12ff0ef          	jal	80002ca0 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003592:	013d09bb          	addw	s3,s10,s3
    80003596:	009d04bb          	addw	s1,s10,s1
    8000359a:	9a6e                	add	s4,s4,s11
    8000359c:	0559f763          	bgeu	s3,s5,800035ea <readi+0xc6>
    uint addr = bmap(ip, off/BSIZE);
    800035a0:	00a4d59b          	srliw	a1,s1,0xa
    800035a4:	855a                	mv	a0,s6
    800035a6:	977ff0ef          	jal	80002f1c <bmap>
    800035aa:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    800035ae:	c5b1                	beqz	a1,800035fa <readi+0xd6>
    bp = bread(ip->dev, addr);
    800035b0:	000b2503          	lw	a0,0(s6)
    800035b4:	de4ff0ef          	jal	80002b98 <bread>
    800035b8:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800035ba:	3ff4f713          	andi	a4,s1,1023
    800035be:	40ec87bb          	subw	a5,s9,a4
    800035c2:	413a86bb          	subw	a3,s5,s3
    800035c6:	8d3e                	mv	s10,a5
    800035c8:	2781                	sext.w	a5,a5
    800035ca:	0006861b          	sext.w	a2,a3
    800035ce:	faf671e3          	bgeu	a2,a5,80003570 <readi+0x4c>
    800035d2:	8d36                	mv	s10,a3
    800035d4:	bf71                	j	80003570 <readi+0x4c>
      brelse(bp);
    800035d6:	854a                	mv	a0,s2
    800035d8:	ec8ff0ef          	jal	80002ca0 <brelse>
      tot = -1;
    800035dc:	59fd                	li	s3,-1
      break;
    800035de:	6946                	ld	s2,80(sp)
    800035e0:	7c02                	ld	s8,32(sp)
    800035e2:	6ce2                	ld	s9,24(sp)
    800035e4:	6d42                	ld	s10,16(sp)
    800035e6:	6da2                	ld	s11,8(sp)
    800035e8:	a831                	j	80003604 <readi+0xe0>
    800035ea:	6946                	ld	s2,80(sp)
    800035ec:	7c02                	ld	s8,32(sp)
    800035ee:	6ce2                	ld	s9,24(sp)
    800035f0:	6d42                	ld	s10,16(sp)
    800035f2:	6da2                	ld	s11,8(sp)
    800035f4:	a801                	j	80003604 <readi+0xe0>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800035f6:	89d6                	mv	s3,s5
    800035f8:	a031                	j	80003604 <readi+0xe0>
    800035fa:	6946                	ld	s2,80(sp)
    800035fc:	7c02                	ld	s8,32(sp)
    800035fe:	6ce2                	ld	s9,24(sp)
    80003600:	6d42                	ld	s10,16(sp)
    80003602:	6da2                	ld	s11,8(sp)
  }
  return tot;
    80003604:	0009851b          	sext.w	a0,s3
    80003608:	69a6                	ld	s3,72(sp)
}
    8000360a:	70a6                	ld	ra,104(sp)
    8000360c:	7406                	ld	s0,96(sp)
    8000360e:	64e6                	ld	s1,88(sp)
    80003610:	6a06                	ld	s4,64(sp)
    80003612:	7ae2                	ld	s5,56(sp)
    80003614:	7b42                	ld	s6,48(sp)
    80003616:	7ba2                	ld	s7,40(sp)
    80003618:	6165                	addi	sp,sp,112
    8000361a:	8082                	ret
    return 0;
    8000361c:	4501                	li	a0,0
}
    8000361e:	8082                	ret

0000000080003620 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003620:	457c                	lw	a5,76(a0)
    80003622:	10d7e063          	bltu	a5,a3,80003722 <writei+0x102>
{
    80003626:	7159                	addi	sp,sp,-112
    80003628:	f486                	sd	ra,104(sp)
    8000362a:	f0a2                	sd	s0,96(sp)
    8000362c:	e8ca                	sd	s2,80(sp)
    8000362e:	e0d2                	sd	s4,64(sp)
    80003630:	fc56                	sd	s5,56(sp)
    80003632:	f85a                	sd	s6,48(sp)
    80003634:	f45e                	sd	s7,40(sp)
    80003636:	1880                	addi	s0,sp,112
    80003638:	8aaa                	mv	s5,a0
    8000363a:	8bae                	mv	s7,a1
    8000363c:	8a32                	mv	s4,a2
    8000363e:	8936                	mv	s2,a3
    80003640:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003642:	00e687bb          	addw	a5,a3,a4
    80003646:	0ed7e063          	bltu	a5,a3,80003726 <writei+0x106>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    8000364a:	00043737          	lui	a4,0x43
    8000364e:	0cf76e63          	bltu	a4,a5,8000372a <writei+0x10a>
    80003652:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003654:	0a0b0f63          	beqz	s6,80003712 <writei+0xf2>
    80003658:	eca6                	sd	s1,88(sp)
    8000365a:	f062                	sd	s8,32(sp)
    8000365c:	ec66                	sd	s9,24(sp)
    8000365e:	e86a                	sd	s10,16(sp)
    80003660:	e46e                	sd	s11,8(sp)
    80003662:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003664:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003668:	5c7d                	li	s8,-1
    8000366a:	a825                	j	800036a2 <writei+0x82>
    8000366c:	020d1d93          	slli	s11,s10,0x20
    80003670:	020ddd93          	srli	s11,s11,0x20
    80003674:	05848513          	addi	a0,s1,88
    80003678:	86ee                	mv	a3,s11
    8000367a:	8652                	mv	a2,s4
    8000367c:	85de                	mv	a1,s7
    8000367e:	953a                	add	a0,a0,a4
    80003680:	bd5fe0ef          	jal	80002254 <either_copyin>
    80003684:	05850a63          	beq	a0,s8,800036d8 <writei+0xb8>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003688:	8526                	mv	a0,s1
    8000368a:	660000ef          	jal	80003cea <log_write>
    brelse(bp);
    8000368e:	8526                	mv	a0,s1
    80003690:	e10ff0ef          	jal	80002ca0 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003694:	013d09bb          	addw	s3,s10,s3
    80003698:	012d093b          	addw	s2,s10,s2
    8000369c:	9a6e                	add	s4,s4,s11
    8000369e:	0569f063          	bgeu	s3,s6,800036de <writei+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    800036a2:	00a9559b          	srliw	a1,s2,0xa
    800036a6:	8556                	mv	a0,s5
    800036a8:	875ff0ef          	jal	80002f1c <bmap>
    800036ac:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    800036b0:	c59d                	beqz	a1,800036de <writei+0xbe>
    bp = bread(ip->dev, addr);
    800036b2:	000aa503          	lw	a0,0(s5)
    800036b6:	ce2ff0ef          	jal	80002b98 <bread>
    800036ba:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800036bc:	3ff97713          	andi	a4,s2,1023
    800036c0:	40ec87bb          	subw	a5,s9,a4
    800036c4:	413b06bb          	subw	a3,s6,s3
    800036c8:	8d3e                	mv	s10,a5
    800036ca:	2781                	sext.w	a5,a5
    800036cc:	0006861b          	sext.w	a2,a3
    800036d0:	f8f67ee3          	bgeu	a2,a5,8000366c <writei+0x4c>
    800036d4:	8d36                	mv	s10,a3
    800036d6:	bf59                	j	8000366c <writei+0x4c>
      brelse(bp);
    800036d8:	8526                	mv	a0,s1
    800036da:	dc6ff0ef          	jal	80002ca0 <brelse>
  }

  if(off > ip->size)
    800036de:	04caa783          	lw	a5,76(s5)
    800036e2:	0327fa63          	bgeu	a5,s2,80003716 <writei+0xf6>
    ip->size = off;
    800036e6:	052aa623          	sw	s2,76(s5)
    800036ea:	64e6                	ld	s1,88(sp)
    800036ec:	7c02                	ld	s8,32(sp)
    800036ee:	6ce2                	ld	s9,24(sp)
    800036f0:	6d42                	ld	s10,16(sp)
    800036f2:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    800036f4:	8556                	mv	a0,s5
    800036f6:	b27ff0ef          	jal	8000321c <iupdate>

  return tot;
    800036fa:	0009851b          	sext.w	a0,s3
    800036fe:	69a6                	ld	s3,72(sp)
}
    80003700:	70a6                	ld	ra,104(sp)
    80003702:	7406                	ld	s0,96(sp)
    80003704:	6946                	ld	s2,80(sp)
    80003706:	6a06                	ld	s4,64(sp)
    80003708:	7ae2                	ld	s5,56(sp)
    8000370a:	7b42                	ld	s6,48(sp)
    8000370c:	7ba2                	ld	s7,40(sp)
    8000370e:	6165                	addi	sp,sp,112
    80003710:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003712:	89da                	mv	s3,s6
    80003714:	b7c5                	j	800036f4 <writei+0xd4>
    80003716:	64e6                	ld	s1,88(sp)
    80003718:	7c02                	ld	s8,32(sp)
    8000371a:	6ce2                	ld	s9,24(sp)
    8000371c:	6d42                	ld	s10,16(sp)
    8000371e:	6da2                	ld	s11,8(sp)
    80003720:	bfd1                	j	800036f4 <writei+0xd4>
    return -1;
    80003722:	557d                	li	a0,-1
}
    80003724:	8082                	ret
    return -1;
    80003726:	557d                	li	a0,-1
    80003728:	bfe1                	j	80003700 <writei+0xe0>
    return -1;
    8000372a:	557d                	li	a0,-1
    8000372c:	bfd1                	j	80003700 <writei+0xe0>

000000008000372e <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    8000372e:	1141                	addi	sp,sp,-16
    80003730:	e406                	sd	ra,8(sp)
    80003732:	e022                	sd	s0,0(sp)
    80003734:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003736:	4639                	li	a2,14
    80003738:	e5cfd0ef          	jal	80000d94 <strncmp>
}
    8000373c:	60a2                	ld	ra,8(sp)
    8000373e:	6402                	ld	s0,0(sp)
    80003740:	0141                	addi	sp,sp,16
    80003742:	8082                	ret

0000000080003744 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003744:	7139                	addi	sp,sp,-64
    80003746:	fc06                	sd	ra,56(sp)
    80003748:	f822                	sd	s0,48(sp)
    8000374a:	f426                	sd	s1,40(sp)
    8000374c:	f04a                	sd	s2,32(sp)
    8000374e:	ec4e                	sd	s3,24(sp)
    80003750:	e852                	sd	s4,16(sp)
    80003752:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003754:	04451703          	lh	a4,68(a0)
    80003758:	4785                	li	a5,1
    8000375a:	00f71a63          	bne	a4,a5,8000376e <dirlookup+0x2a>
    8000375e:	892a                	mv	s2,a0
    80003760:	89ae                	mv	s3,a1
    80003762:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003764:	457c                	lw	a5,76(a0)
    80003766:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003768:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000376a:	e39d                	bnez	a5,80003790 <dirlookup+0x4c>
    8000376c:	a095                	j	800037d0 <dirlookup+0x8c>
    panic("dirlookup not DIR");
    8000376e:	00004517          	auipc	a0,0x4
    80003772:	e3a50513          	addi	a0,a0,-454 # 800075a8 <etext+0x5a8>
    80003776:	81efd0ef          	jal	80000794 <panic>
      panic("dirlookup read");
    8000377a:	00004517          	auipc	a0,0x4
    8000377e:	e4650513          	addi	a0,a0,-442 # 800075c0 <etext+0x5c0>
    80003782:	812fd0ef          	jal	80000794 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003786:	24c1                	addiw	s1,s1,16
    80003788:	04c92783          	lw	a5,76(s2)
    8000378c:	04f4f163          	bgeu	s1,a5,800037ce <dirlookup+0x8a>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003790:	4741                	li	a4,16
    80003792:	86a6                	mv	a3,s1
    80003794:	fc040613          	addi	a2,s0,-64
    80003798:	4581                	li	a1,0
    8000379a:	854a                	mv	a0,s2
    8000379c:	d89ff0ef          	jal	80003524 <readi>
    800037a0:	47c1                	li	a5,16
    800037a2:	fcf51ce3          	bne	a0,a5,8000377a <dirlookup+0x36>
    if(de.inum == 0)
    800037a6:	fc045783          	lhu	a5,-64(s0)
    800037aa:	dff1                	beqz	a5,80003786 <dirlookup+0x42>
    if(namecmp(name, de.name) == 0){
    800037ac:	fc240593          	addi	a1,s0,-62
    800037b0:	854e                	mv	a0,s3
    800037b2:	f7dff0ef          	jal	8000372e <namecmp>
    800037b6:	f961                	bnez	a0,80003786 <dirlookup+0x42>
      if(poff)
    800037b8:	000a0463          	beqz	s4,800037c0 <dirlookup+0x7c>
        *poff = off;
    800037bc:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    800037c0:	fc045583          	lhu	a1,-64(s0)
    800037c4:	00092503          	lw	a0,0(s2)
    800037c8:	829ff0ef          	jal	80002ff0 <iget>
    800037cc:	a011                	j	800037d0 <dirlookup+0x8c>
  return 0;
    800037ce:	4501                	li	a0,0
}
    800037d0:	70e2                	ld	ra,56(sp)
    800037d2:	7442                	ld	s0,48(sp)
    800037d4:	74a2                	ld	s1,40(sp)
    800037d6:	7902                	ld	s2,32(sp)
    800037d8:	69e2                	ld	s3,24(sp)
    800037da:	6a42                	ld	s4,16(sp)
    800037dc:	6121                	addi	sp,sp,64
    800037de:	8082                	ret

00000000800037e0 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    800037e0:	711d                	addi	sp,sp,-96
    800037e2:	ec86                	sd	ra,88(sp)
    800037e4:	e8a2                	sd	s0,80(sp)
    800037e6:	e4a6                	sd	s1,72(sp)
    800037e8:	e0ca                	sd	s2,64(sp)
    800037ea:	fc4e                	sd	s3,56(sp)
    800037ec:	f852                	sd	s4,48(sp)
    800037ee:	f456                	sd	s5,40(sp)
    800037f0:	f05a                	sd	s6,32(sp)
    800037f2:	ec5e                	sd	s7,24(sp)
    800037f4:	e862                	sd	s8,16(sp)
    800037f6:	e466                	sd	s9,8(sp)
    800037f8:	1080                	addi	s0,sp,96
    800037fa:	84aa                	mv	s1,a0
    800037fc:	8b2e                	mv	s6,a1
    800037fe:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003800:	00054703          	lbu	a4,0(a0)
    80003804:	02f00793          	li	a5,47
    80003808:	00f70e63          	beq	a4,a5,80003824 <namex+0x44>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    8000380c:	8d4fe0ef          	jal	800018e0 <myproc>
    80003810:	15053503          	ld	a0,336(a0)
    80003814:	a87ff0ef          	jal	8000329a <idup>
    80003818:	8a2a                	mv	s4,a0
  while(*path == '/')
    8000381a:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    8000381e:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003820:	4b85                	li	s7,1
    80003822:	a871                	j	800038be <namex+0xde>
    ip = iget(ROOTDEV, ROOTINO);
    80003824:	4585                	li	a1,1
    80003826:	4505                	li	a0,1
    80003828:	fc8ff0ef          	jal	80002ff0 <iget>
    8000382c:	8a2a                	mv	s4,a0
    8000382e:	b7f5                	j	8000381a <namex+0x3a>
      iunlockput(ip);
    80003830:	8552                	mv	a0,s4
    80003832:	ca9ff0ef          	jal	800034da <iunlockput>
      return 0;
    80003836:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003838:	8552                	mv	a0,s4
    8000383a:	60e6                	ld	ra,88(sp)
    8000383c:	6446                	ld	s0,80(sp)
    8000383e:	64a6                	ld	s1,72(sp)
    80003840:	6906                	ld	s2,64(sp)
    80003842:	79e2                	ld	s3,56(sp)
    80003844:	7a42                	ld	s4,48(sp)
    80003846:	7aa2                	ld	s5,40(sp)
    80003848:	7b02                	ld	s6,32(sp)
    8000384a:	6be2                	ld	s7,24(sp)
    8000384c:	6c42                	ld	s8,16(sp)
    8000384e:	6ca2                	ld	s9,8(sp)
    80003850:	6125                	addi	sp,sp,96
    80003852:	8082                	ret
      iunlock(ip);
    80003854:	8552                	mv	a0,s4
    80003856:	b29ff0ef          	jal	8000337e <iunlock>
      return ip;
    8000385a:	bff9                	j	80003838 <namex+0x58>
      iunlockput(ip);
    8000385c:	8552                	mv	a0,s4
    8000385e:	c7dff0ef          	jal	800034da <iunlockput>
      return 0;
    80003862:	8a4e                	mv	s4,s3
    80003864:	bfd1                	j	80003838 <namex+0x58>
  len = path - s;
    80003866:	40998633          	sub	a2,s3,s1
    8000386a:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    8000386e:	099c5063          	bge	s8,s9,800038ee <namex+0x10e>
    memmove(name, s, DIRSIZ);
    80003872:	4639                	li	a2,14
    80003874:	85a6                	mv	a1,s1
    80003876:	8556                	mv	a0,s5
    80003878:	cacfd0ef          	jal	80000d24 <memmove>
    8000387c:	84ce                	mv	s1,s3
  while(*path == '/')
    8000387e:	0004c783          	lbu	a5,0(s1)
    80003882:	01279763          	bne	a5,s2,80003890 <namex+0xb0>
    path++;
    80003886:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003888:	0004c783          	lbu	a5,0(s1)
    8000388c:	ff278de3          	beq	a5,s2,80003886 <namex+0xa6>
    ilock(ip);
    80003890:	8552                	mv	a0,s4
    80003892:	a3fff0ef          	jal	800032d0 <ilock>
    if(ip->type != T_DIR){
    80003896:	044a1783          	lh	a5,68(s4)
    8000389a:	f9779be3          	bne	a5,s7,80003830 <namex+0x50>
    if(nameiparent && *path == '\0'){
    8000389e:	000b0563          	beqz	s6,800038a8 <namex+0xc8>
    800038a2:	0004c783          	lbu	a5,0(s1)
    800038a6:	d7dd                	beqz	a5,80003854 <namex+0x74>
    if((next = dirlookup(ip, name, 0)) == 0){
    800038a8:	4601                	li	a2,0
    800038aa:	85d6                	mv	a1,s5
    800038ac:	8552                	mv	a0,s4
    800038ae:	e97ff0ef          	jal	80003744 <dirlookup>
    800038b2:	89aa                	mv	s3,a0
    800038b4:	d545                	beqz	a0,8000385c <namex+0x7c>
    iunlockput(ip);
    800038b6:	8552                	mv	a0,s4
    800038b8:	c23ff0ef          	jal	800034da <iunlockput>
    ip = next;
    800038bc:	8a4e                	mv	s4,s3
  while(*path == '/')
    800038be:	0004c783          	lbu	a5,0(s1)
    800038c2:	01279763          	bne	a5,s2,800038d0 <namex+0xf0>
    path++;
    800038c6:	0485                	addi	s1,s1,1
  while(*path == '/')
    800038c8:	0004c783          	lbu	a5,0(s1)
    800038cc:	ff278de3          	beq	a5,s2,800038c6 <namex+0xe6>
  if(*path == 0)
    800038d0:	cb8d                	beqz	a5,80003902 <namex+0x122>
  while(*path != '/' && *path != 0)
    800038d2:	0004c783          	lbu	a5,0(s1)
    800038d6:	89a6                	mv	s3,s1
  len = path - s;
    800038d8:	4c81                	li	s9,0
    800038da:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    800038dc:	01278963          	beq	a5,s2,800038ee <namex+0x10e>
    800038e0:	d3d9                	beqz	a5,80003866 <namex+0x86>
    path++;
    800038e2:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    800038e4:	0009c783          	lbu	a5,0(s3)
    800038e8:	ff279ce3          	bne	a5,s2,800038e0 <namex+0x100>
    800038ec:	bfad                	j	80003866 <namex+0x86>
    memmove(name, s, len);
    800038ee:	2601                	sext.w	a2,a2
    800038f0:	85a6                	mv	a1,s1
    800038f2:	8556                	mv	a0,s5
    800038f4:	c30fd0ef          	jal	80000d24 <memmove>
    name[len] = 0;
    800038f8:	9cd6                	add	s9,s9,s5
    800038fa:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    800038fe:	84ce                	mv	s1,s3
    80003900:	bfbd                	j	8000387e <namex+0x9e>
  if(nameiparent){
    80003902:	f20b0be3          	beqz	s6,80003838 <namex+0x58>
    iput(ip);
    80003906:	8552                	mv	a0,s4
    80003908:	b4bff0ef          	jal	80003452 <iput>
    return 0;
    8000390c:	4a01                	li	s4,0
    8000390e:	b72d                	j	80003838 <namex+0x58>

0000000080003910 <dirlink>:
{
    80003910:	7139                	addi	sp,sp,-64
    80003912:	fc06                	sd	ra,56(sp)
    80003914:	f822                	sd	s0,48(sp)
    80003916:	f04a                	sd	s2,32(sp)
    80003918:	ec4e                	sd	s3,24(sp)
    8000391a:	e852                	sd	s4,16(sp)
    8000391c:	0080                	addi	s0,sp,64
    8000391e:	892a                	mv	s2,a0
    80003920:	8a2e                	mv	s4,a1
    80003922:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003924:	4601                	li	a2,0
    80003926:	e1fff0ef          	jal	80003744 <dirlookup>
    8000392a:	e535                	bnez	a0,80003996 <dirlink+0x86>
    8000392c:	f426                	sd	s1,40(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000392e:	04c92483          	lw	s1,76(s2)
    80003932:	c48d                	beqz	s1,8000395c <dirlink+0x4c>
    80003934:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003936:	4741                	li	a4,16
    80003938:	86a6                	mv	a3,s1
    8000393a:	fc040613          	addi	a2,s0,-64
    8000393e:	4581                	li	a1,0
    80003940:	854a                	mv	a0,s2
    80003942:	be3ff0ef          	jal	80003524 <readi>
    80003946:	47c1                	li	a5,16
    80003948:	04f51b63          	bne	a0,a5,8000399e <dirlink+0x8e>
    if(de.inum == 0)
    8000394c:	fc045783          	lhu	a5,-64(s0)
    80003950:	c791                	beqz	a5,8000395c <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003952:	24c1                	addiw	s1,s1,16
    80003954:	04c92783          	lw	a5,76(s2)
    80003958:	fcf4efe3          	bltu	s1,a5,80003936 <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    8000395c:	4639                	li	a2,14
    8000395e:	85d2                	mv	a1,s4
    80003960:	fc240513          	addi	a0,s0,-62
    80003964:	c66fd0ef          	jal	80000dca <strncpy>
  de.inum = inum;
    80003968:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000396c:	4741                	li	a4,16
    8000396e:	86a6                	mv	a3,s1
    80003970:	fc040613          	addi	a2,s0,-64
    80003974:	4581                	li	a1,0
    80003976:	854a                	mv	a0,s2
    80003978:	ca9ff0ef          	jal	80003620 <writei>
    8000397c:	1541                	addi	a0,a0,-16
    8000397e:	00a03533          	snez	a0,a0
    80003982:	40a00533          	neg	a0,a0
    80003986:	74a2                	ld	s1,40(sp)
}
    80003988:	70e2                	ld	ra,56(sp)
    8000398a:	7442                	ld	s0,48(sp)
    8000398c:	7902                	ld	s2,32(sp)
    8000398e:	69e2                	ld	s3,24(sp)
    80003990:	6a42                	ld	s4,16(sp)
    80003992:	6121                	addi	sp,sp,64
    80003994:	8082                	ret
    iput(ip);
    80003996:	abdff0ef          	jal	80003452 <iput>
    return -1;
    8000399a:	557d                	li	a0,-1
    8000399c:	b7f5                	j	80003988 <dirlink+0x78>
      panic("dirlink read");
    8000399e:	00004517          	auipc	a0,0x4
    800039a2:	c3250513          	addi	a0,a0,-974 # 800075d0 <etext+0x5d0>
    800039a6:	deffc0ef          	jal	80000794 <panic>

00000000800039aa <namei>:

struct inode*
namei(char *path)
{
    800039aa:	1101                	addi	sp,sp,-32
    800039ac:	ec06                	sd	ra,24(sp)
    800039ae:	e822                	sd	s0,16(sp)
    800039b0:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    800039b2:	fe040613          	addi	a2,s0,-32
    800039b6:	4581                	li	a1,0
    800039b8:	e29ff0ef          	jal	800037e0 <namex>
}
    800039bc:	60e2                	ld	ra,24(sp)
    800039be:	6442                	ld	s0,16(sp)
    800039c0:	6105                	addi	sp,sp,32
    800039c2:	8082                	ret

00000000800039c4 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800039c4:	1141                	addi	sp,sp,-16
    800039c6:	e406                	sd	ra,8(sp)
    800039c8:	e022                	sd	s0,0(sp)
    800039ca:	0800                	addi	s0,sp,16
    800039cc:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800039ce:	4585                	li	a1,1
    800039d0:	e11ff0ef          	jal	800037e0 <namex>
}
    800039d4:	60a2                	ld	ra,8(sp)
    800039d6:	6402                	ld	s0,0(sp)
    800039d8:	0141                	addi	sp,sp,16
    800039da:	8082                	ret

00000000800039dc <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800039dc:	1101                	addi	sp,sp,-32
    800039de:	ec06                	sd	ra,24(sp)
    800039e0:	e822                	sd	s0,16(sp)
    800039e2:	e426                	sd	s1,8(sp)
    800039e4:	e04a                	sd	s2,0(sp)
    800039e6:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    800039e8:	0001f917          	auipc	s2,0x1f
    800039ec:	a4890913          	addi	s2,s2,-1464 # 80022430 <log>
    800039f0:	01892583          	lw	a1,24(s2)
    800039f4:	02892503          	lw	a0,40(s2)
    800039f8:	9a0ff0ef          	jal	80002b98 <bread>
    800039fc:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    800039fe:	02c92603          	lw	a2,44(s2)
    80003a02:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003a04:	00c05f63          	blez	a2,80003a22 <write_head+0x46>
    80003a08:	0001f717          	auipc	a4,0x1f
    80003a0c:	a5870713          	addi	a4,a4,-1448 # 80022460 <log+0x30>
    80003a10:	87aa                	mv	a5,a0
    80003a12:	060a                	slli	a2,a2,0x2
    80003a14:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003a16:	4314                	lw	a3,0(a4)
    80003a18:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003a1a:	0711                	addi	a4,a4,4
    80003a1c:	0791                	addi	a5,a5,4
    80003a1e:	fec79ce3          	bne	a5,a2,80003a16 <write_head+0x3a>
  }
  bwrite(buf);
    80003a22:	8526                	mv	a0,s1
    80003a24:	a4aff0ef          	jal	80002c6e <bwrite>
  brelse(buf);
    80003a28:	8526                	mv	a0,s1
    80003a2a:	a76ff0ef          	jal	80002ca0 <brelse>
}
    80003a2e:	60e2                	ld	ra,24(sp)
    80003a30:	6442                	ld	s0,16(sp)
    80003a32:	64a2                	ld	s1,8(sp)
    80003a34:	6902                	ld	s2,0(sp)
    80003a36:	6105                	addi	sp,sp,32
    80003a38:	8082                	ret

0000000080003a3a <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003a3a:	0001f797          	auipc	a5,0x1f
    80003a3e:	a227a783          	lw	a5,-1502(a5) # 8002245c <log+0x2c>
    80003a42:	08f05f63          	blez	a5,80003ae0 <install_trans+0xa6>
{
    80003a46:	7139                	addi	sp,sp,-64
    80003a48:	fc06                	sd	ra,56(sp)
    80003a4a:	f822                	sd	s0,48(sp)
    80003a4c:	f426                	sd	s1,40(sp)
    80003a4e:	f04a                	sd	s2,32(sp)
    80003a50:	ec4e                	sd	s3,24(sp)
    80003a52:	e852                	sd	s4,16(sp)
    80003a54:	e456                	sd	s5,8(sp)
    80003a56:	e05a                	sd	s6,0(sp)
    80003a58:	0080                	addi	s0,sp,64
    80003a5a:	8b2a                	mv	s6,a0
    80003a5c:	0001fa97          	auipc	s5,0x1f
    80003a60:	a04a8a93          	addi	s5,s5,-1532 # 80022460 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003a64:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003a66:	0001f997          	auipc	s3,0x1f
    80003a6a:	9ca98993          	addi	s3,s3,-1590 # 80022430 <log>
    80003a6e:	a829                	j	80003a88 <install_trans+0x4e>
    brelse(lbuf);
    80003a70:	854a                	mv	a0,s2
    80003a72:	a2eff0ef          	jal	80002ca0 <brelse>
    brelse(dbuf);
    80003a76:	8526                	mv	a0,s1
    80003a78:	a28ff0ef          	jal	80002ca0 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003a7c:	2a05                	addiw	s4,s4,1
    80003a7e:	0a91                	addi	s5,s5,4
    80003a80:	02c9a783          	lw	a5,44(s3)
    80003a84:	04fa5463          	bge	s4,a5,80003acc <install_trans+0x92>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003a88:	0189a583          	lw	a1,24(s3)
    80003a8c:	014585bb          	addw	a1,a1,s4
    80003a90:	2585                	addiw	a1,a1,1
    80003a92:	0289a503          	lw	a0,40(s3)
    80003a96:	902ff0ef          	jal	80002b98 <bread>
    80003a9a:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003a9c:	000aa583          	lw	a1,0(s5)
    80003aa0:	0289a503          	lw	a0,40(s3)
    80003aa4:	8f4ff0ef          	jal	80002b98 <bread>
    80003aa8:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003aaa:	40000613          	li	a2,1024
    80003aae:	05890593          	addi	a1,s2,88
    80003ab2:	05850513          	addi	a0,a0,88
    80003ab6:	a6efd0ef          	jal	80000d24 <memmove>
    bwrite(dbuf);  // write dst to disk
    80003aba:	8526                	mv	a0,s1
    80003abc:	9b2ff0ef          	jal	80002c6e <bwrite>
    if(recovering == 0)
    80003ac0:	fa0b18e3          	bnez	s6,80003a70 <install_trans+0x36>
      bunpin(dbuf);
    80003ac4:	8526                	mv	a0,s1
    80003ac6:	a96ff0ef          	jal	80002d5c <bunpin>
    80003aca:	b75d                	j	80003a70 <install_trans+0x36>
}
    80003acc:	70e2                	ld	ra,56(sp)
    80003ace:	7442                	ld	s0,48(sp)
    80003ad0:	74a2                	ld	s1,40(sp)
    80003ad2:	7902                	ld	s2,32(sp)
    80003ad4:	69e2                	ld	s3,24(sp)
    80003ad6:	6a42                	ld	s4,16(sp)
    80003ad8:	6aa2                	ld	s5,8(sp)
    80003ada:	6b02                	ld	s6,0(sp)
    80003adc:	6121                	addi	sp,sp,64
    80003ade:	8082                	ret
    80003ae0:	8082                	ret

0000000080003ae2 <initlog>:
{
    80003ae2:	7179                	addi	sp,sp,-48
    80003ae4:	f406                	sd	ra,40(sp)
    80003ae6:	f022                	sd	s0,32(sp)
    80003ae8:	ec26                	sd	s1,24(sp)
    80003aea:	e84a                	sd	s2,16(sp)
    80003aec:	e44e                	sd	s3,8(sp)
    80003aee:	1800                	addi	s0,sp,48
    80003af0:	892a                	mv	s2,a0
    80003af2:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003af4:	0001f497          	auipc	s1,0x1f
    80003af8:	93c48493          	addi	s1,s1,-1732 # 80022430 <log>
    80003afc:	00004597          	auipc	a1,0x4
    80003b00:	ae458593          	addi	a1,a1,-1308 # 800075e0 <etext+0x5e0>
    80003b04:	8526                	mv	a0,s1
    80003b06:	86efd0ef          	jal	80000b74 <initlock>
  log.start = sb->logstart;
    80003b0a:	0149a583          	lw	a1,20(s3)
    80003b0e:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80003b10:	0109a783          	lw	a5,16(s3)
    80003b14:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80003b16:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003b1a:	854a                	mv	a0,s2
    80003b1c:	87cff0ef          	jal	80002b98 <bread>
  log.lh.n = lh->n;
    80003b20:	4d30                	lw	a2,88(a0)
    80003b22:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80003b24:	00c05f63          	blez	a2,80003b42 <initlog+0x60>
    80003b28:	87aa                	mv	a5,a0
    80003b2a:	0001f717          	auipc	a4,0x1f
    80003b2e:	93670713          	addi	a4,a4,-1738 # 80022460 <log+0x30>
    80003b32:	060a                	slli	a2,a2,0x2
    80003b34:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80003b36:	4ff4                	lw	a3,92(a5)
    80003b38:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003b3a:	0791                	addi	a5,a5,4
    80003b3c:	0711                	addi	a4,a4,4
    80003b3e:	fec79ce3          	bne	a5,a2,80003b36 <initlog+0x54>
  brelse(buf);
    80003b42:	95eff0ef          	jal	80002ca0 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003b46:	4505                	li	a0,1
    80003b48:	ef3ff0ef          	jal	80003a3a <install_trans>
  log.lh.n = 0;
    80003b4c:	0001f797          	auipc	a5,0x1f
    80003b50:	9007a823          	sw	zero,-1776(a5) # 8002245c <log+0x2c>
  write_head(); // clear the log
    80003b54:	e89ff0ef          	jal	800039dc <write_head>
}
    80003b58:	70a2                	ld	ra,40(sp)
    80003b5a:	7402                	ld	s0,32(sp)
    80003b5c:	64e2                	ld	s1,24(sp)
    80003b5e:	6942                	ld	s2,16(sp)
    80003b60:	69a2                	ld	s3,8(sp)
    80003b62:	6145                	addi	sp,sp,48
    80003b64:	8082                	ret

0000000080003b66 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003b66:	1101                	addi	sp,sp,-32
    80003b68:	ec06                	sd	ra,24(sp)
    80003b6a:	e822                	sd	s0,16(sp)
    80003b6c:	e426                	sd	s1,8(sp)
    80003b6e:	e04a                	sd	s2,0(sp)
    80003b70:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003b72:	0001f517          	auipc	a0,0x1f
    80003b76:	8be50513          	addi	a0,a0,-1858 # 80022430 <log>
    80003b7a:	87afd0ef          	jal	80000bf4 <acquire>
  while(1){
    if(log.committing){
    80003b7e:	0001f497          	auipc	s1,0x1f
    80003b82:	8b248493          	addi	s1,s1,-1870 # 80022430 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80003b86:	4979                	li	s2,30
    80003b88:	a029                	j	80003b92 <begin_op+0x2c>
      sleep(&log, &log.lock);
    80003b8a:	85a6                	mv	a1,s1
    80003b8c:	8526                	mv	a0,s1
    80003b8e:	b20fe0ef          	jal	80001eae <sleep>
    if(log.committing){
    80003b92:	50dc                	lw	a5,36(s1)
    80003b94:	fbfd                	bnez	a5,80003b8a <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80003b96:	5098                	lw	a4,32(s1)
    80003b98:	2705                	addiw	a4,a4,1
    80003b9a:	0027179b          	slliw	a5,a4,0x2
    80003b9e:	9fb9                	addw	a5,a5,a4
    80003ba0:	0017979b          	slliw	a5,a5,0x1
    80003ba4:	54d4                	lw	a3,44(s1)
    80003ba6:	9fb5                	addw	a5,a5,a3
    80003ba8:	00f95763          	bge	s2,a5,80003bb6 <begin_op+0x50>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80003bac:	85a6                	mv	a1,s1
    80003bae:	8526                	mv	a0,s1
    80003bb0:	afefe0ef          	jal	80001eae <sleep>
    80003bb4:	bff9                	j	80003b92 <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    80003bb6:	0001f517          	auipc	a0,0x1f
    80003bba:	87a50513          	addi	a0,a0,-1926 # 80022430 <log>
    80003bbe:	d118                	sw	a4,32(a0)
      release(&log.lock);
    80003bc0:	8ccfd0ef          	jal	80000c8c <release>
      break;
    }
  }
}
    80003bc4:	60e2                	ld	ra,24(sp)
    80003bc6:	6442                	ld	s0,16(sp)
    80003bc8:	64a2                	ld	s1,8(sp)
    80003bca:	6902                	ld	s2,0(sp)
    80003bcc:	6105                	addi	sp,sp,32
    80003bce:	8082                	ret

0000000080003bd0 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003bd0:	7139                	addi	sp,sp,-64
    80003bd2:	fc06                	sd	ra,56(sp)
    80003bd4:	f822                	sd	s0,48(sp)
    80003bd6:	f426                	sd	s1,40(sp)
    80003bd8:	f04a                	sd	s2,32(sp)
    80003bda:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003bdc:	0001f497          	auipc	s1,0x1f
    80003be0:	85448493          	addi	s1,s1,-1964 # 80022430 <log>
    80003be4:	8526                	mv	a0,s1
    80003be6:	80efd0ef          	jal	80000bf4 <acquire>
  log.outstanding -= 1;
    80003bea:	509c                	lw	a5,32(s1)
    80003bec:	37fd                	addiw	a5,a5,-1
    80003bee:	0007891b          	sext.w	s2,a5
    80003bf2:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80003bf4:	50dc                	lw	a5,36(s1)
    80003bf6:	ef9d                	bnez	a5,80003c34 <end_op+0x64>
    panic("log.committing");
  if(log.outstanding == 0){
    80003bf8:	04091763          	bnez	s2,80003c46 <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    80003bfc:	0001f497          	auipc	s1,0x1f
    80003c00:	83448493          	addi	s1,s1,-1996 # 80022430 <log>
    80003c04:	4785                	li	a5,1
    80003c06:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003c08:	8526                	mv	a0,s1
    80003c0a:	882fd0ef          	jal	80000c8c <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003c0e:	54dc                	lw	a5,44(s1)
    80003c10:	04f04b63          	bgtz	a5,80003c66 <end_op+0x96>
    acquire(&log.lock);
    80003c14:	0001f497          	auipc	s1,0x1f
    80003c18:	81c48493          	addi	s1,s1,-2020 # 80022430 <log>
    80003c1c:	8526                	mv	a0,s1
    80003c1e:	fd7fc0ef          	jal	80000bf4 <acquire>
    log.committing = 0;
    80003c22:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80003c26:	8526                	mv	a0,s1
    80003c28:	ad2fe0ef          	jal	80001efa <wakeup>
    release(&log.lock);
    80003c2c:	8526                	mv	a0,s1
    80003c2e:	85efd0ef          	jal	80000c8c <release>
}
    80003c32:	a025                	j	80003c5a <end_op+0x8a>
    80003c34:	ec4e                	sd	s3,24(sp)
    80003c36:	e852                	sd	s4,16(sp)
    80003c38:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80003c3a:	00004517          	auipc	a0,0x4
    80003c3e:	9ae50513          	addi	a0,a0,-1618 # 800075e8 <etext+0x5e8>
    80003c42:	b53fc0ef          	jal	80000794 <panic>
    wakeup(&log);
    80003c46:	0001e497          	auipc	s1,0x1e
    80003c4a:	7ea48493          	addi	s1,s1,2026 # 80022430 <log>
    80003c4e:	8526                	mv	a0,s1
    80003c50:	aaafe0ef          	jal	80001efa <wakeup>
  release(&log.lock);
    80003c54:	8526                	mv	a0,s1
    80003c56:	836fd0ef          	jal	80000c8c <release>
}
    80003c5a:	70e2                	ld	ra,56(sp)
    80003c5c:	7442                	ld	s0,48(sp)
    80003c5e:	74a2                	ld	s1,40(sp)
    80003c60:	7902                	ld	s2,32(sp)
    80003c62:	6121                	addi	sp,sp,64
    80003c64:	8082                	ret
    80003c66:	ec4e                	sd	s3,24(sp)
    80003c68:	e852                	sd	s4,16(sp)
    80003c6a:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80003c6c:	0001ea97          	auipc	s5,0x1e
    80003c70:	7f4a8a93          	addi	s5,s5,2036 # 80022460 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80003c74:	0001ea17          	auipc	s4,0x1e
    80003c78:	7bca0a13          	addi	s4,s4,1980 # 80022430 <log>
    80003c7c:	018a2583          	lw	a1,24(s4)
    80003c80:	012585bb          	addw	a1,a1,s2
    80003c84:	2585                	addiw	a1,a1,1
    80003c86:	028a2503          	lw	a0,40(s4)
    80003c8a:	f0ffe0ef          	jal	80002b98 <bread>
    80003c8e:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80003c90:	000aa583          	lw	a1,0(s5)
    80003c94:	028a2503          	lw	a0,40(s4)
    80003c98:	f01fe0ef          	jal	80002b98 <bread>
    80003c9c:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80003c9e:	40000613          	li	a2,1024
    80003ca2:	05850593          	addi	a1,a0,88
    80003ca6:	05848513          	addi	a0,s1,88
    80003caa:	87afd0ef          	jal	80000d24 <memmove>
    bwrite(to);  // write the log
    80003cae:	8526                	mv	a0,s1
    80003cb0:	fbffe0ef          	jal	80002c6e <bwrite>
    brelse(from);
    80003cb4:	854e                	mv	a0,s3
    80003cb6:	febfe0ef          	jal	80002ca0 <brelse>
    brelse(to);
    80003cba:	8526                	mv	a0,s1
    80003cbc:	fe5fe0ef          	jal	80002ca0 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003cc0:	2905                	addiw	s2,s2,1
    80003cc2:	0a91                	addi	s5,s5,4
    80003cc4:	02ca2783          	lw	a5,44(s4)
    80003cc8:	faf94ae3          	blt	s2,a5,80003c7c <end_op+0xac>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80003ccc:	d11ff0ef          	jal	800039dc <write_head>
    install_trans(0); // Now install writes to home locations
    80003cd0:	4501                	li	a0,0
    80003cd2:	d69ff0ef          	jal	80003a3a <install_trans>
    log.lh.n = 0;
    80003cd6:	0001e797          	auipc	a5,0x1e
    80003cda:	7807a323          	sw	zero,1926(a5) # 8002245c <log+0x2c>
    write_head();    // Erase the transaction from the log
    80003cde:	cffff0ef          	jal	800039dc <write_head>
    80003ce2:	69e2                	ld	s3,24(sp)
    80003ce4:	6a42                	ld	s4,16(sp)
    80003ce6:	6aa2                	ld	s5,8(sp)
    80003ce8:	b735                	j	80003c14 <end_op+0x44>

0000000080003cea <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80003cea:	1101                	addi	sp,sp,-32
    80003cec:	ec06                	sd	ra,24(sp)
    80003cee:	e822                	sd	s0,16(sp)
    80003cf0:	e426                	sd	s1,8(sp)
    80003cf2:	e04a                	sd	s2,0(sp)
    80003cf4:	1000                	addi	s0,sp,32
    80003cf6:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80003cf8:	0001e917          	auipc	s2,0x1e
    80003cfc:	73890913          	addi	s2,s2,1848 # 80022430 <log>
    80003d00:	854a                	mv	a0,s2
    80003d02:	ef3fc0ef          	jal	80000bf4 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80003d06:	02c92603          	lw	a2,44(s2)
    80003d0a:	47f5                	li	a5,29
    80003d0c:	06c7c363          	blt	a5,a2,80003d72 <log_write+0x88>
    80003d10:	0001e797          	auipc	a5,0x1e
    80003d14:	73c7a783          	lw	a5,1852(a5) # 8002244c <log+0x1c>
    80003d18:	37fd                	addiw	a5,a5,-1
    80003d1a:	04f65c63          	bge	a2,a5,80003d72 <log_write+0x88>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80003d1e:	0001e797          	auipc	a5,0x1e
    80003d22:	7327a783          	lw	a5,1842(a5) # 80022450 <log+0x20>
    80003d26:	04f05c63          	blez	a5,80003d7e <log_write+0x94>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80003d2a:	4781                	li	a5,0
    80003d2c:	04c05f63          	blez	a2,80003d8a <log_write+0xa0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003d30:	44cc                	lw	a1,12(s1)
    80003d32:	0001e717          	auipc	a4,0x1e
    80003d36:	72e70713          	addi	a4,a4,1838 # 80022460 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80003d3a:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003d3c:	4314                	lw	a3,0(a4)
    80003d3e:	04b68663          	beq	a3,a1,80003d8a <log_write+0xa0>
  for (i = 0; i < log.lh.n; i++) {
    80003d42:	2785                	addiw	a5,a5,1
    80003d44:	0711                	addi	a4,a4,4
    80003d46:	fef61be3          	bne	a2,a5,80003d3c <log_write+0x52>
      break;
  }
  log.lh.block[i] = b->blockno;
    80003d4a:	0621                	addi	a2,a2,8
    80003d4c:	060a                	slli	a2,a2,0x2
    80003d4e:	0001e797          	auipc	a5,0x1e
    80003d52:	6e278793          	addi	a5,a5,1762 # 80022430 <log>
    80003d56:	97b2                	add	a5,a5,a2
    80003d58:	44d8                	lw	a4,12(s1)
    80003d5a:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80003d5c:	8526                	mv	a0,s1
    80003d5e:	fcbfe0ef          	jal	80002d28 <bpin>
    log.lh.n++;
    80003d62:	0001e717          	auipc	a4,0x1e
    80003d66:	6ce70713          	addi	a4,a4,1742 # 80022430 <log>
    80003d6a:	575c                	lw	a5,44(a4)
    80003d6c:	2785                	addiw	a5,a5,1
    80003d6e:	d75c                	sw	a5,44(a4)
    80003d70:	a80d                	j	80003da2 <log_write+0xb8>
    panic("too big a transaction");
    80003d72:	00004517          	auipc	a0,0x4
    80003d76:	88650513          	addi	a0,a0,-1914 # 800075f8 <etext+0x5f8>
    80003d7a:	a1bfc0ef          	jal	80000794 <panic>
    panic("log_write outside of trans");
    80003d7e:	00004517          	auipc	a0,0x4
    80003d82:	89250513          	addi	a0,a0,-1902 # 80007610 <etext+0x610>
    80003d86:	a0ffc0ef          	jal	80000794 <panic>
  log.lh.block[i] = b->blockno;
    80003d8a:	00878693          	addi	a3,a5,8
    80003d8e:	068a                	slli	a3,a3,0x2
    80003d90:	0001e717          	auipc	a4,0x1e
    80003d94:	6a070713          	addi	a4,a4,1696 # 80022430 <log>
    80003d98:	9736                	add	a4,a4,a3
    80003d9a:	44d4                	lw	a3,12(s1)
    80003d9c:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80003d9e:	faf60fe3          	beq	a2,a5,80003d5c <log_write+0x72>
  }
  release(&log.lock);
    80003da2:	0001e517          	auipc	a0,0x1e
    80003da6:	68e50513          	addi	a0,a0,1678 # 80022430 <log>
    80003daa:	ee3fc0ef          	jal	80000c8c <release>
}
    80003dae:	60e2                	ld	ra,24(sp)
    80003db0:	6442                	ld	s0,16(sp)
    80003db2:	64a2                	ld	s1,8(sp)
    80003db4:	6902                	ld	s2,0(sp)
    80003db6:	6105                	addi	sp,sp,32
    80003db8:	8082                	ret

0000000080003dba <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80003dba:	1101                	addi	sp,sp,-32
    80003dbc:	ec06                	sd	ra,24(sp)
    80003dbe:	e822                	sd	s0,16(sp)
    80003dc0:	e426                	sd	s1,8(sp)
    80003dc2:	e04a                	sd	s2,0(sp)
    80003dc4:	1000                	addi	s0,sp,32
    80003dc6:	84aa                	mv	s1,a0
    80003dc8:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80003dca:	00004597          	auipc	a1,0x4
    80003dce:	86658593          	addi	a1,a1,-1946 # 80007630 <etext+0x630>
    80003dd2:	0521                	addi	a0,a0,8
    80003dd4:	da1fc0ef          	jal	80000b74 <initlock>
  lk->name = name;
    80003dd8:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80003ddc:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003de0:	0204a423          	sw	zero,40(s1)
}
    80003de4:	60e2                	ld	ra,24(sp)
    80003de6:	6442                	ld	s0,16(sp)
    80003de8:	64a2                	ld	s1,8(sp)
    80003dea:	6902                	ld	s2,0(sp)
    80003dec:	6105                	addi	sp,sp,32
    80003dee:	8082                	ret

0000000080003df0 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80003df0:	1101                	addi	sp,sp,-32
    80003df2:	ec06                	sd	ra,24(sp)
    80003df4:	e822                	sd	s0,16(sp)
    80003df6:	e426                	sd	s1,8(sp)
    80003df8:	e04a                	sd	s2,0(sp)
    80003dfa:	1000                	addi	s0,sp,32
    80003dfc:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003dfe:	00850913          	addi	s2,a0,8
    80003e02:	854a                	mv	a0,s2
    80003e04:	df1fc0ef          	jal	80000bf4 <acquire>
  while (lk->locked) {
    80003e08:	409c                	lw	a5,0(s1)
    80003e0a:	c799                	beqz	a5,80003e18 <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    80003e0c:	85ca                	mv	a1,s2
    80003e0e:	8526                	mv	a0,s1
    80003e10:	89efe0ef          	jal	80001eae <sleep>
  while (lk->locked) {
    80003e14:	409c                	lw	a5,0(s1)
    80003e16:	fbfd                	bnez	a5,80003e0c <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80003e18:	4785                	li	a5,1
    80003e1a:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80003e1c:	ac5fd0ef          	jal	800018e0 <myproc>
    80003e20:	591c                	lw	a5,48(a0)
    80003e22:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80003e24:	854a                	mv	a0,s2
    80003e26:	e67fc0ef          	jal	80000c8c <release>
}
    80003e2a:	60e2                	ld	ra,24(sp)
    80003e2c:	6442                	ld	s0,16(sp)
    80003e2e:	64a2                	ld	s1,8(sp)
    80003e30:	6902                	ld	s2,0(sp)
    80003e32:	6105                	addi	sp,sp,32
    80003e34:	8082                	ret

0000000080003e36 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80003e36:	1101                	addi	sp,sp,-32
    80003e38:	ec06                	sd	ra,24(sp)
    80003e3a:	e822                	sd	s0,16(sp)
    80003e3c:	e426                	sd	s1,8(sp)
    80003e3e:	e04a                	sd	s2,0(sp)
    80003e40:	1000                	addi	s0,sp,32
    80003e42:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003e44:	00850913          	addi	s2,a0,8
    80003e48:	854a                	mv	a0,s2
    80003e4a:	dabfc0ef          	jal	80000bf4 <acquire>
  lk->locked = 0;
    80003e4e:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003e52:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80003e56:	8526                	mv	a0,s1
    80003e58:	8a2fe0ef          	jal	80001efa <wakeup>
  release(&lk->lk);
    80003e5c:	854a                	mv	a0,s2
    80003e5e:	e2ffc0ef          	jal	80000c8c <release>
}
    80003e62:	60e2                	ld	ra,24(sp)
    80003e64:	6442                	ld	s0,16(sp)
    80003e66:	64a2                	ld	s1,8(sp)
    80003e68:	6902                	ld	s2,0(sp)
    80003e6a:	6105                	addi	sp,sp,32
    80003e6c:	8082                	ret

0000000080003e6e <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80003e6e:	7179                	addi	sp,sp,-48
    80003e70:	f406                	sd	ra,40(sp)
    80003e72:	f022                	sd	s0,32(sp)
    80003e74:	ec26                	sd	s1,24(sp)
    80003e76:	e84a                	sd	s2,16(sp)
    80003e78:	1800                	addi	s0,sp,48
    80003e7a:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80003e7c:	00850913          	addi	s2,a0,8
    80003e80:	854a                	mv	a0,s2
    80003e82:	d73fc0ef          	jal	80000bf4 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80003e86:	409c                	lw	a5,0(s1)
    80003e88:	ef81                	bnez	a5,80003ea0 <holdingsleep+0x32>
    80003e8a:	4481                	li	s1,0
  release(&lk->lk);
    80003e8c:	854a                	mv	a0,s2
    80003e8e:	dfffc0ef          	jal	80000c8c <release>
  return r;
}
    80003e92:	8526                	mv	a0,s1
    80003e94:	70a2                	ld	ra,40(sp)
    80003e96:	7402                	ld	s0,32(sp)
    80003e98:	64e2                	ld	s1,24(sp)
    80003e9a:	6942                	ld	s2,16(sp)
    80003e9c:	6145                	addi	sp,sp,48
    80003e9e:	8082                	ret
    80003ea0:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    80003ea2:	0284a983          	lw	s3,40(s1)
    80003ea6:	a3bfd0ef          	jal	800018e0 <myproc>
    80003eaa:	5904                	lw	s1,48(a0)
    80003eac:	413484b3          	sub	s1,s1,s3
    80003eb0:	0014b493          	seqz	s1,s1
    80003eb4:	69a2                	ld	s3,8(sp)
    80003eb6:	bfd9                	j	80003e8c <holdingsleep+0x1e>

0000000080003eb8 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80003eb8:	1141                	addi	sp,sp,-16
    80003eba:	e406                	sd	ra,8(sp)
    80003ebc:	e022                	sd	s0,0(sp)
    80003ebe:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80003ec0:	00003597          	auipc	a1,0x3
    80003ec4:	78058593          	addi	a1,a1,1920 # 80007640 <etext+0x640>
    80003ec8:	0001e517          	auipc	a0,0x1e
    80003ecc:	6b050513          	addi	a0,a0,1712 # 80022578 <ftable>
    80003ed0:	ca5fc0ef          	jal	80000b74 <initlock>
}
    80003ed4:	60a2                	ld	ra,8(sp)
    80003ed6:	6402                	ld	s0,0(sp)
    80003ed8:	0141                	addi	sp,sp,16
    80003eda:	8082                	ret

0000000080003edc <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80003edc:	1101                	addi	sp,sp,-32
    80003ede:	ec06                	sd	ra,24(sp)
    80003ee0:	e822                	sd	s0,16(sp)
    80003ee2:	e426                	sd	s1,8(sp)
    80003ee4:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80003ee6:	0001e517          	auipc	a0,0x1e
    80003eea:	69250513          	addi	a0,a0,1682 # 80022578 <ftable>
    80003eee:	d07fc0ef          	jal	80000bf4 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80003ef2:	0001e497          	auipc	s1,0x1e
    80003ef6:	69e48493          	addi	s1,s1,1694 # 80022590 <ftable+0x18>
    80003efa:	0001f717          	auipc	a4,0x1f
    80003efe:	63670713          	addi	a4,a4,1590 # 80023530 <disk>
    if(f->ref == 0){
    80003f02:	40dc                	lw	a5,4(s1)
    80003f04:	cf89                	beqz	a5,80003f1e <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80003f06:	02848493          	addi	s1,s1,40
    80003f0a:	fee49ce3          	bne	s1,a4,80003f02 <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80003f0e:	0001e517          	auipc	a0,0x1e
    80003f12:	66a50513          	addi	a0,a0,1642 # 80022578 <ftable>
    80003f16:	d77fc0ef          	jal	80000c8c <release>
  return 0;
    80003f1a:	4481                	li	s1,0
    80003f1c:	a809                	j	80003f2e <filealloc+0x52>
      f->ref = 1;
    80003f1e:	4785                	li	a5,1
    80003f20:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80003f22:	0001e517          	auipc	a0,0x1e
    80003f26:	65650513          	addi	a0,a0,1622 # 80022578 <ftable>
    80003f2a:	d63fc0ef          	jal	80000c8c <release>
}
    80003f2e:	8526                	mv	a0,s1
    80003f30:	60e2                	ld	ra,24(sp)
    80003f32:	6442                	ld	s0,16(sp)
    80003f34:	64a2                	ld	s1,8(sp)
    80003f36:	6105                	addi	sp,sp,32
    80003f38:	8082                	ret

0000000080003f3a <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80003f3a:	1101                	addi	sp,sp,-32
    80003f3c:	ec06                	sd	ra,24(sp)
    80003f3e:	e822                	sd	s0,16(sp)
    80003f40:	e426                	sd	s1,8(sp)
    80003f42:	1000                	addi	s0,sp,32
    80003f44:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80003f46:	0001e517          	auipc	a0,0x1e
    80003f4a:	63250513          	addi	a0,a0,1586 # 80022578 <ftable>
    80003f4e:	ca7fc0ef          	jal	80000bf4 <acquire>
  if(f->ref < 1)
    80003f52:	40dc                	lw	a5,4(s1)
    80003f54:	02f05063          	blez	a5,80003f74 <filedup+0x3a>
    panic("filedup");
  f->ref++;
    80003f58:	2785                	addiw	a5,a5,1
    80003f5a:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80003f5c:	0001e517          	auipc	a0,0x1e
    80003f60:	61c50513          	addi	a0,a0,1564 # 80022578 <ftable>
    80003f64:	d29fc0ef          	jal	80000c8c <release>
  return f;
}
    80003f68:	8526                	mv	a0,s1
    80003f6a:	60e2                	ld	ra,24(sp)
    80003f6c:	6442                	ld	s0,16(sp)
    80003f6e:	64a2                	ld	s1,8(sp)
    80003f70:	6105                	addi	sp,sp,32
    80003f72:	8082                	ret
    panic("filedup");
    80003f74:	00003517          	auipc	a0,0x3
    80003f78:	6d450513          	addi	a0,a0,1748 # 80007648 <etext+0x648>
    80003f7c:	819fc0ef          	jal	80000794 <panic>

0000000080003f80 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80003f80:	7139                	addi	sp,sp,-64
    80003f82:	fc06                	sd	ra,56(sp)
    80003f84:	f822                	sd	s0,48(sp)
    80003f86:	f426                	sd	s1,40(sp)
    80003f88:	0080                	addi	s0,sp,64
    80003f8a:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80003f8c:	0001e517          	auipc	a0,0x1e
    80003f90:	5ec50513          	addi	a0,a0,1516 # 80022578 <ftable>
    80003f94:	c61fc0ef          	jal	80000bf4 <acquire>
  if(f->ref < 1)
    80003f98:	40dc                	lw	a5,4(s1)
    80003f9a:	04f05a63          	blez	a5,80003fee <fileclose+0x6e>
    panic("fileclose");
  if(--f->ref > 0){
    80003f9e:	37fd                	addiw	a5,a5,-1
    80003fa0:	0007871b          	sext.w	a4,a5
    80003fa4:	c0dc                	sw	a5,4(s1)
    80003fa6:	04e04e63          	bgtz	a4,80004002 <fileclose+0x82>
    80003faa:	f04a                	sd	s2,32(sp)
    80003fac:	ec4e                	sd	s3,24(sp)
    80003fae:	e852                	sd	s4,16(sp)
    80003fb0:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80003fb2:	0004a903          	lw	s2,0(s1)
    80003fb6:	0094ca83          	lbu	s5,9(s1)
    80003fba:	0104ba03          	ld	s4,16(s1)
    80003fbe:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80003fc2:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80003fc6:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80003fca:	0001e517          	auipc	a0,0x1e
    80003fce:	5ae50513          	addi	a0,a0,1454 # 80022578 <ftable>
    80003fd2:	cbbfc0ef          	jal	80000c8c <release>

  if(ff.type == FD_PIPE){
    80003fd6:	4785                	li	a5,1
    80003fd8:	04f90063          	beq	s2,a5,80004018 <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80003fdc:	3979                	addiw	s2,s2,-2
    80003fde:	4785                	li	a5,1
    80003fe0:	0527f563          	bgeu	a5,s2,8000402a <fileclose+0xaa>
    80003fe4:	7902                	ld	s2,32(sp)
    80003fe6:	69e2                	ld	s3,24(sp)
    80003fe8:	6a42                	ld	s4,16(sp)
    80003fea:	6aa2                	ld	s5,8(sp)
    80003fec:	a00d                	j	8000400e <fileclose+0x8e>
    80003fee:	f04a                	sd	s2,32(sp)
    80003ff0:	ec4e                	sd	s3,24(sp)
    80003ff2:	e852                	sd	s4,16(sp)
    80003ff4:	e456                	sd	s5,8(sp)
    panic("fileclose");
    80003ff6:	00003517          	auipc	a0,0x3
    80003ffa:	65a50513          	addi	a0,a0,1626 # 80007650 <etext+0x650>
    80003ffe:	f96fc0ef          	jal	80000794 <panic>
    release(&ftable.lock);
    80004002:	0001e517          	auipc	a0,0x1e
    80004006:	57650513          	addi	a0,a0,1398 # 80022578 <ftable>
    8000400a:	c83fc0ef          	jal	80000c8c <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    8000400e:	70e2                	ld	ra,56(sp)
    80004010:	7442                	ld	s0,48(sp)
    80004012:	74a2                	ld	s1,40(sp)
    80004014:	6121                	addi	sp,sp,64
    80004016:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004018:	85d6                	mv	a1,s5
    8000401a:	8552                	mv	a0,s4
    8000401c:	336000ef          	jal	80004352 <pipeclose>
    80004020:	7902                	ld	s2,32(sp)
    80004022:	69e2                	ld	s3,24(sp)
    80004024:	6a42                	ld	s4,16(sp)
    80004026:	6aa2                	ld	s5,8(sp)
    80004028:	b7dd                	j	8000400e <fileclose+0x8e>
    begin_op();
    8000402a:	b3dff0ef          	jal	80003b66 <begin_op>
    iput(ff.ip);
    8000402e:	854e                	mv	a0,s3
    80004030:	c22ff0ef          	jal	80003452 <iput>
    end_op();
    80004034:	b9dff0ef          	jal	80003bd0 <end_op>
    80004038:	7902                	ld	s2,32(sp)
    8000403a:	69e2                	ld	s3,24(sp)
    8000403c:	6a42                	ld	s4,16(sp)
    8000403e:	6aa2                	ld	s5,8(sp)
    80004040:	b7f9                	j	8000400e <fileclose+0x8e>

0000000080004042 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004042:	715d                	addi	sp,sp,-80
    80004044:	e486                	sd	ra,72(sp)
    80004046:	e0a2                	sd	s0,64(sp)
    80004048:	fc26                	sd	s1,56(sp)
    8000404a:	f44e                	sd	s3,40(sp)
    8000404c:	0880                	addi	s0,sp,80
    8000404e:	84aa                	mv	s1,a0
    80004050:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004052:	88ffd0ef          	jal	800018e0 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004056:	409c                	lw	a5,0(s1)
    80004058:	37f9                	addiw	a5,a5,-2
    8000405a:	4705                	li	a4,1
    8000405c:	04f76063          	bltu	a4,a5,8000409c <filestat+0x5a>
    80004060:	f84a                	sd	s2,48(sp)
    80004062:	892a                	mv	s2,a0
    ilock(f->ip);
    80004064:	6c88                	ld	a0,24(s1)
    80004066:	a6aff0ef          	jal	800032d0 <ilock>
    stati(f->ip, &st);
    8000406a:	fb840593          	addi	a1,s0,-72
    8000406e:	6c88                	ld	a0,24(s1)
    80004070:	c8aff0ef          	jal	800034fa <stati>
    iunlock(f->ip);
    80004074:	6c88                	ld	a0,24(s1)
    80004076:	b08ff0ef          	jal	8000337e <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    8000407a:	46e1                	li	a3,24
    8000407c:	fb840613          	addi	a2,s0,-72
    80004080:	85ce                	mv	a1,s3
    80004082:	05093503          	ld	a0,80(s2)
    80004086:	cccfd0ef          	jal	80001552 <copyout>
    8000408a:	41f5551b          	sraiw	a0,a0,0x1f
    8000408e:	7942                	ld	s2,48(sp)
      return -1;
    return 0;
  }
  return -1;
}
    80004090:	60a6                	ld	ra,72(sp)
    80004092:	6406                	ld	s0,64(sp)
    80004094:	74e2                	ld	s1,56(sp)
    80004096:	79a2                	ld	s3,40(sp)
    80004098:	6161                	addi	sp,sp,80
    8000409a:	8082                	ret
  return -1;
    8000409c:	557d                	li	a0,-1
    8000409e:	bfcd                	j	80004090 <filestat+0x4e>

00000000800040a0 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800040a0:	7179                	addi	sp,sp,-48
    800040a2:	f406                	sd	ra,40(sp)
    800040a4:	f022                	sd	s0,32(sp)
    800040a6:	e84a                	sd	s2,16(sp)
    800040a8:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800040aa:	00854783          	lbu	a5,8(a0)
    800040ae:	cfd1                	beqz	a5,8000414a <fileread+0xaa>
    800040b0:	ec26                	sd	s1,24(sp)
    800040b2:	e44e                	sd	s3,8(sp)
    800040b4:	84aa                	mv	s1,a0
    800040b6:	89ae                	mv	s3,a1
    800040b8:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    800040ba:	411c                	lw	a5,0(a0)
    800040bc:	4705                	li	a4,1
    800040be:	04e78363          	beq	a5,a4,80004104 <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800040c2:	470d                	li	a4,3
    800040c4:	04e78763          	beq	a5,a4,80004112 <fileread+0x72>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    800040c8:	4709                	li	a4,2
    800040ca:	06e79a63          	bne	a5,a4,8000413e <fileread+0x9e>
    ilock(f->ip);
    800040ce:	6d08                	ld	a0,24(a0)
    800040d0:	a00ff0ef          	jal	800032d0 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800040d4:	874a                	mv	a4,s2
    800040d6:	5094                	lw	a3,32(s1)
    800040d8:	864e                	mv	a2,s3
    800040da:	4585                	li	a1,1
    800040dc:	6c88                	ld	a0,24(s1)
    800040de:	c46ff0ef          	jal	80003524 <readi>
    800040e2:	892a                	mv	s2,a0
    800040e4:	00a05563          	blez	a0,800040ee <fileread+0x4e>
      f->off += r;
    800040e8:	509c                	lw	a5,32(s1)
    800040ea:	9fa9                	addw	a5,a5,a0
    800040ec:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800040ee:	6c88                	ld	a0,24(s1)
    800040f0:	a8eff0ef          	jal	8000337e <iunlock>
    800040f4:	64e2                	ld	s1,24(sp)
    800040f6:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    800040f8:	854a                	mv	a0,s2
    800040fa:	70a2                	ld	ra,40(sp)
    800040fc:	7402                	ld	s0,32(sp)
    800040fe:	6942                	ld	s2,16(sp)
    80004100:	6145                	addi	sp,sp,48
    80004102:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004104:	6908                	ld	a0,16(a0)
    80004106:	388000ef          	jal	8000448e <piperead>
    8000410a:	892a                	mv	s2,a0
    8000410c:	64e2                	ld	s1,24(sp)
    8000410e:	69a2                	ld	s3,8(sp)
    80004110:	b7e5                	j	800040f8 <fileread+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004112:	02451783          	lh	a5,36(a0)
    80004116:	03079693          	slli	a3,a5,0x30
    8000411a:	92c1                	srli	a3,a3,0x30
    8000411c:	4725                	li	a4,9
    8000411e:	02d76863          	bltu	a4,a3,8000414e <fileread+0xae>
    80004122:	0792                	slli	a5,a5,0x4
    80004124:	0001e717          	auipc	a4,0x1e
    80004128:	3b470713          	addi	a4,a4,948 # 800224d8 <devsw>
    8000412c:	97ba                	add	a5,a5,a4
    8000412e:	639c                	ld	a5,0(a5)
    80004130:	c39d                	beqz	a5,80004156 <fileread+0xb6>
    r = devsw[f->major].read(1, addr, n);
    80004132:	4505                	li	a0,1
    80004134:	9782                	jalr	a5
    80004136:	892a                	mv	s2,a0
    80004138:	64e2                	ld	s1,24(sp)
    8000413a:	69a2                	ld	s3,8(sp)
    8000413c:	bf75                	j	800040f8 <fileread+0x58>
    panic("fileread");
    8000413e:	00003517          	auipc	a0,0x3
    80004142:	52250513          	addi	a0,a0,1314 # 80007660 <etext+0x660>
    80004146:	e4efc0ef          	jal	80000794 <panic>
    return -1;
    8000414a:	597d                	li	s2,-1
    8000414c:	b775                	j	800040f8 <fileread+0x58>
      return -1;
    8000414e:	597d                	li	s2,-1
    80004150:	64e2                	ld	s1,24(sp)
    80004152:	69a2                	ld	s3,8(sp)
    80004154:	b755                	j	800040f8 <fileread+0x58>
    80004156:	597d                	li	s2,-1
    80004158:	64e2                	ld	s1,24(sp)
    8000415a:	69a2                	ld	s3,8(sp)
    8000415c:	bf71                	j	800040f8 <fileread+0x58>

000000008000415e <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    8000415e:	00954783          	lbu	a5,9(a0)
    80004162:	10078b63          	beqz	a5,80004278 <filewrite+0x11a>
{
    80004166:	715d                	addi	sp,sp,-80
    80004168:	e486                	sd	ra,72(sp)
    8000416a:	e0a2                	sd	s0,64(sp)
    8000416c:	f84a                	sd	s2,48(sp)
    8000416e:	f052                	sd	s4,32(sp)
    80004170:	e85a                	sd	s6,16(sp)
    80004172:	0880                	addi	s0,sp,80
    80004174:	892a                	mv	s2,a0
    80004176:	8b2e                	mv	s6,a1
    80004178:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    8000417a:	411c                	lw	a5,0(a0)
    8000417c:	4705                	li	a4,1
    8000417e:	02e78763          	beq	a5,a4,800041ac <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004182:	470d                	li	a4,3
    80004184:	02e78863          	beq	a5,a4,800041b4 <filewrite+0x56>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004188:	4709                	li	a4,2
    8000418a:	0ce79c63          	bne	a5,a4,80004262 <filewrite+0x104>
    8000418e:	f44e                	sd	s3,40(sp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004190:	0ac05863          	blez	a2,80004240 <filewrite+0xe2>
    80004194:	fc26                	sd	s1,56(sp)
    80004196:	ec56                	sd	s5,24(sp)
    80004198:	e45e                	sd	s7,8(sp)
    8000419a:	e062                	sd	s8,0(sp)
    int i = 0;
    8000419c:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    8000419e:	6b85                	lui	s7,0x1
    800041a0:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    800041a4:	6c05                	lui	s8,0x1
    800041a6:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    800041aa:	a8b5                	j	80004226 <filewrite+0xc8>
    ret = pipewrite(f->pipe, addr, n);
    800041ac:	6908                	ld	a0,16(a0)
    800041ae:	1fc000ef          	jal	800043aa <pipewrite>
    800041b2:	a04d                	j	80004254 <filewrite+0xf6>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800041b4:	02451783          	lh	a5,36(a0)
    800041b8:	03079693          	slli	a3,a5,0x30
    800041bc:	92c1                	srli	a3,a3,0x30
    800041be:	4725                	li	a4,9
    800041c0:	0ad76e63          	bltu	a4,a3,8000427c <filewrite+0x11e>
    800041c4:	0792                	slli	a5,a5,0x4
    800041c6:	0001e717          	auipc	a4,0x1e
    800041ca:	31270713          	addi	a4,a4,786 # 800224d8 <devsw>
    800041ce:	97ba                	add	a5,a5,a4
    800041d0:	679c                	ld	a5,8(a5)
    800041d2:	c7dd                	beqz	a5,80004280 <filewrite+0x122>
    ret = devsw[f->major].write(1, addr, n);
    800041d4:	4505                	li	a0,1
    800041d6:	9782                	jalr	a5
    800041d8:	a8b5                	j	80004254 <filewrite+0xf6>
      if(n1 > max)
    800041da:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    800041de:	989ff0ef          	jal	80003b66 <begin_op>
      ilock(f->ip);
    800041e2:	01893503          	ld	a0,24(s2)
    800041e6:	8eaff0ef          	jal	800032d0 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800041ea:	8756                	mv	a4,s5
    800041ec:	02092683          	lw	a3,32(s2)
    800041f0:	01698633          	add	a2,s3,s6
    800041f4:	4585                	li	a1,1
    800041f6:	01893503          	ld	a0,24(s2)
    800041fa:	c26ff0ef          	jal	80003620 <writei>
    800041fe:	84aa                	mv	s1,a0
    80004200:	00a05763          	blez	a0,8000420e <filewrite+0xb0>
        f->off += r;
    80004204:	02092783          	lw	a5,32(s2)
    80004208:	9fa9                	addw	a5,a5,a0
    8000420a:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    8000420e:	01893503          	ld	a0,24(s2)
    80004212:	96cff0ef          	jal	8000337e <iunlock>
      end_op();
    80004216:	9bbff0ef          	jal	80003bd0 <end_op>

      if(r != n1){
    8000421a:	029a9563          	bne	s5,s1,80004244 <filewrite+0xe6>
        // error from writei
        break;
      }
      i += r;
    8000421e:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004222:	0149da63          	bge	s3,s4,80004236 <filewrite+0xd8>
      int n1 = n - i;
    80004226:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    8000422a:	0004879b          	sext.w	a5,s1
    8000422e:	fafbd6e3          	bge	s7,a5,800041da <filewrite+0x7c>
    80004232:	84e2                	mv	s1,s8
    80004234:	b75d                	j	800041da <filewrite+0x7c>
    80004236:	74e2                	ld	s1,56(sp)
    80004238:	6ae2                	ld	s5,24(sp)
    8000423a:	6ba2                	ld	s7,8(sp)
    8000423c:	6c02                	ld	s8,0(sp)
    8000423e:	a039                	j	8000424c <filewrite+0xee>
    int i = 0;
    80004240:	4981                	li	s3,0
    80004242:	a029                	j	8000424c <filewrite+0xee>
    80004244:	74e2                	ld	s1,56(sp)
    80004246:	6ae2                	ld	s5,24(sp)
    80004248:	6ba2                	ld	s7,8(sp)
    8000424a:	6c02                	ld	s8,0(sp)
    }
    ret = (i == n ? n : -1);
    8000424c:	033a1c63          	bne	s4,s3,80004284 <filewrite+0x126>
    80004250:	8552                	mv	a0,s4
    80004252:	79a2                	ld	s3,40(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004254:	60a6                	ld	ra,72(sp)
    80004256:	6406                	ld	s0,64(sp)
    80004258:	7942                	ld	s2,48(sp)
    8000425a:	7a02                	ld	s4,32(sp)
    8000425c:	6b42                	ld	s6,16(sp)
    8000425e:	6161                	addi	sp,sp,80
    80004260:	8082                	ret
    80004262:	fc26                	sd	s1,56(sp)
    80004264:	f44e                	sd	s3,40(sp)
    80004266:	ec56                	sd	s5,24(sp)
    80004268:	e45e                	sd	s7,8(sp)
    8000426a:	e062                	sd	s8,0(sp)
    panic("filewrite");
    8000426c:	00003517          	auipc	a0,0x3
    80004270:	40450513          	addi	a0,a0,1028 # 80007670 <etext+0x670>
    80004274:	d20fc0ef          	jal	80000794 <panic>
    return -1;
    80004278:	557d                	li	a0,-1
}
    8000427a:	8082                	ret
      return -1;
    8000427c:	557d                	li	a0,-1
    8000427e:	bfd9                	j	80004254 <filewrite+0xf6>
    80004280:	557d                	li	a0,-1
    80004282:	bfc9                	j	80004254 <filewrite+0xf6>
    ret = (i == n ? n : -1);
    80004284:	557d                	li	a0,-1
    80004286:	79a2                	ld	s3,40(sp)
    80004288:	b7f1                	j	80004254 <filewrite+0xf6>

000000008000428a <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    8000428a:	7179                	addi	sp,sp,-48
    8000428c:	f406                	sd	ra,40(sp)
    8000428e:	f022                	sd	s0,32(sp)
    80004290:	ec26                	sd	s1,24(sp)
    80004292:	e052                	sd	s4,0(sp)
    80004294:	1800                	addi	s0,sp,48
    80004296:	84aa                	mv	s1,a0
    80004298:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    8000429a:	0005b023          	sd	zero,0(a1)
    8000429e:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800042a2:	c3bff0ef          	jal	80003edc <filealloc>
    800042a6:	e088                	sd	a0,0(s1)
    800042a8:	c549                	beqz	a0,80004332 <pipealloc+0xa8>
    800042aa:	c33ff0ef          	jal	80003edc <filealloc>
    800042ae:	00aa3023          	sd	a0,0(s4)
    800042b2:	cd25                	beqz	a0,8000432a <pipealloc+0xa0>
    800042b4:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    800042b6:	86ffc0ef          	jal	80000b24 <kalloc>
    800042ba:	892a                	mv	s2,a0
    800042bc:	c12d                	beqz	a0,8000431e <pipealloc+0x94>
    800042be:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    800042c0:	4985                	li	s3,1
    800042c2:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800042c6:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    800042ca:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    800042ce:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    800042d2:	00003597          	auipc	a1,0x3
    800042d6:	3ae58593          	addi	a1,a1,942 # 80007680 <etext+0x680>
    800042da:	89bfc0ef          	jal	80000b74 <initlock>
  (*f0)->type = FD_PIPE;
    800042de:	609c                	ld	a5,0(s1)
    800042e0:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800042e4:	609c                	ld	a5,0(s1)
    800042e6:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800042ea:	609c                	ld	a5,0(s1)
    800042ec:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800042f0:	609c                	ld	a5,0(s1)
    800042f2:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    800042f6:	000a3783          	ld	a5,0(s4)
    800042fa:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    800042fe:	000a3783          	ld	a5,0(s4)
    80004302:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004306:	000a3783          	ld	a5,0(s4)
    8000430a:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    8000430e:	000a3783          	ld	a5,0(s4)
    80004312:	0127b823          	sd	s2,16(a5)
  return 0;
    80004316:	4501                	li	a0,0
    80004318:	6942                	ld	s2,16(sp)
    8000431a:	69a2                	ld	s3,8(sp)
    8000431c:	a01d                	j	80004342 <pipealloc+0xb8>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    8000431e:	6088                	ld	a0,0(s1)
    80004320:	c119                	beqz	a0,80004326 <pipealloc+0x9c>
    80004322:	6942                	ld	s2,16(sp)
    80004324:	a029                	j	8000432e <pipealloc+0xa4>
    80004326:	6942                	ld	s2,16(sp)
    80004328:	a029                	j	80004332 <pipealloc+0xa8>
    8000432a:	6088                	ld	a0,0(s1)
    8000432c:	c10d                	beqz	a0,8000434e <pipealloc+0xc4>
    fileclose(*f0);
    8000432e:	c53ff0ef          	jal	80003f80 <fileclose>
  if(*f1)
    80004332:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004336:	557d                	li	a0,-1
  if(*f1)
    80004338:	c789                	beqz	a5,80004342 <pipealloc+0xb8>
    fileclose(*f1);
    8000433a:	853e                	mv	a0,a5
    8000433c:	c45ff0ef          	jal	80003f80 <fileclose>
  return -1;
    80004340:	557d                	li	a0,-1
}
    80004342:	70a2                	ld	ra,40(sp)
    80004344:	7402                	ld	s0,32(sp)
    80004346:	64e2                	ld	s1,24(sp)
    80004348:	6a02                	ld	s4,0(sp)
    8000434a:	6145                	addi	sp,sp,48
    8000434c:	8082                	ret
  return -1;
    8000434e:	557d                	li	a0,-1
    80004350:	bfcd                	j	80004342 <pipealloc+0xb8>

0000000080004352 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004352:	1101                	addi	sp,sp,-32
    80004354:	ec06                	sd	ra,24(sp)
    80004356:	e822                	sd	s0,16(sp)
    80004358:	e426                	sd	s1,8(sp)
    8000435a:	e04a                	sd	s2,0(sp)
    8000435c:	1000                	addi	s0,sp,32
    8000435e:	84aa                	mv	s1,a0
    80004360:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004362:	893fc0ef          	jal	80000bf4 <acquire>
  if(writable){
    80004366:	02090763          	beqz	s2,80004394 <pipeclose+0x42>
    pi->writeopen = 0;
    8000436a:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    8000436e:	21848513          	addi	a0,s1,536
    80004372:	b89fd0ef          	jal	80001efa <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004376:	2204b783          	ld	a5,544(s1)
    8000437a:	e785                	bnez	a5,800043a2 <pipeclose+0x50>
    release(&pi->lock);
    8000437c:	8526                	mv	a0,s1
    8000437e:	90ffc0ef          	jal	80000c8c <release>
    kfree((char*)pi);
    80004382:	8526                	mv	a0,s1
    80004384:	ebefc0ef          	jal	80000a42 <kfree>
  } else
    release(&pi->lock);
}
    80004388:	60e2                	ld	ra,24(sp)
    8000438a:	6442                	ld	s0,16(sp)
    8000438c:	64a2                	ld	s1,8(sp)
    8000438e:	6902                	ld	s2,0(sp)
    80004390:	6105                	addi	sp,sp,32
    80004392:	8082                	ret
    pi->readopen = 0;
    80004394:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004398:	21c48513          	addi	a0,s1,540
    8000439c:	b5ffd0ef          	jal	80001efa <wakeup>
    800043a0:	bfd9                	j	80004376 <pipeclose+0x24>
    release(&pi->lock);
    800043a2:	8526                	mv	a0,s1
    800043a4:	8e9fc0ef          	jal	80000c8c <release>
}
    800043a8:	b7c5                	j	80004388 <pipeclose+0x36>

00000000800043aa <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800043aa:	711d                	addi	sp,sp,-96
    800043ac:	ec86                	sd	ra,88(sp)
    800043ae:	e8a2                	sd	s0,80(sp)
    800043b0:	e4a6                	sd	s1,72(sp)
    800043b2:	e0ca                	sd	s2,64(sp)
    800043b4:	fc4e                	sd	s3,56(sp)
    800043b6:	f852                	sd	s4,48(sp)
    800043b8:	f456                	sd	s5,40(sp)
    800043ba:	1080                	addi	s0,sp,96
    800043bc:	84aa                	mv	s1,a0
    800043be:	8aae                	mv	s5,a1
    800043c0:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    800043c2:	d1efd0ef          	jal	800018e0 <myproc>
    800043c6:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    800043c8:	8526                	mv	a0,s1
    800043ca:	82bfc0ef          	jal	80000bf4 <acquire>
  while(i < n){
    800043ce:	0b405a63          	blez	s4,80004482 <pipewrite+0xd8>
    800043d2:	f05a                	sd	s6,32(sp)
    800043d4:	ec5e                	sd	s7,24(sp)
    800043d6:	e862                	sd	s8,16(sp)
  int i = 0;
    800043d8:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800043da:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    800043dc:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    800043e0:	21c48b93          	addi	s7,s1,540
    800043e4:	a81d                	j	8000441a <pipewrite+0x70>
      release(&pi->lock);
    800043e6:	8526                	mv	a0,s1
    800043e8:	8a5fc0ef          	jal	80000c8c <release>
      return -1;
    800043ec:	597d                	li	s2,-1
    800043ee:	7b02                	ld	s6,32(sp)
    800043f0:	6be2                	ld	s7,24(sp)
    800043f2:	6c42                	ld	s8,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    800043f4:	854a                	mv	a0,s2
    800043f6:	60e6                	ld	ra,88(sp)
    800043f8:	6446                	ld	s0,80(sp)
    800043fa:	64a6                	ld	s1,72(sp)
    800043fc:	6906                	ld	s2,64(sp)
    800043fe:	79e2                	ld	s3,56(sp)
    80004400:	7a42                	ld	s4,48(sp)
    80004402:	7aa2                	ld	s5,40(sp)
    80004404:	6125                	addi	sp,sp,96
    80004406:	8082                	ret
      wakeup(&pi->nread);
    80004408:	8562                	mv	a0,s8
    8000440a:	af1fd0ef          	jal	80001efa <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    8000440e:	85a6                	mv	a1,s1
    80004410:	855e                	mv	a0,s7
    80004412:	a9dfd0ef          	jal	80001eae <sleep>
  while(i < n){
    80004416:	05495b63          	bge	s2,s4,8000446c <pipewrite+0xc2>
    if(pi->readopen == 0 || killed(pr)){
    8000441a:	2204a783          	lw	a5,544(s1)
    8000441e:	d7e1                	beqz	a5,800043e6 <pipewrite+0x3c>
    80004420:	854e                	mv	a0,s3
    80004422:	cc5fd0ef          	jal	800020e6 <killed>
    80004426:	f161                	bnez	a0,800043e6 <pipewrite+0x3c>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004428:	2184a783          	lw	a5,536(s1)
    8000442c:	21c4a703          	lw	a4,540(s1)
    80004430:	2007879b          	addiw	a5,a5,512
    80004434:	fcf70ae3          	beq	a4,a5,80004408 <pipewrite+0x5e>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004438:	4685                	li	a3,1
    8000443a:	01590633          	add	a2,s2,s5
    8000443e:	faf40593          	addi	a1,s0,-81
    80004442:	0509b503          	ld	a0,80(s3)
    80004446:	9e2fd0ef          	jal	80001628 <copyin>
    8000444a:	03650e63          	beq	a0,s6,80004486 <pipewrite+0xdc>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    8000444e:	21c4a783          	lw	a5,540(s1)
    80004452:	0017871b          	addiw	a4,a5,1
    80004456:	20e4ae23          	sw	a4,540(s1)
    8000445a:	1ff7f793          	andi	a5,a5,511
    8000445e:	97a6                	add	a5,a5,s1
    80004460:	faf44703          	lbu	a4,-81(s0)
    80004464:	00e78c23          	sb	a4,24(a5)
      i++;
    80004468:	2905                	addiw	s2,s2,1
    8000446a:	b775                	j	80004416 <pipewrite+0x6c>
    8000446c:	7b02                	ld	s6,32(sp)
    8000446e:	6be2                	ld	s7,24(sp)
    80004470:	6c42                	ld	s8,16(sp)
  wakeup(&pi->nread);
    80004472:	21848513          	addi	a0,s1,536
    80004476:	a85fd0ef          	jal	80001efa <wakeup>
  release(&pi->lock);
    8000447a:	8526                	mv	a0,s1
    8000447c:	811fc0ef          	jal	80000c8c <release>
  return i;
    80004480:	bf95                	j	800043f4 <pipewrite+0x4a>
  int i = 0;
    80004482:	4901                	li	s2,0
    80004484:	b7fd                	j	80004472 <pipewrite+0xc8>
    80004486:	7b02                	ld	s6,32(sp)
    80004488:	6be2                	ld	s7,24(sp)
    8000448a:	6c42                	ld	s8,16(sp)
    8000448c:	b7dd                	j	80004472 <pipewrite+0xc8>

000000008000448e <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    8000448e:	715d                	addi	sp,sp,-80
    80004490:	e486                	sd	ra,72(sp)
    80004492:	e0a2                	sd	s0,64(sp)
    80004494:	fc26                	sd	s1,56(sp)
    80004496:	f84a                	sd	s2,48(sp)
    80004498:	f44e                	sd	s3,40(sp)
    8000449a:	f052                	sd	s4,32(sp)
    8000449c:	ec56                	sd	s5,24(sp)
    8000449e:	0880                	addi	s0,sp,80
    800044a0:	84aa                	mv	s1,a0
    800044a2:	892e                	mv	s2,a1
    800044a4:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    800044a6:	c3afd0ef          	jal	800018e0 <myproc>
    800044aa:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    800044ac:	8526                	mv	a0,s1
    800044ae:	f46fc0ef          	jal	80000bf4 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800044b2:	2184a703          	lw	a4,536(s1)
    800044b6:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800044ba:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800044be:	02f71563          	bne	a4,a5,800044e8 <piperead+0x5a>
    800044c2:	2244a783          	lw	a5,548(s1)
    800044c6:	cb85                	beqz	a5,800044f6 <piperead+0x68>
    if(killed(pr)){
    800044c8:	8552                	mv	a0,s4
    800044ca:	c1dfd0ef          	jal	800020e6 <killed>
    800044ce:	ed19                	bnez	a0,800044ec <piperead+0x5e>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800044d0:	85a6                	mv	a1,s1
    800044d2:	854e                	mv	a0,s3
    800044d4:	9dbfd0ef          	jal	80001eae <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800044d8:	2184a703          	lw	a4,536(s1)
    800044dc:	21c4a783          	lw	a5,540(s1)
    800044e0:	fef701e3          	beq	a4,a5,800044c2 <piperead+0x34>
    800044e4:	e85a                	sd	s6,16(sp)
    800044e6:	a809                	j	800044f8 <piperead+0x6a>
    800044e8:	e85a                	sd	s6,16(sp)
    800044ea:	a039                	j	800044f8 <piperead+0x6a>
      release(&pi->lock);
    800044ec:	8526                	mv	a0,s1
    800044ee:	f9efc0ef          	jal	80000c8c <release>
      return -1;
    800044f2:	59fd                	li	s3,-1
    800044f4:	a8b1                	j	80004550 <piperead+0xc2>
    800044f6:	e85a                	sd	s6,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800044f8:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800044fa:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800044fc:	05505263          	blez	s5,80004540 <piperead+0xb2>
    if(pi->nread == pi->nwrite)
    80004500:	2184a783          	lw	a5,536(s1)
    80004504:	21c4a703          	lw	a4,540(s1)
    80004508:	02f70c63          	beq	a4,a5,80004540 <piperead+0xb2>
    ch = pi->data[pi->nread++ % PIPESIZE];
    8000450c:	0017871b          	addiw	a4,a5,1
    80004510:	20e4ac23          	sw	a4,536(s1)
    80004514:	1ff7f793          	andi	a5,a5,511
    80004518:	97a6                	add	a5,a5,s1
    8000451a:	0187c783          	lbu	a5,24(a5)
    8000451e:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004522:	4685                	li	a3,1
    80004524:	fbf40613          	addi	a2,s0,-65
    80004528:	85ca                	mv	a1,s2
    8000452a:	050a3503          	ld	a0,80(s4)
    8000452e:	824fd0ef          	jal	80001552 <copyout>
    80004532:	01650763          	beq	a0,s6,80004540 <piperead+0xb2>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004536:	2985                	addiw	s3,s3,1
    80004538:	0905                	addi	s2,s2,1
    8000453a:	fd3a93e3          	bne	s5,s3,80004500 <piperead+0x72>
    8000453e:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004540:	21c48513          	addi	a0,s1,540
    80004544:	9b7fd0ef          	jal	80001efa <wakeup>
  release(&pi->lock);
    80004548:	8526                	mv	a0,s1
    8000454a:	f42fc0ef          	jal	80000c8c <release>
    8000454e:	6b42                	ld	s6,16(sp)
  return i;
}
    80004550:	854e                	mv	a0,s3
    80004552:	60a6                	ld	ra,72(sp)
    80004554:	6406                	ld	s0,64(sp)
    80004556:	74e2                	ld	s1,56(sp)
    80004558:	7942                	ld	s2,48(sp)
    8000455a:	79a2                	ld	s3,40(sp)
    8000455c:	7a02                	ld	s4,32(sp)
    8000455e:	6ae2                	ld	s5,24(sp)
    80004560:	6161                	addi	sp,sp,80
    80004562:	8082                	ret

0000000080004564 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80004564:	1141                	addi	sp,sp,-16
    80004566:	e422                	sd	s0,8(sp)
    80004568:	0800                	addi	s0,sp,16
    8000456a:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    8000456c:	8905                	andi	a0,a0,1
    8000456e:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    80004570:	8b89                	andi	a5,a5,2
    80004572:	c399                	beqz	a5,80004578 <flags2perm+0x14>
      perm |= PTE_W;
    80004574:	00456513          	ori	a0,a0,4
    return perm;
}
    80004578:	6422                	ld	s0,8(sp)
    8000457a:	0141                	addi	sp,sp,16
    8000457c:	8082                	ret

000000008000457e <exec>:

int
exec(char *path, char **argv)
{
    8000457e:	df010113          	addi	sp,sp,-528
    80004582:	20113423          	sd	ra,520(sp)
    80004586:	20813023          	sd	s0,512(sp)
    8000458a:	ffa6                	sd	s1,504(sp)
    8000458c:	fbca                	sd	s2,496(sp)
    8000458e:	0c00                	addi	s0,sp,528
    80004590:	892a                	mv	s2,a0
    80004592:	dea43c23          	sd	a0,-520(s0)
    80004596:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    8000459a:	b46fd0ef          	jal	800018e0 <myproc>
    8000459e:	84aa                	mv	s1,a0

  begin_op();
    800045a0:	dc6ff0ef          	jal	80003b66 <begin_op>

  if((ip = namei(path)) == 0){
    800045a4:	854a                	mv	a0,s2
    800045a6:	c04ff0ef          	jal	800039aa <namei>
    800045aa:	c931                	beqz	a0,800045fe <exec+0x80>
    800045ac:	f3d2                	sd	s4,480(sp)
    800045ae:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    800045b0:	d21fe0ef          	jal	800032d0 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    800045b4:	04000713          	li	a4,64
    800045b8:	4681                	li	a3,0
    800045ba:	e5040613          	addi	a2,s0,-432
    800045be:	4581                	li	a1,0
    800045c0:	8552                	mv	a0,s4
    800045c2:	f63fe0ef          	jal	80003524 <readi>
    800045c6:	04000793          	li	a5,64
    800045ca:	00f51a63          	bne	a0,a5,800045de <exec+0x60>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    800045ce:	e5042703          	lw	a4,-432(s0)
    800045d2:	464c47b7          	lui	a5,0x464c4
    800045d6:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    800045da:	02f70663          	beq	a4,a5,80004606 <exec+0x88>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    800045de:	8552                	mv	a0,s4
    800045e0:	efbfe0ef          	jal	800034da <iunlockput>
    end_op();
    800045e4:	decff0ef          	jal	80003bd0 <end_op>
  }
  return -1;
    800045e8:	557d                	li	a0,-1
    800045ea:	7a1e                	ld	s4,480(sp)
}
    800045ec:	20813083          	ld	ra,520(sp)
    800045f0:	20013403          	ld	s0,512(sp)
    800045f4:	74fe                	ld	s1,504(sp)
    800045f6:	795e                	ld	s2,496(sp)
    800045f8:	21010113          	addi	sp,sp,528
    800045fc:	8082                	ret
    end_op();
    800045fe:	dd2ff0ef          	jal	80003bd0 <end_op>
    return -1;
    80004602:	557d                	li	a0,-1
    80004604:	b7e5                	j	800045ec <exec+0x6e>
    80004606:	ebda                	sd	s6,464(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    80004608:	8526                	mv	a0,s1
    8000460a:	b7efd0ef          	jal	80001988 <proc_pagetable>
    8000460e:	8b2a                	mv	s6,a0
    80004610:	2c050b63          	beqz	a0,800048e6 <exec+0x368>
    80004614:	f7ce                	sd	s3,488(sp)
    80004616:	efd6                	sd	s5,472(sp)
    80004618:	e7de                	sd	s7,456(sp)
    8000461a:	e3e2                	sd	s8,448(sp)
    8000461c:	ff66                	sd	s9,440(sp)
    8000461e:	fb6a                	sd	s10,432(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004620:	e7042d03          	lw	s10,-400(s0)
    80004624:	e8845783          	lhu	a5,-376(s0)
    80004628:	12078963          	beqz	a5,8000475a <exec+0x1dc>
    8000462c:	f76e                	sd	s11,424(sp)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    8000462e:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004630:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    80004632:	6c85                	lui	s9,0x1
    80004634:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004638:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    8000463c:	6a85                	lui	s5,0x1
    8000463e:	a085                	j	8000469e <exec+0x120>
      panic("loadseg: address should exist");
    80004640:	00003517          	auipc	a0,0x3
    80004644:	04850513          	addi	a0,a0,72 # 80007688 <etext+0x688>
    80004648:	94cfc0ef          	jal	80000794 <panic>
    if(sz - i < PGSIZE)
    8000464c:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    8000464e:	8726                	mv	a4,s1
    80004650:	012c06bb          	addw	a3,s8,s2
    80004654:	4581                	li	a1,0
    80004656:	8552                	mv	a0,s4
    80004658:	ecdfe0ef          	jal	80003524 <readi>
    8000465c:	2501                	sext.w	a0,a0
    8000465e:	24a49a63          	bne	s1,a0,800048b2 <exec+0x334>
  for(i = 0; i < sz; i += PGSIZE){
    80004662:	012a893b          	addw	s2,s5,s2
    80004666:	03397363          	bgeu	s2,s3,8000468c <exec+0x10e>
    pa = walkaddr(pagetable, va + i);
    8000466a:	02091593          	slli	a1,s2,0x20
    8000466e:	9181                	srli	a1,a1,0x20
    80004670:	95de                	add	a1,a1,s7
    80004672:	855a                	mv	a0,s6
    80004674:	963fc0ef          	jal	80000fd6 <walkaddr>
    80004678:	862a                	mv	a2,a0
    if(pa == 0)
    8000467a:	d179                	beqz	a0,80004640 <exec+0xc2>
    if(sz - i < PGSIZE)
    8000467c:	412984bb          	subw	s1,s3,s2
    80004680:	0004879b          	sext.w	a5,s1
    80004684:	fcfcf4e3          	bgeu	s9,a5,8000464c <exec+0xce>
    80004688:	84d6                	mv	s1,s5
    8000468a:	b7c9                	j	8000464c <exec+0xce>
    sz = sz1;
    8000468c:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004690:	2d85                	addiw	s11,s11,1
    80004692:	038d0d1b          	addiw	s10,s10,56 # 1038 <_entry-0x7fffefc8>
    80004696:	e8845783          	lhu	a5,-376(s0)
    8000469a:	08fdd063          	bge	s11,a5,8000471a <exec+0x19c>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    8000469e:	2d01                	sext.w	s10,s10
    800046a0:	03800713          	li	a4,56
    800046a4:	86ea                	mv	a3,s10
    800046a6:	e1840613          	addi	a2,s0,-488
    800046aa:	4581                	li	a1,0
    800046ac:	8552                	mv	a0,s4
    800046ae:	e77fe0ef          	jal	80003524 <readi>
    800046b2:	03800793          	li	a5,56
    800046b6:	1cf51663          	bne	a0,a5,80004882 <exec+0x304>
    if(ph.type != ELF_PROG_LOAD)
    800046ba:	e1842783          	lw	a5,-488(s0)
    800046be:	4705                	li	a4,1
    800046c0:	fce798e3          	bne	a5,a4,80004690 <exec+0x112>
    if(ph.memsz < ph.filesz)
    800046c4:	e4043483          	ld	s1,-448(s0)
    800046c8:	e3843783          	ld	a5,-456(s0)
    800046cc:	1af4ef63          	bltu	s1,a5,8000488a <exec+0x30c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    800046d0:	e2843783          	ld	a5,-472(s0)
    800046d4:	94be                	add	s1,s1,a5
    800046d6:	1af4ee63          	bltu	s1,a5,80004892 <exec+0x314>
    if(ph.vaddr % PGSIZE != 0)
    800046da:	df043703          	ld	a4,-528(s0)
    800046de:	8ff9                	and	a5,a5,a4
    800046e0:	1a079d63          	bnez	a5,8000489a <exec+0x31c>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800046e4:	e1c42503          	lw	a0,-484(s0)
    800046e8:	e7dff0ef          	jal	80004564 <flags2perm>
    800046ec:	86aa                	mv	a3,a0
    800046ee:	8626                	mv	a2,s1
    800046f0:	85ca                	mv	a1,s2
    800046f2:	855a                	mv	a0,s6
    800046f4:	c4bfc0ef          	jal	8000133e <uvmalloc>
    800046f8:	e0a43423          	sd	a0,-504(s0)
    800046fc:	1a050363          	beqz	a0,800048a2 <exec+0x324>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004700:	e2843b83          	ld	s7,-472(s0)
    80004704:	e2042c03          	lw	s8,-480(s0)
    80004708:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    8000470c:	00098463          	beqz	s3,80004714 <exec+0x196>
    80004710:	4901                	li	s2,0
    80004712:	bfa1                	j	8000466a <exec+0xec>
    sz = sz1;
    80004714:	e0843903          	ld	s2,-504(s0)
    80004718:	bfa5                	j	80004690 <exec+0x112>
    8000471a:	7dba                	ld	s11,424(sp)
  iunlockput(ip);
    8000471c:	8552                	mv	a0,s4
    8000471e:	dbdfe0ef          	jal	800034da <iunlockput>
  end_op();
    80004722:	caeff0ef          	jal	80003bd0 <end_op>
  p = myproc();
    80004726:	9bafd0ef          	jal	800018e0 <myproc>
    8000472a:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    8000472c:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    80004730:	6985                	lui	s3,0x1
    80004732:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    80004734:	99ca                	add	s3,s3,s2
    80004736:	77fd                	lui	a5,0xfffff
    80004738:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    8000473c:	4691                	li	a3,4
    8000473e:	6609                	lui	a2,0x2
    80004740:	964e                	add	a2,a2,s3
    80004742:	85ce                	mv	a1,s3
    80004744:	855a                	mv	a0,s6
    80004746:	bf9fc0ef          	jal	8000133e <uvmalloc>
    8000474a:	892a                	mv	s2,a0
    8000474c:	e0a43423          	sd	a0,-504(s0)
    80004750:	e519                	bnez	a0,8000475e <exec+0x1e0>
  if(pagetable)
    80004752:	e1343423          	sd	s3,-504(s0)
    80004756:	4a01                	li	s4,0
    80004758:	aab1                	j	800048b4 <exec+0x336>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    8000475a:	4901                	li	s2,0
    8000475c:	b7c1                	j	8000471c <exec+0x19e>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    8000475e:	75f9                	lui	a1,0xffffe
    80004760:	95aa                	add	a1,a1,a0
    80004762:	855a                	mv	a0,s6
    80004764:	dc5fc0ef          	jal	80001528 <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    80004768:	7bfd                	lui	s7,0xfffff
    8000476a:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    8000476c:	e0043783          	ld	a5,-512(s0)
    80004770:	6388                	ld	a0,0(a5)
    80004772:	cd39                	beqz	a0,800047d0 <exec+0x252>
    80004774:	e9040993          	addi	s3,s0,-368
    80004778:	f9040c13          	addi	s8,s0,-112
    8000477c:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    8000477e:	ebafc0ef          	jal	80000e38 <strlen>
    80004782:	0015079b          	addiw	a5,a0,1
    80004786:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    8000478a:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    8000478e:	11796e63          	bltu	s2,s7,800048aa <exec+0x32c>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004792:	e0043d03          	ld	s10,-512(s0)
    80004796:	000d3a03          	ld	s4,0(s10)
    8000479a:	8552                	mv	a0,s4
    8000479c:	e9cfc0ef          	jal	80000e38 <strlen>
    800047a0:	0015069b          	addiw	a3,a0,1
    800047a4:	8652                	mv	a2,s4
    800047a6:	85ca                	mv	a1,s2
    800047a8:	855a                	mv	a0,s6
    800047aa:	da9fc0ef          	jal	80001552 <copyout>
    800047ae:	10054063          	bltz	a0,800048ae <exec+0x330>
    ustack[argc] = sp;
    800047b2:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    800047b6:	0485                	addi	s1,s1,1
    800047b8:	008d0793          	addi	a5,s10,8
    800047bc:	e0f43023          	sd	a5,-512(s0)
    800047c0:	008d3503          	ld	a0,8(s10)
    800047c4:	c909                	beqz	a0,800047d6 <exec+0x258>
    if(argc >= MAXARG)
    800047c6:	09a1                	addi	s3,s3,8
    800047c8:	fb899be3          	bne	s3,s8,8000477e <exec+0x200>
  ip = 0;
    800047cc:	4a01                	li	s4,0
    800047ce:	a0dd                	j	800048b4 <exec+0x336>
  sp = sz;
    800047d0:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    800047d4:	4481                	li	s1,0
  ustack[argc] = 0;
    800047d6:	00349793          	slli	a5,s1,0x3
    800047da:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffdb920>
    800047de:	97a2                	add	a5,a5,s0
    800047e0:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    800047e4:	00148693          	addi	a3,s1,1
    800047e8:	068e                	slli	a3,a3,0x3
    800047ea:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    800047ee:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    800047f2:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    800047f6:	f5796ee3          	bltu	s2,s7,80004752 <exec+0x1d4>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    800047fa:	e9040613          	addi	a2,s0,-368
    800047fe:	85ca                	mv	a1,s2
    80004800:	855a                	mv	a0,s6
    80004802:	d51fc0ef          	jal	80001552 <copyout>
    80004806:	0e054263          	bltz	a0,800048ea <exec+0x36c>
  p->trapframe->a1 = sp;
    8000480a:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    8000480e:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004812:	df843783          	ld	a5,-520(s0)
    80004816:	0007c703          	lbu	a4,0(a5)
    8000481a:	cf11                	beqz	a4,80004836 <exec+0x2b8>
    8000481c:	0785                	addi	a5,a5,1
    if(*s == '/')
    8000481e:	02f00693          	li	a3,47
    80004822:	a039                	j	80004830 <exec+0x2b2>
      last = s+1;
    80004824:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    80004828:	0785                	addi	a5,a5,1
    8000482a:	fff7c703          	lbu	a4,-1(a5)
    8000482e:	c701                	beqz	a4,80004836 <exec+0x2b8>
    if(*s == '/')
    80004830:	fed71ce3          	bne	a4,a3,80004828 <exec+0x2aa>
    80004834:	bfc5                	j	80004824 <exec+0x2a6>
  safestrcpy(p->name, last, sizeof(p->name));
    80004836:	4641                	li	a2,16
    80004838:	df843583          	ld	a1,-520(s0)
    8000483c:	158a8513          	addi	a0,s5,344
    80004840:	dc6fc0ef          	jal	80000e06 <safestrcpy>
  oldpagetable = p->pagetable;
    80004844:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80004848:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    8000484c:	e0843783          	ld	a5,-504(s0)
    80004850:	04fab423          	sd	a5,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80004854:	058ab783          	ld	a5,88(s5)
    80004858:	e6843703          	ld	a4,-408(s0)
    8000485c:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    8000485e:	058ab783          	ld	a5,88(s5)
    80004862:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004866:	85e6                	mv	a1,s9
    80004868:	9a4fd0ef          	jal	80001a0c <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    8000486c:	0004851b          	sext.w	a0,s1
    80004870:	79be                	ld	s3,488(sp)
    80004872:	7a1e                	ld	s4,480(sp)
    80004874:	6afe                	ld	s5,472(sp)
    80004876:	6b5e                	ld	s6,464(sp)
    80004878:	6bbe                	ld	s7,456(sp)
    8000487a:	6c1e                	ld	s8,448(sp)
    8000487c:	7cfa                	ld	s9,440(sp)
    8000487e:	7d5a                	ld	s10,432(sp)
    80004880:	b3b5                	j	800045ec <exec+0x6e>
    80004882:	e1243423          	sd	s2,-504(s0)
    80004886:	7dba                	ld	s11,424(sp)
    80004888:	a035                	j	800048b4 <exec+0x336>
    8000488a:	e1243423          	sd	s2,-504(s0)
    8000488e:	7dba                	ld	s11,424(sp)
    80004890:	a015                	j	800048b4 <exec+0x336>
    80004892:	e1243423          	sd	s2,-504(s0)
    80004896:	7dba                	ld	s11,424(sp)
    80004898:	a831                	j	800048b4 <exec+0x336>
    8000489a:	e1243423          	sd	s2,-504(s0)
    8000489e:	7dba                	ld	s11,424(sp)
    800048a0:	a811                	j	800048b4 <exec+0x336>
    800048a2:	e1243423          	sd	s2,-504(s0)
    800048a6:	7dba                	ld	s11,424(sp)
    800048a8:	a031                	j	800048b4 <exec+0x336>
  ip = 0;
    800048aa:	4a01                	li	s4,0
    800048ac:	a021                	j	800048b4 <exec+0x336>
    800048ae:	4a01                	li	s4,0
  if(pagetable)
    800048b0:	a011                	j	800048b4 <exec+0x336>
    800048b2:	7dba                	ld	s11,424(sp)
    proc_freepagetable(pagetable, sz);
    800048b4:	e0843583          	ld	a1,-504(s0)
    800048b8:	855a                	mv	a0,s6
    800048ba:	952fd0ef          	jal	80001a0c <proc_freepagetable>
  return -1;
    800048be:	557d                	li	a0,-1
  if(ip){
    800048c0:	000a1b63          	bnez	s4,800048d6 <exec+0x358>
    800048c4:	79be                	ld	s3,488(sp)
    800048c6:	7a1e                	ld	s4,480(sp)
    800048c8:	6afe                	ld	s5,472(sp)
    800048ca:	6b5e                	ld	s6,464(sp)
    800048cc:	6bbe                	ld	s7,456(sp)
    800048ce:	6c1e                	ld	s8,448(sp)
    800048d0:	7cfa                	ld	s9,440(sp)
    800048d2:	7d5a                	ld	s10,432(sp)
    800048d4:	bb21                	j	800045ec <exec+0x6e>
    800048d6:	79be                	ld	s3,488(sp)
    800048d8:	6afe                	ld	s5,472(sp)
    800048da:	6b5e                	ld	s6,464(sp)
    800048dc:	6bbe                	ld	s7,456(sp)
    800048de:	6c1e                	ld	s8,448(sp)
    800048e0:	7cfa                	ld	s9,440(sp)
    800048e2:	7d5a                	ld	s10,432(sp)
    800048e4:	b9ed                	j	800045de <exec+0x60>
    800048e6:	6b5e                	ld	s6,464(sp)
    800048e8:	b9dd                	j	800045de <exec+0x60>
  sz = sz1;
    800048ea:	e0843983          	ld	s3,-504(s0)
    800048ee:	b595                	j	80004752 <exec+0x1d4>

00000000800048f0 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    800048f0:	7179                	addi	sp,sp,-48
    800048f2:	f406                	sd	ra,40(sp)
    800048f4:	f022                	sd	s0,32(sp)
    800048f6:	ec26                	sd	s1,24(sp)
    800048f8:	e84a                	sd	s2,16(sp)
    800048fa:	1800                	addi	s0,sp,48
    800048fc:	892e                	mv	s2,a1
    800048fe:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004900:	fdc40593          	addi	a1,s0,-36
    80004904:	f8dfd0ef          	jal	80002890 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004908:	fdc42703          	lw	a4,-36(s0)
    8000490c:	47bd                	li	a5,15
    8000490e:	02e7e963          	bltu	a5,a4,80004940 <argfd+0x50>
    80004912:	fcffc0ef          	jal	800018e0 <myproc>
    80004916:	fdc42703          	lw	a4,-36(s0)
    8000491a:	01a70793          	addi	a5,a4,26
    8000491e:	078e                	slli	a5,a5,0x3
    80004920:	953e                	add	a0,a0,a5
    80004922:	611c                	ld	a5,0(a0)
    80004924:	c385                	beqz	a5,80004944 <argfd+0x54>
    return -1;
  if(pfd)
    80004926:	00090463          	beqz	s2,8000492e <argfd+0x3e>
    *pfd = fd;
    8000492a:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    8000492e:	4501                	li	a0,0
  if(pf)
    80004930:	c091                	beqz	s1,80004934 <argfd+0x44>
    *pf = f;
    80004932:	e09c                	sd	a5,0(s1)
}
    80004934:	70a2                	ld	ra,40(sp)
    80004936:	7402                	ld	s0,32(sp)
    80004938:	64e2                	ld	s1,24(sp)
    8000493a:	6942                	ld	s2,16(sp)
    8000493c:	6145                	addi	sp,sp,48
    8000493e:	8082                	ret
    return -1;
    80004940:	557d                	li	a0,-1
    80004942:	bfcd                	j	80004934 <argfd+0x44>
    80004944:	557d                	li	a0,-1
    80004946:	b7fd                	j	80004934 <argfd+0x44>

0000000080004948 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004948:	1101                	addi	sp,sp,-32
    8000494a:	ec06                	sd	ra,24(sp)
    8000494c:	e822                	sd	s0,16(sp)
    8000494e:	e426                	sd	s1,8(sp)
    80004950:	1000                	addi	s0,sp,32
    80004952:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004954:	f8dfc0ef          	jal	800018e0 <myproc>
    80004958:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    8000495a:	0d050793          	addi	a5,a0,208
    8000495e:	4501                	li	a0,0
    80004960:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80004962:	6398                	ld	a4,0(a5)
    80004964:	cb19                	beqz	a4,8000497a <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    80004966:	2505                	addiw	a0,a0,1
    80004968:	07a1                	addi	a5,a5,8
    8000496a:	fed51ce3          	bne	a0,a3,80004962 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    8000496e:	557d                	li	a0,-1
}
    80004970:	60e2                	ld	ra,24(sp)
    80004972:	6442                	ld	s0,16(sp)
    80004974:	64a2                	ld	s1,8(sp)
    80004976:	6105                	addi	sp,sp,32
    80004978:	8082                	ret
      p->ofile[fd] = f;
    8000497a:	01a50793          	addi	a5,a0,26
    8000497e:	078e                	slli	a5,a5,0x3
    80004980:	963e                	add	a2,a2,a5
    80004982:	e204                	sd	s1,0(a2)
      return fd;
    80004984:	b7f5                	j	80004970 <fdalloc+0x28>

0000000080004986 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80004986:	715d                	addi	sp,sp,-80
    80004988:	e486                	sd	ra,72(sp)
    8000498a:	e0a2                	sd	s0,64(sp)
    8000498c:	fc26                	sd	s1,56(sp)
    8000498e:	f84a                	sd	s2,48(sp)
    80004990:	f44e                	sd	s3,40(sp)
    80004992:	ec56                	sd	s5,24(sp)
    80004994:	e85a                	sd	s6,16(sp)
    80004996:	0880                	addi	s0,sp,80
    80004998:	8b2e                	mv	s6,a1
    8000499a:	89b2                	mv	s3,a2
    8000499c:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    8000499e:	fb040593          	addi	a1,s0,-80
    800049a2:	822ff0ef          	jal	800039c4 <nameiparent>
    800049a6:	84aa                	mv	s1,a0
    800049a8:	10050a63          	beqz	a0,80004abc <create+0x136>
    return 0;

  ilock(dp);
    800049ac:	925fe0ef          	jal	800032d0 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800049b0:	4601                	li	a2,0
    800049b2:	fb040593          	addi	a1,s0,-80
    800049b6:	8526                	mv	a0,s1
    800049b8:	d8dfe0ef          	jal	80003744 <dirlookup>
    800049bc:	8aaa                	mv	s5,a0
    800049be:	c129                	beqz	a0,80004a00 <create+0x7a>
    iunlockput(dp);
    800049c0:	8526                	mv	a0,s1
    800049c2:	b19fe0ef          	jal	800034da <iunlockput>
    ilock(ip);
    800049c6:	8556                	mv	a0,s5
    800049c8:	909fe0ef          	jal	800032d0 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800049cc:	4789                	li	a5,2
    800049ce:	02fb1463          	bne	s6,a5,800049f6 <create+0x70>
    800049d2:	044ad783          	lhu	a5,68(s5)
    800049d6:	37f9                	addiw	a5,a5,-2
    800049d8:	17c2                	slli	a5,a5,0x30
    800049da:	93c1                	srli	a5,a5,0x30
    800049dc:	4705                	li	a4,1
    800049de:	00f76c63          	bltu	a4,a5,800049f6 <create+0x70>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    800049e2:	8556                	mv	a0,s5
    800049e4:	60a6                	ld	ra,72(sp)
    800049e6:	6406                	ld	s0,64(sp)
    800049e8:	74e2                	ld	s1,56(sp)
    800049ea:	7942                	ld	s2,48(sp)
    800049ec:	79a2                	ld	s3,40(sp)
    800049ee:	6ae2                	ld	s5,24(sp)
    800049f0:	6b42                	ld	s6,16(sp)
    800049f2:	6161                	addi	sp,sp,80
    800049f4:	8082                	ret
    iunlockput(ip);
    800049f6:	8556                	mv	a0,s5
    800049f8:	ae3fe0ef          	jal	800034da <iunlockput>
    return 0;
    800049fc:	4a81                	li	s5,0
    800049fe:	b7d5                	j	800049e2 <create+0x5c>
    80004a00:	f052                	sd	s4,32(sp)
  if((ip = ialloc(dp->dev, type)) == 0){
    80004a02:	85da                	mv	a1,s6
    80004a04:	4088                	lw	a0,0(s1)
    80004a06:	f5afe0ef          	jal	80003160 <ialloc>
    80004a0a:	8a2a                	mv	s4,a0
    80004a0c:	cd15                	beqz	a0,80004a48 <create+0xc2>
  ilock(ip);
    80004a0e:	8c3fe0ef          	jal	800032d0 <ilock>
  ip->major = major;
    80004a12:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80004a16:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80004a1a:	4905                	li	s2,1
    80004a1c:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80004a20:	8552                	mv	a0,s4
    80004a22:	ffafe0ef          	jal	8000321c <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80004a26:	032b0763          	beq	s6,s2,80004a54 <create+0xce>
  if(dirlink(dp, name, ip->inum) < 0)
    80004a2a:	004a2603          	lw	a2,4(s4)
    80004a2e:	fb040593          	addi	a1,s0,-80
    80004a32:	8526                	mv	a0,s1
    80004a34:	eddfe0ef          	jal	80003910 <dirlink>
    80004a38:	06054563          	bltz	a0,80004aa2 <create+0x11c>
  iunlockput(dp);
    80004a3c:	8526                	mv	a0,s1
    80004a3e:	a9dfe0ef          	jal	800034da <iunlockput>
  return ip;
    80004a42:	8ad2                	mv	s5,s4
    80004a44:	7a02                	ld	s4,32(sp)
    80004a46:	bf71                	j	800049e2 <create+0x5c>
    iunlockput(dp);
    80004a48:	8526                	mv	a0,s1
    80004a4a:	a91fe0ef          	jal	800034da <iunlockput>
    return 0;
    80004a4e:	8ad2                	mv	s5,s4
    80004a50:	7a02                	ld	s4,32(sp)
    80004a52:	bf41                	j	800049e2 <create+0x5c>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80004a54:	004a2603          	lw	a2,4(s4)
    80004a58:	00003597          	auipc	a1,0x3
    80004a5c:	c5058593          	addi	a1,a1,-944 # 800076a8 <etext+0x6a8>
    80004a60:	8552                	mv	a0,s4
    80004a62:	eaffe0ef          	jal	80003910 <dirlink>
    80004a66:	02054e63          	bltz	a0,80004aa2 <create+0x11c>
    80004a6a:	40d0                	lw	a2,4(s1)
    80004a6c:	00003597          	auipc	a1,0x3
    80004a70:	c4458593          	addi	a1,a1,-956 # 800076b0 <etext+0x6b0>
    80004a74:	8552                	mv	a0,s4
    80004a76:	e9bfe0ef          	jal	80003910 <dirlink>
    80004a7a:	02054463          	bltz	a0,80004aa2 <create+0x11c>
  if(dirlink(dp, name, ip->inum) < 0)
    80004a7e:	004a2603          	lw	a2,4(s4)
    80004a82:	fb040593          	addi	a1,s0,-80
    80004a86:	8526                	mv	a0,s1
    80004a88:	e89fe0ef          	jal	80003910 <dirlink>
    80004a8c:	00054b63          	bltz	a0,80004aa2 <create+0x11c>
    dp->nlink++;  // for ".."
    80004a90:	04a4d783          	lhu	a5,74(s1)
    80004a94:	2785                	addiw	a5,a5,1
    80004a96:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004a9a:	8526                	mv	a0,s1
    80004a9c:	f80fe0ef          	jal	8000321c <iupdate>
    80004aa0:	bf71                	j	80004a3c <create+0xb6>
  ip->nlink = 0;
    80004aa2:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80004aa6:	8552                	mv	a0,s4
    80004aa8:	f74fe0ef          	jal	8000321c <iupdate>
  iunlockput(ip);
    80004aac:	8552                	mv	a0,s4
    80004aae:	a2dfe0ef          	jal	800034da <iunlockput>
  iunlockput(dp);
    80004ab2:	8526                	mv	a0,s1
    80004ab4:	a27fe0ef          	jal	800034da <iunlockput>
  return 0;
    80004ab8:	7a02                	ld	s4,32(sp)
    80004aba:	b725                	j	800049e2 <create+0x5c>
    return 0;
    80004abc:	8aaa                	mv	s5,a0
    80004abe:	b715                	j	800049e2 <create+0x5c>

0000000080004ac0 <sys_dup>:
{
    80004ac0:	7179                	addi	sp,sp,-48
    80004ac2:	f406                	sd	ra,40(sp)
    80004ac4:	f022                	sd	s0,32(sp)
    80004ac6:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80004ac8:	fd840613          	addi	a2,s0,-40
    80004acc:	4581                	li	a1,0
    80004ace:	4501                	li	a0,0
    80004ad0:	e21ff0ef          	jal	800048f0 <argfd>
    return -1;
    80004ad4:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80004ad6:	02054363          	bltz	a0,80004afc <sys_dup+0x3c>
    80004ada:	ec26                	sd	s1,24(sp)
    80004adc:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    80004ade:	fd843903          	ld	s2,-40(s0)
    80004ae2:	854a                	mv	a0,s2
    80004ae4:	e65ff0ef          	jal	80004948 <fdalloc>
    80004ae8:	84aa                	mv	s1,a0
    return -1;
    80004aea:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80004aec:	00054d63          	bltz	a0,80004b06 <sys_dup+0x46>
  filedup(f);
    80004af0:	854a                	mv	a0,s2
    80004af2:	c48ff0ef          	jal	80003f3a <filedup>
  return fd;
    80004af6:	87a6                	mv	a5,s1
    80004af8:	64e2                	ld	s1,24(sp)
    80004afa:	6942                	ld	s2,16(sp)
}
    80004afc:	853e                	mv	a0,a5
    80004afe:	70a2                	ld	ra,40(sp)
    80004b00:	7402                	ld	s0,32(sp)
    80004b02:	6145                	addi	sp,sp,48
    80004b04:	8082                	ret
    80004b06:	64e2                	ld	s1,24(sp)
    80004b08:	6942                	ld	s2,16(sp)
    80004b0a:	bfcd                	j	80004afc <sys_dup+0x3c>

0000000080004b0c <sys_read>:
{
    80004b0c:	7179                	addi	sp,sp,-48
    80004b0e:	f406                	sd	ra,40(sp)
    80004b10:	f022                	sd	s0,32(sp)
    80004b12:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004b14:	fd840593          	addi	a1,s0,-40
    80004b18:	4505                	li	a0,1
    80004b1a:	d93fd0ef          	jal	800028ac <argaddr>
  argint(2, &n);
    80004b1e:	fe440593          	addi	a1,s0,-28
    80004b22:	4509                	li	a0,2
    80004b24:	d6dfd0ef          	jal	80002890 <argint>
  if(argfd(0, 0, &f) < 0)
    80004b28:	fe840613          	addi	a2,s0,-24
    80004b2c:	4581                	li	a1,0
    80004b2e:	4501                	li	a0,0
    80004b30:	dc1ff0ef          	jal	800048f0 <argfd>
    80004b34:	87aa                	mv	a5,a0
    return -1;
    80004b36:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004b38:	0007ca63          	bltz	a5,80004b4c <sys_read+0x40>
  return fileread(f, p, n);
    80004b3c:	fe442603          	lw	a2,-28(s0)
    80004b40:	fd843583          	ld	a1,-40(s0)
    80004b44:	fe843503          	ld	a0,-24(s0)
    80004b48:	d58ff0ef          	jal	800040a0 <fileread>
}
    80004b4c:	70a2                	ld	ra,40(sp)
    80004b4e:	7402                	ld	s0,32(sp)
    80004b50:	6145                	addi	sp,sp,48
    80004b52:	8082                	ret

0000000080004b54 <sys_write>:
{
    80004b54:	7179                	addi	sp,sp,-48
    80004b56:	f406                	sd	ra,40(sp)
    80004b58:	f022                	sd	s0,32(sp)
    80004b5a:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004b5c:	fd840593          	addi	a1,s0,-40
    80004b60:	4505                	li	a0,1
    80004b62:	d4bfd0ef          	jal	800028ac <argaddr>
  argint(2, &n);
    80004b66:	fe440593          	addi	a1,s0,-28
    80004b6a:	4509                	li	a0,2
    80004b6c:	d25fd0ef          	jal	80002890 <argint>
  if(argfd(0, 0, &f) < 0)
    80004b70:	fe840613          	addi	a2,s0,-24
    80004b74:	4581                	li	a1,0
    80004b76:	4501                	li	a0,0
    80004b78:	d79ff0ef          	jal	800048f0 <argfd>
    80004b7c:	87aa                	mv	a5,a0
    return -1;
    80004b7e:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004b80:	0007ca63          	bltz	a5,80004b94 <sys_write+0x40>
  return filewrite(f, p, n);
    80004b84:	fe442603          	lw	a2,-28(s0)
    80004b88:	fd843583          	ld	a1,-40(s0)
    80004b8c:	fe843503          	ld	a0,-24(s0)
    80004b90:	dceff0ef          	jal	8000415e <filewrite>
}
    80004b94:	70a2                	ld	ra,40(sp)
    80004b96:	7402                	ld	s0,32(sp)
    80004b98:	6145                	addi	sp,sp,48
    80004b9a:	8082                	ret

0000000080004b9c <sys_close>:
{
    80004b9c:	1101                	addi	sp,sp,-32
    80004b9e:	ec06                	sd	ra,24(sp)
    80004ba0:	e822                	sd	s0,16(sp)
    80004ba2:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80004ba4:	fe040613          	addi	a2,s0,-32
    80004ba8:	fec40593          	addi	a1,s0,-20
    80004bac:	4501                	li	a0,0
    80004bae:	d43ff0ef          	jal	800048f0 <argfd>
    return -1;
    80004bb2:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80004bb4:	02054063          	bltz	a0,80004bd4 <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    80004bb8:	d29fc0ef          	jal	800018e0 <myproc>
    80004bbc:	fec42783          	lw	a5,-20(s0)
    80004bc0:	07e9                	addi	a5,a5,26
    80004bc2:	078e                	slli	a5,a5,0x3
    80004bc4:	953e                	add	a0,a0,a5
    80004bc6:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80004bca:	fe043503          	ld	a0,-32(s0)
    80004bce:	bb2ff0ef          	jal	80003f80 <fileclose>
  return 0;
    80004bd2:	4781                	li	a5,0
}
    80004bd4:	853e                	mv	a0,a5
    80004bd6:	60e2                	ld	ra,24(sp)
    80004bd8:	6442                	ld	s0,16(sp)
    80004bda:	6105                	addi	sp,sp,32
    80004bdc:	8082                	ret

0000000080004bde <sys_fstat>:
{
    80004bde:	1101                	addi	sp,sp,-32
    80004be0:	ec06                	sd	ra,24(sp)
    80004be2:	e822                	sd	s0,16(sp)
    80004be4:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80004be6:	fe040593          	addi	a1,s0,-32
    80004bea:	4505                	li	a0,1
    80004bec:	cc1fd0ef          	jal	800028ac <argaddr>
  if(argfd(0, 0, &f) < 0)
    80004bf0:	fe840613          	addi	a2,s0,-24
    80004bf4:	4581                	li	a1,0
    80004bf6:	4501                	li	a0,0
    80004bf8:	cf9ff0ef          	jal	800048f0 <argfd>
    80004bfc:	87aa                	mv	a5,a0
    return -1;
    80004bfe:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004c00:	0007c863          	bltz	a5,80004c10 <sys_fstat+0x32>
  return filestat(f, st);
    80004c04:	fe043583          	ld	a1,-32(s0)
    80004c08:	fe843503          	ld	a0,-24(s0)
    80004c0c:	c36ff0ef          	jal	80004042 <filestat>
}
    80004c10:	60e2                	ld	ra,24(sp)
    80004c12:	6442                	ld	s0,16(sp)
    80004c14:	6105                	addi	sp,sp,32
    80004c16:	8082                	ret

0000000080004c18 <sys_link>:
{
    80004c18:	7169                	addi	sp,sp,-304
    80004c1a:	f606                	sd	ra,296(sp)
    80004c1c:	f222                	sd	s0,288(sp)
    80004c1e:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004c20:	08000613          	li	a2,128
    80004c24:	ed040593          	addi	a1,s0,-304
    80004c28:	4501                	li	a0,0
    80004c2a:	c9ffd0ef          	jal	800028c8 <argstr>
    return -1;
    80004c2e:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004c30:	0c054e63          	bltz	a0,80004d0c <sys_link+0xf4>
    80004c34:	08000613          	li	a2,128
    80004c38:	f5040593          	addi	a1,s0,-176
    80004c3c:	4505                	li	a0,1
    80004c3e:	c8bfd0ef          	jal	800028c8 <argstr>
    return -1;
    80004c42:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004c44:	0c054463          	bltz	a0,80004d0c <sys_link+0xf4>
    80004c48:	ee26                	sd	s1,280(sp)
  begin_op();
    80004c4a:	f1dfe0ef          	jal	80003b66 <begin_op>
  if((ip = namei(old)) == 0){
    80004c4e:	ed040513          	addi	a0,s0,-304
    80004c52:	d59fe0ef          	jal	800039aa <namei>
    80004c56:	84aa                	mv	s1,a0
    80004c58:	c53d                	beqz	a0,80004cc6 <sys_link+0xae>
  ilock(ip);
    80004c5a:	e76fe0ef          	jal	800032d0 <ilock>
  if(ip->type == T_DIR){
    80004c5e:	04449703          	lh	a4,68(s1)
    80004c62:	4785                	li	a5,1
    80004c64:	06f70663          	beq	a4,a5,80004cd0 <sys_link+0xb8>
    80004c68:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80004c6a:	04a4d783          	lhu	a5,74(s1)
    80004c6e:	2785                	addiw	a5,a5,1
    80004c70:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004c74:	8526                	mv	a0,s1
    80004c76:	da6fe0ef          	jal	8000321c <iupdate>
  iunlock(ip);
    80004c7a:	8526                	mv	a0,s1
    80004c7c:	f02fe0ef          	jal	8000337e <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80004c80:	fd040593          	addi	a1,s0,-48
    80004c84:	f5040513          	addi	a0,s0,-176
    80004c88:	d3dfe0ef          	jal	800039c4 <nameiparent>
    80004c8c:	892a                	mv	s2,a0
    80004c8e:	cd21                	beqz	a0,80004ce6 <sys_link+0xce>
  ilock(dp);
    80004c90:	e40fe0ef          	jal	800032d0 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80004c94:	00092703          	lw	a4,0(s2)
    80004c98:	409c                	lw	a5,0(s1)
    80004c9a:	04f71363          	bne	a4,a5,80004ce0 <sys_link+0xc8>
    80004c9e:	40d0                	lw	a2,4(s1)
    80004ca0:	fd040593          	addi	a1,s0,-48
    80004ca4:	854a                	mv	a0,s2
    80004ca6:	c6bfe0ef          	jal	80003910 <dirlink>
    80004caa:	02054b63          	bltz	a0,80004ce0 <sys_link+0xc8>
  iunlockput(dp);
    80004cae:	854a                	mv	a0,s2
    80004cb0:	82bfe0ef          	jal	800034da <iunlockput>
  iput(ip);
    80004cb4:	8526                	mv	a0,s1
    80004cb6:	f9cfe0ef          	jal	80003452 <iput>
  end_op();
    80004cba:	f17fe0ef          	jal	80003bd0 <end_op>
  return 0;
    80004cbe:	4781                	li	a5,0
    80004cc0:	64f2                	ld	s1,280(sp)
    80004cc2:	6952                	ld	s2,272(sp)
    80004cc4:	a0a1                	j	80004d0c <sys_link+0xf4>
    end_op();
    80004cc6:	f0bfe0ef          	jal	80003bd0 <end_op>
    return -1;
    80004cca:	57fd                	li	a5,-1
    80004ccc:	64f2                	ld	s1,280(sp)
    80004cce:	a83d                	j	80004d0c <sys_link+0xf4>
    iunlockput(ip);
    80004cd0:	8526                	mv	a0,s1
    80004cd2:	809fe0ef          	jal	800034da <iunlockput>
    end_op();
    80004cd6:	efbfe0ef          	jal	80003bd0 <end_op>
    return -1;
    80004cda:	57fd                	li	a5,-1
    80004cdc:	64f2                	ld	s1,280(sp)
    80004cde:	a03d                	j	80004d0c <sys_link+0xf4>
    iunlockput(dp);
    80004ce0:	854a                	mv	a0,s2
    80004ce2:	ff8fe0ef          	jal	800034da <iunlockput>
  ilock(ip);
    80004ce6:	8526                	mv	a0,s1
    80004ce8:	de8fe0ef          	jal	800032d0 <ilock>
  ip->nlink--;
    80004cec:	04a4d783          	lhu	a5,74(s1)
    80004cf0:	37fd                	addiw	a5,a5,-1
    80004cf2:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004cf6:	8526                	mv	a0,s1
    80004cf8:	d24fe0ef          	jal	8000321c <iupdate>
  iunlockput(ip);
    80004cfc:	8526                	mv	a0,s1
    80004cfe:	fdcfe0ef          	jal	800034da <iunlockput>
  end_op();
    80004d02:	ecffe0ef          	jal	80003bd0 <end_op>
  return -1;
    80004d06:	57fd                	li	a5,-1
    80004d08:	64f2                	ld	s1,280(sp)
    80004d0a:	6952                	ld	s2,272(sp)
}
    80004d0c:	853e                	mv	a0,a5
    80004d0e:	70b2                	ld	ra,296(sp)
    80004d10:	7412                	ld	s0,288(sp)
    80004d12:	6155                	addi	sp,sp,304
    80004d14:	8082                	ret

0000000080004d16 <sys_unlink>:
{
    80004d16:	7151                	addi	sp,sp,-240
    80004d18:	f586                	sd	ra,232(sp)
    80004d1a:	f1a2                	sd	s0,224(sp)
    80004d1c:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80004d1e:	08000613          	li	a2,128
    80004d22:	f3040593          	addi	a1,s0,-208
    80004d26:	4501                	li	a0,0
    80004d28:	ba1fd0ef          	jal	800028c8 <argstr>
    80004d2c:	16054063          	bltz	a0,80004e8c <sys_unlink+0x176>
    80004d30:	eda6                	sd	s1,216(sp)
  begin_op();
    80004d32:	e35fe0ef          	jal	80003b66 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80004d36:	fb040593          	addi	a1,s0,-80
    80004d3a:	f3040513          	addi	a0,s0,-208
    80004d3e:	c87fe0ef          	jal	800039c4 <nameiparent>
    80004d42:	84aa                	mv	s1,a0
    80004d44:	c945                	beqz	a0,80004df4 <sys_unlink+0xde>
  ilock(dp);
    80004d46:	d8afe0ef          	jal	800032d0 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80004d4a:	00003597          	auipc	a1,0x3
    80004d4e:	95e58593          	addi	a1,a1,-1698 # 800076a8 <etext+0x6a8>
    80004d52:	fb040513          	addi	a0,s0,-80
    80004d56:	9d9fe0ef          	jal	8000372e <namecmp>
    80004d5a:	10050e63          	beqz	a0,80004e76 <sys_unlink+0x160>
    80004d5e:	00003597          	auipc	a1,0x3
    80004d62:	95258593          	addi	a1,a1,-1710 # 800076b0 <etext+0x6b0>
    80004d66:	fb040513          	addi	a0,s0,-80
    80004d6a:	9c5fe0ef          	jal	8000372e <namecmp>
    80004d6e:	10050463          	beqz	a0,80004e76 <sys_unlink+0x160>
    80004d72:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    80004d74:	f2c40613          	addi	a2,s0,-212
    80004d78:	fb040593          	addi	a1,s0,-80
    80004d7c:	8526                	mv	a0,s1
    80004d7e:	9c7fe0ef          	jal	80003744 <dirlookup>
    80004d82:	892a                	mv	s2,a0
    80004d84:	0e050863          	beqz	a0,80004e74 <sys_unlink+0x15e>
  ilock(ip);
    80004d88:	d48fe0ef          	jal	800032d0 <ilock>
  if(ip->nlink < 1)
    80004d8c:	04a91783          	lh	a5,74(s2)
    80004d90:	06f05763          	blez	a5,80004dfe <sys_unlink+0xe8>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80004d94:	04491703          	lh	a4,68(s2)
    80004d98:	4785                	li	a5,1
    80004d9a:	06f70963          	beq	a4,a5,80004e0c <sys_unlink+0xf6>
  memset(&de, 0, sizeof(de));
    80004d9e:	4641                	li	a2,16
    80004da0:	4581                	li	a1,0
    80004da2:	fc040513          	addi	a0,s0,-64
    80004da6:	f23fb0ef          	jal	80000cc8 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004daa:	4741                	li	a4,16
    80004dac:	f2c42683          	lw	a3,-212(s0)
    80004db0:	fc040613          	addi	a2,s0,-64
    80004db4:	4581                	li	a1,0
    80004db6:	8526                	mv	a0,s1
    80004db8:	869fe0ef          	jal	80003620 <writei>
    80004dbc:	47c1                	li	a5,16
    80004dbe:	08f51b63          	bne	a0,a5,80004e54 <sys_unlink+0x13e>
  if(ip->type == T_DIR){
    80004dc2:	04491703          	lh	a4,68(s2)
    80004dc6:	4785                	li	a5,1
    80004dc8:	08f70d63          	beq	a4,a5,80004e62 <sys_unlink+0x14c>
  iunlockput(dp);
    80004dcc:	8526                	mv	a0,s1
    80004dce:	f0cfe0ef          	jal	800034da <iunlockput>
  ip->nlink--;
    80004dd2:	04a95783          	lhu	a5,74(s2)
    80004dd6:	37fd                	addiw	a5,a5,-1
    80004dd8:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80004ddc:	854a                	mv	a0,s2
    80004dde:	c3efe0ef          	jal	8000321c <iupdate>
  iunlockput(ip);
    80004de2:	854a                	mv	a0,s2
    80004de4:	ef6fe0ef          	jal	800034da <iunlockput>
  end_op();
    80004de8:	de9fe0ef          	jal	80003bd0 <end_op>
  return 0;
    80004dec:	4501                	li	a0,0
    80004dee:	64ee                	ld	s1,216(sp)
    80004df0:	694e                	ld	s2,208(sp)
    80004df2:	a849                	j	80004e84 <sys_unlink+0x16e>
    end_op();
    80004df4:	dddfe0ef          	jal	80003bd0 <end_op>
    return -1;
    80004df8:	557d                	li	a0,-1
    80004dfa:	64ee                	ld	s1,216(sp)
    80004dfc:	a061                	j	80004e84 <sys_unlink+0x16e>
    80004dfe:	e5ce                	sd	s3,200(sp)
    panic("unlink: nlink < 1");
    80004e00:	00003517          	auipc	a0,0x3
    80004e04:	8b850513          	addi	a0,a0,-1864 # 800076b8 <etext+0x6b8>
    80004e08:	98dfb0ef          	jal	80000794 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004e0c:	04c92703          	lw	a4,76(s2)
    80004e10:	02000793          	li	a5,32
    80004e14:	f8e7f5e3          	bgeu	a5,a4,80004d9e <sys_unlink+0x88>
    80004e18:	e5ce                	sd	s3,200(sp)
    80004e1a:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004e1e:	4741                	li	a4,16
    80004e20:	86ce                	mv	a3,s3
    80004e22:	f1840613          	addi	a2,s0,-232
    80004e26:	4581                	li	a1,0
    80004e28:	854a                	mv	a0,s2
    80004e2a:	efafe0ef          	jal	80003524 <readi>
    80004e2e:	47c1                	li	a5,16
    80004e30:	00f51c63          	bne	a0,a5,80004e48 <sys_unlink+0x132>
    if(de.inum != 0)
    80004e34:	f1845783          	lhu	a5,-232(s0)
    80004e38:	efa1                	bnez	a5,80004e90 <sys_unlink+0x17a>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004e3a:	29c1                	addiw	s3,s3,16
    80004e3c:	04c92783          	lw	a5,76(s2)
    80004e40:	fcf9efe3          	bltu	s3,a5,80004e1e <sys_unlink+0x108>
    80004e44:	69ae                	ld	s3,200(sp)
    80004e46:	bfa1                	j	80004d9e <sys_unlink+0x88>
      panic("isdirempty: readi");
    80004e48:	00003517          	auipc	a0,0x3
    80004e4c:	88850513          	addi	a0,a0,-1912 # 800076d0 <etext+0x6d0>
    80004e50:	945fb0ef          	jal	80000794 <panic>
    80004e54:	e5ce                	sd	s3,200(sp)
    panic("unlink: writei");
    80004e56:	00003517          	auipc	a0,0x3
    80004e5a:	89250513          	addi	a0,a0,-1902 # 800076e8 <etext+0x6e8>
    80004e5e:	937fb0ef          	jal	80000794 <panic>
    dp->nlink--;
    80004e62:	04a4d783          	lhu	a5,74(s1)
    80004e66:	37fd                	addiw	a5,a5,-1
    80004e68:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004e6c:	8526                	mv	a0,s1
    80004e6e:	baefe0ef          	jal	8000321c <iupdate>
    80004e72:	bfa9                	j	80004dcc <sys_unlink+0xb6>
    80004e74:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    80004e76:	8526                	mv	a0,s1
    80004e78:	e62fe0ef          	jal	800034da <iunlockput>
  end_op();
    80004e7c:	d55fe0ef          	jal	80003bd0 <end_op>
  return -1;
    80004e80:	557d                	li	a0,-1
    80004e82:	64ee                	ld	s1,216(sp)
}
    80004e84:	70ae                	ld	ra,232(sp)
    80004e86:	740e                	ld	s0,224(sp)
    80004e88:	616d                	addi	sp,sp,240
    80004e8a:	8082                	ret
    return -1;
    80004e8c:	557d                	li	a0,-1
    80004e8e:	bfdd                	j	80004e84 <sys_unlink+0x16e>
    iunlockput(ip);
    80004e90:	854a                	mv	a0,s2
    80004e92:	e48fe0ef          	jal	800034da <iunlockput>
    goto bad;
    80004e96:	694e                	ld	s2,208(sp)
    80004e98:	69ae                	ld	s3,200(sp)
    80004e9a:	bff1                	j	80004e76 <sys_unlink+0x160>

0000000080004e9c <sys_open>:

uint64
sys_open(void)
{
    80004e9c:	7131                	addi	sp,sp,-192
    80004e9e:	fd06                	sd	ra,184(sp)
    80004ea0:	f922                	sd	s0,176(sp)
    80004ea2:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80004ea4:	f4c40593          	addi	a1,s0,-180
    80004ea8:	4505                	li	a0,1
    80004eaa:	9e7fd0ef          	jal	80002890 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80004eae:	08000613          	li	a2,128
    80004eb2:	f5040593          	addi	a1,s0,-176
    80004eb6:	4501                	li	a0,0
    80004eb8:	a11fd0ef          	jal	800028c8 <argstr>
    80004ebc:	87aa                	mv	a5,a0
    return -1;
    80004ebe:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80004ec0:	0a07c263          	bltz	a5,80004f64 <sys_open+0xc8>
    80004ec4:	f526                	sd	s1,168(sp)

  begin_op();
    80004ec6:	ca1fe0ef          	jal	80003b66 <begin_op>

  if(omode & O_CREATE){
    80004eca:	f4c42783          	lw	a5,-180(s0)
    80004ece:	2007f793          	andi	a5,a5,512
    80004ed2:	c3d5                	beqz	a5,80004f76 <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    80004ed4:	4681                	li	a3,0
    80004ed6:	4601                	li	a2,0
    80004ed8:	4589                	li	a1,2
    80004eda:	f5040513          	addi	a0,s0,-176
    80004ede:	aa9ff0ef          	jal	80004986 <create>
    80004ee2:	84aa                	mv	s1,a0
    if(ip == 0){
    80004ee4:	c541                	beqz	a0,80004f6c <sys_open+0xd0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80004ee6:	04449703          	lh	a4,68(s1)
    80004eea:	478d                	li	a5,3
    80004eec:	00f71763          	bne	a4,a5,80004efa <sys_open+0x5e>
    80004ef0:	0464d703          	lhu	a4,70(s1)
    80004ef4:	47a5                	li	a5,9
    80004ef6:	0ae7ed63          	bltu	a5,a4,80004fb0 <sys_open+0x114>
    80004efa:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80004efc:	fe1fe0ef          	jal	80003edc <filealloc>
    80004f00:	892a                	mv	s2,a0
    80004f02:	c179                	beqz	a0,80004fc8 <sys_open+0x12c>
    80004f04:	ed4e                	sd	s3,152(sp)
    80004f06:	a43ff0ef          	jal	80004948 <fdalloc>
    80004f0a:	89aa                	mv	s3,a0
    80004f0c:	0a054a63          	bltz	a0,80004fc0 <sys_open+0x124>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80004f10:	04449703          	lh	a4,68(s1)
    80004f14:	478d                	li	a5,3
    80004f16:	0cf70263          	beq	a4,a5,80004fda <sys_open+0x13e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80004f1a:	4789                	li	a5,2
    80004f1c:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80004f20:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80004f24:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    80004f28:	f4c42783          	lw	a5,-180(s0)
    80004f2c:	0017c713          	xori	a4,a5,1
    80004f30:	8b05                	andi	a4,a4,1
    80004f32:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80004f36:	0037f713          	andi	a4,a5,3
    80004f3a:	00e03733          	snez	a4,a4
    80004f3e:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80004f42:	4007f793          	andi	a5,a5,1024
    80004f46:	c791                	beqz	a5,80004f52 <sys_open+0xb6>
    80004f48:	04449703          	lh	a4,68(s1)
    80004f4c:	4789                	li	a5,2
    80004f4e:	08f70d63          	beq	a4,a5,80004fe8 <sys_open+0x14c>
    itrunc(ip);
  }

  iunlock(ip);
    80004f52:	8526                	mv	a0,s1
    80004f54:	c2afe0ef          	jal	8000337e <iunlock>
  end_op();
    80004f58:	c79fe0ef          	jal	80003bd0 <end_op>

  return fd;
    80004f5c:	854e                	mv	a0,s3
    80004f5e:	74aa                	ld	s1,168(sp)
    80004f60:	790a                	ld	s2,160(sp)
    80004f62:	69ea                	ld	s3,152(sp)
}
    80004f64:	70ea                	ld	ra,184(sp)
    80004f66:	744a                	ld	s0,176(sp)
    80004f68:	6129                	addi	sp,sp,192
    80004f6a:	8082                	ret
      end_op();
    80004f6c:	c65fe0ef          	jal	80003bd0 <end_op>
      return -1;
    80004f70:	557d                	li	a0,-1
    80004f72:	74aa                	ld	s1,168(sp)
    80004f74:	bfc5                	j	80004f64 <sys_open+0xc8>
    if((ip = namei(path)) == 0){
    80004f76:	f5040513          	addi	a0,s0,-176
    80004f7a:	a31fe0ef          	jal	800039aa <namei>
    80004f7e:	84aa                	mv	s1,a0
    80004f80:	c11d                	beqz	a0,80004fa6 <sys_open+0x10a>
    ilock(ip);
    80004f82:	b4efe0ef          	jal	800032d0 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80004f86:	04449703          	lh	a4,68(s1)
    80004f8a:	4785                	li	a5,1
    80004f8c:	f4f71de3          	bne	a4,a5,80004ee6 <sys_open+0x4a>
    80004f90:	f4c42783          	lw	a5,-180(s0)
    80004f94:	d3bd                	beqz	a5,80004efa <sys_open+0x5e>
      iunlockput(ip);
    80004f96:	8526                	mv	a0,s1
    80004f98:	d42fe0ef          	jal	800034da <iunlockput>
      end_op();
    80004f9c:	c35fe0ef          	jal	80003bd0 <end_op>
      return -1;
    80004fa0:	557d                	li	a0,-1
    80004fa2:	74aa                	ld	s1,168(sp)
    80004fa4:	b7c1                	j	80004f64 <sys_open+0xc8>
      end_op();
    80004fa6:	c2bfe0ef          	jal	80003bd0 <end_op>
      return -1;
    80004faa:	557d                	li	a0,-1
    80004fac:	74aa                	ld	s1,168(sp)
    80004fae:	bf5d                	j	80004f64 <sys_open+0xc8>
    iunlockput(ip);
    80004fb0:	8526                	mv	a0,s1
    80004fb2:	d28fe0ef          	jal	800034da <iunlockput>
    end_op();
    80004fb6:	c1bfe0ef          	jal	80003bd0 <end_op>
    return -1;
    80004fba:	557d                	li	a0,-1
    80004fbc:	74aa                	ld	s1,168(sp)
    80004fbe:	b75d                	j	80004f64 <sys_open+0xc8>
      fileclose(f);
    80004fc0:	854a                	mv	a0,s2
    80004fc2:	fbffe0ef          	jal	80003f80 <fileclose>
    80004fc6:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    80004fc8:	8526                	mv	a0,s1
    80004fca:	d10fe0ef          	jal	800034da <iunlockput>
    end_op();
    80004fce:	c03fe0ef          	jal	80003bd0 <end_op>
    return -1;
    80004fd2:	557d                	li	a0,-1
    80004fd4:	74aa                	ld	s1,168(sp)
    80004fd6:	790a                	ld	s2,160(sp)
    80004fd8:	b771                	j	80004f64 <sys_open+0xc8>
    f->type = FD_DEVICE;
    80004fda:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    80004fde:	04649783          	lh	a5,70(s1)
    80004fe2:	02f91223          	sh	a5,36(s2)
    80004fe6:	bf3d                	j	80004f24 <sys_open+0x88>
    itrunc(ip);
    80004fe8:	8526                	mv	a0,s1
    80004fea:	bd4fe0ef          	jal	800033be <itrunc>
    80004fee:	b795                	j	80004f52 <sys_open+0xb6>

0000000080004ff0 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80004ff0:	7175                	addi	sp,sp,-144
    80004ff2:	e506                	sd	ra,136(sp)
    80004ff4:	e122                	sd	s0,128(sp)
    80004ff6:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80004ff8:	b6ffe0ef          	jal	80003b66 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80004ffc:	08000613          	li	a2,128
    80005000:	f7040593          	addi	a1,s0,-144
    80005004:	4501                	li	a0,0
    80005006:	8c3fd0ef          	jal	800028c8 <argstr>
    8000500a:	02054363          	bltz	a0,80005030 <sys_mkdir+0x40>
    8000500e:	4681                	li	a3,0
    80005010:	4601                	li	a2,0
    80005012:	4585                	li	a1,1
    80005014:	f7040513          	addi	a0,s0,-144
    80005018:	96fff0ef          	jal	80004986 <create>
    8000501c:	c911                	beqz	a0,80005030 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000501e:	cbcfe0ef          	jal	800034da <iunlockput>
  end_op();
    80005022:	baffe0ef          	jal	80003bd0 <end_op>
  return 0;
    80005026:	4501                	li	a0,0
}
    80005028:	60aa                	ld	ra,136(sp)
    8000502a:	640a                	ld	s0,128(sp)
    8000502c:	6149                	addi	sp,sp,144
    8000502e:	8082                	ret
    end_op();
    80005030:	ba1fe0ef          	jal	80003bd0 <end_op>
    return -1;
    80005034:	557d                	li	a0,-1
    80005036:	bfcd                	j	80005028 <sys_mkdir+0x38>

0000000080005038 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005038:	7135                	addi	sp,sp,-160
    8000503a:	ed06                	sd	ra,152(sp)
    8000503c:	e922                	sd	s0,144(sp)
    8000503e:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005040:	b27fe0ef          	jal	80003b66 <begin_op>
  argint(1, &major);
    80005044:	f6c40593          	addi	a1,s0,-148
    80005048:	4505                	li	a0,1
    8000504a:	847fd0ef          	jal	80002890 <argint>
  argint(2, &minor);
    8000504e:	f6840593          	addi	a1,s0,-152
    80005052:	4509                	li	a0,2
    80005054:	83dfd0ef          	jal	80002890 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005058:	08000613          	li	a2,128
    8000505c:	f7040593          	addi	a1,s0,-144
    80005060:	4501                	li	a0,0
    80005062:	867fd0ef          	jal	800028c8 <argstr>
    80005066:	02054563          	bltz	a0,80005090 <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    8000506a:	f6841683          	lh	a3,-152(s0)
    8000506e:	f6c41603          	lh	a2,-148(s0)
    80005072:	458d                	li	a1,3
    80005074:	f7040513          	addi	a0,s0,-144
    80005078:	90fff0ef          	jal	80004986 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000507c:	c911                	beqz	a0,80005090 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000507e:	c5cfe0ef          	jal	800034da <iunlockput>
  end_op();
    80005082:	b4ffe0ef          	jal	80003bd0 <end_op>
  return 0;
    80005086:	4501                	li	a0,0
}
    80005088:	60ea                	ld	ra,152(sp)
    8000508a:	644a                	ld	s0,144(sp)
    8000508c:	610d                	addi	sp,sp,160
    8000508e:	8082                	ret
    end_op();
    80005090:	b41fe0ef          	jal	80003bd0 <end_op>
    return -1;
    80005094:	557d                	li	a0,-1
    80005096:	bfcd                	j	80005088 <sys_mknod+0x50>

0000000080005098 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005098:	7135                	addi	sp,sp,-160
    8000509a:	ed06                	sd	ra,152(sp)
    8000509c:	e922                	sd	s0,144(sp)
    8000509e:	e14a                	sd	s2,128(sp)
    800050a0:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800050a2:	83ffc0ef          	jal	800018e0 <myproc>
    800050a6:	892a                	mv	s2,a0
  
  begin_op();
    800050a8:	abffe0ef          	jal	80003b66 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    800050ac:	08000613          	li	a2,128
    800050b0:	f6040593          	addi	a1,s0,-160
    800050b4:	4501                	li	a0,0
    800050b6:	813fd0ef          	jal	800028c8 <argstr>
    800050ba:	04054363          	bltz	a0,80005100 <sys_chdir+0x68>
    800050be:	e526                	sd	s1,136(sp)
    800050c0:	f6040513          	addi	a0,s0,-160
    800050c4:	8e7fe0ef          	jal	800039aa <namei>
    800050c8:	84aa                	mv	s1,a0
    800050ca:	c915                	beqz	a0,800050fe <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    800050cc:	a04fe0ef          	jal	800032d0 <ilock>
  if(ip->type != T_DIR){
    800050d0:	04449703          	lh	a4,68(s1)
    800050d4:	4785                	li	a5,1
    800050d6:	02f71963          	bne	a4,a5,80005108 <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    800050da:	8526                	mv	a0,s1
    800050dc:	aa2fe0ef          	jal	8000337e <iunlock>
  iput(p->cwd);
    800050e0:	15093503          	ld	a0,336(s2)
    800050e4:	b6efe0ef          	jal	80003452 <iput>
  end_op();
    800050e8:	ae9fe0ef          	jal	80003bd0 <end_op>
  p->cwd = ip;
    800050ec:	14993823          	sd	s1,336(s2)
  return 0;
    800050f0:	4501                	li	a0,0
    800050f2:	64aa                	ld	s1,136(sp)
}
    800050f4:	60ea                	ld	ra,152(sp)
    800050f6:	644a                	ld	s0,144(sp)
    800050f8:	690a                	ld	s2,128(sp)
    800050fa:	610d                	addi	sp,sp,160
    800050fc:	8082                	ret
    800050fe:	64aa                	ld	s1,136(sp)
    end_op();
    80005100:	ad1fe0ef          	jal	80003bd0 <end_op>
    return -1;
    80005104:	557d                	li	a0,-1
    80005106:	b7fd                	j	800050f4 <sys_chdir+0x5c>
    iunlockput(ip);
    80005108:	8526                	mv	a0,s1
    8000510a:	bd0fe0ef          	jal	800034da <iunlockput>
    end_op();
    8000510e:	ac3fe0ef          	jal	80003bd0 <end_op>
    return -1;
    80005112:	557d                	li	a0,-1
    80005114:	64aa                	ld	s1,136(sp)
    80005116:	bff9                	j	800050f4 <sys_chdir+0x5c>

0000000080005118 <sys_exec>:

uint64
sys_exec(void)
{
    80005118:	7121                	addi	sp,sp,-448
    8000511a:	ff06                	sd	ra,440(sp)
    8000511c:	fb22                	sd	s0,432(sp)
    8000511e:	0380                	addi	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005120:	e4840593          	addi	a1,s0,-440
    80005124:	4505                	li	a0,1
    80005126:	f86fd0ef          	jal	800028ac <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    8000512a:	08000613          	li	a2,128
    8000512e:	f5040593          	addi	a1,s0,-176
    80005132:	4501                	li	a0,0
    80005134:	f94fd0ef          	jal	800028c8 <argstr>
    80005138:	87aa                	mv	a5,a0
    return -1;
    8000513a:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    8000513c:	0c07c463          	bltz	a5,80005204 <sys_exec+0xec>
    80005140:	f726                	sd	s1,424(sp)
    80005142:	f34a                	sd	s2,416(sp)
    80005144:	ef4e                	sd	s3,408(sp)
    80005146:	eb52                	sd	s4,400(sp)
  }
  memset(argv, 0, sizeof(argv));
    80005148:	10000613          	li	a2,256
    8000514c:	4581                	li	a1,0
    8000514e:	e5040513          	addi	a0,s0,-432
    80005152:	b77fb0ef          	jal	80000cc8 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005156:	e5040493          	addi	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    8000515a:	89a6                	mv	s3,s1
    8000515c:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    8000515e:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005162:	00391513          	slli	a0,s2,0x3
    80005166:	e4040593          	addi	a1,s0,-448
    8000516a:	e4843783          	ld	a5,-440(s0)
    8000516e:	953e                	add	a0,a0,a5
    80005170:	e96fd0ef          	jal	80002806 <fetchaddr>
    80005174:	02054663          	bltz	a0,800051a0 <sys_exec+0x88>
      goto bad;
    }
    if(uarg == 0){
    80005178:	e4043783          	ld	a5,-448(s0)
    8000517c:	c3a9                	beqz	a5,800051be <sys_exec+0xa6>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    8000517e:	9a7fb0ef          	jal	80000b24 <kalloc>
    80005182:	85aa                	mv	a1,a0
    80005184:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005188:	cd01                	beqz	a0,800051a0 <sys_exec+0x88>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    8000518a:	6605                	lui	a2,0x1
    8000518c:	e4043503          	ld	a0,-448(s0)
    80005190:	ec0fd0ef          	jal	80002850 <fetchstr>
    80005194:	00054663          	bltz	a0,800051a0 <sys_exec+0x88>
    if(i >= NELEM(argv)){
    80005198:	0905                	addi	s2,s2,1
    8000519a:	09a1                	addi	s3,s3,8
    8000519c:	fd4913e3          	bne	s2,s4,80005162 <sys_exec+0x4a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800051a0:	f5040913          	addi	s2,s0,-176
    800051a4:	6088                	ld	a0,0(s1)
    800051a6:	c931                	beqz	a0,800051fa <sys_exec+0xe2>
    kfree(argv[i]);
    800051a8:	89bfb0ef          	jal	80000a42 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800051ac:	04a1                	addi	s1,s1,8
    800051ae:	ff249be3          	bne	s1,s2,800051a4 <sys_exec+0x8c>
  return -1;
    800051b2:	557d                	li	a0,-1
    800051b4:	74ba                	ld	s1,424(sp)
    800051b6:	791a                	ld	s2,416(sp)
    800051b8:	69fa                	ld	s3,408(sp)
    800051ba:	6a5a                	ld	s4,400(sp)
    800051bc:	a0a1                	j	80005204 <sys_exec+0xec>
      argv[i] = 0;
    800051be:	0009079b          	sext.w	a5,s2
    800051c2:	078e                	slli	a5,a5,0x3
    800051c4:	fd078793          	addi	a5,a5,-48
    800051c8:	97a2                	add	a5,a5,s0
    800051ca:	e807b023          	sd	zero,-384(a5)
  int ret = exec(path, argv);
    800051ce:	e5040593          	addi	a1,s0,-432
    800051d2:	f5040513          	addi	a0,s0,-176
    800051d6:	ba8ff0ef          	jal	8000457e <exec>
    800051da:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800051dc:	f5040993          	addi	s3,s0,-176
    800051e0:	6088                	ld	a0,0(s1)
    800051e2:	c511                	beqz	a0,800051ee <sys_exec+0xd6>
    kfree(argv[i]);
    800051e4:	85ffb0ef          	jal	80000a42 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800051e8:	04a1                	addi	s1,s1,8
    800051ea:	ff349be3          	bne	s1,s3,800051e0 <sys_exec+0xc8>
  return ret;
    800051ee:	854a                	mv	a0,s2
    800051f0:	74ba                	ld	s1,424(sp)
    800051f2:	791a                	ld	s2,416(sp)
    800051f4:	69fa                	ld	s3,408(sp)
    800051f6:	6a5a                	ld	s4,400(sp)
    800051f8:	a031                	j	80005204 <sys_exec+0xec>
  return -1;
    800051fa:	557d                	li	a0,-1
    800051fc:	74ba                	ld	s1,424(sp)
    800051fe:	791a                	ld	s2,416(sp)
    80005200:	69fa                	ld	s3,408(sp)
    80005202:	6a5a                	ld	s4,400(sp)
}
    80005204:	70fa                	ld	ra,440(sp)
    80005206:	745a                	ld	s0,432(sp)
    80005208:	6139                	addi	sp,sp,448
    8000520a:	8082                	ret

000000008000520c <sys_pipe>:

uint64
sys_pipe(void)
{
    8000520c:	7139                	addi	sp,sp,-64
    8000520e:	fc06                	sd	ra,56(sp)
    80005210:	f822                	sd	s0,48(sp)
    80005212:	f426                	sd	s1,40(sp)
    80005214:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005216:	ecafc0ef          	jal	800018e0 <myproc>
    8000521a:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    8000521c:	fd840593          	addi	a1,s0,-40
    80005220:	4501                	li	a0,0
    80005222:	e8afd0ef          	jal	800028ac <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005226:	fc840593          	addi	a1,s0,-56
    8000522a:	fd040513          	addi	a0,s0,-48
    8000522e:	85cff0ef          	jal	8000428a <pipealloc>
    return -1;
    80005232:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005234:	0a054463          	bltz	a0,800052dc <sys_pipe+0xd0>
  fd0 = -1;
    80005238:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    8000523c:	fd043503          	ld	a0,-48(s0)
    80005240:	f08ff0ef          	jal	80004948 <fdalloc>
    80005244:	fca42223          	sw	a0,-60(s0)
    80005248:	08054163          	bltz	a0,800052ca <sys_pipe+0xbe>
    8000524c:	fc843503          	ld	a0,-56(s0)
    80005250:	ef8ff0ef          	jal	80004948 <fdalloc>
    80005254:	fca42023          	sw	a0,-64(s0)
    80005258:	06054063          	bltz	a0,800052b8 <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000525c:	4691                	li	a3,4
    8000525e:	fc440613          	addi	a2,s0,-60
    80005262:	fd843583          	ld	a1,-40(s0)
    80005266:	68a8                	ld	a0,80(s1)
    80005268:	aeafc0ef          	jal	80001552 <copyout>
    8000526c:	00054e63          	bltz	a0,80005288 <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005270:	4691                	li	a3,4
    80005272:	fc040613          	addi	a2,s0,-64
    80005276:	fd843583          	ld	a1,-40(s0)
    8000527a:	0591                	addi	a1,a1,4
    8000527c:	68a8                	ld	a0,80(s1)
    8000527e:	ad4fc0ef          	jal	80001552 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005282:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005284:	04055c63          	bgez	a0,800052dc <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    80005288:	fc442783          	lw	a5,-60(s0)
    8000528c:	07e9                	addi	a5,a5,26
    8000528e:	078e                	slli	a5,a5,0x3
    80005290:	97a6                	add	a5,a5,s1
    80005292:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005296:	fc042783          	lw	a5,-64(s0)
    8000529a:	07e9                	addi	a5,a5,26
    8000529c:	078e                	slli	a5,a5,0x3
    8000529e:	94be                	add	s1,s1,a5
    800052a0:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    800052a4:	fd043503          	ld	a0,-48(s0)
    800052a8:	cd9fe0ef          	jal	80003f80 <fileclose>
    fileclose(wf);
    800052ac:	fc843503          	ld	a0,-56(s0)
    800052b0:	cd1fe0ef          	jal	80003f80 <fileclose>
    return -1;
    800052b4:	57fd                	li	a5,-1
    800052b6:	a01d                	j	800052dc <sys_pipe+0xd0>
    if(fd0 >= 0)
    800052b8:	fc442783          	lw	a5,-60(s0)
    800052bc:	0007c763          	bltz	a5,800052ca <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    800052c0:	07e9                	addi	a5,a5,26
    800052c2:	078e                	slli	a5,a5,0x3
    800052c4:	97a6                	add	a5,a5,s1
    800052c6:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    800052ca:	fd043503          	ld	a0,-48(s0)
    800052ce:	cb3fe0ef          	jal	80003f80 <fileclose>
    fileclose(wf);
    800052d2:	fc843503          	ld	a0,-56(s0)
    800052d6:	cabfe0ef          	jal	80003f80 <fileclose>
    return -1;
    800052da:	57fd                	li	a5,-1
}
    800052dc:	853e                	mv	a0,a5
    800052de:	70e2                	ld	ra,56(sp)
    800052e0:	7442                	ld	s0,48(sp)
    800052e2:	74a2                	ld	s1,40(sp)
    800052e4:	6121                	addi	sp,sp,64
    800052e6:	8082                	ret
	...

00000000800052f0 <kernelvec>:
    800052f0:	7111                	addi	sp,sp,-256
    800052f2:	e006                	sd	ra,0(sp)
    800052f4:	e40a                	sd	sp,8(sp)
    800052f6:	e80e                	sd	gp,16(sp)
    800052f8:	ec12                	sd	tp,24(sp)
    800052fa:	f016                	sd	t0,32(sp)
    800052fc:	f41a                	sd	t1,40(sp)
    800052fe:	f81e                	sd	t2,48(sp)
    80005300:	e4aa                	sd	a0,72(sp)
    80005302:	e8ae                	sd	a1,80(sp)
    80005304:	ecb2                	sd	a2,88(sp)
    80005306:	f0b6                	sd	a3,96(sp)
    80005308:	f4ba                	sd	a4,104(sp)
    8000530a:	f8be                	sd	a5,112(sp)
    8000530c:	fcc2                	sd	a6,120(sp)
    8000530e:	e146                	sd	a7,128(sp)
    80005310:	edf2                	sd	t3,216(sp)
    80005312:	f1f6                	sd	t4,224(sp)
    80005314:	f5fa                	sd	t5,232(sp)
    80005316:	f9fe                	sd	t6,240(sp)
    80005318:	bfefd0ef          	jal	80002716 <kerneltrap>
    8000531c:	6082                	ld	ra,0(sp)
    8000531e:	6122                	ld	sp,8(sp)
    80005320:	61c2                	ld	gp,16(sp)
    80005322:	7282                	ld	t0,32(sp)
    80005324:	7322                	ld	t1,40(sp)
    80005326:	73c2                	ld	t2,48(sp)
    80005328:	6526                	ld	a0,72(sp)
    8000532a:	65c6                	ld	a1,80(sp)
    8000532c:	6666                	ld	a2,88(sp)
    8000532e:	7686                	ld	a3,96(sp)
    80005330:	7726                	ld	a4,104(sp)
    80005332:	77c6                	ld	a5,112(sp)
    80005334:	7866                	ld	a6,120(sp)
    80005336:	688a                	ld	a7,128(sp)
    80005338:	6e6e                	ld	t3,216(sp)
    8000533a:	7e8e                	ld	t4,224(sp)
    8000533c:	7f2e                	ld	t5,232(sp)
    8000533e:	7fce                	ld	t6,240(sp)
    80005340:	6111                	addi	sp,sp,256
    80005342:	10200073          	sret
	...

000000008000534e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000534e:	1141                	addi	sp,sp,-16
    80005350:	e422                	sd	s0,8(sp)
    80005352:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005354:	0c0007b7          	lui	a5,0xc000
    80005358:	4705                	li	a4,1
    8000535a:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    8000535c:	0c0007b7          	lui	a5,0xc000
    80005360:	c3d8                	sw	a4,4(a5)
}
    80005362:	6422                	ld	s0,8(sp)
    80005364:	0141                	addi	sp,sp,16
    80005366:	8082                	ret

0000000080005368 <plicinithart>:

void
plicinithart(void)
{
    80005368:	1141                	addi	sp,sp,-16
    8000536a:	e406                	sd	ra,8(sp)
    8000536c:	e022                	sd	s0,0(sp)
    8000536e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005370:	d44fc0ef          	jal	800018b4 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005374:	0085171b          	slliw	a4,a0,0x8
    80005378:	0c0027b7          	lui	a5,0xc002
    8000537c:	97ba                	add	a5,a5,a4
    8000537e:	40200713          	li	a4,1026
    80005382:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005386:	00d5151b          	slliw	a0,a0,0xd
    8000538a:	0c2017b7          	lui	a5,0xc201
    8000538e:	97aa                	add	a5,a5,a0
    80005390:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005394:	60a2                	ld	ra,8(sp)
    80005396:	6402                	ld	s0,0(sp)
    80005398:	0141                	addi	sp,sp,16
    8000539a:	8082                	ret

000000008000539c <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    8000539c:	1141                	addi	sp,sp,-16
    8000539e:	e406                	sd	ra,8(sp)
    800053a0:	e022                	sd	s0,0(sp)
    800053a2:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800053a4:	d10fc0ef          	jal	800018b4 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    800053a8:	00d5151b          	slliw	a0,a0,0xd
    800053ac:	0c2017b7          	lui	a5,0xc201
    800053b0:	97aa                	add	a5,a5,a0
  return irq;
}
    800053b2:	43c8                	lw	a0,4(a5)
    800053b4:	60a2                	ld	ra,8(sp)
    800053b6:	6402                	ld	s0,0(sp)
    800053b8:	0141                	addi	sp,sp,16
    800053ba:	8082                	ret

00000000800053bc <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800053bc:	1101                	addi	sp,sp,-32
    800053be:	ec06                	sd	ra,24(sp)
    800053c0:	e822                	sd	s0,16(sp)
    800053c2:	e426                	sd	s1,8(sp)
    800053c4:	1000                	addi	s0,sp,32
    800053c6:	84aa                	mv	s1,a0
  int hart = cpuid();
    800053c8:	cecfc0ef          	jal	800018b4 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800053cc:	00d5151b          	slliw	a0,a0,0xd
    800053d0:	0c2017b7          	lui	a5,0xc201
    800053d4:	97aa                	add	a5,a5,a0
    800053d6:	c3c4                	sw	s1,4(a5)
}
    800053d8:	60e2                	ld	ra,24(sp)
    800053da:	6442                	ld	s0,16(sp)
    800053dc:	64a2                	ld	s1,8(sp)
    800053de:	6105                	addi	sp,sp,32
    800053e0:	8082                	ret

00000000800053e2 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800053e2:	1141                	addi	sp,sp,-16
    800053e4:	e406                	sd	ra,8(sp)
    800053e6:	e022                	sd	s0,0(sp)
    800053e8:	0800                	addi	s0,sp,16
  if(i >= NUM)
    800053ea:	479d                	li	a5,7
    800053ec:	04a7ca63          	blt	a5,a0,80005440 <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    800053f0:	0001e797          	auipc	a5,0x1e
    800053f4:	14078793          	addi	a5,a5,320 # 80023530 <disk>
    800053f8:	97aa                	add	a5,a5,a0
    800053fa:	0187c783          	lbu	a5,24(a5)
    800053fe:	e7b9                	bnez	a5,8000544c <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005400:	00451693          	slli	a3,a0,0x4
    80005404:	0001e797          	auipc	a5,0x1e
    80005408:	12c78793          	addi	a5,a5,300 # 80023530 <disk>
    8000540c:	6398                	ld	a4,0(a5)
    8000540e:	9736                	add	a4,a4,a3
    80005410:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80005414:	6398                	ld	a4,0(a5)
    80005416:	9736                	add	a4,a4,a3
    80005418:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    8000541c:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005420:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005424:	97aa                	add	a5,a5,a0
    80005426:	4705                	li	a4,1
    80005428:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    8000542c:	0001e517          	auipc	a0,0x1e
    80005430:	11c50513          	addi	a0,a0,284 # 80023548 <disk+0x18>
    80005434:	ac7fc0ef          	jal	80001efa <wakeup>
}
    80005438:	60a2                	ld	ra,8(sp)
    8000543a:	6402                	ld	s0,0(sp)
    8000543c:	0141                	addi	sp,sp,16
    8000543e:	8082                	ret
    panic("free_desc 1");
    80005440:	00002517          	auipc	a0,0x2
    80005444:	2b850513          	addi	a0,a0,696 # 800076f8 <etext+0x6f8>
    80005448:	b4cfb0ef          	jal	80000794 <panic>
    panic("free_desc 2");
    8000544c:	00002517          	auipc	a0,0x2
    80005450:	2bc50513          	addi	a0,a0,700 # 80007708 <etext+0x708>
    80005454:	b40fb0ef          	jal	80000794 <panic>

0000000080005458 <virtio_disk_init>:
{
    80005458:	1101                	addi	sp,sp,-32
    8000545a:	ec06                	sd	ra,24(sp)
    8000545c:	e822                	sd	s0,16(sp)
    8000545e:	e426                	sd	s1,8(sp)
    80005460:	e04a                	sd	s2,0(sp)
    80005462:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005464:	00002597          	auipc	a1,0x2
    80005468:	2b458593          	addi	a1,a1,692 # 80007718 <etext+0x718>
    8000546c:	0001e517          	auipc	a0,0x1e
    80005470:	1ec50513          	addi	a0,a0,492 # 80023658 <disk+0x128>
    80005474:	f00fb0ef          	jal	80000b74 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005478:	100017b7          	lui	a5,0x10001
    8000547c:	4398                	lw	a4,0(a5)
    8000547e:	2701                	sext.w	a4,a4
    80005480:	747277b7          	lui	a5,0x74727
    80005484:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005488:	18f71063          	bne	a4,a5,80005608 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    8000548c:	100017b7          	lui	a5,0x10001
    80005490:	0791                	addi	a5,a5,4 # 10001004 <_entry-0x6fffeffc>
    80005492:	439c                	lw	a5,0(a5)
    80005494:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005496:	4709                	li	a4,2
    80005498:	16e79863          	bne	a5,a4,80005608 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000549c:	100017b7          	lui	a5,0x10001
    800054a0:	07a1                	addi	a5,a5,8 # 10001008 <_entry-0x6fffeff8>
    800054a2:	439c                	lw	a5,0(a5)
    800054a4:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800054a6:	16e79163          	bne	a5,a4,80005608 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800054aa:	100017b7          	lui	a5,0x10001
    800054ae:	47d8                	lw	a4,12(a5)
    800054b0:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800054b2:	554d47b7          	lui	a5,0x554d4
    800054b6:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800054ba:	14f71763          	bne	a4,a5,80005608 <virtio_disk_init+0x1b0>
  *R(VIRTIO_MMIO_STATUS) = status;
    800054be:	100017b7          	lui	a5,0x10001
    800054c2:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    800054c6:	4705                	li	a4,1
    800054c8:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800054ca:	470d                	li	a4,3
    800054cc:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800054ce:	10001737          	lui	a4,0x10001
    800054d2:	4b14                	lw	a3,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800054d4:	c7ffe737          	lui	a4,0xc7ffe
    800054d8:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fdb0ef>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800054dc:	8ef9                	and	a3,a3,a4
    800054de:	10001737          	lui	a4,0x10001
    800054e2:	d314                	sw	a3,32(a4)
  *R(VIRTIO_MMIO_STATUS) = status;
    800054e4:	472d                	li	a4,11
    800054e6:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800054e8:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    800054ec:	439c                	lw	a5,0(a5)
    800054ee:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    800054f2:	8ba1                	andi	a5,a5,8
    800054f4:	12078063          	beqz	a5,80005614 <virtio_disk_init+0x1bc>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800054f8:	100017b7          	lui	a5,0x10001
    800054fc:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80005500:	100017b7          	lui	a5,0x10001
    80005504:	04478793          	addi	a5,a5,68 # 10001044 <_entry-0x6fffefbc>
    80005508:	439c                	lw	a5,0(a5)
    8000550a:	2781                	sext.w	a5,a5
    8000550c:	10079a63          	bnez	a5,80005620 <virtio_disk_init+0x1c8>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005510:	100017b7          	lui	a5,0x10001
    80005514:	03478793          	addi	a5,a5,52 # 10001034 <_entry-0x6fffefcc>
    80005518:	439c                	lw	a5,0(a5)
    8000551a:	2781                	sext.w	a5,a5
  if(max == 0)
    8000551c:	10078863          	beqz	a5,8000562c <virtio_disk_init+0x1d4>
  if(max < NUM)
    80005520:	471d                	li	a4,7
    80005522:	10f77b63          	bgeu	a4,a5,80005638 <virtio_disk_init+0x1e0>
  disk.desc = kalloc();
    80005526:	dfefb0ef          	jal	80000b24 <kalloc>
    8000552a:	0001e497          	auipc	s1,0x1e
    8000552e:	00648493          	addi	s1,s1,6 # 80023530 <disk>
    80005532:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005534:	df0fb0ef          	jal	80000b24 <kalloc>
    80005538:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000553a:	deafb0ef          	jal	80000b24 <kalloc>
    8000553e:	87aa                	mv	a5,a0
    80005540:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80005542:	6088                	ld	a0,0(s1)
    80005544:	10050063          	beqz	a0,80005644 <virtio_disk_init+0x1ec>
    80005548:	0001e717          	auipc	a4,0x1e
    8000554c:	ff073703          	ld	a4,-16(a4) # 80023538 <disk+0x8>
    80005550:	0e070a63          	beqz	a4,80005644 <virtio_disk_init+0x1ec>
    80005554:	0e078863          	beqz	a5,80005644 <virtio_disk_init+0x1ec>
  memset(disk.desc, 0, PGSIZE);
    80005558:	6605                	lui	a2,0x1
    8000555a:	4581                	li	a1,0
    8000555c:	f6cfb0ef          	jal	80000cc8 <memset>
  memset(disk.avail, 0, PGSIZE);
    80005560:	0001e497          	auipc	s1,0x1e
    80005564:	fd048493          	addi	s1,s1,-48 # 80023530 <disk>
    80005568:	6605                	lui	a2,0x1
    8000556a:	4581                	li	a1,0
    8000556c:	6488                	ld	a0,8(s1)
    8000556e:	f5afb0ef          	jal	80000cc8 <memset>
  memset(disk.used, 0, PGSIZE);
    80005572:	6605                	lui	a2,0x1
    80005574:	4581                	li	a1,0
    80005576:	6888                	ld	a0,16(s1)
    80005578:	f50fb0ef          	jal	80000cc8 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    8000557c:	100017b7          	lui	a5,0x10001
    80005580:	4721                	li	a4,8
    80005582:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005584:	4098                	lw	a4,0(s1)
    80005586:	100017b7          	lui	a5,0x10001
    8000558a:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    8000558e:	40d8                	lw	a4,4(s1)
    80005590:	100017b7          	lui	a5,0x10001
    80005594:	08e7a223          	sw	a4,132(a5) # 10001084 <_entry-0x6fffef7c>
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80005598:	649c                	ld	a5,8(s1)
    8000559a:	0007869b          	sext.w	a3,a5
    8000559e:	10001737          	lui	a4,0x10001
    800055a2:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    800055a6:	9781                	srai	a5,a5,0x20
    800055a8:	10001737          	lui	a4,0x10001
    800055ac:	08f72a23          	sw	a5,148(a4) # 10001094 <_entry-0x6fffef6c>
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    800055b0:	689c                	ld	a5,16(s1)
    800055b2:	0007869b          	sext.w	a3,a5
    800055b6:	10001737          	lui	a4,0x10001
    800055ba:	0ad72023          	sw	a3,160(a4) # 100010a0 <_entry-0x6fffef60>
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    800055be:	9781                	srai	a5,a5,0x20
    800055c0:	10001737          	lui	a4,0x10001
    800055c4:	0af72223          	sw	a5,164(a4) # 100010a4 <_entry-0x6fffef5c>
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    800055c8:	10001737          	lui	a4,0x10001
    800055cc:	4785                	li	a5,1
    800055ce:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    800055d0:	00f48c23          	sb	a5,24(s1)
    800055d4:	00f48ca3          	sb	a5,25(s1)
    800055d8:	00f48d23          	sb	a5,26(s1)
    800055dc:	00f48da3          	sb	a5,27(s1)
    800055e0:	00f48e23          	sb	a5,28(s1)
    800055e4:	00f48ea3          	sb	a5,29(s1)
    800055e8:	00f48f23          	sb	a5,30(s1)
    800055ec:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    800055f0:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    800055f4:	100017b7          	lui	a5,0x10001
    800055f8:	0727a823          	sw	s2,112(a5) # 10001070 <_entry-0x6fffef90>
}
    800055fc:	60e2                	ld	ra,24(sp)
    800055fe:	6442                	ld	s0,16(sp)
    80005600:	64a2                	ld	s1,8(sp)
    80005602:	6902                	ld	s2,0(sp)
    80005604:	6105                	addi	sp,sp,32
    80005606:	8082                	ret
    panic("could not find virtio disk");
    80005608:	00002517          	auipc	a0,0x2
    8000560c:	12050513          	addi	a0,a0,288 # 80007728 <etext+0x728>
    80005610:	984fb0ef          	jal	80000794 <panic>
    panic("virtio disk FEATURES_OK unset");
    80005614:	00002517          	auipc	a0,0x2
    80005618:	13450513          	addi	a0,a0,308 # 80007748 <etext+0x748>
    8000561c:	978fb0ef          	jal	80000794 <panic>
    panic("virtio disk should not be ready");
    80005620:	00002517          	auipc	a0,0x2
    80005624:	14850513          	addi	a0,a0,328 # 80007768 <etext+0x768>
    80005628:	96cfb0ef          	jal	80000794 <panic>
    panic("virtio disk has no queue 0");
    8000562c:	00002517          	auipc	a0,0x2
    80005630:	15c50513          	addi	a0,a0,348 # 80007788 <etext+0x788>
    80005634:	960fb0ef          	jal	80000794 <panic>
    panic("virtio disk max queue too short");
    80005638:	00002517          	auipc	a0,0x2
    8000563c:	17050513          	addi	a0,a0,368 # 800077a8 <etext+0x7a8>
    80005640:	954fb0ef          	jal	80000794 <panic>
    panic("virtio disk kalloc");
    80005644:	00002517          	auipc	a0,0x2
    80005648:	18450513          	addi	a0,a0,388 # 800077c8 <etext+0x7c8>
    8000564c:	948fb0ef          	jal	80000794 <panic>

0000000080005650 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005650:	7159                	addi	sp,sp,-112
    80005652:	f486                	sd	ra,104(sp)
    80005654:	f0a2                	sd	s0,96(sp)
    80005656:	eca6                	sd	s1,88(sp)
    80005658:	e8ca                	sd	s2,80(sp)
    8000565a:	e4ce                	sd	s3,72(sp)
    8000565c:	e0d2                	sd	s4,64(sp)
    8000565e:	fc56                	sd	s5,56(sp)
    80005660:	f85a                	sd	s6,48(sp)
    80005662:	f45e                	sd	s7,40(sp)
    80005664:	f062                	sd	s8,32(sp)
    80005666:	ec66                	sd	s9,24(sp)
    80005668:	1880                	addi	s0,sp,112
    8000566a:	8a2a                	mv	s4,a0
    8000566c:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    8000566e:	00c52c83          	lw	s9,12(a0)
    80005672:	001c9c9b          	slliw	s9,s9,0x1
    80005676:	1c82                	slli	s9,s9,0x20
    80005678:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    8000567c:	0001e517          	auipc	a0,0x1e
    80005680:	fdc50513          	addi	a0,a0,-36 # 80023658 <disk+0x128>
    80005684:	d70fb0ef          	jal	80000bf4 <acquire>
  for(int i = 0; i < 3; i++){
    80005688:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    8000568a:	44a1                	li	s1,8
      disk.free[i] = 0;
    8000568c:	0001eb17          	auipc	s6,0x1e
    80005690:	ea4b0b13          	addi	s6,s6,-348 # 80023530 <disk>
  for(int i = 0; i < 3; i++){
    80005694:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005696:	0001ec17          	auipc	s8,0x1e
    8000569a:	fc2c0c13          	addi	s8,s8,-62 # 80023658 <disk+0x128>
    8000569e:	a8b9                	j	800056fc <virtio_disk_rw+0xac>
      disk.free[i] = 0;
    800056a0:	00fb0733          	add	a4,s6,a5
    800056a4:	00070c23          	sb	zero,24(a4) # 10001018 <_entry-0x6fffefe8>
    idx[i] = alloc_desc();
    800056a8:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    800056aa:	0207c563          	bltz	a5,800056d4 <virtio_disk_rw+0x84>
  for(int i = 0; i < 3; i++){
    800056ae:	2905                	addiw	s2,s2,1
    800056b0:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    800056b2:	05590963          	beq	s2,s5,80005704 <virtio_disk_rw+0xb4>
    idx[i] = alloc_desc();
    800056b6:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    800056b8:	0001e717          	auipc	a4,0x1e
    800056bc:	e7870713          	addi	a4,a4,-392 # 80023530 <disk>
    800056c0:	87ce                	mv	a5,s3
    if(disk.free[i]){
    800056c2:	01874683          	lbu	a3,24(a4)
    800056c6:	fee9                	bnez	a3,800056a0 <virtio_disk_rw+0x50>
  for(int i = 0; i < NUM; i++){
    800056c8:	2785                	addiw	a5,a5,1
    800056ca:	0705                	addi	a4,a4,1
    800056cc:	fe979be3          	bne	a5,s1,800056c2 <virtio_disk_rw+0x72>
    idx[i] = alloc_desc();
    800056d0:	57fd                	li	a5,-1
    800056d2:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    800056d4:	01205d63          	blez	s2,800056ee <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    800056d8:	f9042503          	lw	a0,-112(s0)
    800056dc:	d07ff0ef          	jal	800053e2 <free_desc>
      for(int j = 0; j < i; j++)
    800056e0:	4785                	li	a5,1
    800056e2:	0127d663          	bge	a5,s2,800056ee <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    800056e6:	f9442503          	lw	a0,-108(s0)
    800056ea:	cf9ff0ef          	jal	800053e2 <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    800056ee:	85e2                	mv	a1,s8
    800056f0:	0001e517          	auipc	a0,0x1e
    800056f4:	e5850513          	addi	a0,a0,-424 # 80023548 <disk+0x18>
    800056f8:	fb6fc0ef          	jal	80001eae <sleep>
  for(int i = 0; i < 3; i++){
    800056fc:	f9040613          	addi	a2,s0,-112
    80005700:	894e                	mv	s2,s3
    80005702:	bf55                	j	800056b6 <virtio_disk_rw+0x66>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005704:	f9042503          	lw	a0,-112(s0)
    80005708:	00451693          	slli	a3,a0,0x4

  if(write)
    8000570c:	0001e797          	auipc	a5,0x1e
    80005710:	e2478793          	addi	a5,a5,-476 # 80023530 <disk>
    80005714:	00a50713          	addi	a4,a0,10
    80005718:	0712                	slli	a4,a4,0x4
    8000571a:	973e                	add	a4,a4,a5
    8000571c:	01703633          	snez	a2,s7
    80005720:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80005722:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80005726:	01973823          	sd	s9,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    8000572a:	6398                	ld	a4,0(a5)
    8000572c:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    8000572e:	0a868613          	addi	a2,a3,168
    80005732:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80005734:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005736:	6390                	ld	a2,0(a5)
    80005738:	00d605b3          	add	a1,a2,a3
    8000573c:	4741                	li	a4,16
    8000573e:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005740:	4805                	li	a6,1
    80005742:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    80005746:	f9442703          	lw	a4,-108(s0)
    8000574a:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64) b->data;
    8000574e:	0712                	slli	a4,a4,0x4
    80005750:	963a                	add	a2,a2,a4
    80005752:	058a0593          	addi	a1,s4,88
    80005756:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80005758:	0007b883          	ld	a7,0(a5)
    8000575c:	9746                	add	a4,a4,a7
    8000575e:	40000613          	li	a2,1024
    80005762:	c710                	sw	a2,8(a4)
  if(write)
    80005764:	001bb613          	seqz	a2,s7
    80005768:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000576c:	00166613          	ori	a2,a2,1
    80005770:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80005774:	f9842583          	lw	a1,-104(s0)
    80005778:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    8000577c:	00250613          	addi	a2,a0,2
    80005780:	0612                	slli	a2,a2,0x4
    80005782:	963e                	add	a2,a2,a5
    80005784:	577d                	li	a4,-1
    80005786:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    8000578a:	0592                	slli	a1,a1,0x4
    8000578c:	98ae                	add	a7,a7,a1
    8000578e:	03068713          	addi	a4,a3,48
    80005792:	973e                	add	a4,a4,a5
    80005794:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80005798:	6398                	ld	a4,0(a5)
    8000579a:	972e                	add	a4,a4,a1
    8000579c:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800057a0:	4689                	li	a3,2
    800057a2:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    800057a6:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800057aa:	010a2223          	sw	a6,4(s4)
  disk.info[idx[0]].b = b;
    800057ae:	01463423          	sd	s4,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    800057b2:	6794                	ld	a3,8(a5)
    800057b4:	0026d703          	lhu	a4,2(a3)
    800057b8:	8b1d                	andi	a4,a4,7
    800057ba:	0706                	slli	a4,a4,0x1
    800057bc:	96ba                	add	a3,a3,a4
    800057be:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    800057c2:	0330000f          	fence	rw,rw

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    800057c6:	6798                	ld	a4,8(a5)
    800057c8:	00275783          	lhu	a5,2(a4)
    800057cc:	2785                	addiw	a5,a5,1
    800057ce:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    800057d2:	0330000f          	fence	rw,rw

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800057d6:	100017b7          	lui	a5,0x10001
    800057da:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    800057de:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    800057e2:	0001e917          	auipc	s2,0x1e
    800057e6:	e7690913          	addi	s2,s2,-394 # 80023658 <disk+0x128>
  while(b->disk == 1) {
    800057ea:	4485                	li	s1,1
    800057ec:	01079a63          	bne	a5,a6,80005800 <virtio_disk_rw+0x1b0>
    sleep(b, &disk.vdisk_lock);
    800057f0:	85ca                	mv	a1,s2
    800057f2:	8552                	mv	a0,s4
    800057f4:	ebafc0ef          	jal	80001eae <sleep>
  while(b->disk == 1) {
    800057f8:	004a2783          	lw	a5,4(s4)
    800057fc:	fe978ae3          	beq	a5,s1,800057f0 <virtio_disk_rw+0x1a0>
  }

  disk.info[idx[0]].b = 0;
    80005800:	f9042903          	lw	s2,-112(s0)
    80005804:	00290713          	addi	a4,s2,2
    80005808:	0712                	slli	a4,a4,0x4
    8000580a:	0001e797          	auipc	a5,0x1e
    8000580e:	d2678793          	addi	a5,a5,-730 # 80023530 <disk>
    80005812:	97ba                	add	a5,a5,a4
    80005814:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80005818:	0001e997          	auipc	s3,0x1e
    8000581c:	d1898993          	addi	s3,s3,-744 # 80023530 <disk>
    80005820:	00491713          	slli	a4,s2,0x4
    80005824:	0009b783          	ld	a5,0(s3)
    80005828:	97ba                	add	a5,a5,a4
    8000582a:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    8000582e:	854a                	mv	a0,s2
    80005830:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005834:	bafff0ef          	jal	800053e2 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80005838:	8885                	andi	s1,s1,1
    8000583a:	f0fd                	bnez	s1,80005820 <virtio_disk_rw+0x1d0>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    8000583c:	0001e517          	auipc	a0,0x1e
    80005840:	e1c50513          	addi	a0,a0,-484 # 80023658 <disk+0x128>
    80005844:	c48fb0ef          	jal	80000c8c <release>
}
    80005848:	70a6                	ld	ra,104(sp)
    8000584a:	7406                	ld	s0,96(sp)
    8000584c:	64e6                	ld	s1,88(sp)
    8000584e:	6946                	ld	s2,80(sp)
    80005850:	69a6                	ld	s3,72(sp)
    80005852:	6a06                	ld	s4,64(sp)
    80005854:	7ae2                	ld	s5,56(sp)
    80005856:	7b42                	ld	s6,48(sp)
    80005858:	7ba2                	ld	s7,40(sp)
    8000585a:	7c02                	ld	s8,32(sp)
    8000585c:	6ce2                	ld	s9,24(sp)
    8000585e:	6165                	addi	sp,sp,112
    80005860:	8082                	ret

0000000080005862 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80005862:	1101                	addi	sp,sp,-32
    80005864:	ec06                	sd	ra,24(sp)
    80005866:	e822                	sd	s0,16(sp)
    80005868:	e426                	sd	s1,8(sp)
    8000586a:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    8000586c:	0001e497          	auipc	s1,0x1e
    80005870:	cc448493          	addi	s1,s1,-828 # 80023530 <disk>
    80005874:	0001e517          	auipc	a0,0x1e
    80005878:	de450513          	addi	a0,a0,-540 # 80023658 <disk+0x128>
    8000587c:	b78fb0ef          	jal	80000bf4 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80005880:	100017b7          	lui	a5,0x10001
    80005884:	53b8                	lw	a4,96(a5)
    80005886:	8b0d                	andi	a4,a4,3
    80005888:	100017b7          	lui	a5,0x10001
    8000588c:	d3f8                	sw	a4,100(a5)

  __sync_synchronize();
    8000588e:	0330000f          	fence	rw,rw

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80005892:	689c                	ld	a5,16(s1)
    80005894:	0204d703          	lhu	a4,32(s1)
    80005898:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    8000589c:	04f70663          	beq	a4,a5,800058e8 <virtio_disk_intr+0x86>
    __sync_synchronize();
    800058a0:	0330000f          	fence	rw,rw
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800058a4:	6898                	ld	a4,16(s1)
    800058a6:	0204d783          	lhu	a5,32(s1)
    800058aa:	8b9d                	andi	a5,a5,7
    800058ac:	078e                	slli	a5,a5,0x3
    800058ae:	97ba                	add	a5,a5,a4
    800058b0:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    800058b2:	00278713          	addi	a4,a5,2
    800058b6:	0712                	slli	a4,a4,0x4
    800058b8:	9726                	add	a4,a4,s1
    800058ba:	01074703          	lbu	a4,16(a4)
    800058be:	e321                	bnez	a4,800058fe <virtio_disk_intr+0x9c>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    800058c0:	0789                	addi	a5,a5,2
    800058c2:	0792                	slli	a5,a5,0x4
    800058c4:	97a6                	add	a5,a5,s1
    800058c6:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    800058c8:	00052223          	sw	zero,4(a0)
    wakeup(b);
    800058cc:	e2efc0ef          	jal	80001efa <wakeup>

    disk.used_idx += 1;
    800058d0:	0204d783          	lhu	a5,32(s1)
    800058d4:	2785                	addiw	a5,a5,1
    800058d6:	17c2                	slli	a5,a5,0x30
    800058d8:	93c1                	srli	a5,a5,0x30
    800058da:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    800058de:	6898                	ld	a4,16(s1)
    800058e0:	00275703          	lhu	a4,2(a4)
    800058e4:	faf71ee3          	bne	a4,a5,800058a0 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    800058e8:	0001e517          	auipc	a0,0x1e
    800058ec:	d7050513          	addi	a0,a0,-656 # 80023658 <disk+0x128>
    800058f0:	b9cfb0ef          	jal	80000c8c <release>
}
    800058f4:	60e2                	ld	ra,24(sp)
    800058f6:	6442                	ld	s0,16(sp)
    800058f8:	64a2                	ld	s1,8(sp)
    800058fa:	6105                	addi	sp,sp,32
    800058fc:	8082                	ret
      panic("virtio_disk_intr status");
    800058fe:	00002517          	auipc	a0,0x2
    80005902:	ee250513          	addi	a0,a0,-286 # 800077e0 <etext+0x7e0>
    80005906:	e8ffa0ef          	jal	80000794 <panic>
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
