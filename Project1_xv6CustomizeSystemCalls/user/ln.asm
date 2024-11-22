
user/_ln:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	1000                	addi	s0,sp,32
  if(argc != 3){
   8:	478d                	li	a5,3
   a:	00f50d63          	beq	a0,a5,24 <main+0x24>
   e:	e426                	sd	s1,8(sp)
    fprintf(2, "Usage: ln old new\n");
  10:	00001597          	auipc	a1,0x1
  14:	89058593          	addi	a1,a1,-1904 # 8a0 <malloc+0xfc>
  18:	4509                	li	a0,2
  1a:	6ac000ef          	jal	6c6 <fprintf>
    exit(1);
  1e:	4505                	li	a0,1
  20:	298000ef          	jal	2b8 <exit>
  24:	e426                	sd	s1,8(sp)
  26:	84ae                	mv	s1,a1
  }
  if(link(argv[1], argv[2]) < 0)
  28:	698c                	ld	a1,16(a1)
  2a:	6488                	ld	a0,8(s1)
  2c:	2ec000ef          	jal	318 <link>
  30:	00054563          	bltz	a0,3a <main+0x3a>
    fprintf(2, "link %s %s: failed\n", argv[1], argv[2]);
  exit(0);
  34:	4501                	li	a0,0
  36:	282000ef          	jal	2b8 <exit>
    fprintf(2, "link %s %s: failed\n", argv[1], argv[2]);
  3a:	6894                	ld	a3,16(s1)
  3c:	6490                	ld	a2,8(s1)
  3e:	00001597          	auipc	a1,0x1
  42:	87a58593          	addi	a1,a1,-1926 # 8b8 <malloc+0x114>
  46:	4509                	li	a0,2
  48:	67e000ef          	jal	6c6 <fprintf>
  4c:	b7e5                	j	34 <main+0x34>

000000000000004e <start>:
  4e:	1141                	addi	sp,sp,-16
  50:	e406                	sd	ra,8(sp)
  52:	e022                	sd	s0,0(sp)
  54:	0800                	addi	s0,sp,16
  56:	fabff0ef          	jal	0 <main>
  5a:	4501                	li	a0,0
  5c:	25c000ef          	jal	2b8 <exit>

0000000000000060 <strcpy>:
  60:	1141                	addi	sp,sp,-16
  62:	e422                	sd	s0,8(sp)
  64:	0800                	addi	s0,sp,16
  66:	87aa                	mv	a5,a0
  68:	0585                	addi	a1,a1,1
  6a:	0785                	addi	a5,a5,1
  6c:	fff5c703          	lbu	a4,-1(a1)
  70:	fee78fa3          	sb	a4,-1(a5)
  74:	fb75                	bnez	a4,68 <strcpy+0x8>
  76:	6422                	ld	s0,8(sp)
  78:	0141                	addi	sp,sp,16
  7a:	8082                	ret

000000000000007c <strcmp>:
  7c:	1141                	addi	sp,sp,-16
  7e:	e422                	sd	s0,8(sp)
  80:	0800                	addi	s0,sp,16
  82:	00054783          	lbu	a5,0(a0)
  86:	cb91                	beqz	a5,9a <strcmp+0x1e>
  88:	0005c703          	lbu	a4,0(a1)
  8c:	00f71763          	bne	a4,a5,9a <strcmp+0x1e>
  90:	0505                	addi	a0,a0,1
  92:	0585                	addi	a1,a1,1
  94:	00054783          	lbu	a5,0(a0)
  98:	fbe5                	bnez	a5,88 <strcmp+0xc>
  9a:	0005c503          	lbu	a0,0(a1)
  9e:	40a7853b          	subw	a0,a5,a0
  a2:	6422                	ld	s0,8(sp)
  a4:	0141                	addi	sp,sp,16
  a6:	8082                	ret

00000000000000a8 <strlen>:
  a8:	1141                	addi	sp,sp,-16
  aa:	e422                	sd	s0,8(sp)
  ac:	0800                	addi	s0,sp,16
  ae:	00054783          	lbu	a5,0(a0)
  b2:	cf91                	beqz	a5,ce <strlen+0x26>
  b4:	0505                	addi	a0,a0,1
  b6:	87aa                	mv	a5,a0
  b8:	86be                	mv	a3,a5
  ba:	0785                	addi	a5,a5,1
  bc:	fff7c703          	lbu	a4,-1(a5)
  c0:	ff65                	bnez	a4,b8 <strlen+0x10>
  c2:	40a6853b          	subw	a0,a3,a0
  c6:	2505                	addiw	a0,a0,1
  c8:	6422                	ld	s0,8(sp)
  ca:	0141                	addi	sp,sp,16
  cc:	8082                	ret
  ce:	4501                	li	a0,0
  d0:	bfe5                	j	c8 <strlen+0x20>

00000000000000d2 <memset>:
  d2:	1141                	addi	sp,sp,-16
  d4:	e422                	sd	s0,8(sp)
  d6:	0800                	addi	s0,sp,16
  d8:	ca19                	beqz	a2,ee <memset+0x1c>
  da:	87aa                	mv	a5,a0
  dc:	1602                	slli	a2,a2,0x20
  de:	9201                	srli	a2,a2,0x20
  e0:	00a60733          	add	a4,a2,a0
  e4:	00b78023          	sb	a1,0(a5)
  e8:	0785                	addi	a5,a5,1
  ea:	fee79de3          	bne	a5,a4,e4 <memset+0x12>
  ee:	6422                	ld	s0,8(sp)
  f0:	0141                	addi	sp,sp,16
  f2:	8082                	ret

