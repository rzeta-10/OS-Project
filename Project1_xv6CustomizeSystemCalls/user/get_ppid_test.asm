
user/_get_ppid_test:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(void)
{
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
    int ppid = get_ppid();
   8:	332000ef          	jal	33a <get_ppid>
   c:	85aa                	mv	a1,a0
    printf("Parent Process ID: %d\n", ppid);
   e:	00001517          	auipc	a0,0x1
  12:	86250513          	addi	a0,a0,-1950 # 870 <malloc+0xfa>
  16:	6ac000ef          	jal	6c2 <printf>
    exit(0);
  1a:	4501                	li	a0,0
  1c:	26e000ef          	jal	28a <exit>

0000000000000020 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start()
{
  20:	1141                	addi	sp,sp,-16
  22:	e406                	sd	ra,8(sp)
  24:	e022                	sd	s0,0(sp)
  26:	0800                	addi	s0,sp,16
  extern int main();
  main();
  28:	fd9ff0ef          	jal	0 <main>
  exit(0);
  2c:	4501                	li	a0,0
  2e:	25c000ef          	jal	28a <exit>

0000000000000032 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  32:	1141                	addi	sp,sp,-16
  34:	e422                	sd	s0,8(sp)
  36:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  38:	87aa                	mv	a5,a0
  3a:	0585                	addi	a1,a1,1
  3c:	0785                	addi	a5,a5,1
  3e:	fff5c703          	lbu	a4,-1(a1)
  42:	fee78fa3          	sb	a4,-1(a5)
  46:	fb75                	bnez	a4,3a <strcpy+0x8>
    ;
  return os;
}
  48:	6422                	ld	s0,8(sp)
  4a:	0141                	addi	sp,sp,16
  4c:	8082                	ret

000000000000004e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  4e:	1141                	addi	sp,sp,-16
  50:	e422                	sd	s0,8(sp)
  52:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  54:	00054783          	lbu	a5,0(a0)
  58:	cb91                	beqz	a5,6c <strcmp+0x1e>
  5a:	0005c703          	lbu	a4,0(a1)
  5e:	00f71763          	bne	a4,a5,6c <strcmp+0x1e>
    p++, q++;
  62:	0505                	addi	a0,a0,1
  64:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  66:	00054783          	lbu	a5,0(a0)
  6a:	fbe5                	bnez	a5,5a <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  6c:	0005c503          	lbu	a0,0(a1)
}
  70:	40a7853b          	subw	a0,a5,a0
  74:	6422                	ld	s0,8(sp)
  76:	0141                	addi	sp,sp,16
  78:	8082                	ret

000000000000007a <strlen>:

uint
strlen(const char *s)
{
  7a:	1141                	addi	sp,sp,-16
  7c:	e422                	sd	s0,8(sp)
  7e:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  80:	00054783          	lbu	a5,0(a0)
  84:	cf91                	beqz	a5,a0 <strlen+0x26>
  86:	0505                	addi	a0,a0,1
  88:	87aa                	mv	a5,a0
  8a:	86be                	mv	a3,a5
  8c:	0785                	addi	a5,a5,1
  8e:	fff7c703          	lbu	a4,-1(a5)
  92:	ff65                	bnez	a4,8a <strlen+0x10>
  94:	40a6853b          	subw	a0,a3,a0
  98:	2505                	addiw	a0,a0,1
    ;
  return n;
}
  9a:	6422                	ld	s0,8(sp)
  9c:	0141                	addi	sp,sp,16
  9e:	8082                	ret
  for(n = 0; s[n]; n++)
  a0:	4501                	li	a0,0
  a2:	bfe5                	j	9a <strlen+0x20>

00000000000000a4 <memset>:

void*
memset(void *dst, int c, uint n)
{
  a4:	1141                	addi	sp,sp,-16
  a6:	e422                	sd	s0,8(sp)
  a8:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  aa:	ca19                	beqz	a2,c0 <memset+0x1c>
  ac:	87aa                	mv	a5,a0
  ae:	1602                	slli	a2,a2,0x20
  b0:	9201                	srli	a2,a2,0x20
  b2:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
  b6:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
  ba:	0785                	addi	a5,a5,1
  bc:	fee79de3          	bne	a5,a4,b6 <memset+0x12>
  }
  return dst;
}
  c0:	6422                	ld	s0,8(sp)
  c2:	0141                	addi	sp,sp,16
  c4:	8082                	ret

00000000000000c6 <strchr>:

char*
strchr(const char *s, char c)
{
  c6:	1141                	addi	sp,sp,-16
  c8:	e422                	sd	s0,8(sp)
  ca:	0800                	addi	s0,sp,16
  for(; *s; s++)
  cc:	00054783          	lbu	a5,0(a0)
  d0:	cb99                	beqz	a5,e6 <strchr+0x20>
    if(*s == c)
  d2:	00f58763          	beq	a1,a5,e0 <strchr+0x1a>
  for(; *s; s++)
  d6:	0505                	addi	a0,a0,1
  d8:	00054783          	lbu	a5,0(a0)
  dc:	fbfd                	bnez	a5,d2 <strchr+0xc>
      return (char*)s;
  return 0;
  de:	4501                	li	a0,0
}
  e0:	6422                	ld	s0,8(sp)
  e2:	0141                	addi	sp,sp,16
  e4:	8082                	ret
  return 0;
  e6:	4501                	li	a0,0
  e8:	bfe5                	j	e0 <strchr+0x1a>

00000000000000ea <gets>:

