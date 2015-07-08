# http://www.nongnu.org/avr-libc/user-manual/group__demo__project.html
# Modified by zhiyb (Yubo Zhi) - For Qt

PRG	= BoardGame
SRC	= main.cpp mainw.cpp board.cpp boardgame.cpp gomoku.cpp tictactoe.cpp reversi.cpp gomoku3.cpp connect4.cpp minesweeper.cpp #game2048.cpp
MOCH	= mainw.h board.h boardgame.h gomoku.h tictactoe.h reversi.h gomoku3.h connect4.h minesweeper.h #game2048.h
SUBDIRS = 
VERSION	= 0.0.1

#CROSS	= mipsel-linux-
OPTIMIZE	= -Os
STRIP	= true
DEFS	= -DQWS -pipe -fno-exceptions -fno-rtti -Wall -Wno-non-virtual-dtor -Werror
LIBS	= -Wl,-rpath,/opt/qt-2.3.10.new/lib -lqpe -lqte

#QTDIR	= /root/qt/qt-2.3.10.mipsel
#QPEDIR	= /root/qt/qtopia-free-1.5.0.mipsel
QTINC	= $(QTDIR)/include
QPEINC	= $(QPEDIR)/include
QTLIB	= $(QTDIR)/lib
QPELIB	= $(QPEDIR)/lib

# You should not have to change anything below here.

TS	= $(PRG).ts
QM	= $(PRG).qm
LOG	= $(PRG).log
MOCC	= $(addprefix moc_,$(subst .h,.cpp,$(MOCH)))
OBJ	= $(subst .cpp,.o,$(SRC) $(MOCC))

CC	= $(CROSS)g++
LN	= $(CROSS)g++
STRIP	+= && $(CROSS)strip
MOC	= $(QTDIR)/bin/moc
LUPDATE	= lupdate
LRELEASE	= lrelease

CFLAGS	= -g -c $(DEFS) $(OPTIMIZE) -I$(QTINC) -I$(QPEINC)
LDFLAGS	= -g $(LIBS) -L$(QTLIB) -L$(QPELIB)

all: subdirs $(MOCC) $(PRG)

$(MOCC): moc_%.cpp: %.h
	$(MOC) -o $@ $<

$(PRG): $(OBJ)
	$(LN) $(LDFLAGS) -o $@ $^
	$(STRIP) $@ || true
	echo $(shell date '+%Y-%m-%d %H:%M:%S'), $(LN), $@ >> $(LOG)

$(TS):
	$(LUPDATE) $(SRC) $(MOCH) -ts $@

EXTRA_CLEAN_FILES	+= $(QM)
$(QM): $(TS)
	$(LRELEASE) $^ -qm $@

%.o: %.cpp
	$(CC) $(CFLAGS) -o $@ $<

# Subdirectories

.PHONY: subdirs $(SUBDIRS)
subdirs: $(SUBDIRS)

$(SUBDIRS):
	$(MAKE) -C $@

# Dependency:

-include $(OBJ:.o=.d)

%.d: %.cpp
	@set -e; rm -f $@; \
	$(CC) -MM $(CFLAGS) $< > $@.$$$$; \
	sed 's,\($*\)\.o[ :]*,\1.o $@ : ,g' < $@.$$$$ > $@; \
	rm -f $@.$$$$

# Clean up

.PHONY: clean
clean:
	for d in $(SUBDIRS); do (cd $$d; $(MAKE) clean); done
	rm -rf $(OBJ) $(MOCC) *.d *.d.* $(PRG) $(EXTRA_CLEAN_FILES)

# Publish: source code & hex target archive

TAR	= tar
TARFLAGS	= -jc
ARCHIVE	= $(PRG)-$(VERSION).tar.bz2
EXTRA_CLEAN_FILES	+= $(ARCHIVE)

.PHONY: archive
archive: $(ARCHIVE)

$(ARCHIVE): $(PRG)
	$(TAR) $(TARFLAGS) -f $(ARCHIVE) $(SRC) $(MOCH) *.h $(PRG) Makefile

.PHONY: run
run: all
	./$(PRG)