00000000000000f4 <strchr>:
  f4:	1141                	addi	sp,sp,-16
  f6:	e422                	sd	s0,8(sp)
  f8:	0800                	addi	s0,sp,16
  fa:	00054783          	lbu	a5,0(a0)
  fe:	cb99                	beqz	a5,114 <strchr+0x20>
 100:	00f58763          	beq	a1,a5,10e <strchr+0x1a>
 104:	0505                	addi	a0,a0,1
 106:	00054783          	lbu	a5,0(a0)
 10a:	fbfd                	bnez	a5,100 <strchr+0xc>
 10c:	4501                	li	a0,0
 10e:	6422                	ld	s0,8(sp)
 110:	0141                	addi	sp,sp,16
 112:	8082                	ret
 114:	4501                	li	a0,0
 116:	bfe5                	j	10e <strchr+0x1a>

0000000000000118 <gets>:
 118:	711d                	addi	sp,sp,-96
 11a:	ec86                	sd	ra,88(sp)
 11c:	e8a2                	sd	s0,80(sp)
 11e:	e4a6                	sd	s1,72(sp)
 120:	e0ca                	sd	s2,64(sp)
 122:	fc4e                	sd	s3,56(sp)
 124:	f852                	sd	s4,48(sp)
 126:	f456                	sd	s5,40(sp)
 128:	f05a                	sd	s6,32(sp)
 12a:	ec5e                	sd	s7,24(sp)
 12c:	1080                	addi	s0,sp,96
 12e:	8baa                	mv	s7,a0
 130:	8a2e                	mv	s4,a1
 132:	892a                	mv	s2,a0
 134:	4481                	li	s1,0
 136:	4aa9                	li	s5,10
 138:	4b35                	li	s6,13
 13a:	89a6                	mv	s3,s1
 13c:	2485                	addiw	s1,s1,1
 13e:	0344d663          	bge	s1,s4,16a <gets+0x52>
 142:	4605                	li	a2,1
 144:	faf40593          	addi	a1,s0,-81
 148:	4501                	li	a0,0
 14a:	186000ef          	jal	2d0 <read>
 14e:	00a05e63          	blez	a0,16a <gets+0x52>
 152:	faf44783          	lbu	a5,-81(s0)
 156:	00f90023          	sb	a5,0(s2)
 15a:	01578763          	beq	a5,s5,168 <gets+0x50>
 15e:	0905                	addi	s2,s2,1
 160:	fd679de3          	bne	a5,s6,13a <gets+0x22>
 164:	89a6                	mv	s3,s1
 166:	a011                	j	16a <gets+0x52>
 168:	89a6                	mv	s3,s1
 16a:	99de                	add	s3,s3,s7
 16c:	00098023          	sb	zero,0(s3)
 170:	855e                	mv	a0,s7
 172:	60e6                	ld	ra,88(sp)
 174:	6446                	ld	s0,80(sp)
 176:	64a6                	ld	s1,72(sp)
 178:	6906                	ld	s2,64(sp)
 17a:	79e2                	ld	s3,56(sp)
 17c:	7a42                	ld	s4,48(sp)
 17e:	7aa2                	ld	s5,40(sp)
 180:	7b02                	ld	s6,32(sp)
 182:	6be2                	ld	s7,24(sp)
 184:	6125                	addi	sp,sp,96
 186:	8082                	ret

0000000000000188 <stat>:
 188:	1101                	addi	sp,sp,-32
 18a:	ec06                	sd	ra,24(sp)
 18c:	e822                	sd	s0,16(sp)
 18e:	e04a                	sd	s2,0(sp)
 190:	1000                	addi	s0,sp,32
 192:	892e                	mv	s2,a1
 194:	4581                	li	a1,0
 196:	162000ef          	jal	2f8 <open>
 19a:	02054263          	bltz	a0,1be <stat+0x36>
 19e:	e426                	sd	s1,8(sp)
 1a0:	84aa                	mv	s1,a0
 1a2:	85ca                	mv	a1,s2
 1a4:	16c000ef          	jal	310 <fstat>
 1a8:	892a                	mv	s2,a0
 1aa:	8526                	mv	a0,s1
 1ac:	134000ef          	jal	2e0 <close>
 1b0:	64a2                	ld	s1,8(sp)
 1b2:	854a                	mv	a0,s2
 1b4:	60e2                	ld	ra,24(sp)
 1b6:	6442                	ld	s0,16(sp)
 1b8:	6902                	ld	s2,0(sp)
 1ba:	6105                	addi	sp,sp,32
 1bc:	8082                	ret
 1be:	597d                	li	s2,-1
 1c0:	bfcd                	j	1b2 <stat+0x2a>

00000000000001c2 <atoi>:
 1c2:	1141                	addi	sp,sp,-16
 1c4:	e422                	sd	s0,8(sp)
 1c6:	0800                	addi	s0,sp,16
 1c8:	00054683          	lbu	a3,0(a0)
 1cc:	fd06879b          	addiw	a5,a3,-48
 1d0:	0ff7f793          	zext.b	a5,a5
 1d4:	4625                	li	a2,9
 1d6:	02f66863          	bltu	a2,a5,206 <atoi+0x44>
 1da:	872a                	mv	a4,a0
 1dc:	4501                	li	a0,0
 1de:	0705                	addi	a4,a4,1
 1e0:	0025179b          	slliw	a5,a0,0x2
 1e4:	9fa9                	addw	a5,a5,a0
 1e6:	0017979b          	slliw	a5,a5,0x1
 1ea:	9fb5                	addw	a5,a5,a3
 1ec:	fd07851b          	addiw	a0,a5,-48
 1f0:	00074683          	lbu	a3,0(a4)
 1f4:	fd06879b          	addiw	a5,a3,-48
 1f8:	0ff7f793          	zext.b	a5,a5
 1fc:	fef671e3          	bgeu	a2,a5,1de <atoi+0x1c>
 200:	6422                	ld	s0,8(sp)
 202:	0141                	addi	sp,sp,16
 204:	8082                	ret
 206:	4501                	li	a0,0
 208:	bfe5                	j	200 <atoi+0x3e>