char*
gets(char *buf, int max)
{
  ea:	711d                	addi	sp,sp,-96
  ec:	ec86                	sd	ra,88(sp)
  ee:	e8a2                	sd	s0,80(sp)
  f0:	e4a6                	sd	s1,72(sp)
  f2:	e0ca                	sd	s2,64(sp)
  f4:	fc4e                	sd	s3,56(sp)
  f6:	f852                	sd	s4,48(sp)
  f8:	f456                	sd	s5,40(sp)
  fa:	f05a                	sd	s6,32(sp)
  fc:	ec5e                	sd	s7,24(sp)
  fe:	1080                	addi	s0,sp,96
 100:	8baa                	mv	s7,a0
 102:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 104:	892a                	mv	s2,a0
 106:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 108:	4aa9                	li	s5,10
 10a:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 10c:	89a6                	mv	s3,s1
 10e:	2485                	addiw	s1,s1,1
 110:	0344d663          	bge	s1,s4,13c <gets+0x52>
    cc = read(0, &c, 1);
 114:	4605                	li	a2,1
 116:	faf40593          	addi	a1,s0,-81
 11a:	4501                	li	a0,0
 11c:	186000ef          	jal	2a2 <read>
    if(cc < 1)
 120:	00a05e63          	blez	a0,13c <gets+0x52>
    buf[i++] = c;
 124:	faf44783          	lbu	a5,-81(s0)
 128:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 12c:	01578763          	beq	a5,s5,13a <gets+0x50>
 130:	0905                	addi	s2,s2,1
 132:	fd679de3          	bne	a5,s6,10c <gets+0x22>
    buf[i++] = c;
 136:	89a6                	mv	s3,s1
 138:	a011                	j	13c <gets+0x52>
 13a:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 13c:	99de                	add	s3,s3,s7
 13e:	00098023          	sb	zero,0(s3)
  return buf;
}
 142:	855e                	mv	a0,s7
 144:	60e6                	ld	ra,88(sp)
 146:	6446                	ld	s0,80(sp)
 148:	64a6                	ld	s1,72(sp)
 14a:	6906                	ld	s2,64(sp)
 14c:	79e2                	ld	s3,56(sp)
 14e:	7a42                	ld	s4,48(sp)
 150:	7aa2                	ld	s5,40(sp)
 152:	7b02                	ld	s6,32(sp)
 154:	6be2                	ld	s7,24(sp)
 156:	6125                	addi	sp,sp,96
 158:	8082                	ret

000000000000015a <stat>:

int
stat(const char *n, struct stat *st)
{
 15a:	1101                	addi	sp,sp,-32
 15c:	ec06                	sd	ra,24(sp)
 15e:	e822                	sd	s0,16(sp)
 160:	e04a                	sd	s2,0(sp)
 162:	1000                	addi	s0,sp,32
 164:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 166:	4581                	li	a1,0
 168:	162000ef          	jal	2ca <open>
  if(fd < 0)
 16c:	02054263          	bltz	a0,190 <stat+0x36>
 170:	e426                	sd	s1,8(sp)
 172:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 174:	85ca                	mv	a1,s2
 176:	16c000ef          	jal	2e2 <fstat>
 17a:	892a                	mv	s2,a0
  close(fd);
 17c:	8526                	mv	a0,s1
 17e:	134000ef          	jal	2b2 <close>
  return r;
 182:	64a2                	ld	s1,8(sp)
}
 184:	854a                	mv	a0,s2
 186:	60e2                	ld	ra,24(sp)
 188:	6442                	ld	s0,16(sp)
 18a:	6902                	ld	s2,0(sp)
 18c:	6105                	addi	sp,sp,32
 18e:	8082                	ret
    return -1;
 190:	597d                	li	s2,-1
 192:	bfcd                	j	184 <stat+0x2a>

0000000000000194 <atoi>:

int
atoi(const char *s)
{
 194:	1141                	addi	sp,sp,-16
 196:	e422                	sd	s0,8(sp)
 198:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 19a:	00054683          	lbu	a3,0(a0)
 19e:	fd06879b          	addiw	a5,a3,-48
 1a2:	0ff7f793          	zext.b	a5,a5
 1a6:	4625                	li	a2,9
 1a8:	02f66863          	bltu	a2,a5,1d8 <atoi+0x44>
 1ac:	872a                	mv	a4,a0
  n = 0;
 1ae:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 1b0:	0705                	addi	a4,a4,1
 1b2:	0025179b          	slliw	a5,a0,0x2
 1b6:	9fa9                	addw	a5,a5,a0
 1b8:	0017979b          	slliw	a5,a5,0x1
 1bc:	9fb5                	addw	a5,a5,a3
 1be:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 1c2:	00074683          	lbu	a3,0(a4)
 1c6:	fd06879b          	addiw	a5,a3,-48
 1ca:	0ff7f793          	zext.b	a5,a5
 1ce:	fef671e3          	bgeu	a2,a5,1b0 <atoi+0x1c>
  return n;
}
 1d2:	6422                	ld	s0,8(sp)
 1d4:	0141                	addi	sp,sp,16
 1d6:	8082                	ret
  n = 0;
 1d8:	4501                	li	a0,0
 1da:	bfe5                	j	1d2 <atoi+0x3e>

