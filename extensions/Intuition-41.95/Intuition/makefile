# Makefile for Intuition Extension

VERSION = 1.3b

PROPATH = DH1:APSystem/
CREPATH = DH1:AMOS_System/

# Sources for the main extension code.  Don't fool with the order or you'll
# regret it!
INTSRC0 = iheader.s itokens.s intuition.s extutils.s screens.s color.s \
	windows.s fonts.s input.s errorstubs.s text.s graphics.s request.s \
	menus.s gadgets.s other.s extcode.s errors.s

INTSRC = %(INTSRC0:*:src/%1)

# Object files for external code segment.  jumptable.o must be first!
EXTOBJ=	obj/jumptable.o	\
	obj/amosfuncs.o	obj/errors.o	obj/graphics.o	obj/input.o	\
	obj/intmisc.o	obj/iutils.o	obj/memory.o	obj/screens.o	\
	obj/startup.o	obj/windows.o
EXTOBJ_C = %(EXTOBJ:obj/*:obj/creator/%1)
EXTSRC = %(EXTOBJ:obj/*.o:src2/%1.s)
EXTERNAL = obj/extcode
EXTERNAL_C = obj/creator/extcode

# Object files for unregistered version of external code.  Note that many
# don't need to be reassembled.
EXTOBJU=obj/jumptable.o	\
	obj/amosfuncs.o	obj/errors.o	obj/graphics.o	obj/input.o	\
	obj/intmisc.o	obj/iutils.o	obj/memory.o	obju/screens.o	\
	obj/startup.o	obju/windows.o
EXTOBJU_C = %(EXTOBJ:*/*:%1/creator/%2)
# Object files which do need to be reassembled:
EXTOBJUONLY = obju/screens.o obju/windows.o
EXTOBJUONLY_C = %(EXTOBJUONLY:obju/*:obju/creator/%1)
EXTSRCUONLY = %(EXTOBJUONLY:obju/*.o:src2/%1.s)

EXTERNALU = obju/extcode
EXTERNALU_C = obju/creator/extcode


default: pro

all: pro creator pro-unreg creator-unreg

both: pro creator

unreg: pro-unreg creator-unreg

arc: arc-full arc-demo


pro: $(PROPATH)intuition.lib

creator: $(CREPATH)intuition.lib

pro-unreg: $(PROPATH)intuition_unreg.lib

creator-unreg: $(CREPATH)intuition_unreg.lib

clean:
	rm $(EXTERNAL) $(EXTERNAL_C) $(EXTERNALU) $(EXTERNALU_C)
	rm obj/\#?.o obju/\#?.o obj/creator/\#?.o obju/creator/\#?.o

spotless: clean
	rm $(PROPATH)intuition.lib $(PROPATH)intuition_unreg.lib
	rm $(CREPATH)intuition.lib $(CREPATH)intuition_unreg.lib
	touch src/defs.i


$(PROPATH)intuition.lib : \
		$(EXTERNAL) $(INTSRC) src/offsets.i src/defs.i src/macros.i
	/extasm src/intuition.s -o%(left)

$(CREPATH)intuition.lib : \
		$(EXTERNAL_C) $(INTSRC) src/offsets.i src/defs.i src/macros.i
	/extasm src/intuition.s -SCREATOR -o%(left)

$(PROPATH)intuition_unreg.lib : \
		$(EXTERNALU) $(INTSRC) src/offsets.i src/defs.i src/macros.i
	/extasm src/intuition.s -SUNREGISTERED -o%(left)

$(CREPATH)intuition_unreg.lib : \
		$(EXTERNALU_C) $(INTSRC) src/offsets.i src/defs.i src/macros.i
	/extasm src/intuition.s -SCREATOR -SUNREGISTERED -o%(left)


$(EXTERNALU) : $(EXTOBJU)
	dlink -o%(left) %(right)

$(EXTERNAL) : $(EXTOBJ)
	dlink -o%(left) %(right)

$(EXTERNALU_C) : $(EXTOBJU_C)
	dlink -o%(left) %(right)

$(EXTERNAL_C) : $(EXTOBJ_C)
	dlink -o%(left) %(right)

$(EXTOBJ): $(EXTSRC)
	as -o%(left) %(right) -isrc -d

$(EXTOBJ_C): $(EXTSRC)
	as -o%(left) %(right) -isrc -d -SCREATOR

$(EXTOBJUONLY) : $(EXTSRCUONLY)
	as -o%(left) %(right) -isrc -d -SUNREGISTERED

$(EXTOBJUONLY_C) : $(EXTSRCUONLY)
	as -o%(left) %(right) -isrc -d -SCREATOR -SUNREGISTERED

$(EXTOBJ) $(EXTOBJ_C) $(EXTOBJUONLY) $(EXTOBJUONLY_C) :: \
					src/defs.i src/macros.i src/macros2.i

src/defs.i : src/data.i
	touch %(left)

#####

arc-beta:
	@-makedir temp:Intuition
	@copy drawer.info temp:Intuition.info
	@-makedir temp:Intuition/AMOS_System
	@-makedir temp:Intuition/APSystem
	@copy progs/IntuiViewer.amos temp:Intuition clone
#	@copy amos:games/Shanghai.AMOS temp:Intuition clone
	@copy ~(Shanghai).guide temp:Intuition clone quiet
	@copy $(PROPATH)Intuition.lib temp:Intuition/apsystem clone
	@copy $(CREPATH)Intuition.lib temp:Intuition/amos_system clone
	@copy src/IntRoutines.i temp:Intuition clone
	@echo >t:xyz cd temp:
	@echo >>t:xyz lha -rx m IntExtBeta Intuition
	@echo >>t:xyz uuencode IntExtBeta.lha IntExtBeta.uu
	@execute t:xyz
	@delete temp:IntExtBeta.lha t:xyz temp:Intuition all quiet

arc-demo:
	@-makedir temp:Intuition
	@copy drawer.info temp:Intuition.info clone
	@-makedir temp:Intuition/AMOS_System
	@-makedir temp:Intuition/APSystem
	@copy progs/IntuiViewer.AMOS temp:Intuition clone quiet
	@copy IntuiViewer.guide temp:Intuition clone quiet
	@copy $(PROPATH)Def_icon.info temp:Intuition/IntuiViewer.AMOS.info
	@acomp temp:Intuition/IntuiViewer wb inclib quiet
	@copy $(PROPATH)Def_Compiled.info temp:Intuition/IntuiViewer.info
	@patch <intuition.guide.diff -o temp:Intuition/Intuition.guide
	@copy Intuition.guide.info temp:Intuition clone
	@copy IntuiViewer.guide temp:Intuition clone
@#	@copy Shanghai.guide temp:Intuition clone
@#	@copy amos:games/Shanghai.AMOS temp:Intuition clone
@#	@copy $(PROPATH)Def_icon.info temp:Intuition/Shanghai.AMOS.info clone
@#	@acomp temp:Intuition/Shanghai wb inclib quiet
@#	@copy $(PROPATH)Def_Compiled.info temp:Intuition/Shanghai.info clone
	@copy $(PROPATH)intuition_unreg.lib temp:Intuition/apsystem/Intuition.Lib clone
	@copy $(CREPATH)intuition_unreg.lib temp:Intuition/amos_system/Intuition.Lib clone
	@copy Intuition.Lib.info temp:Intuition/apsystem clone
	@copy Intuition.Lib.info temp:Intuition/amos_system clone
	@copy drawer.info temp:Intuition/APSystem.info clone
	@copy drawer.info temp:Intuition/AMOS_System.info clone
	@copy Registration.txt temp:Intuition clone
	@copy src/IntRoutines.i temp:Intuition clone
	@-copy README.$(VERSION) temp:Intuition/README clone
	@echo >t:xyz cd temp:
	@echo >>t:xyz lha -rx m IntExtDemo.lha Intuition Intuition.info
	@echo >>t:xyz uuencode IntExtDemo.lha IntExtDemo.uu IntExt$(VERSION)-Demo.lha
	@execute t:xyz
	@delete temp:IntExtDemo.lha t:xyz temp:Intuition all quiet
@delete t:xyz temp:Intuition all quiet

arc-full:
	@-makedir temp:Intuition
	@copy drawer.info temp:Intuition.info clone
	@-makedir temp:Intuition/AMOS_System
	@-makedir temp:Intuition/APSystem
@#	@copy progs/IntuiViewer.AMOS temp:Intuition clone quiet
@#	@copy IntuiViewer.guide temp:Intuition clone quiet
@#	@copy $(PROPATH)Def_icon.info temp:Intuition/IntuiViewer.AMOS.info
@#	@acomp temp:Intuition/IntuiViewer wb inclib quiet
@#	@copy $(PROPATH)Def_Compiled.info temp:Intuition/IntuiViewer.info
@#	@copy Shanghai.guide temp:Intuition clone
@#	@copy amos:games/Shanghai.AMOS temp:Intuition clone
@#	@copy $(PROPATH)Def_icon.info temp:Intuition/Shanghai.AMOS.info clone
@#	@acomp temp:Intuition/Shanghai wb inclib quiet
@#	@copy $(PROPATH)Def_Compiled.info temp:Intuition/Shanghai.info clone
	@copy Intuition.guide temp:Intuition clone
	@copy Intuition.guide.info temp:Intuition clone
	@copy $(PROPATH)Intuition.lib temp:Intuition/apsystem clone
	@copy $(CREPATH)Intuition.lib temp:Intuition/amos_system clone
	@copy Intuition.Lib.info temp:Intuition/apsystem clone
	@copy Intuition.Lib.info temp:Intuition/amos_system clone
	@copy drawer.info temp:Intuition/APSystem.info clone
	@copy drawer.info temp:Intuition/AMOS_System.info clone
	@copy src/IntRoutines.i temp:Intuition clone
	@-copy README.$(VERSION) temp:Intuition/README clone
	@echo >t:xyz cd temp:
	@echo >>t:xyz lha -rx m IntExtFull Intuition Intuition.info
	@echo >>t:xyz uuencode IntExtFull.lha IntExtFull.uu IntExt$(VERSION).lha
	@execute t:xyz
	@delete temp:IntExtFull.lha t:xyz temp:Intuition all quiet