000000000000020a <memmove>:
 20a:	1141                	addi	sp,sp,-16
 20c:	e422                	sd	s0,8(sp)
 20e:	0800                	addi	s0,sp,16
 210:	02b57463          	bgeu	a0,a1,238 <memmove+0x2e>
 214:	00c05f63          	blez	a2,232 <memmove+0x28>
 218:	1602                	slli	a2,a2,0x20
 21a:	9201                	srli	a2,a2,0x20
 21c:	00c507b3          	add	a5,a0,a2
 220:	872a                	mv	a4,a0
 222:	0585                	addi	a1,a1,1
 224:	0705                	addi	a4,a4,1
 226:	fff5c683          	lbu	a3,-1(a1)
 22a:	fed70fa3          	sb	a3,-1(a4)
 22e:	fef71ae3          	bne	a4,a5,222 <memmove+0x18>
 232:	6422                	ld	s0,8(sp)
 234:	0141                	addi	sp,sp,16
 236:	8082                	ret
 238:	00c50733          	add	a4,a0,a2
 23c:	95b2                	add	a1,a1,a2
 23e:	fec05ae3          	blez	a2,232 <memmove+0x28>
 242:	fff6079b          	addiw	a5,a2,-1
 246:	1782                	slli	a5,a5,0x20
 248:	9381                	srli	a5,a5,0x20
 24a:	fff7c793          	not	a5,a5
 24e:	97ba                	add	a5,a5,a4
 250:	15fd                	addi	a1,a1,-1
 252:	177d                	addi	a4,a4,-1
 254:	0005c683          	lbu	a3,0(a1)
 258:	00d70023          	sb	a3,0(a4)
 25c:	fee79ae3          	bne	a5,a4,250 <memmove+0x46>
 260:	bfc9                	j	232 <memmove+0x28>

0000000000000262 <memcmp>:
 262:	1141                	addi	sp,sp,-16
 264:	e422                	sd	s0,8(sp)
 266:	0800                	addi	s0,sp,16
 268:	ca05                	beqz	a2,298 <memcmp+0x36>
 26a:	fff6069b          	addiw	a3,a2,-1
 26e:	1682                	slli	a3,a3,0x20
 270:	9281                	srli	a3,a3,0x20
 272:	0685                	addi	a3,a3,1
 274:	96aa                	add	a3,a3,a0
 276:	00054783          	lbu	a5,0(a0)
 27a:	0005c703          	lbu	a4,0(a1)
 27e:	00e79863          	bne	a5,a4,28e <memcmp+0x2c>
 282:	0505                	addi	a0,a0,1
 284:	0585                	addi	a1,a1,1
 286:	fed518e3          	bne	a0,a3,276 <memcmp+0x14>
 28a:	4501                	li	a0,0
 28c:	a019                	j	292 <memcmp+0x30>
 28e:	40e7853b          	subw	a0,a5,a4
 292:	6422                	ld	s0,8(sp)
 294:	0141                	addi	sp,sp,16
 296:	8082                	ret
 298:	4501                	li	a0,0
 29a:	bfe5                	j	292 <memcmp+0x30>

000000000000029c <memcpy>:
 29c:	1141                	addi	sp,sp,-16
 29e:	e406                	sd	ra,8(sp)
 2a0:	e022                	sd	s0,0(sp)
 2a2:	0800                	addi	s0,sp,16
 2a4:	f67ff0ef          	jal	20a <memmove>
 2a8:	60a2                	ld	ra,8(sp)
 2aa:	6402                	ld	s0,0(sp)
 2ac:	0141                	addi	sp,sp,16
 2ae:	8082                	ret

00000000000002b0 <fork>:
 2b0:	4885                	li	a7,1
 2b2:	00000073          	ecall
 2b6:	8082                	ret

00000000000002b8 <exit>:
 2b8:	4889                	li	a7,2
 2ba:	00000073          	ecall
 2be:	8082                	ret

00000000000002c0 <wait>:
 2c0:	488d                	li	a7,3
 2c2:	00000073          	ecall
 2c6:	8082                	ret

00000000000002c8 <pipe>:
 2c8:	4891                	li	a7,4
 2ca:	00000073          	ecall
 2ce:	8082                	ret

00000000000002d0 <read>:
 2d0:	4895                	li	a7,5
 2d2:	00000073          	ecall
 2d6:	8082                	ret

00000000000002d8 <write>:
 2d8:	48c1                	li	a7,16
 2da:	00000073          	ecall
 2de:	8082                	ret

00000000000002e0 <close>:
 2e0:	48d5                	li	a7,21
 2e2:	00000073          	ecall
 2e6:	8082                	ret

00000000000002e8 <kill>:
 2e8:	4899                	li	a7,6
 2ea:	00000073          	ecall
 2ee:	8082                	ret

00000000000002f0 <exec>:
 2f0:	489d                	li	a7,7
 2f2:	00000073          	ecall
 2f6:	8082                	ret

00000000000002f8 <open>:
 2f8:	48bd                	li	a7,15
 2fa:	00000073          	ecall
 2fe:	8082                	ret

0000000000000300 <mknod>:
 300:	48c5                	li	a7,17
 302:	00000073          	ecall
 306:	8082                	ret

0000000000000308 <unlink>:
 308:	48c9                	li	a7,18
 30a:	00000073          	ecall
 30e:	8082                	ret