00000000000001dc <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 1dc:	1141                	addi	sp,sp,-16
 1de:	e422                	sd	s0,8(sp)
 1e0:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 1e2:	02b57463          	bgeu	a0,a1,20a <memmove+0x2e>
    while(n-- > 0)
 1e6:	00c05f63          	blez	a2,204 <memmove+0x28>
 1ea:	1602                	slli	a2,a2,0x20
 1ec:	9201                	srli	a2,a2,0x20
 1ee:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 1f2:	872a                	mv	a4,a0
      *dst++ = *src++;
 1f4:	0585                	addi	a1,a1,1
 1f6:	0705                	addi	a4,a4,1
 1f8:	fff5c683          	lbu	a3,-1(a1)
 1fc:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 200:	fef71ae3          	bne	a4,a5,1f4 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 204:	6422                	ld	s0,8(sp)
 206:	0141                	addi	sp,sp,16
 208:	8082                	ret
    dst += n;
 20a:	00c50733          	add	a4,a0,a2
    src += n;
 20e:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 210:	fec05ae3          	blez	a2,204 <memmove+0x28>
 214:	fff6079b          	addiw	a5,a2,-1
 218:	1782                	slli	a5,a5,0x20
 21a:	9381                	srli	a5,a5,0x20
 21c:	fff7c793          	not	a5,a5
 220:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 222:	15fd                	addi	a1,a1,-1
 224:	177d                	addi	a4,a4,-1
 226:	0005c683          	lbu	a3,0(a1)
 22a:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 22e:	fee79ae3          	bne	a5,a4,222 <memmove+0x46>
 232:	bfc9                	j	204 <memmove+0x28>

0000000000000234 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 234:	1141                	addi	sp,sp,-16
 236:	e422                	sd	s0,8(sp)
 238:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 23a:	ca05                	beqz	a2,26a <memcmp+0x36>
 23c:	fff6069b          	addiw	a3,a2,-1
 240:	1682                	slli	a3,a3,0x20
 242:	9281                	srli	a3,a3,0x20
 244:	0685                	addi	a3,a3,1
 246:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 248:	00054783          	lbu	a5,0(a0)
 24c:	0005c703          	lbu	a4,0(a1)
 250:	00e79863          	bne	a5,a4,260 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 254:	0505                	addi	a0,a0,1
    p2++;
 256:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 258:	fed518e3          	bne	a0,a3,248 <memcmp+0x14>
  }
  return 0;
 25c:	4501                	li	a0,0
 25e:	a019                	j	264 <memcmp+0x30>
      return *p1 - *p2;
 260:	40e7853b          	subw	a0,a5,a4
}
 264:	6422                	ld	s0,8(sp)
 266:	0141                	addi	sp,sp,16
 268:	8082                	ret
  return 0;
 26a:	4501                	li	a0,0
 26c:	bfe5                	j	264 <memcmp+0x30>

000000000000026e <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 26e:	1141                	addi	sp,sp,-16
 270:	e406                	sd	ra,8(sp)
 272:	e022                	sd	s0,0(sp)
 274:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 276:	f67ff0ef          	jal	1dc <memmove>
}
 27a:	60a2                	ld	ra,8(sp)
 27c:	6402                	ld	s0,0(sp)
 27e:	0141                	addi	sp,sp,16
 280:	8082                	ret

0000000000000282 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 282:	4885                	li	a7,1
 ecall
 284:	00000073          	ecall
 ret
 288:	8082                	ret

000000000000028a <exit>:
.global exit
exit:
 li a7, SYS_exit
 28a:	4889                	li	a7,2
 ecall
 28c:	00000073          	ecall
 ret
 290:	8082                	ret

0000000000000292 <wait>:
.global wait
wait:
 li a7, SYS_wait
 292:	488d                	li	a7,3
 ecall
 294:	00000073          	ecall
 ret
 298:	8082                	ret

000000000000029a <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 29a:	4891                	li	a7,4
 ecall
 29c:	00000073          	ecall
 ret
 2a0:	8082                	ret

00000000000002a2 <read>:
.global read
read:
 li a7, SYS_read
 2a2:	4895                	li	a7,5
 ecall
 2a4:	00000073          	ecall
 ret
 2a8:	8082                	ret

00000000000002aa <write>:
.global write
write:
 li a7, SYS_write
 2aa:	48c1                	li	a7,16
 ecall
 2ac:	00000073          	ecall
 ret
 2b0:	8082                	ret

00000000000002b2 <close>:
.global close
close:
 li a7, SYS_close
 2b2:	48d5                	li	a7,21
 ecall
 2b4:	00000073          	ecall
 ret
 2b8:	8082                	ret

00000000000002ba <kill>:
.global kill
kill:
 li a7, SYS_kill
 2ba:	4899                	li	a7,6
 ecall
 2bc:	00000073          	ecall
 ret
 2c0:	8082                	ret

00000000000002c2 <exec>:
.global exec
exec:
 li a7, SYS_exec
 2c2:	489d                	li	a7,7
 ecall
 2c4:	00000073          	ecall
 ret
 2c8:	8082                	ret

00000000000002ca <open>:
.global open
open:
 li a7, SYS_open
 2ca:	48bd                	li	a7,15
 ecall
 2cc:	00000073          	ecall
 ret
 2d0:	8082                	ret

00000000000002d2 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 2d2:	48c5                	li	a7,17
 ecall
 2d4:	00000073          	ecall
 ret
 2d8:	8082                	ret

00000000000002da <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 2da:	48c9                	li	a7,18
 ecall
 2dc:	00000073          	ecall
 ret
 2e0:	8082                	ret

00000000000002e2 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 2e2:	48a1                	li	a7,8
 ecall
 2e4:	00000073          	ecall
 ret
 2e8:	8082                	ret

00000000000002ea <link>:
.global link
link:
 li a7, SYS_link
 2ea:	48cd                	li	a7,19
 ecall
 2ec:	00000073          	ecall
 ret
 2f0:	8082                	ret

