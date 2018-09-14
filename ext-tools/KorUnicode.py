#-*- coding: euc-kr -*-
import sys
import re

# test string
# "\uac00\ub098\ub2e4\ub77c \uac00\ub098\ub2e4\ub77c.."

s = sys.argv[2]
print("[+] String : " + s)

tstr = ''
tchar = ''
n = 0
p = re.compile('[0-9a-fu]')


if sys.argv[1] == '1':
	for num in range(0, len(s)):
		if s[num:num+2] == '\\u':
			tchar = '0x'+s[num+2:num+6]
			try:
				tstr = tstr + chr(int(tchar,16))
			except:
				print("             " + " "*num + "[-----]")
				print("\n[+] Invalid unicode found.. Check [----]")
				exit(-1)
			n = 0
		elif n > 5:
			tstr = tstr + s[num]
		n = n + 1
else:
	for num in range(0, len(s)):
		if s[num] == ' ':
			tstr = tstr + ' '
		elif ord(s[num]) < 500:
			tstr = tstr + s[num]
		else:
			tstr = tstr + hex(ord(s[num])).replace('0x','\\u')

# print result
print("[+] Result : " + tstr)