0000000000000310 <fstat>:
 310:	48a1                	li	a7,8
 312:	00000073          	ecall
 316:	8082                	ret

0000000000000318 <link>:
 318:	48cd                	li	a7,19
 31a:	00000073          	ecall
 31e:	8082                	ret

0000000000000320 <mkdir>:
 320:	48d1                	li	a7,20
 322:	00000073          	ecall
 326:	8082                	ret

0000000000000328 <chdir>:
 328:	48a5                	li	a7,9
 32a:	00000073          	ecall
 32e:	8082                	ret

0000000000000330 <dup>:
 330:	48a9                	li	a7,10
 332:	00000073          	ecall
 336:	8082                	ret

0000000000000338 <getpid>:
 338:	48ad                	li	a7,11
 33a:	00000073          	ecall
 33e:	8082                	ret

0000000000000340 <sbrk>:
 340:	48b1                	li	a7,12
 342:	00000073          	ecall
 346:	8082                	ret

0000000000000348 <sleep>:
 348:	48b5                	li	a7,13
 34a:	00000073          	ecall
 34e:	8082                	ret

0000000000000350 <uptime>:
 350:	48b9                	li	a7,14
 352:	00000073          	ecall
 356:	8082                	ret

0000000000000358 <ps>:
 358:	48d9                	li	a7,22
 35a:	00000073          	ecall
 35e:	8082                	ret

0000000000000360 <fork2>:
 360:	48dd                	li	a7,23
 362:	00000073          	ecall
 366:	8082                	ret

0000000000000368 <get_ppid>:
 368:	48e1                	li	a7,24
 36a:	00000073          	ecall
 36e:	8082                	ret

0000000000000370 <set_perm>:
 370:	48e5                	li	a7,25
 372:	00000073          	ecall
 376:	8082                	ret

0000000000000378 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 378:	1101                	addi	sp,sp,-32
 37a:	ec06                	sd	ra,24(sp)
 37c:	e822                	sd	s0,16(sp)
 37e:	1000                	addi	s0,sp,32
 380:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 384:	4605                	li	a2,1
 386:	fef40593          	addi	a1,s0,-17
 38a:	f4fff0ef          	jal	2d8 <write>
}
 38e:	60e2                	ld	ra,24(sp)
 390:	6442                	ld	s0,16(sp)
 392:	6105                	addi	sp,sp,32
 394:	8082                	ret

0000000000000396 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 396:	7139                	addi	sp,sp,-64
 398:	fc06                	sd	ra,56(sp)
 39a:	f822                	sd	s0,48(sp)
 39c:	f426                	sd	s1,40(sp)
 39e:	0080                	addi	s0,sp,64
 3a0:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 3a2:	c299                	beqz	a3,3a8 <printint+0x12>
 3a4:	0805c963          	bltz	a1,436 <printint+0xa0>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 3a8:	2581                	sext.w	a1,a1
  neg = 0;
 3aa:	4881                	li	a7,0
 3ac:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 3b0:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 3b2:	2601                	sext.w	a2,a2
 3b4:	00000517          	auipc	a0,0x0
 3b8:	52450513          	addi	a0,a0,1316 # 8d8 <digits>
 3bc:	883a                	mv	a6,a4
 3be:	2705                	addiw	a4,a4,1
 3c0:	02c5f7bb          	remuw	a5,a1,a2
 3c4:	1782                	slli	a5,a5,0x20
 3c6:	9381                	srli	a5,a5,0x20
 3c8:	97aa                	add	a5,a5,a0
 3ca:	0007c783          	lbu	a5,0(a5)
 3ce:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 3d2:	0005879b          	sext.w	a5,a1
 3d6:	02c5d5bb          	divuw	a1,a1,a2
 3da:	0685                	addi	a3,a3,1
 3dc:	fec7f0e3          	bgeu	a5,a2,3bc <printint+0x26>
  if(neg)
 3e0:	00088c63          	beqz	a7,3f8 <printint+0x62>
    buf[i++] = '-';
 3e4:	fd070793          	addi	a5,a4,-48
 3e8:	00878733          	add	a4,a5,s0
 3ec:	02d00793          	li	a5,45
 3f0:	fef70823          	sb	a5,-16(a4)
 3f4:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 3f8:	02e05a63          	blez	a4,42c <printint+0x96>
 3fc:	f04a                	sd	s2,32(sp)
 3fe:	ec4e                	sd	s3,24(sp)
 400:	fc040793          	addi	a5,s0,-64
 404:	00e78933          	add	s2,a5,a4
 408:	fff78993          	addi	s3,a5,-1
 40c:	99ba                	add	s3,s3,a4
 40e:	377d                	addiw	a4,a4,-1
 410:	1702                	slli	a4,a4,0x20
 412:	9301                	srli	a4,a4,0x20
 414:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 418:	fff94583          	lbu	a1,-1(s2)
 41c:	8526                	mv	a0,s1
 41e:	f5bff0ef          	jal	378 <putc>
  while(--i >= 0)
 422:	197d                	addi	s2,s2,-1
 424:	ff391ae3          	bne	s2,s3,418 <printint+0x82>
 428:	7902                	ld	s2,32(sp)
 42a:	69e2                	ld	s3,24(sp)
}
 42c:	70e2                	ld	ra,56(sp)
 42e:	7442                	ld	s0,48(sp)
 430:	74a2                	ld	s1,40(sp)
 432:	6121                	addi	sp,sp,64
 434:	8082                	ret
    x = -xx;
 436:	40b005bb          	negw	a1,a1
    neg = 1;
 43a:	4885                	li	a7,1
    x = -xx;
 43c:	bf85                	j	3ac <printint+0x16>