00000000000002f2 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 2f2:	48d1                	li	a7,20
 ecall
 2f4:	00000073          	ecall
 ret
 2f8:	8082                	ret

00000000000002fa <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 2fa:	48a5                	li	a7,9
 ecall
 2fc:	00000073          	ecall
 ret
 300:	8082                	ret

0000000000000302 <dup>:
.global dup
dup:
 li a7, SYS_dup
 302:	48a9                	li	a7,10
 ecall
 304:	00000073          	ecall
 ret
 308:	8082                	ret

000000000000030a <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 30a:	48ad                	li	a7,11
 ecall
 30c:	00000073          	ecall
 ret
 310:	8082                	ret

0000000000000312 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 312:	48b1                	li	a7,12
 ecall
 314:	00000073          	ecall
 ret
 318:	8082                	ret

000000000000031a <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 31a:	48b5                	li	a7,13
 ecall
 31c:	00000073          	ecall
 ret
 320:	8082                	ret

0000000000000322 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 322:	48b9                	li	a7,14
 ecall
 324:	00000073          	ecall
 ret
 328:	8082                	ret

000000000000032a <ps>:
.global ps
ps:
 li a7, SYS_ps
 32a:	48d9                	li	a7,22
 ecall
 32c:	00000073          	ecall
 ret
 330:	8082                	ret

0000000000000332 <fork2>:
.global fork2
fork2:
 li a7, SYS_fork2
 332:	48dd                	li	a7,23
 ecall
 334:	00000073          	ecall
 ret
 338:	8082                	ret

000000000000033a <get_ppid>:
 .global get_ppid
get_ppid:
    li a7, SYS_get_ppid
 33a:	48e1                	li	a7,24
    ecall
 33c:	00000073          	ecall
    ret
 340:	8082                	ret

0000000000000342 <set_perm>:
.global set_perm
set_perm:
    li a7, SYS_set_perm
 342:	48e5                	li	a7,25
    ecall
 344:	00000073          	ecall
    ret
 348:	8082                	ret

000000000000034a <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 34a:	1101                	addi	sp,sp,-32
 34c:	ec06                	sd	ra,24(sp)
 34e:	e822                	sd	s0,16(sp)
 350:	1000                	addi	s0,sp,32
 352:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 356:	4605                	li	a2,1
 358:	fef40593          	addi	a1,s0,-17
 35c:	f4fff0ef          	jal	2aa <write>
}
 360:	60e2                	ld	ra,24(sp)
 362:	6442                	ld	s0,16(sp)
 364:	6105                	addi	sp,sp,32
 366:	8082                	ret

0000000000000368 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 368:	7139                	addi	sp,sp,-64
 36a:	fc06                	sd	ra,56(sp)
 36c:	f822                	sd	s0,48(sp)
 36e:	f426                	sd	s1,40(sp)
 370:	0080                	addi	s0,sp,64
 372:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 374:	c299                	beqz	a3,37a <printint+0x12>
 376:	0805c963          	bltz	a1,408 <printint+0xa0>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 37a:	2581                	sext.w	a1,a1
  neg = 0;
 37c:	4881                	li	a7,0
 37e:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 382:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 384:	2601                	sext.w	a2,a2
 386:	00000517          	auipc	a0,0x0
 38a:	50a50513          	addi	a0,a0,1290 # 890 <digits>
 38e:	883a                	mv	a6,a4
 390:	2705                	addiw	a4,a4,1
 392:	02c5f7bb          	remuw	a5,a1,a2
 396:	1782                	slli	a5,a5,0x20
 398:	9381                	srli	a5,a5,0x20
 39a:	97aa                	add	a5,a5,a0
 39c:	0007c783          	lbu	a5,0(a5)
 3a0:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 3a4:	0005879b          	sext.w	a5,a1
 3a8:	02c5d5bb          	divuw	a1,a1,a2
 3ac:	0685                	addi	a3,a3,1
 3ae:	fec7f0e3          	bgeu	a5,a2,38e <printint+0x26>
  if(neg)
 3b2:	00088c63          	beqz	a7,3ca <printint+0x62>
    buf[i++] = '-';
 3b6:	fd070793          	addi	a5,a4,-48
 3ba:	00878733          	add	a4,a5,s0
 3be:	02d00793          	li	a5,45
 3c2:	fef70823          	sb	a5,-16(a4)
 3c6:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 3ca:	02e05a63          	blez	a4,3fe <printint+0x96>
 3ce:	f04a                	sd	s2,32(sp)
 3d0:	ec4e                	sd	s3,24(sp)
 3d2:	fc040793          	addi	a5,s0,-64
 3d6:	00e78933          	add	s2,a5,a4
 3da:	fff78993          	addi	s3,a5,-1
 3de:	99ba                	add	s3,s3,a4
 3e0:	377d                	addiw	a4,a4,-1
 3e2:	1702                	slli	a4,a4,0x20
 3e4:	9301                	srli	a4,a4,0x20
 3e6:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 3ea:	fff94583          	lbu	a1,-1(s2)
 3ee:	8526                	mv	a0,s1
 3f0:	f5bff0ef          	jal	34a <putc>
  while(--i >= 0)
 3f4:	197d                	addi	s2,s2,-1
 3f6:	ff391ae3          	bne	s2,s3,3ea <printint+0x82>
 3fa:	7902                	ld	s2,32(sp)
 3fc:	69e2                	ld	s3,24(sp)
}
 3fe:	70e2                	ld	ra,56(sp)
 400:	7442                	ld	s0,48(sp)
 402:	74a2                	ld	s1,40(sp)
 404:	6121                	addi	sp,sp,64
 406:	8082                	ret
    x = -xx;
 408:	40b005bb          	negw	a1,a1
    neg = 1;
 40c:	4885                	li	a7,1
    x = -xx;
 40e:	bf85                	j	37e <printint+0x16>

