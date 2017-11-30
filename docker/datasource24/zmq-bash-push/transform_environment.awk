#{ if (NF=8) printf("%s Host1 Reader1 5555 %s\n%s Host1 Reader1 6666 %s %s\n%s Host1 Reader1 7777 %s %s %s %s\n", $1, $2, $1, $3, $4, $1, $5, $6, $7, $8)  }
{ if (NF=5) printf("%s Host1 Reader1 66666666666666666666 L=%s\n%s Host1 Reader1 55555555555555555555 T=%s\n%s Host1 Reader1 33333333333333333333 T=%s\n%s Host1 Reader1 44444444444444444444 T=%s\n", $1, $2, $1, $3, $1, $4, $1, $5)  }
