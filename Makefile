CC=gcc
CFLAGS=-lfl -g
EXEC=compilador
LIB_C_FILES=struct/symbol.c struct/object.c struct/list.c struct/stack.c

INPUT_SYN=sintatico.y
INPUT_LEX=lexico.l

OUTPUT_SYN=_sintatico
OUTPUT_SYN_C=${OUTPUT_SYN}.c
OUTPUT_SYN_H=${OUTPUT_SYN}.h
OUTPUT_LEX_C=_lexico.c

OUTFILES=${OUTPUT_LEX_C} ${OUTPUT_SYN_C}
CFILES=${LIB_C_FILES} ${OUTFILES}

all:
	bison -v -t -y -d -o ${OUTPUT_SYN_C} ${INPUT_SYN}
	flex --outfile ${OUTPUT_LEX_C} ${INPUT_LEX}
	${CC} ${CFILES} -o ${EXEC} ${CFLAGS}
	chmod a+x ${EXEC}

test: all
	bash test.sh

clean:
	rm -rf ${OUTFILES} ${OUTPUT_SYN_H} *~ ${EXEC}