0000000000000410 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 410:	711d                	addi	sp,sp,-96
 412:	ec86                	sd	ra,88(sp)
 414:	e8a2                	sd	s0,80(sp)
 416:	e0ca                	sd	s2,64(sp)
 418:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 41a:	0005c903          	lbu	s2,0(a1)
 41e:	26090863          	beqz	s2,68e <vprintf+0x27e>
 422:	e4a6                	sd	s1,72(sp)
 424:	fc4e                	sd	s3,56(sp)
 426:	f852                	sd	s4,48(sp)
 428:	f456                	sd	s5,40(sp)
 42a:	f05a                	sd	s6,32(sp)
 42c:	ec5e                	sd	s7,24(sp)
 42e:	e862                	sd	s8,16(sp)
 430:	e466                	sd	s9,8(sp)
 432:	8b2a                	mv	s6,a0
 434:	8a2e                	mv	s4,a1
 436:	8bb2                	mv	s7,a2
  state = 0;
 438:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 43a:	4481                	li	s1,0
 43c:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 43e:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 442:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 446:	06c00c93          	li	s9,108
 44a:	a005                	j	46a <vprintf+0x5a>
        putc(fd, c0);
 44c:	85ca                	mv	a1,s2
 44e:	855a                	mv	a0,s6
 450:	efbff0ef          	jal	34a <putc>
 454:	a019                	j	45a <vprintf+0x4a>
    } else if(state == '%'){
 456:	03598263          	beq	s3,s5,47a <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 45a:	2485                	addiw	s1,s1,1
 45c:	8726                	mv	a4,s1
 45e:	009a07b3          	add	a5,s4,s1
 462:	0007c903          	lbu	s2,0(a5)
 466:	20090c63          	beqz	s2,67e <vprintf+0x26e>
    c0 = fmt[i] & 0xff;
 46a:	0009079b          	sext.w	a5,s2
    if(state == 0){
 46e:	fe0994e3          	bnez	s3,456 <vprintf+0x46>
      if(c0 == '%'){
 472:	fd579de3          	bne	a5,s5,44c <vprintf+0x3c>
        state = '%';
 476:	89be                	mv	s3,a5
 478:	b7cd                	j	45a <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 47a:	00ea06b3          	add	a3,s4,a4
 47e:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 482:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 484:	c681                	beqz	a3,48c <vprintf+0x7c>
 486:	9752                	add	a4,a4,s4
 488:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 48c:	03878f63          	beq	a5,s8,4ca <vprintf+0xba>
      } else if(c0 == 'l' && c1 == 'd'){
 490:	05978963          	beq	a5,s9,4e2 <vprintf+0xd2>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 494:	07500713          	li	a4,117
 498:	0ee78363          	beq	a5,a4,57e <vprintf+0x16e>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 49c:	07800713          	li	a4,120
 4a0:	12e78563          	beq	a5,a4,5ca <vprintf+0x1ba>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 4a4:	07000713          	li	a4,112
 4a8:	14e78a63          	beq	a5,a4,5fc <vprintf+0x1ec>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 's'){
 4ac:	07300713          	li	a4,115
 4b0:	18e78a63          	beq	a5,a4,644 <vprintf+0x234>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 4b4:	02500713          	li	a4,37
 4b8:	04e79563          	bne	a5,a4,502 <vprintf+0xf2>
        putc(fd, '%');
 4bc:	02500593          	li	a1,37
 4c0:	855a                	mv	a0,s6
 4c2:	e89ff0ef          	jal	34a <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
#endif
      state = 0;
 4c6:	4981                	li	s3,0
 4c8:	bf49                	j	45a <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 4ca:	008b8913          	addi	s2,s7,8
 4ce:	4685                	li	a3,1
 4d0:	4629                	li	a2,10
 4d2:	000ba583          	lw	a1,0(s7)
 4d6:	855a                	mv	a0,s6
 4d8:	e91ff0ef          	jal	368 <printint>
 4dc:	8bca                	mv	s7,s2
      state = 0;
 4de:	4981                	li	s3,0
 4e0:	bfad                	j	45a <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 4e2:	06400793          	li	a5,100
 4e6:	02f68963          	beq	a3,a5,518 <vprintf+0x108>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 4ea:	06c00793          	li	a5,108
 4ee:	04f68263          	beq	a3,a5,532 <vprintf+0x122>
      } else if(c0 == 'l' && c1 == 'u'){
 4f2:	07500793          	li	a5,117
 4f6:	0af68063          	beq	a3,a5,596 <vprintf+0x186>
      } else if(c0 == 'l' && c1 == 'x'){
 4fa:	07800793          	li	a5,120
 4fe:	0ef68263          	beq	a3,a5,5e2 <vprintf+0x1d2>
        putc(fd, '%');
 502:	02500593          	li	a1,37
 506:	855a                	mv	a0,s6
 508:	e43ff0ef          	jal	34a <putc>
        putc(fd, c0);
 50c:	85ca                	mv	a1,s2
 50e:	855a                	mv	a0,s6
 510:	e3bff0ef          	jal	34a <putc>
      state = 0;
 514:	4981                	li	s3,0
 516:	b791                	j	45a <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 518:	008b8913          	addi	s2,s7,8
 51c:	4685                	li	a3,1
 51e:	4629                	li	a2,10
 520:	000ba583          	lw	a1,0(s7)
 524:	855a                	mv	a0,s6
 526:	e43ff0ef          	jal	368 <printint>
        i += 1;
 52a:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 52c:	8bca                	mv	s7,s2
      state = 0;
 52e:	4981                	li	s3,0
        i += 1;
 530:	b72d                	j	45a <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 532:	06400793          	li	a5,100
 536:	02f60763          	beq	a2,a5,564 <vprintf+0x154>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 53a:	07500793          	li	a5,117
 53e:	06f60963          	beq	a2,a5,5b0 <vprintf+0x1a0>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 542:	07800793          	li	a5,120
 546:	faf61ee3          	bne	a2,a5,502 <vprintf+0xf2>
        printint(fd, va_arg(ap, uint64), 16, 0);
 54a:	008b8913          	addi	s2,s7,8
 54e:	4681                	li	a3,0
 550:	4641                	li	a2,16
 552:	000ba583          	lw	a1,0(s7)
 556:	855a                	mv	a0,s6
 558:	e11ff0ef          	jal	368 <printint>
        i += 2;
 55c:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 55e:	8bca                	mv	s7,s2
      state = 0;
 560:	4981                	li	s3,0
        i += 2;
 562:	bde5                	j	45a <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 564:	008b8913          	addi	s2,s7,8
 568:	4685                	li	a3,1
 56a:	4629                	li	a2,10
 56c:	000ba583          	lw	a1,0(s7)
 570:	855a                	mv	a0,s6
 572:	df7ff0ef          	jal	368 <printint>
        i += 2;
 576:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 578:	8bca                	mv	s7,s2
      state = 0;
 57a:	4981                	li	s3,0
        i += 2;
 57c:	bdf9                	j	45a <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 0);
 57e:	008b8913          	addi	s2,s7,8
 582:	4681                	li	a3,0
 584:	4629                	li	a2,10
 586:	000ba583          	lw	a1,0(s7)
 58a:	855a                	mv	a0,s6
 58c:	dddff0ef          	jal	368 <printint>
 590:	8bca                	mv	s7,s2
      state = 0;
 592:	4981                	li	s3,0
 594:	b5d9                	j	45a <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 596:	008b8913          	addi	s2,s7,8
 59a:	4681                	li	a3,0
 59c:	4629                	li	a2,10
 59e:	000ba583          	lw	a1,0(s7)
 5a2:	855a                	mv	a0,s6
 5a4:	dc5ff0ef          	jal	368 <printint>
        i += 1;
 5a8:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 5aa:	8bca                	mv	s7,s2
      state = 0;
 5ac:	4981                	li	s3,0
        i += 1;
 5ae:	b575                	j	45a <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5b0:	008b8913          	addi	s2,s7,8
 5b4:	4681                	li	a3,0
 5b6:	4629                	li	a2,10
 5b8:	000ba583          	lw	a1,0(s7)
 5bc:	855a                	mv	a0,s6
 5be:	dabff0ef          	jal	368 <printint>
        i += 2;
 5c2:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 5c4:	8bca                	mv	s7,s2
      state = 0;
 5c6:	4981                	li	s3,0
        i += 2;
 5c8:	bd49                	j	45a <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 16, 0);
 5ca:	008b8913          	addi	s2,s7,8
 5ce:	4681                	li	a3,0
 5d0:	4641                	li	a2,16
 5d2:	000ba583          	lw	a1,0(s7)
 5d6:	855a                	mv	a0,s6
 5d8:	d91ff0ef          	jal	368 <printint>
 5dc:	8bca                	mv	s7,s2
      state = 0;
 5de:	4981                	li	s3,0
 5e0:	bdad                	j	45a <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 5e2:	008b8913          	addi	s2,s7,8
 5e6:	4681                	li	a3,0
 5e8:	4641                	li	a2,16
 5ea:	000ba583          	lw	a1,0(s7)
 5ee:	855a                	mv	a0,s6
 5f0:	d79ff0ef          	jal	368 <printint>
        i += 1;
 5f4:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 5f6:	8bca                	mv	s7,s2
      state = 0;
 5f8:	4981                	li	s3,0
        i += 1;
 5fa:	b585                	j	45a <vprintf+0x4a>
 5fc:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 5fe:	008b8d13          	addi	s10,s7,8
 602:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 606:	03000593          	li	a1,48
 60a:	855a                	mv	a0,s6
 60c:	d3fff0ef          	jal	34a <putc>
  putc(fd, 'x');
 610:	07800593          	li	a1,120
 614:	855a                	mv	a0,s6
 616:	d35ff0ef          	jal	34a <putc>
 61a:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 61c:	00000b97          	auipc	s7,0x0
 620:	274b8b93          	addi	s7,s7,628 # 890 <digits>
 624:	03c9d793          	srli	a5,s3,0x3c
 628:	97de                	add	a5,a5,s7
 62a:	0007c583          	lbu	a1,0(a5)
 62e:	855a                	mv	a0,s6
 630:	d1bff0ef          	jal	34a <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 634:	0992                	slli	s3,s3,0x4
 636:	397d                	addiw	s2,s2,-1
 638:	fe0916e3          	bnez	s2,624 <vprintf+0x214>
        printptr(fd, va_arg(ap, uint64));
 63c:	8bea                	mv	s7,s10
      state = 0;
 63e:	4981                	li	s3,0
 640:	6d02                	ld	s10,0(sp)
 642:	bd21                	j	45a <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 644:	008b8993          	addi	s3,s7,8
 648:	000bb903          	ld	s2,0(s7)
 64c:	00090f63          	beqz	s2,66a <vprintf+0x25a>
        for(; *s; s++)
 650:	00094583          	lbu	a1,0(s2)
 654:	c195                	beqz	a1,678 <vprintf+0x268>
          putc(fd, *s);
 656:	855a                	mv	a0,s6
 658:	cf3ff0ef          	jal	34a <putc>
        for(; *s; s++)
 65c:	0905                	addi	s2,s2,1
 65e:	00094583          	lbu	a1,0(s2)
 662:	f9f5                	bnez	a1,656 <vprintf+0x246>
        if((s = va_arg(ap, char*)) == 0)
 664:	8bce                	mv	s7,s3
      state = 0;
 666:	4981                	li	s3,0
 668:	bbcd                	j	45a <vprintf+0x4a>
          s = "(null)";
 66a:	00000917          	auipc	s2,0x0
 66e:	21e90913          	addi	s2,s2,542 # 888 <malloc+0x112>
        for(; *s; s++)
 672:	02800593          	li	a1,40
 676:	b7c5                	j	656 <vprintf+0x246>
        if((s = va_arg(ap, char*)) == 0)
 678:	8bce                	mv	s7,s3
      state = 0;
 67a:	4981                	li	s3,0
 67c:	bbf9                	j	45a <vprintf+0x4a>
 67e:	64a6                	ld	s1,72(sp)
 680:	79e2                	ld	s3,56(sp)
 682:	7a42                	ld	s4,48(sp)
 684:	7aa2                	ld	s5,40(sp)
 686:	7b02                	ld	s6,32(sp)
 688:	6be2                	ld	s7,24(sp)
 68a:	6c42                	ld	s8,16(sp)
 68c:	6ca2                	ld	s9,8(sp)
    }
  }
}
 68e:	60e6                	ld	ra,88(sp)
 690:	6446                	ld	s0,80(sp)
 692:	6906                	ld	s2,64(sp)
 694:	6125                	addi	sp,sp,96
 696:	8082                	ret