000000000000043e <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 43e:	711d                	addi	sp,sp,-96
 440:	ec86                	sd	ra,88(sp)
 442:	e8a2                	sd	s0,80(sp)
 444:	e0ca                	sd	s2,64(sp)
 446:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 448:	0005c903          	lbu	s2,0(a1)
 44c:	26090863          	beqz	s2,6bc <vprintf+0x27e>
 450:	e4a6                	sd	s1,72(sp)
 452:	fc4e                	sd	s3,56(sp)
 454:	f852                	sd	s4,48(sp)
 456:	f456                	sd	s5,40(sp)
 458:	f05a                	sd	s6,32(sp)
 45a:	ec5e                	sd	s7,24(sp)
 45c:	e862                	sd	s8,16(sp)
 45e:	e466                	sd	s9,8(sp)
 460:	8b2a                	mv	s6,a0
 462:	8a2e                	mv	s4,a1
 464:	8bb2                	mv	s7,a2
  state = 0;
 466:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 468:	4481                	li	s1,0
 46a:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 46c:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 470:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 474:	06c00c93          	li	s9,108
 478:	a005                	j	498 <vprintf+0x5a>
        putc(fd, c0);
 47a:	85ca                	mv	a1,s2
 47c:	855a                	mv	a0,s6
 47e:	efbff0ef          	jal	378 <putc>
 482:	a019                	j	488 <vprintf+0x4a>
    } else if(state == '%'){
 484:	03598263          	beq	s3,s5,4a8 <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 488:	2485                	addiw	s1,s1,1
 48a:	8726                	mv	a4,s1
 48c:	009a07b3          	add	a5,s4,s1
 490:	0007c903          	lbu	s2,0(a5)
 494:	20090c63          	beqz	s2,6ac <vprintf+0x26e>
    c0 = fmt[i] & 0xff;
 498:	0009079b          	sext.w	a5,s2
    if(state == 0){
 49c:	fe0994e3          	bnez	s3,484 <vprintf+0x46>
      if(c0 == '%'){
 4a0:	fd579de3          	bne	a5,s5,47a <vprintf+0x3c>
        state = '%';
 4a4:	89be                	mv	s3,a5
 4a6:	b7cd                	j	488 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 4a8:	00ea06b3          	add	a3,s4,a4
 4ac:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 4b0:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 4b2:	c681                	beqz	a3,4ba <vprintf+0x7c>
 4b4:	9752                	add	a4,a4,s4
 4b6:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 4ba:	03878f63          	beq	a5,s8,4f8 <vprintf+0xba>
      } else if(c0 == 'l' && c1 == 'd'){
 4be:	05978963          	beq	a5,s9,510 <vprintf+0xd2>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 4c2:	07500713          	li	a4,117
 4c6:	0ee78363          	beq	a5,a4,5ac <vprintf+0x16e>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 4ca:	07800713          	li	a4,120
 4ce:	12e78563          	beq	a5,a4,5f8 <vprintf+0x1ba>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 4d2:	07000713          	li	a4,112
 4d6:	14e78a63          	beq	a5,a4,62a <vprintf+0x1ec>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 's'){
 4da:	07300713          	li	a4,115
 4de:	18e78a63          	beq	a5,a4,672 <vprintf+0x234>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 4e2:	02500713          	li	a4,37
 4e6:	04e79563          	bne	a5,a4,530 <vprintf+0xf2>
        putc(fd, '%');
 4ea:	02500593          	li	a1,37
 4ee:	855a                	mv	a0,s6
 4f0:	e89ff0ef          	jal	378 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
#endif
      state = 0;
 4f4:	4981                	li	s3,0
 4f6:	bf49                	j	488 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 4f8:	008b8913          	addi	s2,s7,8
 4fc:	4685                	li	a3,1
 4fe:	4629                	li	a2,10
 500:	000ba583          	lw	a1,0(s7)
 504:	855a                	mv	a0,s6
 506:	e91ff0ef          	jal	396 <printint>
 50a:	8bca                	mv	s7,s2
      state = 0;
 50c:	4981                	li	s3,0
 50e:	bfad                	j	488 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 510:	06400793          	li	a5,100
 514:	02f68963          	beq	a3,a5,546 <vprintf+0x108>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 518:	06c00793          	li	a5,108
 51c:	04f68263          	beq	a3,a5,560 <vprintf+0x122>
      } else if(c0 == 'l' && c1 == 'u'){
 520:	07500793          	li	a5,117
 524:	0af68063          	beq	a3,a5,5c4 <vprintf+0x186>
      } else if(c0 == 'l' && c1 == 'x'){
 528:	07800793          	li	a5,120
 52c:	0ef68263          	beq	a3,a5,610 <vprintf+0x1d2>
        putc(fd, '%');
 530:	02500593          	li	a1,37
 534:	855a                	mv	a0,s6
 536:	e43ff0ef          	jal	378 <putc>
        putc(fd, c0);
 53a:	85ca                	mv	a1,s2
 53c:	855a                	mv	a0,s6
 53e:	e3bff0ef          	jal	378 <putc>
      state = 0;
 542:	4981                	li	s3,0
 544:	b791                	j	488 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 546:	008b8913          	addi	s2,s7,8
 54a:	4685                	li	a3,1
 54c:	4629                	li	a2,10
 54e:	000ba583          	lw	a1,0(s7)
 552:	855a                	mv	a0,s6
 554:	e43ff0ef          	jal	396 <printint>
        i += 1;
 558:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 55a:	8bca                	mv	s7,s2
      state = 0;
 55c:	4981                	li	s3,0
        i += 1;
 55e:	b72d                	j	488 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 560:	06400793          	li	a5,100
 564:	02f60763          	beq	a2,a5,592 <vprintf+0x154>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 568:	07500793          	li	a5,117
 56c:	06f60963          	beq	a2,a5,5de <vprintf+0x1a0>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 570:	07800793          	li	a5,120
 574:	faf61ee3          	bne	a2,a5,530 <vprintf+0xf2>
        printint(fd, va_arg(ap, uint64), 16, 0);
 578:	008b8913          	addi	s2,s7,8
 57c:	4681                	li	a3,0
 57e:	4641                	li	a2,16
 580:	000ba583          	lw	a1,0(s7)
 584:	855a                	mv	a0,s6
 586:	e11ff0ef          	jal	396 <printint>
        i += 2;
 58a:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 58c:	8bca                	mv	s7,s2
      state = 0;
 58e:	4981                	li	s3,0
        i += 2;
 590:	bde5                	j	488 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 592:	008b8913          	addi	s2,s7,8
 596:	4685                	li	a3,1
 598:	4629                	li	a2,10
 59a:	000ba583          	lw	a1,0(s7)
 59e:	855a                	mv	a0,s6
 5a0:	df7ff0ef          	jal	396 <printint>
        i += 2;
 5a4:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 5a6:	8bca                	mv	s7,s2
      state = 0;
 5a8:	4981                	li	s3,0
        i += 2;
 5aa:	bdf9                	j	488 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 0);
 5ac:	008b8913          	addi	s2,s7,8
 5b0:	4681                	li	a3,0
 5b2:	4629                	li	a2,10
 5b4:	000ba583          	lw	a1,0(s7)
 5b8:	855a                	mv	a0,s6
 5ba:	dddff0ef          	jal	396 <printint>
 5be:	8bca                	mv	s7,s2
      state = 0;
 5c0:	4981                	li	s3,0
 5c2:	b5d9                	j	488 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5c4:	008b8913          	addi	s2,s7,8
 5c8:	4681                	li	a3,0
 5ca:	4629                	li	a2,10
 5cc:	000ba583          	lw	a1,0(s7)
 5d0:	855a                	mv	a0,s6
 5d2:	dc5ff0ef          	jal	396 <printint>
        i += 1;
 5d6:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 5d8:	8bca                	mv	s7,s2
      state = 0;
 5da:	4981                	li	s3,0
        i += 1;
 5dc:	b575                	j	488 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5de:	008b8913          	addi	s2,s7,8
 5e2:	4681                	li	a3,0
 5e4:	4629                	li	a2,10
 5e6:	000ba583          	lw	a1,0(s7)
 5ea:	855a                	mv	a0,s6
 5ec:	dabff0ef          	jal	396 <printint>
        i += 2;
 5f0:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 5f2:	8bca                	mv	s7,s2
      state = 0;
 5f4:	4981                	li	s3,0
        i += 2;
 5f6:	bd49                	j	488 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 16, 0);
 5f8:	008b8913          	addi	s2,s7,8
 5fc:	4681                	li	a3,0
 5fe:	4641                	li	a2,16
 600:	000ba583          	lw	a1,0(s7)
 604:	855a                	mv	a0,s6
 606:	d91ff0ef          	jal	396 <printint>
 60a:	8bca                	mv	s7,s2
      state = 0;
 60c:	4981                	li	s3,0
 60e:	bdad                	j	488 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 610:	008b8913          	addi	s2,s7,8
 614:	4681                	li	a3,0
 616:	4641                	li	a2,16
 618:	000ba583          	lw	a1,0(s7)
 61c:	855a                	mv	a0,s6
 61e:	d79ff0ef          	jal	396 <printint>
        i += 1;
 622:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 624:	8bca                	mv	s7,s2
      state = 0;
 626:	4981                	li	s3,0
        i += 1;
 628:	b585                	j	488 <vprintf+0x4a>
 62a:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 62c:	008b8d13          	addi	s10,s7,8
 630:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 634:	03000593          	li	a1,48
 638:	855a                	mv	a0,s6
 63a:	d3fff0ef          	jal	378 <putc>
  putc(fd, 'x');
 63e:	07800593          	li	a1,120
 642:	855a                	mv	a0,s6
 644:	d35ff0ef          	jal	378 <putc>
 648:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 64a:	00000b97          	auipc	s7,0x0
 64e:	28eb8b93          	addi	s7,s7,654 # 8d8 <digits>
 652:	03c9d793          	srli	a5,s3,0x3c
 656:	97de                	add	a5,a5,s7
 658:	0007c583          	lbu	a1,0(a5)
 65c:	855a                	mv	a0,s6
 65e:	d1bff0ef          	jal	378 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 662:	0992                	slli	s3,s3,0x4
 664:	397d                	addiw	s2,s2,-1
 666:	fe0916e3          	bnez	s2,652 <vprintf+0x214>
        printptr(fd, va_arg(ap, uint64));
 66a:	8bea                	mv	s7,s10
      state = 0;
 66c:	4981                	li	s3,0
 66e:	6d02                	ld	s10,0(sp)
 670:	bd21                	j	488 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 672:	008b8993          	addi	s3,s7,8
 676:	000bb903          	ld	s2,0(s7)
 67a:	00090f63          	beqz	s2,698 <vprintf+0x25a>
        for(; *s; s++)
 67e:	00094583          	lbu	a1,0(s2)
 682:	c195                	beqz	a1,6a6 <vprintf+0x268>
          putc(fd, *s);
 684:	855a                	mv	a0,s6
 686:	cf3ff0ef          	jal	378 <putc>
        for(; *s; s++)
 68a:	0905                	addi	s2,s2,1
 68c:	00094583          	lbu	a1,0(s2)
 690:	f9f5                	bnez	a1,684 <vprintf+0x246>
        if((s = va_arg(ap, char*)) == 0)
 692:	8bce                	mv	s7,s3
      state = 0;
 694:	4981                	li	s3,0
 696:	bbcd                	j	488 <vprintf+0x4a>
          s = "(null)";
 698:	00000917          	auipc	s2,0x0
 69c:	23890913          	addi	s2,s2,568 # 8d0 <malloc+0x12c>
        for(; *s; s++)
 6a0:	02800593          	li	a1,40
 6a4:	b7c5                	j	684 <vprintf+0x246>
        if((s = va_arg(ap, char*)) == 0)
 6a6:	8bce                	mv	s7,s3
      state = 0;
 6a8:	4981                	li	s3,0
 6aa:	bbf9                	j	488 <vprintf+0x4a>
 6ac:	64a6                	ld	s1,72(sp)
 6ae:	79e2                	ld	s3,56(sp)
 6b0:	7a42                	ld	s4,48(sp)
 6b2:	7aa2                	ld	s5,40(sp)
 6b4:	7b02                	ld	s6,32(sp)
 6b6:	6be2                	ld	s7,24(sp)
 6b8:	6c42                	ld	s8,16(sp)
 6ba:	6ca2                	ld	s9,8(sp)
    }
  }
}
 6bc:	60e6                	ld	ra,88(sp)
 6be:	6446                	ld	s0,80(sp)
 6c0:	6906                	ld	s2,64(sp)
 6c2:	6125                	addi	sp,sp,96
 6c4:	8082                	ret

