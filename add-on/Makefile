clean:
	rm -rf usr
	rm -rf y2update.tgz

dist:
	mkdir -p usr/share/YaST2/
	mkdir -p usr/share/YaST2/clients/
	mkdir -p usr/share/YaST2/modules/
	mkdir -p usr/share/YaST2/include/yep/
	cp ../yast/src/inst_yep.ycp usr/share/YaST2/clients/
	cp ../yast/src/complex.ycp usr/share/YaST2/include/yep/
	cp ../yast/src/dialogs.ycp usr/share/YaST2/include/yep/
	cp ../yast/src/helps.ycp usr/share/YaST2/include/yep/
	cp ../yast/src/YEPData.ycp usr/share/YaST2/modules/
	cp ../yast/src/YEPData.ybc usr/share/YaST2/modules/
	tar -zcf y2update.tgz usr