0000000000000698 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 698:	715d                	addi	sp,sp,-80
 69a:	ec06                	sd	ra,24(sp)
 69c:	e822                	sd	s0,16(sp)
 69e:	1000                	addi	s0,sp,32
 6a0:	e010                	sd	a2,0(s0)
 6a2:	e414                	sd	a3,8(s0)
 6a4:	e818                	sd	a4,16(s0)
 6a6:	ec1c                	sd	a5,24(s0)
 6a8:	03043023          	sd	a6,32(s0)
 6ac:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 6b0:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 6b4:	8622                	mv	a2,s0
 6b6:	d5bff0ef          	jal	410 <vprintf>
}
 6ba:	60e2                	ld	ra,24(sp)
 6bc:	6442                	ld	s0,16(sp)
 6be:	6161                	addi	sp,sp,80
 6c0:	8082                	ret

00000000000006c2 <printf>:

void
printf(const char *fmt, ...)
{
 6c2:	711d                	addi	sp,sp,-96
 6c4:	ec06                	sd	ra,24(sp)
 6c6:	e822                	sd	s0,16(sp)
 6c8:	1000                	addi	s0,sp,32
 6ca:	e40c                	sd	a1,8(s0)
 6cc:	e810                	sd	a2,16(s0)
 6ce:	ec14                	sd	a3,24(s0)
 6d0:	f018                	sd	a4,32(s0)
 6d2:	f41c                	sd	a5,40(s0)
 6d4:	03043823          	sd	a6,48(s0)
 6d8:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 6dc:	00840613          	addi	a2,s0,8
 6e0:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 6e4:	85aa                	mv	a1,a0
 6e6:	4505                	li	a0,1
 6e8:	d29ff0ef          	jal	410 <vprintf>
}
 6ec:	60e2                	ld	ra,24(sp)
 6ee:	6442                	ld	s0,16(sp)
 6f0:	6125                	addi	sp,sp,96
 6f2:	8082                	ret