00000000000006c6 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 6c6:	715d                	addi	sp,sp,-80
 6c8:	ec06                	sd	ra,24(sp)
 6ca:	e822                	sd	s0,16(sp)
 6cc:	1000                	addi	s0,sp,32
 6ce:	e010                	sd	a2,0(s0)
 6d0:	e414                	sd	a3,8(s0)
 6d2:	e818                	sd	a4,16(s0)
 6d4:	ec1c                	sd	a5,24(s0)
 6d6:	03043023          	sd	a6,32(s0)
 6da:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 6de:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 6e2:	8622                	mv	a2,s0
 6e4:	d5bff0ef          	jal	43e <vprintf>
}
 6e8:	60e2                	ld	ra,24(sp)
 6ea:	6442                	ld	s0,16(sp)
 6ec:	6161                	addi	sp,sp,80
 6ee:	8082                	ret

00000000000006f0 <printf>:

void
printf(const char *fmt, ...)
{
 6f0:	711d                	addi	sp,sp,-96
 6f2:	ec06                	sd	ra,24(sp)
 6f4:	e822                	sd	s0,16(sp)
 6f6:	1000                	addi	s0,sp,32
 6f8:	e40c                	sd	a1,8(s0)
 6fa:	e810                	sd	a2,16(s0)
 6fc:	ec14                	sd	a3,24(s0)
 6fe:	f018                	sd	a4,32(s0)
 700:	f41c                	sd	a5,40(s0)
 702:	03043823          	sd	a6,48(s0)
 706:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 70a:	00840613          	addi	a2,s0,8
 70e:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 712:	85aa                	mv	a1,a0
 714:	4505                	li	a0,1
 716:	d29ff0ef          	jal	43e <vprintf>
}
 71a:	60e2                	ld	ra,24(sp)
 71c:	6442                	ld	s0,16(sp)
 71e:	6125                	addi	sp,sp,96
 720:	8082                	ret

