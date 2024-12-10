
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	0000a117          	auipc	sp,0xa
    80000004:	40013103          	ld	sp,1024(sp) # 8000a400 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	04a000ef          	jal	80000060 <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
    80000022:	304027f3          	csrr	a5,mie
    80000026:	0207e793          	ori	a5,a5,32
    8000002a:	30479073          	csrw	mie,a5
    8000002e:	30a027f3          	csrr	a5,0x30a
    80000032:	577d                	li	a4,-1
    80000034:	177e                	slli	a4,a4,0x3f
    80000036:	8fd9                	or	a5,a5,a4
    80000038:	30a79073          	csrw	0x30a,a5
    8000003c:	306027f3          	csrr	a5,mcounteren
    80000040:	0027e793          	ori	a5,a5,2
    80000044:	30679073          	csrw	mcounteren,a5
    80000048:	c01027f3          	rdtime	a5
    8000004c:	000f4737          	lui	a4,0xf4
    80000050:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80000054:	97ba                	add	a5,a5,a4
    80000056:	14d79073          	csrw	stimecmp,a5
    8000005a:	6422                	ld	s0,8(sp)
    8000005c:	0141                	addi	sp,sp,16
    8000005e:	8082                	ret

0000000080000060 <start>:
    80000060:	1141                	addi	sp,sp,-16
    80000062:	e406                	sd	ra,8(sp)
    80000064:	e022                	sd	s0,0(sp)
    80000066:	0800                	addi	s0,sp,16
    80000068:	300027f3          	csrr	a5,mstatus
    8000006c:	7779                	lui	a4,0xffffe
    8000006e:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd5257>
    80000072:	8ff9                	and	a5,a5,a4
    80000074:	6705                	lui	a4,0x1
    80000076:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    8000007a:	8fd9                	or	a5,a5,a4
    8000007c:	30079073          	csrw	mstatus,a5
    80000080:	00001797          	auipc	a5,0x1
    80000084:	de278793          	addi	a5,a5,-542 # 80000e62 <main>
    80000088:	34179073          	csrw	mepc,a5
    8000008c:	4781                	li	a5,0
    8000008e:	18079073          	csrw	satp,a5
    80000092:	67c1                	lui	a5,0x10
    80000094:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    80000096:	30279073          	csrw	medeleg,a5
    8000009a:	30379073          	csrw	mideleg,a5
    8000009e:	104027f3          	csrr	a5,sie
    800000a2:	2227e793          	ori	a5,a5,546
    800000a6:	10479073          	csrw	sie,a5
    800000aa:	57fd                	li	a5,-1
    800000ac:	83a9                	srli	a5,a5,0xa
    800000ae:	3b079073          	csrw	pmpaddr0,a5
    800000b2:	47bd                	li	a5,15
    800000b4:	3a079073          	csrw	pmpcfg0,a5
    800000b8:	f65ff0ef          	jal	8000001c <timerinit>
    800000bc:	f14027f3          	csrr	a5,mhartid
    800000c0:	2781                	sext.w	a5,a5
    800000c2:	823e                	mv	tp,a5
    800000c4:	30200073          	mret
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
    80000158:	30c50513          	addi	a0,a0,780 # 80012460 <cons>
    8000015c:	299000ef          	jal	80000bf4 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80000160:	00012497          	auipc	s1,0x12
    80000164:	30048493          	addi	s1,s1,768 # 80012460 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    80000168:	00012917          	auipc	s2,0x12
    8000016c:	39090913          	addi	s2,s2,912 # 800124f8 <cons+0x98>
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
    800001a4:	2c070713          	addi	a4,a4,704 # 80012460 <cons>
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
    800001ee:	27650513          	addi	a0,a0,630 # 80012460 <cons>
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
    80000218:	2ef72223          	sw	a5,740(a4) # 800124f8 <cons+0x98>
    8000021c:	6be2                	ld	s7,24(sp)
    8000021e:	a031                	j	8000022a <consoleread+0xf4>
    80000220:	ec5e                	sd	s7,24(sp)
    80000222:	bfbd                	j	800001a0 <consoleread+0x6a>
    80000224:	6be2                	ld	s7,24(sp)
    80000226:	a011                	j	8000022a <consoleread+0xf4>
    80000228:	6be2                	ld	s7,24(sp)
  release(&cons.lock);
    8000022a:	00012517          	auipc	a0,0x12
    8000022e:	23650513          	addi	a0,a0,566 # 80012460 <cons>
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
    80000282:	1e250513          	addi	a0,a0,482 # 80012460 <cons>
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
    800002a8:	1bc50513          	addi	a0,a0,444 # 80012460 <cons>
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
    800002c6:	19e70713          	addi	a4,a4,414 # 80012460 <cons>
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
    800002ec:	17878793          	addi	a5,a5,376 # 80012460 <cons>
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
    8000031a:	1e27a783          	lw	a5,482(a5) # 800124f8 <cons+0x98>
    8000031e:	9f1d                	subw	a4,a4,a5
    80000320:	08000793          	li	a5,128
    80000324:	f8f710e3          	bne	a4,a5,800002a4 <consoleintr+0x32>
    80000328:	a07d                	j	800003d6 <consoleintr+0x164>
    8000032a:	e04a                	sd	s2,0(sp)
    while(cons.e != cons.w &&
    8000032c:	00012717          	auipc	a4,0x12
    80000330:	13470713          	addi	a4,a4,308 # 80012460 <cons>
    80000334:	0a072783          	lw	a5,160(a4)
    80000338:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    8000033c:	00012497          	auipc	s1,0x12
    80000340:	12448493          	addi	s1,s1,292 # 80012460 <cons>
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
    80000382:	0e270713          	addi	a4,a4,226 # 80012460 <cons>
    80000386:	0a072783          	lw	a5,160(a4)
    8000038a:	09c72703          	lw	a4,156(a4)
    8000038e:	f0f70be3          	beq	a4,a5,800002a4 <consoleintr+0x32>
      cons.e--;
    80000392:	37fd                	addiw	a5,a5,-1
    80000394:	00012717          	auipc	a4,0x12
    80000398:	16f72623          	sw	a5,364(a4) # 80012500 <cons+0xa0>
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
    800003b6:	0ae78793          	addi	a5,a5,174 # 80012460 <cons>
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
    800003da:	12c7a323          	sw	a2,294(a5) # 800124fc <cons+0x9c>
        wakeup(&cons.r);
    800003de:	00012517          	auipc	a0,0x12
    800003e2:	11a50513          	addi	a0,a0,282 # 800124f8 <cons+0x98>
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
    80000400:	06450513          	addi	a0,a0,100 # 80012460 <cons>
    80000404:	770000ef          	jal	80000b74 <initlock>

  uartinit();
    80000408:	3f4000ef          	jal	800007fc <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    8000040c:	00028797          	auipc	a5,0x28
    80000410:	00478793          	addi	a5,a5,4 # 80028410 <devsw>
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
    80000430:	7179                	addi	sp,sp,-48
    80000432:	f406                	sd	ra,40(sp)
    80000434:	f022                	sd	s0,32(sp)
    80000436:	1800                	addi	s0,sp,48
    80000438:	c219                	beqz	a2,8000043e <printint+0xe>
    8000043a:	08054063          	bltz	a0,800004ba <printint+0x8a>
    8000043e:	4881                	li	a7,0
    80000440:	fd040693          	addi	a3,s0,-48
    80000444:	4781                	li	a5,0
    80000446:	00007617          	auipc	a2,0x7
    8000044a:	3ea60613          	addi	a2,a2,1002 # 80007830 <digits>
    8000044e:	883e                	mv	a6,a5
    80000450:	2785                	addiw	a5,a5,1
    80000452:	02b57733          	remu	a4,a0,a1
    80000456:	9732                	add	a4,a4,a2
    80000458:	00074703          	lbu	a4,0(a4)
    8000045c:	00e68023          	sb	a4,0(a3)
    80000460:	872a                	mv	a4,a0
    80000462:	02b55533          	divu	a0,a0,a1
    80000466:	0685                	addi	a3,a3,1
    80000468:	feb773e3          	bgeu	a4,a1,8000044e <printint+0x1e>
    8000046c:	00088a63          	beqz	a7,80000480 <printint+0x50>
    80000470:	1781                	addi	a5,a5,-32
    80000472:	97a2                	add	a5,a5,s0
    80000474:	02d00713          	li	a4,45
    80000478:	fee78823          	sb	a4,-16(a5)
    8000047c:	0028079b          	addiw	a5,a6,2
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
    800004a0:	fff4c503          	lbu	a0,-1(s1)
    800004a4:	d9dff0ef          	jal	80000240 <consputc>
    800004a8:	14fd                	addi	s1,s1,-1
    800004aa:	ff249be3          	bne	s1,s2,800004a0 <printint+0x70>
    800004ae:	64e2                	ld	s1,24(sp)
    800004b0:	6942                	ld	s2,16(sp)
    800004b2:	70a2                	ld	ra,40(sp)
    800004b4:	7402                	ld	s0,32(sp)
    800004b6:	6145                	addi	sp,sp,48
    800004b8:	8082                	ret
    800004ba:	40a00533          	neg	a0,a0
    800004be:	4885                	li	a7,1
    800004c0:	b741                	j	80000440 <printint+0x10>

00000000800004c2 <printf>:
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
    800004e0:	00012797          	auipc	a5,0x12
    800004e4:	0407a783          	lw	a5,64(a5) # 80012520 <pr+0x18>
    800004e8:	f6f43c23          	sd	a5,-136(s0)
    800004ec:	e3a1                	bnez	a5,8000052c <printf+0x6a>
    800004ee:	00840793          	addi	a5,s0,8
    800004f2:	f8f43423          	sd	a5,-120(s0)
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
    80000512:	02500a93          	li	s5,37
    80000516:	06400b13          	li	s6,100
    8000051a:	06c00c13          	li	s8,108
    8000051e:	07500c93          	li	s9,117
    80000522:	07800d13          	li	s10,120
    80000526:	07000d93          	li	s11,112
    8000052a:	a815                	j	8000055e <printf+0x9c>
    8000052c:	00012517          	auipc	a0,0x12
    80000530:	fdc50513          	addi	a0,a0,-36 # 80012508 <pr>
    80000534:	6c0000ef          	jal	80000bf4 <acquire>
    80000538:	00840793          	addi	a5,s0,8
    8000053c:	f8f43423          	sd	a5,-120(s0)
    80000540:	000a4503          	lbu	a0,0(s4)
    80000544:	fd4d                	bnez	a0,800004fe <printf+0x3c>
    80000546:	a481                	j	80000786 <printf+0x2c4>
    80000548:	cf9ff0ef          	jal	80000240 <consputc>
    8000054c:	84ce                	mv	s1,s3
    8000054e:	0014899b          	addiw	s3,s1,1
    80000552:	013a07b3          	add	a5,s4,s3
    80000556:	0007c503          	lbu	a0,0(a5)
    8000055a:	1e050b63          	beqz	a0,80000750 <printf+0x28e>
    8000055e:	ff5515e3          	bne	a0,s5,80000548 <printf+0x86>
    80000562:	0019849b          	addiw	s1,s3,1
    80000566:	009a07b3          	add	a5,s4,s1
    8000056a:	0007c903          	lbu	s2,0(a5)
    8000056e:	1e090163          	beqz	s2,80000750 <printf+0x28e>
    80000572:	0017c783          	lbu	a5,1(a5)
    80000576:	86be                	mv	a3,a5
    80000578:	c789                	beqz	a5,80000582 <printf+0xc0>
    8000057a:	009a0733          	add	a4,s4,s1
    8000057e:	00274683          	lbu	a3,2(a4)
    80000582:	03690763          	beq	s2,s6,800005b0 <printf+0xee>
    80000586:	05890163          	beq	s2,s8,800005c8 <printf+0x106>
    8000058a:	0d990b63          	beq	s2,s9,80000660 <printf+0x19e>
    8000058e:	13a90163          	beq	s2,s10,800006b0 <printf+0x1ee>
    80000592:	13b90b63          	beq	s2,s11,800006c8 <printf+0x206>
    80000596:	07300793          	li	a5,115
    8000059a:	16f90a63          	beq	s2,a5,8000070e <printf+0x24c>
    8000059e:	1b590463          	beq	s2,s5,80000746 <printf+0x284>
    800005a2:	8556                	mv	a0,s5
    800005a4:	c9dff0ef          	jal	80000240 <consputc>
    800005a8:	854a                	mv	a0,s2
    800005aa:	c97ff0ef          	jal	80000240 <consputc>
    800005ae:	b745                	j	8000054e <printf+0x8c>
    800005b0:	f8843783          	ld	a5,-120(s0)
    800005b4:	00878713          	addi	a4,a5,8
    800005b8:	f8e43423          	sd	a4,-120(s0)
    800005bc:	4605                	li	a2,1
    800005be:	45a9                	li	a1,10
    800005c0:	4388                	lw	a0,0(a5)
    800005c2:	e6fff0ef          	jal	80000430 <printint>
    800005c6:	b761                	j	8000054e <printf+0x8c>
    800005c8:	03678663          	beq	a5,s6,800005f4 <printf+0x132>
    800005cc:	05878263          	beq	a5,s8,80000610 <printf+0x14e>
    800005d0:	0b978463          	beq	a5,s9,80000678 <printf+0x1b6>
    800005d4:	fda797e3          	bne	a5,s10,800005a2 <printf+0xe0>
    800005d8:	f8843783          	ld	a5,-120(s0)
    800005dc:	00878713          	addi	a4,a5,8
    800005e0:	f8e43423          	sd	a4,-120(s0)
    800005e4:	4601                	li	a2,0
    800005e6:	45c1                	li	a1,16
    800005e8:	6388                	ld	a0,0(a5)
    800005ea:	e47ff0ef          	jal	80000430 <printint>
    800005ee:	0029849b          	addiw	s1,s3,2
    800005f2:	bfb1                	j	8000054e <printf+0x8c>
    800005f4:	f8843783          	ld	a5,-120(s0)
    800005f8:	00878713          	addi	a4,a5,8
    800005fc:	f8e43423          	sd	a4,-120(s0)
    80000600:	4605                	li	a2,1
    80000602:	45a9                	li	a1,10
    80000604:	6388                	ld	a0,0(a5)
    80000606:	e2bff0ef          	jal	80000430 <printint>
    8000060a:	0029849b          	addiw	s1,s3,2
    8000060e:	b781                	j	8000054e <printf+0x8c>
    80000610:	06400793          	li	a5,100
    80000614:	02f68863          	beq	a3,a5,80000644 <printf+0x182>
    80000618:	07500793          	li	a5,117
    8000061c:	06f68c63          	beq	a3,a5,80000694 <printf+0x1d2>
    80000620:	07800793          	li	a5,120
    80000624:	f6f69fe3          	bne	a3,a5,800005a2 <printf+0xe0>
    80000628:	f8843783          	ld	a5,-120(s0)
    8000062c:	00878713          	addi	a4,a5,8
    80000630:	f8e43423          	sd	a4,-120(s0)
    80000634:	4601                	li	a2,0
    80000636:	45c1                	li	a1,16
    80000638:	6388                	ld	a0,0(a5)
    8000063a:	df7ff0ef          	jal	80000430 <printint>
    8000063e:	0039849b          	addiw	s1,s3,3
    80000642:	b731                	j	8000054e <printf+0x8c>
    80000644:	f8843783          	ld	a5,-120(s0)
    80000648:	00878713          	addi	a4,a5,8
    8000064c:	f8e43423          	sd	a4,-120(s0)
    80000650:	4605                	li	a2,1
    80000652:	45a9                	li	a1,10
    80000654:	6388                	ld	a0,0(a5)
    80000656:	ddbff0ef          	jal	80000430 <printint>
    8000065a:	0039849b          	addiw	s1,s3,3
    8000065e:	bdc5                	j	8000054e <printf+0x8c>
    80000660:	f8843783          	ld	a5,-120(s0)
    80000664:	00878713          	addi	a4,a5,8
    80000668:	f8e43423          	sd	a4,-120(s0)
    8000066c:	4601                	li	a2,0
    8000066e:	45a9                	li	a1,10
    80000670:	4388                	lw	a0,0(a5)
    80000672:	dbfff0ef          	jal	80000430 <printint>
    80000676:	bde1                	j	8000054e <printf+0x8c>
    80000678:	f8843783          	ld	a5,-120(s0)
    8000067c:	00878713          	addi	a4,a5,8
    80000680:	f8e43423          	sd	a4,-120(s0)
    80000684:	4601                	li	a2,0
    80000686:	45a9                	li	a1,10
    80000688:	6388                	ld	a0,0(a5)
    8000068a:	da7ff0ef          	jal	80000430 <printint>
    8000068e:	0029849b          	addiw	s1,s3,2
    80000692:	bd75                	j	8000054e <printf+0x8c>
    80000694:	f8843783          	ld	a5,-120(s0)
    80000698:	00878713          	addi	a4,a5,8
    8000069c:	f8e43423          	sd	a4,-120(s0)
    800006a0:	4601                	li	a2,0
    800006a2:	45a9                	li	a1,10
    800006a4:	6388                	ld	a0,0(a5)
    800006a6:	d8bff0ef          	jal	80000430 <printint>
    800006aa:	0039849b          	addiw	s1,s3,3
    800006ae:	b545                	j	8000054e <printf+0x8c>
    800006b0:	f8843783          	ld	a5,-120(s0)
    800006b4:	00878713          	addi	a4,a5,8
    800006b8:	f8e43423          	sd	a4,-120(s0)
    800006bc:	4601                	li	a2,0
    800006be:	45c1                	li	a1,16
    800006c0:	4388                	lw	a0,0(a5)
    800006c2:	d6fff0ef          	jal	80000430 <printint>
    800006c6:	b561                	j	8000054e <printf+0x8c>
    800006c8:	e4de                	sd	s7,72(sp)
    800006ca:	f8843783          	ld	a5,-120(s0)
    800006ce:	00878713          	addi	a4,a5,8
    800006d2:	f8e43423          	sd	a4,-120(s0)
    800006d6:	0007b983          	ld	s3,0(a5)
    800006da:	03000513          	li	a0,48
    800006de:	b63ff0ef          	jal	80000240 <consputc>
    800006e2:	07800513          	li	a0,120
    800006e6:	b5bff0ef          	jal	80000240 <consputc>
    800006ea:	4941                	li	s2,16
    800006ec:	00007b97          	auipc	s7,0x7
    800006f0:	144b8b93          	addi	s7,s7,324 # 80007830 <digits>
    800006f4:	03c9d793          	srli	a5,s3,0x3c
    800006f8:	97de                	add	a5,a5,s7
    800006fa:	0007c503          	lbu	a0,0(a5)
    800006fe:	b43ff0ef          	jal	80000240 <consputc>
    80000702:	0992                	slli	s3,s3,0x4
    80000704:	397d                	addiw	s2,s2,-1
    80000706:	fe0917e3          	bnez	s2,800006f4 <printf+0x232>
    8000070a:	6ba6                	ld	s7,72(sp)
    8000070c:	b589                	j	8000054e <printf+0x8c>
    8000070e:	f8843783          	ld	a5,-120(s0)
    80000712:	00878713          	addi	a4,a5,8
    80000716:	f8e43423          	sd	a4,-120(s0)
    8000071a:	0007b903          	ld	s2,0(a5)
    8000071e:	00090d63          	beqz	s2,80000738 <printf+0x276>
    80000722:	00094503          	lbu	a0,0(s2)
    80000726:	e20504e3          	beqz	a0,8000054e <printf+0x8c>
    8000072a:	b17ff0ef          	jal	80000240 <consputc>
    8000072e:	0905                	addi	s2,s2,1
    80000730:	00094503          	lbu	a0,0(s2)
    80000734:	f97d                	bnez	a0,8000072a <printf+0x268>
    80000736:	bd21                	j	8000054e <printf+0x8c>
    80000738:	00007917          	auipc	s2,0x7
    8000073c:	8d090913          	addi	s2,s2,-1840 # 80007008 <etext+0x8>
    80000740:	02800513          	li	a0,40
    80000744:	b7dd                	j	8000072a <printf+0x268>
    80000746:	02500513          	li	a0,37
    8000074a:	af7ff0ef          	jal	80000240 <consputc>
    8000074e:	b501                	j	8000054e <printf+0x8c>
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
    80000786:	00012517          	auipc	a0,0x12
    8000078a:	d8250513          	addi	a0,a0,-638 # 80012508 <pr>
    8000078e:	4fe000ef          	jal	80000c8c <release>
    80000792:	bfd9                	j	80000768 <printf+0x2a6>

0000000080000794 <panic>:
    80000794:	1101                	addi	sp,sp,-32
    80000796:	ec06                	sd	ra,24(sp)
    80000798:	e822                	sd	s0,16(sp)
    8000079a:	e426                	sd	s1,8(sp)
    8000079c:	1000                	addi	s0,sp,32
    8000079e:	84aa                	mv	s1,a0
    800007a0:	00012797          	auipc	a5,0x12
    800007a4:	d807a023          	sw	zero,-640(a5) # 80012520 <pr+0x18>
    800007a8:	00007517          	auipc	a0,0x7
    800007ac:	87050513          	addi	a0,a0,-1936 # 80007018 <etext+0x18>
    800007b0:	d13ff0ef          	jal	800004c2 <printf>
    800007b4:	85a6                	mv	a1,s1
    800007b6:	00007517          	auipc	a0,0x7
    800007ba:	86a50513          	addi	a0,a0,-1942 # 80007020 <etext+0x20>
    800007be:	d05ff0ef          	jal	800004c2 <printf>
    800007c2:	4785                	li	a5,1
    800007c4:	0000a717          	auipc	a4,0xa
    800007c8:	c4f72e23          	sw	a5,-932(a4) # 8000a420 <panicked>
    800007cc:	a001                	j	800007cc <panic+0x38>

00000000800007ce <printfinit>:
    800007ce:	1101                	addi	sp,sp,-32
    800007d0:	ec06                	sd	ra,24(sp)
    800007d2:	e822                	sd	s0,16(sp)
    800007d4:	e426                	sd	s1,8(sp)
    800007d6:	1000                	addi	s0,sp,32
    800007d8:	00012497          	auipc	s1,0x12
    800007dc:	d3048493          	addi	s1,s1,-720 # 80012508 <pr>
    800007e0:	00007597          	auipc	a1,0x7
    800007e4:	84858593          	addi	a1,a1,-1976 # 80007028 <etext+0x28>
    800007e8:	8526                	mv	a0,s1
    800007ea:	38a000ef          	jal	80000b74 <initlock>
    800007ee:	4785                	li	a5,1
    800007f0:	cc9c                	sw	a5,24(s1)
    800007f2:	60e2                	ld	ra,24(sp)
    800007f4:	6442                	ld	s0,16(sp)
    800007f6:	64a2                	ld	s1,8(sp)
    800007f8:	6105                	addi	sp,sp,32
    800007fa:	8082                	ret

00000000800007fc <uartinit>:
    800007fc:	1141                	addi	sp,sp,-16
    800007fe:	e406                	sd	ra,8(sp)
    80000800:	e022                	sd	s0,0(sp)
    80000802:	0800                	addi	s0,sp,16
    80000804:	100007b7          	lui	a5,0x10000
    80000808:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>
    8000080c:	10000737          	lui	a4,0x10000
    80000810:	f8000693          	li	a3,-128
    80000814:	00d701a3          	sb	a3,3(a4) # 10000003 <_entry-0x6ffffffd>
    80000818:	468d                	li	a3,3
    8000081a:	10000637          	lui	a2,0x10000
    8000081e:	00d60023          	sb	a3,0(a2) # 10000000 <_entry-0x70000000>
    80000822:	000780a3          	sb	zero,1(a5)
    80000826:	00d701a3          	sb	a3,3(a4)
    8000082a:	10000737          	lui	a4,0x10000
    8000082e:	461d                	li	a2,7
    80000830:	00c70123          	sb	a2,2(a4) # 10000002 <_entry-0x6ffffffe>
    80000834:	00d780a3          	sb	a3,1(a5)
    80000838:	00006597          	auipc	a1,0x6
    8000083c:	7f858593          	addi	a1,a1,2040 # 80007030 <etext+0x30>
    80000840:	00012517          	auipc	a0,0x12
    80000844:	ce850513          	addi	a0,a0,-792 # 80012528 <uart_tx_lock>
    80000848:	32c000ef          	jal	80000b74 <initlock>
    8000084c:	60a2                	ld	ra,8(sp)
    8000084e:	6402                	ld	s0,0(sp)
    80000850:	0141                	addi	sp,sp,16
    80000852:	8082                	ret

0000000080000854 <uartputc_sync>:
    80000854:	1101                	addi	sp,sp,-32
    80000856:	ec06                	sd	ra,24(sp)
    80000858:	e822                	sd	s0,16(sp)
    8000085a:	e426                	sd	s1,8(sp)
    8000085c:	1000                	addi	s0,sp,32
    8000085e:	84aa                	mv	s1,a0
    80000860:	354000ef          	jal	80000bb4 <push_off>
    80000864:	0000a797          	auipc	a5,0xa
    80000868:	bbc7a783          	lw	a5,-1092(a5) # 8000a420 <panicked>
    8000086c:	e795                	bnez	a5,80000898 <uartputc_sync+0x44>
    8000086e:	10000737          	lui	a4,0x10000
    80000872:	0715                	addi	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    80000874:	00074783          	lbu	a5,0(a4)
    80000878:	0207f793          	andi	a5,a5,32
    8000087c:	dfe5                	beqz	a5,80000874 <uartputc_sync+0x20>
    8000087e:	0ff4f513          	zext.b	a0,s1
    80000882:	100007b7          	lui	a5,0x10000
    80000886:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>
    8000088a:	3ae000ef          	jal	80000c38 <pop_off>
    8000088e:	60e2                	ld	ra,24(sp)
    80000890:	6442                	ld	s0,16(sp)
    80000892:	64a2                	ld	s1,8(sp)
    80000894:	6105                	addi	sp,sp,32
    80000896:	8082                	ret
    80000898:	a001                	j	80000898 <uartputc_sync+0x44>

000000008000089a <uartstart>:
    8000089a:	0000a797          	auipc	a5,0xa
    8000089e:	b8e7b783          	ld	a5,-1138(a5) # 8000a428 <uart_tx_r>
    800008a2:	0000a717          	auipc	a4,0xa
    800008a6:	b8e73703          	ld	a4,-1138(a4) # 8000a430 <uart_tx_w>
    800008aa:	08f70263          	beq	a4,a5,8000092e <uartstart+0x94>
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
    800008c2:	10000937          	lui	s2,0x10000
    800008c6:	0915                	addi	s2,s2,5 # 10000005 <_entry-0x6ffffffb>
    800008c8:	00012a97          	auipc	s5,0x12
    800008cc:	c60a8a93          	addi	s5,s5,-928 # 80012528 <uart_tx_lock>
    800008d0:	0000a497          	auipc	s1,0xa
    800008d4:	b5848493          	addi	s1,s1,-1192 # 8000a428 <uart_tx_r>
    800008d8:	10000a37          	lui	s4,0x10000
    800008dc:	0000a997          	auipc	s3,0xa
    800008e0:	b5498993          	addi	s3,s3,-1196 # 8000a430 <uart_tx_w>
    800008e4:	00094703          	lbu	a4,0(s2)
    800008e8:	02077713          	andi	a4,a4,32
    800008ec:	c71d                	beqz	a4,8000091a <uartstart+0x80>
    800008ee:	01f7f713          	andi	a4,a5,31
    800008f2:	9756                	add	a4,a4,s5
    800008f4:	01874b03          	lbu	s6,24(a4)
    800008f8:	0785                	addi	a5,a5,1
    800008fa:	e09c                	sd	a5,0(s1)
    800008fc:	8526                	mv	a0,s1
    800008fe:	5fc010ef          	jal	80001efa <wakeup>
    80000902:	016a0023          	sb	s6,0(s4) # 10000000 <_entry-0x70000000>
    80000906:	609c                	ld	a5,0(s1)
    80000908:	0009b703          	ld	a4,0(s3)
    8000090c:	fcf71ce3          	bne	a4,a5,800008e4 <uartstart+0x4a>
    80000910:	100007b7          	lui	a5,0x10000
    80000914:	0789                	addi	a5,a5,2 # 10000002 <_entry-0x6ffffffe>
    80000916:	0007c783          	lbu	a5,0(a5)
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
    8000092e:	100007b7          	lui	a5,0x10000
    80000932:	0789                	addi	a5,a5,2 # 10000002 <_entry-0x6ffffffe>
    80000934:	0007c783          	lbu	a5,0(a5)
    80000938:	8082                	ret

000000008000093a <uartputc>:
    8000093a:	7179                	addi	sp,sp,-48
    8000093c:	f406                	sd	ra,40(sp)
    8000093e:	f022                	sd	s0,32(sp)
    80000940:	ec26                	sd	s1,24(sp)
    80000942:	e84a                	sd	s2,16(sp)
    80000944:	e44e                	sd	s3,8(sp)
    80000946:	e052                	sd	s4,0(sp)
    80000948:	1800                	addi	s0,sp,48
    8000094a:	8a2a                	mv	s4,a0
    8000094c:	00012517          	auipc	a0,0x12
    80000950:	bdc50513          	addi	a0,a0,-1060 # 80012528 <uart_tx_lock>
    80000954:	2a0000ef          	jal	80000bf4 <acquire>
    80000958:	0000a797          	auipc	a5,0xa
    8000095c:	ac87a783          	lw	a5,-1336(a5) # 8000a420 <panicked>
    80000960:	efbd                	bnez	a5,800009de <uartputc+0xa4>
    80000962:	0000a717          	auipc	a4,0xa
    80000966:	ace73703          	ld	a4,-1330(a4) # 8000a430 <uart_tx_w>
    8000096a:	0000a797          	auipc	a5,0xa
    8000096e:	abe7b783          	ld	a5,-1346(a5) # 8000a428 <uart_tx_r>
    80000972:	02078793          	addi	a5,a5,32
    80000976:	00012997          	auipc	s3,0x12
    8000097a:	bb298993          	addi	s3,s3,-1102 # 80012528 <uart_tx_lock>
    8000097e:	0000a497          	auipc	s1,0xa
    80000982:	aaa48493          	addi	s1,s1,-1366 # 8000a428 <uart_tx_r>
    80000986:	0000a917          	auipc	s2,0xa
    8000098a:	aaa90913          	addi	s2,s2,-1366 # 8000a430 <uart_tx_w>
    8000098e:	00e79d63          	bne	a5,a4,800009a8 <uartputc+0x6e>
    80000992:	85ce                	mv	a1,s3
    80000994:	8526                	mv	a0,s1
    80000996:	518010ef          	jal	80001eae <sleep>
    8000099a:	00093703          	ld	a4,0(s2)
    8000099e:	609c                	ld	a5,0(s1)
    800009a0:	02078793          	addi	a5,a5,32
    800009a4:	fee787e3          	beq	a5,a4,80000992 <uartputc+0x58>
    800009a8:	00012497          	auipc	s1,0x12
    800009ac:	b8048493          	addi	s1,s1,-1152 # 80012528 <uart_tx_lock>
    800009b0:	01f77793          	andi	a5,a4,31
    800009b4:	97a6                	add	a5,a5,s1
    800009b6:	01478c23          	sb	s4,24(a5)
    800009ba:	0705                	addi	a4,a4,1
    800009bc:	0000a797          	auipc	a5,0xa
    800009c0:	a6e7ba23          	sd	a4,-1420(a5) # 8000a430 <uart_tx_w>
    800009c4:	ed7ff0ef          	jal	8000089a <uartstart>
    800009c8:	8526                	mv	a0,s1
    800009ca:	2c2000ef          	jal	80000c8c <release>
    800009ce:	70a2                	ld	ra,40(sp)
    800009d0:	7402                	ld	s0,32(sp)
    800009d2:	64e2                	ld	s1,24(sp)
    800009d4:	6942                	ld	s2,16(sp)
    800009d6:	69a2                	ld	s3,8(sp)
    800009d8:	6a02                	ld	s4,0(sp)
    800009da:	6145                	addi	sp,sp,48
    800009dc:	8082                	ret
    800009de:	a001                	j	800009de <uartputc+0xa4>

00000000800009e0 <uartgetc>:
    800009e0:	1141                	addi	sp,sp,-16
    800009e2:	e422                	sd	s0,8(sp)
    800009e4:	0800                	addi	s0,sp,16
    800009e6:	100007b7          	lui	a5,0x10000
    800009ea:	0795                	addi	a5,a5,5 # 10000005 <_entry-0x6ffffffb>
    800009ec:	0007c783          	lbu	a5,0(a5)
    800009f0:	8b85                	andi	a5,a5,1
    800009f2:	cb81                	beqz	a5,80000a02 <uartgetc+0x22>
    800009f4:	100007b7          	lui	a5,0x10000
    800009f8:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    800009fc:	6422                	ld	s0,8(sp)
    800009fe:	0141                	addi	sp,sp,16
    80000a00:	8082                	ret
    80000a02:	557d                	li	a0,-1
    80000a04:	bfe5                	j	800009fc <uartgetc+0x1c>

0000000080000a06 <uartintr>:
    80000a06:	1101                	addi	sp,sp,-32
    80000a08:	ec06                	sd	ra,24(sp)
    80000a0a:	e822                	sd	s0,16(sp)
    80000a0c:	e426                	sd	s1,8(sp)
    80000a0e:	1000                	addi	s0,sp,32
    80000a10:	54fd                	li	s1,-1
    80000a12:	a019                	j	80000a18 <uartintr+0x12>
    80000a14:	85fff0ef          	jal	80000272 <consoleintr>
    80000a18:	fc9ff0ef          	jal	800009e0 <uartgetc>
    80000a1c:	fe951ce3          	bne	a0,s1,80000a14 <uartintr+0xe>
    80000a20:	00012497          	auipc	s1,0x12
    80000a24:	b0848493          	addi	s1,s1,-1272 # 80012528 <uart_tx_lock>
    80000a28:	8526                	mv	a0,s1
    80000a2a:	1ca000ef          	jal	80000bf4 <acquire>
    80000a2e:	e6dff0ef          	jal	8000089a <uartstart>
    80000a32:	8526                	mv	a0,s1
    80000a34:	258000ef          	jal	80000c8c <release>
    80000a38:	60e2                	ld	ra,24(sp)
    80000a3a:	6442                	ld	s0,16(sp)
    80000a3c:	64a2                	ld	s1,8(sp)
    80000a3e:	6105                	addi	sp,sp,32
    80000a40:	8082                	ret

0000000080000a42 <kfree>:
    80000a42:	1101                	addi	sp,sp,-32
    80000a44:	ec06                	sd	ra,24(sp)
    80000a46:	e822                	sd	s0,16(sp)
    80000a48:	e426                	sd	s1,8(sp)
    80000a4a:	e04a                	sd	s2,0(sp)
    80000a4c:	1000                	addi	s0,sp,32
    80000a4e:	03451793          	slli	a5,a0,0x34
    80000a52:	e7a9                	bnez	a5,80000a9c <kfree+0x5a>
    80000a54:	84aa                	mv	s1,a0
    80000a56:	00029797          	auipc	a5,0x29
    80000a5a:	b5278793          	addi	a5,a5,-1198 # 800295a8 <end>
    80000a5e:	02f56f63          	bltu	a0,a5,80000a9c <kfree+0x5a>
    80000a62:	47c5                	li	a5,17
    80000a64:	07ee                	slli	a5,a5,0x1b
    80000a66:	02f57b63          	bgeu	a0,a5,80000a9c <kfree+0x5a>
    80000a6a:	6605                	lui	a2,0x1
    80000a6c:	4585                	li	a1,1
    80000a6e:	25a000ef          	jal	80000cc8 <memset>
    80000a72:	00012917          	auipc	s2,0x12
    80000a76:	aee90913          	addi	s2,s2,-1298 # 80012560 <kmem>
    80000a7a:	854a                	mv	a0,s2
    80000a7c:	178000ef          	jal	80000bf4 <acquire>
    80000a80:	01893783          	ld	a5,24(s2)
    80000a84:	e09c                	sd	a5,0(s1)
    80000a86:	00993c23          	sd	s1,24(s2)
    80000a8a:	854a                	mv	a0,s2
    80000a8c:	200000ef          	jal	80000c8c <release>
    80000a90:	60e2                	ld	ra,24(sp)
    80000a92:	6442                	ld	s0,16(sp)
    80000a94:	64a2                	ld	s1,8(sp)
    80000a96:	6902                	ld	s2,0(sp)
    80000a98:	6105                	addi	sp,sp,32
    80000a9a:	8082                	ret
    80000a9c:	00006517          	auipc	a0,0x6
    80000aa0:	59c50513          	addi	a0,a0,1436 # 80007038 <etext+0x38>
    80000aa4:	cf1ff0ef          	jal	80000794 <panic>

0000000080000aa8 <freerange>:
    80000aa8:	7179                	addi	sp,sp,-48
    80000aaa:	f406                	sd	ra,40(sp)
    80000aac:	f022                	sd	s0,32(sp)
    80000aae:	ec26                	sd	s1,24(sp)
    80000ab0:	1800                	addi	s0,sp,48
    80000ab2:	6785                	lui	a5,0x1
    80000ab4:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000ab8:	00e504b3          	add	s1,a0,a4
    80000abc:	777d                	lui	a4,0xfffff
    80000abe:	8cf9                	and	s1,s1,a4
    80000ac0:	94be                	add	s1,s1,a5
    80000ac2:	0295e263          	bltu	a1,s1,80000ae6 <freerange+0x3e>
    80000ac6:	e84a                	sd	s2,16(sp)
    80000ac8:	e44e                	sd	s3,8(sp)
    80000aca:	e052                	sd	s4,0(sp)
    80000acc:	892e                	mv	s2,a1
    80000ace:	7a7d                	lui	s4,0xfffff
    80000ad0:	6985                	lui	s3,0x1
    80000ad2:	01448533          	add	a0,s1,s4
    80000ad6:	f6dff0ef          	jal	80000a42 <kfree>
    80000ada:	94ce                	add	s1,s1,s3
    80000adc:	fe997be3          	bgeu	s2,s1,80000ad2 <freerange+0x2a>
    80000ae0:	6942                	ld	s2,16(sp)
    80000ae2:	69a2                	ld	s3,8(sp)
    80000ae4:	6a02                	ld	s4,0(sp)
    80000ae6:	70a2                	ld	ra,40(sp)
    80000ae8:	7402                	ld	s0,32(sp)
    80000aea:	64e2                	ld	s1,24(sp)
    80000aec:	6145                	addi	sp,sp,48
    80000aee:	8082                	ret

0000000080000af0 <kinit>:
    80000af0:	1141                	addi	sp,sp,-16
    80000af2:	e406                	sd	ra,8(sp)
    80000af4:	e022                	sd	s0,0(sp)
    80000af6:	0800                	addi	s0,sp,16
    80000af8:	00006597          	auipc	a1,0x6
    80000afc:	54858593          	addi	a1,a1,1352 # 80007040 <etext+0x40>
    80000b00:	00012517          	auipc	a0,0x12
    80000b04:	a6050513          	addi	a0,a0,-1440 # 80012560 <kmem>
    80000b08:	06c000ef          	jal	80000b74 <initlock>
    80000b0c:	45c5                	li	a1,17
    80000b0e:	05ee                	slli	a1,a1,0x1b
    80000b10:	00029517          	auipc	a0,0x29
    80000b14:	a9850513          	addi	a0,a0,-1384 # 800295a8 <end>
    80000b18:	f91ff0ef          	jal	80000aa8 <freerange>
    80000b1c:	60a2                	ld	ra,8(sp)
    80000b1e:	6402                	ld	s0,0(sp)
    80000b20:	0141                	addi	sp,sp,16
    80000b22:	8082                	ret

0000000080000b24 <kalloc>:
    80000b24:	1101                	addi	sp,sp,-32
    80000b26:	ec06                	sd	ra,24(sp)
    80000b28:	e822                	sd	s0,16(sp)
    80000b2a:	e426                	sd	s1,8(sp)
    80000b2c:	1000                	addi	s0,sp,32
    80000b2e:	00012497          	auipc	s1,0x12
    80000b32:	a3248493          	addi	s1,s1,-1486 # 80012560 <kmem>
    80000b36:	8526                	mv	a0,s1
    80000b38:	0bc000ef          	jal	80000bf4 <acquire>
    80000b3c:	6c84                	ld	s1,24(s1)
    80000b3e:	c485                	beqz	s1,80000b66 <kalloc+0x42>
    80000b40:	609c                	ld	a5,0(s1)
    80000b42:	00012517          	auipc	a0,0x12
    80000b46:	a1e50513          	addi	a0,a0,-1506 # 80012560 <kmem>
    80000b4a:	ed1c                	sd	a5,24(a0)
    80000b4c:	140000ef          	jal	80000c8c <release>
    80000b50:	6605                	lui	a2,0x1
    80000b52:	4595                	li	a1,5
    80000b54:	8526                	mv	a0,s1
    80000b56:	172000ef          	jal	80000cc8 <memset>
    80000b5a:	8526                	mv	a0,s1
    80000b5c:	60e2                	ld	ra,24(sp)
    80000b5e:	6442                	ld	s0,16(sp)
    80000b60:	64a2                	ld	s1,8(sp)
    80000b62:	6105                	addi	sp,sp,32
    80000b64:	8082                	ret
    80000b66:	00012517          	auipc	a0,0x12
    80000b6a:	9fa50513          	addi	a0,a0,-1542 # 80012560 <kmem>
    80000b6e:	11e000ef          	jal	80000c8c <release>
    80000b72:	b7e5                	j	80000b5a <kalloc+0x36>

0000000080000b74 <initlock>:
    80000b74:	1141                	addi	sp,sp,-16
    80000b76:	e422                	sd	s0,8(sp)
    80000b78:	0800                	addi	s0,sp,16
    80000b7a:	e50c                	sd	a1,8(a0)
    80000b7c:	00052023          	sw	zero,0(a0)
    80000b80:	00053823          	sd	zero,16(a0)
    80000b84:	6422                	ld	s0,8(sp)
    80000b86:	0141                	addi	sp,sp,16
    80000b88:	8082                	ret

0000000080000b8a <holding>:
    80000b8a:	411c                	lw	a5,0(a0)
    80000b8c:	e399                	bnez	a5,80000b92 <holding+0x8>
    80000b8e:	4501                	li	a0,0
    80000b90:	8082                	ret
    80000b92:	1101                	addi	sp,sp,-32
    80000b94:	ec06                	sd	ra,24(sp)
    80000b96:	e822                	sd	s0,16(sp)
    80000b98:	e426                	sd	s1,8(sp)
    80000b9a:	1000                	addi	s0,sp,32
    80000b9c:	6904                	ld	s1,16(a0)
    80000b9e:	527000ef          	jal	800018c4 <mycpu>
    80000ba2:	40a48533          	sub	a0,s1,a0
    80000ba6:	00153513          	seqz	a0,a0
    80000baa:	60e2                	ld	ra,24(sp)
    80000bac:	6442                	ld	s0,16(sp)
    80000bae:	64a2                	ld	s1,8(sp)
    80000bb0:	6105                	addi	sp,sp,32
    80000bb2:	8082                	ret

0000000080000bb4 <push_off>:
    80000bb4:	1101                	addi	sp,sp,-32
    80000bb6:	ec06                	sd	ra,24(sp)
    80000bb8:	e822                	sd	s0,16(sp)
    80000bba:	e426                	sd	s1,8(sp)
    80000bbc:	1000                	addi	s0,sp,32
    80000bbe:	100024f3          	csrr	s1,sstatus
    80000bc2:	100027f3          	csrr	a5,sstatus
    80000bc6:	9bf5                	andi	a5,a5,-3
    80000bc8:	10079073          	csrw	sstatus,a5
    80000bcc:	4f9000ef          	jal	800018c4 <mycpu>
    80000bd0:	5d3c                	lw	a5,120(a0)
    80000bd2:	cb99                	beqz	a5,80000be8 <push_off+0x34>
    80000bd4:	4f1000ef          	jal	800018c4 <mycpu>
    80000bd8:	5d3c                	lw	a5,120(a0)
    80000bda:	2785                	addiw	a5,a5,1
    80000bdc:	dd3c                	sw	a5,120(a0)
    80000bde:	60e2                	ld	ra,24(sp)
    80000be0:	6442                	ld	s0,16(sp)
    80000be2:	64a2                	ld	s1,8(sp)
    80000be4:	6105                	addi	sp,sp,32
    80000be6:	8082                	ret
    80000be8:	4dd000ef          	jal	800018c4 <mycpu>
    80000bec:	8085                	srli	s1,s1,0x1
    80000bee:	8885                	andi	s1,s1,1
    80000bf0:	dd64                	sw	s1,124(a0)
    80000bf2:	b7cd                	j	80000bd4 <push_off+0x20>

0000000080000bf4 <acquire>:
    80000bf4:	1101                	addi	sp,sp,-32
    80000bf6:	ec06                	sd	ra,24(sp)
    80000bf8:	e822                	sd	s0,16(sp)
    80000bfa:	e426                	sd	s1,8(sp)
    80000bfc:	1000                	addi	s0,sp,32
    80000bfe:	84aa                	mv	s1,a0
    80000c00:	fb5ff0ef          	jal	80000bb4 <push_off>
    80000c04:	8526                	mv	a0,s1
    80000c06:	f85ff0ef          	jal	80000b8a <holding>
    80000c0a:	4705                	li	a4,1
    80000c0c:	e105                	bnez	a0,80000c2c <acquire+0x38>
    80000c0e:	87ba                	mv	a5,a4
    80000c10:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000c14:	2781                	sext.w	a5,a5
    80000c16:	ffe5                	bnez	a5,80000c0e <acquire+0x1a>
    80000c18:	0330000f          	fence	rw,rw
    80000c1c:	4a9000ef          	jal	800018c4 <mycpu>
    80000c20:	e888                	sd	a0,16(s1)
    80000c22:	60e2                	ld	ra,24(sp)
    80000c24:	6442                	ld	s0,16(sp)
    80000c26:	64a2                	ld	s1,8(sp)
    80000c28:	6105                	addi	sp,sp,32
    80000c2a:	8082                	ret
    80000c2c:	00006517          	auipc	a0,0x6
    80000c30:	41c50513          	addi	a0,a0,1052 # 80007048 <etext+0x48>
    80000c34:	b61ff0ef          	jal	80000794 <panic>

0000000080000c38 <pop_off>:
    80000c38:	1141                	addi	sp,sp,-16
    80000c3a:	e406                	sd	ra,8(sp)
    80000c3c:	e022                	sd	s0,0(sp)
    80000c3e:	0800                	addi	s0,sp,16
    80000c40:	485000ef          	jal	800018c4 <mycpu>
    80000c44:	100027f3          	csrr	a5,sstatus
    80000c48:	8b89                	andi	a5,a5,2
    80000c4a:	e78d                	bnez	a5,80000c74 <pop_off+0x3c>
    80000c4c:	5d3c                	lw	a5,120(a0)
    80000c4e:	02f05963          	blez	a5,80000c80 <pop_off+0x48>
    80000c52:	37fd                	addiw	a5,a5,-1
    80000c54:	0007871b          	sext.w	a4,a5
    80000c58:	dd3c                	sw	a5,120(a0)
    80000c5a:	eb09                	bnez	a4,80000c6c <pop_off+0x34>
    80000c5c:	5d7c                	lw	a5,124(a0)
    80000c5e:	c799                	beqz	a5,80000c6c <pop_off+0x34>
    80000c60:	100027f3          	csrr	a5,sstatus
    80000c64:	0027e793          	ori	a5,a5,2
    80000c68:	10079073          	csrw	sstatus,a5
    80000c6c:	60a2                	ld	ra,8(sp)
    80000c6e:	6402                	ld	s0,0(sp)
    80000c70:	0141                	addi	sp,sp,16
    80000c72:	8082                	ret
    80000c74:	00006517          	auipc	a0,0x6
    80000c78:	3dc50513          	addi	a0,a0,988 # 80007050 <etext+0x50>
    80000c7c:	b19ff0ef          	jal	80000794 <panic>
    80000c80:	00006517          	auipc	a0,0x6
    80000c84:	3e850513          	addi	a0,a0,1000 # 80007068 <etext+0x68>
    80000c88:	b0dff0ef          	jal	80000794 <panic>

0000000080000c8c <release>:
    80000c8c:	1101                	addi	sp,sp,-32
    80000c8e:	ec06                	sd	ra,24(sp)
    80000c90:	e822                	sd	s0,16(sp)
    80000c92:	e426                	sd	s1,8(sp)
    80000c94:	1000                	addi	s0,sp,32
    80000c96:	84aa                	mv	s1,a0
    80000c98:	ef3ff0ef          	jal	80000b8a <holding>
    80000c9c:	c105                	beqz	a0,80000cbc <release+0x30>
    80000c9e:	0004b823          	sd	zero,16(s1)
    80000ca2:	0330000f          	fence	rw,rw
    80000ca6:	0310000f          	fence	rw,w
    80000caa:	0004a023          	sw	zero,0(s1)
    80000cae:	f8bff0ef          	jal	80000c38 <pop_off>
    80000cb2:	60e2                	ld	ra,24(sp)
    80000cb4:	6442                	ld	s0,16(sp)
    80000cb6:	64a2                	ld	s1,8(sp)
    80000cb8:	6105                	addi	sp,sp,32
    80000cba:	8082                	ret
    80000cbc:	00006517          	auipc	a0,0x6
    80000cc0:	3b450513          	addi	a0,a0,948 # 80007070 <etext+0x70>
    80000cc4:	ad1ff0ef          	jal	80000794 <panic>

0000000080000cc8 <memset>:
    80000cc8:	1141                	addi	sp,sp,-16
    80000cca:	e422                	sd	s0,8(sp)
    80000ccc:	0800                	addi	s0,sp,16
    80000cce:	ca19                	beqz	a2,80000ce4 <memset+0x1c>
    80000cd0:	87aa                	mv	a5,a0
    80000cd2:	1602                	slli	a2,a2,0x20
    80000cd4:	9201                	srli	a2,a2,0x20
    80000cd6:	00a60733          	add	a4,a2,a0
    80000cda:	00b78023          	sb	a1,0(a5)
    80000cde:	0785                	addi	a5,a5,1
    80000ce0:	fee79de3          	bne	a5,a4,80000cda <memset+0x12>
    80000ce4:	6422                	ld	s0,8(sp)
    80000ce6:	0141                	addi	sp,sp,16
    80000ce8:	8082                	ret

0000000080000cea <memcmp>:
    80000cea:	1141                	addi	sp,sp,-16
    80000cec:	e422                	sd	s0,8(sp)
    80000cee:	0800                	addi	s0,sp,16
    80000cf0:	ca05                	beqz	a2,80000d20 <memcmp+0x36>
    80000cf2:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000cf6:	1682                	slli	a3,a3,0x20
    80000cf8:	9281                	srli	a3,a3,0x20
    80000cfa:	0685                	addi	a3,a3,1
    80000cfc:	96aa                	add	a3,a3,a0
    80000cfe:	00054783          	lbu	a5,0(a0)
    80000d02:	0005c703          	lbu	a4,0(a1)
    80000d06:	00e79863          	bne	a5,a4,80000d16 <memcmp+0x2c>
    80000d0a:	0505                	addi	a0,a0,1
    80000d0c:	0585                	addi	a1,a1,1
    80000d0e:	fed518e3          	bne	a0,a3,80000cfe <memcmp+0x14>
    80000d12:	4501                	li	a0,0
    80000d14:	a019                	j	80000d1a <memcmp+0x30>
    80000d16:	40e7853b          	subw	a0,a5,a4
    80000d1a:	6422                	ld	s0,8(sp)
    80000d1c:	0141                	addi	sp,sp,16
    80000d1e:	8082                	ret
    80000d20:	4501                	li	a0,0
    80000d22:	bfe5                	j	80000d1a <memcmp+0x30>

0000000080000d24 <memmove>:
    80000d24:	1141                	addi	sp,sp,-16
    80000d26:	e422                	sd	s0,8(sp)
    80000d28:	0800                	addi	s0,sp,16
    80000d2a:	c205                	beqz	a2,80000d4a <memmove+0x26>
    80000d2c:	02a5e263          	bltu	a1,a0,80000d50 <memmove+0x2c>
    80000d30:	1602                	slli	a2,a2,0x20
    80000d32:	9201                	srli	a2,a2,0x20
    80000d34:	00c587b3          	add	a5,a1,a2
    80000d38:	872a                	mv	a4,a0
    80000d3a:	0585                	addi	a1,a1,1
    80000d3c:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffd5a59>
    80000d3e:	fff5c683          	lbu	a3,-1(a1)
    80000d42:	fed70fa3          	sb	a3,-1(a4)
    80000d46:	feb79ae3          	bne	a5,a1,80000d3a <memmove+0x16>
    80000d4a:	6422                	ld	s0,8(sp)
    80000d4c:	0141                	addi	sp,sp,16
    80000d4e:	8082                	ret
    80000d50:	02061693          	slli	a3,a2,0x20
    80000d54:	9281                	srli	a3,a3,0x20
    80000d56:	00d58733          	add	a4,a1,a3
    80000d5a:	fce57be3          	bgeu	a0,a4,80000d30 <memmove+0xc>
    80000d5e:	96aa                	add	a3,a3,a0
    80000d60:	fff6079b          	addiw	a5,a2,-1
    80000d64:	1782                	slli	a5,a5,0x20
    80000d66:	9381                	srli	a5,a5,0x20
    80000d68:	fff7c793          	not	a5,a5
    80000d6c:	97ba                	add	a5,a5,a4
    80000d6e:	177d                	addi	a4,a4,-1
    80000d70:	16fd                	addi	a3,a3,-1
    80000d72:	00074603          	lbu	a2,0(a4)
    80000d76:	00c68023          	sb	a2,0(a3)
    80000d7a:	fef71ae3          	bne	a4,a5,80000d6e <memmove+0x4a>
    80000d7e:	b7f1                	j	80000d4a <memmove+0x26>

0000000080000d80 <memcpy>:
    80000d80:	1141                	addi	sp,sp,-16
    80000d82:	e406                	sd	ra,8(sp)
    80000d84:	e022                	sd	s0,0(sp)
    80000d86:	0800                	addi	s0,sp,16
    80000d88:	f9dff0ef          	jal	80000d24 <memmove>
    80000d8c:	60a2                	ld	ra,8(sp)
    80000d8e:	6402                	ld	s0,0(sp)
    80000d90:	0141                	addi	sp,sp,16
    80000d92:	8082                	ret

0000000080000d94 <strncmp>:
    80000d94:	1141                	addi	sp,sp,-16
    80000d96:	e422                	sd	s0,8(sp)
    80000d98:	0800                	addi	s0,sp,16
    80000d9a:	ce11                	beqz	a2,80000db6 <strncmp+0x22>
    80000d9c:	00054783          	lbu	a5,0(a0)
    80000da0:	cf89                	beqz	a5,80000dba <strncmp+0x26>
    80000da2:	0005c703          	lbu	a4,0(a1)
    80000da6:	00f71a63          	bne	a4,a5,80000dba <strncmp+0x26>
    80000daa:	367d                	addiw	a2,a2,-1
    80000dac:	0505                	addi	a0,a0,1
    80000dae:	0585                	addi	a1,a1,1
    80000db0:	f675                	bnez	a2,80000d9c <strncmp+0x8>
    80000db2:	4501                	li	a0,0
    80000db4:	a801                	j	80000dc4 <strncmp+0x30>
    80000db6:	4501                	li	a0,0
    80000db8:	a031                	j	80000dc4 <strncmp+0x30>
    80000dba:	00054503          	lbu	a0,0(a0)
    80000dbe:	0005c783          	lbu	a5,0(a1)
    80000dc2:	9d1d                	subw	a0,a0,a5
    80000dc4:	6422                	ld	s0,8(sp)
    80000dc6:	0141                	addi	sp,sp,16
    80000dc8:	8082                	ret

0000000080000dca <strncpy>:
    80000dca:	1141                	addi	sp,sp,-16
    80000dcc:	e422                	sd	s0,8(sp)
    80000dce:	0800                	addi	s0,sp,16
    80000dd0:	87aa                	mv	a5,a0
    80000dd2:	86b2                	mv	a3,a2
    80000dd4:	367d                	addiw	a2,a2,-1
    80000dd6:	02d05563          	blez	a3,80000e00 <strncpy+0x36>
    80000dda:	0785                	addi	a5,a5,1
    80000ddc:	0005c703          	lbu	a4,0(a1)
    80000de0:	fee78fa3          	sb	a4,-1(a5)
    80000de4:	0585                	addi	a1,a1,1
    80000de6:	f775                	bnez	a4,80000dd2 <strncpy+0x8>
    80000de8:	873e                	mv	a4,a5
    80000dea:	9fb5                	addw	a5,a5,a3
    80000dec:	37fd                	addiw	a5,a5,-1
    80000dee:	00c05963          	blez	a2,80000e00 <strncpy+0x36>
    80000df2:	0705                	addi	a4,a4,1
    80000df4:	fe070fa3          	sb	zero,-1(a4)
    80000df8:	40e786bb          	subw	a3,a5,a4
    80000dfc:	fed04be3          	bgtz	a3,80000df2 <strncpy+0x28>
    80000e00:	6422                	ld	s0,8(sp)
    80000e02:	0141                	addi	sp,sp,16
    80000e04:	8082                	ret

0000000080000e06 <safestrcpy>:
    80000e06:	1141                	addi	sp,sp,-16
    80000e08:	e422                	sd	s0,8(sp)
    80000e0a:	0800                	addi	s0,sp,16
    80000e0c:	02c05363          	blez	a2,80000e32 <safestrcpy+0x2c>
    80000e10:	fff6069b          	addiw	a3,a2,-1
    80000e14:	1682                	slli	a3,a3,0x20
    80000e16:	9281                	srli	a3,a3,0x20
    80000e18:	96ae                	add	a3,a3,a1
    80000e1a:	87aa                	mv	a5,a0
    80000e1c:	00d58963          	beq	a1,a3,80000e2e <safestrcpy+0x28>
    80000e20:	0585                	addi	a1,a1,1
    80000e22:	0785                	addi	a5,a5,1
    80000e24:	fff5c703          	lbu	a4,-1(a1)
    80000e28:	fee78fa3          	sb	a4,-1(a5)
    80000e2c:	fb65                	bnez	a4,80000e1c <safestrcpy+0x16>
    80000e2e:	00078023          	sb	zero,0(a5)
    80000e32:	6422                	ld	s0,8(sp)
    80000e34:	0141                	addi	sp,sp,16
    80000e36:	8082                	ret

0000000080000e38 <strlen>:
    80000e38:	1141                	addi	sp,sp,-16
    80000e3a:	e422                	sd	s0,8(sp)
    80000e3c:	0800                	addi	s0,sp,16
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
    80000e58:	6422                	ld	s0,8(sp)
    80000e5a:	0141                	addi	sp,sp,16
    80000e5c:	8082                	ret
    80000e5e:	4501                	li	a0,0
    80000e60:	bfe5                	j	80000e58 <strlen+0x20>

0000000080000e62 <main>:
    80000e62:	1141                	addi	sp,sp,-16
    80000e64:	e406                	sd	ra,8(sp)
    80000e66:	e022                	sd	s0,0(sp)
    80000e68:	0800                	addi	s0,sp,16
    80000e6a:	24b000ef          	jal	800018b4 <cpuid>
    80000e6e:	00009717          	auipc	a4,0x9
    80000e72:	5ca70713          	addi	a4,a4,1482 # 8000a438 <started>
    80000e76:	c51d                	beqz	a0,80000ea4 <main+0x42>
    80000e78:	431c                	lw	a5,0(a4)
    80000e7a:	2781                	sext.w	a5,a5
    80000e7c:	dff5                	beqz	a5,80000e78 <main+0x16>
    80000e7e:	0330000f          	fence	rw,rw
    80000e82:	233000ef          	jal	800018b4 <cpuid>
    80000e86:	85aa                	mv	a1,a0
    80000e88:	00006517          	auipc	a0,0x6
    80000e8c:	20850513          	addi	a0,a0,520 # 80007090 <etext+0x90>
    80000e90:	e32ff0ef          	jal	800004c2 <printf>
    80000e94:	080000ef          	jal	80000f14 <kvminithart>
    80000e98:	71c010ef          	jal	800025b4 <trapinithart>
    80000e9c:	66c040ef          	jal	80005508 <plicinithart>
    80000ea0:	675000ef          	jal	80001d14 <scheduler>
    80000ea4:	d48ff0ef          	jal	800003ec <consoleinit>
    80000ea8:	927ff0ef          	jal	800007ce <printfinit>
    80000eac:	00006517          	auipc	a0,0x6
    80000eb0:	48c50513          	addi	a0,a0,1164 # 80007338 <etext+0x338>
    80000eb4:	e0eff0ef          	jal	800004c2 <printf>
    80000eb8:	00006517          	auipc	a0,0x6
    80000ebc:	1c050513          	addi	a0,a0,448 # 80007078 <etext+0x78>
    80000ec0:	e02ff0ef          	jal	800004c2 <printf>
    80000ec4:	00006517          	auipc	a0,0x6
    80000ec8:	47450513          	addi	a0,a0,1140 # 80007338 <etext+0x338>
    80000ecc:	df6ff0ef          	jal	800004c2 <printf>
    80000ed0:	c21ff0ef          	jal	80000af0 <kinit>
    80000ed4:	2ca000ef          	jal	8000119e <kvminit>
    80000ed8:	03c000ef          	jal	80000f14 <kvminithart>
    80000edc:	123000ef          	jal	800017fe <procinit>
    80000ee0:	6b0010ef          	jal	80002590 <trapinit>
    80000ee4:	6d0010ef          	jal	800025b4 <trapinithart>
    80000ee8:	606040ef          	jal	800054ee <plicinit>
    80000eec:	61c040ef          	jal	80005508 <plicinithart>
    80000ef0:	5bd010ef          	jal	80002cac <binit>
    80000ef4:	3ae020ef          	jal	800032a2 <iinit>
    80000ef8:	15a030ef          	jal	80004052 <fileinit>
    80000efc:	6fc040ef          	jal	800055f8 <virtio_disk_init>
    80000f00:	449000ef          	jal	80001b48 <userinit>
    80000f04:	0330000f          	fence	rw,rw
    80000f08:	4785                	li	a5,1
    80000f0a:	00009717          	auipc	a4,0x9
    80000f0e:	52f72723          	sw	a5,1326(a4) # 8000a438 <started>
    80000f12:	b779                	j	80000ea0 <main+0x3e>

0000000080000f14 <kvminithart>:
    80000f14:	1141                	addi	sp,sp,-16
    80000f16:	e422                	sd	s0,8(sp)
    80000f18:	0800                	addi	s0,sp,16
    80000f1a:	12000073          	sfence.vma
    80000f1e:	00009797          	auipc	a5,0x9
    80000f22:	5227b783          	ld	a5,1314(a5) # 8000a440 <kernel_pagetable>
    80000f26:	83b1                	srli	a5,a5,0xc
    80000f28:	577d                	li	a4,-1
    80000f2a:	177e                	slli	a4,a4,0x3f
    80000f2c:	8fd9                	or	a5,a5,a4
    80000f2e:	18079073          	csrw	satp,a5
    80000f32:	12000073          	sfence.vma
    80000f36:	6422                	ld	s0,8(sp)
    80000f38:	0141                	addi	sp,sp,16
    80000f3a:	8082                	ret

0000000080000f3c <walk>:
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
    80000f56:	57fd                	li	a5,-1
    80000f58:	83e9                	srli	a5,a5,0x1a
    80000f5a:	4a79                	li	s4,30
    80000f5c:	4b31                	li	s6,12
    80000f5e:	02b7fc63          	bgeu	a5,a1,80000f96 <walk+0x5a>
    80000f62:	00006517          	auipc	a0,0x6
    80000f66:	14650513          	addi	a0,a0,326 # 800070a8 <etext+0xa8>
    80000f6a:	82bff0ef          	jal	80000794 <panic>
    80000f6e:	060a8263          	beqz	s5,80000fd2 <walk+0x96>
    80000f72:	bb3ff0ef          	jal	80000b24 <kalloc>
    80000f76:	84aa                	mv	s1,a0
    80000f78:	c139                	beqz	a0,80000fbe <walk+0x82>
    80000f7a:	6605                	lui	a2,0x1
    80000f7c:	4581                	li	a1,0
    80000f7e:	d4bff0ef          	jal	80000cc8 <memset>
    80000f82:	00c4d793          	srli	a5,s1,0xc
    80000f86:	07aa                	slli	a5,a5,0xa
    80000f88:	0017e793          	ori	a5,a5,1
    80000f8c:	00f93023          	sd	a5,0(s2)
    80000f90:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffd5a4f>
    80000f92:	036a0063          	beq	s4,s6,80000fb2 <walk+0x76>
    80000f96:	0149d933          	srl	s2,s3,s4
    80000f9a:	1ff97913          	andi	s2,s2,511
    80000f9e:	090e                	slli	s2,s2,0x3
    80000fa0:	9926                	add	s2,s2,s1
    80000fa2:	00093483          	ld	s1,0(s2)
    80000fa6:	0014f793          	andi	a5,s1,1
    80000faa:	d3f1                	beqz	a5,80000f6e <walk+0x32>
    80000fac:	80a9                	srli	s1,s1,0xa
    80000fae:	04b2                	slli	s1,s1,0xc
    80000fb0:	b7c5                	j	80000f90 <walk+0x54>
    80000fb2:	00c9d513          	srli	a0,s3,0xc
    80000fb6:	1ff57513          	andi	a0,a0,511
    80000fba:	050e                	slli	a0,a0,0x3
    80000fbc:	9526                	add	a0,a0,s1
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
    80000fd2:	4501                	li	a0,0
    80000fd4:	b7ed                	j	80000fbe <walk+0x82>

0000000080000fd6 <walkaddr>:
    80000fd6:	57fd                	li	a5,-1
    80000fd8:	83e9                	srli	a5,a5,0x1a
    80000fda:	00b7f463          	bgeu	a5,a1,80000fe2 <walkaddr+0xc>
    80000fde:	4501                	li	a0,0
    80000fe0:	8082                	ret
    80000fe2:	1141                	addi	sp,sp,-16
    80000fe4:	e406                	sd	ra,8(sp)
    80000fe6:	e022                	sd	s0,0(sp)
    80000fe8:	0800                	addi	s0,sp,16
    80000fea:	4601                	li	a2,0
    80000fec:	f51ff0ef          	jal	80000f3c <walk>
    80000ff0:	c105                	beqz	a0,80001010 <walkaddr+0x3a>
    80000ff2:	611c                	ld	a5,0(a0)
    80000ff4:	0117f693          	andi	a3,a5,17
    80000ff8:	4745                	li	a4,17
    80000ffa:	4501                	li	a0,0
    80000ffc:	00e68663          	beq	a3,a4,80001008 <walkaddr+0x32>
    80001000:	60a2                	ld	ra,8(sp)
    80001002:	6402                	ld	s0,0(sp)
    80001004:	0141                	addi	sp,sp,16
    80001006:	8082                	ret
    80001008:	83a9                	srli	a5,a5,0xa
    8000100a:	00c79513          	slli	a0,a5,0xc
    8000100e:	bfcd                	j	80001000 <walkaddr+0x2a>
    80001010:	4501                	li	a0,0
    80001012:	b7fd                	j	80001000 <walkaddr+0x2a>

0000000080001014 <mappages>:
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
    8000102a:	03459793          	slli	a5,a1,0x34
    8000102e:	e7a9                	bnez	a5,80001078 <mappages+0x64>
    80001030:	8aaa                	mv	s5,a0
    80001032:	8b3a                	mv	s6,a4
    80001034:	03461793          	slli	a5,a2,0x34
    80001038:	e7b1                	bnez	a5,80001084 <mappages+0x70>
    8000103a:	ca39                	beqz	a2,80001090 <mappages+0x7c>
    8000103c:	77fd                	lui	a5,0xfffff
    8000103e:	963e                	add	a2,a2,a5
    80001040:	00b609b3          	add	s3,a2,a1
    80001044:	892e                	mv	s2,a1
    80001046:	40b68a33          	sub	s4,a3,a1
    8000104a:	6b85                	lui	s7,0x1
    8000104c:	014904b3          	add	s1,s2,s4
    80001050:	4605                	li	a2,1
    80001052:	85ca                	mv	a1,s2
    80001054:	8556                	mv	a0,s5
    80001056:	ee7ff0ef          	jal	80000f3c <walk>
    8000105a:	c539                	beqz	a0,800010a8 <mappages+0x94>
    8000105c:	611c                	ld	a5,0(a0)
    8000105e:	8b85                	andi	a5,a5,1
    80001060:	ef95                	bnez	a5,8000109c <mappages+0x88>
    80001062:	80b1                	srli	s1,s1,0xc
    80001064:	04aa                	slli	s1,s1,0xa
    80001066:	0164e4b3          	or	s1,s1,s6
    8000106a:	0014e493          	ori	s1,s1,1
    8000106e:	e104                	sd	s1,0(a0)
    80001070:	05390863          	beq	s2,s3,800010c0 <mappages+0xac>
    80001074:	995e                	add	s2,s2,s7
    80001076:	bfd9                	j	8000104c <mappages+0x38>
    80001078:	00006517          	auipc	a0,0x6
    8000107c:	03850513          	addi	a0,a0,56 # 800070b0 <etext+0xb0>
    80001080:	f14ff0ef          	jal	80000794 <panic>
    80001084:	00006517          	auipc	a0,0x6
    80001088:	04c50513          	addi	a0,a0,76 # 800070d0 <etext+0xd0>
    8000108c:	f08ff0ef          	jal	80000794 <panic>
    80001090:	00006517          	auipc	a0,0x6
    80001094:	06050513          	addi	a0,a0,96 # 800070f0 <etext+0xf0>
    80001098:	efcff0ef          	jal	80000794 <panic>
    8000109c:	00006517          	auipc	a0,0x6
    800010a0:	06450513          	addi	a0,a0,100 # 80007100 <etext+0x100>
    800010a4:	ef0ff0ef          	jal	80000794 <panic>
    800010a8:	557d                	li	a0,-1
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
    800010c0:	4501                	li	a0,0
    800010c2:	b7e5                	j	800010aa <mappages+0x96>

00000000800010c4 <kvmmap>:
    800010c4:	1141                	addi	sp,sp,-16
    800010c6:	e406                	sd	ra,8(sp)
    800010c8:	e022                	sd	s0,0(sp)
    800010ca:	0800                	addi	s0,sp,16
    800010cc:	87b6                	mv	a5,a3
    800010ce:	86b2                	mv	a3,a2
    800010d0:	863e                	mv	a2,a5
    800010d2:	f43ff0ef          	jal	80001014 <mappages>
    800010d6:	e509                	bnez	a0,800010e0 <kvmmap+0x1c>
    800010d8:	60a2                	ld	ra,8(sp)
    800010da:	6402                	ld	s0,0(sp)
    800010dc:	0141                	addi	sp,sp,16
    800010de:	8082                	ret
    800010e0:	00006517          	auipc	a0,0x6
    800010e4:	03050513          	addi	a0,a0,48 # 80007110 <etext+0x110>
    800010e8:	eacff0ef          	jal	80000794 <panic>

00000000800010ec <kvmmake>:
    800010ec:	1101                	addi	sp,sp,-32
    800010ee:	ec06                	sd	ra,24(sp)
    800010f0:	e822                	sd	s0,16(sp)
    800010f2:	e426                	sd	s1,8(sp)
    800010f4:	e04a                	sd	s2,0(sp)
    800010f6:	1000                	addi	s0,sp,32
    800010f8:	a2dff0ef          	jal	80000b24 <kalloc>
    800010fc:	84aa                	mv	s1,a0
    800010fe:	6605                	lui	a2,0x1
    80001100:	4581                	li	a1,0
    80001102:	bc7ff0ef          	jal	80000cc8 <memset>
    80001106:	4719                	li	a4,6
    80001108:	6685                	lui	a3,0x1
    8000110a:	10000637          	lui	a2,0x10000
    8000110e:	100005b7          	lui	a1,0x10000
    80001112:	8526                	mv	a0,s1
    80001114:	fb1ff0ef          	jal	800010c4 <kvmmap>
    80001118:	4719                	li	a4,6
    8000111a:	6685                	lui	a3,0x1
    8000111c:	10001637          	lui	a2,0x10001
    80001120:	100015b7          	lui	a1,0x10001
    80001124:	8526                	mv	a0,s1
    80001126:	f9fff0ef          	jal	800010c4 <kvmmap>
    8000112a:	4719                	li	a4,6
    8000112c:	040006b7          	lui	a3,0x4000
    80001130:	0c000637          	lui	a2,0xc000
    80001134:	0c0005b7          	lui	a1,0xc000
    80001138:	8526                	mv	a0,s1
    8000113a:	f8bff0ef          	jal	800010c4 <kvmmap>
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
    8000115c:	46c5                	li	a3,17
    8000115e:	06ee                	slli	a3,a3,0x1b
    80001160:	4719                	li	a4,6
    80001162:	412686b3          	sub	a3,a3,s2
    80001166:	864a                	mv	a2,s2
    80001168:	85ca                	mv	a1,s2
    8000116a:	8526                	mv	a0,s1
    8000116c:	f59ff0ef          	jal	800010c4 <kvmmap>
    80001170:	4729                	li	a4,10
    80001172:	6685                	lui	a3,0x1
    80001174:	00005617          	auipc	a2,0x5
    80001178:	e8c60613          	addi	a2,a2,-372 # 80006000 <_trampoline>
    8000117c:	040005b7          	lui	a1,0x4000
    80001180:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001182:	05b2                	slli	a1,a1,0xc
    80001184:	8526                	mv	a0,s1
    80001186:	f3fff0ef          	jal	800010c4 <kvmmap>
    8000118a:	8526                	mv	a0,s1
    8000118c:	5da000ef          	jal	80001766 <proc_mapstacks>
    80001190:	8526                	mv	a0,s1
    80001192:	60e2                	ld	ra,24(sp)
    80001194:	6442                	ld	s0,16(sp)
    80001196:	64a2                	ld	s1,8(sp)
    80001198:	6902                	ld	s2,0(sp)
    8000119a:	6105                	addi	sp,sp,32
    8000119c:	8082                	ret

000000008000119e <kvminit>:
    8000119e:	1141                	addi	sp,sp,-16
    800011a0:	e406                	sd	ra,8(sp)
    800011a2:	e022                	sd	s0,0(sp)
    800011a4:	0800                	addi	s0,sp,16
    800011a6:	f47ff0ef          	jal	800010ec <kvmmake>
    800011aa:	00009797          	auipc	a5,0x9
    800011ae:	28a7bb23          	sd	a0,662(a5) # 8000a440 <kernel_pagetable>
    800011b2:	60a2                	ld	ra,8(sp)
    800011b4:	6402                	ld	s0,0(sp)
    800011b6:	0141                	addi	sp,sp,16
    800011b8:	8082                	ret

00000000800011ba <uvmunmap>:
    800011ba:	715d                	addi	sp,sp,-80
    800011bc:	e486                	sd	ra,72(sp)
    800011be:	e0a2                	sd	s0,64(sp)
    800011c0:	0880                	addi	s0,sp,80
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
    800011da:	0632                	slli	a2,a2,0xc
    800011dc:	00b609b3          	add	s3,a2,a1
    800011e0:	4b85                	li	s7,1
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
    800011fa:	00006517          	auipc	a0,0x6
    800011fe:	f1e50513          	addi	a0,a0,-226 # 80007118 <etext+0x118>
    80001202:	d92ff0ef          	jal	80000794 <panic>
    80001206:	00006517          	auipc	a0,0x6
    8000120a:	f2a50513          	addi	a0,a0,-214 # 80007130 <etext+0x130>
    8000120e:	d86ff0ef          	jal	80000794 <panic>
    80001212:	00006517          	auipc	a0,0x6
    80001216:	f2e50513          	addi	a0,a0,-210 # 80007140 <etext+0x140>
    8000121a:	d7aff0ef          	jal	80000794 <panic>
    8000121e:	00006517          	auipc	a0,0x6
    80001222:	f3a50513          	addi	a0,a0,-198 # 80007158 <etext+0x158>
    80001226:	d6eff0ef          	jal	80000794 <panic>
    8000122a:	0004b023          	sd	zero,0(s1)
    8000122e:	995a                	add	s2,s2,s6
    80001230:	03397863          	bgeu	s2,s3,80001260 <uvmunmap+0xa6>
    80001234:	4601                	li	a2,0
    80001236:	85ca                	mv	a1,s2
    80001238:	8552                	mv	a0,s4
    8000123a:	d03ff0ef          	jal	80000f3c <walk>
    8000123e:	84aa                	mv	s1,a0
    80001240:	d179                	beqz	a0,80001206 <uvmunmap+0x4c>
    80001242:	6108                	ld	a0,0(a0)
    80001244:	00157793          	andi	a5,a0,1
    80001248:	d7e9                	beqz	a5,80001212 <uvmunmap+0x58>
    8000124a:	3ff57793          	andi	a5,a0,1023
    8000124e:	fd7788e3          	beq	a5,s7,8000121e <uvmunmap+0x64>
    80001252:	fc0a8ce3          	beqz	s5,8000122a <uvmunmap+0x70>
    80001256:	8129                	srli	a0,a0,0xa
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
    8000126e:	60a6                	ld	ra,72(sp)
    80001270:	6406                	ld	s0,64(sp)
    80001272:	6161                	addi	sp,sp,80
    80001274:	8082                	ret

0000000080001276 <uvmcreate>:
    80001276:	1101                	addi	sp,sp,-32
    80001278:	ec06                	sd	ra,24(sp)
    8000127a:	e822                	sd	s0,16(sp)
    8000127c:	e426                	sd	s1,8(sp)
    8000127e:	1000                	addi	s0,sp,32
    80001280:	8a5ff0ef          	jal	80000b24 <kalloc>
    80001284:	84aa                	mv	s1,a0
    80001286:	c509                	beqz	a0,80001290 <uvmcreate+0x1a>
    80001288:	6605                	lui	a2,0x1
    8000128a:	4581                	li	a1,0
    8000128c:	a3dff0ef          	jal	80000cc8 <memset>
    80001290:	8526                	mv	a0,s1
    80001292:	60e2                	ld	ra,24(sp)
    80001294:	6442                	ld	s0,16(sp)
    80001296:	64a2                	ld	s1,8(sp)
    80001298:	6105                	addi	sp,sp,32
    8000129a:	8082                	ret

000000008000129c <uvmfirst>:
    8000129c:	7179                	addi	sp,sp,-48
    8000129e:	f406                	sd	ra,40(sp)
    800012a0:	f022                	sd	s0,32(sp)
    800012a2:	ec26                	sd	s1,24(sp)
    800012a4:	e84a                	sd	s2,16(sp)
    800012a6:	e44e                	sd	s3,8(sp)
    800012a8:	e052                	sd	s4,0(sp)
    800012aa:	1800                	addi	s0,sp,48
    800012ac:	6785                	lui	a5,0x1
    800012ae:	04f67063          	bgeu	a2,a5,800012ee <uvmfirst+0x52>
    800012b2:	8a2a                	mv	s4,a0
    800012b4:	89ae                	mv	s3,a1
    800012b6:	84b2                	mv	s1,a2
    800012b8:	86dff0ef          	jal	80000b24 <kalloc>
    800012bc:	892a                	mv	s2,a0
    800012be:	6605                	lui	a2,0x1
    800012c0:	4581                	li	a1,0
    800012c2:	a07ff0ef          	jal	80000cc8 <memset>
    800012c6:	4779                	li	a4,30
    800012c8:	86ca                	mv	a3,s2
    800012ca:	6605                	lui	a2,0x1
    800012cc:	4581                	li	a1,0
    800012ce:	8552                	mv	a0,s4
    800012d0:	d45ff0ef          	jal	80001014 <mappages>
    800012d4:	8626                	mv	a2,s1
    800012d6:	85ce                	mv	a1,s3
    800012d8:	854a                	mv	a0,s2
    800012da:	a4bff0ef          	jal	80000d24 <memmove>
    800012de:	70a2                	ld	ra,40(sp)
    800012e0:	7402                	ld	s0,32(sp)
    800012e2:	64e2                	ld	s1,24(sp)
    800012e4:	6942                	ld	s2,16(sp)
    800012e6:	69a2                	ld	s3,8(sp)
    800012e8:	6a02                	ld	s4,0(sp)
    800012ea:	6145                	addi	sp,sp,48
    800012ec:	8082                	ret
    800012ee:	00006517          	auipc	a0,0x6
    800012f2:	e8250513          	addi	a0,a0,-382 # 80007170 <etext+0x170>
    800012f6:	c9eff0ef          	jal	80000794 <panic>

00000000800012fa <uvmdealloc>:
    800012fa:	1101                	addi	sp,sp,-32
    800012fc:	ec06                	sd	ra,24(sp)
    800012fe:	e822                	sd	s0,16(sp)
    80001300:	e426                	sd	s1,8(sp)
    80001302:	1000                	addi	s0,sp,32
    80001304:	84ae                	mv	s1,a1
    80001306:	00b67d63          	bgeu	a2,a1,80001320 <uvmdealloc+0x26>
    8000130a:	84b2                	mv	s1,a2
    8000130c:	6785                	lui	a5,0x1
    8000130e:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001310:	00f60733          	add	a4,a2,a5
    80001314:	76fd                	lui	a3,0xfffff
    80001316:	8f75                	and	a4,a4,a3
    80001318:	97ae                	add	a5,a5,a1
    8000131a:	8ff5                	and	a5,a5,a3
    8000131c:	00f76863          	bltu	a4,a5,8000132c <uvmdealloc+0x32>
    80001320:	8526                	mv	a0,s1
    80001322:	60e2                	ld	ra,24(sp)
    80001324:	6442                	ld	s0,16(sp)
    80001326:	64a2                	ld	s1,8(sp)
    80001328:	6105                	addi	sp,sp,32
    8000132a:	8082                	ret
    8000132c:	8f99                	sub	a5,a5,a4
    8000132e:	83b1                	srli	a5,a5,0xc
    80001330:	4685                	li	a3,1
    80001332:	0007861b          	sext.w	a2,a5
    80001336:	85ba                	mv	a1,a4
    80001338:	e83ff0ef          	jal	800011ba <uvmunmap>
    8000133c:	b7d5                	j	80001320 <uvmdealloc+0x26>

000000008000133e <uvmalloc>:
    8000133e:	08b66f63          	bltu	a2,a1,800013dc <uvmalloc+0x9e>
    80001342:	7139                	addi	sp,sp,-64
    80001344:	fc06                	sd	ra,56(sp)
    80001346:	f822                	sd	s0,48(sp)
    80001348:	ec4e                	sd	s3,24(sp)
    8000134a:	e852                	sd	s4,16(sp)
    8000134c:	e456                	sd	s5,8(sp)
    8000134e:	0080                	addi	s0,sp,64
    80001350:	8aaa                	mv	s5,a0
    80001352:	8a32                	mv	s4,a2
    80001354:	6785                	lui	a5,0x1
    80001356:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001358:	95be                	add	a1,a1,a5
    8000135a:	77fd                	lui	a5,0xfffff
    8000135c:	00f5f9b3          	and	s3,a1,a5
    80001360:	08c9f063          	bgeu	s3,a2,800013e0 <uvmalloc+0xa2>
    80001364:	f426                	sd	s1,40(sp)
    80001366:	f04a                	sd	s2,32(sp)
    80001368:	e05a                	sd	s6,0(sp)
    8000136a:	894e                	mv	s2,s3
    8000136c:	0126eb13          	ori	s6,a3,18
    80001370:	fb4ff0ef          	jal	80000b24 <kalloc>
    80001374:	84aa                	mv	s1,a0
    80001376:	c515                	beqz	a0,800013a2 <uvmalloc+0x64>
    80001378:	6605                	lui	a2,0x1
    8000137a:	4581                	li	a1,0
    8000137c:	94dff0ef          	jal	80000cc8 <memset>
    80001380:	875a                	mv	a4,s6
    80001382:	86a6                	mv	a3,s1
    80001384:	6605                	lui	a2,0x1
    80001386:	85ca                	mv	a1,s2
    80001388:	8556                	mv	a0,s5
    8000138a:	c8bff0ef          	jal	80001014 <mappages>
    8000138e:	e915                	bnez	a0,800013c2 <uvmalloc+0x84>
    80001390:	6785                	lui	a5,0x1
    80001392:	993e                	add	s2,s2,a5
    80001394:	fd496ee3          	bltu	s2,s4,80001370 <uvmalloc+0x32>
    80001398:	8552                	mv	a0,s4
    8000139a:	74a2                	ld	s1,40(sp)
    8000139c:	7902                	ld	s2,32(sp)
    8000139e:	6b02                	ld	s6,0(sp)
    800013a0:	a811                	j	800013b4 <uvmalloc+0x76>
    800013a2:	864e                	mv	a2,s3
    800013a4:	85ca                	mv	a1,s2
    800013a6:	8556                	mv	a0,s5
    800013a8:	f53ff0ef          	jal	800012fa <uvmdealloc>
    800013ac:	4501                	li	a0,0
    800013ae:	74a2                	ld	s1,40(sp)
    800013b0:	7902                	ld	s2,32(sp)
    800013b2:	6b02                	ld	s6,0(sp)
    800013b4:	70e2                	ld	ra,56(sp)
    800013b6:	7442                	ld	s0,48(sp)
    800013b8:	69e2                	ld	s3,24(sp)
    800013ba:	6a42                	ld	s4,16(sp)
    800013bc:	6aa2                	ld	s5,8(sp)
    800013be:	6121                	addi	sp,sp,64
    800013c0:	8082                	ret
    800013c2:	8526                	mv	a0,s1
    800013c4:	e7eff0ef          	jal	80000a42 <kfree>
    800013c8:	864e                	mv	a2,s3
    800013ca:	85ca                	mv	a1,s2
    800013cc:	8556                	mv	a0,s5
    800013ce:	f2dff0ef          	jal	800012fa <uvmdealloc>
    800013d2:	4501                	li	a0,0
    800013d4:	74a2                	ld	s1,40(sp)
    800013d6:	7902                	ld	s2,32(sp)
    800013d8:	6b02                	ld	s6,0(sp)
    800013da:	bfe9                	j	800013b4 <uvmalloc+0x76>
    800013dc:	852e                	mv	a0,a1
    800013de:	8082                	ret
    800013e0:	8532                	mv	a0,a2
    800013e2:	bfc9                	j	800013b4 <uvmalloc+0x76>

00000000800013e4 <freewalk>:
    800013e4:	7179                	addi	sp,sp,-48
    800013e6:	f406                	sd	ra,40(sp)
    800013e8:	f022                	sd	s0,32(sp)
    800013ea:	ec26                	sd	s1,24(sp)
    800013ec:	e84a                	sd	s2,16(sp)
    800013ee:	e44e                	sd	s3,8(sp)
    800013f0:	e052                	sd	s4,0(sp)
    800013f2:	1800                	addi	s0,sp,48
    800013f4:	8a2a                	mv	s4,a0
    800013f6:	84aa                	mv	s1,a0
    800013f8:	6905                	lui	s2,0x1
    800013fa:	992a                	add	s2,s2,a0
    800013fc:	4985                	li	s3,1
    800013fe:	a819                	j	80001414 <freewalk+0x30>
    80001400:	83a9                	srli	a5,a5,0xa
    80001402:	00c79513          	slli	a0,a5,0xc
    80001406:	fdfff0ef          	jal	800013e4 <freewalk>
    8000140a:	0004b023          	sd	zero,0(s1)
    8000140e:	04a1                	addi	s1,s1,8
    80001410:	01248f63          	beq	s1,s2,8000142e <freewalk+0x4a>
    80001414:	609c                	ld	a5,0(s1)
    80001416:	00f7f713          	andi	a4,a5,15
    8000141a:	ff3703e3          	beq	a4,s3,80001400 <freewalk+0x1c>
    8000141e:	8b85                	andi	a5,a5,1
    80001420:	d7fd                	beqz	a5,8000140e <freewalk+0x2a>
    80001422:	00006517          	auipc	a0,0x6
    80001426:	d6e50513          	addi	a0,a0,-658 # 80007190 <etext+0x190>
    8000142a:	b6aff0ef          	jal	80000794 <panic>
    8000142e:	8552                	mv	a0,s4
    80001430:	e12ff0ef          	jal	80000a42 <kfree>
    80001434:	70a2                	ld	ra,40(sp)
    80001436:	7402                	ld	s0,32(sp)
    80001438:	64e2                	ld	s1,24(sp)
    8000143a:	6942                	ld	s2,16(sp)
    8000143c:	69a2                	ld	s3,8(sp)
    8000143e:	6a02                	ld	s4,0(sp)
    80001440:	6145                	addi	sp,sp,48
    80001442:	8082                	ret

0000000080001444 <uvmfree>:
    80001444:	1101                	addi	sp,sp,-32
    80001446:	ec06                	sd	ra,24(sp)
    80001448:	e822                	sd	s0,16(sp)
    8000144a:	e426                	sd	s1,8(sp)
    8000144c:	1000                	addi	s0,sp,32
    8000144e:	84aa                	mv	s1,a0
    80001450:	e989                	bnez	a1,80001462 <uvmfree+0x1e>
    80001452:	8526                	mv	a0,s1
    80001454:	f91ff0ef          	jal	800013e4 <freewalk>
    80001458:	60e2                	ld	ra,24(sp)
    8000145a:	6442                	ld	s0,16(sp)
    8000145c:	64a2                	ld	s1,8(sp)
    8000145e:	6105                	addi	sp,sp,32
    80001460:	8082                	ret
    80001462:	6785                	lui	a5,0x1
    80001464:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001466:	95be                	add	a1,a1,a5
    80001468:	4685                	li	a3,1
    8000146a:	00c5d613          	srli	a2,a1,0xc
    8000146e:	4581                	li	a1,0
    80001470:	d4bff0ef          	jal	800011ba <uvmunmap>
    80001474:	bff9                	j	80001452 <uvmfree+0xe>

0000000080001476 <uvmcopy>:
    80001476:	c65d                	beqz	a2,80001524 <uvmcopy+0xae>
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
    80001494:	4981                	li	s3,0
    80001496:	4601                	li	a2,0
    80001498:	85ce                	mv	a1,s3
    8000149a:	855a                	mv	a0,s6
    8000149c:	aa1ff0ef          	jal	80000f3c <walk>
    800014a0:	c121                	beqz	a0,800014e0 <uvmcopy+0x6a>
    800014a2:	6118                	ld	a4,0(a0)
    800014a4:	00177793          	andi	a5,a4,1
    800014a8:	c3b1                	beqz	a5,800014ec <uvmcopy+0x76>
    800014aa:	00a75593          	srli	a1,a4,0xa
    800014ae:	00c59b93          	slli	s7,a1,0xc
    800014b2:	3ff77493          	andi	s1,a4,1023
    800014b6:	e6eff0ef          	jal	80000b24 <kalloc>
    800014ba:	892a                	mv	s2,a0
    800014bc:	c129                	beqz	a0,800014fe <uvmcopy+0x88>
    800014be:	6605                	lui	a2,0x1
    800014c0:	85de                	mv	a1,s7
    800014c2:	863ff0ef          	jal	80000d24 <memmove>
    800014c6:	8726                	mv	a4,s1
    800014c8:	86ca                	mv	a3,s2
    800014ca:	6605                	lui	a2,0x1
    800014cc:	85ce                	mv	a1,s3
    800014ce:	8556                	mv	a0,s5
    800014d0:	b45ff0ef          	jal	80001014 <mappages>
    800014d4:	e115                	bnez	a0,800014f8 <uvmcopy+0x82>
    800014d6:	6785                	lui	a5,0x1
    800014d8:	99be                	add	s3,s3,a5
    800014da:	fb49eee3          	bltu	s3,s4,80001496 <uvmcopy+0x20>
    800014de:	a805                	j	8000150e <uvmcopy+0x98>
    800014e0:	00006517          	auipc	a0,0x6
    800014e4:	cc050513          	addi	a0,a0,-832 # 800071a0 <etext+0x1a0>
    800014e8:	aacff0ef          	jal	80000794 <panic>
    800014ec:	00006517          	auipc	a0,0x6
    800014f0:	cd450513          	addi	a0,a0,-812 # 800071c0 <etext+0x1c0>
    800014f4:	aa0ff0ef          	jal	80000794 <panic>
    800014f8:	854a                	mv	a0,s2
    800014fa:	d48ff0ef          	jal	80000a42 <kfree>
    800014fe:	4685                	li	a3,1
    80001500:	00c9d613          	srli	a2,s3,0xc
    80001504:	4581                	li	a1,0
    80001506:	8556                	mv	a0,s5
    80001508:	cb3ff0ef          	jal	800011ba <uvmunmap>
    8000150c:	557d                	li	a0,-1
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
    80001524:	4501                	li	a0,0
    80001526:	8082                	ret

0000000080001528 <uvmclear>:
    80001528:	1141                	addi	sp,sp,-16
    8000152a:	e406                	sd	ra,8(sp)
    8000152c:	e022                	sd	s0,0(sp)
    8000152e:	0800                	addi	s0,sp,16
    80001530:	4601                	li	a2,0
    80001532:	a0bff0ef          	jal	80000f3c <walk>
    80001536:	c901                	beqz	a0,80001546 <uvmclear+0x1e>
    80001538:	611c                	ld	a5,0(a0)
    8000153a:	9bbd                	andi	a5,a5,-17
    8000153c:	e11c                	sd	a5,0(a0)
    8000153e:	60a2                	ld	ra,8(sp)
    80001540:	6402                	ld	s0,0(sp)
    80001542:	0141                	addi	sp,sp,16
    80001544:	8082                	ret
    80001546:	00006517          	auipc	a0,0x6
    8000154a:	c9a50513          	addi	a0,a0,-870 # 800071e0 <etext+0x1e0>
    8000154e:	a46ff0ef          	jal	80000794 <panic>

0000000080001552 <copyout>:
    80001552:	cad1                	beqz	a3,800015e6 <copyout+0x94>
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
    8000156e:	74fd                	lui	s1,0xfffff
    80001570:	8ced                	and	s1,s1,a1
    80001572:	57fd                	li	a5,-1
    80001574:	83e9                	srli	a5,a5,0x1a
    80001576:	0697ea63          	bltu	a5,s1,800015ea <copyout+0x98>
    8000157a:	e0ca                	sd	s2,64(sp)
    8000157c:	f852                	sd	s4,48(sp)
    8000157e:	e862                	sd	s8,16(sp)
    80001580:	e466                	sd	s9,8(sp)
    80001582:	e06a                	sd	s10,0(sp)
    80001584:	4cd5                	li	s9,21
    80001586:	6d05                	lui	s10,0x1
    80001588:	8c3e                	mv	s8,a5
    8000158a:	a025                	j	800015b2 <copyout+0x60>
    8000158c:	83a9                	srli	a5,a5,0xa
    8000158e:	07b2                	slli	a5,a5,0xc
    80001590:	409a8533          	sub	a0,s5,s1
    80001594:	0009061b          	sext.w	a2,s2
    80001598:	85da                	mv	a1,s6
    8000159a:	953e                	add	a0,a0,a5
    8000159c:	f88ff0ef          	jal	80000d24 <memmove>
    800015a0:	412989b3          	sub	s3,s3,s2
    800015a4:	9b4a                	add	s6,s6,s2
    800015a6:	02098963          	beqz	s3,800015d8 <copyout+0x86>
    800015aa:	054c6263          	bltu	s8,s4,800015ee <copyout+0x9c>
    800015ae:	84d2                	mv	s1,s4
    800015b0:	8ad2                	mv	s5,s4
    800015b2:	4601                	li	a2,0
    800015b4:	85a6                	mv	a1,s1
    800015b6:	855e                	mv	a0,s7
    800015b8:	985ff0ef          	jal	80000f3c <walk>
    800015bc:	c121                	beqz	a0,800015fc <copyout+0xaa>
    800015be:	611c                	ld	a5,0(a0)
    800015c0:	0157f713          	andi	a4,a5,21
    800015c4:	05971b63          	bne	a4,s9,8000161a <copyout+0xc8>
    800015c8:	01a48a33          	add	s4,s1,s10
    800015cc:	415a0933          	sub	s2,s4,s5
    800015d0:	fb29fee3          	bgeu	s3,s2,8000158c <copyout+0x3a>
    800015d4:	894e                	mv	s2,s3
    800015d6:	bf5d                	j	8000158c <copyout+0x3a>
    800015d8:	4501                	li	a0,0
    800015da:	6906                	ld	s2,64(sp)
    800015dc:	7a42                	ld	s4,48(sp)
    800015de:	6c42                	ld	s8,16(sp)
    800015e0:	6ca2                	ld	s9,8(sp)
    800015e2:	6d02                	ld	s10,0(sp)
    800015e4:	a015                	j	80001608 <copyout+0xb6>
    800015e6:	4501                	li	a0,0
    800015e8:	8082                	ret
    800015ea:	557d                	li	a0,-1
    800015ec:	a831                	j	80001608 <copyout+0xb6>
    800015ee:	557d                	li	a0,-1
    800015f0:	6906                	ld	s2,64(sp)
    800015f2:	7a42                	ld	s4,48(sp)
    800015f4:	6c42                	ld	s8,16(sp)
    800015f6:	6ca2                	ld	s9,8(sp)
    800015f8:	6d02                	ld	s10,0(sp)
    800015fa:	a039                	j	80001608 <copyout+0xb6>
    800015fc:	557d                	li	a0,-1
    800015fe:	6906                	ld	s2,64(sp)
    80001600:	7a42                	ld	s4,48(sp)
    80001602:	6c42                	ld	s8,16(sp)
    80001604:	6ca2                	ld	s9,8(sp)
    80001606:	6d02                	ld	s10,0(sp)
    80001608:	60e6                	ld	ra,88(sp)
    8000160a:	6446                	ld	s0,80(sp)
    8000160c:	64a6                	ld	s1,72(sp)
    8000160e:	79e2                	ld	s3,56(sp)
    80001610:	7aa2                	ld	s5,40(sp)
    80001612:	7b02                	ld	s6,32(sp)
    80001614:	6be2                	ld	s7,24(sp)
    80001616:	6125                	addi	sp,sp,96
    80001618:	8082                	ret
    8000161a:	557d                	li	a0,-1
    8000161c:	6906                	ld	s2,64(sp)
    8000161e:	7a42                	ld	s4,48(sp)
    80001620:	6c42                	ld	s8,16(sp)
    80001622:	6ca2                	ld	s9,8(sp)
    80001624:	6d02                	ld	s10,0(sp)
    80001626:	b7cd                	j	80001608 <copyout+0xb6>

0000000080001628 <copyin>:
    80001628:	c6a5                	beqz	a3,80001690 <copyin+0x68>
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
    8000164a:	7bfd                	lui	s7,0xfffff
    8000164c:	6a85                	lui	s5,0x1
    8000164e:	a00d                	j	80001670 <copyin+0x48>
    80001650:	018505b3          	add	a1,a0,s8
    80001654:	0004861b          	sext.w	a2,s1
    80001658:	412585b3          	sub	a1,a1,s2
    8000165c:	8552                	mv	a0,s4
    8000165e:	ec6ff0ef          	jal	80000d24 <memmove>
    80001662:	409989b3          	sub	s3,s3,s1
    80001666:	9a26                	add	s4,s4,s1
    80001668:	01590c33          	add	s8,s2,s5
    8000166c:	02098063          	beqz	s3,8000168c <copyin+0x64>
    80001670:	017c7933          	and	s2,s8,s7
    80001674:	85ca                	mv	a1,s2
    80001676:	855a                	mv	a0,s6
    80001678:	95fff0ef          	jal	80000fd6 <walkaddr>
    8000167c:	cd01                	beqz	a0,80001694 <copyin+0x6c>
    8000167e:	418904b3          	sub	s1,s2,s8
    80001682:	94d6                	add	s1,s1,s5
    80001684:	fc99f6e3          	bgeu	s3,s1,80001650 <copyin+0x28>
    80001688:	84ce                	mv	s1,s3
    8000168a:	b7d9                	j	80001650 <copyin+0x28>
    8000168c:	4501                	li	a0,0
    8000168e:	a021                	j	80001696 <copyin+0x6e>
    80001690:	4501                	li	a0,0
    80001692:	8082                	ret
    80001694:	557d                	li	a0,-1
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
    800016ae:	c6dd                	beqz	a3,8000175c <copyinstr+0xae>
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
    800016ce:	7afd                	lui	s5,0xfffff
    800016d0:	6985                	lui	s3,0x1
    800016d2:	a825                	j	8000170a <copyinstr+0x5c>
    800016d4:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800016d8:	4785                	li	a5,1
    800016da:	37fd                	addiw	a5,a5,-1
    800016dc:	0007851b          	sext.w	a0,a5
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
    800016fc:	40b70933          	sub	s2,a4,a1
    80001700:	01348bb3          	add	s7,s1,s3
    80001704:	04e58463          	beq	a1,a4,8000174c <copyinstr+0x9e>
    80001708:	8b3e                	mv	s6,a5
    8000170a:	015bf4b3          	and	s1,s7,s5
    8000170e:	85a6                	mv	a1,s1
    80001710:	8552                	mv	a0,s4
    80001712:	8c5ff0ef          	jal	80000fd6 <walkaddr>
    80001716:	cd0d                	beqz	a0,80001750 <copyinstr+0xa2>
    80001718:	417486b3          	sub	a3,s1,s7
    8000171c:	96ce                	add	a3,a3,s3
    8000171e:	00d97363          	bgeu	s2,a3,80001724 <copyinstr+0x76>
    80001722:	86ca                	mv	a3,s2
    80001724:	955e                	add	a0,a0,s7
    80001726:	8d05                	sub	a0,a0,s1
    80001728:	c695                	beqz	a3,80001754 <copyinstr+0xa6>
    8000172a:	87da                	mv	a5,s6
    8000172c:	885a                	mv	a6,s6
    8000172e:	41650633          	sub	a2,a0,s6
    80001732:	96da                	add	a3,a3,s6
    80001734:	85be                	mv	a1,a5
    80001736:	00f60733          	add	a4,a2,a5
    8000173a:	00074703          	lbu	a4,0(a4)
    8000173e:	db59                	beqz	a4,800016d4 <copyinstr+0x26>
    80001740:	00e78023          	sb	a4,0(a5)
    80001744:	0785                	addi	a5,a5,1
    80001746:	fed797e3          	bne	a5,a3,80001734 <copyinstr+0x86>
    8000174a:	b775                	j	800016f6 <copyinstr+0x48>
    8000174c:	4781                	li	a5,0
    8000174e:	b771                	j	800016da <copyinstr+0x2c>
    80001750:	557d                	li	a0,-1
    80001752:	b779                	j	800016e0 <copyinstr+0x32>
    80001754:	6b85                	lui	s7,0x1
    80001756:	9ba6                	add	s7,s7,s1
    80001758:	87da                	mv	a5,s6
    8000175a:	b77d                	j	80001708 <copyinstr+0x5a>
    8000175c:	4781                	li	a5,0
    8000175e:	37fd                	addiw	a5,a5,-1
    80001760:	0007851b          	sext.w	a0,a5
    80001764:	8082                	ret

0000000080001766 <proc_mapstacks>:
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
    8000177c:	00011497          	auipc	s1,0x11
    80001780:	23448493          	addi	s1,s1,564 # 800129b0 <proc>
    80001784:	8b26                	mv	s6,s1
    80001786:	ff4df937          	lui	s2,0xff4df
    8000178a:	9bd90913          	addi	s2,s2,-1603 # ffffffffff4de9bd <end+0xffffffff7f4b5415>
    8000178e:	0936                	slli	s2,s2,0xd
    80001790:	6f590913          	addi	s2,s2,1781
    80001794:	0936                	slli	s2,s2,0xd
    80001796:	bd390913          	addi	s2,s2,-1069
    8000179a:	0932                	slli	s2,s2,0xc
    8000179c:	7a790913          	addi	s2,s2,1959
    800017a0:	040009b7          	lui	s3,0x4000
    800017a4:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    800017a6:	09b2                	slli	s3,s3,0xc
    800017a8:	00017a97          	auipc	s5,0x17
    800017ac:	e08a8a93          	addi	s5,s5,-504 # 800185b0 <ptable>
    800017b0:	b74ff0ef          	jal	80000b24 <kalloc>
    800017b4:	862a                	mv	a2,a0
    800017b6:	cd15                	beqz	a0,800017f2 <proc_mapstacks+0x8c>
    800017b8:	416485b3          	sub	a1,s1,s6
    800017bc:	8591                	srai	a1,a1,0x4
    800017be:	032585b3          	mul	a1,a1,s2
    800017c2:	2585                	addiw	a1,a1,1
    800017c4:	00d5959b          	slliw	a1,a1,0xd
    800017c8:	4719                	li	a4,6
    800017ca:	6685                	lui	a3,0x1
    800017cc:	40b985b3          	sub	a1,s3,a1
    800017d0:	8552                	mv	a0,s4
    800017d2:	8f3ff0ef          	jal	800010c4 <kvmmap>
    800017d6:	17048493          	addi	s1,s1,368
    800017da:	fd549be3          	bne	s1,s5,800017b0 <proc_mapstacks+0x4a>
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
    800017f2:	00006517          	auipc	a0,0x6
    800017f6:	9fe50513          	addi	a0,a0,-1538 # 800071f0 <etext+0x1f0>
    800017fa:	f9bfe0ef          	jal	80000794 <panic>

00000000800017fe <procinit>:
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
    80001812:	00006597          	auipc	a1,0x6
    80001816:	9e658593          	addi	a1,a1,-1562 # 800071f8 <etext+0x1f8>
    8000181a:	00011517          	auipc	a0,0x11
    8000181e:	d6650513          	addi	a0,a0,-666 # 80012580 <pid_lock>
    80001822:	b52ff0ef          	jal	80000b74 <initlock>
    80001826:	00006597          	auipc	a1,0x6
    8000182a:	9da58593          	addi	a1,a1,-1574 # 80007200 <etext+0x200>
    8000182e:	00011517          	auipc	a0,0x11
    80001832:	d6a50513          	addi	a0,a0,-662 # 80012598 <wait_lock>
    80001836:	b3eff0ef          	jal	80000b74 <initlock>
    8000183a:	00011497          	auipc	s1,0x11
    8000183e:	17648493          	addi	s1,s1,374 # 800129b0 <proc>
    80001842:	00006b17          	auipc	s6,0x6
    80001846:	9ceb0b13          	addi	s6,s6,-1586 # 80007210 <etext+0x210>
    8000184a:	8aa6                	mv	s5,s1
    8000184c:	ff4df937          	lui	s2,0xff4df
    80001850:	9bd90913          	addi	s2,s2,-1603 # ffffffffff4de9bd <end+0xffffffff7f4b5415>
    80001854:	0936                	slli	s2,s2,0xd
    80001856:	6f590913          	addi	s2,s2,1781
    8000185a:	0936                	slli	s2,s2,0xd
    8000185c:	bd390913          	addi	s2,s2,-1069
    80001860:	0932                	slli	s2,s2,0xc
    80001862:	7a790913          	addi	s2,s2,1959
    80001866:	040009b7          	lui	s3,0x4000
    8000186a:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    8000186c:	09b2                	slli	s3,s3,0xc
    8000186e:	00017a17          	auipc	s4,0x17
    80001872:	d42a0a13          	addi	s4,s4,-702 # 800185b0 <ptable>
    80001876:	85da                	mv	a1,s6
    80001878:	8526                	mv	a0,s1
    8000187a:	afaff0ef          	jal	80000b74 <initlock>
    8000187e:	0004ae23          	sw	zero,28(s1)
    80001882:	415487b3          	sub	a5,s1,s5
    80001886:	8791                	srai	a5,a5,0x4
    80001888:	032787b3          	mul	a5,a5,s2
    8000188c:	2785                	addiw	a5,a5,1
    8000188e:	00d7979b          	slliw	a5,a5,0xd
    80001892:	40f987b3          	sub	a5,s3,a5
    80001896:	e0bc                	sd	a5,64(s1)
    80001898:	17048493          	addi	s1,s1,368
    8000189c:	fd449de3          	bne	s1,s4,80001876 <procinit+0x78>
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
    800018b4:	1141                	addi	sp,sp,-16
    800018b6:	e422                	sd	s0,8(sp)
    800018b8:	0800                	addi	s0,sp,16
    800018ba:	8512                	mv	a0,tp
    800018bc:	2501                	sext.w	a0,a0
    800018be:	6422                	ld	s0,8(sp)
    800018c0:	0141                	addi	sp,sp,16
    800018c2:	8082                	ret

00000000800018c4 <mycpu>:
    800018c4:	1141                	addi	sp,sp,-16
    800018c6:	e422                	sd	s0,8(sp)
    800018c8:	0800                	addi	s0,sp,16
    800018ca:	8792                	mv	a5,tp
    800018cc:	2781                	sext.w	a5,a5
    800018ce:	079e                	slli	a5,a5,0x7
    800018d0:	00011517          	auipc	a0,0x11
    800018d4:	ce050513          	addi	a0,a0,-800 # 800125b0 <cpus>
    800018d8:	953e                	add	a0,a0,a5
    800018da:	6422                	ld	s0,8(sp)
    800018dc:	0141                	addi	sp,sp,16
    800018de:	8082                	ret

00000000800018e0 <myproc>:
    800018e0:	1101                	addi	sp,sp,-32
    800018e2:	ec06                	sd	ra,24(sp)
    800018e4:	e822                	sd	s0,16(sp)
    800018e6:	e426                	sd	s1,8(sp)
    800018e8:	1000                	addi	s0,sp,32
    800018ea:	acaff0ef          	jal	80000bb4 <push_off>
    800018ee:	8792                	mv	a5,tp
    800018f0:	2781                	sext.w	a5,a5
    800018f2:	079e                	slli	a5,a5,0x7
    800018f4:	00011717          	auipc	a4,0x11
    800018f8:	c8c70713          	addi	a4,a4,-884 # 80012580 <pid_lock>
    800018fc:	97ba                	add	a5,a5,a4
    800018fe:	7b84                	ld	s1,48(a5)
    80001900:	b38ff0ef          	jal	80000c38 <pop_off>
    80001904:	8526                	mv	a0,s1
    80001906:	60e2                	ld	ra,24(sp)
    80001908:	6442                	ld	s0,16(sp)
    8000190a:	64a2                	ld	s1,8(sp)
    8000190c:	6105                	addi	sp,sp,32
    8000190e:	8082                	ret

0000000080001910 <forkret>:
    80001910:	1141                	addi	sp,sp,-16
    80001912:	e406                	sd	ra,8(sp)
    80001914:	e022                	sd	s0,0(sp)
    80001916:	0800                	addi	s0,sp,16
    80001918:	fc9ff0ef          	jal	800018e0 <myproc>
    8000191c:	b70ff0ef          	jal	80000c8c <release>
    80001920:	00009797          	auipc	a5,0x9
    80001924:	a907a783          	lw	a5,-1392(a5) # 8000a3b0 <first.1>
    80001928:	e799                	bnez	a5,80001936 <forkret+0x26>
    8000192a:	4a3000ef          	jal	800025cc <usertrapret>
    8000192e:	60a2                	ld	ra,8(sp)
    80001930:	6402                	ld	s0,0(sp)
    80001932:	0141                	addi	sp,sp,16
    80001934:	8082                	ret
    80001936:	4505                	li	a0,1
    80001938:	0ff010ef          	jal	80003236 <fsinit>
    8000193c:	00009797          	auipc	a5,0x9
    80001940:	a607aa23          	sw	zero,-1420(a5) # 8000a3b0 <first.1>
    80001944:	0330000f          	fence	rw,rw
    80001948:	b7cd                	j	8000192a <forkret+0x1a>

000000008000194a <allocpid>:
    8000194a:	1101                	addi	sp,sp,-32
    8000194c:	ec06                	sd	ra,24(sp)
    8000194e:	e822                	sd	s0,16(sp)
    80001950:	e426                	sd	s1,8(sp)
    80001952:	e04a                	sd	s2,0(sp)
    80001954:	1000                	addi	s0,sp,32
    80001956:	00011917          	auipc	s2,0x11
    8000195a:	c2a90913          	addi	s2,s2,-982 # 80012580 <pid_lock>
    8000195e:	854a                	mv	a0,s2
    80001960:	a94ff0ef          	jal	80000bf4 <acquire>
    80001964:	00009797          	auipc	a5,0x9
    80001968:	a5078793          	addi	a5,a5,-1456 # 8000a3b4 <nextpid>
    8000196c:	4384                	lw	s1,0(a5)
    8000196e:	0014871b          	addiw	a4,s1,1
    80001972:	c398                	sw	a4,0(a5)
    80001974:	854a                	mv	a0,s2
    80001976:	b16ff0ef          	jal	80000c8c <release>
    8000197a:	8526                	mv	a0,s1
    8000197c:	60e2                	ld	ra,24(sp)
    8000197e:	6442                	ld	s0,16(sp)
    80001980:	64a2                	ld	s1,8(sp)
    80001982:	6902                	ld	s2,0(sp)
    80001984:	6105                	addi	sp,sp,32
    80001986:	8082                	ret

0000000080001988 <proc_pagetable>:
    80001988:	1101                	addi	sp,sp,-32
    8000198a:	ec06                	sd	ra,24(sp)
    8000198c:	e822                	sd	s0,16(sp)
    8000198e:	e426                	sd	s1,8(sp)
    80001990:	e04a                	sd	s2,0(sp)
    80001992:	1000                	addi	s0,sp,32
    80001994:	892a                	mv	s2,a0
    80001996:	8e1ff0ef          	jal	80001276 <uvmcreate>
    8000199a:	84aa                	mv	s1,a0
    8000199c:	cd05                	beqz	a0,800019d4 <proc_pagetable+0x4c>
    8000199e:	4729                	li	a4,10
    800019a0:	00004697          	auipc	a3,0x4
    800019a4:	66068693          	addi	a3,a3,1632 # 80006000 <_trampoline>
    800019a8:	6605                	lui	a2,0x1
    800019aa:	040005b7          	lui	a1,0x4000
    800019ae:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800019b0:	05b2                	slli	a1,a1,0xc
    800019b2:	e62ff0ef          	jal	80001014 <mappages>
    800019b6:	02054663          	bltz	a0,800019e2 <proc_pagetable+0x5a>
    800019ba:	4719                	li	a4,6
    800019bc:	05893683          	ld	a3,88(s2)
    800019c0:	6605                	lui	a2,0x1
    800019c2:	020005b7          	lui	a1,0x2000
    800019c6:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    800019c8:	05b6                	slli	a1,a1,0xd
    800019ca:	8526                	mv	a0,s1
    800019cc:	e48ff0ef          	jal	80001014 <mappages>
    800019d0:	00054f63          	bltz	a0,800019ee <proc_pagetable+0x66>
    800019d4:	8526                	mv	a0,s1
    800019d6:	60e2                	ld	ra,24(sp)
    800019d8:	6442                	ld	s0,16(sp)
    800019da:	64a2                	ld	s1,8(sp)
    800019dc:	6902                	ld	s2,0(sp)
    800019de:	6105                	addi	sp,sp,32
    800019e0:	8082                	ret
    800019e2:	4581                	li	a1,0
    800019e4:	8526                	mv	a0,s1
    800019e6:	a5fff0ef          	jal	80001444 <uvmfree>
    800019ea:	4481                	li	s1,0
    800019ec:	b7e5                	j	800019d4 <proc_pagetable+0x4c>
    800019ee:	4681                	li	a3,0
    800019f0:	4605                	li	a2,1
    800019f2:	040005b7          	lui	a1,0x4000
    800019f6:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800019f8:	05b2                	slli	a1,a1,0xc
    800019fa:	8526                	mv	a0,s1
    800019fc:	fbeff0ef          	jal	800011ba <uvmunmap>
    80001a00:	4581                	li	a1,0
    80001a02:	8526                	mv	a0,s1
    80001a04:	a41ff0ef          	jal	80001444 <uvmfree>
    80001a08:	4481                	li	s1,0
    80001a0a:	b7e9                	j	800019d4 <proc_pagetable+0x4c>

0000000080001a0c <proc_freepagetable>:
    80001a0c:	1101                	addi	sp,sp,-32
    80001a0e:	ec06                	sd	ra,24(sp)
    80001a10:	e822                	sd	s0,16(sp)
    80001a12:	e426                	sd	s1,8(sp)
    80001a14:	e04a                	sd	s2,0(sp)
    80001a16:	1000                	addi	s0,sp,32
    80001a18:	84aa                	mv	s1,a0
    80001a1a:	892e                	mv	s2,a1
    80001a1c:	4681                	li	a3,0
    80001a1e:	4605                	li	a2,1
    80001a20:	040005b7          	lui	a1,0x4000
    80001a24:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001a26:	05b2                	slli	a1,a1,0xc
    80001a28:	f92ff0ef          	jal	800011ba <uvmunmap>
    80001a2c:	4681                	li	a3,0
    80001a2e:	4605                	li	a2,1
    80001a30:	020005b7          	lui	a1,0x2000
    80001a34:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001a36:	05b6                	slli	a1,a1,0xd
    80001a38:	8526                	mv	a0,s1
    80001a3a:	f80ff0ef          	jal	800011ba <uvmunmap>
    80001a3e:	85ca                	mv	a1,s2
    80001a40:	8526                	mv	a0,s1
    80001a42:	a03ff0ef          	jal	80001444 <uvmfree>
    80001a46:	60e2                	ld	ra,24(sp)
    80001a48:	6442                	ld	s0,16(sp)
    80001a4a:	64a2                	ld	s1,8(sp)
    80001a4c:	6902                	ld	s2,0(sp)
    80001a4e:	6105                	addi	sp,sp,32
    80001a50:	8082                	ret

0000000080001a52 <freeproc>:
    80001a52:	1101                	addi	sp,sp,-32
    80001a54:	ec06                	sd	ra,24(sp)
    80001a56:	e822                	sd	s0,16(sp)
    80001a58:	e426                	sd	s1,8(sp)
    80001a5a:	1000                	addi	s0,sp,32
    80001a5c:	84aa                	mv	s1,a0
    80001a5e:	6d28                	ld	a0,88(a0)
    80001a60:	c119                	beqz	a0,80001a66 <freeproc+0x14>
    80001a62:	fe1fe0ef          	jal	80000a42 <kfree>
    80001a66:	0404bc23          	sd	zero,88(s1)
    80001a6a:	68a8                	ld	a0,80(s1)
    80001a6c:	c501                	beqz	a0,80001a74 <freeproc+0x22>
    80001a6e:	64ac                	ld	a1,72(s1)
    80001a70:	f9dff0ef          	jal	80001a0c <proc_freepagetable>
    80001a74:	0404b823          	sd	zero,80(s1)
    80001a78:	0404b423          	sd	zero,72(s1)
    80001a7c:	0204a823          	sw	zero,48(s1)
    80001a80:	0204bc23          	sd	zero,56(s1)
    80001a84:	14048c23          	sb	zero,344(s1)
    80001a88:	0204b023          	sd	zero,32(s1)
    80001a8c:	0204a423          	sw	zero,40(s1)
    80001a90:	0204a623          	sw	zero,44(s1)
    80001a94:	0004ae23          	sw	zero,28(s1)
    80001a98:	60e2                	ld	ra,24(sp)
    80001a9a:	6442                	ld	s0,16(sp)
    80001a9c:	64a2                	ld	s1,8(sp)
    80001a9e:	6105                	addi	sp,sp,32
    80001aa0:	8082                	ret

0000000080001aa2 <allocproc>:
    80001aa2:	1101                	addi	sp,sp,-32
    80001aa4:	ec06                	sd	ra,24(sp)
    80001aa6:	e822                	sd	s0,16(sp)
    80001aa8:	e426                	sd	s1,8(sp)
    80001aaa:	e04a                	sd	s2,0(sp)
    80001aac:	1000                	addi	s0,sp,32
    80001aae:	00011497          	auipc	s1,0x11
    80001ab2:	f0248493          	addi	s1,s1,-254 # 800129b0 <proc>
    80001ab6:	00017917          	auipc	s2,0x17
    80001aba:	afa90913          	addi	s2,s2,-1286 # 800185b0 <ptable>
    80001abe:	8526                	mv	a0,s1
    80001ac0:	934ff0ef          	jal	80000bf4 <acquire>
    80001ac4:	4cdc                	lw	a5,28(s1)
    80001ac6:	cb91                	beqz	a5,80001ada <allocproc+0x38>
    80001ac8:	8526                	mv	a0,s1
    80001aca:	9c2ff0ef          	jal	80000c8c <release>
    80001ace:	17048493          	addi	s1,s1,368
    80001ad2:	ff2496e3          	bne	s1,s2,80001abe <allocproc+0x1c>
    80001ad6:	4481                	li	s1,0
    80001ad8:	a089                	j	80001b1a <allocproc+0x78>
    80001ada:	e71ff0ef          	jal	8000194a <allocpid>
    80001ade:	d888                	sw	a0,48(s1)
    80001ae0:	4785                	li	a5,1
    80001ae2:	ccdc                	sw	a5,28(s1)
    80001ae4:	840ff0ef          	jal	80000b24 <kalloc>
    80001ae8:	892a                	mv	s2,a0
    80001aea:	eca8                	sd	a0,88(s1)
    80001aec:	cd15                	beqz	a0,80001b28 <allocproc+0x86>
    80001aee:	8526                	mv	a0,s1
    80001af0:	e99ff0ef          	jal	80001988 <proc_pagetable>
    80001af4:	892a                	mv	s2,a0
    80001af6:	e8a8                	sd	a0,80(s1)
    80001af8:	c121                	beqz	a0,80001b38 <allocproc+0x96>
    80001afa:	07000613          	li	a2,112
    80001afe:	4581                	li	a1,0
    80001b00:	06048513          	addi	a0,s1,96
    80001b04:	9c4ff0ef          	jal	80000cc8 <memset>
    80001b08:	00000797          	auipc	a5,0x0
    80001b0c:	e0878793          	addi	a5,a5,-504 # 80001910 <forkret>
    80001b10:	f0bc                	sd	a5,96(s1)
    80001b12:	60bc                	ld	a5,64(s1)
    80001b14:	6705                	lui	a4,0x1
    80001b16:	97ba                	add	a5,a5,a4
    80001b18:	f4bc                	sd	a5,104(s1)
    80001b1a:	8526                	mv	a0,s1
    80001b1c:	60e2                	ld	ra,24(sp)
    80001b1e:	6442                	ld	s0,16(sp)
    80001b20:	64a2                	ld	s1,8(sp)
    80001b22:	6902                	ld	s2,0(sp)
    80001b24:	6105                	addi	sp,sp,32
    80001b26:	8082                	ret
    80001b28:	8526                	mv	a0,s1
    80001b2a:	f29ff0ef          	jal	80001a52 <freeproc>
    80001b2e:	8526                	mv	a0,s1
    80001b30:	95cff0ef          	jal	80000c8c <release>
    80001b34:	84ca                	mv	s1,s2
    80001b36:	b7d5                	j	80001b1a <allocproc+0x78>
    80001b38:	8526                	mv	a0,s1
    80001b3a:	f19ff0ef          	jal	80001a52 <freeproc>
    80001b3e:	8526                	mv	a0,s1
    80001b40:	94cff0ef          	jal	80000c8c <release>
    80001b44:	84ca                	mv	s1,s2
    80001b46:	bfd1                	j	80001b1a <allocproc+0x78>

0000000080001b48 <userinit>:
    80001b48:	1101                	addi	sp,sp,-32
    80001b4a:	ec06                	sd	ra,24(sp)
    80001b4c:	e822                	sd	s0,16(sp)
    80001b4e:	e426                	sd	s1,8(sp)
    80001b50:	1000                	addi	s0,sp,32
    80001b52:	f51ff0ef          	jal	80001aa2 <allocproc>
    80001b56:	84aa                	mv	s1,a0
    80001b58:	00009797          	auipc	a5,0x9
    80001b5c:	8ea7b823          	sd	a0,-1808(a5) # 8000a448 <initproc>
    80001b60:	03400613          	li	a2,52
    80001b64:	00009597          	auipc	a1,0x9
    80001b68:	85c58593          	addi	a1,a1,-1956 # 8000a3c0 <initcode>
    80001b6c:	6928                	ld	a0,80(a0)
    80001b6e:	f2eff0ef          	jal	8000129c <uvmfirst>
    80001b72:	6785                	lui	a5,0x1
    80001b74:	e4bc                	sd	a5,72(s1)
    80001b76:	6cb8                	ld	a4,88(s1)
    80001b78:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
    80001b7c:	6cb8                	ld	a4,88(s1)
    80001b7e:	fb1c                	sd	a5,48(a4)
    80001b80:	4641                	li	a2,16
    80001b82:	00005597          	auipc	a1,0x5
    80001b86:	69658593          	addi	a1,a1,1686 # 80007218 <etext+0x218>
    80001b8a:	15848513          	addi	a0,s1,344
    80001b8e:	a78ff0ef          	jal	80000e06 <safestrcpy>
    80001b92:	00005517          	auipc	a0,0x5
    80001b96:	69650513          	addi	a0,a0,1686 # 80007228 <etext+0x228>
    80001b9a:	7ab010ef          	jal	80003b44 <namei>
    80001b9e:	14a4b823          	sd	a0,336(s1)
    80001ba2:	478d                	li	a5,3
    80001ba4:	ccdc                	sw	a5,28(s1)
    80001ba6:	8526                	mv	a0,s1
    80001ba8:	8e4ff0ef          	jal	80000c8c <release>
    80001bac:	60e2                	ld	ra,24(sp)
    80001bae:	6442                	ld	s0,16(sp)
    80001bb0:	64a2                	ld	s1,8(sp)
    80001bb2:	6105                	addi	sp,sp,32
    80001bb4:	8082                	ret

0000000080001bb6 <growproc>:
    80001bb6:	1101                	addi	sp,sp,-32
    80001bb8:	ec06                	sd	ra,24(sp)
    80001bba:	e822                	sd	s0,16(sp)
    80001bbc:	e426                	sd	s1,8(sp)
    80001bbe:	e04a                	sd	s2,0(sp)
    80001bc0:	1000                	addi	s0,sp,32
    80001bc2:	892a                	mv	s2,a0
    80001bc4:	d1dff0ef          	jal	800018e0 <myproc>
    80001bc8:	84aa                	mv	s1,a0
    80001bca:	652c                	ld	a1,72(a0)
    80001bcc:	01204c63          	bgtz	s2,80001be4 <growproc+0x2e>
    80001bd0:	02094463          	bltz	s2,80001bf8 <growproc+0x42>
    80001bd4:	e4ac                	sd	a1,72(s1)
    80001bd6:	4501                	li	a0,0
    80001bd8:	60e2                	ld	ra,24(sp)
    80001bda:	6442                	ld	s0,16(sp)
    80001bdc:	64a2                	ld	s1,8(sp)
    80001bde:	6902                	ld	s2,0(sp)
    80001be0:	6105                	addi	sp,sp,32
    80001be2:	8082                	ret
    80001be4:	4691                	li	a3,4
    80001be6:	00b90633          	add	a2,s2,a1
    80001bea:	6928                	ld	a0,80(a0)
    80001bec:	f52ff0ef          	jal	8000133e <uvmalloc>
    80001bf0:	85aa                	mv	a1,a0
    80001bf2:	f16d                	bnez	a0,80001bd4 <growproc+0x1e>
    80001bf4:	557d                	li	a0,-1
    80001bf6:	b7cd                	j	80001bd8 <growproc+0x22>
    80001bf8:	00b90633          	add	a2,s2,a1
    80001bfc:	6928                	ld	a0,80(a0)
    80001bfe:	efcff0ef          	jal	800012fa <uvmdealloc>
    80001c02:	85aa                	mv	a1,a0
    80001c04:	bfc1                	j	80001bd4 <growproc+0x1e>

0000000080001c06 <fork>:
    80001c06:	7139                	addi	sp,sp,-64
    80001c08:	fc06                	sd	ra,56(sp)
    80001c0a:	f822                	sd	s0,48(sp)
    80001c0c:	f04a                	sd	s2,32(sp)
    80001c0e:	e456                	sd	s5,8(sp)
    80001c10:	0080                	addi	s0,sp,64
    80001c12:	ccfff0ef          	jal	800018e0 <myproc>
    80001c16:	8aaa                	mv	s5,a0
    80001c18:	e8bff0ef          	jal	80001aa2 <allocproc>
    80001c1c:	0e050a63          	beqz	a0,80001d10 <fork+0x10a>
    80001c20:	e852                	sd	s4,16(sp)
    80001c22:	8a2a                	mv	s4,a0
    80001c24:	048ab603          	ld	a2,72(s5)
    80001c28:	692c                	ld	a1,80(a0)
    80001c2a:	050ab503          	ld	a0,80(s5)
    80001c2e:	849ff0ef          	jal	80001476 <uvmcopy>
    80001c32:	04054a63          	bltz	a0,80001c86 <fork+0x80>
    80001c36:	f426                	sd	s1,40(sp)
    80001c38:	ec4e                	sd	s3,24(sp)
    80001c3a:	048ab783          	ld	a5,72(s5)
    80001c3e:	04fa3423          	sd	a5,72(s4)
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
    80001c70:	058a3783          	ld	a5,88(s4)
    80001c74:	0607b823          	sd	zero,112(a5)
    80001c78:	0d0a8493          	addi	s1,s5,208
    80001c7c:	0d0a0913          	addi	s2,s4,208
    80001c80:	150a8993          	addi	s3,s5,336
    80001c84:	a831                	j	80001ca0 <fork+0x9a>
    80001c86:	8552                	mv	a0,s4
    80001c88:	dcbff0ef          	jal	80001a52 <freeproc>
    80001c8c:	8552                	mv	a0,s4
    80001c8e:	ffffe0ef          	jal	80000c8c <release>
    80001c92:	597d                	li	s2,-1
    80001c94:	6a42                	ld	s4,16(sp)
    80001c96:	a0b5                	j	80001d02 <fork+0xfc>
    80001c98:	04a1                	addi	s1,s1,8
    80001c9a:	0921                	addi	s2,s2,8
    80001c9c:	01348963          	beq	s1,s3,80001cae <fork+0xa8>
    80001ca0:	6088                	ld	a0,0(s1)
    80001ca2:	d97d                	beqz	a0,80001c98 <fork+0x92>
    80001ca4:	430020ef          	jal	800040d4 <filedup>
    80001ca8:	00a93023          	sd	a0,0(s2)
    80001cac:	b7f5                	j	80001c98 <fork+0x92>
    80001cae:	150ab503          	ld	a0,336(s5)
    80001cb2:	782010ef          	jal	80003434 <idup>
    80001cb6:	14aa3823          	sd	a0,336(s4)
    80001cba:	4641                	li	a2,16
    80001cbc:	158a8593          	addi	a1,s5,344
    80001cc0:	158a0513          	addi	a0,s4,344
    80001cc4:	942ff0ef          	jal	80000e06 <safestrcpy>
    80001cc8:	030a2903          	lw	s2,48(s4)
    80001ccc:	8552                	mv	a0,s4
    80001cce:	fbffe0ef          	jal	80000c8c <release>
    80001cd2:	00011497          	auipc	s1,0x11
    80001cd6:	8c648493          	addi	s1,s1,-1850 # 80012598 <wait_lock>
    80001cda:	8526                	mv	a0,s1
    80001cdc:	f19fe0ef          	jal	80000bf4 <acquire>
    80001ce0:	035a3c23          	sd	s5,56(s4)
    80001ce4:	8526                	mv	a0,s1
    80001ce6:	fa7fe0ef          	jal	80000c8c <release>
    80001cea:	8552                	mv	a0,s4
    80001cec:	f09fe0ef          	jal	80000bf4 <acquire>
    80001cf0:	478d                	li	a5,3
    80001cf2:	00fa2e23          	sw	a5,28(s4)
    80001cf6:	8552                	mv	a0,s4
    80001cf8:	f95fe0ef          	jal	80000c8c <release>
    80001cfc:	74a2                	ld	s1,40(sp)
    80001cfe:	69e2                	ld	s3,24(sp)
    80001d00:	6a42                	ld	s4,16(sp)
    80001d02:	854a                	mv	a0,s2
    80001d04:	70e2                	ld	ra,56(sp)
    80001d06:	7442                	ld	s0,48(sp)
    80001d08:	7902                	ld	s2,32(sp)
    80001d0a:	6aa2                	ld	s5,8(sp)
    80001d0c:	6121                	addi	sp,sp,64
    80001d0e:	8082                	ret
    80001d10:	597d                	li	s2,-1
    80001d12:	bfc5                	j	80001d02 <fork+0xfc>

0000000080001d14 <scheduler>:
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
    80001d2e:	2781                	sext.w	a5,a5
    80001d30:	00779b13          	slli	s6,a5,0x7
    80001d34:	00011717          	auipc	a4,0x11
    80001d38:	84c70713          	addi	a4,a4,-1972 # 80012580 <pid_lock>
    80001d3c:	975a                	add	a4,a4,s6
    80001d3e:	02073823          	sd	zero,48(a4)
    80001d42:	00011717          	auipc	a4,0x11
    80001d46:	87670713          	addi	a4,a4,-1930 # 800125b8 <cpus+0x8>
    80001d4a:	9b3a                	add	s6,s6,a4
    80001d4c:	4c11                	li	s8,4
    80001d4e:	079e                	slli	a5,a5,0x7
    80001d50:	00011a17          	auipc	s4,0x11
    80001d54:	830a0a13          	addi	s4,s4,-2000 # 80012580 <pid_lock>
    80001d58:	9a3e                	add	s4,s4,a5
    80001d5a:	4b85                	li	s7,1
    80001d5c:	00017997          	auipc	s3,0x17
    80001d60:	85498993          	addi	s3,s3,-1964 # 800185b0 <ptable>
    80001d64:	a0a9                	j	80001dae <scheduler+0x9a>
    80001d66:	8526                	mv	a0,s1
    80001d68:	f25fe0ef          	jal	80000c8c <release>
    80001d6c:	17048493          	addi	s1,s1,368
    80001d70:	03348563          	beq	s1,s3,80001d9a <scheduler+0x86>
    80001d74:	8526                	mv	a0,s1
    80001d76:	e7ffe0ef          	jal	80000bf4 <acquire>
    80001d7a:	4cdc                	lw	a5,28(s1)
    80001d7c:	ff2795e3          	bne	a5,s2,80001d66 <scheduler+0x52>
    80001d80:	0184ae23          	sw	s8,28(s1)
    80001d84:	029a3823          	sd	s1,48(s4)
    80001d88:	06048593          	addi	a1,s1,96
    80001d8c:	855a                	mv	a0,s6
    80001d8e:	798000ef          	jal	80002526 <swtch>
    80001d92:	020a3823          	sd	zero,48(s4)
    80001d96:	8ade                	mv	s5,s7
    80001d98:	b7f9                	j	80001d66 <scheduler+0x52>
    80001d9a:	000a9a63          	bnez	s5,80001dae <scheduler+0x9a>
    80001d9e:	100027f3          	csrr	a5,sstatus
    80001da2:	0027e793          	ori	a5,a5,2
    80001da6:	10079073          	csrw	sstatus,a5
    80001daa:	10500073          	wfi
    80001dae:	100027f3          	csrr	a5,sstatus
    80001db2:	0027e793          	ori	a5,a5,2
    80001db6:	10079073          	csrw	sstatus,a5
    80001dba:	4a81                	li	s5,0
    80001dbc:	00011497          	auipc	s1,0x11
    80001dc0:	bf448493          	addi	s1,s1,-1036 # 800129b0 <proc>
    80001dc4:	490d                	li	s2,3
    80001dc6:	b77d                	j	80001d74 <scheduler+0x60>

0000000080001dc8 <sched>:
    80001dc8:	7179                	addi	sp,sp,-48
    80001dca:	f406                	sd	ra,40(sp)
    80001dcc:	f022                	sd	s0,32(sp)
    80001dce:	ec26                	sd	s1,24(sp)
    80001dd0:	e84a                	sd	s2,16(sp)
    80001dd2:	e44e                	sd	s3,8(sp)
    80001dd4:	1800                	addi	s0,sp,48
    80001dd6:	b0bff0ef          	jal	800018e0 <myproc>
    80001dda:	84aa                	mv	s1,a0
    80001ddc:	daffe0ef          	jal	80000b8a <holding>
    80001de0:	c92d                	beqz	a0,80001e52 <sched+0x8a>
    80001de2:	8792                	mv	a5,tp
    80001de4:	2781                	sext.w	a5,a5
    80001de6:	079e                	slli	a5,a5,0x7
    80001de8:	00010717          	auipc	a4,0x10
    80001dec:	79870713          	addi	a4,a4,1944 # 80012580 <pid_lock>
    80001df0:	97ba                	add	a5,a5,a4
    80001df2:	0a87a703          	lw	a4,168(a5)
    80001df6:	4785                	li	a5,1
    80001df8:	06f71363          	bne	a4,a5,80001e5e <sched+0x96>
    80001dfc:	4cd8                	lw	a4,28(s1)
    80001dfe:	4791                	li	a5,4
    80001e00:	06f70563          	beq	a4,a5,80001e6a <sched+0xa2>
    80001e04:	100027f3          	csrr	a5,sstatus
    80001e08:	8b89                	andi	a5,a5,2
    80001e0a:	e7b5                	bnez	a5,80001e76 <sched+0xae>
    80001e0c:	8792                	mv	a5,tp
    80001e0e:	00010917          	auipc	s2,0x10
    80001e12:	77290913          	addi	s2,s2,1906 # 80012580 <pid_lock>
    80001e16:	2781                	sext.w	a5,a5
    80001e18:	079e                	slli	a5,a5,0x7
    80001e1a:	97ca                	add	a5,a5,s2
    80001e1c:	0ac7a983          	lw	s3,172(a5)
    80001e20:	8792                	mv	a5,tp
    80001e22:	2781                	sext.w	a5,a5
    80001e24:	079e                	slli	a5,a5,0x7
    80001e26:	00010597          	auipc	a1,0x10
    80001e2a:	79258593          	addi	a1,a1,1938 # 800125b8 <cpus+0x8>
    80001e2e:	95be                	add	a1,a1,a5
    80001e30:	06048513          	addi	a0,s1,96
    80001e34:	6f2000ef          	jal	80002526 <swtch>
    80001e38:	8792                	mv	a5,tp
    80001e3a:	2781                	sext.w	a5,a5
    80001e3c:	079e                	slli	a5,a5,0x7
    80001e3e:	993e                	add	s2,s2,a5
    80001e40:	0b392623          	sw	s3,172(s2)
    80001e44:	70a2                	ld	ra,40(sp)
    80001e46:	7402                	ld	s0,32(sp)
    80001e48:	64e2                	ld	s1,24(sp)
    80001e4a:	6942                	ld	s2,16(sp)
    80001e4c:	69a2                	ld	s3,8(sp)
    80001e4e:	6145                	addi	sp,sp,48
    80001e50:	8082                	ret
    80001e52:	00005517          	auipc	a0,0x5
    80001e56:	3de50513          	addi	a0,a0,990 # 80007230 <etext+0x230>
    80001e5a:	93bfe0ef          	jal	80000794 <panic>
    80001e5e:	00005517          	auipc	a0,0x5
    80001e62:	3e250513          	addi	a0,a0,994 # 80007240 <etext+0x240>
    80001e66:	92ffe0ef          	jal	80000794 <panic>
    80001e6a:	00005517          	auipc	a0,0x5
    80001e6e:	3e650513          	addi	a0,a0,998 # 80007250 <etext+0x250>
    80001e72:	923fe0ef          	jal	80000794 <panic>
    80001e76:	00005517          	auipc	a0,0x5
    80001e7a:	3ea50513          	addi	a0,a0,1002 # 80007260 <etext+0x260>
    80001e7e:	917fe0ef          	jal	80000794 <panic>

0000000080001e82 <yield>:
    80001e82:	1101                	addi	sp,sp,-32
    80001e84:	ec06                	sd	ra,24(sp)
    80001e86:	e822                	sd	s0,16(sp)
    80001e88:	e426                	sd	s1,8(sp)
    80001e8a:	1000                	addi	s0,sp,32
    80001e8c:	a55ff0ef          	jal	800018e0 <myproc>
    80001e90:	84aa                	mv	s1,a0
    80001e92:	d63fe0ef          	jal	80000bf4 <acquire>
    80001e96:	478d                	li	a5,3
    80001e98:	ccdc                	sw	a5,28(s1)
    80001e9a:	f2fff0ef          	jal	80001dc8 <sched>
    80001e9e:	8526                	mv	a0,s1
    80001ea0:	dedfe0ef          	jal	80000c8c <release>
    80001ea4:	60e2                	ld	ra,24(sp)
    80001ea6:	6442                	ld	s0,16(sp)
    80001ea8:	64a2                	ld	s1,8(sp)
    80001eaa:	6105                	addi	sp,sp,32
    80001eac:	8082                	ret

0000000080001eae <sleep>:
    80001eae:	7179                	addi	sp,sp,-48
    80001eb0:	f406                	sd	ra,40(sp)
    80001eb2:	f022                	sd	s0,32(sp)
    80001eb4:	ec26                	sd	s1,24(sp)
    80001eb6:	e84a                	sd	s2,16(sp)
    80001eb8:	e44e                	sd	s3,8(sp)
    80001eba:	1800                	addi	s0,sp,48
    80001ebc:	89aa                	mv	s3,a0
    80001ebe:	892e                	mv	s2,a1
    80001ec0:	a21ff0ef          	jal	800018e0 <myproc>
    80001ec4:	84aa                	mv	s1,a0
    80001ec6:	d2ffe0ef          	jal	80000bf4 <acquire>
    80001eca:	854a                	mv	a0,s2
    80001ecc:	dc1fe0ef          	jal	80000c8c <release>
    80001ed0:	0334b023          	sd	s3,32(s1)
    80001ed4:	4789                	li	a5,2
    80001ed6:	ccdc                	sw	a5,28(s1)
    80001ed8:	ef1ff0ef          	jal	80001dc8 <sched>
    80001edc:	0204b023          	sd	zero,32(s1)
    80001ee0:	8526                	mv	a0,s1
    80001ee2:	dabfe0ef          	jal	80000c8c <release>
    80001ee6:	854a                	mv	a0,s2
    80001ee8:	d0dfe0ef          	jal	80000bf4 <acquire>
    80001eec:	70a2                	ld	ra,40(sp)
    80001eee:	7402                	ld	s0,32(sp)
    80001ef0:	64e2                	ld	s1,24(sp)
    80001ef2:	6942                	ld	s2,16(sp)
    80001ef4:	69a2                	ld	s3,8(sp)
    80001ef6:	6145                	addi	sp,sp,48
    80001ef8:	8082                	ret

0000000080001efa <wakeup>:
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
    80001f0e:	00011497          	auipc	s1,0x11
    80001f12:	aa248493          	addi	s1,s1,-1374 # 800129b0 <proc>
    80001f16:	4989                	li	s3,2
    80001f18:	4a8d                	li	s5,3
    80001f1a:	00016917          	auipc	s2,0x16
    80001f1e:	69690913          	addi	s2,s2,1686 # 800185b0 <ptable>
    80001f22:	a801                	j	80001f32 <wakeup+0x38>
    80001f24:	8526                	mv	a0,s1
    80001f26:	d67fe0ef          	jal	80000c8c <release>
    80001f2a:	17048493          	addi	s1,s1,368
    80001f2e:	03248263          	beq	s1,s2,80001f52 <wakeup+0x58>
    80001f32:	9afff0ef          	jal	800018e0 <myproc>
    80001f36:	fea48ae3          	beq	s1,a0,80001f2a <wakeup+0x30>
    80001f3a:	8526                	mv	a0,s1
    80001f3c:	cb9fe0ef          	jal	80000bf4 <acquire>
    80001f40:	4cdc                	lw	a5,28(s1)
    80001f42:	ff3791e3          	bne	a5,s3,80001f24 <wakeup+0x2a>
    80001f46:	709c                	ld	a5,32(s1)
    80001f48:	fd479ee3          	bne	a5,s4,80001f24 <wakeup+0x2a>
    80001f4c:	0154ae23          	sw	s5,28(s1)
    80001f50:	bfd1                	j	80001f24 <wakeup+0x2a>
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
    80001f64:	7179                	addi	sp,sp,-48
    80001f66:	f406                	sd	ra,40(sp)
    80001f68:	f022                	sd	s0,32(sp)
    80001f6a:	ec26                	sd	s1,24(sp)
    80001f6c:	e84a                	sd	s2,16(sp)
    80001f6e:	e44e                	sd	s3,8(sp)
    80001f70:	e052                	sd	s4,0(sp)
    80001f72:	1800                	addi	s0,sp,48
    80001f74:	892a                	mv	s2,a0
    80001f76:	00011497          	auipc	s1,0x11
    80001f7a:	a3a48493          	addi	s1,s1,-1478 # 800129b0 <proc>
    80001f7e:	00008a17          	auipc	s4,0x8
    80001f82:	4caa0a13          	addi	s4,s4,1226 # 8000a448 <initproc>
    80001f86:	00016997          	auipc	s3,0x16
    80001f8a:	62a98993          	addi	s3,s3,1578 # 800185b0 <ptable>
    80001f8e:	a029                	j	80001f98 <reparent+0x34>
    80001f90:	17048493          	addi	s1,s1,368
    80001f94:	01348b63          	beq	s1,s3,80001faa <reparent+0x46>
    80001f98:	7c9c                	ld	a5,56(s1)
    80001f9a:	ff279be3          	bne	a5,s2,80001f90 <reparent+0x2c>
    80001f9e:	000a3503          	ld	a0,0(s4)
    80001fa2:	fc88                	sd	a0,56(s1)
    80001fa4:	f57ff0ef          	jal	80001efa <wakeup>
    80001fa8:	b7e5                	j	80001f90 <reparent+0x2c>
    80001faa:	70a2                	ld	ra,40(sp)
    80001fac:	7402                	ld	s0,32(sp)
    80001fae:	64e2                	ld	s1,24(sp)
    80001fb0:	6942                	ld	s2,16(sp)
    80001fb2:	69a2                	ld	s3,8(sp)
    80001fb4:	6a02                	ld	s4,0(sp)
    80001fb6:	6145                	addi	sp,sp,48
    80001fb8:	8082                	ret

0000000080001fba <exit>:
    80001fba:	7179                	addi	sp,sp,-48
    80001fbc:	f406                	sd	ra,40(sp)
    80001fbe:	f022                	sd	s0,32(sp)
    80001fc0:	ec26                	sd	s1,24(sp)
    80001fc2:	e84a                	sd	s2,16(sp)
    80001fc4:	e44e                	sd	s3,8(sp)
    80001fc6:	e052                	sd	s4,0(sp)
    80001fc8:	1800                	addi	s0,sp,48
    80001fca:	8a2a                	mv	s4,a0
    80001fcc:	915ff0ef          	jal	800018e0 <myproc>
    80001fd0:	89aa                	mv	s3,a0
    80001fd2:	00008797          	auipc	a5,0x8
    80001fd6:	4767b783          	ld	a5,1142(a5) # 8000a448 <initproc>
    80001fda:	0d050493          	addi	s1,a0,208
    80001fde:	15050913          	addi	s2,a0,336
    80001fe2:	00a79f63          	bne	a5,a0,80002000 <exit+0x46>
    80001fe6:	00005517          	auipc	a0,0x5
    80001fea:	29250513          	addi	a0,a0,658 # 80007278 <etext+0x278>
    80001fee:	fa6fe0ef          	jal	80000794 <panic>
    80001ff2:	128020ef          	jal	8000411a <fileclose>
    80001ff6:	0004b023          	sd	zero,0(s1)
    80001ffa:	04a1                	addi	s1,s1,8
    80001ffc:	01248563          	beq	s1,s2,80002006 <exit+0x4c>
    80002000:	6088                	ld	a0,0(s1)
    80002002:	f965                	bnez	a0,80001ff2 <exit+0x38>
    80002004:	bfdd                	j	80001ffa <exit+0x40>
    80002006:	4fb010ef          	jal	80003d00 <begin_op>
    8000200a:	1509b503          	ld	a0,336(s3)
    8000200e:	5de010ef          	jal	800035ec <iput>
    80002012:	559010ef          	jal	80003d6a <end_op>
    80002016:	1409b823          	sd	zero,336(s3)
    8000201a:	00010497          	auipc	s1,0x10
    8000201e:	57e48493          	addi	s1,s1,1406 # 80012598 <wait_lock>
    80002022:	8526                	mv	a0,s1
    80002024:	bd1fe0ef          	jal	80000bf4 <acquire>
    80002028:	854e                	mv	a0,s3
    8000202a:	f3bff0ef          	jal	80001f64 <reparent>
    8000202e:	0389b503          	ld	a0,56(s3)
    80002032:	ec9ff0ef          	jal	80001efa <wakeup>
    80002036:	854e                	mv	a0,s3
    80002038:	bbdfe0ef          	jal	80000bf4 <acquire>
    8000203c:	0349a623          	sw	s4,44(s3)
    80002040:	4795                	li	a5,5
    80002042:	00f9ae23          	sw	a5,28(s3)
    80002046:	8526                	mv	a0,s1
    80002048:	c45fe0ef          	jal	80000c8c <release>
    8000204c:	d7dff0ef          	jal	80001dc8 <sched>
    80002050:	00005517          	auipc	a0,0x5
    80002054:	23850513          	addi	a0,a0,568 # 80007288 <etext+0x288>
    80002058:	f3cfe0ef          	jal	80000794 <panic>

000000008000205c <kill>:
    8000205c:	7179                	addi	sp,sp,-48
    8000205e:	f406                	sd	ra,40(sp)
    80002060:	f022                	sd	s0,32(sp)
    80002062:	ec26                	sd	s1,24(sp)
    80002064:	e84a                	sd	s2,16(sp)
    80002066:	e44e                	sd	s3,8(sp)
    80002068:	1800                	addi	s0,sp,48
    8000206a:	892a                	mv	s2,a0
    8000206c:	00011497          	auipc	s1,0x11
    80002070:	94448493          	addi	s1,s1,-1724 # 800129b0 <proc>
    80002074:	00016997          	auipc	s3,0x16
    80002078:	53c98993          	addi	s3,s3,1340 # 800185b0 <ptable>
    8000207c:	8526                	mv	a0,s1
    8000207e:	b77fe0ef          	jal	80000bf4 <acquire>
    80002082:	589c                	lw	a5,48(s1)
    80002084:	01278b63          	beq	a5,s2,8000209a <kill+0x3e>
    80002088:	8526                	mv	a0,s1
    8000208a:	c03fe0ef          	jal	80000c8c <release>
    8000208e:	17048493          	addi	s1,s1,368
    80002092:	ff3495e3          	bne	s1,s3,8000207c <kill+0x20>
    80002096:	557d                	li	a0,-1
    80002098:	a819                	j	800020ae <kill+0x52>
    8000209a:	4785                	li	a5,1
    8000209c:	d49c                	sw	a5,40(s1)
    8000209e:	4cd8                	lw	a4,28(s1)
    800020a0:	4789                	li	a5,2
    800020a2:	00f70d63          	beq	a4,a5,800020bc <kill+0x60>
    800020a6:	8526                	mv	a0,s1
    800020a8:	be5fe0ef          	jal	80000c8c <release>
    800020ac:	4501                	li	a0,0
    800020ae:	70a2                	ld	ra,40(sp)
    800020b0:	7402                	ld	s0,32(sp)
    800020b2:	64e2                	ld	s1,24(sp)
    800020b4:	6942                	ld	s2,16(sp)
    800020b6:	69a2                	ld	s3,8(sp)
    800020b8:	6145                	addi	sp,sp,48
    800020ba:	8082                	ret
    800020bc:	478d                	li	a5,3
    800020be:	ccdc                	sw	a5,28(s1)
    800020c0:	b7dd                	j	800020a6 <kill+0x4a>

00000000800020c2 <setkilled>:
    800020c2:	1101                	addi	sp,sp,-32
    800020c4:	ec06                	sd	ra,24(sp)
    800020c6:	e822                	sd	s0,16(sp)
    800020c8:	e426                	sd	s1,8(sp)
    800020ca:	1000                	addi	s0,sp,32
    800020cc:	84aa                	mv	s1,a0
    800020ce:	b27fe0ef          	jal	80000bf4 <acquire>
    800020d2:	4785                	li	a5,1
    800020d4:	d49c                	sw	a5,40(s1)
    800020d6:	8526                	mv	a0,s1
    800020d8:	bb5fe0ef          	jal	80000c8c <release>
    800020dc:	60e2                	ld	ra,24(sp)
    800020de:	6442                	ld	s0,16(sp)
    800020e0:	64a2                	ld	s1,8(sp)
    800020e2:	6105                	addi	sp,sp,32
    800020e4:	8082                	ret

00000000800020e6 <killed>:
    800020e6:	1101                	addi	sp,sp,-32
    800020e8:	ec06                	sd	ra,24(sp)
    800020ea:	e822                	sd	s0,16(sp)
    800020ec:	e426                	sd	s1,8(sp)
    800020ee:	e04a                	sd	s2,0(sp)
    800020f0:	1000                	addi	s0,sp,32
    800020f2:	84aa                	mv	s1,a0
    800020f4:	b01fe0ef          	jal	80000bf4 <acquire>
    800020f8:	0284a903          	lw	s2,40(s1)
    800020fc:	8526                	mv	a0,s1
    800020fe:	b8ffe0ef          	jal	80000c8c <release>
    80002102:	854a                	mv	a0,s2
    80002104:	60e2                	ld	ra,24(sp)
    80002106:	6442                	ld	s0,16(sp)
    80002108:	64a2                	ld	s1,8(sp)
    8000210a:	6902                	ld	s2,0(sp)
    8000210c:	6105                	addi	sp,sp,32
    8000210e:	8082                	ret

0000000080002110 <wait>:
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
    8000212a:	fb6ff0ef          	jal	800018e0 <myproc>
    8000212e:	892a                	mv	s2,a0
    80002130:	00010517          	auipc	a0,0x10
    80002134:	46850513          	addi	a0,a0,1128 # 80012598 <wait_lock>
    80002138:	abdfe0ef          	jal	80000bf4 <acquire>
    8000213c:	4b81                	li	s7,0
    8000213e:	4a15                	li	s4,5
    80002140:	4a85                	li	s5,1
    80002142:	00016997          	auipc	s3,0x16
    80002146:	46e98993          	addi	s3,s3,1134 # 800185b0 <ptable>
    8000214a:	00010c17          	auipc	s8,0x10
    8000214e:	44ec0c13          	addi	s8,s8,1102 # 80012598 <wait_lock>
    80002152:	a871                	j	800021ee <wait+0xde>
    80002154:	0304a983          	lw	s3,48(s1)
    80002158:	000b0c63          	beqz	s6,80002170 <wait+0x60>
    8000215c:	4691                	li	a3,4
    8000215e:	02c48613          	addi	a2,s1,44
    80002162:	85da                	mv	a1,s6
    80002164:	05093503          	ld	a0,80(s2)
    80002168:	beaff0ef          	jal	80001552 <copyout>
    8000216c:	02054b63          	bltz	a0,800021a2 <wait+0x92>
    80002170:	8526                	mv	a0,s1
    80002172:	8e1ff0ef          	jal	80001a52 <freeproc>
    80002176:	8526                	mv	a0,s1
    80002178:	b15fe0ef          	jal	80000c8c <release>
    8000217c:	00010517          	auipc	a0,0x10
    80002180:	41c50513          	addi	a0,a0,1052 # 80012598 <wait_lock>
    80002184:	b09fe0ef          	jal	80000c8c <release>
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
    800021a2:	8526                	mv	a0,s1
    800021a4:	ae9fe0ef          	jal	80000c8c <release>
    800021a8:	00010517          	auipc	a0,0x10
    800021ac:	3f050513          	addi	a0,a0,1008 # 80012598 <wait_lock>
    800021b0:	addfe0ef          	jal	80000c8c <release>
    800021b4:	59fd                	li	s3,-1
    800021b6:	bfc9                	j	80002188 <wait+0x78>
    800021b8:	17048493          	addi	s1,s1,368
    800021bc:	03348063          	beq	s1,s3,800021dc <wait+0xcc>
    800021c0:	7c9c                	ld	a5,56(s1)
    800021c2:	ff279be3          	bne	a5,s2,800021b8 <wait+0xa8>
    800021c6:	8526                	mv	a0,s1
    800021c8:	a2dfe0ef          	jal	80000bf4 <acquire>
    800021cc:	4cdc                	lw	a5,28(s1)
    800021ce:	f94783e3          	beq	a5,s4,80002154 <wait+0x44>
    800021d2:	8526                	mv	a0,s1
    800021d4:	ab9fe0ef          	jal	80000c8c <release>
    800021d8:	8756                	mv	a4,s5
    800021da:	bff9                	j	800021b8 <wait+0xa8>
    800021dc:	cf19                	beqz	a4,800021fa <wait+0xea>
    800021de:	854a                	mv	a0,s2
    800021e0:	f07ff0ef          	jal	800020e6 <killed>
    800021e4:	e919                	bnez	a0,800021fa <wait+0xea>
    800021e6:	85e2                	mv	a1,s8
    800021e8:	854a                	mv	a0,s2
    800021ea:	cc5ff0ef          	jal	80001eae <sleep>
    800021ee:	875e                	mv	a4,s7
    800021f0:	00010497          	auipc	s1,0x10
    800021f4:	7c048493          	addi	s1,s1,1984 # 800129b0 <proc>
    800021f8:	b7e1                	j	800021c0 <wait+0xb0>
    800021fa:	00010517          	auipc	a0,0x10
    800021fe:	39e50513          	addi	a0,a0,926 # 80012598 <wait_lock>
    80002202:	a8bfe0ef          	jal	80000c8c <release>
    80002206:	59fd                	li	s3,-1
    80002208:	b741                	j	80002188 <wait+0x78>

000000008000220a <either_copyout>:
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
    80002222:	ebeff0ef          	jal	800018e0 <myproc>
    80002226:	cc99                	beqz	s1,80002244 <either_copyout+0x3a>
    80002228:	86d2                	mv	a3,s4
    8000222a:	864e                	mv	a2,s3
    8000222c:	85ca                	mv	a1,s2
    8000222e:	6928                	ld	a0,80(a0)
    80002230:	b22ff0ef          	jal	80001552 <copyout>
    80002234:	70a2                	ld	ra,40(sp)
    80002236:	7402                	ld	s0,32(sp)
    80002238:	64e2                	ld	s1,24(sp)
    8000223a:	6942                	ld	s2,16(sp)
    8000223c:	69a2                	ld	s3,8(sp)
    8000223e:	6a02                	ld	s4,0(sp)
    80002240:	6145                	addi	sp,sp,48
    80002242:	8082                	ret
    80002244:	000a061b          	sext.w	a2,s4
    80002248:	85ce                	mv	a1,s3
    8000224a:	854a                	mv	a0,s2
    8000224c:	ad9fe0ef          	jal	80000d24 <memmove>
    80002250:	8526                	mv	a0,s1
    80002252:	b7cd                	j	80002234 <either_copyout+0x2a>

0000000080002254 <either_copyin>:
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
    8000226c:	e74ff0ef          	jal	800018e0 <myproc>
    80002270:	cc99                	beqz	s1,8000228e <either_copyin+0x3a>
    80002272:	86d2                	mv	a3,s4
    80002274:	864e                	mv	a2,s3
    80002276:	85ca                	mv	a1,s2
    80002278:	6928                	ld	a0,80(a0)
    8000227a:	baeff0ef          	jal	80001628 <copyin>
    8000227e:	70a2                	ld	ra,40(sp)
    80002280:	7402                	ld	s0,32(sp)
    80002282:	64e2                	ld	s1,24(sp)
    80002284:	6942                	ld	s2,16(sp)
    80002286:	69a2                	ld	s3,8(sp)
    80002288:	6a02                	ld	s4,0(sp)
    8000228a:	6145                	addi	sp,sp,48
    8000228c:	8082                	ret
    8000228e:	000a061b          	sext.w	a2,s4
    80002292:	85ce                	mv	a1,s3
    80002294:	854a                	mv	a0,s2
    80002296:	a8ffe0ef          	jal	80000d24 <memmove>
    8000229a:	8526                	mv	a0,s1
    8000229c:	b7cd                	j	8000227e <either_copyin+0x2a>

000000008000229e <procdump>:
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
    800022b4:	00005517          	auipc	a0,0x5
    800022b8:	08450513          	addi	a0,a0,132 # 80007338 <etext+0x338>
    800022bc:	a06fe0ef          	jal	800004c2 <printf>
    800022c0:	00011497          	auipc	s1,0x11
    800022c4:	84848493          	addi	s1,s1,-1976 # 80012b08 <proc+0x158>
    800022c8:	00016917          	auipc	s2,0x16
    800022cc:	44090913          	addi	s2,s2,1088 # 80018708 <ptable+0x158>
    800022d0:	4b15                	li	s6,5
    800022d2:	00005997          	auipc	s3,0x5
    800022d6:	fc698993          	addi	s3,s3,-58 # 80007298 <etext+0x298>
    800022da:	00005a97          	auipc	s5,0x5
    800022de:	fc6a8a93          	addi	s5,s5,-58 # 800072a0 <etext+0x2a0>
    800022e2:	00005a17          	auipc	s4,0x5
    800022e6:	056a0a13          	addi	s4,s4,86 # 80007338 <etext+0x338>
    800022ea:	00005b97          	auipc	s7,0x5
    800022ee:	576b8b93          	addi	s7,s7,1398 # 80007860 <states.0>
    800022f2:	a829                	j	8000230c <procdump+0x6e>
    800022f4:	ed86a583          	lw	a1,-296(a3)
    800022f8:	8556                	mv	a0,s5
    800022fa:	9c8fe0ef          	jal	800004c2 <printf>
    800022fe:	8552                	mv	a0,s4
    80002300:	9c2fe0ef          	jal	800004c2 <printf>
    80002304:	17048493          	addi	s1,s1,368
    80002308:	03248263          	beq	s1,s2,8000232c <procdump+0x8e>
    8000230c:	86a6                	mv	a3,s1
    8000230e:	ec44a783          	lw	a5,-316(s1)
    80002312:	dbed                	beqz	a5,80002304 <procdump+0x66>
    80002314:	864e                	mv	a2,s3
    80002316:	fcfb6fe3          	bltu	s6,a5,800022f4 <procdump+0x56>
    8000231a:	02079713          	slli	a4,a5,0x20
    8000231e:	01d75793          	srli	a5,a4,0x1d
    80002322:	97de                	add	a5,a5,s7
    80002324:	6390                	ld	a2,0(a5)
    80002326:	f679                	bnez	a2,800022f4 <procdump+0x56>
    80002328:	864e                	mv	a2,s3
    8000232a:	b7e9                	j	800022f4 <procdump+0x56>
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
    8000235c:	10016073          	csrsi	sstatus,2
    80002360:	00010517          	auipc	a0,0x10
    80002364:	23850513          	addi	a0,a0,568 # 80012598 <wait_lock>
    80002368:	88dfe0ef          	jal	80000bf4 <acquire>
    8000236c:	00005517          	auipc	a0,0x5
    80002370:	f4450513          	addi	a0,a0,-188 # 800072b0 <etext+0x2b0>
    80002374:	94efe0ef          	jal	800004c2 <printf>
    80002378:	00010497          	auipc	s1,0x10
    8000237c:	79048493          	addi	s1,s1,1936 # 80012b08 <proc+0x158>
    80002380:	00016a17          	auipc	s4,0x16
    80002384:	388a0a13          	addi	s4,s4,904 # 80018708 <ptable+0x158>
    80002388:	4995                	li	s3,5
    8000238a:	00005917          	auipc	s2,0x5
    8000238e:	4be90913          	addi	s2,s2,1214 # 80007848 <digits+0x18>
    80002392:	00005c97          	auipc	s9,0x5
    80002396:	f96c8c93          	addi	s9,s9,-106 # 80007328 <etext+0x328>
    8000239a:	00005c17          	auipc	s8,0x5
    8000239e:	f76c0c13          	addi	s8,s8,-138 # 80007310 <etext+0x310>
    800023a2:	00005b97          	auipc	s7,0x5
    800023a6:	f56b8b93          	addi	s7,s7,-170 # 800072f8 <etext+0x2f8>
    800023aa:	00005b17          	auipc	s6,0x5
    800023ae:	f36b0b13          	addi	s6,s6,-202 # 800072e0 <etext+0x2e0>
    800023b2:	00005a97          	auipc	s5,0x5
    800023b6:	f16a8a93          	addi	s5,s5,-234 # 800072c8 <etext+0x2c8>
    800023ba:	a811                	j	800023ce <ps+0x8c>
    800023bc:	ed84a603          	lw	a2,-296(s1)
    800023c0:	8556                	mv	a0,s5
    800023c2:	900fe0ef          	jal	800004c2 <printf>
    800023c6:	17048493          	addi	s1,s1,368
    800023ca:	05448663          	beq	s1,s4,80002416 <ps+0xd4>
    800023ce:	85a6                	mv	a1,s1
    800023d0:	ec44a783          	lw	a5,-316(s1)
    800023d4:	fef9e9e3          	bltu	s3,a5,800023c6 <ps+0x84>
    800023d8:	ec44e783          	lwu	a5,-316(s1)
    800023dc:	078a                	slli	a5,a5,0x2
    800023de:	97ca                	add	a5,a5,s2
    800023e0:	439c                	lw	a5,0(a5)
    800023e2:	97ca                	add	a5,a5,s2
    800023e4:	8782                	jr	a5
    800023e6:	ed84a603          	lw	a2,-296(s1)
    800023ea:	855a                	mv	a0,s6
    800023ec:	8d6fe0ef          	jal	800004c2 <printf>
    800023f0:	bfd9                	j	800023c6 <ps+0x84>
    800023f2:	ed84a603          	lw	a2,-296(s1)
    800023f6:	855e                	mv	a0,s7
    800023f8:	8cafe0ef          	jal	800004c2 <printf>
    800023fc:	b7e9                	j	800023c6 <ps+0x84>
    800023fe:	ed84a603          	lw	a2,-296(s1)
    80002402:	8562                	mv	a0,s8
    80002404:	8befe0ef          	jal	800004c2 <printf>
    80002408:	bf7d                	j	800023c6 <ps+0x84>
    8000240a:	ed84a603          	lw	a2,-296(s1)
    8000240e:	8566                	mv	a0,s9
    80002410:	8b2fe0ef          	jal	800004c2 <printf>
    80002414:	bf4d                	j	800023c6 <ps+0x84>
    80002416:	00010517          	auipc	a0,0x10
    8000241a:	18250513          	addi	a0,a0,386 # 80012598 <wait_lock>
    8000241e:	86ffe0ef          	jal	80000c8c <release>
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
    8000243e:	7139                	addi	sp,sp,-64
    80002440:	fc06                	sd	ra,56(sp)
    80002442:	f822                	sd	s0,48(sp)
    80002444:	f426                	sd	s1,40(sp)
    80002446:	e456                	sd	s5,8(sp)
    80002448:	0080                	addi	s0,sp,64
    8000244a:	84aa                	mv	s1,a0
    8000244c:	c94ff0ef          	jal	800018e0 <myproc>
    80002450:	8aaa                	mv	s5,a0
    80002452:	e50ff0ef          	jal	80001aa2 <allocproc>
    80002456:	c571                	beqz	a0,80002522 <fork_with_priority+0xe4>
    80002458:	e852                	sd	s4,16(sp)
    8000245a:	8a2a                	mv	s4,a0
    8000245c:	048ab603          	ld	a2,72(s5)
    80002460:	692c                	ld	a1,80(a0)
    80002462:	050ab503          	ld	a0,80(s5)
    80002466:	810ff0ef          	jal	80001476 <uvmcopy>
    8000246a:	04054c63          	bltz	a0,800024c2 <fork_with_priority+0x84>
    8000246e:	f04a                	sd	s2,32(sp)
    80002470:	ec4e                	sd	s3,24(sp)
    80002472:	048ab783          	ld	a5,72(s5)
    80002476:	04fa3423          	sd	a5,72(s4)
    8000247a:	035a3c23          	sd	s5,56(s4)
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
    800024b0:	169a2423          	sw	s1,360(s4)
    800024b4:	0d0a8493          	addi	s1,s5,208
    800024b8:	0d0a0913          	addi	s2,s4,208
    800024bc:	150a8993          	addi	s3,s5,336
    800024c0:	a819                	j	800024d6 <fork_with_priority+0x98>
    800024c2:	8552                	mv	a0,s4
    800024c4:	d8eff0ef          	jal	80001a52 <freeproc>
    800024c8:	54fd                	li	s1,-1
    800024ca:	6a42                	ld	s4,16(sp)
    800024cc:	a0a1                	j	80002514 <fork_with_priority+0xd6>
    800024ce:	04a1                	addi	s1,s1,8
    800024d0:	0921                	addi	s2,s2,8
    800024d2:	01348963          	beq	s1,s3,800024e4 <fork_with_priority+0xa6>
    800024d6:	6088                	ld	a0,0(s1)
    800024d8:	d97d                	beqz	a0,800024ce <fork_with_priority+0x90>
    800024da:	3fb010ef          	jal	800040d4 <filedup>
    800024de:	00a93023          	sd	a0,0(s2)
    800024e2:	b7f5                	j	800024ce <fork_with_priority+0x90>
    800024e4:	150ab503          	ld	a0,336(s5)
    800024e8:	74d000ef          	jal	80003434 <idup>
    800024ec:	14aa3823          	sd	a0,336(s4)
    800024f0:	4641                	li	a2,16
    800024f2:	158a8593          	addi	a1,s5,344
    800024f6:	158a0513          	addi	a0,s4,344
    800024fa:	90dfe0ef          	jal	80000e06 <safestrcpy>
    800024fe:	030a2483          	lw	s1,48(s4)
    80002502:	478d                	li	a5,3
    80002504:	00fa2e23          	sw	a5,28(s4)
    80002508:	8552                	mv	a0,s4
    8000250a:	f82fe0ef          	jal	80000c8c <release>
    8000250e:	7902                	ld	s2,32(sp)
    80002510:	69e2                	ld	s3,24(sp)
    80002512:	6a42                	ld	s4,16(sp)
    80002514:	8526                	mv	a0,s1
    80002516:	70e2                	ld	ra,56(sp)
    80002518:	7442                	ld	s0,48(sp)
    8000251a:	74a2                	ld	s1,40(sp)
    8000251c:	6aa2                	ld	s5,8(sp)
    8000251e:	6121                	addi	sp,sp,64
    80002520:	8082                	ret
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
    80002590:	1141                	addi	sp,sp,-16
    80002592:	e406                	sd	ra,8(sp)
    80002594:	e022                	sd	s0,0(sp)
    80002596:	0800                	addi	s0,sp,16
    80002598:	00005597          	auipc	a1,0x5
    8000259c:	dd858593          	addi	a1,a1,-552 # 80007370 <etext+0x370>
    800025a0:	0001c517          	auipc	a0,0x1c
    800025a4:	c2850513          	addi	a0,a0,-984 # 8001e1c8 <tickslock>
    800025a8:	dccfe0ef          	jal	80000b74 <initlock>
    800025ac:	60a2                	ld	ra,8(sp)
    800025ae:	6402                	ld	s0,0(sp)
    800025b0:	0141                	addi	sp,sp,16
    800025b2:	8082                	ret

00000000800025b4 <trapinithart>:
    800025b4:	1141                	addi	sp,sp,-16
    800025b6:	e422                	sd	s0,8(sp)
    800025b8:	0800                	addi	s0,sp,16
    800025ba:	00003797          	auipc	a5,0x3
    800025be:	ed678793          	addi	a5,a5,-298 # 80005490 <kernelvec>
    800025c2:	10579073          	csrw	stvec,a5
    800025c6:	6422                	ld	s0,8(sp)
    800025c8:	0141                	addi	sp,sp,16
    800025ca:	8082                	ret

00000000800025cc <usertrapret>:
    800025cc:	1141                	addi	sp,sp,-16
    800025ce:	e406                	sd	ra,8(sp)
    800025d0:	e022                	sd	s0,0(sp)
    800025d2:	0800                	addi	s0,sp,16
    800025d4:	b0cff0ef          	jal	800018e0 <myproc>
    800025d8:	100027f3          	csrr	a5,sstatus
    800025dc:	9bf5                	andi	a5,a5,-3
    800025de:	10079073          	csrw	sstatus,a5
    800025e2:	00004697          	auipc	a3,0x4
    800025e6:	a1e68693          	addi	a3,a3,-1506 # 80006000 <_trampoline>
    800025ea:	00004717          	auipc	a4,0x4
    800025ee:	a1670713          	addi	a4,a4,-1514 # 80006000 <_trampoline>
    800025f2:	8f15                	sub	a4,a4,a3
    800025f4:	040007b7          	lui	a5,0x4000
    800025f8:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    800025fa:	07b2                	slli	a5,a5,0xc
    800025fc:	973e                	add	a4,a4,a5
    800025fe:	10571073          	csrw	stvec,a4
    80002602:	6d38                	ld	a4,88(a0)
    80002604:	18002673          	csrr	a2,satp
    80002608:	e310                	sd	a2,0(a4)
    8000260a:	6d30                	ld	a2,88(a0)
    8000260c:	6138                	ld	a4,64(a0)
    8000260e:	6585                	lui	a1,0x1
    80002610:	972e                	add	a4,a4,a1
    80002612:	e618                	sd	a4,8(a2)
    80002614:	6d38                	ld	a4,88(a0)
    80002616:	00000617          	auipc	a2,0x0
    8000261a:	11060613          	addi	a2,a2,272 # 80002726 <usertrap>
    8000261e:	eb10                	sd	a2,16(a4)
    80002620:	6d38                	ld	a4,88(a0)
    80002622:	8612                	mv	a2,tp
    80002624:	f310                	sd	a2,32(a4)
    80002626:	10002773          	csrr	a4,sstatus
    8000262a:	eff77713          	andi	a4,a4,-257
    8000262e:	02076713          	ori	a4,a4,32
    80002632:	10071073          	csrw	sstatus,a4
    80002636:	6d38                	ld	a4,88(a0)
    80002638:	6f18                	ld	a4,24(a4)
    8000263a:	14171073          	csrw	sepc,a4
    8000263e:	6928                	ld	a0,80(a0)
    80002640:	8131                	srli	a0,a0,0xc
    80002642:	00004717          	auipc	a4,0x4
    80002646:	a5a70713          	addi	a4,a4,-1446 # 8000609c <userret>
    8000264a:	8f15                	sub	a4,a4,a3
    8000264c:	97ba                	add	a5,a5,a4
    8000264e:	577d                	li	a4,-1
    80002650:	177e                	slli	a4,a4,0x3f
    80002652:	8d59                	or	a0,a0,a4
    80002654:	9782                	jalr	a5
    80002656:	60a2                	ld	ra,8(sp)
    80002658:	6402                	ld	s0,0(sp)
    8000265a:	0141                	addi	sp,sp,16
    8000265c:	8082                	ret

000000008000265e <clockintr>:
    8000265e:	1101                	addi	sp,sp,-32
    80002660:	ec06                	sd	ra,24(sp)
    80002662:	e822                	sd	s0,16(sp)
    80002664:	1000                	addi	s0,sp,32
    80002666:	a4eff0ef          	jal	800018b4 <cpuid>
    8000266a:	cd11                	beqz	a0,80002686 <clockintr+0x28>
    8000266c:	c01027f3          	rdtime	a5
    80002670:	000f4737          	lui	a4,0xf4
    80002674:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80002678:	97ba                	add	a5,a5,a4
    8000267a:	14d79073          	csrw	stimecmp,a5
    8000267e:	60e2                	ld	ra,24(sp)
    80002680:	6442                	ld	s0,16(sp)
    80002682:	6105                	addi	sp,sp,32
    80002684:	8082                	ret
    80002686:	e426                	sd	s1,8(sp)
    80002688:	0001c497          	auipc	s1,0x1c
    8000268c:	b4048493          	addi	s1,s1,-1216 # 8001e1c8 <tickslock>
    80002690:	8526                	mv	a0,s1
    80002692:	d62fe0ef          	jal	80000bf4 <acquire>
    80002696:	00008517          	auipc	a0,0x8
    8000269a:	dba50513          	addi	a0,a0,-582 # 8000a450 <ticks>
    8000269e:	411c                	lw	a5,0(a0)
    800026a0:	2785                	addiw	a5,a5,1
    800026a2:	c11c                	sw	a5,0(a0)
    800026a4:	857ff0ef          	jal	80001efa <wakeup>
    800026a8:	8526                	mv	a0,s1
    800026aa:	de2fe0ef          	jal	80000c8c <release>
    800026ae:	64a2                	ld	s1,8(sp)
    800026b0:	bf75                	j	8000266c <clockintr+0xe>

00000000800026b2 <devintr>:
    800026b2:	1101                	addi	sp,sp,-32
    800026b4:	ec06                	sd	ra,24(sp)
    800026b6:	e822                	sd	s0,16(sp)
    800026b8:	1000                	addi	s0,sp,32
    800026ba:	14202773          	csrr	a4,scause
    800026be:	57fd                	li	a5,-1
    800026c0:	17fe                	slli	a5,a5,0x3f
    800026c2:	07a5                	addi	a5,a5,9
    800026c4:	00f70c63          	beq	a4,a5,800026dc <devintr+0x2a>
    800026c8:	57fd                	li	a5,-1
    800026ca:	17fe                	slli	a5,a5,0x3f
    800026cc:	0795                	addi	a5,a5,5
    800026ce:	4501                	li	a0,0
    800026d0:	04f70763          	beq	a4,a5,8000271e <devintr+0x6c>
    800026d4:	60e2                	ld	ra,24(sp)
    800026d6:	6442                	ld	s0,16(sp)
    800026d8:	6105                	addi	sp,sp,32
    800026da:	8082                	ret
    800026dc:	e426                	sd	s1,8(sp)
    800026de:	65f020ef          	jal	8000553c <plic_claim>
    800026e2:	84aa                	mv	s1,a0
    800026e4:	47a9                	li	a5,10
    800026e6:	00f50963          	beq	a0,a5,800026f8 <devintr+0x46>
    800026ea:	4785                	li	a5,1
    800026ec:	00f50963          	beq	a0,a5,800026fe <devintr+0x4c>
    800026f0:	4505                	li	a0,1
    800026f2:	e889                	bnez	s1,80002704 <devintr+0x52>
    800026f4:	64a2                	ld	s1,8(sp)
    800026f6:	bff9                	j	800026d4 <devintr+0x22>
    800026f8:	b0efe0ef          	jal	80000a06 <uartintr>
    800026fc:	a819                	j	80002712 <devintr+0x60>
    800026fe:	304030ef          	jal	80005a02 <virtio_disk_intr>
    80002702:	a801                	j	80002712 <devintr+0x60>
    80002704:	85a6                	mv	a1,s1
    80002706:	00005517          	auipc	a0,0x5
    8000270a:	c7250513          	addi	a0,a0,-910 # 80007378 <etext+0x378>
    8000270e:	db5fd0ef          	jal	800004c2 <printf>
    80002712:	8526                	mv	a0,s1
    80002714:	649020ef          	jal	8000555c <plic_complete>
    80002718:	4505                	li	a0,1
    8000271a:	64a2                	ld	s1,8(sp)
    8000271c:	bf65                	j	800026d4 <devintr+0x22>
    8000271e:	f41ff0ef          	jal	8000265e <clockintr>
    80002722:	4509                	li	a0,2
    80002724:	bf45                	j	800026d4 <devintr+0x22>

0000000080002726 <usertrap>:
    80002726:	1101                	addi	sp,sp,-32
    80002728:	ec06                	sd	ra,24(sp)
    8000272a:	e822                	sd	s0,16(sp)
    8000272c:	e426                	sd	s1,8(sp)
    8000272e:	e04a                	sd	s2,0(sp)
    80002730:	1000                	addi	s0,sp,32
    80002732:	100027f3          	csrr	a5,sstatus
    80002736:	1007f793          	andi	a5,a5,256
    8000273a:	ef85                	bnez	a5,80002772 <usertrap+0x4c>
    8000273c:	00003797          	auipc	a5,0x3
    80002740:	d5478793          	addi	a5,a5,-684 # 80005490 <kernelvec>
    80002744:	10579073          	csrw	stvec,a5
    80002748:	998ff0ef          	jal	800018e0 <myproc>
    8000274c:	84aa                	mv	s1,a0
    8000274e:	6d3c                	ld	a5,88(a0)
    80002750:	14102773          	csrr	a4,sepc
    80002754:	ef98                	sd	a4,24(a5)
    80002756:	14202773          	csrr	a4,scause
    8000275a:	47a1                	li	a5,8
    8000275c:	02f70163          	beq	a4,a5,8000277e <usertrap+0x58>
    80002760:	f53ff0ef          	jal	800026b2 <devintr>
    80002764:	892a                	mv	s2,a0
    80002766:	c135                	beqz	a0,800027ca <usertrap+0xa4>
    80002768:	8526                	mv	a0,s1
    8000276a:	97dff0ef          	jal	800020e6 <killed>
    8000276e:	cd1d                	beqz	a0,800027ac <usertrap+0x86>
    80002770:	a81d                	j	800027a6 <usertrap+0x80>
    80002772:	00005517          	auipc	a0,0x5
    80002776:	c2650513          	addi	a0,a0,-986 # 80007398 <etext+0x398>
    8000277a:	81afe0ef          	jal	80000794 <panic>
    8000277e:	969ff0ef          	jal	800020e6 <killed>
    80002782:	e121                	bnez	a0,800027c2 <usertrap+0x9c>
    80002784:	6cb8                	ld	a4,88(s1)
    80002786:	6f1c                	ld	a5,24(a4)
    80002788:	0791                	addi	a5,a5,4
    8000278a:	ef1c                	sd	a5,24(a4)
    8000278c:	100027f3          	csrr	a5,sstatus
    80002790:	0027e793          	ori	a5,a5,2
    80002794:	10079073          	csrw	sstatus,a5
    80002798:	248000ef          	jal	800029e0 <syscall>
    8000279c:	8526                	mv	a0,s1
    8000279e:	949ff0ef          	jal	800020e6 <killed>
    800027a2:	c901                	beqz	a0,800027b2 <usertrap+0x8c>
    800027a4:	4901                	li	s2,0
    800027a6:	557d                	li	a0,-1
    800027a8:	813ff0ef          	jal	80001fba <exit>
    800027ac:	4789                	li	a5,2
    800027ae:	04f90563          	beq	s2,a5,800027f8 <usertrap+0xd2>
    800027b2:	e1bff0ef          	jal	800025cc <usertrapret>
    800027b6:	60e2                	ld	ra,24(sp)
    800027b8:	6442                	ld	s0,16(sp)
    800027ba:	64a2                	ld	s1,8(sp)
    800027bc:	6902                	ld	s2,0(sp)
    800027be:	6105                	addi	sp,sp,32
    800027c0:	8082                	ret
    800027c2:	557d                	li	a0,-1
    800027c4:	ff6ff0ef          	jal	80001fba <exit>
    800027c8:	bf75                	j	80002784 <usertrap+0x5e>
    800027ca:	142025f3          	csrr	a1,scause
    800027ce:	5890                	lw	a2,48(s1)
    800027d0:	00005517          	auipc	a0,0x5
    800027d4:	be850513          	addi	a0,a0,-1048 # 800073b8 <etext+0x3b8>
    800027d8:	cebfd0ef          	jal	800004c2 <printf>
    800027dc:	141025f3          	csrr	a1,sepc
    800027e0:	14302673          	csrr	a2,stval
    800027e4:	00005517          	auipc	a0,0x5
    800027e8:	c0450513          	addi	a0,a0,-1020 # 800073e8 <etext+0x3e8>
    800027ec:	cd7fd0ef          	jal	800004c2 <printf>
    800027f0:	8526                	mv	a0,s1
    800027f2:	8d1ff0ef          	jal	800020c2 <setkilled>
    800027f6:	b75d                	j	8000279c <usertrap+0x76>
    800027f8:	e8aff0ef          	jal	80001e82 <yield>
    800027fc:	bf5d                	j	800027b2 <usertrap+0x8c>

00000000800027fe <kerneltrap>:
    800027fe:	7179                	addi	sp,sp,-48
    80002800:	f406                	sd	ra,40(sp)
    80002802:	f022                	sd	s0,32(sp)
    80002804:	ec26                	sd	s1,24(sp)
    80002806:	e84a                	sd	s2,16(sp)
    80002808:	e44e                	sd	s3,8(sp)
    8000280a:	1800                	addi	s0,sp,48
    8000280c:	14102973          	csrr	s2,sepc
    80002810:	100024f3          	csrr	s1,sstatus
    80002814:	142029f3          	csrr	s3,scause
    80002818:	1004f793          	andi	a5,s1,256
    8000281c:	c795                	beqz	a5,80002848 <kerneltrap+0x4a>
    8000281e:	100027f3          	csrr	a5,sstatus
    80002822:	8b89                	andi	a5,a5,2
    80002824:	eb85                	bnez	a5,80002854 <kerneltrap+0x56>
    80002826:	e8dff0ef          	jal	800026b2 <devintr>
    8000282a:	c91d                	beqz	a0,80002860 <kerneltrap+0x62>
    8000282c:	4789                	li	a5,2
    8000282e:	04f50a63          	beq	a0,a5,80002882 <kerneltrap+0x84>
    80002832:	14191073          	csrw	sepc,s2
    80002836:	10049073          	csrw	sstatus,s1
    8000283a:	70a2                	ld	ra,40(sp)
    8000283c:	7402                	ld	s0,32(sp)
    8000283e:	64e2                	ld	s1,24(sp)
    80002840:	6942                	ld	s2,16(sp)
    80002842:	69a2                	ld	s3,8(sp)
    80002844:	6145                	addi	sp,sp,48
    80002846:	8082                	ret
    80002848:	00005517          	auipc	a0,0x5
    8000284c:	bc850513          	addi	a0,a0,-1080 # 80007410 <etext+0x410>
    80002850:	f45fd0ef          	jal	80000794 <panic>
    80002854:	00005517          	auipc	a0,0x5
    80002858:	be450513          	addi	a0,a0,-1052 # 80007438 <etext+0x438>
    8000285c:	f39fd0ef          	jal	80000794 <panic>
    80002860:	14102673          	csrr	a2,sepc
    80002864:	143026f3          	csrr	a3,stval
    80002868:	85ce                	mv	a1,s3
    8000286a:	00005517          	auipc	a0,0x5
    8000286e:	bee50513          	addi	a0,a0,-1042 # 80007458 <etext+0x458>
    80002872:	c51fd0ef          	jal	800004c2 <printf>
    80002876:	00005517          	auipc	a0,0x5
    8000287a:	c0a50513          	addi	a0,a0,-1014 # 80007480 <etext+0x480>
    8000287e:	f17fd0ef          	jal	80000794 <panic>
    80002882:	85eff0ef          	jal	800018e0 <myproc>
    80002886:	d555                	beqz	a0,80002832 <kerneltrap+0x34>
    80002888:	dfaff0ef          	jal	80001e82 <yield>
    8000288c:	b75d                	j	80002832 <kerneltrap+0x34>

000000008000288e <argraw>:
    8000288e:	1101                	addi	sp,sp,-32
    80002890:	ec06                	sd	ra,24(sp)
    80002892:	e822                	sd	s0,16(sp)
    80002894:	e426                	sd	s1,8(sp)
    80002896:	1000                	addi	s0,sp,32
    80002898:	84aa                	mv	s1,a0
    8000289a:	846ff0ef          	jal	800018e0 <myproc>
    8000289e:	4795                	li	a5,5
    800028a0:	0497e163          	bltu	a5,s1,800028e2 <argraw+0x54>
    800028a4:	048a                	slli	s1,s1,0x2
    800028a6:	00005717          	auipc	a4,0x5
    800028aa:	fea70713          	addi	a4,a4,-22 # 80007890 <states.0+0x30>
    800028ae:	94ba                	add	s1,s1,a4
    800028b0:	409c                	lw	a5,0(s1)
    800028b2:	97ba                	add	a5,a5,a4
    800028b4:	8782                	jr	a5
    800028b6:	6d3c                	ld	a5,88(a0)
    800028b8:	7ba8                	ld	a0,112(a5)
    800028ba:	60e2                	ld	ra,24(sp)
    800028bc:	6442                	ld	s0,16(sp)
    800028be:	64a2                	ld	s1,8(sp)
    800028c0:	6105                	addi	sp,sp,32
    800028c2:	8082                	ret
    800028c4:	6d3c                	ld	a5,88(a0)
    800028c6:	7fa8                	ld	a0,120(a5)
    800028c8:	bfcd                	j	800028ba <argraw+0x2c>
    800028ca:	6d3c                	ld	a5,88(a0)
    800028cc:	63c8                	ld	a0,128(a5)
    800028ce:	b7f5                	j	800028ba <argraw+0x2c>
    800028d0:	6d3c                	ld	a5,88(a0)
    800028d2:	67c8                	ld	a0,136(a5)
    800028d4:	b7dd                	j	800028ba <argraw+0x2c>
    800028d6:	6d3c                	ld	a5,88(a0)
    800028d8:	6bc8                	ld	a0,144(a5)
    800028da:	b7c5                	j	800028ba <argraw+0x2c>
    800028dc:	6d3c                	ld	a5,88(a0)
    800028de:	6fc8                	ld	a0,152(a5)
    800028e0:	bfe9                	j	800028ba <argraw+0x2c>
    800028e2:	00005517          	auipc	a0,0x5
    800028e6:	bae50513          	addi	a0,a0,-1106 # 80007490 <etext+0x490>
    800028ea:	eabfd0ef          	jal	80000794 <panic>

00000000800028ee <fetchaddr>:
    800028ee:	1101                	addi	sp,sp,-32
    800028f0:	ec06                	sd	ra,24(sp)
    800028f2:	e822                	sd	s0,16(sp)
    800028f4:	e426                	sd	s1,8(sp)
    800028f6:	e04a                	sd	s2,0(sp)
    800028f8:	1000                	addi	s0,sp,32
    800028fa:	84aa                	mv	s1,a0
    800028fc:	892e                	mv	s2,a1
    800028fe:	fe3fe0ef          	jal	800018e0 <myproc>
    80002902:	653c                	ld	a5,72(a0)
    80002904:	02f4f663          	bgeu	s1,a5,80002930 <fetchaddr+0x42>
    80002908:	00848713          	addi	a4,s1,8
    8000290c:	02e7e463          	bltu	a5,a4,80002934 <fetchaddr+0x46>
    80002910:	46a1                	li	a3,8
    80002912:	8626                	mv	a2,s1
    80002914:	85ca                	mv	a1,s2
    80002916:	6928                	ld	a0,80(a0)
    80002918:	d11fe0ef          	jal	80001628 <copyin>
    8000291c:	00a03533          	snez	a0,a0
    80002920:	40a00533          	neg	a0,a0
    80002924:	60e2                	ld	ra,24(sp)
    80002926:	6442                	ld	s0,16(sp)
    80002928:	64a2                	ld	s1,8(sp)
    8000292a:	6902                	ld	s2,0(sp)
    8000292c:	6105                	addi	sp,sp,32
    8000292e:	8082                	ret
    80002930:	557d                	li	a0,-1
    80002932:	bfcd                	j	80002924 <fetchaddr+0x36>
    80002934:	557d                	li	a0,-1
    80002936:	b7fd                	j	80002924 <fetchaddr+0x36>

0000000080002938 <fetchstr>:
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
    8000294c:	f95fe0ef          	jal	800018e0 <myproc>
    80002950:	86ce                	mv	a3,s3
    80002952:	864a                	mv	a2,s2
    80002954:	85a6                	mv	a1,s1
    80002956:	6928                	ld	a0,80(a0)
    80002958:	d57fe0ef          	jal	800016ae <copyinstr>
    8000295c:	00054c63          	bltz	a0,80002974 <fetchstr+0x3c>
    80002960:	8526                	mv	a0,s1
    80002962:	cd6fe0ef          	jal	80000e38 <strlen>
    80002966:	70a2                	ld	ra,40(sp)
    80002968:	7402                	ld	s0,32(sp)
    8000296a:	64e2                	ld	s1,24(sp)
    8000296c:	6942                	ld	s2,16(sp)
    8000296e:	69a2                	ld	s3,8(sp)
    80002970:	6145                	addi	sp,sp,48
    80002972:	8082                	ret
    80002974:	557d                	li	a0,-1
    80002976:	bfc5                	j	80002966 <fetchstr+0x2e>

0000000080002978 <argint>:
    80002978:	1101                	addi	sp,sp,-32
    8000297a:	ec06                	sd	ra,24(sp)
    8000297c:	e822                	sd	s0,16(sp)
    8000297e:	e426                	sd	s1,8(sp)
    80002980:	1000                	addi	s0,sp,32
    80002982:	84ae                	mv	s1,a1
    80002984:	f0bff0ef          	jal	8000288e <argraw>
    80002988:	c088                	sw	a0,0(s1)
    8000298a:	60e2                	ld	ra,24(sp)
    8000298c:	6442                	ld	s0,16(sp)
    8000298e:	64a2                	ld	s1,8(sp)
    80002990:	6105                	addi	sp,sp,32
    80002992:	8082                	ret

0000000080002994 <argaddr>:
    80002994:	1101                	addi	sp,sp,-32
    80002996:	ec06                	sd	ra,24(sp)
    80002998:	e822                	sd	s0,16(sp)
    8000299a:	e426                	sd	s1,8(sp)
    8000299c:	1000                	addi	s0,sp,32
    8000299e:	84ae                	mv	s1,a1
    800029a0:	eefff0ef          	jal	8000288e <argraw>
    800029a4:	e088                	sd	a0,0(s1)
    800029a6:	60e2                	ld	ra,24(sp)
    800029a8:	6442                	ld	s0,16(sp)
    800029aa:	64a2                	ld	s1,8(sp)
    800029ac:	6105                	addi	sp,sp,32
    800029ae:	8082                	ret

00000000800029b0 <argstr>:
    800029b0:	7179                	addi	sp,sp,-48
    800029b2:	f406                	sd	ra,40(sp)
    800029b4:	f022                	sd	s0,32(sp)
    800029b6:	ec26                	sd	s1,24(sp)
    800029b8:	e84a                	sd	s2,16(sp)
    800029ba:	1800                	addi	s0,sp,48
    800029bc:	84ae                	mv	s1,a1
    800029be:	8932                	mv	s2,a2
    800029c0:	fd840593          	addi	a1,s0,-40
    800029c4:	fd1ff0ef          	jal	80002994 <argaddr>
    800029c8:	864a                	mv	a2,s2
    800029ca:	85a6                	mv	a1,s1
    800029cc:	fd843503          	ld	a0,-40(s0)
    800029d0:	f69ff0ef          	jal	80002938 <fetchstr>
    800029d4:	70a2                	ld	ra,40(sp)
    800029d6:	7402                	ld	s0,32(sp)
    800029d8:	64e2                	ld	s1,24(sp)
    800029da:	6942                	ld	s2,16(sp)
    800029dc:	6145                	addi	sp,sp,48
    800029de:	8082                	ret

00000000800029e0 <syscall>:
    800029e0:	1101                	addi	sp,sp,-32
    800029e2:	ec06                	sd	ra,24(sp)
    800029e4:	e822                	sd	s0,16(sp)
    800029e6:	e426                	sd	s1,8(sp)
    800029e8:	e04a                	sd	s2,0(sp)
    800029ea:	1000                	addi	s0,sp,32
    800029ec:	ef5fe0ef          	jal	800018e0 <myproc>
    800029f0:	84aa                	mv	s1,a0
    800029f2:	05853903          	ld	s2,88(a0)
    800029f6:	0a893783          	ld	a5,168(s2)
    800029fa:	0007869b          	sext.w	a3,a5
    800029fe:	37fd                	addiw	a5,a5,-1
    80002a00:	4761                	li	a4,24
    80002a02:	00f76f63          	bltu	a4,a5,80002a20 <syscall+0x40>
    80002a06:	00369713          	slli	a4,a3,0x3
    80002a0a:	00005797          	auipc	a5,0x5
    80002a0e:	e9e78793          	addi	a5,a5,-354 # 800078a8 <syscalls>
    80002a12:	97ba                	add	a5,a5,a4
    80002a14:	639c                	ld	a5,0(a5)
    80002a16:	c789                	beqz	a5,80002a20 <syscall+0x40>
    80002a18:	9782                	jalr	a5
    80002a1a:	06a93823          	sd	a0,112(s2)
    80002a1e:	a829                	j	80002a38 <syscall+0x58>
    80002a20:	15848613          	addi	a2,s1,344
    80002a24:	588c                	lw	a1,48(s1)
    80002a26:	00005517          	auipc	a0,0x5
    80002a2a:	a7250513          	addi	a0,a0,-1422 # 80007498 <etext+0x498>
    80002a2e:	a95fd0ef          	jal	800004c2 <printf>
    80002a32:	6cbc                	ld	a5,88(s1)
    80002a34:	577d                	li	a4,-1
    80002a36:	fbb8                	sd	a4,112(a5)
    80002a38:	60e2                	ld	ra,24(sp)
    80002a3a:	6442                	ld	s0,16(sp)
    80002a3c:	64a2                	ld	s1,8(sp)
    80002a3e:	6902                	ld	s2,0(sp)
    80002a40:	6105                	addi	sp,sp,32
    80002a42:	8082                	ret

0000000080002a44 <sys_exit>:
#include "proc.h"
extern struct proc proc[];

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

0000000080002a68 <sys_set_perm>:
uint64
sys_set_perm(void)
{
    80002a68:	1101                	addi	sp,sp,-32
    80002a6a:	ec06                	sd	ra,24(sp)
    80002a6c:	e822                	sd	s0,16(sp)
    80002a6e:	1000                	addi	s0,sp,32
    int pid, perm_flags;

    // Retrieve arguments using argint
    argint(0, &pid);
    80002a70:	fec40593          	addi	a1,s0,-20
    80002a74:	4501                	li	a0,0
    80002a76:	f03ff0ef          	jal	80002978 <argint>
    argint(1, &perm_flags);
    80002a7a:	fe840593          	addi	a1,s0,-24
    80002a7e:	4505                	li	a0,1
    80002a80:	ef9ff0ef          	jal	80002978 <argint>

    struct proc *p;

    // Loop through the process table to find the process with the given PID
    for (p = proc; p < &proc[NPROC]; p++) {
        if (p->pid == pid) {
    80002a84:	fec42683          	lw	a3,-20(s0)
    for (p = proc; p < &proc[NPROC]; p++) {
    80002a88:	00010797          	auipc	a5,0x10
    80002a8c:	f2878793          	addi	a5,a5,-216 # 800129b0 <proc>
    80002a90:	00016617          	auipc	a2,0x16
    80002a94:	b2060613          	addi	a2,a2,-1248 # 800185b0 <ptable>
        if (p->pid == pid) {
    80002a98:	5b98                	lw	a4,48(a5)
    80002a9a:	00d70863          	beq	a4,a3,80002aaa <sys_set_perm+0x42>
    for (p = proc; p < &proc[NPROC]; p++) {
    80002a9e:	17078793          	addi	a5,a5,368
    80002aa2:	fec79be3          	bne	a5,a2,80002a98 <sys_set_perm+0x30>
            p->perm_flags = perm_flags;  // Set the permission flags
            return 0;  // Success
        }
    }

    return -1;  // Process not found
    80002aa6:	557d                	li	a0,-1
    80002aa8:	a029                	j	80002ab2 <sys_set_perm+0x4a>
            p->perm_flags = perm_flags;  // Set the permission flags
    80002aaa:	fe842703          	lw	a4,-24(s0)
    80002aae:	cf98                	sw	a4,24(a5)
            return 0;  // Success
    80002ab0:	4501                	li	a0,0
}
    80002ab2:	60e2                	ld	ra,24(sp)
    80002ab4:	6442                	ld	s0,16(sp)
    80002ab6:	6105                	addi	sp,sp,32
    80002ab8:	8082                	ret

0000000080002aba <sys_getpid>:


uint64
sys_getpid(void)
{
    80002aba:	1141                	addi	sp,sp,-16
    80002abc:	e406                	sd	ra,8(sp)
    80002abe:	e022                	sd	s0,0(sp)
    80002ac0:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002ac2:	e1ffe0ef          	jal	800018e0 <myproc>
}
    80002ac6:	5908                	lw	a0,48(a0)
    80002ac8:	60a2                	ld	ra,8(sp)
    80002aca:	6402                	ld	s0,0(sp)
    80002acc:	0141                	addi	sp,sp,16
    80002ace:	8082                	ret

0000000080002ad0 <sys_fork>:

uint64
sys_fork(void)
{
    80002ad0:	1141                	addi	sp,sp,-16
    80002ad2:	e406                	sd	ra,8(sp)
    80002ad4:	e022                	sd	s0,0(sp)
    80002ad6:	0800                	addi	s0,sp,16
  return fork();
    80002ad8:	92eff0ef          	jal	80001c06 <fork>
}
    80002adc:	60a2                	ld	ra,8(sp)
    80002ade:	6402                	ld	s0,0(sp)
    80002ae0:	0141                	addi	sp,sp,16
    80002ae2:	8082                	ret

0000000080002ae4 <sys_wait>:

uint64
sys_wait(void)
{
    80002ae4:	1101                	addi	sp,sp,-32
    80002ae6:	ec06                	sd	ra,24(sp)
    80002ae8:	e822                	sd	s0,16(sp)
    80002aea:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002aec:	fe840593          	addi	a1,s0,-24
    80002af0:	4501                	li	a0,0
    80002af2:	ea3ff0ef          	jal	80002994 <argaddr>
  return wait(p);
    80002af6:	fe843503          	ld	a0,-24(s0)
    80002afa:	e16ff0ef          	jal	80002110 <wait>
}
    80002afe:	60e2                	ld	ra,24(sp)
    80002b00:	6442                	ld	s0,16(sp)
    80002b02:	6105                	addi	sp,sp,32
    80002b04:	8082                	ret

0000000080002b06 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002b06:	7179                	addi	sp,sp,-48
    80002b08:	f406                	sd	ra,40(sp)
    80002b0a:	f022                	sd	s0,32(sp)
    80002b0c:	ec26                	sd	s1,24(sp)
    80002b0e:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80002b10:	fdc40593          	addi	a1,s0,-36
    80002b14:	4501                	li	a0,0
    80002b16:	e63ff0ef          	jal	80002978 <argint>
  addr = myproc()->sz;
    80002b1a:	dc7fe0ef          	jal	800018e0 <myproc>
    80002b1e:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    80002b20:	fdc42503          	lw	a0,-36(s0)
    80002b24:	892ff0ef          	jal	80001bb6 <growproc>
    80002b28:	00054863          	bltz	a0,80002b38 <sys_sbrk+0x32>
    return -1;
  return addr;
}
    80002b2c:	8526                	mv	a0,s1
    80002b2e:	70a2                	ld	ra,40(sp)
    80002b30:	7402                	ld	s0,32(sp)
    80002b32:	64e2                	ld	s1,24(sp)
    80002b34:	6145                	addi	sp,sp,48
    80002b36:	8082                	ret
    return -1;
    80002b38:	54fd                	li	s1,-1
    80002b3a:	bfcd                	j	80002b2c <sys_sbrk+0x26>

0000000080002b3c <sys_sleep>:

uint64
sys_sleep(void)
{
    80002b3c:	7139                	addi	sp,sp,-64
    80002b3e:	fc06                	sd	ra,56(sp)
    80002b40:	f822                	sd	s0,48(sp)
    80002b42:	f04a                	sd	s2,32(sp)
    80002b44:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002b46:	fcc40593          	addi	a1,s0,-52
    80002b4a:	4501                	li	a0,0
    80002b4c:	e2dff0ef          	jal	80002978 <argint>
  if(n < 0)
    80002b50:	fcc42783          	lw	a5,-52(s0)
    80002b54:	0607c763          	bltz	a5,80002bc2 <sys_sleep+0x86>
    n = 0;
  acquire(&tickslock);
    80002b58:	0001b517          	auipc	a0,0x1b
    80002b5c:	67050513          	addi	a0,a0,1648 # 8001e1c8 <tickslock>
    80002b60:	894fe0ef          	jal	80000bf4 <acquire>
  ticks0 = ticks;
    80002b64:	00008917          	auipc	s2,0x8
    80002b68:	8ec92903          	lw	s2,-1812(s2) # 8000a450 <ticks>
  while(ticks - ticks0 < n){
    80002b6c:	fcc42783          	lw	a5,-52(s0)
    80002b70:	cf8d                	beqz	a5,80002baa <sys_sleep+0x6e>
    80002b72:	f426                	sd	s1,40(sp)
    80002b74:	ec4e                	sd	s3,24(sp)
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002b76:	0001b997          	auipc	s3,0x1b
    80002b7a:	65298993          	addi	s3,s3,1618 # 8001e1c8 <tickslock>
    80002b7e:	00008497          	auipc	s1,0x8
    80002b82:	8d248493          	addi	s1,s1,-1838 # 8000a450 <ticks>
    if(killed(myproc())){
    80002b86:	d5bfe0ef          	jal	800018e0 <myproc>
    80002b8a:	d5cff0ef          	jal	800020e6 <killed>
    80002b8e:	ed0d                	bnez	a0,80002bc8 <sys_sleep+0x8c>
    sleep(&ticks, &tickslock);
    80002b90:	85ce                	mv	a1,s3
    80002b92:	8526                	mv	a0,s1
    80002b94:	b1aff0ef          	jal	80001eae <sleep>
  while(ticks - ticks0 < n){
    80002b98:	409c                	lw	a5,0(s1)
    80002b9a:	412787bb          	subw	a5,a5,s2
    80002b9e:	fcc42703          	lw	a4,-52(s0)
    80002ba2:	fee7e2e3          	bltu	a5,a4,80002b86 <sys_sleep+0x4a>
    80002ba6:	74a2                	ld	s1,40(sp)
    80002ba8:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80002baa:	0001b517          	auipc	a0,0x1b
    80002bae:	61e50513          	addi	a0,a0,1566 # 8001e1c8 <tickslock>
    80002bb2:	8dafe0ef          	jal	80000c8c <release>
  return 0;
    80002bb6:	4501                	li	a0,0
}
    80002bb8:	70e2                	ld	ra,56(sp)
    80002bba:	7442                	ld	s0,48(sp)
    80002bbc:	7902                	ld	s2,32(sp)
    80002bbe:	6121                	addi	sp,sp,64
    80002bc0:	8082                	ret
    n = 0;
    80002bc2:	fc042623          	sw	zero,-52(s0)
    80002bc6:	bf49                	j	80002b58 <sys_sleep+0x1c>
      release(&tickslock);
    80002bc8:	0001b517          	auipc	a0,0x1b
    80002bcc:	60050513          	addi	a0,a0,1536 # 8001e1c8 <tickslock>
    80002bd0:	8bcfe0ef          	jal	80000c8c <release>
      return -1;
    80002bd4:	557d                	li	a0,-1
    80002bd6:	74a2                	ld	s1,40(sp)
    80002bd8:	69e2                	ld	s3,24(sp)
    80002bda:	bff9                	j	80002bb8 <sys_sleep+0x7c>

0000000080002bdc <sys_kill>:

uint64
sys_kill(void)
{
    80002bdc:	1101                	addi	sp,sp,-32
    80002bde:	ec06                	sd	ra,24(sp)
    80002be0:	e822                	sd	s0,16(sp)
    80002be2:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002be4:	fec40593          	addi	a1,s0,-20
    80002be8:	4501                	li	a0,0
    80002bea:	d8fff0ef          	jal	80002978 <argint>
  return kill(pid);
    80002bee:	fec42503          	lw	a0,-20(s0)
    80002bf2:	c6aff0ef          	jal	8000205c <kill>
}
    80002bf6:	60e2                	ld	ra,24(sp)
    80002bf8:	6442                	ld	s0,16(sp)
    80002bfa:	6105                	addi	sp,sp,32
    80002bfc:	8082                	ret

0000000080002bfe <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002bfe:	1101                	addi	sp,sp,-32
    80002c00:	ec06                	sd	ra,24(sp)
    80002c02:	e822                	sd	s0,16(sp)
    80002c04:	e426                	sd	s1,8(sp)
    80002c06:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002c08:	0001b517          	auipc	a0,0x1b
    80002c0c:	5c050513          	addi	a0,a0,1472 # 8001e1c8 <tickslock>
    80002c10:	fe5fd0ef          	jal	80000bf4 <acquire>
  xticks = ticks;
    80002c14:	00008497          	auipc	s1,0x8
    80002c18:	83c4a483          	lw	s1,-1988(s1) # 8000a450 <ticks>
  release(&tickslock);
    80002c1c:	0001b517          	auipc	a0,0x1b
    80002c20:	5ac50513          	addi	a0,a0,1452 # 8001e1c8 <tickslock>
    80002c24:	868fe0ef          	jal	80000c8c <release>
  return xticks;
}
    80002c28:	02049513          	slli	a0,s1,0x20
    80002c2c:	9101                	srli	a0,a0,0x20
    80002c2e:	60e2                	ld	ra,24(sp)
    80002c30:	6442                	ld	s0,16(sp)
    80002c32:	64a2                	ld	s1,8(sp)
    80002c34:	6105                	addi	sp,sp,32
    80002c36:	8082                	ret

0000000080002c38 <sys_ps>:

uint64
sys_ps ( void )
{
    80002c38:	1141                	addi	sp,sp,-16
    80002c3a:	e406                	sd	ra,8(sp)
    80002c3c:	e022                	sd	s0,0(sp)
    80002c3e:	0800                	addi	s0,sp,16
return ps ();
    80002c40:	f02ff0ef          	jal	80002342 <ps>
}  
    80002c44:	60a2                	ld	ra,8(sp)
    80002c46:	6402                	ld	s0,0(sp)
    80002c48:	0141                	addi	sp,sp,16
    80002c4a:	8082                	ret

0000000080002c4c <sys_fork2>:

uint64
sys_fork2(void)
{
    80002c4c:	1101                	addi	sp,sp,-32
    80002c4e:	ec06                	sd	ra,24(sp)
    80002c50:	e822                	sd	s0,16(sp)
    80002c52:	1000                	addi	s0,sp,32
    int priority;
    printf("sys_fork2 called by PID: %d\n", myproc()->pid);
    80002c54:	c8dfe0ef          	jal	800018e0 <myproc>
    80002c58:	590c                	lw	a1,48(a0)
    80002c5a:	00005517          	auipc	a0,0x5
    80002c5e:	85e50513          	addi	a0,a0,-1954 # 800074b8 <etext+0x4b8>
    80002c62:	861fd0ef          	jal	800004c2 <printf>

    argint(0, &priority);
    80002c66:	fec40593          	addi	a1,s0,-20
    80002c6a:	4501                	li	a0,0
    80002c6c:	d0dff0ef          	jal	80002978 <argint>

    printf("sys_fork2 priority: %d\n", priority);
    80002c70:	fec42583          	lw	a1,-20(s0)
    80002c74:	00005517          	auipc	a0,0x5
    80002c78:	86450513          	addi	a0,a0,-1948 # 800074d8 <etext+0x4d8>
    80002c7c:	847fd0ef          	jal	800004c2 <printf>

    return fork_with_priority(priority);
    80002c80:	fec42503          	lw	a0,-20(s0)
    80002c84:	fbaff0ef          	jal	8000243e <fork_with_priority>
}
    80002c88:	60e2                	ld	ra,24(sp)
    80002c8a:	6442                	ld	s0,16(sp)
    80002c8c:	6105                	addi	sp,sp,32
    80002c8e:	8082                	ret

0000000080002c90 <sys_get_ppid>:


uint64
sys_get_ppid(void)
{
    80002c90:	1141                	addi	sp,sp,-16
    80002c92:	e406                	sd	ra,8(sp)
    80002c94:	e022                	sd	s0,0(sp)
    80002c96:	0800                	addi	s0,sp,16
    struct proc *p = myproc(); // Get the current process
    80002c98:	c49fe0ef          	jal	800018e0 <myproc>
    if (p->parent) {
    80002c9c:	7d1c                	ld	a5,56(a0)
        return p->parent->pid; // Return parent PID
    }
    return -1; // No parent (e.g., init process)
    80002c9e:	557d                	li	a0,-1
    if (p->parent) {
    80002ca0:	c391                	beqz	a5,80002ca4 <sys_get_ppid+0x14>
        return p->parent->pid; // Return parent PID
    80002ca2:	5b88                	lw	a0,48(a5)
}
    80002ca4:	60a2                	ld	ra,8(sp)
    80002ca6:	6402                	ld	s0,0(sp)
    80002ca8:	0141                	addi	sp,sp,16
    80002caa:	8082                	ret

0000000080002cac <binit>:
    80002cac:	7179                	addi	sp,sp,-48
    80002cae:	f406                	sd	ra,40(sp)
    80002cb0:	f022                	sd	s0,32(sp)
    80002cb2:	ec26                	sd	s1,24(sp)
    80002cb4:	e84a                	sd	s2,16(sp)
    80002cb6:	e44e                	sd	s3,8(sp)
    80002cb8:	e052                	sd	s4,0(sp)
    80002cba:	1800                	addi	s0,sp,48
    80002cbc:	00005597          	auipc	a1,0x5
    80002cc0:	83458593          	addi	a1,a1,-1996 # 800074f0 <etext+0x4f0>
    80002cc4:	0001b517          	auipc	a0,0x1b
    80002cc8:	51c50513          	addi	a0,a0,1308 # 8001e1e0 <bcache>
    80002ccc:	ea9fd0ef          	jal	80000b74 <initlock>
    80002cd0:	00023797          	auipc	a5,0x23
    80002cd4:	51078793          	addi	a5,a5,1296 # 800261e0 <bcache+0x8000>
    80002cd8:	00023717          	auipc	a4,0x23
    80002cdc:	77070713          	addi	a4,a4,1904 # 80026448 <bcache+0x8268>
    80002ce0:	2ae7b823          	sd	a4,688(a5)
    80002ce4:	2ae7bc23          	sd	a4,696(a5)
    80002ce8:	0001b497          	auipc	s1,0x1b
    80002cec:	51048493          	addi	s1,s1,1296 # 8001e1f8 <bcache+0x18>
    80002cf0:	893e                	mv	s2,a5
    80002cf2:	89ba                	mv	s3,a4
    80002cf4:	00005a17          	auipc	s4,0x5
    80002cf8:	804a0a13          	addi	s4,s4,-2044 # 800074f8 <etext+0x4f8>
    80002cfc:	2b893783          	ld	a5,696(s2)
    80002d00:	e8bc                	sd	a5,80(s1)
    80002d02:	0534b423          	sd	s3,72(s1)
    80002d06:	85d2                	mv	a1,s4
    80002d08:	01048513          	addi	a0,s1,16
    80002d0c:	248010ef          	jal	80003f54 <initsleeplock>
    80002d10:	2b893783          	ld	a5,696(s2)
    80002d14:	e7a4                	sd	s1,72(a5)
    80002d16:	2a993c23          	sd	s1,696(s2)
    80002d1a:	45848493          	addi	s1,s1,1112
    80002d1e:	fd349fe3          	bne	s1,s3,80002cfc <binit+0x50>
    80002d22:	70a2                	ld	ra,40(sp)
    80002d24:	7402                	ld	s0,32(sp)
    80002d26:	64e2                	ld	s1,24(sp)
    80002d28:	6942                	ld	s2,16(sp)
    80002d2a:	69a2                	ld	s3,8(sp)
    80002d2c:	6a02                	ld	s4,0(sp)
    80002d2e:	6145                	addi	sp,sp,48
    80002d30:	8082                	ret

0000000080002d32 <bread>:
    80002d32:	7179                	addi	sp,sp,-48
    80002d34:	f406                	sd	ra,40(sp)
    80002d36:	f022                	sd	s0,32(sp)
    80002d38:	ec26                	sd	s1,24(sp)
    80002d3a:	e84a                	sd	s2,16(sp)
    80002d3c:	e44e                	sd	s3,8(sp)
    80002d3e:	1800                	addi	s0,sp,48
    80002d40:	892a                	mv	s2,a0
    80002d42:	89ae                	mv	s3,a1
    80002d44:	0001b517          	auipc	a0,0x1b
    80002d48:	49c50513          	addi	a0,a0,1180 # 8001e1e0 <bcache>
    80002d4c:	ea9fd0ef          	jal	80000bf4 <acquire>
    80002d50:	00023497          	auipc	s1,0x23
    80002d54:	7484b483          	ld	s1,1864(s1) # 80026498 <bcache+0x82b8>
    80002d58:	00023797          	auipc	a5,0x23
    80002d5c:	6f078793          	addi	a5,a5,1776 # 80026448 <bcache+0x8268>
    80002d60:	02f48b63          	beq	s1,a5,80002d96 <bread+0x64>
    80002d64:	873e                	mv	a4,a5
    80002d66:	a021                	j	80002d6e <bread+0x3c>
    80002d68:	68a4                	ld	s1,80(s1)
    80002d6a:	02e48663          	beq	s1,a4,80002d96 <bread+0x64>
    80002d6e:	449c                	lw	a5,8(s1)
    80002d70:	ff279ce3          	bne	a5,s2,80002d68 <bread+0x36>
    80002d74:	44dc                	lw	a5,12(s1)
    80002d76:	ff3799e3          	bne	a5,s3,80002d68 <bread+0x36>
    80002d7a:	40bc                	lw	a5,64(s1)
    80002d7c:	2785                	addiw	a5,a5,1
    80002d7e:	c0bc                	sw	a5,64(s1)
    80002d80:	0001b517          	auipc	a0,0x1b
    80002d84:	46050513          	addi	a0,a0,1120 # 8001e1e0 <bcache>
    80002d88:	f05fd0ef          	jal	80000c8c <release>
    80002d8c:	01048513          	addi	a0,s1,16
    80002d90:	1fa010ef          	jal	80003f8a <acquiresleep>
    80002d94:	a889                	j	80002de6 <bread+0xb4>
    80002d96:	00023497          	auipc	s1,0x23
    80002d9a:	6fa4b483          	ld	s1,1786(s1) # 80026490 <bcache+0x82b0>
    80002d9e:	00023797          	auipc	a5,0x23
    80002da2:	6aa78793          	addi	a5,a5,1706 # 80026448 <bcache+0x8268>
    80002da6:	00f48863          	beq	s1,a5,80002db6 <bread+0x84>
    80002daa:	873e                	mv	a4,a5
    80002dac:	40bc                	lw	a5,64(s1)
    80002dae:	cb91                	beqz	a5,80002dc2 <bread+0x90>
    80002db0:	64a4                	ld	s1,72(s1)
    80002db2:	fee49de3          	bne	s1,a4,80002dac <bread+0x7a>
    80002db6:	00004517          	auipc	a0,0x4
    80002dba:	74a50513          	addi	a0,a0,1866 # 80007500 <etext+0x500>
    80002dbe:	9d7fd0ef          	jal	80000794 <panic>
    80002dc2:	0124a423          	sw	s2,8(s1)
    80002dc6:	0134a623          	sw	s3,12(s1)
    80002dca:	0004a023          	sw	zero,0(s1)
    80002dce:	4785                	li	a5,1
    80002dd0:	c0bc                	sw	a5,64(s1)
    80002dd2:	0001b517          	auipc	a0,0x1b
    80002dd6:	40e50513          	addi	a0,a0,1038 # 8001e1e0 <bcache>
    80002dda:	eb3fd0ef          	jal	80000c8c <release>
    80002dde:	01048513          	addi	a0,s1,16
    80002de2:	1a8010ef          	jal	80003f8a <acquiresleep>
    80002de6:	409c                	lw	a5,0(s1)
    80002de8:	cb89                	beqz	a5,80002dfa <bread+0xc8>
    80002dea:	8526                	mv	a0,s1
    80002dec:	70a2                	ld	ra,40(sp)
    80002dee:	7402                	ld	s0,32(sp)
    80002df0:	64e2                	ld	s1,24(sp)
    80002df2:	6942                	ld	s2,16(sp)
    80002df4:	69a2                	ld	s3,8(sp)
    80002df6:	6145                	addi	sp,sp,48
    80002df8:	8082                	ret
    80002dfa:	4581                	li	a1,0
    80002dfc:	8526                	mv	a0,s1
    80002dfe:	1f3020ef          	jal	800057f0 <virtio_disk_rw>
    80002e02:	4785                	li	a5,1
    80002e04:	c09c                	sw	a5,0(s1)
    80002e06:	b7d5                	j	80002dea <bread+0xb8>

0000000080002e08 <bwrite>:
    80002e08:	1101                	addi	sp,sp,-32
    80002e0a:	ec06                	sd	ra,24(sp)
    80002e0c:	e822                	sd	s0,16(sp)
    80002e0e:	e426                	sd	s1,8(sp)
    80002e10:	1000                	addi	s0,sp,32
    80002e12:	84aa                	mv	s1,a0
    80002e14:	0541                	addi	a0,a0,16
    80002e16:	1f2010ef          	jal	80004008 <holdingsleep>
    80002e1a:	c911                	beqz	a0,80002e2e <bwrite+0x26>
    80002e1c:	4585                	li	a1,1
    80002e1e:	8526                	mv	a0,s1
    80002e20:	1d1020ef          	jal	800057f0 <virtio_disk_rw>
    80002e24:	60e2                	ld	ra,24(sp)
    80002e26:	6442                	ld	s0,16(sp)
    80002e28:	64a2                	ld	s1,8(sp)
    80002e2a:	6105                	addi	sp,sp,32
    80002e2c:	8082                	ret
    80002e2e:	00004517          	auipc	a0,0x4
    80002e32:	6ea50513          	addi	a0,a0,1770 # 80007518 <etext+0x518>
    80002e36:	95ffd0ef          	jal	80000794 <panic>

0000000080002e3a <brelse>:
    80002e3a:	1101                	addi	sp,sp,-32
    80002e3c:	ec06                	sd	ra,24(sp)
    80002e3e:	e822                	sd	s0,16(sp)
    80002e40:	e426                	sd	s1,8(sp)
    80002e42:	e04a                	sd	s2,0(sp)
    80002e44:	1000                	addi	s0,sp,32
    80002e46:	84aa                	mv	s1,a0
    80002e48:	01050913          	addi	s2,a0,16
    80002e4c:	854a                	mv	a0,s2
    80002e4e:	1ba010ef          	jal	80004008 <holdingsleep>
    80002e52:	c135                	beqz	a0,80002eb6 <brelse+0x7c>
    80002e54:	854a                	mv	a0,s2
    80002e56:	17a010ef          	jal	80003fd0 <releasesleep>
    80002e5a:	0001b517          	auipc	a0,0x1b
    80002e5e:	38650513          	addi	a0,a0,902 # 8001e1e0 <bcache>
    80002e62:	d93fd0ef          	jal	80000bf4 <acquire>
    80002e66:	40bc                	lw	a5,64(s1)
    80002e68:	37fd                	addiw	a5,a5,-1
    80002e6a:	0007871b          	sext.w	a4,a5
    80002e6e:	c0bc                	sw	a5,64(s1)
    80002e70:	e71d                	bnez	a4,80002e9e <brelse+0x64>
    80002e72:	68b8                	ld	a4,80(s1)
    80002e74:	64bc                	ld	a5,72(s1)
    80002e76:	e73c                	sd	a5,72(a4)
    80002e78:	68b8                	ld	a4,80(s1)
    80002e7a:	ebb8                	sd	a4,80(a5)
    80002e7c:	00023797          	auipc	a5,0x23
    80002e80:	36478793          	addi	a5,a5,868 # 800261e0 <bcache+0x8000>
    80002e84:	2b87b703          	ld	a4,696(a5)
    80002e88:	e8b8                	sd	a4,80(s1)
    80002e8a:	00023717          	auipc	a4,0x23
    80002e8e:	5be70713          	addi	a4,a4,1470 # 80026448 <bcache+0x8268>
    80002e92:	e4b8                	sd	a4,72(s1)
    80002e94:	2b87b703          	ld	a4,696(a5)
    80002e98:	e724                	sd	s1,72(a4)
    80002e9a:	2a97bc23          	sd	s1,696(a5)
    80002e9e:	0001b517          	auipc	a0,0x1b
    80002ea2:	34250513          	addi	a0,a0,834 # 8001e1e0 <bcache>
    80002ea6:	de7fd0ef          	jal	80000c8c <release>
    80002eaa:	60e2                	ld	ra,24(sp)
    80002eac:	6442                	ld	s0,16(sp)
    80002eae:	64a2                	ld	s1,8(sp)
    80002eb0:	6902                	ld	s2,0(sp)
    80002eb2:	6105                	addi	sp,sp,32
    80002eb4:	8082                	ret
    80002eb6:	00004517          	auipc	a0,0x4
    80002eba:	66a50513          	addi	a0,a0,1642 # 80007520 <etext+0x520>
    80002ebe:	8d7fd0ef          	jal	80000794 <panic>

0000000080002ec2 <bpin>:
    80002ec2:	1101                	addi	sp,sp,-32
    80002ec4:	ec06                	sd	ra,24(sp)
    80002ec6:	e822                	sd	s0,16(sp)
    80002ec8:	e426                	sd	s1,8(sp)
    80002eca:	1000                	addi	s0,sp,32
    80002ecc:	84aa                	mv	s1,a0
    80002ece:	0001b517          	auipc	a0,0x1b
    80002ed2:	31250513          	addi	a0,a0,786 # 8001e1e0 <bcache>
    80002ed6:	d1ffd0ef          	jal	80000bf4 <acquire>
    80002eda:	40bc                	lw	a5,64(s1)
    80002edc:	2785                	addiw	a5,a5,1
    80002ede:	c0bc                	sw	a5,64(s1)
    80002ee0:	0001b517          	auipc	a0,0x1b
    80002ee4:	30050513          	addi	a0,a0,768 # 8001e1e0 <bcache>
    80002ee8:	da5fd0ef          	jal	80000c8c <release>
    80002eec:	60e2                	ld	ra,24(sp)
    80002eee:	6442                	ld	s0,16(sp)
    80002ef0:	64a2                	ld	s1,8(sp)
    80002ef2:	6105                	addi	sp,sp,32
    80002ef4:	8082                	ret

0000000080002ef6 <bunpin>:
    80002ef6:	1101                	addi	sp,sp,-32
    80002ef8:	ec06                	sd	ra,24(sp)
    80002efa:	e822                	sd	s0,16(sp)
    80002efc:	e426                	sd	s1,8(sp)
    80002efe:	1000                	addi	s0,sp,32
    80002f00:	84aa                	mv	s1,a0
    80002f02:	0001b517          	auipc	a0,0x1b
    80002f06:	2de50513          	addi	a0,a0,734 # 8001e1e0 <bcache>
    80002f0a:	cebfd0ef          	jal	80000bf4 <acquire>
    80002f0e:	40bc                	lw	a5,64(s1)
    80002f10:	37fd                	addiw	a5,a5,-1
    80002f12:	c0bc                	sw	a5,64(s1)
    80002f14:	0001b517          	auipc	a0,0x1b
    80002f18:	2cc50513          	addi	a0,a0,716 # 8001e1e0 <bcache>
    80002f1c:	d71fd0ef          	jal	80000c8c <release>
    80002f20:	60e2                	ld	ra,24(sp)
    80002f22:	6442                	ld	s0,16(sp)
    80002f24:	64a2                	ld	s1,8(sp)
    80002f26:	6105                	addi	sp,sp,32
    80002f28:	8082                	ret

0000000080002f2a <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80002f2a:	1101                	addi	sp,sp,-32
    80002f2c:	ec06                	sd	ra,24(sp)
    80002f2e:	e822                	sd	s0,16(sp)
    80002f30:	e426                	sd	s1,8(sp)
    80002f32:	e04a                	sd	s2,0(sp)
    80002f34:	1000                	addi	s0,sp,32
    80002f36:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80002f38:	00d5d59b          	srliw	a1,a1,0xd
    80002f3c:	00024797          	auipc	a5,0x24
    80002f40:	9807a783          	lw	a5,-1664(a5) # 800268bc <sb+0x1c>
    80002f44:	9dbd                	addw	a1,a1,a5
    80002f46:	dedff0ef          	jal	80002d32 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80002f4a:	0074f713          	andi	a4,s1,7
    80002f4e:	4785                	li	a5,1
    80002f50:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80002f54:	14ce                	slli	s1,s1,0x33
    80002f56:	90d9                	srli	s1,s1,0x36
    80002f58:	00950733          	add	a4,a0,s1
    80002f5c:	05874703          	lbu	a4,88(a4)
    80002f60:	00e7f6b3          	and	a3,a5,a4
    80002f64:	c29d                	beqz	a3,80002f8a <bfree+0x60>
    80002f66:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80002f68:	94aa                	add	s1,s1,a0
    80002f6a:	fff7c793          	not	a5,a5
    80002f6e:	8f7d                	and	a4,a4,a5
    80002f70:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80002f74:	711000ef          	jal	80003e84 <log_write>
  brelse(bp);
    80002f78:	854a                	mv	a0,s2
    80002f7a:	ec1ff0ef          	jal	80002e3a <brelse>
}
    80002f7e:	60e2                	ld	ra,24(sp)
    80002f80:	6442                	ld	s0,16(sp)
    80002f82:	64a2                	ld	s1,8(sp)
    80002f84:	6902                	ld	s2,0(sp)
    80002f86:	6105                	addi	sp,sp,32
    80002f88:	8082                	ret
    panic("freeing free block");
    80002f8a:	00004517          	auipc	a0,0x4
    80002f8e:	59e50513          	addi	a0,a0,1438 # 80007528 <etext+0x528>
    80002f92:	803fd0ef          	jal	80000794 <panic>

0000000080002f96 <balloc>:
{
    80002f96:	711d                	addi	sp,sp,-96
    80002f98:	ec86                	sd	ra,88(sp)
    80002f9a:	e8a2                	sd	s0,80(sp)
    80002f9c:	e4a6                	sd	s1,72(sp)
    80002f9e:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80002fa0:	00024797          	auipc	a5,0x24
    80002fa4:	9047a783          	lw	a5,-1788(a5) # 800268a4 <sb+0x4>
    80002fa8:	0e078f63          	beqz	a5,800030a6 <balloc+0x110>
    80002fac:	e0ca                	sd	s2,64(sp)
    80002fae:	fc4e                	sd	s3,56(sp)
    80002fb0:	f852                	sd	s4,48(sp)
    80002fb2:	f456                	sd	s5,40(sp)
    80002fb4:	f05a                	sd	s6,32(sp)
    80002fb6:	ec5e                	sd	s7,24(sp)
    80002fb8:	e862                	sd	s8,16(sp)
    80002fba:	e466                	sd	s9,8(sp)
    80002fbc:	8baa                	mv	s7,a0
    80002fbe:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80002fc0:	00024b17          	auipc	s6,0x24
    80002fc4:	8e0b0b13          	addi	s6,s6,-1824 # 800268a0 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002fc8:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80002fca:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002fcc:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80002fce:	6c89                	lui	s9,0x2
    80002fd0:	a0b5                	j	8000303c <balloc+0xa6>
        bp->data[bi/8] |= m;  // Mark block in use.
    80002fd2:	97ca                	add	a5,a5,s2
    80002fd4:	8e55                	or	a2,a2,a3
    80002fd6:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80002fda:	854a                	mv	a0,s2
    80002fdc:	6a9000ef          	jal	80003e84 <log_write>
        brelse(bp);
    80002fe0:	854a                	mv	a0,s2
    80002fe2:	e59ff0ef          	jal	80002e3a <brelse>
  bp = bread(dev, bno);
    80002fe6:	85a6                	mv	a1,s1
    80002fe8:	855e                	mv	a0,s7
    80002fea:	d49ff0ef          	jal	80002d32 <bread>
    80002fee:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80002ff0:	40000613          	li	a2,1024
    80002ff4:	4581                	li	a1,0
    80002ff6:	05850513          	addi	a0,a0,88
    80002ffa:	ccffd0ef          	jal	80000cc8 <memset>
  log_write(bp);
    80002ffe:	854a                	mv	a0,s2
    80003000:	685000ef          	jal	80003e84 <log_write>
  brelse(bp);
    80003004:	854a                	mv	a0,s2
    80003006:	e35ff0ef          	jal	80002e3a <brelse>
}
    8000300a:	6906                	ld	s2,64(sp)
    8000300c:	79e2                	ld	s3,56(sp)
    8000300e:	7a42                	ld	s4,48(sp)
    80003010:	7aa2                	ld	s5,40(sp)
    80003012:	7b02                	ld	s6,32(sp)
    80003014:	6be2                	ld	s7,24(sp)
    80003016:	6c42                	ld	s8,16(sp)
    80003018:	6ca2                	ld	s9,8(sp)
}
    8000301a:	8526                	mv	a0,s1
    8000301c:	60e6                	ld	ra,88(sp)
    8000301e:	6446                	ld	s0,80(sp)
    80003020:	64a6                	ld	s1,72(sp)
    80003022:	6125                	addi	sp,sp,96
    80003024:	8082                	ret
    brelse(bp);
    80003026:	854a                	mv	a0,s2
    80003028:	e13ff0ef          	jal	80002e3a <brelse>
  for(b = 0; b < sb.size; b += BPB){
    8000302c:	015c87bb          	addw	a5,s9,s5
    80003030:	00078a9b          	sext.w	s5,a5
    80003034:	004b2703          	lw	a4,4(s6)
    80003038:	04eaff63          	bgeu	s5,a4,80003096 <balloc+0x100>
    bp = bread(dev, BBLOCK(b, sb));
    8000303c:	41fad79b          	sraiw	a5,s5,0x1f
    80003040:	0137d79b          	srliw	a5,a5,0x13
    80003044:	015787bb          	addw	a5,a5,s5
    80003048:	40d7d79b          	sraiw	a5,a5,0xd
    8000304c:	01cb2583          	lw	a1,28(s6)
    80003050:	9dbd                	addw	a1,a1,a5
    80003052:	855e                	mv	a0,s7
    80003054:	cdfff0ef          	jal	80002d32 <bread>
    80003058:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000305a:	004b2503          	lw	a0,4(s6)
    8000305e:	000a849b          	sext.w	s1,s5
    80003062:	8762                	mv	a4,s8
    80003064:	fca4f1e3          	bgeu	s1,a0,80003026 <balloc+0x90>
      m = 1 << (bi % 8);
    80003068:	00777693          	andi	a3,a4,7
    8000306c:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003070:	41f7579b          	sraiw	a5,a4,0x1f
    80003074:	01d7d79b          	srliw	a5,a5,0x1d
    80003078:	9fb9                	addw	a5,a5,a4
    8000307a:	4037d79b          	sraiw	a5,a5,0x3
    8000307e:	00f90633          	add	a2,s2,a5
    80003082:	05864603          	lbu	a2,88(a2)
    80003086:	00c6f5b3          	and	a1,a3,a2
    8000308a:	d5a1                	beqz	a1,80002fd2 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000308c:	2705                	addiw	a4,a4,1
    8000308e:	2485                	addiw	s1,s1,1
    80003090:	fd471ae3          	bne	a4,s4,80003064 <balloc+0xce>
    80003094:	bf49                	j	80003026 <balloc+0x90>
    80003096:	6906                	ld	s2,64(sp)
    80003098:	79e2                	ld	s3,56(sp)
    8000309a:	7a42                	ld	s4,48(sp)
    8000309c:	7aa2                	ld	s5,40(sp)
    8000309e:	7b02                	ld	s6,32(sp)
    800030a0:	6be2                	ld	s7,24(sp)
    800030a2:	6c42                	ld	s8,16(sp)
    800030a4:	6ca2                	ld	s9,8(sp)
  printf("balloc: out of blocks\n");
    800030a6:	00004517          	auipc	a0,0x4
    800030aa:	49a50513          	addi	a0,a0,1178 # 80007540 <etext+0x540>
    800030ae:	c14fd0ef          	jal	800004c2 <printf>
  return 0;
    800030b2:	4481                	li	s1,0
    800030b4:	b79d                	j	8000301a <balloc+0x84>

00000000800030b6 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    800030b6:	7179                	addi	sp,sp,-48
    800030b8:	f406                	sd	ra,40(sp)
    800030ba:	f022                	sd	s0,32(sp)
    800030bc:	ec26                	sd	s1,24(sp)
    800030be:	e84a                	sd	s2,16(sp)
    800030c0:	e44e                	sd	s3,8(sp)
    800030c2:	1800                	addi	s0,sp,48
    800030c4:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800030c6:	47ad                	li	a5,11
    800030c8:	02b7e663          	bltu	a5,a1,800030f4 <bmap+0x3e>
    if((addr = ip->addrs[bn]) == 0){
    800030cc:	02059793          	slli	a5,a1,0x20
    800030d0:	01e7d593          	srli	a1,a5,0x1e
    800030d4:	00b504b3          	add	s1,a0,a1
    800030d8:	0504a903          	lw	s2,80(s1)
    800030dc:	06091a63          	bnez	s2,80003150 <bmap+0x9a>
      addr = balloc(ip->dev);
    800030e0:	4108                	lw	a0,0(a0)
    800030e2:	eb5ff0ef          	jal	80002f96 <balloc>
    800030e6:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800030ea:	06090363          	beqz	s2,80003150 <bmap+0x9a>
        return 0;
      ip->addrs[bn] = addr;
    800030ee:	0524a823          	sw	s2,80(s1)
    800030f2:	a8b9                	j	80003150 <bmap+0x9a>
    }
    return addr;
  }
  bn -= NDIRECT;
    800030f4:	ff45849b          	addiw	s1,a1,-12
    800030f8:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800030fc:	0ff00793          	li	a5,255
    80003100:	06e7ee63          	bltu	a5,a4,8000317c <bmap+0xc6>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003104:	08052903          	lw	s2,128(a0)
    80003108:	00091d63          	bnez	s2,80003122 <bmap+0x6c>
      addr = balloc(ip->dev);
    8000310c:	4108                	lw	a0,0(a0)
    8000310e:	e89ff0ef          	jal	80002f96 <balloc>
    80003112:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003116:	02090d63          	beqz	s2,80003150 <bmap+0x9a>
    8000311a:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    8000311c:	0929a023          	sw	s2,128(s3)
    80003120:	a011                	j	80003124 <bmap+0x6e>
    80003122:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    80003124:	85ca                	mv	a1,s2
    80003126:	0009a503          	lw	a0,0(s3)
    8000312a:	c09ff0ef          	jal	80002d32 <bread>
    8000312e:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003130:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003134:	02049713          	slli	a4,s1,0x20
    80003138:	01e75593          	srli	a1,a4,0x1e
    8000313c:	00b784b3          	add	s1,a5,a1
    80003140:	0004a903          	lw	s2,0(s1)
    80003144:	00090e63          	beqz	s2,80003160 <bmap+0xaa>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003148:	8552                	mv	a0,s4
    8000314a:	cf1ff0ef          	jal	80002e3a <brelse>
    return addr;
    8000314e:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    80003150:	854a                	mv	a0,s2
    80003152:	70a2                	ld	ra,40(sp)
    80003154:	7402                	ld	s0,32(sp)
    80003156:	64e2                	ld	s1,24(sp)
    80003158:	6942                	ld	s2,16(sp)
    8000315a:	69a2                	ld	s3,8(sp)
    8000315c:	6145                	addi	sp,sp,48
    8000315e:	8082                	ret
      addr = balloc(ip->dev);
    80003160:	0009a503          	lw	a0,0(s3)
    80003164:	e33ff0ef          	jal	80002f96 <balloc>
    80003168:	0005091b          	sext.w	s2,a0
      if(addr){
    8000316c:	fc090ee3          	beqz	s2,80003148 <bmap+0x92>
        a[bn] = addr;
    80003170:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003174:	8552                	mv	a0,s4
    80003176:	50f000ef          	jal	80003e84 <log_write>
    8000317a:	b7f9                	j	80003148 <bmap+0x92>
    8000317c:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    8000317e:	00004517          	auipc	a0,0x4
    80003182:	3da50513          	addi	a0,a0,986 # 80007558 <etext+0x558>
    80003186:	e0efd0ef          	jal	80000794 <panic>

000000008000318a <iget>:
{
    8000318a:	7179                	addi	sp,sp,-48
    8000318c:	f406                	sd	ra,40(sp)
    8000318e:	f022                	sd	s0,32(sp)
    80003190:	ec26                	sd	s1,24(sp)
    80003192:	e84a                	sd	s2,16(sp)
    80003194:	e44e                	sd	s3,8(sp)
    80003196:	e052                	sd	s4,0(sp)
    80003198:	1800                	addi	s0,sp,48
    8000319a:	89aa                	mv	s3,a0
    8000319c:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    8000319e:	00023517          	auipc	a0,0x23
    800031a2:	72250513          	addi	a0,a0,1826 # 800268c0 <itable>
    800031a6:	a4ffd0ef          	jal	80000bf4 <acquire>
  empty = 0;
    800031aa:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800031ac:	00023497          	auipc	s1,0x23
    800031b0:	72c48493          	addi	s1,s1,1836 # 800268d8 <itable+0x18>
    800031b4:	00025697          	auipc	a3,0x25
    800031b8:	1b468693          	addi	a3,a3,436 # 80028368 <log>
    800031bc:	a039                	j	800031ca <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800031be:	02090963          	beqz	s2,800031f0 <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800031c2:	08848493          	addi	s1,s1,136
    800031c6:	02d48863          	beq	s1,a3,800031f6 <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800031ca:	449c                	lw	a5,8(s1)
    800031cc:	fef059e3          	blez	a5,800031be <iget+0x34>
    800031d0:	4098                	lw	a4,0(s1)
    800031d2:	ff3716e3          	bne	a4,s3,800031be <iget+0x34>
    800031d6:	40d8                	lw	a4,4(s1)
    800031d8:	ff4713e3          	bne	a4,s4,800031be <iget+0x34>
      ip->ref++;
    800031dc:	2785                	addiw	a5,a5,1
    800031de:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    800031e0:	00023517          	auipc	a0,0x23
    800031e4:	6e050513          	addi	a0,a0,1760 # 800268c0 <itable>
    800031e8:	aa5fd0ef          	jal	80000c8c <release>
      return ip;
    800031ec:	8926                	mv	s2,s1
    800031ee:	a02d                	j	80003218 <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800031f0:	fbe9                	bnez	a5,800031c2 <iget+0x38>
      empty = ip;
    800031f2:	8926                	mv	s2,s1
    800031f4:	b7f9                	j	800031c2 <iget+0x38>
  if(empty == 0)
    800031f6:	02090a63          	beqz	s2,8000322a <iget+0xa0>
  ip->dev = dev;
    800031fa:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800031fe:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003202:	4785                	li	a5,1
    80003204:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003208:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    8000320c:	00023517          	auipc	a0,0x23
    80003210:	6b450513          	addi	a0,a0,1716 # 800268c0 <itable>
    80003214:	a79fd0ef          	jal	80000c8c <release>
}
    80003218:	854a                	mv	a0,s2
    8000321a:	70a2                	ld	ra,40(sp)
    8000321c:	7402                	ld	s0,32(sp)
    8000321e:	64e2                	ld	s1,24(sp)
    80003220:	6942                	ld	s2,16(sp)
    80003222:	69a2                	ld	s3,8(sp)
    80003224:	6a02                	ld	s4,0(sp)
    80003226:	6145                	addi	sp,sp,48
    80003228:	8082                	ret
    panic("iget: no inodes");
    8000322a:	00004517          	auipc	a0,0x4
    8000322e:	34650513          	addi	a0,a0,838 # 80007570 <etext+0x570>
    80003232:	d62fd0ef          	jal	80000794 <panic>

0000000080003236 <fsinit>:
fsinit(int dev) {
    80003236:	7179                	addi	sp,sp,-48
    80003238:	f406                	sd	ra,40(sp)
    8000323a:	f022                	sd	s0,32(sp)
    8000323c:	ec26                	sd	s1,24(sp)
    8000323e:	e84a                	sd	s2,16(sp)
    80003240:	e44e                	sd	s3,8(sp)
    80003242:	1800                	addi	s0,sp,48
    80003244:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003246:	4585                	li	a1,1
    80003248:	aebff0ef          	jal	80002d32 <bread>
    8000324c:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    8000324e:	00023997          	auipc	s3,0x23
    80003252:	65298993          	addi	s3,s3,1618 # 800268a0 <sb>
    80003256:	02000613          	li	a2,32
    8000325a:	05850593          	addi	a1,a0,88
    8000325e:	854e                	mv	a0,s3
    80003260:	ac5fd0ef          	jal	80000d24 <memmove>
  brelse(bp);
    80003264:	8526                	mv	a0,s1
    80003266:	bd5ff0ef          	jal	80002e3a <brelse>
  if(sb.magic != FSMAGIC)
    8000326a:	0009a703          	lw	a4,0(s3)
    8000326e:	102037b7          	lui	a5,0x10203
    80003272:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003276:	02f71063          	bne	a4,a5,80003296 <fsinit+0x60>
  initlog(dev, &sb);
    8000327a:	00023597          	auipc	a1,0x23
    8000327e:	62658593          	addi	a1,a1,1574 # 800268a0 <sb>
    80003282:	854a                	mv	a0,s2
    80003284:	1f9000ef          	jal	80003c7c <initlog>
}
    80003288:	70a2                	ld	ra,40(sp)
    8000328a:	7402                	ld	s0,32(sp)
    8000328c:	64e2                	ld	s1,24(sp)
    8000328e:	6942                	ld	s2,16(sp)
    80003290:	69a2                	ld	s3,8(sp)
    80003292:	6145                	addi	sp,sp,48
    80003294:	8082                	ret
    panic("invalid file system");
    80003296:	00004517          	auipc	a0,0x4
    8000329a:	2ea50513          	addi	a0,a0,746 # 80007580 <etext+0x580>
    8000329e:	cf6fd0ef          	jal	80000794 <panic>

00000000800032a2 <iinit>:
{
    800032a2:	7179                	addi	sp,sp,-48
    800032a4:	f406                	sd	ra,40(sp)
    800032a6:	f022                	sd	s0,32(sp)
    800032a8:	ec26                	sd	s1,24(sp)
    800032aa:	e84a                	sd	s2,16(sp)
    800032ac:	e44e                	sd	s3,8(sp)
    800032ae:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800032b0:	00004597          	auipc	a1,0x4
    800032b4:	2e858593          	addi	a1,a1,744 # 80007598 <etext+0x598>
    800032b8:	00023517          	auipc	a0,0x23
    800032bc:	60850513          	addi	a0,a0,1544 # 800268c0 <itable>
    800032c0:	8b5fd0ef          	jal	80000b74 <initlock>
  for(i = 0; i < NINODE; i++) {
    800032c4:	00023497          	auipc	s1,0x23
    800032c8:	62448493          	addi	s1,s1,1572 # 800268e8 <itable+0x28>
    800032cc:	00025997          	auipc	s3,0x25
    800032d0:	0ac98993          	addi	s3,s3,172 # 80028378 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    800032d4:	00004917          	auipc	s2,0x4
    800032d8:	2cc90913          	addi	s2,s2,716 # 800075a0 <etext+0x5a0>
    800032dc:	85ca                	mv	a1,s2
    800032de:	8526                	mv	a0,s1
    800032e0:	475000ef          	jal	80003f54 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800032e4:	08848493          	addi	s1,s1,136
    800032e8:	ff349ae3          	bne	s1,s3,800032dc <iinit+0x3a>
}
    800032ec:	70a2                	ld	ra,40(sp)
    800032ee:	7402                	ld	s0,32(sp)
    800032f0:	64e2                	ld	s1,24(sp)
    800032f2:	6942                	ld	s2,16(sp)
    800032f4:	69a2                	ld	s3,8(sp)
    800032f6:	6145                	addi	sp,sp,48
    800032f8:	8082                	ret

00000000800032fa <ialloc>:
{
    800032fa:	7139                	addi	sp,sp,-64
    800032fc:	fc06                	sd	ra,56(sp)
    800032fe:	f822                	sd	s0,48(sp)
    80003300:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    80003302:	00023717          	auipc	a4,0x23
    80003306:	5aa72703          	lw	a4,1450(a4) # 800268ac <sb+0xc>
    8000330a:	4785                	li	a5,1
    8000330c:	06e7f063          	bgeu	a5,a4,8000336c <ialloc+0x72>
    80003310:	f426                	sd	s1,40(sp)
    80003312:	f04a                	sd	s2,32(sp)
    80003314:	ec4e                	sd	s3,24(sp)
    80003316:	e852                	sd	s4,16(sp)
    80003318:	e456                	sd	s5,8(sp)
    8000331a:	e05a                	sd	s6,0(sp)
    8000331c:	8aaa                	mv	s5,a0
    8000331e:	8b2e                	mv	s6,a1
    80003320:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003322:	00023a17          	auipc	s4,0x23
    80003326:	57ea0a13          	addi	s4,s4,1406 # 800268a0 <sb>
    8000332a:	00495593          	srli	a1,s2,0x4
    8000332e:	018a2783          	lw	a5,24(s4)
    80003332:	9dbd                	addw	a1,a1,a5
    80003334:	8556                	mv	a0,s5
    80003336:	9fdff0ef          	jal	80002d32 <bread>
    8000333a:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    8000333c:	05850993          	addi	s3,a0,88
    80003340:	00f97793          	andi	a5,s2,15
    80003344:	079a                	slli	a5,a5,0x6
    80003346:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003348:	00099783          	lh	a5,0(s3)
    8000334c:	cb9d                	beqz	a5,80003382 <ialloc+0x88>
    brelse(bp);
    8000334e:	aedff0ef          	jal	80002e3a <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003352:	0905                	addi	s2,s2,1
    80003354:	00ca2703          	lw	a4,12(s4)
    80003358:	0009079b          	sext.w	a5,s2
    8000335c:	fce7e7e3          	bltu	a5,a4,8000332a <ialloc+0x30>
    80003360:	74a2                	ld	s1,40(sp)
    80003362:	7902                	ld	s2,32(sp)
    80003364:	69e2                	ld	s3,24(sp)
    80003366:	6a42                	ld	s4,16(sp)
    80003368:	6aa2                	ld	s5,8(sp)
    8000336a:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    8000336c:	00004517          	auipc	a0,0x4
    80003370:	23c50513          	addi	a0,a0,572 # 800075a8 <etext+0x5a8>
    80003374:	94efd0ef          	jal	800004c2 <printf>
  return 0;
    80003378:	4501                	li	a0,0
}
    8000337a:	70e2                	ld	ra,56(sp)
    8000337c:	7442                	ld	s0,48(sp)
    8000337e:	6121                	addi	sp,sp,64
    80003380:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003382:	04000613          	li	a2,64
    80003386:	4581                	li	a1,0
    80003388:	854e                	mv	a0,s3
    8000338a:	93ffd0ef          	jal	80000cc8 <memset>
      dip->type = type;
    8000338e:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003392:	8526                	mv	a0,s1
    80003394:	2f1000ef          	jal	80003e84 <log_write>
      brelse(bp);
    80003398:	8526                	mv	a0,s1
    8000339a:	aa1ff0ef          	jal	80002e3a <brelse>
      return iget(dev, inum);
    8000339e:	0009059b          	sext.w	a1,s2
    800033a2:	8556                	mv	a0,s5
    800033a4:	de7ff0ef          	jal	8000318a <iget>
    800033a8:	74a2                	ld	s1,40(sp)
    800033aa:	7902                	ld	s2,32(sp)
    800033ac:	69e2                	ld	s3,24(sp)
    800033ae:	6a42                	ld	s4,16(sp)
    800033b0:	6aa2                	ld	s5,8(sp)
    800033b2:	6b02                	ld	s6,0(sp)
    800033b4:	b7d9                	j	8000337a <ialloc+0x80>

00000000800033b6 <iupdate>:
{
    800033b6:	1101                	addi	sp,sp,-32
    800033b8:	ec06                	sd	ra,24(sp)
    800033ba:	e822                	sd	s0,16(sp)
    800033bc:	e426                	sd	s1,8(sp)
    800033be:	e04a                	sd	s2,0(sp)
    800033c0:	1000                	addi	s0,sp,32
    800033c2:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800033c4:	415c                	lw	a5,4(a0)
    800033c6:	0047d79b          	srliw	a5,a5,0x4
    800033ca:	00023597          	auipc	a1,0x23
    800033ce:	4ee5a583          	lw	a1,1262(a1) # 800268b8 <sb+0x18>
    800033d2:	9dbd                	addw	a1,a1,a5
    800033d4:	4108                	lw	a0,0(a0)
    800033d6:	95dff0ef          	jal	80002d32 <bread>
    800033da:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800033dc:	05850793          	addi	a5,a0,88
    800033e0:	40d8                	lw	a4,4(s1)
    800033e2:	8b3d                	andi	a4,a4,15
    800033e4:	071a                	slli	a4,a4,0x6
    800033e6:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    800033e8:	04449703          	lh	a4,68(s1)
    800033ec:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    800033f0:	04649703          	lh	a4,70(s1)
    800033f4:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    800033f8:	04849703          	lh	a4,72(s1)
    800033fc:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003400:	04a49703          	lh	a4,74(s1)
    80003404:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003408:	44f8                	lw	a4,76(s1)
    8000340a:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    8000340c:	03400613          	li	a2,52
    80003410:	05048593          	addi	a1,s1,80
    80003414:	00c78513          	addi	a0,a5,12
    80003418:	90dfd0ef          	jal	80000d24 <memmove>
  log_write(bp);
    8000341c:	854a                	mv	a0,s2
    8000341e:	267000ef          	jal	80003e84 <log_write>
  brelse(bp);
    80003422:	854a                	mv	a0,s2
    80003424:	a17ff0ef          	jal	80002e3a <brelse>
}
    80003428:	60e2                	ld	ra,24(sp)
    8000342a:	6442                	ld	s0,16(sp)
    8000342c:	64a2                	ld	s1,8(sp)
    8000342e:	6902                	ld	s2,0(sp)
    80003430:	6105                	addi	sp,sp,32
    80003432:	8082                	ret

0000000080003434 <idup>:
{
    80003434:	1101                	addi	sp,sp,-32
    80003436:	ec06                	sd	ra,24(sp)
    80003438:	e822                	sd	s0,16(sp)
    8000343a:	e426                	sd	s1,8(sp)
    8000343c:	1000                	addi	s0,sp,32
    8000343e:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003440:	00023517          	auipc	a0,0x23
    80003444:	48050513          	addi	a0,a0,1152 # 800268c0 <itable>
    80003448:	facfd0ef          	jal	80000bf4 <acquire>
  ip->ref++;
    8000344c:	449c                	lw	a5,8(s1)
    8000344e:	2785                	addiw	a5,a5,1
    80003450:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003452:	00023517          	auipc	a0,0x23
    80003456:	46e50513          	addi	a0,a0,1134 # 800268c0 <itable>
    8000345a:	833fd0ef          	jal	80000c8c <release>
}
    8000345e:	8526                	mv	a0,s1
    80003460:	60e2                	ld	ra,24(sp)
    80003462:	6442                	ld	s0,16(sp)
    80003464:	64a2                	ld	s1,8(sp)
    80003466:	6105                	addi	sp,sp,32
    80003468:	8082                	ret

000000008000346a <ilock>:
{
    8000346a:	1101                	addi	sp,sp,-32
    8000346c:	ec06                	sd	ra,24(sp)
    8000346e:	e822                	sd	s0,16(sp)
    80003470:	e426                	sd	s1,8(sp)
    80003472:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003474:	cd19                	beqz	a0,80003492 <ilock+0x28>
    80003476:	84aa                	mv	s1,a0
    80003478:	451c                	lw	a5,8(a0)
    8000347a:	00f05c63          	blez	a5,80003492 <ilock+0x28>
  acquiresleep(&ip->lock);
    8000347e:	0541                	addi	a0,a0,16
    80003480:	30b000ef          	jal	80003f8a <acquiresleep>
  if(ip->valid == 0){
    80003484:	40bc                	lw	a5,64(s1)
    80003486:	cf89                	beqz	a5,800034a0 <ilock+0x36>
}
    80003488:	60e2                	ld	ra,24(sp)
    8000348a:	6442                	ld	s0,16(sp)
    8000348c:	64a2                	ld	s1,8(sp)
    8000348e:	6105                	addi	sp,sp,32
    80003490:	8082                	ret
    80003492:	e04a                	sd	s2,0(sp)
    panic("ilock");
    80003494:	00004517          	auipc	a0,0x4
    80003498:	12c50513          	addi	a0,a0,300 # 800075c0 <etext+0x5c0>
    8000349c:	af8fd0ef          	jal	80000794 <panic>
    800034a0:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800034a2:	40dc                	lw	a5,4(s1)
    800034a4:	0047d79b          	srliw	a5,a5,0x4
    800034a8:	00023597          	auipc	a1,0x23
    800034ac:	4105a583          	lw	a1,1040(a1) # 800268b8 <sb+0x18>
    800034b0:	9dbd                	addw	a1,a1,a5
    800034b2:	4088                	lw	a0,0(s1)
    800034b4:	87fff0ef          	jal	80002d32 <bread>
    800034b8:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800034ba:	05850593          	addi	a1,a0,88
    800034be:	40dc                	lw	a5,4(s1)
    800034c0:	8bbd                	andi	a5,a5,15
    800034c2:	079a                	slli	a5,a5,0x6
    800034c4:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800034c6:	00059783          	lh	a5,0(a1)
    800034ca:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800034ce:	00259783          	lh	a5,2(a1)
    800034d2:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800034d6:	00459783          	lh	a5,4(a1)
    800034da:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800034de:	00659783          	lh	a5,6(a1)
    800034e2:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800034e6:	459c                	lw	a5,8(a1)
    800034e8:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800034ea:	03400613          	li	a2,52
    800034ee:	05b1                	addi	a1,a1,12
    800034f0:	05048513          	addi	a0,s1,80
    800034f4:	831fd0ef          	jal	80000d24 <memmove>
    brelse(bp);
    800034f8:	854a                	mv	a0,s2
    800034fa:	941ff0ef          	jal	80002e3a <brelse>
    ip->valid = 1;
    800034fe:	4785                	li	a5,1
    80003500:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003502:	04449783          	lh	a5,68(s1)
    80003506:	c399                	beqz	a5,8000350c <ilock+0xa2>
    80003508:	6902                	ld	s2,0(sp)
    8000350a:	bfbd                	j	80003488 <ilock+0x1e>
      panic("ilock: no type");
    8000350c:	00004517          	auipc	a0,0x4
    80003510:	0bc50513          	addi	a0,a0,188 # 800075c8 <etext+0x5c8>
    80003514:	a80fd0ef          	jal	80000794 <panic>

0000000080003518 <iunlock>:
{
    80003518:	1101                	addi	sp,sp,-32
    8000351a:	ec06                	sd	ra,24(sp)
    8000351c:	e822                	sd	s0,16(sp)
    8000351e:	e426                	sd	s1,8(sp)
    80003520:	e04a                	sd	s2,0(sp)
    80003522:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003524:	c505                	beqz	a0,8000354c <iunlock+0x34>
    80003526:	84aa                	mv	s1,a0
    80003528:	01050913          	addi	s2,a0,16
    8000352c:	854a                	mv	a0,s2
    8000352e:	2db000ef          	jal	80004008 <holdingsleep>
    80003532:	cd09                	beqz	a0,8000354c <iunlock+0x34>
    80003534:	449c                	lw	a5,8(s1)
    80003536:	00f05b63          	blez	a5,8000354c <iunlock+0x34>
  releasesleep(&ip->lock);
    8000353a:	854a                	mv	a0,s2
    8000353c:	295000ef          	jal	80003fd0 <releasesleep>
}
    80003540:	60e2                	ld	ra,24(sp)
    80003542:	6442                	ld	s0,16(sp)
    80003544:	64a2                	ld	s1,8(sp)
    80003546:	6902                	ld	s2,0(sp)
    80003548:	6105                	addi	sp,sp,32
    8000354a:	8082                	ret
    panic("iunlock");
    8000354c:	00004517          	auipc	a0,0x4
    80003550:	08c50513          	addi	a0,a0,140 # 800075d8 <etext+0x5d8>
    80003554:	a40fd0ef          	jal	80000794 <panic>

0000000080003558 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003558:	7179                	addi	sp,sp,-48
    8000355a:	f406                	sd	ra,40(sp)
    8000355c:	f022                	sd	s0,32(sp)
    8000355e:	ec26                	sd	s1,24(sp)
    80003560:	e84a                	sd	s2,16(sp)
    80003562:	e44e                	sd	s3,8(sp)
    80003564:	1800                	addi	s0,sp,48
    80003566:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003568:	05050493          	addi	s1,a0,80
    8000356c:	08050913          	addi	s2,a0,128
    80003570:	a021                	j	80003578 <itrunc+0x20>
    80003572:	0491                	addi	s1,s1,4
    80003574:	01248b63          	beq	s1,s2,8000358a <itrunc+0x32>
    if(ip->addrs[i]){
    80003578:	408c                	lw	a1,0(s1)
    8000357a:	dde5                	beqz	a1,80003572 <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    8000357c:	0009a503          	lw	a0,0(s3)
    80003580:	9abff0ef          	jal	80002f2a <bfree>
      ip->addrs[i] = 0;
    80003584:	0004a023          	sw	zero,0(s1)
    80003588:	b7ed                	j	80003572 <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    8000358a:	0809a583          	lw	a1,128(s3)
    8000358e:	ed89                	bnez	a1,800035a8 <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003590:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003594:	854e                	mv	a0,s3
    80003596:	e21ff0ef          	jal	800033b6 <iupdate>
}
    8000359a:	70a2                	ld	ra,40(sp)
    8000359c:	7402                	ld	s0,32(sp)
    8000359e:	64e2                	ld	s1,24(sp)
    800035a0:	6942                	ld	s2,16(sp)
    800035a2:	69a2                	ld	s3,8(sp)
    800035a4:	6145                	addi	sp,sp,48
    800035a6:	8082                	ret
    800035a8:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800035aa:	0009a503          	lw	a0,0(s3)
    800035ae:	f84ff0ef          	jal	80002d32 <bread>
    800035b2:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    800035b4:	05850493          	addi	s1,a0,88
    800035b8:	45850913          	addi	s2,a0,1112
    800035bc:	a021                	j	800035c4 <itrunc+0x6c>
    800035be:	0491                	addi	s1,s1,4
    800035c0:	01248963          	beq	s1,s2,800035d2 <itrunc+0x7a>
      if(a[j])
    800035c4:	408c                	lw	a1,0(s1)
    800035c6:	dde5                	beqz	a1,800035be <itrunc+0x66>
        bfree(ip->dev, a[j]);
    800035c8:	0009a503          	lw	a0,0(s3)
    800035cc:	95fff0ef          	jal	80002f2a <bfree>
    800035d0:	b7fd                	j	800035be <itrunc+0x66>
    brelse(bp);
    800035d2:	8552                	mv	a0,s4
    800035d4:	867ff0ef          	jal	80002e3a <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    800035d8:	0809a583          	lw	a1,128(s3)
    800035dc:	0009a503          	lw	a0,0(s3)
    800035e0:	94bff0ef          	jal	80002f2a <bfree>
    ip->addrs[NDIRECT] = 0;
    800035e4:	0809a023          	sw	zero,128(s3)
    800035e8:	6a02                	ld	s4,0(sp)
    800035ea:	b75d                	j	80003590 <itrunc+0x38>

00000000800035ec <iput>:
{
    800035ec:	1101                	addi	sp,sp,-32
    800035ee:	ec06                	sd	ra,24(sp)
    800035f0:	e822                	sd	s0,16(sp)
    800035f2:	e426                	sd	s1,8(sp)
    800035f4:	1000                	addi	s0,sp,32
    800035f6:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800035f8:	00023517          	auipc	a0,0x23
    800035fc:	2c850513          	addi	a0,a0,712 # 800268c0 <itable>
    80003600:	df4fd0ef          	jal	80000bf4 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003604:	4498                	lw	a4,8(s1)
    80003606:	4785                	li	a5,1
    80003608:	02f70063          	beq	a4,a5,80003628 <iput+0x3c>
  ip->ref--;
    8000360c:	449c                	lw	a5,8(s1)
    8000360e:	37fd                	addiw	a5,a5,-1
    80003610:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003612:	00023517          	auipc	a0,0x23
    80003616:	2ae50513          	addi	a0,a0,686 # 800268c0 <itable>
    8000361a:	e72fd0ef          	jal	80000c8c <release>
}
    8000361e:	60e2                	ld	ra,24(sp)
    80003620:	6442                	ld	s0,16(sp)
    80003622:	64a2                	ld	s1,8(sp)
    80003624:	6105                	addi	sp,sp,32
    80003626:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003628:	40bc                	lw	a5,64(s1)
    8000362a:	d3ed                	beqz	a5,8000360c <iput+0x20>
    8000362c:	04a49783          	lh	a5,74(s1)
    80003630:	fff1                	bnez	a5,8000360c <iput+0x20>
    80003632:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    80003634:	01048913          	addi	s2,s1,16
    80003638:	854a                	mv	a0,s2
    8000363a:	151000ef          	jal	80003f8a <acquiresleep>
    release(&itable.lock);
    8000363e:	00023517          	auipc	a0,0x23
    80003642:	28250513          	addi	a0,a0,642 # 800268c0 <itable>
    80003646:	e46fd0ef          	jal	80000c8c <release>
    itrunc(ip);
    8000364a:	8526                	mv	a0,s1
    8000364c:	f0dff0ef          	jal	80003558 <itrunc>
    ip->type = 0;
    80003650:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003654:	8526                	mv	a0,s1
    80003656:	d61ff0ef          	jal	800033b6 <iupdate>
    ip->valid = 0;
    8000365a:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    8000365e:	854a                	mv	a0,s2
    80003660:	171000ef          	jal	80003fd0 <releasesleep>
    acquire(&itable.lock);
    80003664:	00023517          	auipc	a0,0x23
    80003668:	25c50513          	addi	a0,a0,604 # 800268c0 <itable>
    8000366c:	d88fd0ef          	jal	80000bf4 <acquire>
    80003670:	6902                	ld	s2,0(sp)
    80003672:	bf69                	j	8000360c <iput+0x20>

0000000080003674 <iunlockput>:
{
    80003674:	1101                	addi	sp,sp,-32
    80003676:	ec06                	sd	ra,24(sp)
    80003678:	e822                	sd	s0,16(sp)
    8000367a:	e426                	sd	s1,8(sp)
    8000367c:	1000                	addi	s0,sp,32
    8000367e:	84aa                	mv	s1,a0
  iunlock(ip);
    80003680:	e99ff0ef          	jal	80003518 <iunlock>
  iput(ip);
    80003684:	8526                	mv	a0,s1
    80003686:	f67ff0ef          	jal	800035ec <iput>
}
    8000368a:	60e2                	ld	ra,24(sp)
    8000368c:	6442                	ld	s0,16(sp)
    8000368e:	64a2                	ld	s1,8(sp)
    80003690:	6105                	addi	sp,sp,32
    80003692:	8082                	ret

0000000080003694 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003694:	1141                	addi	sp,sp,-16
    80003696:	e422                	sd	s0,8(sp)
    80003698:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    8000369a:	411c                	lw	a5,0(a0)
    8000369c:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    8000369e:	415c                	lw	a5,4(a0)
    800036a0:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    800036a2:	04451783          	lh	a5,68(a0)
    800036a6:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    800036aa:	04a51783          	lh	a5,74(a0)
    800036ae:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    800036b2:	04c56783          	lwu	a5,76(a0)
    800036b6:	e99c                	sd	a5,16(a1)
}
    800036b8:	6422                	ld	s0,8(sp)
    800036ba:	0141                	addi	sp,sp,16
    800036bc:	8082                	ret

00000000800036be <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800036be:	457c                	lw	a5,76(a0)
    800036c0:	0ed7eb63          	bltu	a5,a3,800037b6 <readi+0xf8>
{
    800036c4:	7159                	addi	sp,sp,-112
    800036c6:	f486                	sd	ra,104(sp)
    800036c8:	f0a2                	sd	s0,96(sp)
    800036ca:	eca6                	sd	s1,88(sp)
    800036cc:	e0d2                	sd	s4,64(sp)
    800036ce:	fc56                	sd	s5,56(sp)
    800036d0:	f85a                	sd	s6,48(sp)
    800036d2:	f45e                	sd	s7,40(sp)
    800036d4:	1880                	addi	s0,sp,112
    800036d6:	8b2a                	mv	s6,a0
    800036d8:	8bae                	mv	s7,a1
    800036da:	8a32                	mv	s4,a2
    800036dc:	84b6                	mv	s1,a3
    800036de:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    800036e0:	9f35                	addw	a4,a4,a3
    return 0;
    800036e2:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    800036e4:	0cd76063          	bltu	a4,a3,800037a4 <readi+0xe6>
    800036e8:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    800036ea:	00e7f463          	bgeu	a5,a4,800036f2 <readi+0x34>
    n = ip->size - off;
    800036ee:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800036f2:	080a8f63          	beqz	s5,80003790 <readi+0xd2>
    800036f6:	e8ca                	sd	s2,80(sp)
    800036f8:	f062                	sd	s8,32(sp)
    800036fa:	ec66                	sd	s9,24(sp)
    800036fc:	e86a                	sd	s10,16(sp)
    800036fe:	e46e                	sd	s11,8(sp)
    80003700:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003702:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003706:	5c7d                	li	s8,-1
    80003708:	a80d                	j	8000373a <readi+0x7c>
    8000370a:	020d1d93          	slli	s11,s10,0x20
    8000370e:	020ddd93          	srli	s11,s11,0x20
    80003712:	05890613          	addi	a2,s2,88
    80003716:	86ee                	mv	a3,s11
    80003718:	963a                	add	a2,a2,a4
    8000371a:	85d2                	mv	a1,s4
    8000371c:	855e                	mv	a0,s7
    8000371e:	aedfe0ef          	jal	8000220a <either_copyout>
    80003722:	05850763          	beq	a0,s8,80003770 <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003726:	854a                	mv	a0,s2
    80003728:	f12ff0ef          	jal	80002e3a <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000372c:	013d09bb          	addw	s3,s10,s3
    80003730:	009d04bb          	addw	s1,s10,s1
    80003734:	9a6e                	add	s4,s4,s11
    80003736:	0559f763          	bgeu	s3,s5,80003784 <readi+0xc6>
    uint addr = bmap(ip, off/BSIZE);
    8000373a:	00a4d59b          	srliw	a1,s1,0xa
    8000373e:	855a                	mv	a0,s6
    80003740:	977ff0ef          	jal	800030b6 <bmap>
    80003744:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003748:	c5b1                	beqz	a1,80003794 <readi+0xd6>
    bp = bread(ip->dev, addr);
    8000374a:	000b2503          	lw	a0,0(s6)
    8000374e:	de4ff0ef          	jal	80002d32 <bread>
    80003752:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003754:	3ff4f713          	andi	a4,s1,1023
    80003758:	40ec87bb          	subw	a5,s9,a4
    8000375c:	413a86bb          	subw	a3,s5,s3
    80003760:	8d3e                	mv	s10,a5
    80003762:	2781                	sext.w	a5,a5
    80003764:	0006861b          	sext.w	a2,a3
    80003768:	faf671e3          	bgeu	a2,a5,8000370a <readi+0x4c>
    8000376c:	8d36                	mv	s10,a3
    8000376e:	bf71                	j	8000370a <readi+0x4c>
      brelse(bp);
    80003770:	854a                	mv	a0,s2
    80003772:	ec8ff0ef          	jal	80002e3a <brelse>
      tot = -1;
    80003776:	59fd                	li	s3,-1
      break;
    80003778:	6946                	ld	s2,80(sp)
    8000377a:	7c02                	ld	s8,32(sp)
    8000377c:	6ce2                	ld	s9,24(sp)
    8000377e:	6d42                	ld	s10,16(sp)
    80003780:	6da2                	ld	s11,8(sp)
    80003782:	a831                	j	8000379e <readi+0xe0>
    80003784:	6946                	ld	s2,80(sp)
    80003786:	7c02                	ld	s8,32(sp)
    80003788:	6ce2                	ld	s9,24(sp)
    8000378a:	6d42                	ld	s10,16(sp)
    8000378c:	6da2                	ld	s11,8(sp)
    8000378e:	a801                	j	8000379e <readi+0xe0>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003790:	89d6                	mv	s3,s5
    80003792:	a031                	j	8000379e <readi+0xe0>
    80003794:	6946                	ld	s2,80(sp)
    80003796:	7c02                	ld	s8,32(sp)
    80003798:	6ce2                	ld	s9,24(sp)
    8000379a:	6d42                	ld	s10,16(sp)
    8000379c:	6da2                	ld	s11,8(sp)
  }
  return tot;
    8000379e:	0009851b          	sext.w	a0,s3
    800037a2:	69a6                	ld	s3,72(sp)
}
    800037a4:	70a6                	ld	ra,104(sp)
    800037a6:	7406                	ld	s0,96(sp)
    800037a8:	64e6                	ld	s1,88(sp)
    800037aa:	6a06                	ld	s4,64(sp)
    800037ac:	7ae2                	ld	s5,56(sp)
    800037ae:	7b42                	ld	s6,48(sp)
    800037b0:	7ba2                	ld	s7,40(sp)
    800037b2:	6165                	addi	sp,sp,112
    800037b4:	8082                	ret
    return 0;
    800037b6:	4501                	li	a0,0
}
    800037b8:	8082                	ret

00000000800037ba <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800037ba:	457c                	lw	a5,76(a0)
    800037bc:	10d7e063          	bltu	a5,a3,800038bc <writei+0x102>
{
    800037c0:	7159                	addi	sp,sp,-112
    800037c2:	f486                	sd	ra,104(sp)
    800037c4:	f0a2                	sd	s0,96(sp)
    800037c6:	e8ca                	sd	s2,80(sp)
    800037c8:	e0d2                	sd	s4,64(sp)
    800037ca:	fc56                	sd	s5,56(sp)
    800037cc:	f85a                	sd	s6,48(sp)
    800037ce:	f45e                	sd	s7,40(sp)
    800037d0:	1880                	addi	s0,sp,112
    800037d2:	8aaa                	mv	s5,a0
    800037d4:	8bae                	mv	s7,a1
    800037d6:	8a32                	mv	s4,a2
    800037d8:	8936                	mv	s2,a3
    800037da:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    800037dc:	00e687bb          	addw	a5,a3,a4
    800037e0:	0ed7e063          	bltu	a5,a3,800038c0 <writei+0x106>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    800037e4:	00043737          	lui	a4,0x43
    800037e8:	0cf76e63          	bltu	a4,a5,800038c4 <writei+0x10a>
    800037ec:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800037ee:	0a0b0f63          	beqz	s6,800038ac <writei+0xf2>
    800037f2:	eca6                	sd	s1,88(sp)
    800037f4:	f062                	sd	s8,32(sp)
    800037f6:	ec66                	sd	s9,24(sp)
    800037f8:	e86a                	sd	s10,16(sp)
    800037fa:	e46e                	sd	s11,8(sp)
    800037fc:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800037fe:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003802:	5c7d                	li	s8,-1
    80003804:	a825                	j	8000383c <writei+0x82>
    80003806:	020d1d93          	slli	s11,s10,0x20
    8000380a:	020ddd93          	srli	s11,s11,0x20
    8000380e:	05848513          	addi	a0,s1,88
    80003812:	86ee                	mv	a3,s11
    80003814:	8652                	mv	a2,s4
    80003816:	85de                	mv	a1,s7
    80003818:	953a                	add	a0,a0,a4
    8000381a:	a3bfe0ef          	jal	80002254 <either_copyin>
    8000381e:	05850a63          	beq	a0,s8,80003872 <writei+0xb8>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003822:	8526                	mv	a0,s1
    80003824:	660000ef          	jal	80003e84 <log_write>
    brelse(bp);
    80003828:	8526                	mv	a0,s1
    8000382a:	e10ff0ef          	jal	80002e3a <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000382e:	013d09bb          	addw	s3,s10,s3
    80003832:	012d093b          	addw	s2,s10,s2
    80003836:	9a6e                	add	s4,s4,s11
    80003838:	0569f063          	bgeu	s3,s6,80003878 <writei+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    8000383c:	00a9559b          	srliw	a1,s2,0xa
    80003840:	8556                	mv	a0,s5
    80003842:	875ff0ef          	jal	800030b6 <bmap>
    80003846:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    8000384a:	c59d                	beqz	a1,80003878 <writei+0xbe>
    bp = bread(ip->dev, addr);
    8000384c:	000aa503          	lw	a0,0(s5)
    80003850:	ce2ff0ef          	jal	80002d32 <bread>
    80003854:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003856:	3ff97713          	andi	a4,s2,1023
    8000385a:	40ec87bb          	subw	a5,s9,a4
    8000385e:	413b06bb          	subw	a3,s6,s3
    80003862:	8d3e                	mv	s10,a5
    80003864:	2781                	sext.w	a5,a5
    80003866:	0006861b          	sext.w	a2,a3
    8000386a:	f8f67ee3          	bgeu	a2,a5,80003806 <writei+0x4c>
    8000386e:	8d36                	mv	s10,a3
    80003870:	bf59                	j	80003806 <writei+0x4c>
      brelse(bp);
    80003872:	8526                	mv	a0,s1
    80003874:	dc6ff0ef          	jal	80002e3a <brelse>
  }

  if(off > ip->size)
    80003878:	04caa783          	lw	a5,76(s5)
    8000387c:	0327fa63          	bgeu	a5,s2,800038b0 <writei+0xf6>
    ip->size = off;
    80003880:	052aa623          	sw	s2,76(s5)
    80003884:	64e6                	ld	s1,88(sp)
    80003886:	7c02                	ld	s8,32(sp)
    80003888:	6ce2                	ld	s9,24(sp)
    8000388a:	6d42                	ld	s10,16(sp)
    8000388c:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    8000388e:	8556                	mv	a0,s5
    80003890:	b27ff0ef          	jal	800033b6 <iupdate>

  return tot;
    80003894:	0009851b          	sext.w	a0,s3
    80003898:	69a6                	ld	s3,72(sp)
}
    8000389a:	70a6                	ld	ra,104(sp)
    8000389c:	7406                	ld	s0,96(sp)
    8000389e:	6946                	ld	s2,80(sp)
    800038a0:	6a06                	ld	s4,64(sp)
    800038a2:	7ae2                	ld	s5,56(sp)
    800038a4:	7b42                	ld	s6,48(sp)
    800038a6:	7ba2                	ld	s7,40(sp)
    800038a8:	6165                	addi	sp,sp,112
    800038aa:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800038ac:	89da                	mv	s3,s6
    800038ae:	b7c5                	j	8000388e <writei+0xd4>
    800038b0:	64e6                	ld	s1,88(sp)
    800038b2:	7c02                	ld	s8,32(sp)
    800038b4:	6ce2                	ld	s9,24(sp)
    800038b6:	6d42                	ld	s10,16(sp)
    800038b8:	6da2                	ld	s11,8(sp)
    800038ba:	bfd1                	j	8000388e <writei+0xd4>
    return -1;
    800038bc:	557d                	li	a0,-1
}
    800038be:	8082                	ret
    return -1;
    800038c0:	557d                	li	a0,-1
    800038c2:	bfe1                	j	8000389a <writei+0xe0>
    return -1;
    800038c4:	557d                	li	a0,-1
    800038c6:	bfd1                	j	8000389a <writei+0xe0>

00000000800038c8 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    800038c8:	1141                	addi	sp,sp,-16
    800038ca:	e406                	sd	ra,8(sp)
    800038cc:	e022                	sd	s0,0(sp)
    800038ce:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    800038d0:	4639                	li	a2,14
    800038d2:	cc2fd0ef          	jal	80000d94 <strncmp>
}
    800038d6:	60a2                	ld	ra,8(sp)
    800038d8:	6402                	ld	s0,0(sp)
    800038da:	0141                	addi	sp,sp,16
    800038dc:	8082                	ret

00000000800038de <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    800038de:	7139                	addi	sp,sp,-64
    800038e0:	fc06                	sd	ra,56(sp)
    800038e2:	f822                	sd	s0,48(sp)
    800038e4:	f426                	sd	s1,40(sp)
    800038e6:	f04a                	sd	s2,32(sp)
    800038e8:	ec4e                	sd	s3,24(sp)
    800038ea:	e852                	sd	s4,16(sp)
    800038ec:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    800038ee:	04451703          	lh	a4,68(a0)
    800038f2:	4785                	li	a5,1
    800038f4:	00f71a63          	bne	a4,a5,80003908 <dirlookup+0x2a>
    800038f8:	892a                	mv	s2,a0
    800038fa:	89ae                	mv	s3,a1
    800038fc:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    800038fe:	457c                	lw	a5,76(a0)
    80003900:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003902:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003904:	e39d                	bnez	a5,8000392a <dirlookup+0x4c>
    80003906:	a095                	j	8000396a <dirlookup+0x8c>
    panic("dirlookup not DIR");
    80003908:	00004517          	auipc	a0,0x4
    8000390c:	cd850513          	addi	a0,a0,-808 # 800075e0 <etext+0x5e0>
    80003910:	e85fc0ef          	jal	80000794 <panic>
      panic("dirlookup read");
    80003914:	00004517          	auipc	a0,0x4
    80003918:	ce450513          	addi	a0,a0,-796 # 800075f8 <etext+0x5f8>
    8000391c:	e79fc0ef          	jal	80000794 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003920:	24c1                	addiw	s1,s1,16
    80003922:	04c92783          	lw	a5,76(s2)
    80003926:	04f4f163          	bgeu	s1,a5,80003968 <dirlookup+0x8a>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000392a:	4741                	li	a4,16
    8000392c:	86a6                	mv	a3,s1
    8000392e:	fc040613          	addi	a2,s0,-64
    80003932:	4581                	li	a1,0
    80003934:	854a                	mv	a0,s2
    80003936:	d89ff0ef          	jal	800036be <readi>
    8000393a:	47c1                	li	a5,16
    8000393c:	fcf51ce3          	bne	a0,a5,80003914 <dirlookup+0x36>
    if(de.inum == 0)
    80003940:	fc045783          	lhu	a5,-64(s0)
    80003944:	dff1                	beqz	a5,80003920 <dirlookup+0x42>
    if(namecmp(name, de.name) == 0){
    80003946:	fc240593          	addi	a1,s0,-62
    8000394a:	854e                	mv	a0,s3
    8000394c:	f7dff0ef          	jal	800038c8 <namecmp>
    80003950:	f961                	bnez	a0,80003920 <dirlookup+0x42>
      if(poff)
    80003952:	000a0463          	beqz	s4,8000395a <dirlookup+0x7c>
        *poff = off;
    80003956:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    8000395a:	fc045583          	lhu	a1,-64(s0)
    8000395e:	00092503          	lw	a0,0(s2)
    80003962:	829ff0ef          	jal	8000318a <iget>
    80003966:	a011                	j	8000396a <dirlookup+0x8c>
  return 0;
    80003968:	4501                	li	a0,0
}
    8000396a:	70e2                	ld	ra,56(sp)
    8000396c:	7442                	ld	s0,48(sp)
    8000396e:	74a2                	ld	s1,40(sp)
    80003970:	7902                	ld	s2,32(sp)
    80003972:	69e2                	ld	s3,24(sp)
    80003974:	6a42                	ld	s4,16(sp)
    80003976:	6121                	addi	sp,sp,64
    80003978:	8082                	ret

000000008000397a <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    8000397a:	711d                	addi	sp,sp,-96
    8000397c:	ec86                	sd	ra,88(sp)
    8000397e:	e8a2                	sd	s0,80(sp)
    80003980:	e4a6                	sd	s1,72(sp)
    80003982:	e0ca                	sd	s2,64(sp)
    80003984:	fc4e                	sd	s3,56(sp)
    80003986:	f852                	sd	s4,48(sp)
    80003988:	f456                	sd	s5,40(sp)
    8000398a:	f05a                	sd	s6,32(sp)
    8000398c:	ec5e                	sd	s7,24(sp)
    8000398e:	e862                	sd	s8,16(sp)
    80003990:	e466                	sd	s9,8(sp)
    80003992:	1080                	addi	s0,sp,96
    80003994:	84aa                	mv	s1,a0
    80003996:	8b2e                	mv	s6,a1
    80003998:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    8000399a:	00054703          	lbu	a4,0(a0)
    8000399e:	02f00793          	li	a5,47
    800039a2:	00f70e63          	beq	a4,a5,800039be <namex+0x44>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    800039a6:	f3bfd0ef          	jal	800018e0 <myproc>
    800039aa:	15053503          	ld	a0,336(a0)
    800039ae:	a87ff0ef          	jal	80003434 <idup>
    800039b2:	8a2a                	mv	s4,a0
  while(*path == '/')
    800039b4:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    800039b8:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    800039ba:	4b85                	li	s7,1
    800039bc:	a871                	j	80003a58 <namex+0xde>
    ip = iget(ROOTDEV, ROOTINO);
    800039be:	4585                	li	a1,1
    800039c0:	4505                	li	a0,1
    800039c2:	fc8ff0ef          	jal	8000318a <iget>
    800039c6:	8a2a                	mv	s4,a0
    800039c8:	b7f5                	j	800039b4 <namex+0x3a>
      iunlockput(ip);
    800039ca:	8552                	mv	a0,s4
    800039cc:	ca9ff0ef          	jal	80003674 <iunlockput>
      return 0;
    800039d0:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    800039d2:	8552                	mv	a0,s4
    800039d4:	60e6                	ld	ra,88(sp)
    800039d6:	6446                	ld	s0,80(sp)
    800039d8:	64a6                	ld	s1,72(sp)
    800039da:	6906                	ld	s2,64(sp)
    800039dc:	79e2                	ld	s3,56(sp)
    800039de:	7a42                	ld	s4,48(sp)
    800039e0:	7aa2                	ld	s5,40(sp)
    800039e2:	7b02                	ld	s6,32(sp)
    800039e4:	6be2                	ld	s7,24(sp)
    800039e6:	6c42                	ld	s8,16(sp)
    800039e8:	6ca2                	ld	s9,8(sp)
    800039ea:	6125                	addi	sp,sp,96
    800039ec:	8082                	ret
      iunlock(ip);
    800039ee:	8552                	mv	a0,s4
    800039f0:	b29ff0ef          	jal	80003518 <iunlock>
      return ip;
    800039f4:	bff9                	j	800039d2 <namex+0x58>
      iunlockput(ip);
    800039f6:	8552                	mv	a0,s4
    800039f8:	c7dff0ef          	jal	80003674 <iunlockput>
      return 0;
    800039fc:	8a4e                	mv	s4,s3
    800039fe:	bfd1                	j	800039d2 <namex+0x58>
  len = path - s;
    80003a00:	40998633          	sub	a2,s3,s1
    80003a04:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003a08:	099c5063          	bge	s8,s9,80003a88 <namex+0x10e>
    memmove(name, s, DIRSIZ);
    80003a0c:	4639                	li	a2,14
    80003a0e:	85a6                	mv	a1,s1
    80003a10:	8556                	mv	a0,s5
    80003a12:	b12fd0ef          	jal	80000d24 <memmove>
    80003a16:	84ce                	mv	s1,s3
  while(*path == '/')
    80003a18:	0004c783          	lbu	a5,0(s1)
    80003a1c:	01279763          	bne	a5,s2,80003a2a <namex+0xb0>
    path++;
    80003a20:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003a22:	0004c783          	lbu	a5,0(s1)
    80003a26:	ff278de3          	beq	a5,s2,80003a20 <namex+0xa6>
    ilock(ip);
    80003a2a:	8552                	mv	a0,s4
    80003a2c:	a3fff0ef          	jal	8000346a <ilock>
    if(ip->type != T_DIR){
    80003a30:	044a1783          	lh	a5,68(s4)
    80003a34:	f9779be3          	bne	a5,s7,800039ca <namex+0x50>
    if(nameiparent && *path == '\0'){
    80003a38:	000b0563          	beqz	s6,80003a42 <namex+0xc8>
    80003a3c:	0004c783          	lbu	a5,0(s1)
    80003a40:	d7dd                	beqz	a5,800039ee <namex+0x74>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003a42:	4601                	li	a2,0
    80003a44:	85d6                	mv	a1,s5
    80003a46:	8552                	mv	a0,s4
    80003a48:	e97ff0ef          	jal	800038de <dirlookup>
    80003a4c:	89aa                	mv	s3,a0
    80003a4e:	d545                	beqz	a0,800039f6 <namex+0x7c>
    iunlockput(ip);
    80003a50:	8552                	mv	a0,s4
    80003a52:	c23ff0ef          	jal	80003674 <iunlockput>
    ip = next;
    80003a56:	8a4e                	mv	s4,s3
  while(*path == '/')
    80003a58:	0004c783          	lbu	a5,0(s1)
    80003a5c:	01279763          	bne	a5,s2,80003a6a <namex+0xf0>
    path++;
    80003a60:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003a62:	0004c783          	lbu	a5,0(s1)
    80003a66:	ff278de3          	beq	a5,s2,80003a60 <namex+0xe6>
  if(*path == 0)
    80003a6a:	cb8d                	beqz	a5,80003a9c <namex+0x122>
  while(*path != '/' && *path != 0)
    80003a6c:	0004c783          	lbu	a5,0(s1)
    80003a70:	89a6                	mv	s3,s1
  len = path - s;
    80003a72:	4c81                	li	s9,0
    80003a74:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    80003a76:	01278963          	beq	a5,s2,80003a88 <namex+0x10e>
    80003a7a:	d3d9                	beqz	a5,80003a00 <namex+0x86>
    path++;
    80003a7c:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80003a7e:	0009c783          	lbu	a5,0(s3)
    80003a82:	ff279ce3          	bne	a5,s2,80003a7a <namex+0x100>
    80003a86:	bfad                	j	80003a00 <namex+0x86>
    memmove(name, s, len);
    80003a88:	2601                	sext.w	a2,a2
    80003a8a:	85a6                	mv	a1,s1
    80003a8c:	8556                	mv	a0,s5
    80003a8e:	a96fd0ef          	jal	80000d24 <memmove>
    name[len] = 0;
    80003a92:	9cd6                	add	s9,s9,s5
    80003a94:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80003a98:	84ce                	mv	s1,s3
    80003a9a:	bfbd                	j	80003a18 <namex+0x9e>
  if(nameiparent){
    80003a9c:	f20b0be3          	beqz	s6,800039d2 <namex+0x58>
    iput(ip);
    80003aa0:	8552                	mv	a0,s4
    80003aa2:	b4bff0ef          	jal	800035ec <iput>
    return 0;
    80003aa6:	4a01                	li	s4,0
    80003aa8:	b72d                	j	800039d2 <namex+0x58>

0000000080003aaa <dirlink>:
{
    80003aaa:	7139                	addi	sp,sp,-64
    80003aac:	fc06                	sd	ra,56(sp)
    80003aae:	f822                	sd	s0,48(sp)
    80003ab0:	f04a                	sd	s2,32(sp)
    80003ab2:	ec4e                	sd	s3,24(sp)
    80003ab4:	e852                	sd	s4,16(sp)
    80003ab6:	0080                	addi	s0,sp,64
    80003ab8:	892a                	mv	s2,a0
    80003aba:	8a2e                	mv	s4,a1
    80003abc:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003abe:	4601                	li	a2,0
    80003ac0:	e1fff0ef          	jal	800038de <dirlookup>
    80003ac4:	e535                	bnez	a0,80003b30 <dirlink+0x86>
    80003ac6:	f426                	sd	s1,40(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003ac8:	04c92483          	lw	s1,76(s2)
    80003acc:	c48d                	beqz	s1,80003af6 <dirlink+0x4c>
    80003ace:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003ad0:	4741                	li	a4,16
    80003ad2:	86a6                	mv	a3,s1
    80003ad4:	fc040613          	addi	a2,s0,-64
    80003ad8:	4581                	li	a1,0
    80003ada:	854a                	mv	a0,s2
    80003adc:	be3ff0ef          	jal	800036be <readi>
    80003ae0:	47c1                	li	a5,16
    80003ae2:	04f51b63          	bne	a0,a5,80003b38 <dirlink+0x8e>
    if(de.inum == 0)
    80003ae6:	fc045783          	lhu	a5,-64(s0)
    80003aea:	c791                	beqz	a5,80003af6 <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003aec:	24c1                	addiw	s1,s1,16
    80003aee:	04c92783          	lw	a5,76(s2)
    80003af2:	fcf4efe3          	bltu	s1,a5,80003ad0 <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    80003af6:	4639                	li	a2,14
    80003af8:	85d2                	mv	a1,s4
    80003afa:	fc240513          	addi	a0,s0,-62
    80003afe:	accfd0ef          	jal	80000dca <strncpy>
  de.inum = inum;
    80003b02:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003b06:	4741                	li	a4,16
    80003b08:	86a6                	mv	a3,s1
    80003b0a:	fc040613          	addi	a2,s0,-64
    80003b0e:	4581                	li	a1,0
    80003b10:	854a                	mv	a0,s2
    80003b12:	ca9ff0ef          	jal	800037ba <writei>
    80003b16:	1541                	addi	a0,a0,-16
    80003b18:	00a03533          	snez	a0,a0
    80003b1c:	40a00533          	neg	a0,a0
    80003b20:	74a2                	ld	s1,40(sp)
}
    80003b22:	70e2                	ld	ra,56(sp)
    80003b24:	7442                	ld	s0,48(sp)
    80003b26:	7902                	ld	s2,32(sp)
    80003b28:	69e2                	ld	s3,24(sp)
    80003b2a:	6a42                	ld	s4,16(sp)
    80003b2c:	6121                	addi	sp,sp,64
    80003b2e:	8082                	ret
    iput(ip);
    80003b30:	abdff0ef          	jal	800035ec <iput>
    return -1;
    80003b34:	557d                	li	a0,-1
    80003b36:	b7f5                	j	80003b22 <dirlink+0x78>
      panic("dirlink read");
    80003b38:	00004517          	auipc	a0,0x4
    80003b3c:	ad050513          	addi	a0,a0,-1328 # 80007608 <etext+0x608>
    80003b40:	c55fc0ef          	jal	80000794 <panic>

0000000080003b44 <namei>:

struct inode*
namei(char *path)
{
    80003b44:	1101                	addi	sp,sp,-32
    80003b46:	ec06                	sd	ra,24(sp)
    80003b48:	e822                	sd	s0,16(sp)
    80003b4a:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003b4c:	fe040613          	addi	a2,s0,-32
    80003b50:	4581                	li	a1,0
    80003b52:	e29ff0ef          	jal	8000397a <namex>
}
    80003b56:	60e2                	ld	ra,24(sp)
    80003b58:	6442                	ld	s0,16(sp)
    80003b5a:	6105                	addi	sp,sp,32
    80003b5c:	8082                	ret

0000000080003b5e <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003b5e:	1141                	addi	sp,sp,-16
    80003b60:	e406                	sd	ra,8(sp)
    80003b62:	e022                	sd	s0,0(sp)
    80003b64:	0800                	addi	s0,sp,16
    80003b66:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003b68:	4585                	li	a1,1
    80003b6a:	e11ff0ef          	jal	8000397a <namex>
}
    80003b6e:	60a2                	ld	ra,8(sp)
    80003b70:	6402                	ld	s0,0(sp)
    80003b72:	0141                	addi	sp,sp,16
    80003b74:	8082                	ret

0000000080003b76 <write_head>:
    80003b76:	1101                	addi	sp,sp,-32
    80003b78:	ec06                	sd	ra,24(sp)
    80003b7a:	e822                	sd	s0,16(sp)
    80003b7c:	e426                	sd	s1,8(sp)
    80003b7e:	e04a                	sd	s2,0(sp)
    80003b80:	1000                	addi	s0,sp,32
    80003b82:	00024917          	auipc	s2,0x24
    80003b86:	7e690913          	addi	s2,s2,2022 # 80028368 <log>
    80003b8a:	01892583          	lw	a1,24(s2)
    80003b8e:	02892503          	lw	a0,40(s2)
    80003b92:	9a0ff0ef          	jal	80002d32 <bread>
    80003b96:	84aa                	mv	s1,a0
    80003b98:	02c92603          	lw	a2,44(s2)
    80003b9c:	cd30                	sw	a2,88(a0)
    80003b9e:	00c05f63          	blez	a2,80003bbc <write_head+0x46>
    80003ba2:	00024717          	auipc	a4,0x24
    80003ba6:	7f670713          	addi	a4,a4,2038 # 80028398 <log+0x30>
    80003baa:	87aa                	mv	a5,a0
    80003bac:	060a                	slli	a2,a2,0x2
    80003bae:	962a                	add	a2,a2,a0
    80003bb0:	4314                	lw	a3,0(a4)
    80003bb2:	cff4                	sw	a3,92(a5)
    80003bb4:	0711                	addi	a4,a4,4
    80003bb6:	0791                	addi	a5,a5,4
    80003bb8:	fec79ce3          	bne	a5,a2,80003bb0 <write_head+0x3a>
    80003bbc:	8526                	mv	a0,s1
    80003bbe:	a4aff0ef          	jal	80002e08 <bwrite>
    80003bc2:	8526                	mv	a0,s1
    80003bc4:	a76ff0ef          	jal	80002e3a <brelse>
    80003bc8:	60e2                	ld	ra,24(sp)
    80003bca:	6442                	ld	s0,16(sp)
    80003bcc:	64a2                	ld	s1,8(sp)
    80003bce:	6902                	ld	s2,0(sp)
    80003bd0:	6105                	addi	sp,sp,32
    80003bd2:	8082                	ret

0000000080003bd4 <install_trans>:
    80003bd4:	00024797          	auipc	a5,0x24
    80003bd8:	7c07a783          	lw	a5,1984(a5) # 80028394 <log+0x2c>
    80003bdc:	08f05f63          	blez	a5,80003c7a <install_trans+0xa6>
    80003be0:	7139                	addi	sp,sp,-64
    80003be2:	fc06                	sd	ra,56(sp)
    80003be4:	f822                	sd	s0,48(sp)
    80003be6:	f426                	sd	s1,40(sp)
    80003be8:	f04a                	sd	s2,32(sp)
    80003bea:	ec4e                	sd	s3,24(sp)
    80003bec:	e852                	sd	s4,16(sp)
    80003bee:	e456                	sd	s5,8(sp)
    80003bf0:	e05a                	sd	s6,0(sp)
    80003bf2:	0080                	addi	s0,sp,64
    80003bf4:	8b2a                	mv	s6,a0
    80003bf6:	00024a97          	auipc	s5,0x24
    80003bfa:	7a2a8a93          	addi	s5,s5,1954 # 80028398 <log+0x30>
    80003bfe:	4a01                	li	s4,0
    80003c00:	00024997          	auipc	s3,0x24
    80003c04:	76898993          	addi	s3,s3,1896 # 80028368 <log>
    80003c08:	a829                	j	80003c22 <install_trans+0x4e>
    80003c0a:	854a                	mv	a0,s2
    80003c0c:	a2eff0ef          	jal	80002e3a <brelse>
    80003c10:	8526                	mv	a0,s1
    80003c12:	a28ff0ef          	jal	80002e3a <brelse>
    80003c16:	2a05                	addiw	s4,s4,1
    80003c18:	0a91                	addi	s5,s5,4
    80003c1a:	02c9a783          	lw	a5,44(s3)
    80003c1e:	04fa5463          	bge	s4,a5,80003c66 <install_trans+0x92>
    80003c22:	0189a583          	lw	a1,24(s3)
    80003c26:	014585bb          	addw	a1,a1,s4
    80003c2a:	2585                	addiw	a1,a1,1
    80003c2c:	0289a503          	lw	a0,40(s3)
    80003c30:	902ff0ef          	jal	80002d32 <bread>
    80003c34:	892a                	mv	s2,a0
    80003c36:	000aa583          	lw	a1,0(s5)
    80003c3a:	0289a503          	lw	a0,40(s3)
    80003c3e:	8f4ff0ef          	jal	80002d32 <bread>
    80003c42:	84aa                	mv	s1,a0
    80003c44:	40000613          	li	a2,1024
    80003c48:	05890593          	addi	a1,s2,88
    80003c4c:	05850513          	addi	a0,a0,88
    80003c50:	8d4fd0ef          	jal	80000d24 <memmove>
    80003c54:	8526                	mv	a0,s1
    80003c56:	9b2ff0ef          	jal	80002e08 <bwrite>
    80003c5a:	fa0b18e3          	bnez	s6,80003c0a <install_trans+0x36>
    80003c5e:	8526                	mv	a0,s1
    80003c60:	a96ff0ef          	jal	80002ef6 <bunpin>
    80003c64:	b75d                	j	80003c0a <install_trans+0x36>
    80003c66:	70e2                	ld	ra,56(sp)
    80003c68:	7442                	ld	s0,48(sp)
    80003c6a:	74a2                	ld	s1,40(sp)
    80003c6c:	7902                	ld	s2,32(sp)
    80003c6e:	69e2                	ld	s3,24(sp)
    80003c70:	6a42                	ld	s4,16(sp)
    80003c72:	6aa2                	ld	s5,8(sp)
    80003c74:	6b02                	ld	s6,0(sp)
    80003c76:	6121                	addi	sp,sp,64
    80003c78:	8082                	ret
    80003c7a:	8082                	ret

0000000080003c7c <initlog>:
    80003c7c:	7179                	addi	sp,sp,-48
    80003c7e:	f406                	sd	ra,40(sp)
    80003c80:	f022                	sd	s0,32(sp)
    80003c82:	ec26                	sd	s1,24(sp)
    80003c84:	e84a                	sd	s2,16(sp)
    80003c86:	e44e                	sd	s3,8(sp)
    80003c88:	1800                	addi	s0,sp,48
    80003c8a:	892a                	mv	s2,a0
    80003c8c:	89ae                	mv	s3,a1
    80003c8e:	00024497          	auipc	s1,0x24
    80003c92:	6da48493          	addi	s1,s1,1754 # 80028368 <log>
    80003c96:	00004597          	auipc	a1,0x4
    80003c9a:	98258593          	addi	a1,a1,-1662 # 80007618 <etext+0x618>
    80003c9e:	8526                	mv	a0,s1
    80003ca0:	ed5fc0ef          	jal	80000b74 <initlock>
    80003ca4:	0149a583          	lw	a1,20(s3)
    80003ca8:	cc8c                	sw	a1,24(s1)
    80003caa:	0109a783          	lw	a5,16(s3)
    80003cae:	ccdc                	sw	a5,28(s1)
    80003cb0:	0324a423          	sw	s2,40(s1)
    80003cb4:	854a                	mv	a0,s2
    80003cb6:	87cff0ef          	jal	80002d32 <bread>
    80003cba:	4d30                	lw	a2,88(a0)
    80003cbc:	d4d0                	sw	a2,44(s1)
    80003cbe:	00c05f63          	blez	a2,80003cdc <initlog+0x60>
    80003cc2:	87aa                	mv	a5,a0
    80003cc4:	00024717          	auipc	a4,0x24
    80003cc8:	6d470713          	addi	a4,a4,1748 # 80028398 <log+0x30>
    80003ccc:	060a                	slli	a2,a2,0x2
    80003cce:	962a                	add	a2,a2,a0
    80003cd0:	4ff4                	lw	a3,92(a5)
    80003cd2:	c314                	sw	a3,0(a4)
    80003cd4:	0791                	addi	a5,a5,4
    80003cd6:	0711                	addi	a4,a4,4
    80003cd8:	fec79ce3          	bne	a5,a2,80003cd0 <initlog+0x54>
    80003cdc:	95eff0ef          	jal	80002e3a <brelse>
    80003ce0:	4505                	li	a0,1
    80003ce2:	ef3ff0ef          	jal	80003bd4 <install_trans>
    80003ce6:	00024797          	auipc	a5,0x24
    80003cea:	6a07a723          	sw	zero,1710(a5) # 80028394 <log+0x2c>
    80003cee:	e89ff0ef          	jal	80003b76 <write_head>
    80003cf2:	70a2                	ld	ra,40(sp)
    80003cf4:	7402                	ld	s0,32(sp)
    80003cf6:	64e2                	ld	s1,24(sp)
    80003cf8:	6942                	ld	s2,16(sp)
    80003cfa:	69a2                	ld	s3,8(sp)
    80003cfc:	6145                	addi	sp,sp,48
    80003cfe:	8082                	ret

0000000080003d00 <begin_op>:
    80003d00:	1101                	addi	sp,sp,-32
    80003d02:	ec06                	sd	ra,24(sp)
    80003d04:	e822                	sd	s0,16(sp)
    80003d06:	e426                	sd	s1,8(sp)
    80003d08:	e04a                	sd	s2,0(sp)
    80003d0a:	1000                	addi	s0,sp,32
    80003d0c:	00024517          	auipc	a0,0x24
    80003d10:	65c50513          	addi	a0,a0,1628 # 80028368 <log>
    80003d14:	ee1fc0ef          	jal	80000bf4 <acquire>
    80003d18:	00024497          	auipc	s1,0x24
    80003d1c:	65048493          	addi	s1,s1,1616 # 80028368 <log>
    80003d20:	4979                	li	s2,30
    80003d22:	a029                	j	80003d2c <begin_op+0x2c>
    80003d24:	85a6                	mv	a1,s1
    80003d26:	8526                	mv	a0,s1
    80003d28:	986fe0ef          	jal	80001eae <sleep>
    80003d2c:	50dc                	lw	a5,36(s1)
    80003d2e:	fbfd                	bnez	a5,80003d24 <begin_op+0x24>
    80003d30:	5098                	lw	a4,32(s1)
    80003d32:	2705                	addiw	a4,a4,1
    80003d34:	0027179b          	slliw	a5,a4,0x2
    80003d38:	9fb9                	addw	a5,a5,a4
    80003d3a:	0017979b          	slliw	a5,a5,0x1
    80003d3e:	54d4                	lw	a3,44(s1)
    80003d40:	9fb5                	addw	a5,a5,a3
    80003d42:	00f95763          	bge	s2,a5,80003d50 <begin_op+0x50>
    80003d46:	85a6                	mv	a1,s1
    80003d48:	8526                	mv	a0,s1
    80003d4a:	964fe0ef          	jal	80001eae <sleep>
    80003d4e:	bff9                	j	80003d2c <begin_op+0x2c>
    80003d50:	00024517          	auipc	a0,0x24
    80003d54:	61850513          	addi	a0,a0,1560 # 80028368 <log>
    80003d58:	d118                	sw	a4,32(a0)
    80003d5a:	f33fc0ef          	jal	80000c8c <release>
    80003d5e:	60e2                	ld	ra,24(sp)
    80003d60:	6442                	ld	s0,16(sp)
    80003d62:	64a2                	ld	s1,8(sp)
    80003d64:	6902                	ld	s2,0(sp)
    80003d66:	6105                	addi	sp,sp,32
    80003d68:	8082                	ret

0000000080003d6a <end_op>:
    80003d6a:	7139                	addi	sp,sp,-64
    80003d6c:	fc06                	sd	ra,56(sp)
    80003d6e:	f822                	sd	s0,48(sp)
    80003d70:	f426                	sd	s1,40(sp)
    80003d72:	f04a                	sd	s2,32(sp)
    80003d74:	0080                	addi	s0,sp,64
    80003d76:	00024497          	auipc	s1,0x24
    80003d7a:	5f248493          	addi	s1,s1,1522 # 80028368 <log>
    80003d7e:	8526                	mv	a0,s1
    80003d80:	e75fc0ef          	jal	80000bf4 <acquire>
    80003d84:	509c                	lw	a5,32(s1)
    80003d86:	37fd                	addiw	a5,a5,-1
    80003d88:	0007891b          	sext.w	s2,a5
    80003d8c:	d09c                	sw	a5,32(s1)
    80003d8e:	50dc                	lw	a5,36(s1)
    80003d90:	ef9d                	bnez	a5,80003dce <end_op+0x64>
    80003d92:	04091763          	bnez	s2,80003de0 <end_op+0x76>
    80003d96:	00024497          	auipc	s1,0x24
    80003d9a:	5d248493          	addi	s1,s1,1490 # 80028368 <log>
    80003d9e:	4785                	li	a5,1
    80003da0:	d0dc                	sw	a5,36(s1)
    80003da2:	8526                	mv	a0,s1
    80003da4:	ee9fc0ef          	jal	80000c8c <release>
    80003da8:	54dc                	lw	a5,44(s1)
    80003daa:	04f04b63          	bgtz	a5,80003e00 <end_op+0x96>
    80003dae:	00024497          	auipc	s1,0x24
    80003db2:	5ba48493          	addi	s1,s1,1466 # 80028368 <log>
    80003db6:	8526                	mv	a0,s1
    80003db8:	e3dfc0ef          	jal	80000bf4 <acquire>
    80003dbc:	0204a223          	sw	zero,36(s1)
    80003dc0:	8526                	mv	a0,s1
    80003dc2:	938fe0ef          	jal	80001efa <wakeup>
    80003dc6:	8526                	mv	a0,s1
    80003dc8:	ec5fc0ef          	jal	80000c8c <release>
    80003dcc:	a025                	j	80003df4 <end_op+0x8a>
    80003dce:	ec4e                	sd	s3,24(sp)
    80003dd0:	e852                	sd	s4,16(sp)
    80003dd2:	e456                	sd	s5,8(sp)
    80003dd4:	00004517          	auipc	a0,0x4
    80003dd8:	84c50513          	addi	a0,a0,-1972 # 80007620 <etext+0x620>
    80003ddc:	9b9fc0ef          	jal	80000794 <panic>
    80003de0:	00024497          	auipc	s1,0x24
    80003de4:	58848493          	addi	s1,s1,1416 # 80028368 <log>
    80003de8:	8526                	mv	a0,s1
    80003dea:	910fe0ef          	jal	80001efa <wakeup>
    80003dee:	8526                	mv	a0,s1
    80003df0:	e9dfc0ef          	jal	80000c8c <release>
    80003df4:	70e2                	ld	ra,56(sp)
    80003df6:	7442                	ld	s0,48(sp)
    80003df8:	74a2                	ld	s1,40(sp)
    80003dfa:	7902                	ld	s2,32(sp)
    80003dfc:	6121                	addi	sp,sp,64
    80003dfe:	8082                	ret
    80003e00:	ec4e                	sd	s3,24(sp)
    80003e02:	e852                	sd	s4,16(sp)
    80003e04:	e456                	sd	s5,8(sp)
    80003e06:	00024a97          	auipc	s5,0x24
    80003e0a:	592a8a93          	addi	s5,s5,1426 # 80028398 <log+0x30>
    80003e0e:	00024a17          	auipc	s4,0x24
    80003e12:	55aa0a13          	addi	s4,s4,1370 # 80028368 <log>
    80003e16:	018a2583          	lw	a1,24(s4)
    80003e1a:	012585bb          	addw	a1,a1,s2
    80003e1e:	2585                	addiw	a1,a1,1
    80003e20:	028a2503          	lw	a0,40(s4)
    80003e24:	f0ffe0ef          	jal	80002d32 <bread>
    80003e28:	84aa                	mv	s1,a0
    80003e2a:	000aa583          	lw	a1,0(s5)
    80003e2e:	028a2503          	lw	a0,40(s4)
    80003e32:	f01fe0ef          	jal	80002d32 <bread>
    80003e36:	89aa                	mv	s3,a0
    80003e38:	40000613          	li	a2,1024
    80003e3c:	05850593          	addi	a1,a0,88
    80003e40:	05848513          	addi	a0,s1,88
    80003e44:	ee1fc0ef          	jal	80000d24 <memmove>
    80003e48:	8526                	mv	a0,s1
    80003e4a:	fbffe0ef          	jal	80002e08 <bwrite>
    80003e4e:	854e                	mv	a0,s3
    80003e50:	febfe0ef          	jal	80002e3a <brelse>
    80003e54:	8526                	mv	a0,s1
    80003e56:	fe5fe0ef          	jal	80002e3a <brelse>
    80003e5a:	2905                	addiw	s2,s2,1
    80003e5c:	0a91                	addi	s5,s5,4
    80003e5e:	02ca2783          	lw	a5,44(s4)
    80003e62:	faf94ae3          	blt	s2,a5,80003e16 <end_op+0xac>
    80003e66:	d11ff0ef          	jal	80003b76 <write_head>
    80003e6a:	4501                	li	a0,0
    80003e6c:	d69ff0ef          	jal	80003bd4 <install_trans>
    80003e70:	00024797          	auipc	a5,0x24
    80003e74:	5207a223          	sw	zero,1316(a5) # 80028394 <log+0x2c>
    80003e78:	cffff0ef          	jal	80003b76 <write_head>
    80003e7c:	69e2                	ld	s3,24(sp)
    80003e7e:	6a42                	ld	s4,16(sp)
    80003e80:	6aa2                	ld	s5,8(sp)
    80003e82:	b735                	j	80003dae <end_op+0x44>

0000000080003e84 <log_write>:
    80003e84:	1101                	addi	sp,sp,-32
    80003e86:	ec06                	sd	ra,24(sp)
    80003e88:	e822                	sd	s0,16(sp)
    80003e8a:	e426                	sd	s1,8(sp)
    80003e8c:	e04a                	sd	s2,0(sp)
    80003e8e:	1000                	addi	s0,sp,32
    80003e90:	84aa                	mv	s1,a0
    80003e92:	00024917          	auipc	s2,0x24
    80003e96:	4d690913          	addi	s2,s2,1238 # 80028368 <log>
    80003e9a:	854a                	mv	a0,s2
    80003e9c:	d59fc0ef          	jal	80000bf4 <acquire>
    80003ea0:	02c92603          	lw	a2,44(s2)
    80003ea4:	47f5                	li	a5,29
    80003ea6:	06c7c363          	blt	a5,a2,80003f0c <log_write+0x88>
    80003eaa:	00024797          	auipc	a5,0x24
    80003eae:	4da7a783          	lw	a5,1242(a5) # 80028384 <log+0x1c>
    80003eb2:	37fd                	addiw	a5,a5,-1
    80003eb4:	04f65c63          	bge	a2,a5,80003f0c <log_write+0x88>
    80003eb8:	00024797          	auipc	a5,0x24
    80003ebc:	4d07a783          	lw	a5,1232(a5) # 80028388 <log+0x20>
    80003ec0:	04f05c63          	blez	a5,80003f18 <log_write+0x94>
    80003ec4:	4781                	li	a5,0
    80003ec6:	04c05f63          	blez	a2,80003f24 <log_write+0xa0>
    80003eca:	44cc                	lw	a1,12(s1)
    80003ecc:	00024717          	auipc	a4,0x24
    80003ed0:	4cc70713          	addi	a4,a4,1228 # 80028398 <log+0x30>
    80003ed4:	4781                	li	a5,0
    80003ed6:	4314                	lw	a3,0(a4)
    80003ed8:	04b68663          	beq	a3,a1,80003f24 <log_write+0xa0>
    80003edc:	2785                	addiw	a5,a5,1
    80003ede:	0711                	addi	a4,a4,4
    80003ee0:	fef61be3          	bne	a2,a5,80003ed6 <log_write+0x52>
    80003ee4:	0621                	addi	a2,a2,8
    80003ee6:	060a                	slli	a2,a2,0x2
    80003ee8:	00024797          	auipc	a5,0x24
    80003eec:	48078793          	addi	a5,a5,1152 # 80028368 <log>
    80003ef0:	97b2                	add	a5,a5,a2
    80003ef2:	44d8                	lw	a4,12(s1)
    80003ef4:	cb98                	sw	a4,16(a5)
    80003ef6:	8526                	mv	a0,s1
    80003ef8:	fcbfe0ef          	jal	80002ec2 <bpin>
    80003efc:	00024717          	auipc	a4,0x24
    80003f00:	46c70713          	addi	a4,a4,1132 # 80028368 <log>
    80003f04:	575c                	lw	a5,44(a4)
    80003f06:	2785                	addiw	a5,a5,1
    80003f08:	d75c                	sw	a5,44(a4)
    80003f0a:	a80d                	j	80003f3c <log_write+0xb8>
    80003f0c:	00003517          	auipc	a0,0x3
    80003f10:	72450513          	addi	a0,a0,1828 # 80007630 <etext+0x630>
    80003f14:	881fc0ef          	jal	80000794 <panic>
    80003f18:	00003517          	auipc	a0,0x3
    80003f1c:	73050513          	addi	a0,a0,1840 # 80007648 <etext+0x648>
    80003f20:	875fc0ef          	jal	80000794 <panic>
    80003f24:	00878693          	addi	a3,a5,8
    80003f28:	068a                	slli	a3,a3,0x2
    80003f2a:	00024717          	auipc	a4,0x24
    80003f2e:	43e70713          	addi	a4,a4,1086 # 80028368 <log>
    80003f32:	9736                	add	a4,a4,a3
    80003f34:	44d4                	lw	a3,12(s1)
    80003f36:	cb14                	sw	a3,16(a4)
    80003f38:	faf60fe3          	beq	a2,a5,80003ef6 <log_write+0x72>
    80003f3c:	00024517          	auipc	a0,0x24
    80003f40:	42c50513          	addi	a0,a0,1068 # 80028368 <log>
    80003f44:	d49fc0ef          	jal	80000c8c <release>
    80003f48:	60e2                	ld	ra,24(sp)
    80003f4a:	6442                	ld	s0,16(sp)
    80003f4c:	64a2                	ld	s1,8(sp)
    80003f4e:	6902                	ld	s2,0(sp)
    80003f50:	6105                	addi	sp,sp,32
    80003f52:	8082                	ret

0000000080003f54 <initsleeplock>:
    80003f54:	1101                	addi	sp,sp,-32
    80003f56:	ec06                	sd	ra,24(sp)
    80003f58:	e822                	sd	s0,16(sp)
    80003f5a:	e426                	sd	s1,8(sp)
    80003f5c:	e04a                	sd	s2,0(sp)
    80003f5e:	1000                	addi	s0,sp,32
    80003f60:	84aa                	mv	s1,a0
    80003f62:	892e                	mv	s2,a1
    80003f64:	00003597          	auipc	a1,0x3
    80003f68:	70458593          	addi	a1,a1,1796 # 80007668 <etext+0x668>
    80003f6c:	0521                	addi	a0,a0,8
    80003f6e:	c07fc0ef          	jal	80000b74 <initlock>
    80003f72:	0324b023          	sd	s2,32(s1)
    80003f76:	0004a023          	sw	zero,0(s1)
    80003f7a:	0204a423          	sw	zero,40(s1)
    80003f7e:	60e2                	ld	ra,24(sp)
    80003f80:	6442                	ld	s0,16(sp)
    80003f82:	64a2                	ld	s1,8(sp)
    80003f84:	6902                	ld	s2,0(sp)
    80003f86:	6105                	addi	sp,sp,32
    80003f88:	8082                	ret

0000000080003f8a <acquiresleep>:
    80003f8a:	1101                	addi	sp,sp,-32
    80003f8c:	ec06                	sd	ra,24(sp)
    80003f8e:	e822                	sd	s0,16(sp)
    80003f90:	e426                	sd	s1,8(sp)
    80003f92:	e04a                	sd	s2,0(sp)
    80003f94:	1000                	addi	s0,sp,32
    80003f96:	84aa                	mv	s1,a0
    80003f98:	00850913          	addi	s2,a0,8
    80003f9c:	854a                	mv	a0,s2
    80003f9e:	c57fc0ef          	jal	80000bf4 <acquire>
    80003fa2:	409c                	lw	a5,0(s1)
    80003fa4:	c799                	beqz	a5,80003fb2 <acquiresleep+0x28>
    80003fa6:	85ca                	mv	a1,s2
    80003fa8:	8526                	mv	a0,s1
    80003faa:	f05fd0ef          	jal	80001eae <sleep>
    80003fae:	409c                	lw	a5,0(s1)
    80003fb0:	fbfd                	bnez	a5,80003fa6 <acquiresleep+0x1c>
    80003fb2:	4785                	li	a5,1
    80003fb4:	c09c                	sw	a5,0(s1)
    80003fb6:	92bfd0ef          	jal	800018e0 <myproc>
    80003fba:	591c                	lw	a5,48(a0)
    80003fbc:	d49c                	sw	a5,40(s1)
    80003fbe:	854a                	mv	a0,s2
    80003fc0:	ccdfc0ef          	jal	80000c8c <release>
    80003fc4:	60e2                	ld	ra,24(sp)
    80003fc6:	6442                	ld	s0,16(sp)
    80003fc8:	64a2                	ld	s1,8(sp)
    80003fca:	6902                	ld	s2,0(sp)
    80003fcc:	6105                	addi	sp,sp,32
    80003fce:	8082                	ret

0000000080003fd0 <releasesleep>:
    80003fd0:	1101                	addi	sp,sp,-32
    80003fd2:	ec06                	sd	ra,24(sp)
    80003fd4:	e822                	sd	s0,16(sp)
    80003fd6:	e426                	sd	s1,8(sp)
    80003fd8:	e04a                	sd	s2,0(sp)
    80003fda:	1000                	addi	s0,sp,32
    80003fdc:	84aa                	mv	s1,a0
    80003fde:	00850913          	addi	s2,a0,8
    80003fe2:	854a                	mv	a0,s2
    80003fe4:	c11fc0ef          	jal	80000bf4 <acquire>
    80003fe8:	0004a023          	sw	zero,0(s1)
    80003fec:	0204a423          	sw	zero,40(s1)
    80003ff0:	8526                	mv	a0,s1
    80003ff2:	f09fd0ef          	jal	80001efa <wakeup>
    80003ff6:	854a                	mv	a0,s2
    80003ff8:	c95fc0ef          	jal	80000c8c <release>
    80003ffc:	60e2                	ld	ra,24(sp)
    80003ffe:	6442                	ld	s0,16(sp)
    80004000:	64a2                	ld	s1,8(sp)
    80004002:	6902                	ld	s2,0(sp)
    80004004:	6105                	addi	sp,sp,32
    80004006:	8082                	ret

0000000080004008 <holdingsleep>:
    80004008:	7179                	addi	sp,sp,-48
    8000400a:	f406                	sd	ra,40(sp)
    8000400c:	f022                	sd	s0,32(sp)
    8000400e:	ec26                	sd	s1,24(sp)
    80004010:	e84a                	sd	s2,16(sp)
    80004012:	1800                	addi	s0,sp,48
    80004014:	84aa                	mv	s1,a0
    80004016:	00850913          	addi	s2,a0,8
    8000401a:	854a                	mv	a0,s2
    8000401c:	bd9fc0ef          	jal	80000bf4 <acquire>
    80004020:	409c                	lw	a5,0(s1)
    80004022:	ef81                	bnez	a5,8000403a <holdingsleep+0x32>
    80004024:	4481                	li	s1,0
    80004026:	854a                	mv	a0,s2
    80004028:	c65fc0ef          	jal	80000c8c <release>
    8000402c:	8526                	mv	a0,s1
    8000402e:	70a2                	ld	ra,40(sp)
    80004030:	7402                	ld	s0,32(sp)
    80004032:	64e2                	ld	s1,24(sp)
    80004034:	6942                	ld	s2,16(sp)
    80004036:	6145                	addi	sp,sp,48
    80004038:	8082                	ret
    8000403a:	e44e                	sd	s3,8(sp)
    8000403c:	0284a983          	lw	s3,40(s1)
    80004040:	8a1fd0ef          	jal	800018e0 <myproc>
    80004044:	5904                	lw	s1,48(a0)
    80004046:	413484b3          	sub	s1,s1,s3
    8000404a:	0014b493          	seqz	s1,s1
    8000404e:	69a2                	ld	s3,8(sp)
    80004050:	bfd9                	j	80004026 <holdingsleep+0x1e>

0000000080004052 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004052:	1141                	addi	sp,sp,-16
    80004054:	e406                	sd	ra,8(sp)
    80004056:	e022                	sd	s0,0(sp)
    80004058:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    8000405a:	00003597          	auipc	a1,0x3
    8000405e:	61e58593          	addi	a1,a1,1566 # 80007678 <etext+0x678>
    80004062:	00024517          	auipc	a0,0x24
    80004066:	44e50513          	addi	a0,a0,1102 # 800284b0 <ftable>
    8000406a:	b0bfc0ef          	jal	80000b74 <initlock>
}
    8000406e:	60a2                	ld	ra,8(sp)
    80004070:	6402                	ld	s0,0(sp)
    80004072:	0141                	addi	sp,sp,16
    80004074:	8082                	ret

0000000080004076 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004076:	1101                	addi	sp,sp,-32
    80004078:	ec06                	sd	ra,24(sp)
    8000407a:	e822                	sd	s0,16(sp)
    8000407c:	e426                	sd	s1,8(sp)
    8000407e:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004080:	00024517          	auipc	a0,0x24
    80004084:	43050513          	addi	a0,a0,1072 # 800284b0 <ftable>
    80004088:	b6dfc0ef          	jal	80000bf4 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000408c:	00024497          	auipc	s1,0x24
    80004090:	43c48493          	addi	s1,s1,1084 # 800284c8 <ftable+0x18>
    80004094:	00025717          	auipc	a4,0x25
    80004098:	3d470713          	addi	a4,a4,980 # 80029468 <disk>
    if(f->ref == 0){
    8000409c:	40dc                	lw	a5,4(s1)
    8000409e:	cf89                	beqz	a5,800040b8 <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800040a0:	02848493          	addi	s1,s1,40
    800040a4:	fee49ce3          	bne	s1,a4,8000409c <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800040a8:	00024517          	auipc	a0,0x24
    800040ac:	40850513          	addi	a0,a0,1032 # 800284b0 <ftable>
    800040b0:	bddfc0ef          	jal	80000c8c <release>
  return 0;
    800040b4:	4481                	li	s1,0
    800040b6:	a809                	j	800040c8 <filealloc+0x52>
      f->ref = 1;
    800040b8:	4785                	li	a5,1
    800040ba:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800040bc:	00024517          	auipc	a0,0x24
    800040c0:	3f450513          	addi	a0,a0,1012 # 800284b0 <ftable>
    800040c4:	bc9fc0ef          	jal	80000c8c <release>
}
    800040c8:	8526                	mv	a0,s1
    800040ca:	60e2                	ld	ra,24(sp)
    800040cc:	6442                	ld	s0,16(sp)
    800040ce:	64a2                	ld	s1,8(sp)
    800040d0:	6105                	addi	sp,sp,32
    800040d2:	8082                	ret

00000000800040d4 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800040d4:	1101                	addi	sp,sp,-32
    800040d6:	ec06                	sd	ra,24(sp)
    800040d8:	e822                	sd	s0,16(sp)
    800040da:	e426                	sd	s1,8(sp)
    800040dc:	1000                	addi	s0,sp,32
    800040de:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800040e0:	00024517          	auipc	a0,0x24
    800040e4:	3d050513          	addi	a0,a0,976 # 800284b0 <ftable>
    800040e8:	b0dfc0ef          	jal	80000bf4 <acquire>
  if(f->ref < 1)
    800040ec:	40dc                	lw	a5,4(s1)
    800040ee:	02f05063          	blez	a5,8000410e <filedup+0x3a>
    panic("filedup");
  f->ref++;
    800040f2:	2785                	addiw	a5,a5,1
    800040f4:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800040f6:	00024517          	auipc	a0,0x24
    800040fa:	3ba50513          	addi	a0,a0,954 # 800284b0 <ftable>
    800040fe:	b8ffc0ef          	jal	80000c8c <release>
  return f;
}
    80004102:	8526                	mv	a0,s1
    80004104:	60e2                	ld	ra,24(sp)
    80004106:	6442                	ld	s0,16(sp)
    80004108:	64a2                	ld	s1,8(sp)
    8000410a:	6105                	addi	sp,sp,32
    8000410c:	8082                	ret
    panic("filedup");
    8000410e:	00003517          	auipc	a0,0x3
    80004112:	57250513          	addi	a0,a0,1394 # 80007680 <etext+0x680>
    80004116:	e7efc0ef          	jal	80000794 <panic>

000000008000411a <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    8000411a:	7139                	addi	sp,sp,-64
    8000411c:	fc06                	sd	ra,56(sp)
    8000411e:	f822                	sd	s0,48(sp)
    80004120:	f426                	sd	s1,40(sp)
    80004122:	0080                	addi	s0,sp,64
    80004124:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004126:	00024517          	auipc	a0,0x24
    8000412a:	38a50513          	addi	a0,a0,906 # 800284b0 <ftable>
    8000412e:	ac7fc0ef          	jal	80000bf4 <acquire>
  if(f->ref < 1)
    80004132:	40dc                	lw	a5,4(s1)
    80004134:	04f05a63          	blez	a5,80004188 <fileclose+0x6e>
    panic("fileclose");
  if(--f->ref > 0){
    80004138:	37fd                	addiw	a5,a5,-1
    8000413a:	0007871b          	sext.w	a4,a5
    8000413e:	c0dc                	sw	a5,4(s1)
    80004140:	04e04e63          	bgtz	a4,8000419c <fileclose+0x82>
    80004144:	f04a                	sd	s2,32(sp)
    80004146:	ec4e                	sd	s3,24(sp)
    80004148:	e852                	sd	s4,16(sp)
    8000414a:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    8000414c:	0004a903          	lw	s2,0(s1)
    80004150:	0094ca83          	lbu	s5,9(s1)
    80004154:	0104ba03          	ld	s4,16(s1)
    80004158:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    8000415c:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004160:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004164:	00024517          	auipc	a0,0x24
    80004168:	34c50513          	addi	a0,a0,844 # 800284b0 <ftable>
    8000416c:	b21fc0ef          	jal	80000c8c <release>

  if(ff.type == FD_PIPE){
    80004170:	4785                	li	a5,1
    80004172:	04f90063          	beq	s2,a5,800041b2 <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004176:	3979                	addiw	s2,s2,-2
    80004178:	4785                	li	a5,1
    8000417a:	0527f563          	bgeu	a5,s2,800041c4 <fileclose+0xaa>
    8000417e:	7902                	ld	s2,32(sp)
    80004180:	69e2                	ld	s3,24(sp)
    80004182:	6a42                	ld	s4,16(sp)
    80004184:	6aa2                	ld	s5,8(sp)
    80004186:	a00d                	j	800041a8 <fileclose+0x8e>
    80004188:	f04a                	sd	s2,32(sp)
    8000418a:	ec4e                	sd	s3,24(sp)
    8000418c:	e852                	sd	s4,16(sp)
    8000418e:	e456                	sd	s5,8(sp)
    panic("fileclose");
    80004190:	00003517          	auipc	a0,0x3
    80004194:	4f850513          	addi	a0,a0,1272 # 80007688 <etext+0x688>
    80004198:	dfcfc0ef          	jal	80000794 <panic>
    release(&ftable.lock);
    8000419c:	00024517          	auipc	a0,0x24
    800041a0:	31450513          	addi	a0,a0,788 # 800284b0 <ftable>
    800041a4:	ae9fc0ef          	jal	80000c8c <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    800041a8:	70e2                	ld	ra,56(sp)
    800041aa:	7442                	ld	s0,48(sp)
    800041ac:	74a2                	ld	s1,40(sp)
    800041ae:	6121                	addi	sp,sp,64
    800041b0:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800041b2:	85d6                	mv	a1,s5
    800041b4:	8552                	mv	a0,s4
    800041b6:	336000ef          	jal	800044ec <pipeclose>
    800041ba:	7902                	ld	s2,32(sp)
    800041bc:	69e2                	ld	s3,24(sp)
    800041be:	6a42                	ld	s4,16(sp)
    800041c0:	6aa2                	ld	s5,8(sp)
    800041c2:	b7dd                	j	800041a8 <fileclose+0x8e>
    begin_op();
    800041c4:	b3dff0ef          	jal	80003d00 <begin_op>
    iput(ff.ip);
    800041c8:	854e                	mv	a0,s3
    800041ca:	c22ff0ef          	jal	800035ec <iput>
    end_op();
    800041ce:	b9dff0ef          	jal	80003d6a <end_op>
    800041d2:	7902                	ld	s2,32(sp)
    800041d4:	69e2                	ld	s3,24(sp)
    800041d6:	6a42                	ld	s4,16(sp)
    800041d8:	6aa2                	ld	s5,8(sp)
    800041da:	b7f9                	j	800041a8 <fileclose+0x8e>

00000000800041dc <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800041dc:	715d                	addi	sp,sp,-80
    800041de:	e486                	sd	ra,72(sp)
    800041e0:	e0a2                	sd	s0,64(sp)
    800041e2:	fc26                	sd	s1,56(sp)
    800041e4:	f44e                	sd	s3,40(sp)
    800041e6:	0880                	addi	s0,sp,80
    800041e8:	84aa                	mv	s1,a0
    800041ea:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    800041ec:	ef4fd0ef          	jal	800018e0 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    800041f0:	409c                	lw	a5,0(s1)
    800041f2:	37f9                	addiw	a5,a5,-2
    800041f4:	4705                	li	a4,1
    800041f6:	04f76063          	bltu	a4,a5,80004236 <filestat+0x5a>
    800041fa:	f84a                	sd	s2,48(sp)
    800041fc:	892a                	mv	s2,a0
    ilock(f->ip);
    800041fe:	6c88                	ld	a0,24(s1)
    80004200:	a6aff0ef          	jal	8000346a <ilock>
    stati(f->ip, &st);
    80004204:	fb840593          	addi	a1,s0,-72
    80004208:	6c88                	ld	a0,24(s1)
    8000420a:	c8aff0ef          	jal	80003694 <stati>
    iunlock(f->ip);
    8000420e:	6c88                	ld	a0,24(s1)
    80004210:	b08ff0ef          	jal	80003518 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004214:	46e1                	li	a3,24
    80004216:	fb840613          	addi	a2,s0,-72
    8000421a:	85ce                	mv	a1,s3
    8000421c:	05093503          	ld	a0,80(s2)
    80004220:	b32fd0ef          	jal	80001552 <copyout>
    80004224:	41f5551b          	sraiw	a0,a0,0x1f
    80004228:	7942                	ld	s2,48(sp)
      return -1;
    return 0;
  }
  return -1;
}
    8000422a:	60a6                	ld	ra,72(sp)
    8000422c:	6406                	ld	s0,64(sp)
    8000422e:	74e2                	ld	s1,56(sp)
    80004230:	79a2                	ld	s3,40(sp)
    80004232:	6161                	addi	sp,sp,80
    80004234:	8082                	ret
  return -1;
    80004236:	557d                	li	a0,-1
    80004238:	bfcd                	j	8000422a <filestat+0x4e>

000000008000423a <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    8000423a:	7179                	addi	sp,sp,-48
    8000423c:	f406                	sd	ra,40(sp)
    8000423e:	f022                	sd	s0,32(sp)
    80004240:	e84a                	sd	s2,16(sp)
    80004242:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004244:	00854783          	lbu	a5,8(a0)
    80004248:	cfd1                	beqz	a5,800042e4 <fileread+0xaa>
    8000424a:	ec26                	sd	s1,24(sp)
    8000424c:	e44e                	sd	s3,8(sp)
    8000424e:	84aa                	mv	s1,a0
    80004250:	89ae                	mv	s3,a1
    80004252:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004254:	411c                	lw	a5,0(a0)
    80004256:	4705                	li	a4,1
    80004258:	04e78363          	beq	a5,a4,8000429e <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000425c:	470d                	li	a4,3
    8000425e:	04e78763          	beq	a5,a4,800042ac <fileread+0x72>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004262:	4709                	li	a4,2
    80004264:	06e79a63          	bne	a5,a4,800042d8 <fileread+0x9e>
    ilock(f->ip);
    80004268:	6d08                	ld	a0,24(a0)
    8000426a:	a00ff0ef          	jal	8000346a <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    8000426e:	874a                	mv	a4,s2
    80004270:	5094                	lw	a3,32(s1)
    80004272:	864e                	mv	a2,s3
    80004274:	4585                	li	a1,1
    80004276:	6c88                	ld	a0,24(s1)
    80004278:	c46ff0ef          	jal	800036be <readi>
    8000427c:	892a                	mv	s2,a0
    8000427e:	00a05563          	blez	a0,80004288 <fileread+0x4e>
      f->off += r;
    80004282:	509c                	lw	a5,32(s1)
    80004284:	9fa9                	addw	a5,a5,a0
    80004286:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004288:	6c88                	ld	a0,24(s1)
    8000428a:	a8eff0ef          	jal	80003518 <iunlock>
    8000428e:	64e2                	ld	s1,24(sp)
    80004290:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    80004292:	854a                	mv	a0,s2
    80004294:	70a2                	ld	ra,40(sp)
    80004296:	7402                	ld	s0,32(sp)
    80004298:	6942                	ld	s2,16(sp)
    8000429a:	6145                	addi	sp,sp,48
    8000429c:	8082                	ret
    r = piperead(f->pipe, addr, n);
    8000429e:	6908                	ld	a0,16(a0)
    800042a0:	388000ef          	jal	80004628 <piperead>
    800042a4:	892a                	mv	s2,a0
    800042a6:	64e2                	ld	s1,24(sp)
    800042a8:	69a2                	ld	s3,8(sp)
    800042aa:	b7e5                	j	80004292 <fileread+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800042ac:	02451783          	lh	a5,36(a0)
    800042b0:	03079693          	slli	a3,a5,0x30
    800042b4:	92c1                	srli	a3,a3,0x30
    800042b6:	4725                	li	a4,9
    800042b8:	02d76863          	bltu	a4,a3,800042e8 <fileread+0xae>
    800042bc:	0792                	slli	a5,a5,0x4
    800042be:	00024717          	auipc	a4,0x24
    800042c2:	15270713          	addi	a4,a4,338 # 80028410 <devsw>
    800042c6:	97ba                	add	a5,a5,a4
    800042c8:	639c                	ld	a5,0(a5)
    800042ca:	c39d                	beqz	a5,800042f0 <fileread+0xb6>
    r = devsw[f->major].read(1, addr, n);
    800042cc:	4505                	li	a0,1
    800042ce:	9782                	jalr	a5
    800042d0:	892a                	mv	s2,a0
    800042d2:	64e2                	ld	s1,24(sp)
    800042d4:	69a2                	ld	s3,8(sp)
    800042d6:	bf75                	j	80004292 <fileread+0x58>
    panic("fileread");
    800042d8:	00003517          	auipc	a0,0x3
    800042dc:	3c050513          	addi	a0,a0,960 # 80007698 <etext+0x698>
    800042e0:	cb4fc0ef          	jal	80000794 <panic>
    return -1;
    800042e4:	597d                	li	s2,-1
    800042e6:	b775                	j	80004292 <fileread+0x58>
      return -1;
    800042e8:	597d                	li	s2,-1
    800042ea:	64e2                	ld	s1,24(sp)
    800042ec:	69a2                	ld	s3,8(sp)
    800042ee:	b755                	j	80004292 <fileread+0x58>
    800042f0:	597d                	li	s2,-1
    800042f2:	64e2                	ld	s1,24(sp)
    800042f4:	69a2                	ld	s3,8(sp)
    800042f6:	bf71                	j	80004292 <fileread+0x58>

00000000800042f8 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    800042f8:	00954783          	lbu	a5,9(a0)
    800042fc:	10078b63          	beqz	a5,80004412 <filewrite+0x11a>
{
    80004300:	715d                	addi	sp,sp,-80
    80004302:	e486                	sd	ra,72(sp)
    80004304:	e0a2                	sd	s0,64(sp)
    80004306:	f84a                	sd	s2,48(sp)
    80004308:	f052                	sd	s4,32(sp)
    8000430a:	e85a                	sd	s6,16(sp)
    8000430c:	0880                	addi	s0,sp,80
    8000430e:	892a                	mv	s2,a0
    80004310:	8b2e                	mv	s6,a1
    80004312:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004314:	411c                	lw	a5,0(a0)
    80004316:	4705                	li	a4,1
    80004318:	02e78763          	beq	a5,a4,80004346 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000431c:	470d                	li	a4,3
    8000431e:	02e78863          	beq	a5,a4,8000434e <filewrite+0x56>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004322:	4709                	li	a4,2
    80004324:	0ce79c63          	bne	a5,a4,800043fc <filewrite+0x104>
    80004328:	f44e                	sd	s3,40(sp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    8000432a:	0ac05863          	blez	a2,800043da <filewrite+0xe2>
    8000432e:	fc26                	sd	s1,56(sp)
    80004330:	ec56                	sd	s5,24(sp)
    80004332:	e45e                	sd	s7,8(sp)
    80004334:	e062                	sd	s8,0(sp)
    int i = 0;
    80004336:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    80004338:	6b85                	lui	s7,0x1
    8000433a:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    8000433e:	6c05                	lui	s8,0x1
    80004340:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80004344:	a8b5                	j	800043c0 <filewrite+0xc8>
    ret = pipewrite(f->pipe, addr, n);
    80004346:	6908                	ld	a0,16(a0)
    80004348:	1fc000ef          	jal	80004544 <pipewrite>
    8000434c:	a04d                	j	800043ee <filewrite+0xf6>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    8000434e:	02451783          	lh	a5,36(a0)
    80004352:	03079693          	slli	a3,a5,0x30
    80004356:	92c1                	srli	a3,a3,0x30
    80004358:	4725                	li	a4,9
    8000435a:	0ad76e63          	bltu	a4,a3,80004416 <filewrite+0x11e>
    8000435e:	0792                	slli	a5,a5,0x4
    80004360:	00024717          	auipc	a4,0x24
    80004364:	0b070713          	addi	a4,a4,176 # 80028410 <devsw>
    80004368:	97ba                	add	a5,a5,a4
    8000436a:	679c                	ld	a5,8(a5)
    8000436c:	c7dd                	beqz	a5,8000441a <filewrite+0x122>
    ret = devsw[f->major].write(1, addr, n);
    8000436e:	4505                	li	a0,1
    80004370:	9782                	jalr	a5
    80004372:	a8b5                	j	800043ee <filewrite+0xf6>
      if(n1 > max)
    80004374:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    80004378:	989ff0ef          	jal	80003d00 <begin_op>
      ilock(f->ip);
    8000437c:	01893503          	ld	a0,24(s2)
    80004380:	8eaff0ef          	jal	8000346a <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004384:	8756                	mv	a4,s5
    80004386:	02092683          	lw	a3,32(s2)
    8000438a:	01698633          	add	a2,s3,s6
    8000438e:	4585                	li	a1,1
    80004390:	01893503          	ld	a0,24(s2)
    80004394:	c26ff0ef          	jal	800037ba <writei>
    80004398:	84aa                	mv	s1,a0
    8000439a:	00a05763          	blez	a0,800043a8 <filewrite+0xb0>
        f->off += r;
    8000439e:	02092783          	lw	a5,32(s2)
    800043a2:	9fa9                	addw	a5,a5,a0
    800043a4:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800043a8:	01893503          	ld	a0,24(s2)
    800043ac:	96cff0ef          	jal	80003518 <iunlock>
      end_op();
    800043b0:	9bbff0ef          	jal	80003d6a <end_op>

      if(r != n1){
    800043b4:	029a9563          	bne	s5,s1,800043de <filewrite+0xe6>
        // error from writei
        break;
      }
      i += r;
    800043b8:	013489bb          	addw	s3,s1,s3
    while(i < n){
    800043bc:	0149da63          	bge	s3,s4,800043d0 <filewrite+0xd8>
      int n1 = n - i;
    800043c0:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    800043c4:	0004879b          	sext.w	a5,s1
    800043c8:	fafbd6e3          	bge	s7,a5,80004374 <filewrite+0x7c>
    800043cc:	84e2                	mv	s1,s8
    800043ce:	b75d                	j	80004374 <filewrite+0x7c>
    800043d0:	74e2                	ld	s1,56(sp)
    800043d2:	6ae2                	ld	s5,24(sp)
    800043d4:	6ba2                	ld	s7,8(sp)
    800043d6:	6c02                	ld	s8,0(sp)
    800043d8:	a039                	j	800043e6 <filewrite+0xee>
    int i = 0;
    800043da:	4981                	li	s3,0
    800043dc:	a029                	j	800043e6 <filewrite+0xee>
    800043de:	74e2                	ld	s1,56(sp)
    800043e0:	6ae2                	ld	s5,24(sp)
    800043e2:	6ba2                	ld	s7,8(sp)
    800043e4:	6c02                	ld	s8,0(sp)
    }
    ret = (i == n ? n : -1);
    800043e6:	033a1c63          	bne	s4,s3,8000441e <filewrite+0x126>
    800043ea:	8552                	mv	a0,s4
    800043ec:	79a2                	ld	s3,40(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    800043ee:	60a6                	ld	ra,72(sp)
    800043f0:	6406                	ld	s0,64(sp)
    800043f2:	7942                	ld	s2,48(sp)
    800043f4:	7a02                	ld	s4,32(sp)
    800043f6:	6b42                	ld	s6,16(sp)
    800043f8:	6161                	addi	sp,sp,80
    800043fa:	8082                	ret
    800043fc:	fc26                	sd	s1,56(sp)
    800043fe:	f44e                	sd	s3,40(sp)
    80004400:	ec56                	sd	s5,24(sp)
    80004402:	e45e                	sd	s7,8(sp)
    80004404:	e062                	sd	s8,0(sp)
    panic("filewrite");
    80004406:	00003517          	auipc	a0,0x3
    8000440a:	2a250513          	addi	a0,a0,674 # 800076a8 <etext+0x6a8>
    8000440e:	b86fc0ef          	jal	80000794 <panic>
    return -1;
    80004412:	557d                	li	a0,-1
}
    80004414:	8082                	ret
      return -1;
    80004416:	557d                	li	a0,-1
    80004418:	bfd9                	j	800043ee <filewrite+0xf6>
    8000441a:	557d                	li	a0,-1
    8000441c:	bfc9                	j	800043ee <filewrite+0xf6>
    ret = (i == n ? n : -1);
    8000441e:	557d                	li	a0,-1
    80004420:	79a2                	ld	s3,40(sp)
    80004422:	b7f1                	j	800043ee <filewrite+0xf6>

0000000080004424 <pipealloc>:
    80004424:	7179                	addi	sp,sp,-48
    80004426:	f406                	sd	ra,40(sp)
    80004428:	f022                	sd	s0,32(sp)
    8000442a:	ec26                	sd	s1,24(sp)
    8000442c:	e052                	sd	s4,0(sp)
    8000442e:	1800                	addi	s0,sp,48
    80004430:	84aa                	mv	s1,a0
    80004432:	8a2e                	mv	s4,a1
    80004434:	0005b023          	sd	zero,0(a1)
    80004438:	00053023          	sd	zero,0(a0)
    8000443c:	c3bff0ef          	jal	80004076 <filealloc>
    80004440:	e088                	sd	a0,0(s1)
    80004442:	c549                	beqz	a0,800044cc <pipealloc+0xa8>
    80004444:	c33ff0ef          	jal	80004076 <filealloc>
    80004448:	00aa3023          	sd	a0,0(s4)
    8000444c:	cd25                	beqz	a0,800044c4 <pipealloc+0xa0>
    8000444e:	e84a                	sd	s2,16(sp)
    80004450:	ed4fc0ef          	jal	80000b24 <kalloc>
    80004454:	892a                	mv	s2,a0
    80004456:	c12d                	beqz	a0,800044b8 <pipealloc+0x94>
    80004458:	e44e                	sd	s3,8(sp)
    8000445a:	4985                	li	s3,1
    8000445c:	23352023          	sw	s3,544(a0)
    80004460:	23352223          	sw	s3,548(a0)
    80004464:	20052e23          	sw	zero,540(a0)
    80004468:	20052c23          	sw	zero,536(a0)
    8000446c:	00003597          	auipc	a1,0x3
    80004470:	24c58593          	addi	a1,a1,588 # 800076b8 <etext+0x6b8>
    80004474:	f00fc0ef          	jal	80000b74 <initlock>
    80004478:	609c                	ld	a5,0(s1)
    8000447a:	0137a023          	sw	s3,0(a5)
    8000447e:	609c                	ld	a5,0(s1)
    80004480:	01378423          	sb	s3,8(a5)
    80004484:	609c                	ld	a5,0(s1)
    80004486:	000784a3          	sb	zero,9(a5)
    8000448a:	609c                	ld	a5,0(s1)
    8000448c:	0127b823          	sd	s2,16(a5)
    80004490:	000a3783          	ld	a5,0(s4)
    80004494:	0137a023          	sw	s3,0(a5)
    80004498:	000a3783          	ld	a5,0(s4)
    8000449c:	00078423          	sb	zero,8(a5)
    800044a0:	000a3783          	ld	a5,0(s4)
    800044a4:	013784a3          	sb	s3,9(a5)
    800044a8:	000a3783          	ld	a5,0(s4)
    800044ac:	0127b823          	sd	s2,16(a5)
    800044b0:	4501                	li	a0,0
    800044b2:	6942                	ld	s2,16(sp)
    800044b4:	69a2                	ld	s3,8(sp)
    800044b6:	a01d                	j	800044dc <pipealloc+0xb8>
    800044b8:	6088                	ld	a0,0(s1)
    800044ba:	c119                	beqz	a0,800044c0 <pipealloc+0x9c>
    800044bc:	6942                	ld	s2,16(sp)
    800044be:	a029                	j	800044c8 <pipealloc+0xa4>
    800044c0:	6942                	ld	s2,16(sp)
    800044c2:	a029                	j	800044cc <pipealloc+0xa8>
    800044c4:	6088                	ld	a0,0(s1)
    800044c6:	c10d                	beqz	a0,800044e8 <pipealloc+0xc4>
    800044c8:	c53ff0ef          	jal	8000411a <fileclose>
    800044cc:	000a3783          	ld	a5,0(s4)
    800044d0:	557d                	li	a0,-1
    800044d2:	c789                	beqz	a5,800044dc <pipealloc+0xb8>
    800044d4:	853e                	mv	a0,a5
    800044d6:	c45ff0ef          	jal	8000411a <fileclose>
    800044da:	557d                	li	a0,-1
    800044dc:	70a2                	ld	ra,40(sp)
    800044de:	7402                	ld	s0,32(sp)
    800044e0:	64e2                	ld	s1,24(sp)
    800044e2:	6a02                	ld	s4,0(sp)
    800044e4:	6145                	addi	sp,sp,48
    800044e6:	8082                	ret
    800044e8:	557d                	li	a0,-1
    800044ea:	bfcd                	j	800044dc <pipealloc+0xb8>

00000000800044ec <pipeclose>:
    800044ec:	1101                	addi	sp,sp,-32
    800044ee:	ec06                	sd	ra,24(sp)
    800044f0:	e822                	sd	s0,16(sp)
    800044f2:	e426                	sd	s1,8(sp)
    800044f4:	e04a                	sd	s2,0(sp)
    800044f6:	1000                	addi	s0,sp,32
    800044f8:	84aa                	mv	s1,a0
    800044fa:	892e                	mv	s2,a1
    800044fc:	ef8fc0ef          	jal	80000bf4 <acquire>
    80004500:	02090763          	beqz	s2,8000452e <pipeclose+0x42>
    80004504:	2204a223          	sw	zero,548(s1)
    80004508:	21848513          	addi	a0,s1,536
    8000450c:	9effd0ef          	jal	80001efa <wakeup>
    80004510:	2204b783          	ld	a5,544(s1)
    80004514:	e785                	bnez	a5,8000453c <pipeclose+0x50>
    80004516:	8526                	mv	a0,s1
    80004518:	f74fc0ef          	jal	80000c8c <release>
    8000451c:	8526                	mv	a0,s1
    8000451e:	d24fc0ef          	jal	80000a42 <kfree>
    80004522:	60e2                	ld	ra,24(sp)
    80004524:	6442                	ld	s0,16(sp)
    80004526:	64a2                	ld	s1,8(sp)
    80004528:	6902                	ld	s2,0(sp)
    8000452a:	6105                	addi	sp,sp,32
    8000452c:	8082                	ret
    8000452e:	2204a023          	sw	zero,544(s1)
    80004532:	21c48513          	addi	a0,s1,540
    80004536:	9c5fd0ef          	jal	80001efa <wakeup>
    8000453a:	bfd9                	j	80004510 <pipeclose+0x24>
    8000453c:	8526                	mv	a0,s1
    8000453e:	f4efc0ef          	jal	80000c8c <release>
    80004542:	b7c5                	j	80004522 <pipeclose+0x36>

0000000080004544 <pipewrite>:
    80004544:	711d                	addi	sp,sp,-96
    80004546:	ec86                	sd	ra,88(sp)
    80004548:	e8a2                	sd	s0,80(sp)
    8000454a:	e4a6                	sd	s1,72(sp)
    8000454c:	e0ca                	sd	s2,64(sp)
    8000454e:	fc4e                	sd	s3,56(sp)
    80004550:	f852                	sd	s4,48(sp)
    80004552:	f456                	sd	s5,40(sp)
    80004554:	1080                	addi	s0,sp,96
    80004556:	84aa                	mv	s1,a0
    80004558:	8aae                	mv	s5,a1
    8000455a:	8a32                	mv	s4,a2
    8000455c:	b84fd0ef          	jal	800018e0 <myproc>
    80004560:	89aa                	mv	s3,a0
    80004562:	8526                	mv	a0,s1
    80004564:	e90fc0ef          	jal	80000bf4 <acquire>
    80004568:	0b405a63          	blez	s4,8000461c <pipewrite+0xd8>
    8000456c:	f05a                	sd	s6,32(sp)
    8000456e:	ec5e                	sd	s7,24(sp)
    80004570:	e862                	sd	s8,16(sp)
    80004572:	4901                	li	s2,0
    80004574:	5b7d                	li	s6,-1
    80004576:	21848c13          	addi	s8,s1,536
    8000457a:	21c48b93          	addi	s7,s1,540
    8000457e:	a81d                	j	800045b4 <pipewrite+0x70>
    80004580:	8526                	mv	a0,s1
    80004582:	f0afc0ef          	jal	80000c8c <release>
    80004586:	597d                	li	s2,-1
    80004588:	7b02                	ld	s6,32(sp)
    8000458a:	6be2                	ld	s7,24(sp)
    8000458c:	6c42                	ld	s8,16(sp)
    8000458e:	854a                	mv	a0,s2
    80004590:	60e6                	ld	ra,88(sp)
    80004592:	6446                	ld	s0,80(sp)
    80004594:	64a6                	ld	s1,72(sp)
    80004596:	6906                	ld	s2,64(sp)
    80004598:	79e2                	ld	s3,56(sp)
    8000459a:	7a42                	ld	s4,48(sp)
    8000459c:	7aa2                	ld	s5,40(sp)
    8000459e:	6125                	addi	sp,sp,96
    800045a0:	8082                	ret
    800045a2:	8562                	mv	a0,s8
    800045a4:	957fd0ef          	jal	80001efa <wakeup>
    800045a8:	85a6                	mv	a1,s1
    800045aa:	855e                	mv	a0,s7
    800045ac:	903fd0ef          	jal	80001eae <sleep>
    800045b0:	05495b63          	bge	s2,s4,80004606 <pipewrite+0xc2>
    800045b4:	2204a783          	lw	a5,544(s1)
    800045b8:	d7e1                	beqz	a5,80004580 <pipewrite+0x3c>
    800045ba:	854e                	mv	a0,s3
    800045bc:	b2bfd0ef          	jal	800020e6 <killed>
    800045c0:	f161                	bnez	a0,80004580 <pipewrite+0x3c>
    800045c2:	2184a783          	lw	a5,536(s1)
    800045c6:	21c4a703          	lw	a4,540(s1)
    800045ca:	2007879b          	addiw	a5,a5,512
    800045ce:	fcf70ae3          	beq	a4,a5,800045a2 <pipewrite+0x5e>
    800045d2:	4685                	li	a3,1
    800045d4:	01590633          	add	a2,s2,s5
    800045d8:	faf40593          	addi	a1,s0,-81
    800045dc:	0509b503          	ld	a0,80(s3)
    800045e0:	848fd0ef          	jal	80001628 <copyin>
    800045e4:	03650e63          	beq	a0,s6,80004620 <pipewrite+0xdc>
    800045e8:	21c4a783          	lw	a5,540(s1)
    800045ec:	0017871b          	addiw	a4,a5,1
    800045f0:	20e4ae23          	sw	a4,540(s1)
    800045f4:	1ff7f793          	andi	a5,a5,511
    800045f8:	97a6                	add	a5,a5,s1
    800045fa:	faf44703          	lbu	a4,-81(s0)
    800045fe:	00e78c23          	sb	a4,24(a5)
    80004602:	2905                	addiw	s2,s2,1
    80004604:	b775                	j	800045b0 <pipewrite+0x6c>
    80004606:	7b02                	ld	s6,32(sp)
    80004608:	6be2                	ld	s7,24(sp)
    8000460a:	6c42                	ld	s8,16(sp)
    8000460c:	21848513          	addi	a0,s1,536
    80004610:	8ebfd0ef          	jal	80001efa <wakeup>
    80004614:	8526                	mv	a0,s1
    80004616:	e76fc0ef          	jal	80000c8c <release>
    8000461a:	bf95                	j	8000458e <pipewrite+0x4a>
    8000461c:	4901                	li	s2,0
    8000461e:	b7fd                	j	8000460c <pipewrite+0xc8>
    80004620:	7b02                	ld	s6,32(sp)
    80004622:	6be2                	ld	s7,24(sp)
    80004624:	6c42                	ld	s8,16(sp)
    80004626:	b7dd                	j	8000460c <pipewrite+0xc8>

0000000080004628 <piperead>:
    80004628:	715d                	addi	sp,sp,-80
    8000462a:	e486                	sd	ra,72(sp)
    8000462c:	e0a2                	sd	s0,64(sp)
    8000462e:	fc26                	sd	s1,56(sp)
    80004630:	f84a                	sd	s2,48(sp)
    80004632:	f44e                	sd	s3,40(sp)
    80004634:	f052                	sd	s4,32(sp)
    80004636:	ec56                	sd	s5,24(sp)
    80004638:	0880                	addi	s0,sp,80
    8000463a:	84aa                	mv	s1,a0
    8000463c:	892e                	mv	s2,a1
    8000463e:	8ab2                	mv	s5,a2
    80004640:	aa0fd0ef          	jal	800018e0 <myproc>
    80004644:	8a2a                	mv	s4,a0
    80004646:	8526                	mv	a0,s1
    80004648:	dacfc0ef          	jal	80000bf4 <acquire>
    8000464c:	2184a703          	lw	a4,536(s1)
    80004650:	21c4a783          	lw	a5,540(s1)
    80004654:	21848993          	addi	s3,s1,536
    80004658:	02f71563          	bne	a4,a5,80004682 <piperead+0x5a>
    8000465c:	2244a783          	lw	a5,548(s1)
    80004660:	cb85                	beqz	a5,80004690 <piperead+0x68>
    80004662:	8552                	mv	a0,s4
    80004664:	a83fd0ef          	jal	800020e6 <killed>
    80004668:	ed19                	bnez	a0,80004686 <piperead+0x5e>
    8000466a:	85a6                	mv	a1,s1
    8000466c:	854e                	mv	a0,s3
    8000466e:	841fd0ef          	jal	80001eae <sleep>
    80004672:	2184a703          	lw	a4,536(s1)
    80004676:	21c4a783          	lw	a5,540(s1)
    8000467a:	fef701e3          	beq	a4,a5,8000465c <piperead+0x34>
    8000467e:	e85a                	sd	s6,16(sp)
    80004680:	a809                	j	80004692 <piperead+0x6a>
    80004682:	e85a                	sd	s6,16(sp)
    80004684:	a039                	j	80004692 <piperead+0x6a>
    80004686:	8526                	mv	a0,s1
    80004688:	e04fc0ef          	jal	80000c8c <release>
    8000468c:	59fd                	li	s3,-1
    8000468e:	a8b1                	j	800046ea <piperead+0xc2>
    80004690:	e85a                	sd	s6,16(sp)
    80004692:	4981                	li	s3,0
    80004694:	5b7d                	li	s6,-1
    80004696:	05505263          	blez	s5,800046da <piperead+0xb2>
    8000469a:	2184a783          	lw	a5,536(s1)
    8000469e:	21c4a703          	lw	a4,540(s1)
    800046a2:	02f70c63          	beq	a4,a5,800046da <piperead+0xb2>
    800046a6:	0017871b          	addiw	a4,a5,1
    800046aa:	20e4ac23          	sw	a4,536(s1)
    800046ae:	1ff7f793          	andi	a5,a5,511
    800046b2:	97a6                	add	a5,a5,s1
    800046b4:	0187c783          	lbu	a5,24(a5)
    800046b8:	faf40fa3          	sb	a5,-65(s0)
    800046bc:	4685                	li	a3,1
    800046be:	fbf40613          	addi	a2,s0,-65
    800046c2:	85ca                	mv	a1,s2
    800046c4:	050a3503          	ld	a0,80(s4)
    800046c8:	e8bfc0ef          	jal	80001552 <copyout>
    800046cc:	01650763          	beq	a0,s6,800046da <piperead+0xb2>
    800046d0:	2985                	addiw	s3,s3,1
    800046d2:	0905                	addi	s2,s2,1
    800046d4:	fd3a93e3          	bne	s5,s3,8000469a <piperead+0x72>
    800046d8:	89d6                	mv	s3,s5
    800046da:	21c48513          	addi	a0,s1,540
    800046de:	81dfd0ef          	jal	80001efa <wakeup>
    800046e2:	8526                	mv	a0,s1
    800046e4:	da8fc0ef          	jal	80000c8c <release>
    800046e8:	6b42                	ld	s6,16(sp)
    800046ea:	854e                	mv	a0,s3
    800046ec:	60a6                	ld	ra,72(sp)
    800046ee:	6406                	ld	s0,64(sp)
    800046f0:	74e2                	ld	s1,56(sp)
    800046f2:	7942                	ld	s2,48(sp)
    800046f4:	79a2                	ld	s3,40(sp)
    800046f6:	7a02                	ld	s4,32(sp)
    800046f8:	6ae2                	ld	s5,24(sp)
    800046fa:	6161                	addi	sp,sp,80
    800046fc:	8082                	ret

00000000800046fe <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    800046fe:	1141                	addi	sp,sp,-16
    80004700:	e422                	sd	s0,8(sp)
    80004702:	0800                	addi	s0,sp,16
    80004704:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004706:	8905                	andi	a0,a0,1
    80004708:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    8000470a:	8b89                	andi	a5,a5,2
    8000470c:	c399                	beqz	a5,80004712 <flags2perm+0x14>
      perm |= PTE_W;
    8000470e:	00456513          	ori	a0,a0,4
    return perm;
}
    80004712:	6422                	ld	s0,8(sp)
    80004714:	0141                	addi	sp,sp,16
    80004716:	8082                	ret

0000000080004718 <exec>:

int
exec(char *path, char **argv)
{
    80004718:	df010113          	addi	sp,sp,-528
    8000471c:	20113423          	sd	ra,520(sp)
    80004720:	20813023          	sd	s0,512(sp)
    80004724:	ffa6                	sd	s1,504(sp)
    80004726:	fbca                	sd	s2,496(sp)
    80004728:	0c00                	addi	s0,sp,528
    8000472a:	892a                	mv	s2,a0
    8000472c:	dea43c23          	sd	a0,-520(s0)
    80004730:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004734:	9acfd0ef          	jal	800018e0 <myproc>
    80004738:	84aa                	mv	s1,a0

  begin_op();
    8000473a:	dc6ff0ef          	jal	80003d00 <begin_op>

  if((ip = namei(path)) == 0){
    8000473e:	854a                	mv	a0,s2
    80004740:	c04ff0ef          	jal	80003b44 <namei>
    80004744:	c931                	beqz	a0,80004798 <exec+0x80>
    80004746:	f3d2                	sd	s4,480(sp)
    80004748:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    8000474a:	d21fe0ef          	jal	8000346a <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    8000474e:	04000713          	li	a4,64
    80004752:	4681                	li	a3,0
    80004754:	e5040613          	addi	a2,s0,-432
    80004758:	4581                	li	a1,0
    8000475a:	8552                	mv	a0,s4
    8000475c:	f63fe0ef          	jal	800036be <readi>
    80004760:	04000793          	li	a5,64
    80004764:	00f51a63          	bne	a0,a5,80004778 <exec+0x60>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80004768:	e5042703          	lw	a4,-432(s0)
    8000476c:	464c47b7          	lui	a5,0x464c4
    80004770:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004774:	02f70663          	beq	a4,a5,800047a0 <exec+0x88>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004778:	8552                	mv	a0,s4
    8000477a:	efbfe0ef          	jal	80003674 <iunlockput>
    end_op();
    8000477e:	decff0ef          	jal	80003d6a <end_op>
  }
  return -1;
    80004782:	557d                	li	a0,-1
    80004784:	7a1e                	ld	s4,480(sp)
}
    80004786:	20813083          	ld	ra,520(sp)
    8000478a:	20013403          	ld	s0,512(sp)
    8000478e:	74fe                	ld	s1,504(sp)
    80004790:	795e                	ld	s2,496(sp)
    80004792:	21010113          	addi	sp,sp,528
    80004796:	8082                	ret
    end_op();
    80004798:	dd2ff0ef          	jal	80003d6a <end_op>
    return -1;
    8000479c:	557d                	li	a0,-1
    8000479e:	b7e5                	j	80004786 <exec+0x6e>
    800047a0:	ebda                	sd	s6,464(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    800047a2:	8526                	mv	a0,s1
    800047a4:	9e4fd0ef          	jal	80001988 <proc_pagetable>
    800047a8:	8b2a                	mv	s6,a0
    800047aa:	2c050b63          	beqz	a0,80004a80 <exec+0x368>
    800047ae:	f7ce                	sd	s3,488(sp)
    800047b0:	efd6                	sd	s5,472(sp)
    800047b2:	e7de                	sd	s7,456(sp)
    800047b4:	e3e2                	sd	s8,448(sp)
    800047b6:	ff66                	sd	s9,440(sp)
    800047b8:	fb6a                	sd	s10,432(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800047ba:	e7042d03          	lw	s10,-400(s0)
    800047be:	e8845783          	lhu	a5,-376(s0)
    800047c2:	12078963          	beqz	a5,800048f4 <exec+0x1dc>
    800047c6:	f76e                	sd	s11,424(sp)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800047c8:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800047ca:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    800047cc:	6c85                	lui	s9,0x1
    800047ce:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    800047d2:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    800047d6:	6a85                	lui	s5,0x1
    800047d8:	a085                	j	80004838 <exec+0x120>
      panic("loadseg: address should exist");
    800047da:	00003517          	auipc	a0,0x3
    800047de:	ee650513          	addi	a0,a0,-282 # 800076c0 <etext+0x6c0>
    800047e2:	fb3fb0ef          	jal	80000794 <panic>
    if(sz - i < PGSIZE)
    800047e6:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    800047e8:	8726                	mv	a4,s1
    800047ea:	012c06bb          	addw	a3,s8,s2
    800047ee:	4581                	li	a1,0
    800047f0:	8552                	mv	a0,s4
    800047f2:	ecdfe0ef          	jal	800036be <readi>
    800047f6:	2501                	sext.w	a0,a0
    800047f8:	24a49a63          	bne	s1,a0,80004a4c <exec+0x334>
  for(i = 0; i < sz; i += PGSIZE){
    800047fc:	012a893b          	addw	s2,s5,s2
    80004800:	03397363          	bgeu	s2,s3,80004826 <exec+0x10e>
    pa = walkaddr(pagetable, va + i);
    80004804:	02091593          	slli	a1,s2,0x20
    80004808:	9181                	srli	a1,a1,0x20
    8000480a:	95de                	add	a1,a1,s7
    8000480c:	855a                	mv	a0,s6
    8000480e:	fc8fc0ef          	jal	80000fd6 <walkaddr>
    80004812:	862a                	mv	a2,a0
    if(pa == 0)
    80004814:	d179                	beqz	a0,800047da <exec+0xc2>
    if(sz - i < PGSIZE)
    80004816:	412984bb          	subw	s1,s3,s2
    8000481a:	0004879b          	sext.w	a5,s1
    8000481e:	fcfcf4e3          	bgeu	s9,a5,800047e6 <exec+0xce>
    80004822:	84d6                	mv	s1,s5
    80004824:	b7c9                	j	800047e6 <exec+0xce>
    sz = sz1;
    80004826:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000482a:	2d85                	addiw	s11,s11,1
    8000482c:	038d0d1b          	addiw	s10,s10,56 # 1038 <_entry-0x7fffefc8>
    80004830:	e8845783          	lhu	a5,-376(s0)
    80004834:	08fdd063          	bge	s11,a5,800048b4 <exec+0x19c>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004838:	2d01                	sext.w	s10,s10
    8000483a:	03800713          	li	a4,56
    8000483e:	86ea                	mv	a3,s10
    80004840:	e1840613          	addi	a2,s0,-488
    80004844:	4581                	li	a1,0
    80004846:	8552                	mv	a0,s4
    80004848:	e77fe0ef          	jal	800036be <readi>
    8000484c:	03800793          	li	a5,56
    80004850:	1cf51663          	bne	a0,a5,80004a1c <exec+0x304>
    if(ph.type != ELF_PROG_LOAD)
    80004854:	e1842783          	lw	a5,-488(s0)
    80004858:	4705                	li	a4,1
    8000485a:	fce798e3          	bne	a5,a4,8000482a <exec+0x112>
    if(ph.memsz < ph.filesz)
    8000485e:	e4043483          	ld	s1,-448(s0)
    80004862:	e3843783          	ld	a5,-456(s0)
    80004866:	1af4ef63          	bltu	s1,a5,80004a24 <exec+0x30c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    8000486a:	e2843783          	ld	a5,-472(s0)
    8000486e:	94be                	add	s1,s1,a5
    80004870:	1af4ee63          	bltu	s1,a5,80004a2c <exec+0x314>
    if(ph.vaddr % PGSIZE != 0)
    80004874:	df043703          	ld	a4,-528(s0)
    80004878:	8ff9                	and	a5,a5,a4
    8000487a:	1a079d63          	bnez	a5,80004a34 <exec+0x31c>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    8000487e:	e1c42503          	lw	a0,-484(s0)
    80004882:	e7dff0ef          	jal	800046fe <flags2perm>
    80004886:	86aa                	mv	a3,a0
    80004888:	8626                	mv	a2,s1
    8000488a:	85ca                	mv	a1,s2
    8000488c:	855a                	mv	a0,s6
    8000488e:	ab1fc0ef          	jal	8000133e <uvmalloc>
    80004892:	e0a43423          	sd	a0,-504(s0)
    80004896:	1a050363          	beqz	a0,80004a3c <exec+0x324>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    8000489a:	e2843b83          	ld	s7,-472(s0)
    8000489e:	e2042c03          	lw	s8,-480(s0)
    800048a2:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    800048a6:	00098463          	beqz	s3,800048ae <exec+0x196>
    800048aa:	4901                	li	s2,0
    800048ac:	bfa1                	j	80004804 <exec+0xec>
    sz = sz1;
    800048ae:	e0843903          	ld	s2,-504(s0)
    800048b2:	bfa5                	j	8000482a <exec+0x112>
    800048b4:	7dba                	ld	s11,424(sp)
  iunlockput(ip);
    800048b6:	8552                	mv	a0,s4
    800048b8:	dbdfe0ef          	jal	80003674 <iunlockput>
  end_op();
    800048bc:	caeff0ef          	jal	80003d6a <end_op>
  p = myproc();
    800048c0:	820fd0ef          	jal	800018e0 <myproc>
    800048c4:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    800048c6:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    800048ca:	6985                	lui	s3,0x1
    800048cc:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    800048ce:	99ca                	add	s3,s3,s2
    800048d0:	77fd                	lui	a5,0xfffff
    800048d2:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    800048d6:	4691                	li	a3,4
    800048d8:	6609                	lui	a2,0x2
    800048da:	964e                	add	a2,a2,s3
    800048dc:	85ce                	mv	a1,s3
    800048de:	855a                	mv	a0,s6
    800048e0:	a5ffc0ef          	jal	8000133e <uvmalloc>
    800048e4:	892a                	mv	s2,a0
    800048e6:	e0a43423          	sd	a0,-504(s0)
    800048ea:	e519                	bnez	a0,800048f8 <exec+0x1e0>
  if(pagetable)
    800048ec:	e1343423          	sd	s3,-504(s0)
    800048f0:	4a01                	li	s4,0
    800048f2:	aab1                	j	80004a4e <exec+0x336>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800048f4:	4901                	li	s2,0
    800048f6:	b7c1                	j	800048b6 <exec+0x19e>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    800048f8:	75f9                	lui	a1,0xffffe
    800048fa:	95aa                	add	a1,a1,a0
    800048fc:	855a                	mv	a0,s6
    800048fe:	c2bfc0ef          	jal	80001528 <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    80004902:	7bfd                	lui	s7,0xfffff
    80004904:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    80004906:	e0043783          	ld	a5,-512(s0)
    8000490a:	6388                	ld	a0,0(a5)
    8000490c:	cd39                	beqz	a0,8000496a <exec+0x252>
    8000490e:	e9040993          	addi	s3,s0,-368
    80004912:	f9040c13          	addi	s8,s0,-112
    80004916:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004918:	d20fc0ef          	jal	80000e38 <strlen>
    8000491c:	0015079b          	addiw	a5,a0,1
    80004920:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004924:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80004928:	11796e63          	bltu	s2,s7,80004a44 <exec+0x32c>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    8000492c:	e0043d03          	ld	s10,-512(s0)
    80004930:	000d3a03          	ld	s4,0(s10)
    80004934:	8552                	mv	a0,s4
    80004936:	d02fc0ef          	jal	80000e38 <strlen>
    8000493a:	0015069b          	addiw	a3,a0,1
    8000493e:	8652                	mv	a2,s4
    80004940:	85ca                	mv	a1,s2
    80004942:	855a                	mv	a0,s6
    80004944:	c0ffc0ef          	jal	80001552 <copyout>
    80004948:	10054063          	bltz	a0,80004a48 <exec+0x330>
    ustack[argc] = sp;
    8000494c:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004950:	0485                	addi	s1,s1,1
    80004952:	008d0793          	addi	a5,s10,8
    80004956:	e0f43023          	sd	a5,-512(s0)
    8000495a:	008d3503          	ld	a0,8(s10)
    8000495e:	c909                	beqz	a0,80004970 <exec+0x258>
    if(argc >= MAXARG)
    80004960:	09a1                	addi	s3,s3,8
    80004962:	fb899be3          	bne	s3,s8,80004918 <exec+0x200>
  ip = 0;
    80004966:	4a01                	li	s4,0
    80004968:	a0dd                	j	80004a4e <exec+0x336>
  sp = sz;
    8000496a:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    8000496e:	4481                	li	s1,0
  ustack[argc] = 0;
    80004970:	00349793          	slli	a5,s1,0x3
    80004974:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffd59e8>
    80004978:	97a2                	add	a5,a5,s0
    8000497a:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    8000497e:	00148693          	addi	a3,s1,1
    80004982:	068e                	slli	a3,a3,0x3
    80004984:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004988:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    8000498c:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    80004990:	f5796ee3          	bltu	s2,s7,800048ec <exec+0x1d4>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004994:	e9040613          	addi	a2,s0,-368
    80004998:	85ca                	mv	a1,s2
    8000499a:	855a                	mv	a0,s6
    8000499c:	bb7fc0ef          	jal	80001552 <copyout>
    800049a0:	0e054263          	bltz	a0,80004a84 <exec+0x36c>
  p->trapframe->a1 = sp;
    800049a4:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    800049a8:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    800049ac:	df843783          	ld	a5,-520(s0)
    800049b0:	0007c703          	lbu	a4,0(a5)
    800049b4:	cf11                	beqz	a4,800049d0 <exec+0x2b8>
    800049b6:	0785                	addi	a5,a5,1
    if(*s == '/')
    800049b8:	02f00693          	li	a3,47
    800049bc:	a039                	j	800049ca <exec+0x2b2>
      last = s+1;
    800049be:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    800049c2:	0785                	addi	a5,a5,1
    800049c4:	fff7c703          	lbu	a4,-1(a5)
    800049c8:	c701                	beqz	a4,800049d0 <exec+0x2b8>
    if(*s == '/')
    800049ca:	fed71ce3          	bne	a4,a3,800049c2 <exec+0x2aa>
    800049ce:	bfc5                	j	800049be <exec+0x2a6>
  safestrcpy(p->name, last, sizeof(p->name));
    800049d0:	4641                	li	a2,16
    800049d2:	df843583          	ld	a1,-520(s0)
    800049d6:	158a8513          	addi	a0,s5,344
    800049da:	c2cfc0ef          	jal	80000e06 <safestrcpy>
  oldpagetable = p->pagetable;
    800049de:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    800049e2:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    800049e6:	e0843783          	ld	a5,-504(s0)
    800049ea:	04fab423          	sd	a5,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    800049ee:	058ab783          	ld	a5,88(s5)
    800049f2:	e6843703          	ld	a4,-408(s0)
    800049f6:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    800049f8:	058ab783          	ld	a5,88(s5)
    800049fc:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004a00:	85e6                	mv	a1,s9
    80004a02:	80afd0ef          	jal	80001a0c <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004a06:	0004851b          	sext.w	a0,s1
    80004a0a:	79be                	ld	s3,488(sp)
    80004a0c:	7a1e                	ld	s4,480(sp)
    80004a0e:	6afe                	ld	s5,472(sp)
    80004a10:	6b5e                	ld	s6,464(sp)
    80004a12:	6bbe                	ld	s7,456(sp)
    80004a14:	6c1e                	ld	s8,448(sp)
    80004a16:	7cfa                	ld	s9,440(sp)
    80004a18:	7d5a                	ld	s10,432(sp)
    80004a1a:	b3b5                	j	80004786 <exec+0x6e>
    80004a1c:	e1243423          	sd	s2,-504(s0)
    80004a20:	7dba                	ld	s11,424(sp)
    80004a22:	a035                	j	80004a4e <exec+0x336>
    80004a24:	e1243423          	sd	s2,-504(s0)
    80004a28:	7dba                	ld	s11,424(sp)
    80004a2a:	a015                	j	80004a4e <exec+0x336>
    80004a2c:	e1243423          	sd	s2,-504(s0)
    80004a30:	7dba                	ld	s11,424(sp)
    80004a32:	a831                	j	80004a4e <exec+0x336>
    80004a34:	e1243423          	sd	s2,-504(s0)
    80004a38:	7dba                	ld	s11,424(sp)
    80004a3a:	a811                	j	80004a4e <exec+0x336>
    80004a3c:	e1243423          	sd	s2,-504(s0)
    80004a40:	7dba                	ld	s11,424(sp)
    80004a42:	a031                	j	80004a4e <exec+0x336>
  ip = 0;
    80004a44:	4a01                	li	s4,0
    80004a46:	a021                	j	80004a4e <exec+0x336>
    80004a48:	4a01                	li	s4,0
  if(pagetable)
    80004a4a:	a011                	j	80004a4e <exec+0x336>
    80004a4c:	7dba                	ld	s11,424(sp)
    proc_freepagetable(pagetable, sz);
    80004a4e:	e0843583          	ld	a1,-504(s0)
    80004a52:	855a                	mv	a0,s6
    80004a54:	fb9fc0ef          	jal	80001a0c <proc_freepagetable>
  return -1;
    80004a58:	557d                	li	a0,-1
  if(ip){
    80004a5a:	000a1b63          	bnez	s4,80004a70 <exec+0x358>
    80004a5e:	79be                	ld	s3,488(sp)
    80004a60:	7a1e                	ld	s4,480(sp)
    80004a62:	6afe                	ld	s5,472(sp)
    80004a64:	6b5e                	ld	s6,464(sp)
    80004a66:	6bbe                	ld	s7,456(sp)
    80004a68:	6c1e                	ld	s8,448(sp)
    80004a6a:	7cfa                	ld	s9,440(sp)
    80004a6c:	7d5a                	ld	s10,432(sp)
    80004a6e:	bb21                	j	80004786 <exec+0x6e>
    80004a70:	79be                	ld	s3,488(sp)
    80004a72:	6afe                	ld	s5,472(sp)
    80004a74:	6b5e                	ld	s6,464(sp)
    80004a76:	6bbe                	ld	s7,456(sp)
    80004a78:	6c1e                	ld	s8,448(sp)
    80004a7a:	7cfa                	ld	s9,440(sp)
    80004a7c:	7d5a                	ld	s10,432(sp)
    80004a7e:	b9ed                	j	80004778 <exec+0x60>
    80004a80:	6b5e                	ld	s6,464(sp)
    80004a82:	b9dd                	j	80004778 <exec+0x60>
  sz = sz1;
    80004a84:	e0843983          	ld	s3,-504(s0)
    80004a88:	b595                	j	800048ec <exec+0x1d4>

0000000080004a8a <argfd>:
    80004a8a:	7179                	addi	sp,sp,-48
    80004a8c:	f406                	sd	ra,40(sp)
    80004a8e:	f022                	sd	s0,32(sp)
    80004a90:	ec26                	sd	s1,24(sp)
    80004a92:	e84a                	sd	s2,16(sp)
    80004a94:	1800                	addi	s0,sp,48
    80004a96:	892e                	mv	s2,a1
    80004a98:	84b2                	mv	s1,a2
    80004a9a:	fdc40593          	addi	a1,s0,-36
    80004a9e:	edbfd0ef          	jal	80002978 <argint>
    80004aa2:	fdc42703          	lw	a4,-36(s0)
    80004aa6:	47bd                	li	a5,15
    80004aa8:	02e7e963          	bltu	a5,a4,80004ada <argfd+0x50>
    80004aac:	e35fc0ef          	jal	800018e0 <myproc>
    80004ab0:	fdc42703          	lw	a4,-36(s0)
    80004ab4:	01a70793          	addi	a5,a4,26
    80004ab8:	078e                	slli	a5,a5,0x3
    80004aba:	953e                	add	a0,a0,a5
    80004abc:	611c                	ld	a5,0(a0)
    80004abe:	c385                	beqz	a5,80004ade <argfd+0x54>
    80004ac0:	00090463          	beqz	s2,80004ac8 <argfd+0x3e>
    80004ac4:	00e92023          	sw	a4,0(s2)
    80004ac8:	4501                	li	a0,0
    80004aca:	c091                	beqz	s1,80004ace <argfd+0x44>
    80004acc:	e09c                	sd	a5,0(s1)
    80004ace:	70a2                	ld	ra,40(sp)
    80004ad0:	7402                	ld	s0,32(sp)
    80004ad2:	64e2                	ld	s1,24(sp)
    80004ad4:	6942                	ld	s2,16(sp)
    80004ad6:	6145                	addi	sp,sp,48
    80004ad8:	8082                	ret
    80004ada:	557d                	li	a0,-1
    80004adc:	bfcd                	j	80004ace <argfd+0x44>
    80004ade:	557d                	li	a0,-1
    80004ae0:	b7fd                	j	80004ace <argfd+0x44>

0000000080004ae2 <fdalloc>:
    80004ae2:	1101                	addi	sp,sp,-32
    80004ae4:	ec06                	sd	ra,24(sp)
    80004ae6:	e822                	sd	s0,16(sp)
    80004ae8:	e426                	sd	s1,8(sp)
    80004aea:	1000                	addi	s0,sp,32
    80004aec:	84aa                	mv	s1,a0
    80004aee:	df3fc0ef          	jal	800018e0 <myproc>
    80004af2:	862a                	mv	a2,a0
    80004af4:	0d050793          	addi	a5,a0,208
    80004af8:	4501                	li	a0,0
    80004afa:	46c1                	li	a3,16
    80004afc:	6398                	ld	a4,0(a5)
    80004afe:	cb19                	beqz	a4,80004b14 <fdalloc+0x32>
    80004b00:	2505                	addiw	a0,a0,1
    80004b02:	07a1                	addi	a5,a5,8
    80004b04:	fed51ce3          	bne	a0,a3,80004afc <fdalloc+0x1a>
    80004b08:	557d                	li	a0,-1
    80004b0a:	60e2                	ld	ra,24(sp)
    80004b0c:	6442                	ld	s0,16(sp)
    80004b0e:	64a2                	ld	s1,8(sp)
    80004b10:	6105                	addi	sp,sp,32
    80004b12:	8082                	ret
    80004b14:	01a50793          	addi	a5,a0,26
    80004b18:	078e                	slli	a5,a5,0x3
    80004b1a:	963e                	add	a2,a2,a5
    80004b1c:	e204                	sd	s1,0(a2)
    80004b1e:	b7f5                	j	80004b0a <fdalloc+0x28>

0000000080004b20 <create>:
    80004b20:	715d                	addi	sp,sp,-80
    80004b22:	e486                	sd	ra,72(sp)
    80004b24:	e0a2                	sd	s0,64(sp)
    80004b26:	fc26                	sd	s1,56(sp)
    80004b28:	f84a                	sd	s2,48(sp)
    80004b2a:	f44e                	sd	s3,40(sp)
    80004b2c:	ec56                	sd	s5,24(sp)
    80004b2e:	e85a                	sd	s6,16(sp)
    80004b30:	0880                	addi	s0,sp,80
    80004b32:	8b2e                	mv	s6,a1
    80004b34:	89b2                	mv	s3,a2
    80004b36:	8936                	mv	s2,a3
    80004b38:	fb040593          	addi	a1,s0,-80
    80004b3c:	822ff0ef          	jal	80003b5e <nameiparent>
    80004b40:	84aa                	mv	s1,a0
    80004b42:	10050a63          	beqz	a0,80004c56 <create+0x136>
    80004b46:	925fe0ef          	jal	8000346a <ilock>
    80004b4a:	4601                	li	a2,0
    80004b4c:	fb040593          	addi	a1,s0,-80
    80004b50:	8526                	mv	a0,s1
    80004b52:	d8dfe0ef          	jal	800038de <dirlookup>
    80004b56:	8aaa                	mv	s5,a0
    80004b58:	c129                	beqz	a0,80004b9a <create+0x7a>
    80004b5a:	8526                	mv	a0,s1
    80004b5c:	b19fe0ef          	jal	80003674 <iunlockput>
    80004b60:	8556                	mv	a0,s5
    80004b62:	909fe0ef          	jal	8000346a <ilock>
    80004b66:	4789                	li	a5,2
    80004b68:	02fb1463          	bne	s6,a5,80004b90 <create+0x70>
    80004b6c:	044ad783          	lhu	a5,68(s5)
    80004b70:	37f9                	addiw	a5,a5,-2
    80004b72:	17c2                	slli	a5,a5,0x30
    80004b74:	93c1                	srli	a5,a5,0x30
    80004b76:	4705                	li	a4,1
    80004b78:	00f76c63          	bltu	a4,a5,80004b90 <create+0x70>
    80004b7c:	8556                	mv	a0,s5
    80004b7e:	60a6                	ld	ra,72(sp)
    80004b80:	6406                	ld	s0,64(sp)
    80004b82:	74e2                	ld	s1,56(sp)
    80004b84:	7942                	ld	s2,48(sp)
    80004b86:	79a2                	ld	s3,40(sp)
    80004b88:	6ae2                	ld	s5,24(sp)
    80004b8a:	6b42                	ld	s6,16(sp)
    80004b8c:	6161                	addi	sp,sp,80
    80004b8e:	8082                	ret
    80004b90:	8556                	mv	a0,s5
    80004b92:	ae3fe0ef          	jal	80003674 <iunlockput>
    80004b96:	4a81                	li	s5,0
    80004b98:	b7d5                	j	80004b7c <create+0x5c>
    80004b9a:	f052                	sd	s4,32(sp)
    80004b9c:	85da                	mv	a1,s6
    80004b9e:	4088                	lw	a0,0(s1)
    80004ba0:	f5afe0ef          	jal	800032fa <ialloc>
    80004ba4:	8a2a                	mv	s4,a0
    80004ba6:	cd15                	beqz	a0,80004be2 <create+0xc2>
    80004ba8:	8c3fe0ef          	jal	8000346a <ilock>
    80004bac:	053a1323          	sh	s3,70(s4)
    80004bb0:	052a1423          	sh	s2,72(s4)
    80004bb4:	4905                	li	s2,1
    80004bb6:	052a1523          	sh	s2,74(s4)
    80004bba:	8552                	mv	a0,s4
    80004bbc:	ffafe0ef          	jal	800033b6 <iupdate>
    80004bc0:	032b0763          	beq	s6,s2,80004bee <create+0xce>
    80004bc4:	004a2603          	lw	a2,4(s4)
    80004bc8:	fb040593          	addi	a1,s0,-80
    80004bcc:	8526                	mv	a0,s1
    80004bce:	eddfe0ef          	jal	80003aaa <dirlink>
    80004bd2:	06054563          	bltz	a0,80004c3c <create+0x11c>
    80004bd6:	8526                	mv	a0,s1
    80004bd8:	a9dfe0ef          	jal	80003674 <iunlockput>
    80004bdc:	8ad2                	mv	s5,s4
    80004bde:	7a02                	ld	s4,32(sp)
    80004be0:	bf71                	j	80004b7c <create+0x5c>
    80004be2:	8526                	mv	a0,s1
    80004be4:	a91fe0ef          	jal	80003674 <iunlockput>
    80004be8:	8ad2                	mv	s5,s4
    80004bea:	7a02                	ld	s4,32(sp)
    80004bec:	bf41                	j	80004b7c <create+0x5c>
    80004bee:	004a2603          	lw	a2,4(s4)
    80004bf2:	00003597          	auipc	a1,0x3
    80004bf6:	aee58593          	addi	a1,a1,-1298 # 800076e0 <etext+0x6e0>
    80004bfa:	8552                	mv	a0,s4
    80004bfc:	eaffe0ef          	jal	80003aaa <dirlink>
    80004c00:	02054e63          	bltz	a0,80004c3c <create+0x11c>
    80004c04:	40d0                	lw	a2,4(s1)
    80004c06:	00003597          	auipc	a1,0x3
    80004c0a:	ae258593          	addi	a1,a1,-1310 # 800076e8 <etext+0x6e8>
    80004c0e:	8552                	mv	a0,s4
    80004c10:	e9bfe0ef          	jal	80003aaa <dirlink>
    80004c14:	02054463          	bltz	a0,80004c3c <create+0x11c>
    80004c18:	004a2603          	lw	a2,4(s4)
    80004c1c:	fb040593          	addi	a1,s0,-80
    80004c20:	8526                	mv	a0,s1
    80004c22:	e89fe0ef          	jal	80003aaa <dirlink>
    80004c26:	00054b63          	bltz	a0,80004c3c <create+0x11c>
    80004c2a:	04a4d783          	lhu	a5,74(s1)
    80004c2e:	2785                	addiw	a5,a5,1
    80004c30:	04f49523          	sh	a5,74(s1)
    80004c34:	8526                	mv	a0,s1
    80004c36:	f80fe0ef          	jal	800033b6 <iupdate>
    80004c3a:	bf71                	j	80004bd6 <create+0xb6>
    80004c3c:	040a1523          	sh	zero,74(s4)
    80004c40:	8552                	mv	a0,s4
    80004c42:	f74fe0ef          	jal	800033b6 <iupdate>
    80004c46:	8552                	mv	a0,s4
    80004c48:	a2dfe0ef          	jal	80003674 <iunlockput>
    80004c4c:	8526                	mv	a0,s1
    80004c4e:	a27fe0ef          	jal	80003674 <iunlockput>
    80004c52:	7a02                	ld	s4,32(sp)
    80004c54:	b725                	j	80004b7c <create+0x5c>
    80004c56:	8aaa                	mv	s5,a0
    80004c58:	b715                	j	80004b7c <create+0x5c>

0000000080004c5a <sys_dup>:
    80004c5a:	7179                	addi	sp,sp,-48
    80004c5c:	f406                	sd	ra,40(sp)
    80004c5e:	f022                	sd	s0,32(sp)
    80004c60:	1800                	addi	s0,sp,48
    80004c62:	fd840613          	addi	a2,s0,-40
    80004c66:	4581                	li	a1,0
    80004c68:	4501                	li	a0,0
    80004c6a:	e21ff0ef          	jal	80004a8a <argfd>
    80004c6e:	57fd                	li	a5,-1
    80004c70:	02054363          	bltz	a0,80004c96 <sys_dup+0x3c>
    80004c74:	ec26                	sd	s1,24(sp)
    80004c76:	e84a                	sd	s2,16(sp)
    80004c78:	fd843903          	ld	s2,-40(s0)
    80004c7c:	854a                	mv	a0,s2
    80004c7e:	e65ff0ef          	jal	80004ae2 <fdalloc>
    80004c82:	84aa                	mv	s1,a0
    80004c84:	57fd                	li	a5,-1
    80004c86:	00054d63          	bltz	a0,80004ca0 <sys_dup+0x46>
    80004c8a:	854a                	mv	a0,s2
    80004c8c:	c48ff0ef          	jal	800040d4 <filedup>
    80004c90:	87a6                	mv	a5,s1
    80004c92:	64e2                	ld	s1,24(sp)
    80004c94:	6942                	ld	s2,16(sp)
    80004c96:	853e                	mv	a0,a5
    80004c98:	70a2                	ld	ra,40(sp)
    80004c9a:	7402                	ld	s0,32(sp)
    80004c9c:	6145                	addi	sp,sp,48
    80004c9e:	8082                	ret
    80004ca0:	64e2                	ld	s1,24(sp)
    80004ca2:	6942                	ld	s2,16(sp)
    80004ca4:	bfcd                	j	80004c96 <sys_dup+0x3c>

0000000080004ca6 <sys_read>:
    80004ca6:	7179                	addi	sp,sp,-48
    80004ca8:	f406                	sd	ra,40(sp)
    80004caa:	f022                	sd	s0,32(sp)
    80004cac:	1800                	addi	s0,sp,48
    80004cae:	fd840593          	addi	a1,s0,-40
    80004cb2:	4505                	li	a0,1
    80004cb4:	ce1fd0ef          	jal	80002994 <argaddr>
    80004cb8:	fe440593          	addi	a1,s0,-28
    80004cbc:	4509                	li	a0,2
    80004cbe:	cbbfd0ef          	jal	80002978 <argint>
    80004cc2:	fe840613          	addi	a2,s0,-24
    80004cc6:	4581                	li	a1,0
    80004cc8:	4501                	li	a0,0
    80004cca:	dc1ff0ef          	jal	80004a8a <argfd>
    80004cce:	87aa                	mv	a5,a0
    80004cd0:	557d                	li	a0,-1
    80004cd2:	0007ca63          	bltz	a5,80004ce6 <sys_read+0x40>
    80004cd6:	fe442603          	lw	a2,-28(s0)
    80004cda:	fd843583          	ld	a1,-40(s0)
    80004cde:	fe843503          	ld	a0,-24(s0)
    80004ce2:	d58ff0ef          	jal	8000423a <fileread>
    80004ce6:	70a2                	ld	ra,40(sp)
    80004ce8:	7402                	ld	s0,32(sp)
    80004cea:	6145                	addi	sp,sp,48
    80004cec:	8082                	ret

0000000080004cee <sys_write>:
    80004cee:	7179                	addi	sp,sp,-48
    80004cf0:	f406                	sd	ra,40(sp)
    80004cf2:	f022                	sd	s0,32(sp)
    80004cf4:	1800                	addi	s0,sp,48
    80004cf6:	fd840593          	addi	a1,s0,-40
    80004cfa:	4505                	li	a0,1
    80004cfc:	c99fd0ef          	jal	80002994 <argaddr>
    80004d00:	fe440593          	addi	a1,s0,-28
    80004d04:	4509                	li	a0,2
    80004d06:	c73fd0ef          	jal	80002978 <argint>
    80004d0a:	fe840613          	addi	a2,s0,-24
    80004d0e:	4581                	li	a1,0
    80004d10:	4501                	li	a0,0
    80004d12:	d79ff0ef          	jal	80004a8a <argfd>
    80004d16:	87aa                	mv	a5,a0
    80004d18:	557d                	li	a0,-1
    80004d1a:	0007ca63          	bltz	a5,80004d2e <sys_write+0x40>
    80004d1e:	fe442603          	lw	a2,-28(s0)
    80004d22:	fd843583          	ld	a1,-40(s0)
    80004d26:	fe843503          	ld	a0,-24(s0)
    80004d2a:	dceff0ef          	jal	800042f8 <filewrite>
    80004d2e:	70a2                	ld	ra,40(sp)
    80004d30:	7402                	ld	s0,32(sp)
    80004d32:	6145                	addi	sp,sp,48
    80004d34:	8082                	ret

0000000080004d36 <sys_close>:
    80004d36:	1101                	addi	sp,sp,-32
    80004d38:	ec06                	sd	ra,24(sp)
    80004d3a:	e822                	sd	s0,16(sp)
    80004d3c:	1000                	addi	s0,sp,32
    80004d3e:	fe040613          	addi	a2,s0,-32
    80004d42:	fec40593          	addi	a1,s0,-20
    80004d46:	4501                	li	a0,0
    80004d48:	d43ff0ef          	jal	80004a8a <argfd>
    80004d4c:	57fd                	li	a5,-1
    80004d4e:	02054063          	bltz	a0,80004d6e <sys_close+0x38>
    80004d52:	b8ffc0ef          	jal	800018e0 <myproc>
    80004d56:	fec42783          	lw	a5,-20(s0)
    80004d5a:	07e9                	addi	a5,a5,26
    80004d5c:	078e                	slli	a5,a5,0x3
    80004d5e:	953e                	add	a0,a0,a5
    80004d60:	00053023          	sd	zero,0(a0)
    80004d64:	fe043503          	ld	a0,-32(s0)
    80004d68:	bb2ff0ef          	jal	8000411a <fileclose>
    80004d6c:	4781                	li	a5,0
    80004d6e:	853e                	mv	a0,a5
    80004d70:	60e2                	ld	ra,24(sp)
    80004d72:	6442                	ld	s0,16(sp)
    80004d74:	6105                	addi	sp,sp,32
    80004d76:	8082                	ret

0000000080004d78 <sys_fstat>:
    80004d78:	1101                	addi	sp,sp,-32
    80004d7a:	ec06                	sd	ra,24(sp)
    80004d7c:	e822                	sd	s0,16(sp)
    80004d7e:	1000                	addi	s0,sp,32
    80004d80:	fe040593          	addi	a1,s0,-32
    80004d84:	4505                	li	a0,1
    80004d86:	c0ffd0ef          	jal	80002994 <argaddr>
    80004d8a:	fe840613          	addi	a2,s0,-24
    80004d8e:	4581                	li	a1,0
    80004d90:	4501                	li	a0,0
    80004d92:	cf9ff0ef          	jal	80004a8a <argfd>
    80004d96:	87aa                	mv	a5,a0
    80004d98:	557d                	li	a0,-1
    80004d9a:	0007c863          	bltz	a5,80004daa <sys_fstat+0x32>
    80004d9e:	fe043583          	ld	a1,-32(s0)
    80004da2:	fe843503          	ld	a0,-24(s0)
    80004da6:	c36ff0ef          	jal	800041dc <filestat>
    80004daa:	60e2                	ld	ra,24(sp)
    80004dac:	6442                	ld	s0,16(sp)
    80004dae:	6105                	addi	sp,sp,32
    80004db0:	8082                	ret

0000000080004db2 <sys_link>:
    80004db2:	7169                	addi	sp,sp,-304
    80004db4:	f606                	sd	ra,296(sp)
    80004db6:	f222                	sd	s0,288(sp)
    80004db8:	1a00                	addi	s0,sp,304
    80004dba:	08000613          	li	a2,128
    80004dbe:	ed040593          	addi	a1,s0,-304
    80004dc2:	4501                	li	a0,0
    80004dc4:	bedfd0ef          	jal	800029b0 <argstr>
    80004dc8:	57fd                	li	a5,-1
    80004dca:	0c054e63          	bltz	a0,80004ea6 <sys_link+0xf4>
    80004dce:	08000613          	li	a2,128
    80004dd2:	f5040593          	addi	a1,s0,-176
    80004dd6:	4505                	li	a0,1
    80004dd8:	bd9fd0ef          	jal	800029b0 <argstr>
    80004ddc:	57fd                	li	a5,-1
    80004dde:	0c054463          	bltz	a0,80004ea6 <sys_link+0xf4>
    80004de2:	ee26                	sd	s1,280(sp)
    80004de4:	f1dfe0ef          	jal	80003d00 <begin_op>
    80004de8:	ed040513          	addi	a0,s0,-304
    80004dec:	d59fe0ef          	jal	80003b44 <namei>
    80004df0:	84aa                	mv	s1,a0
    80004df2:	c53d                	beqz	a0,80004e60 <sys_link+0xae>
    80004df4:	e76fe0ef          	jal	8000346a <ilock>
    80004df8:	04449703          	lh	a4,68(s1)
    80004dfc:	4785                	li	a5,1
    80004dfe:	06f70663          	beq	a4,a5,80004e6a <sys_link+0xb8>
    80004e02:	ea4a                	sd	s2,272(sp)
    80004e04:	04a4d783          	lhu	a5,74(s1)
    80004e08:	2785                	addiw	a5,a5,1
    80004e0a:	04f49523          	sh	a5,74(s1)
    80004e0e:	8526                	mv	a0,s1
    80004e10:	da6fe0ef          	jal	800033b6 <iupdate>
    80004e14:	8526                	mv	a0,s1
    80004e16:	f02fe0ef          	jal	80003518 <iunlock>
    80004e1a:	fd040593          	addi	a1,s0,-48
    80004e1e:	f5040513          	addi	a0,s0,-176
    80004e22:	d3dfe0ef          	jal	80003b5e <nameiparent>
    80004e26:	892a                	mv	s2,a0
    80004e28:	cd21                	beqz	a0,80004e80 <sys_link+0xce>
    80004e2a:	e40fe0ef          	jal	8000346a <ilock>
    80004e2e:	00092703          	lw	a4,0(s2)
    80004e32:	409c                	lw	a5,0(s1)
    80004e34:	04f71363          	bne	a4,a5,80004e7a <sys_link+0xc8>
    80004e38:	40d0                	lw	a2,4(s1)
    80004e3a:	fd040593          	addi	a1,s0,-48
    80004e3e:	854a                	mv	a0,s2
    80004e40:	c6bfe0ef          	jal	80003aaa <dirlink>
    80004e44:	02054b63          	bltz	a0,80004e7a <sys_link+0xc8>
    80004e48:	854a                	mv	a0,s2
    80004e4a:	82bfe0ef          	jal	80003674 <iunlockput>
    80004e4e:	8526                	mv	a0,s1
    80004e50:	f9cfe0ef          	jal	800035ec <iput>
    80004e54:	f17fe0ef          	jal	80003d6a <end_op>
    80004e58:	4781                	li	a5,0
    80004e5a:	64f2                	ld	s1,280(sp)
    80004e5c:	6952                	ld	s2,272(sp)
    80004e5e:	a0a1                	j	80004ea6 <sys_link+0xf4>
    80004e60:	f0bfe0ef          	jal	80003d6a <end_op>
    80004e64:	57fd                	li	a5,-1
    80004e66:	64f2                	ld	s1,280(sp)
    80004e68:	a83d                	j	80004ea6 <sys_link+0xf4>
    80004e6a:	8526                	mv	a0,s1
    80004e6c:	809fe0ef          	jal	80003674 <iunlockput>
    80004e70:	efbfe0ef          	jal	80003d6a <end_op>
    80004e74:	57fd                	li	a5,-1
    80004e76:	64f2                	ld	s1,280(sp)
    80004e78:	a03d                	j	80004ea6 <sys_link+0xf4>
    80004e7a:	854a                	mv	a0,s2
    80004e7c:	ff8fe0ef          	jal	80003674 <iunlockput>
    80004e80:	8526                	mv	a0,s1
    80004e82:	de8fe0ef          	jal	8000346a <ilock>
    80004e86:	04a4d783          	lhu	a5,74(s1)
    80004e8a:	37fd                	addiw	a5,a5,-1
    80004e8c:	04f49523          	sh	a5,74(s1)
    80004e90:	8526                	mv	a0,s1
    80004e92:	d24fe0ef          	jal	800033b6 <iupdate>
    80004e96:	8526                	mv	a0,s1
    80004e98:	fdcfe0ef          	jal	80003674 <iunlockput>
    80004e9c:	ecffe0ef          	jal	80003d6a <end_op>
    80004ea0:	57fd                	li	a5,-1
    80004ea2:	64f2                	ld	s1,280(sp)
    80004ea4:	6952                	ld	s2,272(sp)
    80004ea6:	853e                	mv	a0,a5
    80004ea8:	70b2                	ld	ra,296(sp)
    80004eaa:	7412                	ld	s0,288(sp)
    80004eac:	6155                	addi	sp,sp,304
    80004eae:	8082                	ret

0000000080004eb0 <sys_unlink>:
    80004eb0:	7151                	addi	sp,sp,-240
    80004eb2:	f586                	sd	ra,232(sp)
    80004eb4:	f1a2                	sd	s0,224(sp)
    80004eb6:	1980                	addi	s0,sp,240
    80004eb8:	08000613          	li	a2,128
    80004ebc:	f3040593          	addi	a1,s0,-208
    80004ec0:	4501                	li	a0,0
    80004ec2:	aeffd0ef          	jal	800029b0 <argstr>
    80004ec6:	16054063          	bltz	a0,80005026 <sys_unlink+0x176>
    80004eca:	eda6                	sd	s1,216(sp)
    80004ecc:	e35fe0ef          	jal	80003d00 <begin_op>
    80004ed0:	fb040593          	addi	a1,s0,-80
    80004ed4:	f3040513          	addi	a0,s0,-208
    80004ed8:	c87fe0ef          	jal	80003b5e <nameiparent>
    80004edc:	84aa                	mv	s1,a0
    80004ede:	c945                	beqz	a0,80004f8e <sys_unlink+0xde>
    80004ee0:	d8afe0ef          	jal	8000346a <ilock>
    80004ee4:	00002597          	auipc	a1,0x2
    80004ee8:	7fc58593          	addi	a1,a1,2044 # 800076e0 <etext+0x6e0>
    80004eec:	fb040513          	addi	a0,s0,-80
    80004ef0:	9d9fe0ef          	jal	800038c8 <namecmp>
    80004ef4:	10050e63          	beqz	a0,80005010 <sys_unlink+0x160>
    80004ef8:	00002597          	auipc	a1,0x2
    80004efc:	7f058593          	addi	a1,a1,2032 # 800076e8 <etext+0x6e8>
    80004f00:	fb040513          	addi	a0,s0,-80
    80004f04:	9c5fe0ef          	jal	800038c8 <namecmp>
    80004f08:	10050463          	beqz	a0,80005010 <sys_unlink+0x160>
    80004f0c:	e9ca                	sd	s2,208(sp)
    80004f0e:	f2c40613          	addi	a2,s0,-212
    80004f12:	fb040593          	addi	a1,s0,-80
    80004f16:	8526                	mv	a0,s1
    80004f18:	9c7fe0ef          	jal	800038de <dirlookup>
    80004f1c:	892a                	mv	s2,a0
    80004f1e:	0e050863          	beqz	a0,8000500e <sys_unlink+0x15e>
    80004f22:	d48fe0ef          	jal	8000346a <ilock>
    80004f26:	04a91783          	lh	a5,74(s2)
    80004f2a:	06f05763          	blez	a5,80004f98 <sys_unlink+0xe8>
    80004f2e:	04491703          	lh	a4,68(s2)
    80004f32:	4785                	li	a5,1
    80004f34:	06f70963          	beq	a4,a5,80004fa6 <sys_unlink+0xf6>
    80004f38:	4641                	li	a2,16
    80004f3a:	4581                	li	a1,0
    80004f3c:	fc040513          	addi	a0,s0,-64
    80004f40:	d89fb0ef          	jal	80000cc8 <memset>
    80004f44:	4741                	li	a4,16
    80004f46:	f2c42683          	lw	a3,-212(s0)
    80004f4a:	fc040613          	addi	a2,s0,-64
    80004f4e:	4581                	li	a1,0
    80004f50:	8526                	mv	a0,s1
    80004f52:	869fe0ef          	jal	800037ba <writei>
    80004f56:	47c1                	li	a5,16
    80004f58:	08f51b63          	bne	a0,a5,80004fee <sys_unlink+0x13e>
    80004f5c:	04491703          	lh	a4,68(s2)
    80004f60:	4785                	li	a5,1
    80004f62:	08f70d63          	beq	a4,a5,80004ffc <sys_unlink+0x14c>
    80004f66:	8526                	mv	a0,s1
    80004f68:	f0cfe0ef          	jal	80003674 <iunlockput>
    80004f6c:	04a95783          	lhu	a5,74(s2)
    80004f70:	37fd                	addiw	a5,a5,-1
    80004f72:	04f91523          	sh	a5,74(s2)
    80004f76:	854a                	mv	a0,s2
    80004f78:	c3efe0ef          	jal	800033b6 <iupdate>
    80004f7c:	854a                	mv	a0,s2
    80004f7e:	ef6fe0ef          	jal	80003674 <iunlockput>
    80004f82:	de9fe0ef          	jal	80003d6a <end_op>
    80004f86:	4501                	li	a0,0
    80004f88:	64ee                	ld	s1,216(sp)
    80004f8a:	694e                	ld	s2,208(sp)
    80004f8c:	a849                	j	8000501e <sys_unlink+0x16e>
    80004f8e:	dddfe0ef          	jal	80003d6a <end_op>
    80004f92:	557d                	li	a0,-1
    80004f94:	64ee                	ld	s1,216(sp)
    80004f96:	a061                	j	8000501e <sys_unlink+0x16e>
    80004f98:	e5ce                	sd	s3,200(sp)
    80004f9a:	00002517          	auipc	a0,0x2
    80004f9e:	75650513          	addi	a0,a0,1878 # 800076f0 <etext+0x6f0>
    80004fa2:	ff2fb0ef          	jal	80000794 <panic>
    80004fa6:	04c92703          	lw	a4,76(s2)
    80004faa:	02000793          	li	a5,32
    80004fae:	f8e7f5e3          	bgeu	a5,a4,80004f38 <sys_unlink+0x88>
    80004fb2:	e5ce                	sd	s3,200(sp)
    80004fb4:	02000993          	li	s3,32
    80004fb8:	4741                	li	a4,16
    80004fba:	86ce                	mv	a3,s3
    80004fbc:	f1840613          	addi	a2,s0,-232
    80004fc0:	4581                	li	a1,0
    80004fc2:	854a                	mv	a0,s2
    80004fc4:	efafe0ef          	jal	800036be <readi>
    80004fc8:	47c1                	li	a5,16
    80004fca:	00f51c63          	bne	a0,a5,80004fe2 <sys_unlink+0x132>
    80004fce:	f1845783          	lhu	a5,-232(s0)
    80004fd2:	efa1                	bnez	a5,8000502a <sys_unlink+0x17a>
    80004fd4:	29c1                	addiw	s3,s3,16
    80004fd6:	04c92783          	lw	a5,76(s2)
    80004fda:	fcf9efe3          	bltu	s3,a5,80004fb8 <sys_unlink+0x108>
    80004fde:	69ae                	ld	s3,200(sp)
    80004fe0:	bfa1                	j	80004f38 <sys_unlink+0x88>
    80004fe2:	00002517          	auipc	a0,0x2
    80004fe6:	72650513          	addi	a0,a0,1830 # 80007708 <etext+0x708>
    80004fea:	faafb0ef          	jal	80000794 <panic>
    80004fee:	e5ce                	sd	s3,200(sp)
    80004ff0:	00002517          	auipc	a0,0x2
    80004ff4:	73050513          	addi	a0,a0,1840 # 80007720 <etext+0x720>
    80004ff8:	f9cfb0ef          	jal	80000794 <panic>
    80004ffc:	04a4d783          	lhu	a5,74(s1)
    80005000:	37fd                	addiw	a5,a5,-1
    80005002:	04f49523          	sh	a5,74(s1)
    80005006:	8526                	mv	a0,s1
    80005008:	baefe0ef          	jal	800033b6 <iupdate>
    8000500c:	bfa9                	j	80004f66 <sys_unlink+0xb6>
    8000500e:	694e                	ld	s2,208(sp)
    80005010:	8526                	mv	a0,s1
    80005012:	e62fe0ef          	jal	80003674 <iunlockput>
    80005016:	d55fe0ef          	jal	80003d6a <end_op>
    8000501a:	557d                	li	a0,-1
    8000501c:	64ee                	ld	s1,216(sp)
    8000501e:	70ae                	ld	ra,232(sp)
    80005020:	740e                	ld	s0,224(sp)
    80005022:	616d                	addi	sp,sp,240
    80005024:	8082                	ret
    80005026:	557d                	li	a0,-1
    80005028:	bfdd                	j	8000501e <sys_unlink+0x16e>
    8000502a:	854a                	mv	a0,s2
    8000502c:	e48fe0ef          	jal	80003674 <iunlockput>
    80005030:	694e                	ld	s2,208(sp)
    80005032:	69ae                	ld	s3,200(sp)
    80005034:	bff1                	j	80005010 <sys_unlink+0x160>

0000000080005036 <sys_open>:
    80005036:	7131                	addi	sp,sp,-192
    80005038:	fd06                	sd	ra,184(sp)
    8000503a:	f922                	sd	s0,176(sp)
    8000503c:	0180                	addi	s0,sp,192
    8000503e:	f4c40593          	addi	a1,s0,-180
    80005042:	4505                	li	a0,1
    80005044:	935fd0ef          	jal	80002978 <argint>
    80005048:	08000613          	li	a2,128
    8000504c:	f5040593          	addi	a1,s0,-176
    80005050:	4501                	li	a0,0
    80005052:	95ffd0ef          	jal	800029b0 <argstr>
    80005056:	87aa                	mv	a5,a0
    80005058:	557d                	li	a0,-1
    8000505a:	0a07c263          	bltz	a5,800050fe <sys_open+0xc8>
    8000505e:	f526                	sd	s1,168(sp)
    80005060:	ca1fe0ef          	jal	80003d00 <begin_op>
    80005064:	f4c42783          	lw	a5,-180(s0)
    80005068:	2007f793          	andi	a5,a5,512
    8000506c:	c3d5                	beqz	a5,80005110 <sys_open+0xda>
    8000506e:	4681                	li	a3,0
    80005070:	4601                	li	a2,0
    80005072:	4589                	li	a1,2
    80005074:	f5040513          	addi	a0,s0,-176
    80005078:	aa9ff0ef          	jal	80004b20 <create>
    8000507c:	84aa                	mv	s1,a0
    8000507e:	c541                	beqz	a0,80005106 <sys_open+0xd0>
    80005080:	04449703          	lh	a4,68(s1)
    80005084:	478d                	li	a5,3
    80005086:	00f71763          	bne	a4,a5,80005094 <sys_open+0x5e>
    8000508a:	0464d703          	lhu	a4,70(s1)
    8000508e:	47a5                	li	a5,9
    80005090:	0ae7ed63          	bltu	a5,a4,8000514a <sys_open+0x114>
    80005094:	f14a                	sd	s2,160(sp)
    80005096:	fe1fe0ef          	jal	80004076 <filealloc>
    8000509a:	892a                	mv	s2,a0
    8000509c:	c179                	beqz	a0,80005162 <sys_open+0x12c>
    8000509e:	ed4e                	sd	s3,152(sp)
    800050a0:	a43ff0ef          	jal	80004ae2 <fdalloc>
    800050a4:	89aa                	mv	s3,a0
    800050a6:	0a054a63          	bltz	a0,8000515a <sys_open+0x124>
    800050aa:	04449703          	lh	a4,68(s1)
    800050ae:	478d                	li	a5,3
    800050b0:	0cf70263          	beq	a4,a5,80005174 <sys_open+0x13e>
    800050b4:	4789                	li	a5,2
    800050b6:	00f92023          	sw	a5,0(s2)
    800050ba:	02092023          	sw	zero,32(s2)
    800050be:	00993c23          	sd	s1,24(s2)
    800050c2:	f4c42783          	lw	a5,-180(s0)
    800050c6:	0017c713          	xori	a4,a5,1
    800050ca:	8b05                	andi	a4,a4,1
    800050cc:	00e90423          	sb	a4,8(s2)
    800050d0:	0037f713          	andi	a4,a5,3
    800050d4:	00e03733          	snez	a4,a4
    800050d8:	00e904a3          	sb	a4,9(s2)
    800050dc:	4007f793          	andi	a5,a5,1024
    800050e0:	c791                	beqz	a5,800050ec <sys_open+0xb6>
    800050e2:	04449703          	lh	a4,68(s1)
    800050e6:	4789                	li	a5,2
    800050e8:	08f70d63          	beq	a4,a5,80005182 <sys_open+0x14c>
    800050ec:	8526                	mv	a0,s1
    800050ee:	c2afe0ef          	jal	80003518 <iunlock>
    800050f2:	c79fe0ef          	jal	80003d6a <end_op>
    800050f6:	854e                	mv	a0,s3
    800050f8:	74aa                	ld	s1,168(sp)
    800050fa:	790a                	ld	s2,160(sp)
    800050fc:	69ea                	ld	s3,152(sp)
    800050fe:	70ea                	ld	ra,184(sp)
    80005100:	744a                	ld	s0,176(sp)
    80005102:	6129                	addi	sp,sp,192
    80005104:	8082                	ret
    80005106:	c65fe0ef          	jal	80003d6a <end_op>
    8000510a:	557d                	li	a0,-1
    8000510c:	74aa                	ld	s1,168(sp)
    8000510e:	bfc5                	j	800050fe <sys_open+0xc8>
    80005110:	f5040513          	addi	a0,s0,-176
    80005114:	a31fe0ef          	jal	80003b44 <namei>
    80005118:	84aa                	mv	s1,a0
    8000511a:	c11d                	beqz	a0,80005140 <sys_open+0x10a>
    8000511c:	b4efe0ef          	jal	8000346a <ilock>
    80005120:	04449703          	lh	a4,68(s1)
    80005124:	4785                	li	a5,1
    80005126:	f4f71de3          	bne	a4,a5,80005080 <sys_open+0x4a>
    8000512a:	f4c42783          	lw	a5,-180(s0)
    8000512e:	d3bd                	beqz	a5,80005094 <sys_open+0x5e>
    80005130:	8526                	mv	a0,s1
    80005132:	d42fe0ef          	jal	80003674 <iunlockput>
    80005136:	c35fe0ef          	jal	80003d6a <end_op>
    8000513a:	557d                	li	a0,-1
    8000513c:	74aa                	ld	s1,168(sp)
    8000513e:	b7c1                	j	800050fe <sys_open+0xc8>
    80005140:	c2bfe0ef          	jal	80003d6a <end_op>
    80005144:	557d                	li	a0,-1
    80005146:	74aa                	ld	s1,168(sp)
    80005148:	bf5d                	j	800050fe <sys_open+0xc8>
    8000514a:	8526                	mv	a0,s1
    8000514c:	d28fe0ef          	jal	80003674 <iunlockput>
    80005150:	c1bfe0ef          	jal	80003d6a <end_op>
    80005154:	557d                	li	a0,-1
    80005156:	74aa                	ld	s1,168(sp)
    80005158:	b75d                	j	800050fe <sys_open+0xc8>
    8000515a:	854a                	mv	a0,s2
    8000515c:	fbffe0ef          	jal	8000411a <fileclose>
    80005160:	69ea                	ld	s3,152(sp)
    80005162:	8526                	mv	a0,s1
    80005164:	d10fe0ef          	jal	80003674 <iunlockput>
    80005168:	c03fe0ef          	jal	80003d6a <end_op>
    8000516c:	557d                	li	a0,-1
    8000516e:	74aa                	ld	s1,168(sp)
    80005170:	790a                	ld	s2,160(sp)
    80005172:	b771                	j	800050fe <sys_open+0xc8>
    80005174:	00f92023          	sw	a5,0(s2)
    80005178:	04649783          	lh	a5,70(s1)
    8000517c:	02f91223          	sh	a5,36(s2)
    80005180:	bf3d                	j	800050be <sys_open+0x88>
    80005182:	8526                	mv	a0,s1
    80005184:	bd4fe0ef          	jal	80003558 <itrunc>
    80005188:	b795                	j	800050ec <sys_open+0xb6>

000000008000518a <sys_mkdir>:
    8000518a:	7175                	addi	sp,sp,-144
    8000518c:	e506                	sd	ra,136(sp)
    8000518e:	e122                	sd	s0,128(sp)
    80005190:	0900                	addi	s0,sp,144
    80005192:	b6ffe0ef          	jal	80003d00 <begin_op>
    80005196:	08000613          	li	a2,128
    8000519a:	f7040593          	addi	a1,s0,-144
    8000519e:	4501                	li	a0,0
    800051a0:	811fd0ef          	jal	800029b0 <argstr>
    800051a4:	02054363          	bltz	a0,800051ca <sys_mkdir+0x40>
    800051a8:	4681                	li	a3,0
    800051aa:	4601                	li	a2,0
    800051ac:	4585                	li	a1,1
    800051ae:	f7040513          	addi	a0,s0,-144
    800051b2:	96fff0ef          	jal	80004b20 <create>
    800051b6:	c911                	beqz	a0,800051ca <sys_mkdir+0x40>
    800051b8:	cbcfe0ef          	jal	80003674 <iunlockput>
    800051bc:	baffe0ef          	jal	80003d6a <end_op>
    800051c0:	4501                	li	a0,0
    800051c2:	60aa                	ld	ra,136(sp)
    800051c4:	640a                	ld	s0,128(sp)
    800051c6:	6149                	addi	sp,sp,144
    800051c8:	8082                	ret
    800051ca:	ba1fe0ef          	jal	80003d6a <end_op>
    800051ce:	557d                	li	a0,-1
    800051d0:	bfcd                	j	800051c2 <sys_mkdir+0x38>

00000000800051d2 <sys_mknod>:
    800051d2:	7135                	addi	sp,sp,-160
    800051d4:	ed06                	sd	ra,152(sp)
    800051d6:	e922                	sd	s0,144(sp)
    800051d8:	1100                	addi	s0,sp,160
    800051da:	b27fe0ef          	jal	80003d00 <begin_op>
    800051de:	f6c40593          	addi	a1,s0,-148
    800051e2:	4505                	li	a0,1
    800051e4:	f94fd0ef          	jal	80002978 <argint>
    800051e8:	f6840593          	addi	a1,s0,-152
    800051ec:	4509                	li	a0,2
    800051ee:	f8afd0ef          	jal	80002978 <argint>
    800051f2:	08000613          	li	a2,128
    800051f6:	f7040593          	addi	a1,s0,-144
    800051fa:	4501                	li	a0,0
    800051fc:	fb4fd0ef          	jal	800029b0 <argstr>
    80005200:	02054563          	bltz	a0,8000522a <sys_mknod+0x58>
    80005204:	f6841683          	lh	a3,-152(s0)
    80005208:	f6c41603          	lh	a2,-148(s0)
    8000520c:	458d                	li	a1,3
    8000520e:	f7040513          	addi	a0,s0,-144
    80005212:	90fff0ef          	jal	80004b20 <create>
    80005216:	c911                	beqz	a0,8000522a <sys_mknod+0x58>
    80005218:	c5cfe0ef          	jal	80003674 <iunlockput>
    8000521c:	b4ffe0ef          	jal	80003d6a <end_op>
    80005220:	4501                	li	a0,0
    80005222:	60ea                	ld	ra,152(sp)
    80005224:	644a                	ld	s0,144(sp)
    80005226:	610d                	addi	sp,sp,160
    80005228:	8082                	ret
    8000522a:	b41fe0ef          	jal	80003d6a <end_op>
    8000522e:	557d                	li	a0,-1
    80005230:	bfcd                	j	80005222 <sys_mknod+0x50>

0000000080005232 <sys_chdir>:
    80005232:	7135                	addi	sp,sp,-160
    80005234:	ed06                	sd	ra,152(sp)
    80005236:	e922                	sd	s0,144(sp)
    80005238:	e14a                	sd	s2,128(sp)
    8000523a:	1100                	addi	s0,sp,160
    8000523c:	ea4fc0ef          	jal	800018e0 <myproc>
    80005240:	892a                	mv	s2,a0
    80005242:	abffe0ef          	jal	80003d00 <begin_op>
    80005246:	08000613          	li	a2,128
    8000524a:	f6040593          	addi	a1,s0,-160
    8000524e:	4501                	li	a0,0
    80005250:	f60fd0ef          	jal	800029b0 <argstr>
    80005254:	04054363          	bltz	a0,8000529a <sys_chdir+0x68>
    80005258:	e526                	sd	s1,136(sp)
    8000525a:	f6040513          	addi	a0,s0,-160
    8000525e:	8e7fe0ef          	jal	80003b44 <namei>
    80005262:	84aa                	mv	s1,a0
    80005264:	c915                	beqz	a0,80005298 <sys_chdir+0x66>
    80005266:	a04fe0ef          	jal	8000346a <ilock>
    8000526a:	04449703          	lh	a4,68(s1)
    8000526e:	4785                	li	a5,1
    80005270:	02f71963          	bne	a4,a5,800052a2 <sys_chdir+0x70>
    80005274:	8526                	mv	a0,s1
    80005276:	aa2fe0ef          	jal	80003518 <iunlock>
    8000527a:	15093503          	ld	a0,336(s2)
    8000527e:	b6efe0ef          	jal	800035ec <iput>
    80005282:	ae9fe0ef          	jal	80003d6a <end_op>
    80005286:	14993823          	sd	s1,336(s2)
    8000528a:	4501                	li	a0,0
    8000528c:	64aa                	ld	s1,136(sp)
    8000528e:	60ea                	ld	ra,152(sp)
    80005290:	644a                	ld	s0,144(sp)
    80005292:	690a                	ld	s2,128(sp)
    80005294:	610d                	addi	sp,sp,160
    80005296:	8082                	ret
    80005298:	64aa                	ld	s1,136(sp)
    8000529a:	ad1fe0ef          	jal	80003d6a <end_op>
    8000529e:	557d                	li	a0,-1
    800052a0:	b7fd                	j	8000528e <sys_chdir+0x5c>
    800052a2:	8526                	mv	a0,s1
    800052a4:	bd0fe0ef          	jal	80003674 <iunlockput>
    800052a8:	ac3fe0ef          	jal	80003d6a <end_op>
    800052ac:	557d                	li	a0,-1
    800052ae:	64aa                	ld	s1,136(sp)
    800052b0:	bff9                	j	8000528e <sys_chdir+0x5c>

00000000800052b2 <sys_exec>:
    800052b2:	7121                	addi	sp,sp,-448
    800052b4:	ff06                	sd	ra,440(sp)
    800052b6:	fb22                	sd	s0,432(sp)
    800052b8:	0380                	addi	s0,sp,448
    800052ba:	e4840593          	addi	a1,s0,-440
    800052be:	4505                	li	a0,1
    800052c0:	ed4fd0ef          	jal	80002994 <argaddr>
    800052c4:	08000613          	li	a2,128
    800052c8:	f5040593          	addi	a1,s0,-176
    800052cc:	4501                	li	a0,0
    800052ce:	ee2fd0ef          	jal	800029b0 <argstr>
    800052d2:	87aa                	mv	a5,a0
    800052d4:	557d                	li	a0,-1
    800052d6:	0c07c463          	bltz	a5,8000539e <sys_exec+0xec>
    800052da:	f726                	sd	s1,424(sp)
    800052dc:	f34a                	sd	s2,416(sp)
    800052de:	ef4e                	sd	s3,408(sp)
    800052e0:	eb52                	sd	s4,400(sp)
    800052e2:	10000613          	li	a2,256
    800052e6:	4581                	li	a1,0
    800052e8:	e5040513          	addi	a0,s0,-432
    800052ec:	9ddfb0ef          	jal	80000cc8 <memset>
    800052f0:	e5040493          	addi	s1,s0,-432
    800052f4:	89a6                	mv	s3,s1
    800052f6:	4901                	li	s2,0
    800052f8:	02000a13          	li	s4,32
    800052fc:	00391513          	slli	a0,s2,0x3
    80005300:	e4040593          	addi	a1,s0,-448
    80005304:	e4843783          	ld	a5,-440(s0)
    80005308:	953e                	add	a0,a0,a5
    8000530a:	de4fd0ef          	jal	800028ee <fetchaddr>
    8000530e:	02054663          	bltz	a0,8000533a <sys_exec+0x88>
    80005312:	e4043783          	ld	a5,-448(s0)
    80005316:	c3a9                	beqz	a5,80005358 <sys_exec+0xa6>
    80005318:	80dfb0ef          	jal	80000b24 <kalloc>
    8000531c:	85aa                	mv	a1,a0
    8000531e:	00a9b023          	sd	a0,0(s3)
    80005322:	cd01                	beqz	a0,8000533a <sys_exec+0x88>
    80005324:	6605                	lui	a2,0x1
    80005326:	e4043503          	ld	a0,-448(s0)
    8000532a:	e0efd0ef          	jal	80002938 <fetchstr>
    8000532e:	00054663          	bltz	a0,8000533a <sys_exec+0x88>
    80005332:	0905                	addi	s2,s2,1
    80005334:	09a1                	addi	s3,s3,8
    80005336:	fd4913e3          	bne	s2,s4,800052fc <sys_exec+0x4a>
    8000533a:	f5040913          	addi	s2,s0,-176
    8000533e:	6088                	ld	a0,0(s1)
    80005340:	c931                	beqz	a0,80005394 <sys_exec+0xe2>
    80005342:	f00fb0ef          	jal	80000a42 <kfree>
    80005346:	04a1                	addi	s1,s1,8
    80005348:	ff249be3          	bne	s1,s2,8000533e <sys_exec+0x8c>
    8000534c:	557d                	li	a0,-1
    8000534e:	74ba                	ld	s1,424(sp)
    80005350:	791a                	ld	s2,416(sp)
    80005352:	69fa                	ld	s3,408(sp)
    80005354:	6a5a                	ld	s4,400(sp)
    80005356:	a0a1                	j	8000539e <sys_exec+0xec>
    80005358:	0009079b          	sext.w	a5,s2
    8000535c:	078e                	slli	a5,a5,0x3
    8000535e:	fd078793          	addi	a5,a5,-48
    80005362:	97a2                	add	a5,a5,s0
    80005364:	e807b023          	sd	zero,-384(a5)
    80005368:	e5040593          	addi	a1,s0,-432
    8000536c:	f5040513          	addi	a0,s0,-176
    80005370:	ba8ff0ef          	jal	80004718 <exec>
    80005374:	892a                	mv	s2,a0
    80005376:	f5040993          	addi	s3,s0,-176
    8000537a:	6088                	ld	a0,0(s1)
    8000537c:	c511                	beqz	a0,80005388 <sys_exec+0xd6>
    8000537e:	ec4fb0ef          	jal	80000a42 <kfree>
    80005382:	04a1                	addi	s1,s1,8
    80005384:	ff349be3          	bne	s1,s3,8000537a <sys_exec+0xc8>
    80005388:	854a                	mv	a0,s2
    8000538a:	74ba                	ld	s1,424(sp)
    8000538c:	791a                	ld	s2,416(sp)
    8000538e:	69fa                	ld	s3,408(sp)
    80005390:	6a5a                	ld	s4,400(sp)
    80005392:	a031                	j	8000539e <sys_exec+0xec>
    80005394:	557d                	li	a0,-1
    80005396:	74ba                	ld	s1,424(sp)
    80005398:	791a                	ld	s2,416(sp)
    8000539a:	69fa                	ld	s3,408(sp)
    8000539c:	6a5a                	ld	s4,400(sp)
    8000539e:	70fa                	ld	ra,440(sp)
    800053a0:	745a                	ld	s0,432(sp)
    800053a2:	6139                	addi	sp,sp,448
    800053a4:	8082                	ret

00000000800053a6 <sys_pipe>:
    800053a6:	7139                	addi	sp,sp,-64
    800053a8:	fc06                	sd	ra,56(sp)
    800053aa:	f822                	sd	s0,48(sp)
    800053ac:	f426                	sd	s1,40(sp)
    800053ae:	0080                	addi	s0,sp,64
    800053b0:	d30fc0ef          	jal	800018e0 <myproc>
    800053b4:	84aa                	mv	s1,a0
    800053b6:	fd840593          	addi	a1,s0,-40
    800053ba:	4501                	li	a0,0
    800053bc:	dd8fd0ef          	jal	80002994 <argaddr>
    800053c0:	fc840593          	addi	a1,s0,-56
    800053c4:	fd040513          	addi	a0,s0,-48
    800053c8:	85cff0ef          	jal	80004424 <pipealloc>
    800053cc:	57fd                	li	a5,-1
    800053ce:	0a054463          	bltz	a0,80005476 <sys_pipe+0xd0>
    800053d2:	fcf42223          	sw	a5,-60(s0)
    800053d6:	fd043503          	ld	a0,-48(s0)
    800053da:	f08ff0ef          	jal	80004ae2 <fdalloc>
    800053de:	fca42223          	sw	a0,-60(s0)
    800053e2:	08054163          	bltz	a0,80005464 <sys_pipe+0xbe>
    800053e6:	fc843503          	ld	a0,-56(s0)
    800053ea:	ef8ff0ef          	jal	80004ae2 <fdalloc>
    800053ee:	fca42023          	sw	a0,-64(s0)
    800053f2:	06054063          	bltz	a0,80005452 <sys_pipe+0xac>
    800053f6:	4691                	li	a3,4
    800053f8:	fc440613          	addi	a2,s0,-60
    800053fc:	fd843583          	ld	a1,-40(s0)
    80005400:	68a8                	ld	a0,80(s1)
    80005402:	950fc0ef          	jal	80001552 <copyout>
    80005406:	00054e63          	bltz	a0,80005422 <sys_pipe+0x7c>
    8000540a:	4691                	li	a3,4
    8000540c:	fc040613          	addi	a2,s0,-64
    80005410:	fd843583          	ld	a1,-40(s0)
    80005414:	0591                	addi	a1,a1,4
    80005416:	68a8                	ld	a0,80(s1)
    80005418:	93afc0ef          	jal	80001552 <copyout>
    8000541c:	4781                	li	a5,0
    8000541e:	04055c63          	bgez	a0,80005476 <sys_pipe+0xd0>
    80005422:	fc442783          	lw	a5,-60(s0)
    80005426:	07e9                	addi	a5,a5,26
    80005428:	078e                	slli	a5,a5,0x3
    8000542a:	97a6                	add	a5,a5,s1
    8000542c:	0007b023          	sd	zero,0(a5)
    80005430:	fc042783          	lw	a5,-64(s0)
    80005434:	07e9                	addi	a5,a5,26
    80005436:	078e                	slli	a5,a5,0x3
    80005438:	94be                	add	s1,s1,a5
    8000543a:	0004b023          	sd	zero,0(s1)
    8000543e:	fd043503          	ld	a0,-48(s0)
    80005442:	cd9fe0ef          	jal	8000411a <fileclose>
    80005446:	fc843503          	ld	a0,-56(s0)
    8000544a:	cd1fe0ef          	jal	8000411a <fileclose>
    8000544e:	57fd                	li	a5,-1
    80005450:	a01d                	j	80005476 <sys_pipe+0xd0>
    80005452:	fc442783          	lw	a5,-60(s0)
    80005456:	0007c763          	bltz	a5,80005464 <sys_pipe+0xbe>
    8000545a:	07e9                	addi	a5,a5,26
    8000545c:	078e                	slli	a5,a5,0x3
    8000545e:	97a6                	add	a5,a5,s1
    80005460:	0007b023          	sd	zero,0(a5)
    80005464:	fd043503          	ld	a0,-48(s0)
    80005468:	cb3fe0ef          	jal	8000411a <fileclose>
    8000546c:	fc843503          	ld	a0,-56(s0)
    80005470:	cabfe0ef          	jal	8000411a <fileclose>
    80005474:	57fd                	li	a5,-1
    80005476:	853e                	mv	a0,a5
    80005478:	70e2                	ld	ra,56(sp)
    8000547a:	7442                	ld	s0,48(sp)
    8000547c:	74a2                	ld	s1,40(sp)
    8000547e:	6121                	addi	sp,sp,64
    80005480:	8082                	ret
	...

0000000080005490 <kernelvec>:
    80005490:	7111                	addi	sp,sp,-256
    80005492:	e006                	sd	ra,0(sp)
    80005494:	e40a                	sd	sp,8(sp)
    80005496:	e80e                	sd	gp,16(sp)
    80005498:	ec12                	sd	tp,24(sp)
    8000549a:	f016                	sd	t0,32(sp)
    8000549c:	f41a                	sd	t1,40(sp)
    8000549e:	f81e                	sd	t2,48(sp)
    800054a0:	e4aa                	sd	a0,72(sp)
    800054a2:	e8ae                	sd	a1,80(sp)
    800054a4:	ecb2                	sd	a2,88(sp)
    800054a6:	f0b6                	sd	a3,96(sp)
    800054a8:	f4ba                	sd	a4,104(sp)
    800054aa:	f8be                	sd	a5,112(sp)
    800054ac:	fcc2                	sd	a6,120(sp)
    800054ae:	e146                	sd	a7,128(sp)
    800054b0:	edf2                	sd	t3,216(sp)
    800054b2:	f1f6                	sd	t4,224(sp)
    800054b4:	f5fa                	sd	t5,232(sp)
    800054b6:	f9fe                	sd	t6,240(sp)
    800054b8:	b46fd0ef          	jal	800027fe <kerneltrap>
    800054bc:	6082                	ld	ra,0(sp)
    800054be:	6122                	ld	sp,8(sp)
    800054c0:	61c2                	ld	gp,16(sp)
    800054c2:	7282                	ld	t0,32(sp)
    800054c4:	7322                	ld	t1,40(sp)
    800054c6:	73c2                	ld	t2,48(sp)
    800054c8:	6526                	ld	a0,72(sp)
    800054ca:	65c6                	ld	a1,80(sp)
    800054cc:	6666                	ld	a2,88(sp)
    800054ce:	7686                	ld	a3,96(sp)
    800054d0:	7726                	ld	a4,104(sp)
    800054d2:	77c6                	ld	a5,112(sp)
    800054d4:	7866                	ld	a6,120(sp)
    800054d6:	688a                	ld	a7,128(sp)
    800054d8:	6e6e                	ld	t3,216(sp)
    800054da:	7e8e                	ld	t4,224(sp)
    800054dc:	7f2e                	ld	t5,232(sp)
    800054de:	7fce                	ld	t6,240(sp)
    800054e0:	6111                	addi	sp,sp,256
    800054e2:	10200073          	sret
	...

00000000800054ee <plicinit>:
    800054ee:	1141                	addi	sp,sp,-16
    800054f0:	e422                	sd	s0,8(sp)
    800054f2:	0800                	addi	s0,sp,16
    800054f4:	0c0007b7          	lui	a5,0xc000
    800054f8:	4705                	li	a4,1
    800054fa:	d798                	sw	a4,40(a5)
    800054fc:	0c0007b7          	lui	a5,0xc000
    80005500:	c3d8                	sw	a4,4(a5)
    80005502:	6422                	ld	s0,8(sp)
    80005504:	0141                	addi	sp,sp,16
    80005506:	8082                	ret

0000000080005508 <plicinithart>:
    80005508:	1141                	addi	sp,sp,-16
    8000550a:	e406                	sd	ra,8(sp)
    8000550c:	e022                	sd	s0,0(sp)
    8000550e:	0800                	addi	s0,sp,16
    80005510:	ba4fc0ef          	jal	800018b4 <cpuid>
    80005514:	0085171b          	slliw	a4,a0,0x8
    80005518:	0c0027b7          	lui	a5,0xc002
    8000551c:	97ba                	add	a5,a5,a4
    8000551e:	40200713          	li	a4,1026
    80005522:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>
    80005526:	00d5151b          	slliw	a0,a0,0xd
    8000552a:	0c2017b7          	lui	a5,0xc201
    8000552e:	97aa                	add	a5,a5,a0
    80005530:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
    80005534:	60a2                	ld	ra,8(sp)
    80005536:	6402                	ld	s0,0(sp)
    80005538:	0141                	addi	sp,sp,16
    8000553a:	8082                	ret

000000008000553c <plic_claim>:
    8000553c:	1141                	addi	sp,sp,-16
    8000553e:	e406                	sd	ra,8(sp)
    80005540:	e022                	sd	s0,0(sp)
    80005542:	0800                	addi	s0,sp,16
    80005544:	b70fc0ef          	jal	800018b4 <cpuid>
    80005548:	00d5151b          	slliw	a0,a0,0xd
    8000554c:	0c2017b7          	lui	a5,0xc201
    80005550:	97aa                	add	a5,a5,a0
    80005552:	43c8                	lw	a0,4(a5)
    80005554:	60a2                	ld	ra,8(sp)
    80005556:	6402                	ld	s0,0(sp)
    80005558:	0141                	addi	sp,sp,16
    8000555a:	8082                	ret

000000008000555c <plic_complete>:
    8000555c:	1101                	addi	sp,sp,-32
    8000555e:	ec06                	sd	ra,24(sp)
    80005560:	e822                	sd	s0,16(sp)
    80005562:	e426                	sd	s1,8(sp)
    80005564:	1000                	addi	s0,sp,32
    80005566:	84aa                	mv	s1,a0
    80005568:	b4cfc0ef          	jal	800018b4 <cpuid>
    8000556c:	00d5151b          	slliw	a0,a0,0xd
    80005570:	0c2017b7          	lui	a5,0xc201
    80005574:	97aa                	add	a5,a5,a0
    80005576:	c3c4                	sw	s1,4(a5)
    80005578:	60e2                	ld	ra,24(sp)
    8000557a:	6442                	ld	s0,16(sp)
    8000557c:	64a2                	ld	s1,8(sp)
    8000557e:	6105                	addi	sp,sp,32
    80005580:	8082                	ret

0000000080005582 <free_desc>:
    80005582:	1141                	addi	sp,sp,-16
    80005584:	e406                	sd	ra,8(sp)
    80005586:	e022                	sd	s0,0(sp)
    80005588:	0800                	addi	s0,sp,16
    8000558a:	479d                	li	a5,7
    8000558c:	04a7ca63          	blt	a5,a0,800055e0 <free_desc+0x5e>
    80005590:	00024797          	auipc	a5,0x24
    80005594:	ed878793          	addi	a5,a5,-296 # 80029468 <disk>
    80005598:	97aa                	add	a5,a5,a0
    8000559a:	0187c783          	lbu	a5,24(a5)
    8000559e:	e7b9                	bnez	a5,800055ec <free_desc+0x6a>
    800055a0:	00451693          	slli	a3,a0,0x4
    800055a4:	00024797          	auipc	a5,0x24
    800055a8:	ec478793          	addi	a5,a5,-316 # 80029468 <disk>
    800055ac:	6398                	ld	a4,0(a5)
    800055ae:	9736                	add	a4,a4,a3
    800055b0:	00073023          	sd	zero,0(a4)
    800055b4:	6398                	ld	a4,0(a5)
    800055b6:	9736                	add	a4,a4,a3
    800055b8:	00072423          	sw	zero,8(a4)
    800055bc:	00071623          	sh	zero,12(a4)
    800055c0:	00071723          	sh	zero,14(a4)
    800055c4:	97aa                	add	a5,a5,a0
    800055c6:	4705                	li	a4,1
    800055c8:	00e78c23          	sb	a4,24(a5)
    800055cc:	00024517          	auipc	a0,0x24
    800055d0:	eb450513          	addi	a0,a0,-332 # 80029480 <disk+0x18>
    800055d4:	927fc0ef          	jal	80001efa <wakeup>
    800055d8:	60a2                	ld	ra,8(sp)
    800055da:	6402                	ld	s0,0(sp)
    800055dc:	0141                	addi	sp,sp,16
    800055de:	8082                	ret
    800055e0:	00002517          	auipc	a0,0x2
    800055e4:	15050513          	addi	a0,a0,336 # 80007730 <etext+0x730>
    800055e8:	9acfb0ef          	jal	80000794 <panic>
    800055ec:	00002517          	auipc	a0,0x2
    800055f0:	15450513          	addi	a0,a0,340 # 80007740 <etext+0x740>
    800055f4:	9a0fb0ef          	jal	80000794 <panic>

00000000800055f8 <virtio_disk_init>:
    800055f8:	1101                	addi	sp,sp,-32
    800055fa:	ec06                	sd	ra,24(sp)
    800055fc:	e822                	sd	s0,16(sp)
    800055fe:	e426                	sd	s1,8(sp)
    80005600:	e04a                	sd	s2,0(sp)
    80005602:	1000                	addi	s0,sp,32
    80005604:	00002597          	auipc	a1,0x2
    80005608:	14c58593          	addi	a1,a1,332 # 80007750 <etext+0x750>
    8000560c:	00024517          	auipc	a0,0x24
    80005610:	f8450513          	addi	a0,a0,-124 # 80029590 <disk+0x128>
    80005614:	d60fb0ef          	jal	80000b74 <initlock>
    80005618:	100017b7          	lui	a5,0x10001
    8000561c:	4398                	lw	a4,0(a5)
    8000561e:	2701                	sext.w	a4,a4
    80005620:	747277b7          	lui	a5,0x74727
    80005624:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005628:	18f71063          	bne	a4,a5,800057a8 <virtio_disk_init+0x1b0>
    8000562c:	100017b7          	lui	a5,0x10001
    80005630:	0791                	addi	a5,a5,4 # 10001004 <_entry-0x6fffeffc>
    80005632:	439c                	lw	a5,0(a5)
    80005634:	2781                	sext.w	a5,a5
    80005636:	4709                	li	a4,2
    80005638:	16e79863          	bne	a5,a4,800057a8 <virtio_disk_init+0x1b0>
    8000563c:	100017b7          	lui	a5,0x10001
    80005640:	07a1                	addi	a5,a5,8 # 10001008 <_entry-0x6fffeff8>
    80005642:	439c                	lw	a5,0(a5)
    80005644:	2781                	sext.w	a5,a5
    80005646:	16e79163          	bne	a5,a4,800057a8 <virtio_disk_init+0x1b0>
    8000564a:	100017b7          	lui	a5,0x10001
    8000564e:	47d8                	lw	a4,12(a5)
    80005650:	2701                	sext.w	a4,a4
    80005652:	554d47b7          	lui	a5,0x554d4
    80005656:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000565a:	14f71763          	bne	a4,a5,800057a8 <virtio_disk_init+0x1b0>
    8000565e:	100017b7          	lui	a5,0x10001
    80005662:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
    80005666:	4705                	li	a4,1
    80005668:	dbb8                	sw	a4,112(a5)
    8000566a:	470d                	li	a4,3
    8000566c:	dbb8                	sw	a4,112(a5)
    8000566e:	10001737          	lui	a4,0x10001
    80005672:	4b14                	lw	a3,16(a4)
    80005674:	c7ffe737          	lui	a4,0xc7ffe
    80005678:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd51b7>
    8000567c:	8ef9                	and	a3,a3,a4
    8000567e:	10001737          	lui	a4,0x10001
    80005682:	d314                	sw	a3,32(a4)
    80005684:	472d                	li	a4,11
    80005686:	dbb8                	sw	a4,112(a5)
    80005688:	07078793          	addi	a5,a5,112
    8000568c:	439c                	lw	a5,0(a5)
    8000568e:	0007891b          	sext.w	s2,a5
    80005692:	8ba1                	andi	a5,a5,8
    80005694:	12078063          	beqz	a5,800057b4 <virtio_disk_init+0x1bc>
    80005698:	100017b7          	lui	a5,0x10001
    8000569c:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
    800056a0:	100017b7          	lui	a5,0x10001
    800056a4:	04478793          	addi	a5,a5,68 # 10001044 <_entry-0x6fffefbc>
    800056a8:	439c                	lw	a5,0(a5)
    800056aa:	2781                	sext.w	a5,a5
    800056ac:	10079a63          	bnez	a5,800057c0 <virtio_disk_init+0x1c8>
    800056b0:	100017b7          	lui	a5,0x10001
    800056b4:	03478793          	addi	a5,a5,52 # 10001034 <_entry-0x6fffefcc>
    800056b8:	439c                	lw	a5,0(a5)
    800056ba:	2781                	sext.w	a5,a5
    800056bc:	10078863          	beqz	a5,800057cc <virtio_disk_init+0x1d4>
    800056c0:	471d                	li	a4,7
    800056c2:	10f77b63          	bgeu	a4,a5,800057d8 <virtio_disk_init+0x1e0>
    800056c6:	c5efb0ef          	jal	80000b24 <kalloc>
    800056ca:	00024497          	auipc	s1,0x24
    800056ce:	d9e48493          	addi	s1,s1,-610 # 80029468 <disk>
    800056d2:	e088                	sd	a0,0(s1)
    800056d4:	c50fb0ef          	jal	80000b24 <kalloc>
    800056d8:	e488                	sd	a0,8(s1)
    800056da:	c4afb0ef          	jal	80000b24 <kalloc>
    800056de:	87aa                	mv	a5,a0
    800056e0:	e888                	sd	a0,16(s1)
    800056e2:	6088                	ld	a0,0(s1)
    800056e4:	10050063          	beqz	a0,800057e4 <virtio_disk_init+0x1ec>
    800056e8:	00024717          	auipc	a4,0x24
    800056ec:	d8873703          	ld	a4,-632(a4) # 80029470 <disk+0x8>
    800056f0:	0e070a63          	beqz	a4,800057e4 <virtio_disk_init+0x1ec>
    800056f4:	0e078863          	beqz	a5,800057e4 <virtio_disk_init+0x1ec>
    800056f8:	6605                	lui	a2,0x1
    800056fa:	4581                	li	a1,0
    800056fc:	dccfb0ef          	jal	80000cc8 <memset>
    80005700:	00024497          	auipc	s1,0x24
    80005704:	d6848493          	addi	s1,s1,-664 # 80029468 <disk>
    80005708:	6605                	lui	a2,0x1
    8000570a:	4581                	li	a1,0
    8000570c:	6488                	ld	a0,8(s1)
    8000570e:	dbafb0ef          	jal	80000cc8 <memset>
    80005712:	6605                	lui	a2,0x1
    80005714:	4581                	li	a1,0
    80005716:	6888                	ld	a0,16(s1)
    80005718:	db0fb0ef          	jal	80000cc8 <memset>
    8000571c:	100017b7          	lui	a5,0x10001
    80005720:	4721                	li	a4,8
    80005722:	df98                	sw	a4,56(a5)
    80005724:	4098                	lw	a4,0(s1)
    80005726:	100017b7          	lui	a5,0x10001
    8000572a:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
    8000572e:	40d8                	lw	a4,4(s1)
    80005730:	100017b7          	lui	a5,0x10001
    80005734:	08e7a223          	sw	a4,132(a5) # 10001084 <_entry-0x6fffef7c>
    80005738:	649c                	ld	a5,8(s1)
    8000573a:	0007869b          	sext.w	a3,a5
    8000573e:	10001737          	lui	a4,0x10001
    80005742:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
    80005746:	9781                	srai	a5,a5,0x20
    80005748:	10001737          	lui	a4,0x10001
    8000574c:	08f72a23          	sw	a5,148(a4) # 10001094 <_entry-0x6fffef6c>
    80005750:	689c                	ld	a5,16(s1)
    80005752:	0007869b          	sext.w	a3,a5
    80005756:	10001737          	lui	a4,0x10001
    8000575a:	0ad72023          	sw	a3,160(a4) # 100010a0 <_entry-0x6fffef60>
    8000575e:	9781                	srai	a5,a5,0x20
    80005760:	10001737          	lui	a4,0x10001
    80005764:	0af72223          	sw	a5,164(a4) # 100010a4 <_entry-0x6fffef5c>
    80005768:	10001737          	lui	a4,0x10001
    8000576c:	4785                	li	a5,1
    8000576e:	c37c                	sw	a5,68(a4)
    80005770:	00f48c23          	sb	a5,24(s1)
    80005774:	00f48ca3          	sb	a5,25(s1)
    80005778:	00f48d23          	sb	a5,26(s1)
    8000577c:	00f48da3          	sb	a5,27(s1)
    80005780:	00f48e23          	sb	a5,28(s1)
    80005784:	00f48ea3          	sb	a5,29(s1)
    80005788:	00f48f23          	sb	a5,30(s1)
    8000578c:	00f48fa3          	sb	a5,31(s1)
    80005790:	00496913          	ori	s2,s2,4
    80005794:	100017b7          	lui	a5,0x10001
    80005798:	0727a823          	sw	s2,112(a5) # 10001070 <_entry-0x6fffef90>
    8000579c:	60e2                	ld	ra,24(sp)
    8000579e:	6442                	ld	s0,16(sp)
    800057a0:	64a2                	ld	s1,8(sp)
    800057a2:	6902                	ld	s2,0(sp)
    800057a4:	6105                	addi	sp,sp,32
    800057a6:	8082                	ret
    800057a8:	00002517          	auipc	a0,0x2
    800057ac:	fb850513          	addi	a0,a0,-72 # 80007760 <etext+0x760>
    800057b0:	fe5fa0ef          	jal	80000794 <panic>
    800057b4:	00002517          	auipc	a0,0x2
    800057b8:	fcc50513          	addi	a0,a0,-52 # 80007780 <etext+0x780>
    800057bc:	fd9fa0ef          	jal	80000794 <panic>
    800057c0:	00002517          	auipc	a0,0x2
    800057c4:	fe050513          	addi	a0,a0,-32 # 800077a0 <etext+0x7a0>
    800057c8:	fcdfa0ef          	jal	80000794 <panic>
    800057cc:	00002517          	auipc	a0,0x2
    800057d0:	ff450513          	addi	a0,a0,-12 # 800077c0 <etext+0x7c0>
    800057d4:	fc1fa0ef          	jal	80000794 <panic>
    800057d8:	00002517          	auipc	a0,0x2
    800057dc:	00850513          	addi	a0,a0,8 # 800077e0 <etext+0x7e0>
    800057e0:	fb5fa0ef          	jal	80000794 <panic>
    800057e4:	00002517          	auipc	a0,0x2
    800057e8:	01c50513          	addi	a0,a0,28 # 80007800 <etext+0x800>
    800057ec:	fa9fa0ef          	jal	80000794 <panic>

00000000800057f0 <virtio_disk_rw>:
    800057f0:	7159                	addi	sp,sp,-112
    800057f2:	f486                	sd	ra,104(sp)
    800057f4:	f0a2                	sd	s0,96(sp)
    800057f6:	eca6                	sd	s1,88(sp)
    800057f8:	e8ca                	sd	s2,80(sp)
    800057fa:	e4ce                	sd	s3,72(sp)
    800057fc:	e0d2                	sd	s4,64(sp)
    800057fe:	fc56                	sd	s5,56(sp)
    80005800:	f85a                	sd	s6,48(sp)
    80005802:	f45e                	sd	s7,40(sp)
    80005804:	f062                	sd	s8,32(sp)
    80005806:	ec66                	sd	s9,24(sp)
    80005808:	1880                	addi	s0,sp,112
    8000580a:	8a2a                	mv	s4,a0
    8000580c:	8bae                	mv	s7,a1
    8000580e:	00c52c83          	lw	s9,12(a0)
    80005812:	001c9c9b          	slliw	s9,s9,0x1
    80005816:	1c82                	slli	s9,s9,0x20
    80005818:	020cdc93          	srli	s9,s9,0x20
    8000581c:	00024517          	auipc	a0,0x24
    80005820:	d7450513          	addi	a0,a0,-652 # 80029590 <disk+0x128>
    80005824:	bd0fb0ef          	jal	80000bf4 <acquire>
    80005828:	4981                	li	s3,0
    8000582a:	44a1                	li	s1,8
    8000582c:	00024b17          	auipc	s6,0x24
    80005830:	c3cb0b13          	addi	s6,s6,-964 # 80029468 <disk>
    80005834:	4a8d                	li	s5,3
    80005836:	00024c17          	auipc	s8,0x24
    8000583a:	d5ac0c13          	addi	s8,s8,-678 # 80029590 <disk+0x128>
    8000583e:	a8b9                	j	8000589c <virtio_disk_rw+0xac>
    80005840:	00fb0733          	add	a4,s6,a5
    80005844:	00070c23          	sb	zero,24(a4) # 10001018 <_entry-0x6fffefe8>
    80005848:	c19c                	sw	a5,0(a1)
    8000584a:	0207c563          	bltz	a5,80005874 <virtio_disk_rw+0x84>
    8000584e:	2905                	addiw	s2,s2,1
    80005850:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80005852:	05590963          	beq	s2,s5,800058a4 <virtio_disk_rw+0xb4>
    80005856:	85b2                	mv	a1,a2
    80005858:	00024717          	auipc	a4,0x24
    8000585c:	c1070713          	addi	a4,a4,-1008 # 80029468 <disk>
    80005860:	87ce                	mv	a5,s3
    80005862:	01874683          	lbu	a3,24(a4)
    80005866:	fee9                	bnez	a3,80005840 <virtio_disk_rw+0x50>
    80005868:	2785                	addiw	a5,a5,1
    8000586a:	0705                	addi	a4,a4,1
    8000586c:	fe979be3          	bne	a5,s1,80005862 <virtio_disk_rw+0x72>
    80005870:	57fd                	li	a5,-1
    80005872:	c19c                	sw	a5,0(a1)
    80005874:	01205d63          	blez	s2,8000588e <virtio_disk_rw+0x9e>
    80005878:	f9042503          	lw	a0,-112(s0)
    8000587c:	d07ff0ef          	jal	80005582 <free_desc>
    80005880:	4785                	li	a5,1
    80005882:	0127d663          	bge	a5,s2,8000588e <virtio_disk_rw+0x9e>
    80005886:	f9442503          	lw	a0,-108(s0)
    8000588a:	cf9ff0ef          	jal	80005582 <free_desc>
    8000588e:	85e2                	mv	a1,s8
    80005890:	00024517          	auipc	a0,0x24
    80005894:	bf050513          	addi	a0,a0,-1040 # 80029480 <disk+0x18>
    80005898:	e16fc0ef          	jal	80001eae <sleep>
    8000589c:	f9040613          	addi	a2,s0,-112
    800058a0:	894e                	mv	s2,s3
    800058a2:	bf55                	j	80005856 <virtio_disk_rw+0x66>
    800058a4:	f9042503          	lw	a0,-112(s0)
    800058a8:	00451693          	slli	a3,a0,0x4
    800058ac:	00024797          	auipc	a5,0x24
    800058b0:	bbc78793          	addi	a5,a5,-1092 # 80029468 <disk>
    800058b4:	00a50713          	addi	a4,a0,10
    800058b8:	0712                	slli	a4,a4,0x4
    800058ba:	973e                	add	a4,a4,a5
    800058bc:	01703633          	snez	a2,s7
    800058c0:	c710                	sw	a2,8(a4)
    800058c2:	00072623          	sw	zero,12(a4)
    800058c6:	01973823          	sd	s9,16(a4)
    800058ca:	6398                	ld	a4,0(a5)
    800058cc:	9736                	add	a4,a4,a3
    800058ce:	0a868613          	addi	a2,a3,168
    800058d2:	963e                	add	a2,a2,a5
    800058d4:	e310                	sd	a2,0(a4)
    800058d6:	6390                	ld	a2,0(a5)
    800058d8:	00d605b3          	add	a1,a2,a3
    800058dc:	4741                	li	a4,16
    800058de:	c598                	sw	a4,8(a1)
    800058e0:	4805                	li	a6,1
    800058e2:	01059623          	sh	a6,12(a1)
    800058e6:	f9442703          	lw	a4,-108(s0)
    800058ea:	00e59723          	sh	a4,14(a1)
    800058ee:	0712                	slli	a4,a4,0x4
    800058f0:	963a                	add	a2,a2,a4
    800058f2:	058a0593          	addi	a1,s4,88
    800058f6:	e20c                	sd	a1,0(a2)
    800058f8:	0007b883          	ld	a7,0(a5)
    800058fc:	9746                	add	a4,a4,a7
    800058fe:	40000613          	li	a2,1024
    80005902:	c710                	sw	a2,8(a4)
    80005904:	001bb613          	seqz	a2,s7
    80005908:	0016161b          	slliw	a2,a2,0x1
    8000590c:	00166613          	ori	a2,a2,1
    80005910:	00c71623          	sh	a2,12(a4)
    80005914:	f9842583          	lw	a1,-104(s0)
    80005918:	00b71723          	sh	a1,14(a4)
    8000591c:	00250613          	addi	a2,a0,2
    80005920:	0612                	slli	a2,a2,0x4
    80005922:	963e                	add	a2,a2,a5
    80005924:	577d                	li	a4,-1
    80005926:	00e60823          	sb	a4,16(a2)
    8000592a:	0592                	slli	a1,a1,0x4
    8000592c:	98ae                	add	a7,a7,a1
    8000592e:	03068713          	addi	a4,a3,48
    80005932:	973e                	add	a4,a4,a5
    80005934:	00e8b023          	sd	a4,0(a7)
    80005938:	6398                	ld	a4,0(a5)
    8000593a:	972e                	add	a4,a4,a1
    8000593c:	01072423          	sw	a6,8(a4)
    80005940:	4689                	li	a3,2
    80005942:	00d71623          	sh	a3,12(a4)
    80005946:	00071723          	sh	zero,14(a4)
    8000594a:	010a2223          	sw	a6,4(s4)
    8000594e:	01463423          	sd	s4,8(a2)
    80005952:	6794                	ld	a3,8(a5)
    80005954:	0026d703          	lhu	a4,2(a3)
    80005958:	8b1d                	andi	a4,a4,7
    8000595a:	0706                	slli	a4,a4,0x1
    8000595c:	96ba                	add	a3,a3,a4
    8000595e:	00a69223          	sh	a0,4(a3)
    80005962:	0330000f          	fence	rw,rw
    80005966:	6798                	ld	a4,8(a5)
    80005968:	00275783          	lhu	a5,2(a4)
    8000596c:	2785                	addiw	a5,a5,1
    8000596e:	00f71123          	sh	a5,2(a4)
    80005972:	0330000f          	fence	rw,rw
    80005976:	100017b7          	lui	a5,0x10001
    8000597a:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>
    8000597e:	004a2783          	lw	a5,4(s4)
    80005982:	00024917          	auipc	s2,0x24
    80005986:	c0e90913          	addi	s2,s2,-1010 # 80029590 <disk+0x128>
    8000598a:	4485                	li	s1,1
    8000598c:	01079a63          	bne	a5,a6,800059a0 <virtio_disk_rw+0x1b0>
    80005990:	85ca                	mv	a1,s2
    80005992:	8552                	mv	a0,s4
    80005994:	d1afc0ef          	jal	80001eae <sleep>
    80005998:	004a2783          	lw	a5,4(s4)
    8000599c:	fe978ae3          	beq	a5,s1,80005990 <virtio_disk_rw+0x1a0>
    800059a0:	f9042903          	lw	s2,-112(s0)
    800059a4:	00290713          	addi	a4,s2,2
    800059a8:	0712                	slli	a4,a4,0x4
    800059aa:	00024797          	auipc	a5,0x24
    800059ae:	abe78793          	addi	a5,a5,-1346 # 80029468 <disk>
    800059b2:	97ba                	add	a5,a5,a4
    800059b4:	0007b423          	sd	zero,8(a5)
    800059b8:	00024997          	auipc	s3,0x24
    800059bc:	ab098993          	addi	s3,s3,-1360 # 80029468 <disk>
    800059c0:	00491713          	slli	a4,s2,0x4
    800059c4:	0009b783          	ld	a5,0(s3)
    800059c8:	97ba                	add	a5,a5,a4
    800059ca:	00c7d483          	lhu	s1,12(a5)
    800059ce:	854a                	mv	a0,s2
    800059d0:	00e7d903          	lhu	s2,14(a5)
    800059d4:	bafff0ef          	jal	80005582 <free_desc>
    800059d8:	8885                	andi	s1,s1,1
    800059da:	f0fd                	bnez	s1,800059c0 <virtio_disk_rw+0x1d0>
    800059dc:	00024517          	auipc	a0,0x24
    800059e0:	bb450513          	addi	a0,a0,-1100 # 80029590 <disk+0x128>
    800059e4:	aa8fb0ef          	jal	80000c8c <release>
    800059e8:	70a6                	ld	ra,104(sp)
    800059ea:	7406                	ld	s0,96(sp)
    800059ec:	64e6                	ld	s1,88(sp)
    800059ee:	6946                	ld	s2,80(sp)
    800059f0:	69a6                	ld	s3,72(sp)
    800059f2:	6a06                	ld	s4,64(sp)
    800059f4:	7ae2                	ld	s5,56(sp)
    800059f6:	7b42                	ld	s6,48(sp)
    800059f8:	7ba2                	ld	s7,40(sp)
    800059fa:	7c02                	ld	s8,32(sp)
    800059fc:	6ce2                	ld	s9,24(sp)
    800059fe:	6165                	addi	sp,sp,112
    80005a00:	8082                	ret

0000000080005a02 <virtio_disk_intr>:
    80005a02:	1101                	addi	sp,sp,-32
    80005a04:	ec06                	sd	ra,24(sp)
    80005a06:	e822                	sd	s0,16(sp)
    80005a08:	e426                	sd	s1,8(sp)
    80005a0a:	1000                	addi	s0,sp,32
    80005a0c:	00024497          	auipc	s1,0x24
    80005a10:	a5c48493          	addi	s1,s1,-1444 # 80029468 <disk>
    80005a14:	00024517          	auipc	a0,0x24
    80005a18:	b7c50513          	addi	a0,a0,-1156 # 80029590 <disk+0x128>
    80005a1c:	9d8fb0ef          	jal	80000bf4 <acquire>
    80005a20:	100017b7          	lui	a5,0x10001
    80005a24:	53b8                	lw	a4,96(a5)
    80005a26:	8b0d                	andi	a4,a4,3
    80005a28:	100017b7          	lui	a5,0x10001
    80005a2c:	d3f8                	sw	a4,100(a5)
    80005a2e:	0330000f          	fence	rw,rw
    80005a32:	689c                	ld	a5,16(s1)
    80005a34:	0204d703          	lhu	a4,32(s1)
    80005a38:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    80005a3c:	04f70663          	beq	a4,a5,80005a88 <virtio_disk_intr+0x86>
    80005a40:	0330000f          	fence	rw,rw
    80005a44:	6898                	ld	a4,16(s1)
    80005a46:	0204d783          	lhu	a5,32(s1)
    80005a4a:	8b9d                	andi	a5,a5,7
    80005a4c:	078e                	slli	a5,a5,0x3
    80005a4e:	97ba                	add	a5,a5,a4
    80005a50:	43dc                	lw	a5,4(a5)
    80005a52:	00278713          	addi	a4,a5,2
    80005a56:	0712                	slli	a4,a4,0x4
    80005a58:	9726                	add	a4,a4,s1
    80005a5a:	01074703          	lbu	a4,16(a4)
    80005a5e:	e321                	bnez	a4,80005a9e <virtio_disk_intr+0x9c>
    80005a60:	0789                	addi	a5,a5,2
    80005a62:	0792                	slli	a5,a5,0x4
    80005a64:	97a6                	add	a5,a5,s1
    80005a66:	6788                	ld	a0,8(a5)
    80005a68:	00052223          	sw	zero,4(a0)
    80005a6c:	c8efc0ef          	jal	80001efa <wakeup>
    80005a70:	0204d783          	lhu	a5,32(s1)
    80005a74:	2785                	addiw	a5,a5,1
    80005a76:	17c2                	slli	a5,a5,0x30
    80005a78:	93c1                	srli	a5,a5,0x30
    80005a7a:	02f49023          	sh	a5,32(s1)
    80005a7e:	6898                	ld	a4,16(s1)
    80005a80:	00275703          	lhu	a4,2(a4)
    80005a84:	faf71ee3          	bne	a4,a5,80005a40 <virtio_disk_intr+0x3e>
    80005a88:	00024517          	auipc	a0,0x24
    80005a8c:	b0850513          	addi	a0,a0,-1272 # 80029590 <disk+0x128>
    80005a90:	9fcfb0ef          	jal	80000c8c <release>
    80005a94:	60e2                	ld	ra,24(sp)
    80005a96:	6442                	ld	s0,16(sp)
    80005a98:	64a2                	ld	s1,8(sp)
    80005a9a:	6105                	addi	sp,sp,32
    80005a9c:	8082                	ret
    80005a9e:	00002517          	auipc	a0,0x2
    80005aa2:	d7a50513          	addi	a0,a0,-646 # 80007818 <etext+0x818>
    80005aa6:	ceffa0ef          	jal	80000794 <panic>
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