00000000000006f4 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6f4:	1141                	addi	sp,sp,-16
 6f6:	e422                	sd	s0,8(sp)
 6f8:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6fa:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6fe:	00001797          	auipc	a5,0x1
 702:	9027b783          	ld	a5,-1790(a5) # 1000 <freep>
 706:	a02d                	j	730 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 708:	4618                	lw	a4,8(a2)
 70a:	9f2d                	addw	a4,a4,a1
 70c:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 710:	6398                	ld	a4,0(a5)
 712:	6310                	ld	a2,0(a4)
 714:	a83d                	j	752 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 716:	ff852703          	lw	a4,-8(a0)
 71a:	9f31                	addw	a4,a4,a2
 71c:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 71e:	ff053683          	ld	a3,-16(a0)
 722:	a091                	j	766 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 724:	6398                	ld	a4,0(a5)
 726:	00e7e463          	bltu	a5,a4,72e <free+0x3a>
 72a:	00e6ea63          	bltu	a3,a4,73e <free+0x4a>
{
 72e:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 730:	fed7fae3          	bgeu	a5,a3,724 <free+0x30>
 734:	6398                	ld	a4,0(a5)
 736:	00e6e463          	bltu	a3,a4,73e <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 73a:	fee7eae3          	bltu	a5,a4,72e <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 73e:	ff852583          	lw	a1,-8(a0)
 742:	6390                	ld	a2,0(a5)
 744:	02059813          	slli	a6,a1,0x20
 748:	01c85713          	srli	a4,a6,0x1c
 74c:	9736                	add	a4,a4,a3
 74e:	fae60de3          	beq	a2,a4,708 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 752:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 756:	4790                	lw	a2,8(a5)
 758:	02061593          	slli	a1,a2,0x20
 75c:	01c5d713          	srli	a4,a1,0x1c
 760:	973e                	add	a4,a4,a5
 762:	fae68ae3          	beq	a3,a4,716 <free+0x22>
    p->s.ptr = bp->s.ptr;
 766:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 768:	00001717          	auipc	a4,0x1
 76c:	88f73c23          	sd	a5,-1896(a4) # 1000 <freep>
}
 770:	6422                	ld	s0,8(sp)
 772:	0141                	addi	sp,sp,16
 774:	8082                	ret