0000000000000722 <free>:
 722:	1141                	addi	sp,sp,-16
 724:	e422                	sd	s0,8(sp)
 726:	0800                	addi	s0,sp,16
 728:	ff050693          	addi	a3,a0,-16
 72c:	00001797          	auipc	a5,0x1
 730:	8d47b783          	ld	a5,-1836(a5) # 1000 <freep>
 734:	a02d                	j	75e <free+0x3c>
 736:	4618                	lw	a4,8(a2)
 738:	9f2d                	addw	a4,a4,a1
 73a:	fee52c23          	sw	a4,-8(a0)
 73e:	6398                	ld	a4,0(a5)
 740:	6310                	ld	a2,0(a4)
 742:	a83d                	j	780 <free+0x5e>
 744:	ff852703          	lw	a4,-8(a0)
 748:	9f31                	addw	a4,a4,a2
 74a:	c798                	sw	a4,8(a5)
 74c:	ff053683          	ld	a3,-16(a0)
 750:	a091                	j	794 <free+0x72>
 752:	6398                	ld	a4,0(a5)
 754:	00e7e463          	bltu	a5,a4,75c <free+0x3a>
 758:	00e6ea63          	bltu	a3,a4,76c <free+0x4a>
 75c:	87ba                	mv	a5,a4
 75e:	fed7fae3          	bgeu	a5,a3,752 <free+0x30>
 762:	6398                	ld	a4,0(a5)
 764:	00e6e463          	bltu	a3,a4,76c <free+0x4a>
 768:	fee7eae3          	bltu	a5,a4,75c <free+0x3a>
 76c:	ff852583          	lw	a1,-8(a0)
 770:	6390                	ld	a2,0(a5)
 772:	02059813          	slli	a6,a1,0x20
 776:	01c85713          	srli	a4,a6,0x1c
 77a:	9736                	add	a4,a4,a3
 77c:	fae60de3          	beq	a2,a4,736 <free+0x14>
 780:	fec53823          	sd	a2,-16(a0)
 784:	4790                	lw	a2,8(a5)
 786:	02061593          	slli	a1,a2,0x20
 78a:	01c5d713          	srli	a4,a1,0x1c
 78e:	973e                	add	a4,a4,a5
 790:	fae68ae3          	beq	a3,a4,744 <free+0x22>
 794:	e394                	sd	a3,0(a5)
 796:	00001717          	auipc	a4,0x1
 79a:	86f73523          	sd	a5,-1942(a4) # 1000 <freep>
 79e:	6422                	ld	s0,8(sp)
 7a0:	0141                	addi	sp,sp,16
 7a2:	8082                	ret