0000000000000776 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 776:	7139                	addi	sp,sp,-64
 778:	fc06                	sd	ra,56(sp)
 77a:	f822                	sd	s0,48(sp)
 77c:	f426                	sd	s1,40(sp)
 77e:	ec4e                	sd	s3,24(sp)
 780:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 782:	02051493          	slli	s1,a0,0x20
 786:	9081                	srli	s1,s1,0x20
 788:	04bd                	addi	s1,s1,15
 78a:	8091                	srli	s1,s1,0x4
 78c:	0014899b          	addiw	s3,s1,1
 790:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 792:	00001517          	auipc	a0,0x1
 796:	86e53503          	ld	a0,-1938(a0) # 1000 <freep>
 79a:	c915                	beqz	a0,7ce <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 79c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 79e:	4798                	lw	a4,8(a5)
 7a0:	08977a63          	bgeu	a4,s1,834 <malloc+0xbe>
 7a4:	f04a                	sd	s2,32(sp)
 7a6:	e852                	sd	s4,16(sp)
 7a8:	e456                	sd	s5,8(sp)
 7aa:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 7ac:	8a4e                	mv	s4,s3
 7ae:	0009871b          	sext.w	a4,s3
 7b2:	6685                	lui	a3,0x1
 7b4:	00d77363          	bgeu	a4,a3,7ba <malloc+0x44>
 7b8:	6a05                	lui	s4,0x1
 7ba:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 7be:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 7c2:	00001917          	auipc	s2,0x1
 7c6:	83e90913          	addi	s2,s2,-1986 # 1000 <freep>
  if(p == (char*)-1)
 7ca:	5afd                	li	s5,-1
 7cc:	a081                	j	80c <malloc+0x96>
 7ce:	f04a                	sd	s2,32(sp)
 7d0:	e852                	sd	s4,16(sp)
 7d2:	e456                	sd	s5,8(sp)
 7d4:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 7d6:	00001797          	auipc	a5,0x1
 7da:	83a78793          	addi	a5,a5,-1990 # 1010 <base>
 7de:	00001717          	auipc	a4,0x1
 7e2:	82f73123          	sd	a5,-2014(a4) # 1000 <freep>
 7e6:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 7e8:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 7ec:	b7c1                	j	7ac <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 7ee:	6398                	ld	a4,0(a5)
 7f0:	e118                	sd	a4,0(a0)
 7f2:	a8a9                	j	84c <malloc+0xd6>
  hp->s.size = nu;
 7f4:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 7f8:	0541                	addi	a0,a0,16
 7fa:	efbff0ef          	jal	6f4 <free>
  return freep;
 7fe:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 802:	c12d                	beqz	a0,864 <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 804:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 806:	4798                	lw	a4,8(a5)
 808:	02977263          	bgeu	a4,s1,82c <malloc+0xb6>
    if(p == freep)
 80c:	00093703          	ld	a4,0(s2)
 810:	853e                	mv	a0,a5
 812:	fef719e3          	bne	a4,a5,804 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 816:	8552                	mv	a0,s4
 818:	afbff0ef          	jal	312 <sbrk>
  if(p == (char*)-1)
 81c:	fd551ce3          	bne	a0,s5,7f4 <malloc+0x7e>
        return 0;
 820:	4501                	li	a0,0
 822:	7902                	ld	s2,32(sp)
 824:	6a42                	ld	s4,16(sp)
 826:	6aa2                	ld	s5,8(sp)
 828:	6b02                	ld	s6,0(sp)
 82a:	a03d                	j	858 <malloc+0xe2>
 82c:	7902                	ld	s2,32(sp)
 82e:	6a42                	ld	s4,16(sp)
 830:	6aa2                	ld	s5,8(sp)
 832:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 834:	fae48de3          	beq	s1,a4,7ee <malloc+0x78>
        p->s.size -= nunits;
 838:	4137073b          	subw	a4,a4,s3
 83c:	c798                	sw	a4,8(a5)
        p += p->s.size;
 83e:	02071693          	slli	a3,a4,0x20
 842:	01c6d713          	srli	a4,a3,0x1c
 846:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 848:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 84c:	00000717          	auipc	a4,0x0
 850:	7aa73a23          	sd	a0,1972(a4) # 1000 <freep>
      return (void*)(p + 1);
 854:	01078513          	addi	a0,a5,16
  }
}
 858:	70e2                	ld	ra,56(sp)
 85a:	7442                	ld	s0,48(sp)
 85c:	74a2                	ld	s1,40(sp)
 85e:	69e2                	ld	s3,24(sp)
 860:	6121                	addi	sp,sp,64
 862:	8082                	ret
 864:	7902                	ld	s2,32(sp)
 866:	6a42                	ld	s4,16(sp)
 868:	6aa2                	ld	s5,8(sp)
 86a:	6b02                	ld	s6,0(sp)
 86c:	b7f5                	j	858 <malloc+0xe2>