00000000000007a4 <malloc>:
 7a4:	7139                	addi	sp,sp,-64
 7a6:	fc06                	sd	ra,56(sp)
 7a8:	f822                	sd	s0,48(sp)
 7aa:	f426                	sd	s1,40(sp)
 7ac:	ec4e                	sd	s3,24(sp)
 7ae:	0080                	addi	s0,sp,64
 7b0:	02051493          	slli	s1,a0,0x20
 7b4:	9081                	srli	s1,s1,0x20
 7b6:	04bd                	addi	s1,s1,15
 7b8:	8091                	srli	s1,s1,0x4
 7ba:	0014899b          	addiw	s3,s1,1
 7be:	0485                	addi	s1,s1,1
 7c0:	00001517          	auipc	a0,0x1
 7c4:	84053503          	ld	a0,-1984(a0) # 1000 <freep>
 7c8:	c915                	beqz	a0,7fc <malloc+0x58>
 7ca:	611c                	ld	a5,0(a0)
 7cc:	4798                	lw	a4,8(a5)
 7ce:	08977a63          	bgeu	a4,s1,862 <malloc+0xbe>
 7d2:	f04a                	sd	s2,32(sp)
 7d4:	e852                	sd	s4,16(sp)
 7d6:	e456                	sd	s5,8(sp)
 7d8:	e05a                	sd	s6,0(sp)
 7da:	8a4e                	mv	s4,s3
 7dc:	0009871b          	sext.w	a4,s3
 7e0:	6685                	lui	a3,0x1
 7e2:	00d77363          	bgeu	a4,a3,7e8 <malloc+0x44>
 7e6:	6a05                	lui	s4,0x1
 7e8:	000a0b1b          	sext.w	s6,s4
 7ec:	004a1a1b          	slliw	s4,s4,0x4
 7f0:	00001917          	auipc	s2,0x1
 7f4:	81090913          	addi	s2,s2,-2032 # 1000 <freep>
 7f8:	5afd                	li	s5,-1
 7fa:	a081                	j	83a <malloc+0x96>
 7fc:	f04a                	sd	s2,32(sp)
 7fe:	e852                	sd	s4,16(sp)
 800:	e456                	sd	s5,8(sp)
 802:	e05a                	sd	s6,0(sp)
 804:	00001797          	auipc	a5,0x1
 808:	80c78793          	addi	a5,a5,-2036 # 1010 <base>
 80c:	00000717          	auipc	a4,0x0
 810:	7ef73a23          	sd	a5,2036(a4) # 1000 <freep>
 814:	e39c                	sd	a5,0(a5)
 816:	0007a423          	sw	zero,8(a5)
 81a:	b7c1                	j	7da <malloc+0x36>
 81c:	6398                	ld	a4,0(a5)
 81e:	e118                	sd	a4,0(a0)
 820:	a8a9                	j	87a <malloc+0xd6>
 822:	01652423          	sw	s6,8(a0)
 826:	0541                	addi	a0,a0,16
 828:	efbff0ef          	jal	722 <free>
 82c:	00093503          	ld	a0,0(s2)
 830:	c12d                	beqz	a0,892 <malloc+0xee>
 832:	611c                	ld	a5,0(a0)
 834:	4798                	lw	a4,8(a5)
 836:	02977263          	bgeu	a4,s1,85a <malloc+0xb6>
 83a:	00093703          	ld	a4,0(s2)
 83e:	853e                	mv	a0,a5
 840:	fef719e3          	bne	a4,a5,832 <malloc+0x8e>
 844:	8552                	mv	a0,s4
 846:	afbff0ef          	jal	340 <sbrk>
 84a:	fd551ce3          	bne	a0,s5,822 <malloc+0x7e>
 84e:	4501                	li	a0,0
 850:	7902                	ld	s2,32(sp)
 852:	6a42                	ld	s4,16(sp)
 854:	6aa2                	ld	s5,8(sp)
 856:	6b02                	ld	s6,0(sp)
 858:	a03d                	j	886 <malloc+0xe2>
 85a:	7902                	ld	s2,32(sp)
 85c:	6a42                	ld	s4,16(sp)
 85e:	6aa2                	ld	s5,8(sp)
 860:	6b02                	ld	s6,0(sp)
 862:	fae48de3          	beq	s1,a4,81c <malloc+0x78>
 866:	4137073b          	subw	a4,a4,s3
 86a:	c798                	sw	a4,8(a5)
 86c:	02071693          	slli	a3,a4,0x20
 870:	01c6d713          	srli	a4,a3,0x1c
 874:	97ba                	add	a5,a5,a4
 876:	0137a423          	sw	s3,8(a5)
 87a:	00000717          	auipc	a4,0x0
 87e:	78a73323          	sd	a0,1926(a4) # 1000 <freep>
 882:	01078513          	addi	a0,a5,16
 886:	70e2                	ld	ra,56(sp)
 888:	7442                	ld	s0,48(sp)
 88a:	74a2                	ld	s1,40(sp)
 88c:	69e2                	ld	s3,24(sp)
 88e:	6121                	addi	sp,sp,64
 890:	8082                	ret
 892:	7902                	ld	s2,32(sp)
 894:	6a42                	ld	s4,16(sp)
 896:	6aa2                	ld	s5,8(sp)
 898:	6b02                	ld	s6,0(sp)
 89a:	b7f5                	j	886 <malloc+0xe2>
