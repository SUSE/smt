---------------------------------------------------------------------------------------------------------------
-- select PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, PRODUCTLOWER, VERSIONLOWER, RELEASELOWER, ARCHLOWER, FRIENDLY, 
--        PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS
-- from ncc.NNW_PRODUCT_DATA
--------------------------------------------------------------------------------------------------------------- 
-- result export as insert statements
---------------------------------------------------------------------------------------------------------------
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(1, 'TestProduct', '1.0', NULL, NULL, 'testproduct', '1.0', NULL, NULL, 'Test Product', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="disk" description="" command="hwinfo --disk"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="scsi" description="" command="hwinfo --scsi"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="tape" description="" command="hwinfo --tape"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="identification" description="" page="reg-prod.jsp?guid={guid}&amp;lang={lang}" class="mandatory">
		<param id="email" description=""/>
	</param>
	<param id="regcode" description="" page="reg-prod.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="moniker" description="" page="reg-prod.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="disk" description="" command="hwinfo --disk"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
		<param id="scsi" description="" command="hwinfo --scsi"/>
		<param id="sound" description="" command="hwinfo --sound"/>
		<param id="tape" description="" command="hwinfo --tape"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="regcode"></param>
	<param id="group">erictestgroup</param>
	<param id="group">erictestgroup2</param>
</service>', NULL, 'Test');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(2, 'SUSE Linux', '10.1', NULL, NULL, 'suse linux', '10.1', NULL, NULL, 'SUSE Linux 10.1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="elogin" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="identification" description="" page="http://download.novell.com/delivery/reg/suse.jsp" class="tentative">
		<param id="elogin" description=""/>
	</param>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="sound" description="" command="hwinfo --sound"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="regcode-suse"></param>
	<param name="catalog">SUSE-Linux-10.1-Updates</param>
</service>', NULL, 'SUSE');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(424, 'SUSE-Linux-Enterprise-Server-SP1-migration', '10', NULL, 'i386', 'suse-linux-enterprise-server-sp1-migration', '10', NULL, 'i386', 'SUSE Linux Enterprise Server 10 SP1 Migration', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sles" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
    <guid description="" class="mandatory"/>
    <param id="secret" description="" command="zmd-secret" class="mandatory"/>
    <host description=""/>
    <product description="" class="mandatory"/>
    <param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
    <param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
    <param id="regcode-sles" description=""/>
    <param id="moniker" description=""/>
    <param id="sysident" description="">
        <param id="processor" description="" command="uname -p"/>
        <param id="platform" description="" command="uname -i"/>
        <param id="hostname" description="" command="uname -n"/>
    </param>
    <privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo> 
', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="group">sles10-sp1-migration</param>
</service>', 'Y', 'SLES');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(425, 'SUSE-Linux-Enterprise-Server-SP1-migration', '10', NULL, 'x86_64', 'suse-linux-enterprise-server-sp1-migration', '10', NULL, 'x86_64', 'SUSE Linux Enterprise Server 10 SP1 Migration', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sles" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
    <guid description="" class="mandatory"/>
    <param id="secret" description="" command="zmd-secret" class="mandatory"/>
    <host description=""/>
    <product description="" class="mandatory"/>
    <param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
    <param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
    <param id="regcode-sles" description=""/>
    <param id="moniker" description=""/>
    <param id="sysident" description="">
        <param id="processor" description="" command="uname -p"/>
        <param id="platform" description="" command="uname -i"/>
        <param id="hostname" description="" command="uname -n"/>
    </param>
    <privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo> 
', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="group">sles10-sp1-migration</param>
</service>', 'Y', 'SLES');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(422, 'SUSE-Linux-Enterprise-Server-SP1-migration', '10', NULL, 'i586', 'suse-linux-enterprise-server-sp1-migration', '10', NULL, 'i586', 'SUSE Linux Enterprise Server 10 SP1 Migration', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sles" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
    <guid description="" class="mandatory"/>
    <param id="secret" description="" command="zmd-secret" class="mandatory"/>
    <host description=""/>
    <product description="" class="mandatory"/>
    <param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
    <param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
    <param id="regcode-sles" description=""/>
    <param id="moniker" description=""/>
    <param id="sysident" description="">
        <param id="processor" description="" command="uname -p"/>
        <param id="platform" description="" command="uname -i"/>
        <param id="hostname" description="" command="uname -n"/>
    </param>
    <privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo> 
', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="group">sles10-sp1-migration</param>
</service>', 'Y', 'SLES');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(423, 'SUSE-Linux-Enterprise-Server-SP1-migration', '10', NULL, 'i486', 'suse-linux-enterprise-server-sp1-migration', '10', NULL, 'i486', 'SUSE Linux Enterprise Server 10 SP1 Migration', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sles" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
    <guid description="" class="mandatory"/>
    <param id="secret" description="" command="zmd-secret" class="mandatory"/>
    <host description=""/>
    <product description="" class="mandatory"/>
    <param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
    <param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
    <param id="regcode-sles" description=""/>
    <param id="moniker" description=""/>
    <param id="sysident" description="">
        <param id="processor" description="" command="uname -p"/>
        <param id="platform" description="" command="uname -i"/>
        <param id="hostname" description="" command="uname -n"/>
    </param>
    <privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo> 
', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="group">sles10-sp1-migration</param>
</service>', 'Y', 'SLES');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(421, 'SUSE-Linux-Enterprise-Server-SP1-migration', '10', NULL, 'i686', 'suse-linux-enterprise-server-sp1-migration', '10', NULL, 'i686', 'SUSE Linux Enterprise Server 10 SP1 Migration', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sles" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
    <guid description="" class="mandatory"/>
    <param id="secret" description="" command="zmd-secret" class="mandatory"/>
    <host description=""/>
    <product description="" class="mandatory"/>
    <param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
    <param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
    <param id="regcode-sles" description=""/>
    <param id="moniker" description=""/>
    <param id="sysident" description="">
        <param id="processor" description="" command="uname -p"/>
        <param id="platform" description="" command="uname -i"/>
        <param id="hostname" description="" command="uname -n"/>
    </param>
    <privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo> 
', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="group">sles10-sp1-migration</param>
</service>', 'Y', 'SLES');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(420, 'SUSE-Linux-Enterprise-Desktop-SP1-migration', '10', NULL, 'x86_64', 'suse-linux-enterprise-desktop-sp1-migration', '10', NULL, 'x86_64', 'SUSE Linux Enterprise Desktop 10 SP1 Migration', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sled" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
    <guid description="" class="mandatory"/>
    <param id="secret" description="" command="zmd-secret" class="mandatory"/>
    <host description=""/>
    <product description="" class="mandatory"/>
    <param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
    <param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
    <param id="regcode-sled" description=""/>
    <param id="moniker" description=""/>
    <param id="sysident" description="">
        <param id="processor" description="" command="uname -p"/>
        <param id="platform" description="" command="uname -i"/>
        <param id="hostname" description="" command="uname -n"/>
    </param>
    <privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo> 
', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" type="${mirror:type}" description="${mirror:name}">
	<param id="url">${mirror:url}</param>
	<param id="group">sled10-sp1-migration</param>
</service>', 'Y', 'SLED');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(418, 'SUSE-Linux-Enterprise-Desktop-SP1-migration', '10', NULL, 'i486', 'suse-linux-enterprise-desktop-sp1-migration', '10', NULL, 'i486', 'SUSE Linux Enterprise Desktop 10 SP1 Migration', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sled" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
    <guid description="" class="mandatory"/>
    <param id="secret" description="" command="zmd-secret" class="mandatory"/>
    <host description=""/>
    <product description="" class="mandatory"/>
    <param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
    <param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
    <param id="regcode-sled" description=""/>
    <param id="moniker" description=""/>
    <param id="sysident" description="">
        <param id="processor" description="" command="uname -p"/>
        <param id="platform" description="" command="uname -i"/>
        <param id="hostname" description="" command="uname -n"/>
    </param>
    <privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo> 
', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" type="${mirror:type}" description="${mirror:name}">
	<param id="url">${mirror:url}</param>
	<param id="group">sled10-sp1-migration</param>
</service>', 'Y', 'SLED');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(419, 'SUSE-Linux-Enterprise-Desktop-SP1-migration', '10', NULL, 'i386', 'suse-linux-enterprise-desktop-sp1-migration', '10', NULL, 'i386', 'SUSE Linux Enterprise Desktop 10 SP1 Migration', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sled" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
    <guid description="" class="mandatory"/>
    <param id="secret" description="" command="zmd-secret" class="mandatory"/>
    <host description=""/>
    <product description="" class="mandatory"/>
    <param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
    <param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
    <param id="regcode-sled" description=""/>
    <param id="moniker" description=""/>
    <param id="sysident" description="">
        <param id="processor" description="" command="uname -p"/>
        <param id="platform" description="" command="uname -i"/>
        <param id="hostname" description="" command="uname -n"/>
    </param>
    <privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo> 
', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" type="${mirror:type}" description="${mirror:name}">
	<param id="url">${mirror:url}</param>
	<param id="group">sled10-sp1-migration</param>
</service>', 'Y', 'SLED');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(416, 'SUSE-Linux-Enterprise-Desktop-SP1-migration', '10', NULL, 'i686', 'suse-linux-enterprise-desktop-sp1-migration', '10', NULL, 'i686', 'SUSE Linux Enterprise Desktop 10 SP1 Migration', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sled" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
    <guid description="" class="mandatory"/>
    <param id="secret" description="" command="zmd-secret" class="mandatory"/>
    <host description=""/>
    <product description="" class="mandatory"/>
    <param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
    <param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
    <param id="regcode-sled" description=""/>
    <param id="moniker" description=""/>
    <param id="sysident" description="">
        <param id="processor" description="" command="uname -p"/>
        <param id="platform" description="" command="uname -i"/>
        <param id="hostname" description="" command="uname -n"/>
    </param>
    <privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo> 
', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" type="${mirror:type}" description="${mirror:name}">
	<param id="url">${mirror:url}</param>
	<param id="group">sled10-sp1-migration</param>
</service>', 'Y', 'SLED');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(417, 'SUSE-Linux-Enterprise-Desktop-SP1-migration', '10', NULL, 'i586', 'suse-linux-enterprise-desktop-sp1-migration', '10', NULL, 'i586', 'SUSE Linux Enterprise Desktop 10 SP1 Migration', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sled" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
    <guid description="" class="mandatory"/>
    <param id="secret" description="" command="zmd-secret" class="mandatory"/>
    <host description=""/>
    <product description="" class="mandatory"/>
    <param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
    <param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
    <param id="regcode-sled" description=""/>
    <param id="moniker" description=""/>
    <param id="sysident" description="">
        <param id="processor" description="" command="uname -p"/>
        <param id="platform" description="" command="uname -i"/>
        <param id="hostname" description="" command="uname -n"/>
    </param>
    <privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo> 
', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" type="${mirror:type}" description="${mirror:name}">
	<param id="url">${mirror:url}</param>
	<param id="group">sled10-sp1-migration</param>
</service>', 'Y', 'SLED');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(376, 'openSUSE-10.3-dvd5-download', '10.3', NULL, NULL, 'opensuse-10.3-dvd5-download', '10.3', NULL, NULL, 'openSUSE 10.3', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="elogin" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="desktops" description="" command="installed-desktops"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="identification" description="" page="http://download.novell.com/delivery/reg/suse.jsp" class="tentative">
		<param id="elogin" description=""/>
	</param>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="desktops" description="" command="installed-desktops"/>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="sound" description="" command="hwinfo --sound"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param name="catalog">openSUSE-10.3-Updates</param>
</service>', 'Y', 'SUSE');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(377, 'openSUSE-10.3-CD-download', '10.3', NULL, NULL, 'opensuse-10.3-cd-download', '10.3', NULL, NULL, 'openSUSE 10.3', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="elogin" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="desktops" description="" command="installed-desktops"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="identification" description="" page="http://download.novell.com/delivery/reg/suse.jsp" class="tentative">
		<param id="elogin" description=""/>
	</param>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="desktops" description="" command="installed-desktops"/>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="sound" description="" command="hwinfo --sound"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param name="catalog">openSUSE-10.3-Updates</param>
</service>', 'Y', 'SUSE');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(396, 'Zenworks Linux Management', '7.2', NULL, NULL, 'zenworks linux management', '7.2', NULL, NULL, 'Zenworks Linux Management 7.2', NULL, NULL, NULL, 'N', 'ZlmSatellite');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(340, 'openSUSE-10.2-FTP', '10.2', NULL, NULL, 'opensuse-10.2-ftp', '10.2', NULL, NULL, 'openSUSE 10.2', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="elogin" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="desktops" description="" command="installed-desktops"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="identification" description="" page="http://download.novell.com/delivery/reg/suse.jsp" class="tentative">
		<param id="elogin" description=""/>
	</param>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="desktops" description="" command="installed-desktops"/>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="sound" description="" command="hwinfo --sound"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="regcode-suse"></param>
	<param name="catalog">SUSE-Linux-10.2-Updates</param>
</service>', 'Y', 'SUSE');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(356, 'ATI Video Drivers STAGE', NULL, NULL, NULL, 'ati video drivers stage', NULL, NULL, NULL, 'ATI Video Drivers', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="hw_inventory" description="">
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" type="${mirror:type}" description="${mirror:name}">
	<param id="url">${mirror:url}</param>
	<param name="catalog">tkar_ati_updates</param>
</service>', NULL, 'ATI');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(357, 'nVidia Video Drivers STAGE', NULL, NULL, NULL, 'nvidia video drivers stage', NULL, NULL, NULL, 'nVidia Video Drivers', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="hw_inventory" description="">
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" type="${mirror:type}" description="${mirror:name}">
	<param id="url">${mirror:url}</param>
	<param name="catalog">tkar_nvidia_updates</param>
</service>', NULL, 'nVidia');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(17, 'SUSE-Linux-DVD9-i386', '10.1', NULL, 'i386', 'suse-linux-dvd9-i386', '10.1', NULL, 'i386', 'SUSE Linux 10.1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="elogin" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="identification" description="" page="http://download.novell.com/delivery/reg/suse.jsp" class="tentative">
		<param id="elogin" description=""/>
	</param>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="sound" description="" command="hwinfo --sound"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="regcode-suse"></param>
	<param name="catalog">SUSE-Linux-10.1-Updates</param>
</service>', NULL, 'SUSE');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(18, 'SUSE-Linux-CD-OSS-i386', '10.1', NULL, 'i386', 'suse-linux-cd-oss-i386', '10.1', NULL, 'i386', 'SUSE Linux 10.1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="elogin" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="identification" description="" page="http://download.novell.com/delivery/reg/suse.jsp" class="tentative">
		<param id="elogin" description=""/>
	</param>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="sound" description="" command="hwinfo --sound"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="regcode-suse"></param>
	<param name="catalog">SUSE-Linux-10.1-Updates</param>
</service>', NULL, 'SUSE');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(19, 'SUSE-Linux-CD-OSS-ppc', '10.1', NULL, 'ppc', 'suse-linux-cd-oss-ppc', '10.1', NULL, 'ppc', 'SUSE Linux 10.1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="elogin" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="identification" description="" page="http://download.novell.com/delivery/reg/suse.jsp" class="tentative">
		<param id="elogin" description=""/>
	</param>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="sound" description="" command="hwinfo --sound"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="regcode-suse"></param>
	<param name="catalog">SUSE-Linux-10.1-Updates</param>
</service>', NULL, 'SUSE');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(20, 'SUSE-Linux-CD-OSS-x86_64', '10.1', NULL, 'x86_64', 'suse-linux-cd-oss-x86_64', '10.1', NULL, 'x86_64', 'SUSE Linux 10.1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="elogin" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="identification" description="" page="http://download.novell.com/delivery/reg/suse.jsp" class="tentative">
		<param id="elogin" description=""/>
	</param>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="sound" description="" command="hwinfo --sound"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="regcode-suse"></param>
	<param name="catalog">SUSE-Linux-10.1-Updates</param>
</service>', NULL, 'SUSE');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(21, 'SUSE-Linux-Enterprise-Desktop-i386', '10', NULL, 'i686', 'suse-linux-enterprise-desktop-i386', '10', NULL, 'i686', 'SUSE Linux Enterprise Desktop 10', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sled" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="sys" description="" command="hwinfo --sys"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="identification" description="" page="reg.jsp?guid={guid}&amp;lang={lang}" class="mandatory">
		<param id="email" description=""/>
	</param>
	<param id="regcode-sled" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="moniker" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
		<param id="sound" description="" command="hwinfo --sound"/>
		<param id="sys" description="" command="hwinfo --sys"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" type="${mirror:type}" description="${mirror:name}">
	<param id="url">${mirror:url}</param>
	<group-catalogs/>
</service>', 'Y', 'SLED');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(22, 'SUSE-Linux-Enterprise-Desktop-i386', '10', NULL, 'i586', 'suse-linux-enterprise-desktop-i386', '10', NULL, 'i586', 'SUSE Linux Enterprise Desktop 10', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sled" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="sys" description="" command="hwinfo --sys"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="identification" description="" page="reg.jsp?guid={guid}&amp;lang={lang}" class="mandatory">
		<param id="email" description=""/>
	</param>
	<param id="regcode-sled" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="moniker" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
		<param id="sound" description="" command="hwinfo --sound"/>
		<param id="sys" description="" command="hwinfo --sys"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" type="${mirror:type}" description="${mirror:name}">
	<param id="url">${mirror:url}</param>
	<group-catalogs/>
</service>', 'Y', 'SLED');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(23, 'SUSE-Linux-Enterprise-Desktop-i386', '10', NULL, 'i486', 'suse-linux-enterprise-desktop-i386', '10', NULL, 'i486', 'SUSE Linux Enterprise Desktop 10', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sled" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="sys" description="" command="hwinfo --sys"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="identification" description="" page="reg.jsp?guid={guid}&amp;lang={lang}" class="mandatory">
		<param id="email" description=""/>
	</param>
	<param id="regcode-sled" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="moniker" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
		<param id="sound" description="" command="hwinfo --sound"/>
		<param id="sys" description="" command="hwinfo --sys"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" type="${mirror:type}" description="${mirror:name}">
	<param id="url">${mirror:url}</param>
	<group-catalogs/>
</service>', 'Y', 'SLED');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(24, 'SUSE-Linux-Enterprise-Desktop-i386', '10', NULL, 'i386', 'suse-linux-enterprise-desktop-i386', '10', NULL, 'i386', 'SUSE Linux Enterprise Desktop 10', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sled" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="sys" description="" command="hwinfo --sys"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="identification" description="" page="reg.jsp?guid={guid}&amp;lang={lang}" class="mandatory">
		<param id="email" description=""/>
	</param>
	<param id="regcode-sled" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="moniker" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
		<param id="sound" description="" command="hwinfo --sound"/>
		<param id="sys" description="" command="hwinfo --sys"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" type="${mirror:type}" description="${mirror:name}">
	<param id="url">${mirror:url}</param>
	<group-catalogs/>
</service>', 'Y', 'SLED');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(25, 'SUSE-Linux-Enterprise-Desktop-x86_64', '10', NULL, 'x86_64', 'suse-linux-enterprise-desktop-x86_64', '10', NULL, 'x86_64', 'SUSE Linux Enterprise Desktop 10', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sled" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="sys" description="" command="hwinfo --sys"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="identification" description="" page="reg.jsp?guid={guid}&amp;lang={lang}" class="mandatory">
		<param id="email" description=""/>
	</param>
	<param id="regcode-sled" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="moniker" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
		<param id="sound" description="" command="hwinfo --sound"/>
		<param id="sys" description="" command="hwinfo --sys"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" type="${mirror:type}" description="${mirror:name}">
	<param id="url">${mirror:url}</param>
	<group-catalogs/>
</service>', 'Y', 'SLED');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(26, 'SUSE-Linux-Enterprise-Server-i386', '10', NULL, 'i686', 'suse-linux-enterprise-server-i386', '10', NULL, 'i686', 'SUSE Linux Enterprise Server 10', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sles" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="disk" description="" command="hwinfo --disk"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="scsi" description="" command="hwinfo --scsi"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="sys" description="" command="hwinfo --sys"/>
	<param id="tape" description="" command="hwinfo --tape"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="identification" description="" page="reg.jsp?guid={guid}&amp;lang={lang}" class="mandatory">
		<param id="email" description=""/>
	</param>
	<param id="regcode-sles" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="moniker" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="disk" description="" command="hwinfo --disk"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
		<param id="scsi" description="" command="hwinfo --scsi"/>
		<param id="sound" description="" command="hwinfo --sound"/>
		<param id="sys" description="" command="hwinfo --sys"/>
		<param id="tape" description="" command="hwinfo --tape"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<group-catalogs/>
</service>', 'Y', 'SLES');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(27, 'SUSE-Linux-Enterprise-Server-i386', '10', NULL, 'i586', 'suse-linux-enterprise-server-i386', '10', NULL, 'i586', 'SUSE Linux Enterprise Server 10', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sles" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="disk" description="" command="hwinfo --disk"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="scsi" description="" command="hwinfo --scsi"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="sys" description="" command="hwinfo --sys"/>
	<param id="tape" description="" command="hwinfo --tape"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="identification" description="" page="reg.jsp?guid={guid}&amp;lang={lang}" class="mandatory">
		<param id="email" description=""/>
	</param>
	<param id="regcode-sles" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="moniker" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="disk" description="" command="hwinfo --disk"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
		<param id="scsi" description="" command="hwinfo --scsi"/>
		<param id="sound" description="" command="hwinfo --sound"/>
		<param id="sys" description="" command="hwinfo --sys"/>
		<param id="tape" description="" command="hwinfo --tape"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<group-catalogs/>
</service>', 'Y', 'SLES');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(28, 'SUSE-Linux-Enterprise-Server-i386', '10', NULL, 'i486', 'suse-linux-enterprise-server-i386', '10', NULL, 'i486', 'SUSE Linux Enterprise Server 10', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sles" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="disk" description="" command="hwinfo --disk"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="scsi" description="" command="hwinfo --scsi"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="sys" description="" command="hwinfo --sys"/>
	<param id="tape" description="" command="hwinfo --tape"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="identification" description="" page="reg.jsp?guid={guid}&amp;lang={lang}" class="mandatory">
		<param id="email" description=""/>
	</param>
	<param id="regcode-sles" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="moniker" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="disk" description="" command="hwinfo --disk"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
		<param id="scsi" description="" command="hwinfo --scsi"/>
		<param id="sound" description="" command="hwinfo --sound"/>
		<param id="sys" description="" command="hwinfo --sys"/>
		<param id="tape" description="" command="hwinfo --tape"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<group-catalogs/>
</service>', 'Y', 'SLES');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(29, 'SUSE-Linux-Enterprise-Server-i386', '10', NULL, 'i386', 'suse-linux-enterprise-server-i386', '10', NULL, 'i386', 'SUSE Linux Enterprise Server 10', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sles" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="disk" description="" command="hwinfo --disk"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="scsi" description="" command="hwinfo --scsi"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="sys" description="" command="hwinfo --sys"/>
	<param id="tape" description="" command="hwinfo --tape"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="identification" description="" page="reg.jsp?guid={guid}&amp;lang={lang}" class="mandatory">
		<param id="email" description=""/>
	</param>
	<param id="regcode-sles" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="moniker" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="disk" description="" command="hwinfo --disk"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
		<param id="scsi" description="" command="hwinfo --scsi"/>
		<param id="sound" description="" command="hwinfo --sound"/>
		<param id="sys" description="" command="hwinfo --sys"/>
		<param id="tape" description="" command="hwinfo --tape"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<group-catalogs/>
</service>', 'Y', 'SLES');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(30, 'SUSE-Linux-Enterprise-Server-x86_64', '10', NULL, 'x86_64', 'suse-linux-enterprise-server-x86_64', '10', NULL, 'x86_64', 'SUSE Linux Enterprise Server 10', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sles" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="disk" description="" command="hwinfo --disk"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="scsi" description="" command="hwinfo --scsi"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="sys" description="" command="hwinfo --sys"/>
	<param id="tape" description="" command="hwinfo --tape"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="identification" description="" page="reg.jsp?guid={guid}&amp;lang={lang}" class="mandatory">
		<param id="email" description=""/>
	</param>
	<param id="regcode-sles" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="moniker" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="disk" description="" command="hwinfo --disk"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
		<param id="scsi" description="" command="hwinfo --scsi"/>
		<param id="sound" description="" command="hwinfo --sound"/>
		<param id="sys" description="" command="hwinfo --sys"/>
		<param id="tape" description="" command="hwinfo --tape"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<group-catalogs/>
</service>', 'Y', 'SLES');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(31, 'SUSE-Linux-Enterprise-Server-ppc', '10', NULL, 'ppc', 'suse-linux-enterprise-server-ppc', '10', NULL, 'ppc', 'SUSE Linux Enterprise Server 10', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sles" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="disk" description="" command="hwinfo --disk"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="scsi" description="" command="hwinfo --scsi"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="sys" description="" command="hwinfo --sys"/>
	<param id="tape" description="" command="hwinfo --tape"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="identification" description="" page="reg.jsp?guid={guid}&amp;lang={lang}" class="mandatory">
		<param id="email" description=""/>
	</param>
	<param id="regcode-sles" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="moniker" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="disk" description="" command="hwinfo --disk"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
		<param id="scsi" description="" command="hwinfo --scsi"/>
		<param id="sound" description="" command="hwinfo --sound"/>
		<param id="sys" description="" command="hwinfo --sys"/>
		<param id="tape" description="" command="hwinfo --tape"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<group-catalogs/>
</service>', 'Y', 'SLES');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(32, 'SUSE-Linux-Enterprise-Server-ppc', '10', NULL, 'ppc64', 'suse-linux-enterprise-server-ppc', '10', NULL, 'ppc64', 'SUSE Linux Enterprise Server 10', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sles" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="disk" description="" command="hwinfo --disk"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="scsi" description="" command="hwinfo --scsi"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="sys" description="" command="hwinfo --sys"/>
	<param id="tape" description="" command="hwinfo --tape"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="identification" description="" page="reg.jsp?guid={guid}&amp;lang={lang}" class="mandatory">
		<param id="email" description=""/>
	</param>
	<param id="regcode-sles" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="moniker" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="disk" description="" command="hwinfo --disk"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
		<param id="scsi" description="" command="hwinfo --scsi"/>
		<param id="sound" description="" command="hwinfo --sound"/>
		<param id="sys" description="" command="hwinfo --sys"/>
		<param id="tape" description="" command="hwinfo --tape"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<group-catalogs/>
</service>', 'Y', 'SLES');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(33, 'SUSE-Linux-Enterprise-Server-ia64', '10', NULL, 'ia64', 'suse-linux-enterprise-server-ia64', '10', NULL, 'ia64', 'SUSE Linux Enterprise Server 10', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sles" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="disk" description="" command="hwinfo --disk"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="scsi" description="" command="hwinfo --scsi"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="sys" description="" command="hwinfo --sys"/>
	<param id="tape" description="" command="hwinfo --tape"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="identification" description="" page="reg.jsp?guid={guid}&amp;lang={lang}" class="mandatory">
		<param id="email" description=""/>
	</param>
	<param id="regcode-sles" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="moniker" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="disk" description="" command="hwinfo --disk"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
		<param id="scsi" description="" command="hwinfo --scsi"/>
		<param id="sound" description="" command="hwinfo --sound"/>
		<param id="sys" description="" command="hwinfo --sys"/>
		<param id="tape" description="" command="hwinfo --tape"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<group-catalogs/>
</service>', 'Y', 'SLES');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(34, 'SUSE-Linux-Enterprise-Server-s390x', '10', NULL, 's390x', 'suse-linux-enterprise-server-s390x', '10', NULL, 's390x', 'SUSE Linux Enterprise Server 10', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sles" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="disk" description="" command="hwinfo --disk"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="scsi" description="" command="hwinfo --scsi"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="sys" description="" command="hwinfo --sys"/>
	<param id="tape" description="" command="hwinfo --tape"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="identification" description="" page="reg.jsp?guid={guid}&amp;lang={lang}" class="mandatory">
		<param id="email" description=""/>
	</param>
	<param id="regcode-sles" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="moniker" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="disk" description="" command="hwinfo --disk"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
		<param id="scsi" description="" command="hwinfo --scsi"/>
		<param id="sound" description="" command="hwinfo --sound"/>
		<param id="sys" description="" command="hwinfo --sys"/>
		<param id="tape" description="" command="hwinfo --tape"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<group-catalogs/>
</service>', 'Y', 'SLES');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(35, 'SUSE-Linux-Enterprise-Server-s390x', '10', NULL, 's390', 'suse-linux-enterprise-server-s390x', '10', NULL, 's390', 'SUSE Linux Enterprise Server 10', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sles" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="disk" description="" command="hwinfo --disk"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="scsi" description="" command="hwinfo --scsi"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="sys" description="" command="hwinfo --sys"/>
	<param id="tape" description="" command="hwinfo --tape"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="identification" description="" page="reg.jsp?guid={guid}&amp;lang={lang}" class="mandatory">
		<param id="email" description=""/>
	</param>
	<param id="regcode-sles" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="moniker" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="disk" description="" command="hwinfo --disk"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
		<param id="scsi" description="" command="hwinfo --scsi"/>
		<param id="sound" description="" command="hwinfo --sound"/>
		<param id="sys" description="" command="hwinfo --sys"/>
		<param id="tape" description="" command="hwinfo --tape"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<group-catalogs/>
</service>', 'Y', 'SLES');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(56, 'SUSE-Linux-10.1-CD-download-x86', '10.1', NULL, 'i386', 'suse-linux-10.1-cd-download-x86', '10.1', NULL, 'i386', 'SUSE Linux 10.1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="elogin" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>
', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="identification" description="" page="http://download.novell.com/delivery/reg/suse.jsp" class="tentative">
		<param id="elogin" description=""/>
	</param>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="sound" description="" command="hwinfo --sound"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="regcode-suse"></param>
	<param name="catalog">SUSE-Linux-10.1-Updates</param>
</service>
', 'Y', 'SUSE');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(57, 'SUSE-Linux-10.1-CD-download-ppc', '10.1', NULL, NULL, 'suse-linux-10.1-cd-download-ppc', '10.1', NULL, NULL, 'SUSE Linux 10.1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="elogin" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>
', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="identification" description="" page="http://download.novell.com/delivery/reg/suse.jsp" class="tentative">
		<param id="elogin" description=""/>
	</param>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="sound" description="" command="hwinfo --sound"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="regcode-suse"></param>
	<param name="catalog">SUSE-Linux-10.1-Updates</param>
</service>
', 'Y', 'SUSE');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(58, 'SUSE-Linux-10.1-CD-download-x86_64', '10.1', NULL, 'x86_64', 'suse-linux-10.1-cd-download-x86_64', '10.1', NULL, 'x86_64', 'SUSE Linux 10.1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="elogin" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>
', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="identification" description="" page="http://download.novell.com/delivery/reg/suse.jsp" class="tentative">
		<param id="elogin" description=""/>
	</param>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="sound" description="" command="hwinfo --sound"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="regcode-suse"></param>
	<param name="catalog">SUSE-Linux-10.1-Updates</param>
</service>
', 'Y', 'SUSE');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(81, 'SUSE-Linux-10.1-CD-download-x86', '10.1', NULL, 'i686', 'suse-linux-10.1-cd-download-x86', '10.1', NULL, 'i686', 'SUSE Linux 10.1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="elogin" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>
', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="identification" description="" page="http://download.novell.com/delivery/reg/suse.jsp" class="tentative">
		<param id="elogin" description=""/>
	</param>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="sound" description="" command="hwinfo --sound"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="regcode-suse"></param>
	<param name="catalog">SUSE-Linux-10.1-Updates</param>
</service>
', 'Y', 'SUSE');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(80, 'SUSE-Linux-10.1-CD-download-x86', '10.1', NULL, 'i586', 'suse-linux-10.1-cd-download-x86', '10.1', NULL, 'i586', 'SUSE Linux 10.1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="elogin" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>
', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="identification" description="" page="http://download.novell.com/delivery/reg/suse.jsp" class="tentative">
		<param id="elogin" description=""/>
	</param>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="sound" description="" command="hwinfo --sound"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="regcode-suse"></param>
	<param name="catalog">SUSE-Linux-10.1-Updates</param>
</service>
', 'Y', 'SUSE');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(61, 'SUSE-Linux-10.1-CD-x86', '10.1', NULL, 'i386', 'suse-linux-10.1-cd-x86', '10.1', NULL, 'i386', 'SUSE Linux 10.1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="elogin" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>
', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="identification" description="" page="http://download.novell.com/delivery/reg/suse.jsp" class="tentative">
		<param id="elogin" description=""/>
	</param>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="sound" description="" command="hwinfo --sound"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="regcode-suse"></param>
	<param name="catalog">SUSE-Linux-10.1-Updates</param>
</service>
', 'Y', 'SUSE');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(62, 'SUSE-Linux-10.1-CD-ppc', '10.1', NULL, 'ppc', 'suse-linux-10.1-cd-ppc', '10.1', NULL, 'ppc', 'SUSE Linux 10.1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="elogin" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>
', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="identification" description="" page="http://download.novell.com/delivery/reg/suse.jsp" class="tentative">
		<param id="elogin" description=""/>
	</param>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="sound" description="" command="hwinfo --sound"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="regcode-suse"></param>
	<param name="catalog">SUSE-Linux-10.1-Updates</param>
</service>
', 'Y', 'SUSE');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(63, 'SUSE-Linux-10.1-CD-x86_64', '10.1', NULL, 'x86_64', 'suse-linux-10.1-cd-x86_64', '10.1', NULL, 'x86_64', 'SUSE Linux 10.1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="elogin" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>
', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="identification" description="" page="http://download.novell.com/delivery/reg/suse.jsp" class="tentative">
		<param id="elogin" description=""/>
	</param>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="sound" description="" command="hwinfo --sound"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="regcode-suse"></param>
	<param name="catalog">SUSE-Linux-10.1-Updates</param>
</service>
', 'Y', 'SUSE');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(64, 'SUSE-Linux-10.1-DVD9-x86-x86_64', '10.1', NULL, 'x86_64', 'suse-linux-10.1-dvd9-x86-x86_64', '10.1', NULL, 'x86_64', 'SUSE Linux 10.1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="elogin" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>
', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="identification" description="" page="http://download.novell.com/delivery/reg/suse.jsp" class="tentative">
		<param id="elogin" description=""/>
	</param>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="sound" description="" command="hwinfo --sound"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="regcode-suse"></param>
	<param name="catalog">SUSE-Linux-10.1-Updates</param>
</service>
', 'Y', 'SUSE');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(65, 'SUSE-Linux-10.1-OSS-DVD-x86', '10.1', NULL, 'i386', 'suse-linux-10.1-oss-dvd-x86', '10.1', NULL, 'i386', 'SUSE Linux 10.1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="elogin" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>
', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="identification" description="" page="http://download.novell.com/delivery/reg/suse.jsp" class="tentative">
		<param id="elogin" description=""/>
	</param>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="sound" description="" command="hwinfo --sound"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="regcode-suse"></param>
	<param name="catalog">SUSE-Linux-10.1-Updates</param>
</service>
', 'Y', 'SUSE');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(66, 'SUSE-Linux-10.1-DVD-OSS-i386', '10.1', NULL, 'i386', 'suse-linux-10.1-dvd-oss-i386', '10.1', NULL, 'i386', 'SUSE Linux 10.1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="elogin" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>
', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="identification" description="" page="http://download.novell.com/delivery/reg/suse.jsp" class="tentative">
		<param id="elogin" description=""/>
	</param>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="sound" description="" command="hwinfo --sound"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="regcode-suse"></param>
	<param name="catalog">SUSE-Linux-10.1-Updates</param>
</service>
', 'Y', 'SUSE');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(67, 'SUSE-Linux-10.1-DVD-OSS-ppc', '10.1', NULL, 'ppc', 'suse-linux-10.1-dvd-oss-ppc', '10.1', NULL, 'ppc', 'SUSE Linux 10.1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="elogin" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>
', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="identification" description="" page="http://download.novell.com/delivery/reg/suse.jsp" class="tentative">
		<param id="elogin" description=""/>
	</param>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="sound" description="" command="hwinfo --sound"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="regcode-suse"></param>
	<param name="catalog">SUSE-Linux-10.1-Updates</param>
</service>
', 'Y', 'SUSE');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(68, 'SUSE-Linux-10.1-DVD-OSS-x86_64', '10.1', NULL, 'x86_64', 'suse-linux-10.1-dvd-oss-x86_64', '10.1', NULL, 'x86_64', 'SUSE Linux 10.1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="elogin" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>
', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="identification" description="" page="http://download.novell.com/delivery/reg/suse.jsp" class="tentative">
		<param id="elogin" description=""/>
	</param>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="sound" description="" command="hwinfo --sound"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="regcode-suse"></param>
	<param name="catalog">SUSE-Linux-10.1-Updates</param>
</service>
', 'Y', 'SUSE');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(69, 'SUSE-Linux-10.1-FTP', '10.1', NULL, NULL, 'suse-linux-10.1-ftp', '10.1', NULL, NULL, 'SUSE Linux 10.1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="elogin" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>
', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="identification" description="" page="http://download.novell.com/delivery/reg/suse.jsp" class="tentative">
		<param id="elogin" description=""/>
	</param>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="sound" description="" command="hwinfo --sound"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="regcode-suse"></param>
	<param name="catalog">SUSE-Linux-10.1-Updates</param>
</service>
', 'Y', 'SUSE');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(76, 'SUSE-Linux-10.1-DVD-i386', '10.1', NULL, 'i386', 'suse-linux-10.1-dvd-i386', '10.1', NULL, 'i386', 'SUSE Linux 10.1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="elogin" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>
', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="identification" description="" page="http://download.novell.com/delivery/reg/suse.jsp" class="tentative">
		<param id="elogin" description=""/>
	</param>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="sound" description="" command="hwinfo --sound"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="regcode-suse"></param>
	<param name="catalog">SUSE-Linux-10.1-Updates</param>
</service>
', 'Y', 'SUSE');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(77, 'SUSE-Linux-10.1-DVD-x86_64', '10.1', NULL, 'x86_64', 'suse-linux-10.1-dvd-x86_64', '10.1', NULL, 'x86_64', 'SUSE Linux 10.1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="elogin" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>
', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="identification" description="" page="http://download.novell.com/delivery/reg/suse.jsp" class="tentative">
		<param id="elogin" description=""/>
	</param>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="sound" description="" command="hwinfo --sound"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="regcode-suse"></param>
	<param name="catalog">SUSE-Linux-10.1-Updates</param>
</service>
', 'Y', 'SUSE');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(78, 'SuSE-Linux-10.1-PromoDVD-i386', '10.1', NULL, 'i386', 'suse-linux-10.1-promodvd-i386', '10.1', NULL, 'i386', 'SUSE Linux 10.1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="elogin" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>
', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="identification" description="" page="http://download.novell.com/delivery/reg/suse.jsp" class="tentative">
		<param id="elogin" description=""/>
	</param>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="sound" description="" command="hwinfo --sound"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="regcode-suse"></param>
	<param name="catalog">SUSE-Linux-10.1-Updates</param>
</service>
', 'Y', 'SUSE');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(79, 'SUSE-Linux-10.1-CD-download-x86', '10.1', NULL, 'i486', 'suse-linux-10.1-cd-download-x86', '10.1', NULL, 'i486', 'SUSE Linux 10.1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="elogin" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>
', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="identification" description="" page="http://download.novell.com/delivery/reg/suse.jsp" class="tentative">
		<param id="elogin" description=""/>
	</param>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="sound" description="" command="hwinfo --sound"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="regcode-suse"></param>
	<param name="catalog">SUSE-Linux-10.1-Updates</param>
</service>
', 'Y', 'SUSE');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(96, 'SUSE-Linux-10.1-CD-x86', '10.1', NULL, 'i486', 'suse-linux-10.1-cd-x86', '10.1', NULL, 'i486', 'SUSE Linux 10.1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="elogin" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>
', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="identification" description="" page="http://download.novell.com/delivery/reg/suse.jsp" class="tentative">
		<param id="elogin" description=""/>
	</param>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="sound" description="" command="hwinfo --sound"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="regcode-suse"></param>
	<param name="catalog">SUSE-Linux-10.1-Updates</param>
</service>
', 'Y', 'SUSE');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(97, 'SUSE-Linux-10.1-CD-x86', '10.1', NULL, 'i586', 'suse-linux-10.1-cd-x86', '10.1', NULL, 'i586', 'SUSE Linux 10.1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="elogin" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>
', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="identification" description="" page="http://download.novell.com/delivery/reg/suse.jsp" class="tentative">
		<param id="elogin" description=""/>
	</param>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="sound" description="" command="hwinfo --sound"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="regcode-suse"></param>
	<param name="catalog">SUSE-Linux-10.1-Updates</param>
</service>
', 'Y', 'SUSE');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(98, 'SUSE-Linux-10.1-CD-x86', '10.1', NULL, 'i686', 'suse-linux-10.1-cd-x86', '10.1', NULL, 'i686', 'SUSE Linux 10.1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="elogin" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>
', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="identification" description="" page="http://download.novell.com/delivery/reg/suse.jsp" class="tentative">
		<param id="elogin" description=""/>
	</param>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="sound" description="" command="hwinfo --sound"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="regcode-suse"></param>
	<param name="catalog">SUSE-Linux-10.1-Updates</param>
</service>
', 'Y', 'SUSE');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(99, 'SUSE-Linux-10.1-DVD-OSS-i386', '10.1', NULL, 'i486', 'suse-linux-10.1-dvd-oss-i386', '10.1', NULL, 'i486', 'SUSE Linux 10.1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="elogin" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>
', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="identification" description="" page="http://download.novell.com/delivery/reg/suse.jsp" class="tentative">
		<param id="elogin" description=""/>
	</param>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="sound" description="" command="hwinfo --sound"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="regcode-suse"></param>
	<param name="catalog">SUSE-Linux-10.1-Updates</param>
</service>
', 'Y', 'SUSE');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(100, 'SUSE-Linux-10.1-DVD-OSS-i386', '10.1', NULL, 'i586', 'suse-linux-10.1-dvd-oss-i386', '10.1', NULL, 'i586', 'SUSE Linux 10.1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="elogin" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>
', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="identification" description="" page="http://download.novell.com/delivery/reg/suse.jsp" class="tentative">
		<param id="elogin" description=""/>
	</param>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="sound" description="" command="hwinfo --sound"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="regcode-suse"></param>
	<param name="catalog">SUSE-Linux-10.1-Updates</param>
</service>
', 'Y', 'SUSE');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(101, 'SUSE-Linux-10.1-DVD-OSS-i386', '10.1', NULL, 'i686', 'suse-linux-10.1-dvd-oss-i386', '10.1', NULL, 'i686', 'SUSE Linux 10.1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="elogin" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>
', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="identification" description="" page="http://download.novell.com/delivery/reg/suse.jsp" class="tentative">
		<param id="elogin" description=""/>
	</param>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="sound" description="" command="hwinfo --sound"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="regcode-suse"></param>
	<param name="catalog">SUSE-Linux-10.1-Updates</param>
</service>
', 'Y', 'SUSE');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(102, 'SUSE-Linux-10.1-DVD-i386', '10.1', NULL, 'i486', 'suse-linux-10.1-dvd-i386', '10.1', NULL, 'i486', 'SUSE Linux 10.1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="elogin" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>
', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="identification" description="" page="http://download.novell.com/delivery/reg/suse.jsp" class="tentative">
		<param id="elogin" description=""/>
	</param>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="sound" description="" command="hwinfo --sound"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="regcode-suse"></param>
	<param name="catalog">SUSE-Linux-10.1-Updates</param>
</service>
', 'Y', 'SUSE');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(103, 'SUSE-Linux-10.1-DVD-i386', '10.1', NULL, 'i586', 'suse-linux-10.1-dvd-i386', '10.1', NULL, 'i586', 'SUSE Linux 10.1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="elogin" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>
', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="identification" description="" page="http://download.novell.com/delivery/reg/suse.jsp" class="tentative">
		<param id="elogin" description=""/>
	</param>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="sound" description="" command="hwinfo --sound"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="regcode-suse"></param>
	<param name="catalog">SUSE-Linux-10.1-Updates</param>
</service>
', 'Y', 'SUSE');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(104, 'SUSE-Linux-10.1-DVD-i386', '10.1', NULL, 'i686', 'suse-linux-10.1-dvd-i386', '10.1', NULL, 'i686', 'SUSE Linux 10.1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="elogin" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>
', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="identification" description="" page="http://download.novell.com/delivery/reg/suse.jsp" class="tentative">
		<param id="elogin" description=""/>
	</param>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="sound" description="" command="hwinfo --sound"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="regcode-suse"></param>
	<param name="catalog">SUSE-Linux-10.1-Updates</param>
</service>
', 'Y', 'SUSE');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(105, 'SUSE-Linux-10.1-OSS-DVD-x86', '10.1', NULL, 'i486', 'suse-linux-10.1-oss-dvd-x86', '10.1', NULL, 'i486', 'SUSE Linux 10.1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="elogin" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>
', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="identification" description="" page="http://download.novell.com/delivery/reg/suse.jsp" class="tentative">
		<param id="elogin" description=""/>
	</param>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="sound" description="" command="hwinfo --sound"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="regcode-suse"></param>
	<param name="catalog">SUSE-Linux-10.1-Updates</param>
</service>
', 'Y', 'SUSE');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(106, 'SUSE-Linux-10.1-OSS-DVD-x86', '10.1', NULL, 'i586', 'suse-linux-10.1-oss-dvd-x86', '10.1', NULL, 'i586', 'SUSE Linux 10.1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="elogin" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>
', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="identification" description="" page="http://download.novell.com/delivery/reg/suse.jsp" class="tentative">
		<param id="elogin" description=""/>
	</param>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="sound" description="" command="hwinfo --sound"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="regcode-suse"></param>
	<param name="catalog">SUSE-Linux-10.1-Updates</param>
</service>
', 'Y', 'SUSE');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(107, 'SUSE-Linux-10.1-OSS-DVD-x86', '10.1', NULL, 'i686', 'suse-linux-10.1-oss-dvd-x86', '10.1', NULL, 'i686', 'SUSE Linux 10.1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="elogin" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>
', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="identification" description="" page="http://download.novell.com/delivery/reg/suse.jsp" class="tentative">
		<param id="elogin" description=""/>
	</param>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="sound" description="" command="hwinfo --sound"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="regcode-suse"></param>
	<param name="catalog">SUSE-Linux-10.1-Updates</param>
</service>
', 'Y', 'SUSE');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(108, 'SuSE-Linux-10.1-PromoDVD-i386', '10.1', NULL, 'i486', 'suse-linux-10.1-promodvd-i386', '10.1', NULL, 'i486', 'SUSE Linux 10.1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="elogin" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>
', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="identification" description="" page="http://download.novell.com/delivery/reg/suse.jsp" class="tentative">
		<param id="elogin" description=""/>
	</param>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="sound" description="" command="hwinfo --sound"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="regcode-suse"></param>
	<param name="catalog">SUSE-Linux-10.1-Updates</param>
</service>
', 'Y', 'SUSE');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(109, 'SuSE-Linux-10.1-PromoDVD-i386', '10.1', NULL, 'i586', 'suse-linux-10.1-promodvd-i386', '10.1', NULL, 'i586', 'SUSE Linux 10.1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="elogin" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>
', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="identification" description="" page="http://download.novell.com/delivery/reg/suse.jsp" class="tentative">
		<param id="elogin" description=""/>
	</param>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="sound" description="" command="hwinfo --sound"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="regcode-suse"></param>
	<param name="catalog">SUSE-Linux-10.1-Updates</param>
</service>
', 'Y', 'SUSE');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(110, 'SuSE-Linux-10.1-PromoDVD-i386', '10.1', NULL, 'i686', 'suse-linux-10.1-promodvd-i386', '10.1', NULL, 'i686', 'SUSE Linux 10.1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="elogin" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>
', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="identification" description="" page="http://download.novell.com/delivery/reg/suse.jsp" class="tentative">
		<param id="elogin" description=""/>
	</param>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="sound" description="" command="hwinfo --sound"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="regcode-suse"></param>
	<param name="catalog">SUSE-Linux-10.1-Updates</param>
</service>
', 'Y', 'SUSE');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(111, 'SUSE-Linux-CD-OSS-i386', '10.1', NULL, 'i486', 'suse-linux-cd-oss-i386', '10.1', NULL, 'i486', 'SUSE Linux 10.1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="elogin" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="identification" description="" page="http://download.novell.com/delivery/reg/suse.jsp" class="tentative">
		<param id="elogin" description=""/>
	</param>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="sound" description="" command="hwinfo --sound"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="regcode-suse"></param>
	<param name="catalog">SUSE-Linux-10.1-Updates</param>
</service>', NULL, 'SUSE');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(112, 'SUSE-Linux-CD-OSS-i386', '10.1', NULL, 'i586', 'suse-linux-cd-oss-i386', '10.1', NULL, 'i586', 'SUSE Linux 10.1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="elogin" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="identification" description="" page="http://download.novell.com/delivery/reg/suse.jsp" class="tentative">
		<param id="elogin" description=""/>
	</param>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="sound" description="" command="hwinfo --sound"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="regcode-suse"></param>
	<param name="catalog">SUSE-Linux-10.1-Updates</param>
</service>', NULL, 'SUSE');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(113, 'SUSE-Linux-CD-OSS-i386', '10.1', NULL, 'i686', 'suse-linux-cd-oss-i386', '10.1', NULL, 'i686', 'SUSE Linux 10.1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="elogin" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="identification" description="" page="http://download.novell.com/delivery/reg/suse.jsp" class="tentative">
		<param id="elogin" description=""/>
	</param>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="sound" description="" command="hwinfo --sound"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="regcode-suse"></param>
	<param name="catalog">SUSE-Linux-10.1-Updates</param>
</service>', NULL, 'SUSE');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(114, 'SUSE-Linux-DVD9-i386', '10.1', NULL, 'i486', 'suse-linux-dvd9-i386', '10.1', NULL, 'i486', 'SUSE Linux 10.1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="elogin" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="identification" description="" page="http://download.novell.com/delivery/reg/suse.jsp" class="tentative">
		<param id="elogin" description=""/>
	</param>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="sound" description="" command="hwinfo --sound"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="regcode-suse"></param>
	<param name="catalog">SUSE-Linux-10.1-Updates</param>
</service>', NULL, 'SUSE');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(115, 'SUSE-Linux-DVD9-i386', '10.1', NULL, 'i586', 'suse-linux-dvd9-i386', '10.1', NULL, 'i586', 'SUSE Linux 10.1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="elogin" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="identification" description="" page="http://download.novell.com/delivery/reg/suse.jsp" class="tentative">
		<param id="elogin" description=""/>
	</param>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="sound" description="" command="hwinfo --sound"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="regcode-suse"></param>
	<param name="catalog">SUSE-Linux-10.1-Updates</param>
</service>', NULL, 'SUSE');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(116, 'SUSE-Linux-DVD9-i386', '10.1', NULL, 'i686', 'suse-linux-dvd9-i386', '10.1', NULL, 'i686', 'SUSE Linux 10.1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="elogin" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="identification" description="" page="http://download.novell.com/delivery/reg/suse.jsp" class="tentative">
		<param id="elogin" description=""/>
	</param>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="sound" description="" command="hwinfo --sound"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="regcode-suse"></param>
	<param name="catalog">SUSE-Linux-10.1-Updates</param>
</service>', NULL, 'SUSE');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(125, 'SUSE-Linux-10.1-DVD9-x86-x86_64', '10.1', NULL, 'i386', 'suse-linux-10.1-dvd9-x86-x86_64', '10.1', NULL, 'i386', 'SUSE Linux 10.1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="elogin" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="identification" description="" page="http://download.novell.com/delivery/reg/suse.jsp" class="tentative">
		<param id="elogin" description=""/>
	</param>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="sound" description="" command="hwinfo --sound"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="regcode-suse"></param>
	<param name="catalog">SUSE-Linux-10.1-Updates</param>
</service>', 'Y', 'SUSE');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(126, 'SUSE-Linux-10.1-DVD9-x86-x86_64', '10.1', NULL, 'i486', 'suse-linux-10.1-dvd9-x86-x86_64', '10.1', NULL, 'i486', 'SUSE Linux 10.1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="elogin" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="identification" description="" page="http://download.novell.com/delivery/reg/suse.jsp" class="tentative">
		<param id="elogin" description=""/>
	</param>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="sound" description="" command="hwinfo --sound"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="regcode-suse"></param>
	<param name="catalog">SUSE-Linux-10.1-Updates</param>
</service>', 'Y', 'SUSE');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(127, 'SUSE-Linux-10.1-DVD9-x86-x86_64', '10.1', NULL, 'i586', 'suse-linux-10.1-dvd9-x86-x86_64', '10.1', NULL, 'i586', 'SUSE Linux 10.1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="elogin" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="identification" description="" page="http://download.novell.com/delivery/reg/suse.jsp" class="tentative">
		<param id="elogin" description=""/>
	</param>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="sound" description="" command="hwinfo --sound"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="regcode-suse"></param>
	<param name="catalog">SUSE-Linux-10.1-Updates</param>
</service>', 'Y', 'SUSE');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(128, 'SUSE-Linux-10.1-DVD9-x86-x86_64', '10.1', NULL, 'i686', 'suse-linux-10.1-dvd9-x86-x86_64', '10.1', NULL, 'i686', 'SUSE Linux 10.1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="elogin" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="identification" description="" page="http://download.novell.com/delivery/reg/suse.jsp" class="tentative">
		<param id="elogin" description=""/>
	</param>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="sound" description="" command="hwinfo --sound"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="regcode-suse"></param>
	<param name="catalog">SUSE-Linux-10.1-Updates</param>
</service>', 'Y', 'SUSE');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(136, 'SUSE-Linux-10.1-DVD9-CTMAGAZIN-x86-x86_64', '10.1', NULL, 'i686', 'suse-linux-10.1-dvd9-ctmagazin-x86-x86_64', '10.1', NULL, 'i686', 'SUSE Linux 10.1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="elogin" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="identification" description="" page="http://download.novell.com/delivery/reg/suse.jsp" class="tentative">
		<param id="elogin" description=""/>
	</param>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="sound" description="" command="hwinfo --sound"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="regcode-suse"></param>
	<param name="catalog">SUSE-Linux-10.1-Updates</param>
</service>', 'Y', 'SUSE');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(137, 'SUSE-Linux-10.1-DVD9-CTMAGAZIN-x86-x86_64', '10.1', NULL, 'i586', 'suse-linux-10.1-dvd9-ctmagazin-x86-x86_64', '10.1', NULL, 'i586', 'SUSE Linux 10.1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="elogin" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="identification" description="" page="http://download.novell.com/delivery/reg/suse.jsp" class="tentative">
		<param id="elogin" description=""/>
	</param>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="sound" description="" command="hwinfo --sound"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="regcode-suse"></param>
	<param name="catalog">SUSE-Linux-10.1-Updates</param>
</service>', 'Y', 'SUSE');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(138, 'SUSE-Linux-10.1-DVD9-CTMAGAZIN-x86-x86_64', '10.1', NULL, 'i486', 'suse-linux-10.1-dvd9-ctmagazin-x86-x86_64', '10.1', NULL, 'i486', 'SUSE Linux 10.1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="elogin" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="identification" description="" page="http://download.novell.com/delivery/reg/suse.jsp" class="tentative">
		<param id="elogin" description=""/>
	</param>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="sound" description="" command="hwinfo --sound"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="regcode-suse"></param>
	<param name="catalog">SUSE-Linux-10.1-Updates</param>
</service>', 'Y', 'SUSE');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(139, 'SUSE-Linux-10.1-DVD9-CTMAGAZIN-x86-x86_64', '10.1', NULL, 'i386', 'suse-linux-10.1-dvd9-ctmagazin-x86-x86_64', '10.1', NULL, 'i386', 'SUSE Linux 10.1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="elogin" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="identification" description="" page="http://download.novell.com/delivery/reg/suse.jsp" class="tentative">
		<param id="elogin" description=""/>
	</param>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="sound" description="" command="hwinfo --sound"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="regcode-suse"></param>
	<param name="catalog">SUSE-Linux-10.1-Updates</param>
</service>', 'Y', 'SUSE');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(140, 'SUSE-Linux-10.1-DVD9-CTMAGAZIN-x86-x86_64', '10.1', NULL, 'x86_64', 'suse-linux-10.1-dvd9-ctmagazin-x86-x86_64', '10.1', NULL, 'x86_64', 'SUSE Linux 10.1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="elogin" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="identification" description="" page="http://download.novell.com/delivery/reg/suse.jsp" class="tentative">
		<param id="elogin" description=""/>
	</param>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="sound" description="" command="hwinfo --sound"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="regcode-suse"></param>
	<param name="catalog">SUSE-Linux-10.1-Updates</param>
</service>', 'Y', 'SUSE');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(141, 'nVidia Video Drivers', NULL, NULL, NULL, 'nvidia video drivers', NULL, NULL, NULL, 'nVidia Video Drivers', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="hw_inventory" description="">
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" type="${mirror:type}" description="${mirror:name}">
	<param id="url">${mirror:url}</param>
	<param name="catalog">download_nvidia_com</param>
</service>', 'Y', 'nVidia');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(142, 'ATI Video Drivers', NULL, NULL, NULL, 'ati video drivers', NULL, NULL, NULL, 'ATI Video Drivers', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="hw_inventory" description="">
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" type="${mirror:type}" description="${mirror:name}">
	<param id="url">${mirror:url}</param>
	<param name="catalog">www2_ati_com</param>
</service>', 'Y', 'ATI');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(157, 'SUSE-Linux-10.1.42-CD-download-x86', '10.1.1', NULL, NULL, 'suse-linux-10.1.42-cd-download-x86', '10.1.1', NULL, NULL, 'SUSE Linux 10.2', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="elogin" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>
', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="identification" description="" page="http://download.novell.com/delivery/reg/suse.jsp" class="tentative">
		<param id="elogin" description=""/>
	</param>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="sound" description="" command="hwinfo --sound"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="regcode-suse"></param>
	<param name="catalog">SUSE-Linux-10.1-Updates</param>
</service>
', NULL, 'SUSE');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(159, 'SUSE-Linux-10.1.42-CD-download-ppc', '10.1.1', NULL, NULL, 'suse-linux-10.1.42-cd-download-ppc', '10.1.1', NULL, NULL, 'SUSE Linux 10.2', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="elogin" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>
', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="identification" description="" page="http://download.novell.com/delivery/reg/suse.jsp" class="tentative">
		<param id="elogin" description=""/>
	</param>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="sound" description="" command="hwinfo --sound"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="regcode-suse"></param>
	<param name="catalog">SUSE-Linux-10.1-Updates</param>
</service>
', NULL, 'SUSE');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(156, 'SUSE-Linux-10.1.42-CD-download', '10.1.1', NULL, NULL, 'suse-linux-10.1.42-cd-download', '10.1.1', NULL, NULL, 'SUSE Linux 10.2', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="elogin" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>
', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="identification" description="" page="http://download.novell.com/delivery/reg/suse.jsp" class="tentative">
		<param id="elogin" description=""/>
	</param>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="sound" description="" command="hwinfo --sound"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="regcode-suse"></param>
	<param name="catalog">SUSE-Linux-10.1-Updates</param>
</service>
', NULL, 'SUSE');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(158, 'SUSE-Linux-10.1.42-CD-download-x86_64', '10.1.1', NULL, NULL, 'suse-linux-10.1.42-cd-download-x86_64', '10.1.1', NULL, NULL, 'SUSE Linux 10.2', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="elogin" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>
', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="identification" description="" page="http://download.novell.com/delivery/reg/suse.jsp" class="tentative">
		<param id="elogin" description=""/>
	</param>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="sound" description="" command="hwinfo --sound"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="regcode-suse"></param>
	<param name="catalog">SUSE-Linux-10.1-Updates</param>
</service>
', NULL, 'SUSE');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(176, 'SUSE-Linux-Enterprise-SDK-i386', '10', NULL, NULL, 'suse-linux-enterprise-sdk-i386', '10', NULL, NULL, 'SUSE Linux 10 Software Development Kit', NULL, NULL, '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="group">sle10-sdk</param>
</service>', 'Y', 'SDK');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(177, 'SUSE-Linux-Enterprise-SDK-x86_64', '10', NULL, NULL, 'suse-linux-enterprise-sdk-x86_64', '10', NULL, NULL, 'SUSE Linux 10 Software Development Kit', NULL, NULL, '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="group">sle10-sdk</param>
</service>', 'Y', 'SDK');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(178, 'SUSE-Linux-Enterprise-SDK-ia64', '10', NULL, NULL, 'suse-linux-enterprise-sdk-ia64', '10', NULL, NULL, 'SUSE Linux 10 Software Development Kit', NULL, NULL, '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="group">sle10-sdk</param>
</service>', 'Y', 'SDK');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(179, 'SUSE-Linux-Enterprise-SDK-s390x', '10', NULL, NULL, 'suse-linux-enterprise-sdk-s390x', '10', NULL, NULL, 'SUSE Linux 10 Software Development Kit', NULL, NULL, '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="group">sle10-sdk</param>
</service>', 'Y', 'SDK');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(180, 'SUSE-Linux-Enterprise-SDK-ppc', '10', NULL, NULL, 'suse-linux-enterprise-sdk-ppc', '10', NULL, NULL, 'SUSE Linux 10 Software Development Kit', NULL, NULL, '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="group">sle10-sdk</param>
</service>', 'Y', 'SDK');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(200, 'openSUSE-10.1.42-CD-download', '10.1.42', NULL, NULL, 'opensuse-10.1.42-cd-download', '10.1.42', NULL, NULL, 'SUSE Linux 10.2', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="elogin" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>
', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="identification" description="" page="http://download.novell.com/delivery/reg/suse.jsp" class="tentative">
		<param id="elogin" description=""/>
	</param>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="sound" description="" command="hwinfo --sound"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="regcode-suse"></param>
	<param name="catalog">SUSE-Linux-10.2-Updates</param>
</service>
', NULL, 'SUSE');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(236, 'openSUSE-10.2-CD-download', '10.2', NULL, NULL, 'opensuse-10.2-cd-download', '10.2', NULL, NULL, 'SUSE Linux 10.2', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="elogin" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="desktops" description="" command="installed-desktops"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="identification" description="" page="http://download.novell.com/delivery/reg/suse.jsp" class="tentative">
		<param id="elogin" description=""/>
	</param>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="desktops" description="" command="installed-desktops"/>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="sound" description="" command="hwinfo --sound"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="regcode-suse"></param>
	<param name="catalog">SUSE-Linux-10.2-Updates</param>
</service>', 'Y', 'SUSE');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(257, 'SUSE Linux', '10.2', NULL, NULL, 'suse linux', '10.2', NULL, NULL, 'SUSE Linux 10.2', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="elogin" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="desktops" description="" command="installed-desktops"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="identification" description="" page="http://download.novell.com/delivery/reg/suse.jsp" class="tentative">
		<param id="elogin" description=""/>
	</param>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="desktops" description="" command="installed-desktops"/>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="sound" description="" command="hwinfo --sound"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="regcode-suse"></param>
	<param name="catalog">SUSE-Linux-10.2-Updates</param>
</service>', NULL, 'SUSE');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(276, 'SUSE-Linux-Enterprise-RT', '10', NULL, NULL, 'suse-linux-enterprise-rt', '10', NULL, NULL, 'SUSE Linux Enterprise Real-Time 10', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-slert" description="" class="mandatory"/>
	<param id="moniker" description=""/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
		<guid description="" class="mandatory"/>
		<param id="secret" description="" command="zmd-secret" class="mandatory"/>
		<host description=""/>
		<product description="" class="mandatory"/>
		<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
		<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
		<param id="identification" description="" page="reg.jsp?guid={guid}&amp;lang={lang}" class="mandatory">
				<param id="email" description=""/>
		</param>
		<param id="regcode-slert" description="" page="reg.jsp?guid={guid}&amp;lang={lang}" class="mandatory"/>
		<param id="moniker" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
		<param id="sysident" description="">
				<param id="processor" description="" command="uname -p"/>
				<param id="platform" description="" command="uname -i"/>
				<param id="hostname" description="" command="uname -n"/>
		</param>
		<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<group-catalogs/>
</service>', 'Y', 'SLERT');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(296, 'openSUSE', '10.2', NULL, NULL, 'opensuse', '10.2', NULL, NULL, 'openSUSE 10.2', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="elogin" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="desktops" description="" command="installed-desktops"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="identification" description="" page="http://download.novell.com/delivery/reg/suse.jsp" class="tentative">
		<param id="elogin" description=""/>
	</param>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="desktops" description="" command="installed-desktops"/>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="sound" description="" command="hwinfo --sound"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="regcode-suse"></param>
	<param name="catalog">SUSE-Linux-10.2-Updates</param>
</service>', NULL, 'SUSE');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(316, 'SUSE-Linux-Enterprise-SDK-DVD-i386', '10', NULL, NULL, 'suse-linux-enterprise-sdk-dvd-i386', '10', NULL, NULL, 'SUSE Linux 10 Software Development Kit', NULL, NULL, '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="group">sle10-sdk</param>
</service>', 'Y', 'SDK');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(317, 'SUSE-Linux-Enterprise-SDK-DVD-x86_64', '10', NULL, NULL, 'suse-linux-enterprise-sdk-dvd-x86_64', '10', NULL, NULL, 'SUSE Linux 10 Software Development Kit', NULL, NULL, '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="group">sle10-sdk</param>
</service>', 'Y', 'SDK');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(318, 'SUSE-Linux-Enterprise-SDK-DVD-ia64', '10', NULL, NULL, 'suse-linux-enterprise-sdk-dvd-ia64', '10', NULL, NULL, 'SUSE Linux 10 Software Development Kit', NULL, NULL, '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="group">sle10-sdk</param>
</service>', 'Y', 'SDK');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(319, 'SUSE-Linux-Enterprise-SDK-DVD-s390x', '10', NULL, NULL, 'suse-linux-enterprise-sdk-dvd-s390x', '10', NULL, NULL, 'SUSE Linux 10 Software Development Kit', NULL, NULL, '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="group">sle10-sdk</param>
</service>', 'Y', 'SDK');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(320, 'SUSE-Linux-Enterprise-SDK-DVD-ppc', '10', NULL, NULL, 'suse-linux-enterprise-sdk-dvd-ppc', '10', NULL, NULL, 'SUSE Linux 10 Software Development Kit', NULL, NULL, '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="group">sle10-sdk</param>
</service>', 'Y', 'SDK');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(336, 'openSUSE-10.2-dvd5-download', '10.2', NULL, NULL, 'opensuse-10.2-dvd5-download', '10.2', NULL, NULL, 'openSUSE 10.2', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="elogin" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="desktops" description="" command="installed-desktops"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="identification" description="" page="http://download.novell.com/delivery/reg/suse.jsp" class="tentative">
		<param id="elogin" description=""/>
	</param>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="desktops" description="" command="installed-desktops"/>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="sound" description="" command="hwinfo --sound"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="regcode-suse"></param>
	<param name="catalog">SUSE-Linux-10.2-Updates</param>
</service>', 'Y', 'SUSE');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(337, 'openSUSE-10.2-CD-retail', '10.2', NULL, NULL, 'opensuse-10.2-cd-retail', '10.2', NULL, NULL, 'openSUSE 10.2', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="elogin" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="desktops" description="" command="installed-desktops"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="identification" description="" page="http://download.novell.com/delivery/reg/suse.jsp" class="tentative">
		<param id="elogin" description=""/>
	</param>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="desktops" description="" command="installed-desktops"/>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="sound" description="" command="hwinfo --sound"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="regcode-suse"></param>
	<param name="catalog">SUSE-Linux-10.2-Updates</param>
</service>', 'Y', 'SUSE');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(338, 'openSUSE-10.2-DVD9-retail', '10.2', NULL, NULL, 'opensuse-10.2-dvd9-retail', '10.2', NULL, NULL, 'openSUSE 10.2', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="elogin" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="desktops" description="" command="installed-desktops"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="identification" description="" page="http://download.novell.com/delivery/reg/suse.jsp" class="tentative">
		<param id="elogin" description=""/>
	</param>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="desktops" description="" command="installed-desktops"/>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="sound" description="" command="hwinfo --sound"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="regcode-suse"></param>
	<param name="catalog">SUSE-Linux-10.2-Updates</param>
</service>', 'Y', 'SUSE');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(339, 'openSUSE-10.2-Promo', '10.2', NULL, NULL, 'opensuse-10.2-promo', '10.2', NULL, NULL, 'openSUSE 10.2', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="elogin" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="desktops" description="" command="installed-desktops"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="identification" description="" page="http://download.novell.com/delivery/reg/suse.jsp" class="tentative">
		<param id="elogin" description=""/>
	</param>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="desktops" description="" command="installed-desktops"/>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="sound" description="" command="hwinfo --sound"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="regcode-suse"></param>
	<param name="catalog">SUSE-Linux-10.2-Updates</param>
</service>', 'Y', 'SUSE');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(426, 'SUSE-Linux-Enterprise-Server-SP1-migration', '10', NULL, 'ppc', 'suse-linux-enterprise-server-sp1-migration', '10', NULL, 'ppc', 'SUSE Linux Enterprise Server 10 SP1 Migration', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sles" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
    <guid description="" class="mandatory"/>
    <param id="secret" description="" command="zmd-secret" class="mandatory"/>
    <host description=""/>
    <product description="" class="mandatory"/>
    <param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
    <param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
    <param id="regcode-sles" description=""/>
    <param id="moniker" description=""/>
    <param id="sysident" description="">
        <param id="processor" description="" command="uname -p"/>
        <param id="platform" description="" command="uname -i"/>
        <param id="hostname" description="" command="uname -n"/>
    </param>
    <privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo> 
', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="group">sles10-sp1-migration</param>
</service>', 'Y', 'SLES');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(427, 'SUSE-Linux-Enterprise-Server-SP1-migration', '10', NULL, 'ppc64', 'suse-linux-enterprise-server-sp1-migration', '10', NULL, 'ppc64', 'SUSE Linux Enterprise Server 10 SP1 Migration', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sles" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
    <guid description="" class="mandatory"/>
    <param id="secret" description="" command="zmd-secret" class="mandatory"/>
    <host description=""/>
    <product description="" class="mandatory"/>
    <param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
    <param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
    <param id="regcode-sles" description=""/>
    <param id="moniker" description=""/>
    <param id="sysident" description="">
        <param id="processor" description="" command="uname -p"/>
        <param id="platform" description="" command="uname -i"/>
        <param id="hostname" description="" command="uname -n"/>
    </param>
    <privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo> 
', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="group">sles10-sp1-migration</param>
</service>', 'Y', 'SLES');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(428, 'SUSE-Linux-Enterprise-Server-SP1-migration', '10', NULL, 'ia64', 'suse-linux-enterprise-server-sp1-migration', '10', NULL, 'ia64', 'SUSE Linux Enterprise Server 10 SP1 Migration', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sles" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
    <guid description="" class="mandatory"/>
    <param id="secret" description="" command="zmd-secret" class="mandatory"/>
    <host description=""/>
    <product description="" class="mandatory"/>
    <param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
    <param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
    <param id="regcode-sles" description=""/>
    <param id="moniker" description=""/>
    <param id="sysident" description="">
        <param id="processor" description="" command="uname -p"/>
        <param id="platform" description="" command="uname -i"/>
        <param id="hostname" description="" command="uname -n"/>
    </param>
    <privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo> 
', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="group">sles10-sp1-migration</param>
</service>', 'Y', 'SLES');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(429, 'SUSE-Linux-Enterprise-Server-SP1-migration', '10', NULL, 's390', 'suse-linux-enterprise-server-sp1-migration', '10', NULL, 's390', 'SUSE Linux Enterprise Server 10 SP1 Migration', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sles" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
    <guid description="" class="mandatory"/>
    <param id="secret" description="" command="zmd-secret" class="mandatory"/>
    <host description=""/>
    <product description="" class="mandatory"/>
    <param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
    <param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
    <param id="regcode-sles" description=""/>
    <param id="moniker" description=""/>
    <param id="sysident" description="">
        <param id="processor" description="" command="uname -p"/>
        <param id="platform" description="" command="uname -i"/>
        <param id="hostname" description="" command="uname -n"/>
    </param>
    <privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo> 
', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="group">sles10-sp1-migration</param>
</service>', 'Y', 'SLES');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(430, 'SUSE-Linux-Enterprise-Server-SP1-migration', '10', NULL, 's390x', 'suse-linux-enterprise-server-sp1-migration', '10', NULL, 's390x', 'SUSE Linux Enterprise Server 10 SP1 Migration', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sles" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
    <guid description="" class="mandatory"/>
    <param id="secret" description="" command="zmd-secret" class="mandatory"/>
    <host description=""/>
    <product description="" class="mandatory"/>
    <param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
    <param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
    <param id="regcode-sles" description=""/>
    <param id="moniker" description=""/>
    <param id="sysident" description="">
        <param id="processor" description="" command="uname -p"/>
        <param id="platform" description="" command="uname -i"/>
        <param id="hostname" description="" command="uname -n"/>
    </param>
    <privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo> 
', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="group">sles10-sp1-migration</param>
</service>', 'Y', 'SLES');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(431, 'SUSE-Linux-Enterprise-Desktop-SP1', '10', NULL, 'i686', 'suse-linux-enterprise-desktop-sp1', '10', NULL, 'i686', 'SUSE Linux Enterprise Desktop 10 SP1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sled" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="disk" description="" command="hwinfo --disk"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="scsi" description="" command="hwinfo --scsi"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="sys" description="" command="hwinfo --sys"/>
	<param id="tape" description="" command="hwinfo --tape"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="identification" description="" page="reg.jsp?guid={guid}&amp;lang={lang}" class="mandatory">
		<param id="email" description=""/>
	</param>
	<param id="regcode-sled" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="moniker" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
		<param id="sound" description="" command="hwinfo --sound"/>
		<param id="sys" description="" command="hwinfo --sys"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" type="${mirror:type}" description="${mirror:name}">
	<param id="url">${mirror:url}</param>
	<group-catalogs/>
</service>', 'Y', 'SLED');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(432, 'SUSE-Linux-Enterprise-Desktop-SP1', '10', NULL, 'i586', 'suse-linux-enterprise-desktop-sp1', '10', NULL, 'i586', 'SUSE Linux Enterprise Desktop 10 SP1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sled" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="disk" description="" command="hwinfo --disk"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="scsi" description="" command="hwinfo --scsi"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="sys" description="" command="hwinfo --sys"/>
	<param id="tape" description="" command="hwinfo --tape"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="identification" description="" page="reg.jsp?guid={guid}&amp;lang={lang}" class="mandatory">
		<param id="email" description=""/>
	</param>
	<param id="regcode-sled" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="moniker" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
		<param id="sound" description="" command="hwinfo --sound"/>
		<param id="sys" description="" command="hwinfo --sys"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" type="${mirror:type}" description="${mirror:name}">
	<param id="url">${mirror:url}</param>
	<group-catalogs/>
</service>', 'Y', 'SLED');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(433, 'SUSE-Linux-Enterprise-Desktop-SP1', '10', NULL, 'i486', 'suse-linux-enterprise-desktop-sp1', '10', NULL, 'i486', 'SUSE Linux Enterprise Desktop 10 SP1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sled" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="disk" description="" command="hwinfo --disk"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="scsi" description="" command="hwinfo --scsi"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="sys" description="" command="hwinfo --sys"/>
	<param id="tape" description="" command="hwinfo --tape"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="identification" description="" page="reg.jsp?guid={guid}&amp;lang={lang}" class="mandatory">
		<param id="email" description=""/>
	</param>
	<param id="regcode-sled" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="moniker" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
		<param id="sound" description="" command="hwinfo --sound"/>
		<param id="sys" description="" command="hwinfo --sys"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" type="${mirror:type}" description="${mirror:name}">
	<param id="url">${mirror:url}</param>
	<group-catalogs/>
</service>', 'Y', 'SLED');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(434, 'SUSE-Linux-Enterprise-Desktop-SP1', '10', NULL, 'i386', 'suse-linux-enterprise-desktop-sp1', '10', NULL, 'i386', 'SUSE Linux Enterprise Desktop 10 SP1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sled" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="disk" description="" command="hwinfo --disk"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="scsi" description="" command="hwinfo --scsi"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="sys" description="" command="hwinfo --sys"/>
	<param id="tape" description="" command="hwinfo --tape"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="identification" description="" page="reg.jsp?guid={guid}&amp;lang={lang}" class="mandatory">
		<param id="email" description=""/>
	</param>
	<param id="regcode-sled" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="moniker" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
		<param id="sound" description="" command="hwinfo --sound"/>
		<param id="sys" description="" command="hwinfo --sys"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" type="${mirror:type}" description="${mirror:name}">
	<param id="url">${mirror:url}</param>
	<group-catalogs/>
</service>', 'Y', 'SLED');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(435, 'SUSE-Linux-Enterprise-Desktop-SP1', '10', NULL, 'x86_64', 'suse-linux-enterprise-desktop-sp1', '10', NULL, 'x86_64', 'SUSE Linux Enterprise Desktop 10 SP1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sled" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="disk" description="" command="hwinfo --disk"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="scsi" description="" command="hwinfo --scsi"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="sys" description="" command="hwinfo --sys"/>
	<param id="tape" description="" command="hwinfo --tape"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="identification" description="" page="reg.jsp?guid={guid}&amp;lang={lang}" class="mandatory">
		<param id="email" description=""/>
	</param>
	<param id="regcode-sled" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="moniker" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
		<param id="sound" description="" command="hwinfo --sound"/>
		<param id="sys" description="" command="hwinfo --sys"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" type="${mirror:type}" description="${mirror:name}">
	<param id="url">${mirror:url}</param>
	<group-catalogs/>
</service>', 'Y', 'SLED');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(436, 'SUSE-Linux-Enterprise-Server-SP1', '10', NULL, 'i686', 'suse-linux-enterprise-server-sp1', '10', NULL, 'i686', 'SUSE Linux Enterprise Server 10 SP1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sles" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="disk" description="" command="hwinfo --disk"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="scsi" description="" command="hwinfo --scsi"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="sys" description="" command="hwinfo --sys"/>
	<param id="tape" description="" command="hwinfo --tape"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="identification" description="" page="reg.jsp?guid={guid}&amp;lang={lang}" class="mandatory">
		<param id="email" description=""/>
	</param>
	<param id="regcode-sles" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="moniker" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="disk" description="" command="hwinfo --disk"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
		<param id="scsi" description="" command="hwinfo --scsi"/>
		<param id="sound" description="" command="hwinfo --sound"/>
		<param id="sys" description="" command="hwinfo --sys"/>
		<param id="tape" description="" command="hwinfo --tape"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<group-catalogs/>
</service>', 'Y', 'SLES');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(437, 'SUSE-Linux-Enterprise-Server-SP1', '10', NULL, 'i586', 'suse-linux-enterprise-server-sp1', '10', NULL, 'i586', 'SUSE Linux Enterprise Server 10 SP1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sles" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="disk" description="" command="hwinfo --disk"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="scsi" description="" command="hwinfo --scsi"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="sys" description="" command="hwinfo --sys"/>
	<param id="tape" description="" command="hwinfo --tape"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="identification" description="" page="reg.jsp?guid={guid}&amp;lang={lang}" class="mandatory">
		<param id="email" description=""/>
	</param>
	<param id="regcode-sles" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="moniker" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="disk" description="" command="hwinfo --disk"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
		<param id="scsi" description="" command="hwinfo --scsi"/>
		<param id="sound" description="" command="hwinfo --sound"/>
		<param id="sys" description="" command="hwinfo --sys"/>
		<param id="tape" description="" command="hwinfo --tape"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<group-catalogs/>
</service>', 'Y', 'SLES');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(438, 'SUSE-Linux-Enterprise-Server-SP1', '10', NULL, 'i486', 'suse-linux-enterprise-server-sp1', '10', NULL, 'i486', 'SUSE Linux Enterprise Server 10 SP1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sles" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="disk" description="" command="hwinfo --disk"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="scsi" description="" command="hwinfo --scsi"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="sys" description="" command="hwinfo --sys"/>
	<param id="tape" description="" command="hwinfo --tape"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="identification" description="" page="reg.jsp?guid={guid}&amp;lang={lang}" class="mandatory">
		<param id="email" description=""/>
	</param>
	<param id="regcode-sles" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="moniker" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="disk" description="" command="hwinfo --disk"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
		<param id="scsi" description="" command="hwinfo --scsi"/>
		<param id="sound" description="" command="hwinfo --sound"/>
		<param id="sys" description="" command="hwinfo --sys"/>
		<param id="tape" description="" command="hwinfo --tape"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<group-catalogs/>
</service>', 'Y', 'SLES');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(439, 'SUSE-Linux-Enterprise-Server-SP1', '10', NULL, 'i386', 'suse-linux-enterprise-server-sp1', '10', NULL, 'i386', 'SUSE Linux Enterprise Server 10 SP1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sles" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="disk" description="" command="hwinfo --disk"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="scsi" description="" command="hwinfo --scsi"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="sys" description="" command="hwinfo --sys"/>
	<param id="tape" description="" command="hwinfo --tape"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="identification" description="" page="reg.jsp?guid={guid}&amp;lang={lang}" class="mandatory">
		<param id="email" description=""/>
	</param>
	<param id="regcode-sles" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="moniker" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="disk" description="" command="hwinfo --disk"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
		<param id="scsi" description="" command="hwinfo --scsi"/>
		<param id="sound" description="" command="hwinfo --sound"/>
		<param id="sys" description="" command="hwinfo --sys"/>
		<param id="tape" description="" command="hwinfo --tape"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<group-catalogs/>
</service>', 'Y', 'SLES');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(440, 'SUSE-Linux-Enterprise-Server-SP1', '10', NULL, 'x86_64', 'suse-linux-enterprise-server-sp1', '10', NULL, 'x86_64', 'SUSE Linux Enterprise Server 10 SP1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sles" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="disk" description="" command="hwinfo --disk"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="scsi" description="" command="hwinfo --scsi"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="sys" description="" command="hwinfo --sys"/>
	<param id="tape" description="" command="hwinfo --tape"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="identification" description="" page="reg.jsp?guid={guid}&amp;lang={lang}" class="mandatory">
		<param id="email" description=""/>
	</param>
	<param id="regcode-sles" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="moniker" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="disk" description="" command="hwinfo --disk"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
		<param id="scsi" description="" command="hwinfo --scsi"/>
		<param id="sound" description="" command="hwinfo --sound"/>
		<param id="sys" description="" command="hwinfo --sys"/>
		<param id="tape" description="" command="hwinfo --tape"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<group-catalogs/>
</service>', 'Y', 'SLES');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(441, 'SUSE-Linux-Enterprise-Server-SP1', '10', NULL, 'ppc', 'suse-linux-enterprise-server-sp1', '10', NULL, 'ppc', 'SUSE Linux Enterprise Server 10 SP1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sles" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="disk" description="" command="hwinfo --disk"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="scsi" description="" command="hwinfo --scsi"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="sys" description="" command="hwinfo --sys"/>
	<param id="tape" description="" command="hwinfo --tape"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="identification" description="" page="reg.jsp?guid={guid}&amp;lang={lang}" class="mandatory">
		<param id="email" description=""/>
	</param>
	<param id="regcode-sles" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="moniker" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="disk" description="" command="hwinfo --disk"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
		<param id="scsi" description="" command="hwinfo --scsi"/>
		<param id="sound" description="" command="hwinfo --sound"/>
		<param id="sys" description="" command="hwinfo --sys"/>
		<param id="tape" description="" command="hwinfo --tape"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<group-catalogs/>
</service>', 'Y', 'SLES');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(442, 'SUSE-Linux-Enterprise-Server-SP1', '10', NULL, 'ppc64', 'suse-linux-enterprise-server-sp1', '10', NULL, 'ppc64', 'SUSE Linux Enterprise Server 10 SP1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sles" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="disk" description="" command="hwinfo --disk"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="scsi" description="" command="hwinfo --scsi"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="sys" description="" command="hwinfo --sys"/>
	<param id="tape" description="" command="hwinfo --tape"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="identification" description="" page="reg.jsp?guid={guid}&amp;lang={lang}" class="mandatory">
		<param id="email" description=""/>
	</param>
	<param id="regcode-sles" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="moniker" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="disk" description="" command="hwinfo --disk"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
		<param id="scsi" description="" command="hwinfo --scsi"/>
		<param id="sound" description="" command="hwinfo --sound"/>
		<param id="sys" description="" command="hwinfo --sys"/>
		<param id="tape" description="" command="hwinfo --tape"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<group-catalogs/>
</service>', 'Y', 'SLES');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(443, 'SUSE-Linux-Enterprise-Server-SP1', '10', NULL, 'ia64', 'suse-linux-enterprise-server-sp1', '10', NULL, 'ia64', 'SUSE Linux Enterprise Server 10 SP1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sles" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="disk" description="" command="hwinfo --disk"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="scsi" description="" command="hwinfo --scsi"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="sys" description="" command="hwinfo --sys"/>
	<param id="tape" description="" command="hwinfo --tape"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="identification" description="" page="reg.jsp?guid={guid}&amp;lang={lang}" class="mandatory">
		<param id="email" description=""/>
	</param>
	<param id="regcode-sles" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="moniker" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="disk" description="" command="hwinfo --disk"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
		<param id="scsi" description="" command="hwinfo --scsi"/>
		<param id="sound" description="" command="hwinfo --sound"/>
		<param id="sys" description="" command="hwinfo --sys"/>
		<param id="tape" description="" command="hwinfo --tape"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<group-catalogs/>
</service>', 'Y', 'SLES');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(444, 'SUSE-Linux-Enterprise-Server-SP1', '10', NULL, 's390', 'suse-linux-enterprise-server-sp1', '10', NULL, 's390', 'SUSE Linux Enterprise Server 10 SP1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sles" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="disk" description="" command="hwinfo --disk"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="scsi" description="" command="hwinfo --scsi"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="sys" description="" command="hwinfo --sys"/>
	<param id="tape" description="" command="hwinfo --tape"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="identification" description="" page="reg.jsp?guid={guid}&amp;lang={lang}" class="mandatory">
		<param id="email" description=""/>
	</param>
	<param id="regcode-sles" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="moniker" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="disk" description="" command="hwinfo --disk"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
		<param id="scsi" description="" command="hwinfo --scsi"/>
		<param id="sound" description="" command="hwinfo --sound"/>
		<param id="sys" description="" command="hwinfo --sys"/>
		<param id="tape" description="" command="hwinfo --tape"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<group-catalogs/>
</service>', 'Y', 'SLES');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(445, 'SUSE-Linux-Enterprise-Server-SP1', '10', NULL, 's390x', 'suse-linux-enterprise-server-sp1', '10', NULL, 's390x', 'SUSE Linux Enterprise Server 10 SP1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sles" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="disk" description="" command="hwinfo --disk"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="scsi" description="" command="hwinfo --scsi"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="sys" description="" command="hwinfo --sys"/>
	<param id="tape" description="" command="hwinfo --tape"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="identification" description="" page="reg.jsp?guid={guid}&amp;lang={lang}" class="mandatory">
		<param id="email" description=""/>
	</param>
	<param id="regcode-sles" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="moniker" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="disk" description="" command="hwinfo --disk"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
		<param id="scsi" description="" command="hwinfo --scsi"/>
		<param id="sound" description="" command="hwinfo --sound"/>
		<param id="sys" description="" command="hwinfo --sys"/>
		<param id="tape" description="" command="hwinfo --tape"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<group-catalogs/>
</service>', 'Y', 'SLES');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(446, 'SUSE-Linux-Enterprise-Desktop-SP1', '10', 'online', 'i686', 'suse-linux-enterprise-desktop-sp1', '10', 'online', 'i686', 'SUSE Linux Enterprise Desktop 10 SP1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sled" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="disk" description="" command="hwinfo --disk"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="scsi" description="" command="hwinfo --scsi"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="sys" description="" command="hwinfo --sys"/>
	<param id="tape" description="" command="hwinfo --tape"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="identification" description="" page="reg.jsp?guid={guid}&amp;lang={lang}" class="mandatory">
		<param id="email" description=""/>
	</param>
	<param id="regcode-sled" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="moniker" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
		<param id="sound" description="" command="hwinfo --sound"/>
		<param id="sys" description="" command="hwinfo --sys"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" type="${mirror:type}" description="${mirror:name}">
	<param id="url">${mirror:url}</param>
	<group-catalogs/>
</service>', 'Y', 'SLED');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(447, 'SUSE-Linux-Enterprise-Desktop-SP1', '10', 'online', 'i586', 'suse-linux-enterprise-desktop-sp1', '10', 'online', 'i586', 'SUSE Linux Enterprise Desktop 10 SP1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sled" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="disk" description="" command="hwinfo --disk"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="scsi" description="" command="hwinfo --scsi"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="sys" description="" command="hwinfo --sys"/>
	<param id="tape" description="" command="hwinfo --tape"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="identification" description="" page="reg.jsp?guid={guid}&amp;lang={lang}" class="mandatory">
		<param id="email" description=""/>
	</param>
	<param id="regcode-sled" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="moniker" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
		<param id="sound" description="" command="hwinfo --sound"/>
		<param id="sys" description="" command="hwinfo --sys"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" type="${mirror:type}" description="${mirror:name}">
	<param id="url">${mirror:url}</param>
	<group-catalogs/>
</service>', 'Y', 'SLED');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(448, 'SUSE-Linux-Enterprise-Desktop-SP1', '10', 'online', 'i486', 'suse-linux-enterprise-desktop-sp1', '10', 'online', 'i486', 'SUSE Linux Enterprise Desktop 10 SP1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sled" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="disk" description="" command="hwinfo --disk"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="scsi" description="" command="hwinfo --scsi"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="sys" description="" command="hwinfo --sys"/>
	<param id="tape" description="" command="hwinfo --tape"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="identification" description="" page="reg.jsp?guid={guid}&amp;lang={lang}" class="mandatory">
		<param id="email" description=""/>
	</param>
	<param id="regcode-sled" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="moniker" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
		<param id="sound" description="" command="hwinfo --sound"/>
		<param id="sys" description="" command="hwinfo --sys"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" type="${mirror:type}" description="${mirror:name}">
	<param id="url">${mirror:url}</param>
	<group-catalogs/>
</service>', 'Y', 'SLED');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(449, 'SUSE-Linux-Enterprise-Desktop-SP1', '10', 'online', 'i386', 'suse-linux-enterprise-desktop-sp1', '10', 'online', 'i386', 'SUSE Linux Enterprise Desktop 10 SP1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sled" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="disk" description="" command="hwinfo --disk"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="scsi" description="" command="hwinfo --scsi"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="sys" description="" command="hwinfo --sys"/>
	<param id="tape" description="" command="hwinfo --tape"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="identification" description="" page="reg.jsp?guid={guid}&amp;lang={lang}" class="mandatory">
		<param id="email" description=""/>
	</param>
	<param id="regcode-sled" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="moniker" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
		<param id="sound" description="" command="hwinfo --sound"/>
		<param id="sys" description="" command="hwinfo --sys"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" type="${mirror:type}" description="${mirror:name}">
	<param id="url">${mirror:url}</param>
	<group-catalogs/>
</service>', 'Y', 'SLED');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(450, 'SUSE-Linux-Enterprise-Desktop-SP1', '10', 'online', 'x86_64', 'suse-linux-enterprise-desktop-sp1', '10', 'online', 'x86_64', 'SUSE Linux Enterprise Desktop 10 SP1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sled" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="disk" description="" command="hwinfo --disk"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="scsi" description="" command="hwinfo --scsi"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="sys" description="" command="hwinfo --sys"/>
	<param id="tape" description="" command="hwinfo --tape"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="identification" description="" page="reg.jsp?guid={guid}&amp;lang={lang}" class="mandatory">
		<param id="email" description=""/>
	</param>
	<param id="regcode-sled" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="moniker" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
		<param id="sound" description="" command="hwinfo --sound"/>
		<param id="sys" description="" command="hwinfo --sys"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" type="${mirror:type}" description="${mirror:name}">
	<param id="url">${mirror:url}</param>
	<group-catalogs/>
</service>', 'Y', 'SLED');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(451, 'SUSE-Linux-Enterprise-Server-SP1', '10', 'online', 'i686', 'suse-linux-enterprise-server-sp1', '10', 'online', 'i686', 'SUSE Linux Enterprise Server 10 SP1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sles" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="disk" description="" command="hwinfo --disk"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="scsi" description="" command="hwinfo --scsi"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="sys" description="" command="hwinfo --sys"/>
	<param id="tape" description="" command="hwinfo --tape"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="identification" description="" page="reg.jsp?guid={guid}&amp;lang={lang}" class="mandatory">
		<param id="email" description=""/>
	</param>
	<param id="regcode-sles" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="moniker" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="disk" description="" command="hwinfo --disk"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
		<param id="scsi" description="" command="hwinfo --scsi"/>
		<param id="sound" description="" command="hwinfo --sound"/>
		<param id="sys" description="" command="hwinfo --sys"/>
		<param id="tape" description="" command="hwinfo --tape"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<group-catalogs/>
</service>', 'Y', 'SLES');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(452, 'SUSE-Linux-Enterprise-Server-SP1', '10', 'online', 'i586', 'suse-linux-enterprise-server-sp1', '10', 'online', 'i586', 'SUSE Linux Enterprise Server 10 SP1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sles" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="disk" description="" command="hwinfo --disk"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="scsi" description="" command="hwinfo --scsi"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="sys" description="" command="hwinfo --sys"/>
	<param id="tape" description="" command="hwinfo --tape"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="identification" description="" page="reg.jsp?guid={guid}&amp;lang={lang}" class="mandatory">
		<param id="email" description=""/>
	</param>
	<param id="regcode-sles" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="moniker" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="disk" description="" command="hwinfo --disk"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
		<param id="scsi" description="" command="hwinfo --scsi"/>
		<param id="sound" description="" command="hwinfo --sound"/>
		<param id="sys" description="" command="hwinfo --sys"/>
		<param id="tape" description="" command="hwinfo --tape"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<group-catalogs/>
</service>', 'Y', 'SLES');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(453, 'SUSE-Linux-Enterprise-Server-SP1', '10', 'online', 'i486', 'suse-linux-enterprise-server-sp1', '10', 'online', 'i486', 'SUSE Linux Enterprise Server 10 SP1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sles" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="disk" description="" command="hwinfo --disk"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="scsi" description="" command="hwinfo --scsi"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="sys" description="" command="hwinfo --sys"/>
	<param id="tape" description="" command="hwinfo --tape"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="identification" description="" page="reg.jsp?guid={guid}&amp;lang={lang}" class="mandatory">
		<param id="email" description=""/>
	</param>
	<param id="regcode-sles" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="moniker" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="disk" description="" command="hwinfo --disk"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
		<param id="scsi" description="" command="hwinfo --scsi"/>
		<param id="sound" description="" command="hwinfo --sound"/>
		<param id="sys" description="" command="hwinfo --sys"/>
		<param id="tape" description="" command="hwinfo --tape"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<group-catalogs/>
</service>', 'Y', 'SLES');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(454, 'SUSE-Linux-Enterprise-Server-SP1', '10', 'online', 'i386', 'suse-linux-enterprise-server-sp1', '10', 'online', 'i386', 'SUSE Linux Enterprise Server 10 SP1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sles" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="disk" description="" command="hwinfo --disk"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="scsi" description="" command="hwinfo --scsi"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="sys" description="" command="hwinfo --sys"/>
	<param id="tape" description="" command="hwinfo --tape"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="identification" description="" page="reg.jsp?guid={guid}&amp;lang={lang}" class="mandatory">
		<param id="email" description=""/>
	</param>
	<param id="regcode-sles" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="moniker" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="disk" description="" command="hwinfo --disk"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
		<param id="scsi" description="" command="hwinfo --scsi"/>
		<param id="sound" description="" command="hwinfo --sound"/>
		<param id="sys" description="" command="hwinfo --sys"/>
		<param id="tape" description="" command="hwinfo --tape"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<group-catalogs/>
</service>', 'Y', 'SLES');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(455, 'SUSE-Linux-Enterprise-Server-SP1', '10', 'online', 'x86_64', 'suse-linux-enterprise-server-sp1', '10', 'online', 'x86_64', 'SUSE Linux Enterprise Server 10 SP1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sles" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="disk" description="" command="hwinfo --disk"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="scsi" description="" command="hwinfo --scsi"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="sys" description="" command="hwinfo --sys"/>
	<param id="tape" description="" command="hwinfo --tape"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="identification" description="" page="reg.jsp?guid={guid}&amp;lang={lang}" class="mandatory">
		<param id="email" description=""/>
	</param>
	<param id="regcode-sles" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="moniker" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="disk" description="" command="hwinfo --disk"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
		<param id="scsi" description="" command="hwinfo --scsi"/>
		<param id="sound" description="" command="hwinfo --sound"/>
		<param id="sys" description="" command="hwinfo --sys"/>
		<param id="tape" description="" command="hwinfo --tape"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<group-catalogs/>
</service>', 'Y', 'SLES');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(456, 'SUSE-Linux-Enterprise-Server-SP1', '10', 'online', 'ppc', 'suse-linux-enterprise-server-sp1', '10', 'online', 'ppc', 'SUSE Linux Enterprise Server 10 SP1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sles" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="disk" description="" command="hwinfo --disk"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="scsi" description="" command="hwinfo --scsi"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="sys" description="" command="hwinfo --sys"/>
	<param id="tape" description="" command="hwinfo --tape"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="identification" description="" page="reg.jsp?guid={guid}&amp;lang={lang}" class="mandatory">
		<param id="email" description=""/>
	</param>
	<param id="regcode-sles" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="moniker" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="disk" description="" command="hwinfo --disk"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
		<param id="scsi" description="" command="hwinfo --scsi"/>
		<param id="sound" description="" command="hwinfo --sound"/>
		<param id="sys" description="" command="hwinfo --sys"/>
		<param id="tape" description="" command="hwinfo --tape"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<group-catalogs/>
</service>', 'Y', 'SLES');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(457, 'SUSE-Linux-Enterprise-Server-SP1', '10', 'online', 'ppc64', 'suse-linux-enterprise-server-sp1', '10', 'online', 'ppc64', 'SUSE Linux Enterprise Server 10 SP1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sles" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="disk" description="" command="hwinfo --disk"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="scsi" description="" command="hwinfo --scsi"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="sys" description="" command="hwinfo --sys"/>
	<param id="tape" description="" command="hwinfo --tape"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="identification" description="" page="reg.jsp?guid={guid}&amp;lang={lang}" class="mandatory">
		<param id="email" description=""/>
	</param>
	<param id="regcode-sles" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="moniker" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="disk" description="" command="hwinfo --disk"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
		<param id="scsi" description="" command="hwinfo --scsi"/>
		<param id="sound" description="" command="hwinfo --sound"/>
		<param id="sys" description="" command="hwinfo --sys"/>
		<param id="tape" description="" command="hwinfo --tape"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<group-catalogs/>
</service>', 'Y', 'SLES');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(458, 'SUSE-Linux-Enterprise-Server-SP1', '10', 'online', 'ia64', 'suse-linux-enterprise-server-sp1', '10', 'online', 'ia64', 'SUSE Linux Enterprise Server 10 SP1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sles" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="disk" description="" command="hwinfo --disk"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="scsi" description="" command="hwinfo --scsi"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="sys" description="" command="hwinfo --sys"/>
	<param id="tape" description="" command="hwinfo --tape"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="identification" description="" page="reg.jsp?guid={guid}&amp;lang={lang}" class="mandatory">
		<param id="email" description=""/>
	</param>
	<param id="regcode-sles" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="moniker" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="disk" description="" command="hwinfo --disk"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
		<param id="scsi" description="" command="hwinfo --scsi"/>
		<param id="sound" description="" command="hwinfo --sound"/>
		<param id="sys" description="" command="hwinfo --sys"/>
		<param id="tape" description="" command="hwinfo --tape"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<group-catalogs/>
</service>', 'Y', 'SLES');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(459, 'SUSE-Linux-Enterprise-Server-SP1', '10', 'online', 's390', 'suse-linux-enterprise-server-sp1', '10', 'online', 's390', 'SUSE Linux Enterprise Server 10 SP1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sles" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="disk" description="" command="hwinfo --disk"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="scsi" description="" command="hwinfo --scsi"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="sys" description="" command="hwinfo --sys"/>
	<param id="tape" description="" command="hwinfo --tape"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="identification" description="" page="reg.jsp?guid={guid}&amp;lang={lang}" class="mandatory">
		<param id="email" description=""/>
	</param>
	<param id="regcode-sles" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="moniker" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="disk" description="" command="hwinfo --disk"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
		<param id="scsi" description="" command="hwinfo --scsi"/>
		<param id="sound" description="" command="hwinfo --sound"/>
		<param id="sys" description="" command="hwinfo --sys"/>
		<param id="tape" description="" command="hwinfo --tape"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<group-catalogs/>
</service>', 'Y', 'SLES');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(460, 'SUSE-Linux-Enterprise-Server-SP1', '10', 'online', 's390x', 'suse-linux-enterprise-server-sp1', '10', 'online', 's390x', 'SUSE Linux Enterprise Server 10 SP1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sles" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="disk" description="" command="hwinfo --disk"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="scsi" description="" command="hwinfo --scsi"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="sys" description="" command="hwinfo --sys"/>
	<param id="tape" description="" command="hwinfo --tape"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="identification" description="" page="reg.jsp?guid={guid}&amp;lang={lang}" class="mandatory">
		<param id="email" description=""/>
	</param>
	<param id="regcode-sles" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="moniker" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="disk" description="" command="hwinfo --disk"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
		<param id="scsi" description="" command="hwinfo --scsi"/>
		<param id="sound" description="" command="hwinfo --sound"/>
		<param id="sys" description="" command="hwinfo --sys"/>
		<param id="tape" description="" command="hwinfo --tape"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<group-catalogs/>
</service>', 'Y', 'SLES');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(476, 'ATI Video Drivers SP1 STAGE', NULL, NULL, NULL, 'ati video drivers sp1 stage', NULL, NULL, NULL, NULL, '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="hw_inventory" description="">
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" type="${mirror:type}" description="${mirror:name}">
	<param id="url">${mirror:url}</param>
	<param name="catalog">tkar_ati_updates</param>
</service>', NULL, 'ATI');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(477, 'nVidia Video Drivers SP1 STAGE', NULL, NULL, NULL, 'nvidia video drivers sp1 stage', NULL, NULL, NULL, NULL, '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="hw_inventory" description="">
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" type="${mirror:type}" description="${mirror:name}">
	<param id="url">${mirror:url}</param>
	<param name="catalog">tkar_nvidia_updates</param>
</service>', NULL, 'nVidia');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(498, 'ATI Video Drivers SP1', NULL, NULL, NULL, 'ati video drivers sp1', NULL, NULL, NULL, 'ATI Video Drivers SP1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="hw_inventory" description="">
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" type="${mirror:type}" description="${mirror:name}">
	<param id="url">${mirror:url}</param>
	<param name="catalog">ATI-Drivers</param>
</service>', NULL, 'ATI');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(499, 'nVidia Video Drivers SP1', NULL, NULL, NULL, 'nvidia video drivers sp1', NULL, NULL, NULL, 'nVidia Video Drivers SP1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="hw_inventory" description="">
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" type="${mirror:type}" description="${mirror:name}">
	<param id="url">${mirror:url}</param>
	<param name="catalog">nVidia-Drivers</param>
</service>', NULL, 'nVidia');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(538, 'Novell-Open-Enterprise-Server-i386', '2', NULL, 'i486', 'novell-open-enterprise-server-i386', '2', NULL, 'i486', 'Novell Open Enterprise Server 2', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-oes" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="identification" description="" page="reg.jsp?guid={guid}&amp;lang={lang}" class="mandatory">
		<param id="email" description=""/>
	</param>
	<param id="regcode-oes" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="moniker" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="disk" description="" command="hwinfo --disk"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
		<param id="scsi" description="" command="hwinfo --scsi"/>
		<param id="sound" description="" command="hwinfo --sound"/>
		<param id="sys" description="" command="hwinfo --sys"/>
		<param id="tape" description="" command="hwinfo --tape"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<group-catalogs/>
</service>', 'Y', 'OES');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(536, 'Novell-Open-Enterprise-Server-i386', '2', NULL, 'i686', 'novell-open-enterprise-server-i386', '2', NULL, 'i686', 'Novell Open Enterprise Server 2', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-oes" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="identification" description="" page="reg.jsp?guid={guid}&amp;lang={lang}" class="mandatory">
		<param id="email" description=""/>
	</param>
	<param id="regcode-oes" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="moniker" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="disk" description="" command="hwinfo --disk"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
		<param id="scsi" description="" command="hwinfo --scsi"/>
		<param id="sound" description="" command="hwinfo --sound"/>
		<param id="sys" description="" command="hwinfo --sys"/>
		<param id="tape" description="" command="hwinfo --tape"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<group-catalogs/>
</service>', 'Y', 'OES');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(537, 'Novell-Open-Enterprise-Server-i386', '2', NULL, 'i586', 'novell-open-enterprise-server-i386', '2', NULL, 'i586', 'Novell Open Enterprise Server 2', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-oes" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="identification" description="" page="reg.jsp?guid={guid}&amp;lang={lang}" class="mandatory">
		<param id="email" description=""/>
	</param>
	<param id="regcode-oes" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="moniker" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="disk" description="" command="hwinfo --disk"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
		<param id="scsi" description="" command="hwinfo --scsi"/>
		<param id="sound" description="" command="hwinfo --sound"/>
		<param id="sys" description="" command="hwinfo --sys"/>
		<param id="tape" description="" command="hwinfo --tape"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<group-catalogs/>
</service>', 'Y', 'OES');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(539, 'Novell-Open-Enterprise-Server-i386', '2', NULL, 'i386', 'novell-open-enterprise-server-i386', '2', NULL, 'i386', 'Novell Open Enterprise Server 2', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-oes" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="identification" description="" page="reg.jsp?guid={guid}&amp;lang={lang}" class="mandatory">
		<param id="email" description=""/>
	</param>
	<param id="regcode-oes" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="moniker" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="disk" description="" command="hwinfo --disk"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
		<param id="scsi" description="" command="hwinfo --scsi"/>
		<param id="sound" description="" command="hwinfo --sound"/>
		<param id="sys" description="" command="hwinfo --sys"/>
		<param id="tape" description="" command="hwinfo --tape"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<group-catalogs/>
</service>', 'Y', 'OES');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(540, 'Novell-Open-Enterprise-Server-x86_64', '2', NULL, 'x86_64', 'novell-open-enterprise-server-x86_64', '2', NULL, 'x86_64', 'Novell Open Enterprise Server 2', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-oes" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="identification" description="" page="reg.jsp?guid={guid}&amp;lang={lang}" class="mandatory">
		<param id="email" description=""/>
	</param>
	<param id="regcode-oes" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="moniker" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="disk" description="" command="hwinfo --disk"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
		<param id="scsi" description="" command="hwinfo --scsi"/>
		<param id="sound" description="" command="hwinfo --sound"/>
		<param id="sys" description="" command="hwinfo --sys"/>
		<param id="tape" description="" command="hwinfo --tape"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<group-catalogs/>
</service>', 'Y', 'OES');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(556, 'SUSE-Linux-Enterprise-SDK-SP1-migration', '10', NULL, NULL, 'suse-linux-enterprise-sdk-sp1-migration', '10', NULL, NULL, 'SUSE Linux 10 SP1 Software Development Kit', NULL, NULL, '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="group">sle10-sdk-sp1-online</param>
</service>', 'Y', 'SDK');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(557, 'SUSE-Linux-Enterprise-SDK-SP1', '10', NULL, NULL, 'suse-linux-enterprise-sdk-sp1', '10', NULL, NULL, 'SUSE Linux 10 SP1 Software Development Kit', NULL, NULL, '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="group">sle10-sdk-sp1</param>
</service>', 'Y', 'SDK');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(560, 'openSUSE-10.3-GNOME-download', '10.3', NULL, NULL, 'opensuse-10.3-gnome-download', '10.3', NULL, NULL, 'openSUSE 10.3', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="elogin" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="desktops" description="" command="installed-desktops"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="identification" description="" page="http://download.novell.com/delivery/reg/suse.jsp" class="tentative">
		<param id="elogin" description=""/>
	</param>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="desktops" description="" command="installed-desktops"/>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="sound" description="" command="hwinfo --sound"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param name="catalog">openSUSE-10.3-Updates</param>
</service>', 'Y', 'SUSE');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(561, 'openSUSE-10.3-KDE-download', '10.3', NULL, NULL, 'opensuse-10.3-kde-download', '10.3', NULL, NULL, 'openSUSE 10.3', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="elogin" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="desktops" description="" command="installed-desktops"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="identification" description="" page="http://download.novell.com/delivery/reg/suse.jsp" class="tentative">
		<param id="elogin" description=""/>
	</param>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="desktops" description="" command="installed-desktops"/>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="sound" description="" command="hwinfo --sound"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param name="catalog">openSUSE-10.3-Updates</param>
</service>', 'Y', 'SUSE');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(580, 'SUSE-Linux-Enterprise-Virtual-Machine-Driver-Pack', '10', NULL, NULL, 'suse-linux-enterprise-virtual-machine-driver-pack', '10', NULL, NULL, 'SUSE Linux Enterprise Virtual Machine Driver Pack 1.1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-vmdp" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="disk" description="" command="hwinfo --disk"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="scsi" description="" command="hwinfo --scsi"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="sys" description="" command="hwinfo --sys"/>
	<param id="tape" description="" command="hwinfo --tape"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="identification" description="" page="reg.jsp?guid={guid}&amp;lang={lang}" class="mandatory">
		<param id="email" description=""/>
	</param>
	<param id="regcode-vmdp" description="" class="mandatory" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="moniker" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="disk" description="" command="hwinfo --disk"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
		<param id="scsi" description="" command="hwinfo --scsi"/>
		<param id="sound" description="" command="hwinfo --sound"/>
		<param id="sys" description="" command="hwinfo --sys"/>
		<param id="tape" description="" command="hwinfo --tape"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<group-catalogs/>
</service>', 'Y', 'VMDP');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(600, 'ZENworks Pulsar', '1.0', NULL, NULL, 'zenworks pulsar', '1.0', NULL, NULL, 'ZENworks Pulsar 1.0', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="regcode-zenworks" description="" class="mandatory"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>', '<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
        <guid description="" class="mandatory"/>
        <host description=""/>
        <product description="" class="mandatory"/>
        <param id="regcode-zenworks" description="" class="requested"/>
        <privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}" product="ZENworks">
	<param id="url">${mirror:url}</param>
	<product>${product:product}</product>
</service>', 'Y', 'Pulsar');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(621, 'SUSE-Linux-Enterprise-HA-Server', '1.0', NULL, NULL, 'suse-linux-enterprise-ha-server', '1.0', NULL, NULL, 'SUSE Linux Enterprise HA Server 1.0', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-slehas" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="disk" description="" command="hwinfo --disk"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="scsi" description="" command="hwinfo --scsi"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="sys" description="" command="hwinfo --sys"/>
	<param id="tape" description="" command="hwinfo --tape"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="identification" description="" page="reg.jsp?guid={guid}&amp;lang={lang}" class="mandatory">
		<param id="email" description=""/>
	</param>
	<param id="regcode-slehas" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="moniker" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="disk" description="" command="hwinfo --disk"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
		<param id="scsi" description="" command="hwinfo --scsi"/>
		<param id="sound" description="" command="hwinfo --sound"/>
		<param id="sys" description="" command="hwinfo --sys"/>
		<param id="tape" description="" command="hwinfo --tape"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<group-catalogs/>
</service>', 'Y', 'SLES-HA');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(640, 'ZENworks_Orchestrator', '1.1', NULL, 'i686', 'zenworks_orchestrator', '1.1', NULL, 'i686', 'ZENworks Orchestrator 1.1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-zos" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="disk" description="" command="hwinfo --disk"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="scsi" description="" command="hwinfo --scsi"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="sys" description="" command="hwinfo --sys"/>
	<param id="tape" description="" command="hwinfo --tape"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="identification" description="" page="reg.jsp?guid={guid}&amp;lang={lang}" class="mandatory">
		<param id="email" description=""/>
	</param>
	<param id="regcode-zos" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="moniker" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="disk" description="" command="hwinfo --disk"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
		<param id="scsi" description="" command="hwinfo --scsi"/>
		<param id="sound" description="" command="hwinfo --sound"/>
		<param id="sys" description="" command="hwinfo --sys"/>
		<param id="tape" description="" command="hwinfo --tape"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<group-catalogs/>
</service>', 'Y', 'ZOS');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(660, 'openSUSE-10.3-OSS-Gnome', '10.3', NULL, NULL, 'opensuse-10.3-oss-gnome', '10.3', NULL, NULL, 'openSUSE 10.3', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="elogin" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="desktops" description="" command="installed-desktops"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="identification" description="" page="http://download.novell.com/delivery/reg/suse.jsp" class="tentative">
		<param id="elogin" description=""/>
	</param>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="desktops" description="" command="installed-desktops"/>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="sound" description="" command="hwinfo --sound"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param name="catalog">openSUSE-10.3-Updates</param>
</service>', 'Y', 'SUSE');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(661, 'openSUSE-10.3-OSS-KDE', '10.3', NULL, NULL, 'opensuse-10.3-oss-kde', '10.3', NULL, NULL, 'openSUSE 10.3', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="elogin" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="desktops" description="" command="installed-desktops"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="identification" description="" page="http://download.novell.com/delivery/reg/suse.jsp" class="tentative">
		<param id="elogin" description=""/>
	</param>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="desktops" description="" command="installed-desktops"/>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="sound" description="" command="hwinfo --sound"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param name="catalog">openSUSE-10.3-Updates</param>
</service>', 'Y', 'SUSE');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(662, 'openSUSE-10.3-DVD', '10.3', NULL, NULL, 'opensuse-10.3-dvd', '10.3', NULL, NULL, 'openSUSE 10.3', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="elogin" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="desktops" description="" command="installed-desktops"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="identification" description="" page="http://download.novell.com/delivery/reg/suse.jsp" class="tentative">
		<param id="elogin" description=""/>
	</param>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="desktops" description="" command="installed-desktops"/>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="sound" description="" command="hwinfo --sound"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param name="catalog">openSUSE-10.3-Updates</param>
</service>', 'Y', 'SUSE');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(663, 'openSUSE-10.3-retail', '10.3', NULL, NULL, 'opensuse-10.3-retail', '10.3', NULL, NULL, 'openSUSE 10.3', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="elogin" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="desktops" description="" command="installed-desktops"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="identification" description="" page="http://download.novell.com/delivery/reg/suse.jsp" class="tentative">
		<param id="elogin" description=""/>
	</param>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="desktops" description="" command="installed-desktops"/>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="sound" description="" command="hwinfo --sound"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param name="catalog">openSUSE-10.3-Updates</param>
</service>', 'Y', 'SUSE');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(664, 'openSUSE-10.3-FTP', '10.3', NULL, NULL, 'opensuse-10.3-ftp', '10.3', NULL, NULL, 'openSUSE 10.3', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="elogin" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="desktops" description="" command="installed-desktops"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="identification" description="" page="http://download.novell.com/delivery/reg/suse.jsp" class="tentative">
		<param id="elogin" description=""/>
	</param>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="desktops" description="" command="installed-desktops"/>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="sound" description="" command="hwinfo --sound"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param name="catalog">openSUSE-10.3-Updates</param>
</service>', 'Y', 'SUSE');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(680, 'SUSE-Linux-Enterprise-RT', '10.2.0', NULL, NULL, 'suse-linux-enterprise-rt', '10.2.0', NULL, NULL, 'SUSE Linux Enterprise Server RT Solution 10', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-slert" description="" class="mandatory"/>
	<param id="moniker" description=""/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
		<guid description="" class="mandatory"/>
		<param id="secret" description="" command="zmd-secret" class="mandatory"/>
		<host description=""/>
		<product description="" class="mandatory"/>
		<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
		<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
		<param id="identification" description="" page="reg.jsp?guid={guid}&amp;lang={lang}" class="mandatory">
				<param id="email" description=""/>
		</param>
		<param id="regcode-slert" description="" page="reg.jsp?guid={guid}&amp;lang={lang}" class="mandatory"/>
		<param id="moniker" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
		<param id="sysident" description="">
				<param id="processor" description="" command="uname -p"/>
				<param id="platform" description="" command="uname -i"/>
				<param id="hostname" description="" command="uname -n"/>
		</param>
		<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<group-catalogs/>
</service>', 'Y', 'SLERT');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(700, 'openSUSE-10.3-DVD-ct', '10.3', NULL, NULL, 'opensuse-10.3-dvd-ct', '10.3', NULL, NULL, 'openSUSE 10.3', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="elogin" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="desktops" description="" command="installed-desktops"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="identification" description="" page="http://download.novell.com/delivery/reg/suse.jsp" class="tentative">
		<param id="elogin" description=""/>
	</param>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="desktops" description="" command="installed-desktops"/>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="sound" description="" command="hwinfo --sound"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param name="catalog">openSUSE-10.3-Updates</param>
</service>', 'Y', 'SUSE');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(701, 'openSUSE-10.3-DVD-Magazine', '10.3', NULL, NULL, 'opensuse-10.3-dvd-magazine', '10.3', NULL, NULL, 'openSUSE 10.3', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="elogin" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="desktops" description="" command="installed-desktops"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="identification" description="" page="http://download.novell.com/delivery/reg/suse.jsp" class="tentative">
		<param id="elogin" description=""/>
	</param>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="desktops" description="" command="installed-desktops"/>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="sound" description="" command="hwinfo --sound"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param name="catalog">openSUSE-10.3-Updates</param>
</service>', 'Y', 'SUSE');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(720, 'SUSE-Linux-Enterprise-Desktop-SP1', '10', 'Lenovo_1_1y', NULL, 'suse-linux-enterprise-desktop-sp1', '10', 'lenovo_1_1y', NULL, 'SUSE Linux Enterprise Desktop 10 SP1 (Lenovo Edition)', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sled" description=""/>
	<param id="moniker" description=""/>
	<param id="vendor" description=""/>
	<param id="serial" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="bios" description="" command="hwinfo --bios"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="disk" description="" command="hwinfo --disk"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="scsi" description="" command="hwinfo --scsi"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="sys" description="" command="hwinfo --sys"/>
	<param id="tape" description="" command="hwinfo --tape"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="identification" description="" page="reg.jsp?guid={guid}&amp;lang={lang}" class="mandatory">
		<param id="email" description=""/>
	</param>
	<param id="regcode-sled" description="" page="reg.jsp?guid={guid}&amp;lang={lang}" class="hidden"/>
	<param id="moniker" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="vendor" description="" page="serial.jsp?guid={guid}&amp;lang={lang}" class="mandatory"/>
	<param id="serial" description="" page="serial.jsp?guid={guid}&amp;lang={lang}" class="mandatory"/>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="bios" description="" command="hwinfo --bios"/>
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
		<param id="sound" description="" command="hwinfo --sound"/>
		<param id="sys" description="" command="hwinfo --sys"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" type="${mirror:type}" description="${mirror:name}">
	<param id="url">${mirror:url}</param>
	<group-catalogs/>
</service>', 'N', 'SLED');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(721, 'SUSE-Linux-Enterprise-Desktop-SP1', '10', 'Lenovo_1_3y', NULL, 'suse-linux-enterprise-desktop-sp1', '10', 'lenovo_1_3y', NULL, 'SUSE Linux Enterprise Desktop 10 SP1 (Lenovo Edition)', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sled" description=""/>
	<param id="moniker" description=""/>
	<param id="vendor" description=""/>
	<param id="serial" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="bios" description="" command="hwinfo --bios"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="disk" description="" command="hwinfo --disk"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="scsi" description="" command="hwinfo --scsi"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="sys" description="" command="hwinfo --sys"/>
	<param id="tape" description="" command="hwinfo --tape"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="identification" description="" page="reg.jsp?guid={guid}&amp;lang={lang}" class="mandatory">
		<param id="email" description=""/>
	</param>
	<param id="regcode-sled" description="" page="reg.jsp?guid={guid}&amp;lang={lang}" class="hidden"/>
	<param id="moniker" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="vendor" description="" page="serial.jsp?guid={guid}&amp;lang={lang}" class="mandatory"/>
	<param id="serial" description="" page="serial.jsp?guid={guid}&amp;lang={lang}" class="mandatory"/>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="bios" description="" command="hwinfo --bios"/>
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
		<param id="sound" description="" command="hwinfo --sound"/>
		<param id="sys" description="" command="hwinfo --sys"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" type="${mirror:type}" description="${mirror:name}">
	<param id="url">${mirror:url}</param>
	<group-catalogs/>
</service>', 'N', 'SLED');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(722, 'SUSE-Linux-Enterprise-Desktop-SP1', '10', 'DellChina', NULL, 'suse-linux-enterprise-desktop-sp1', '10', 'dellchina', NULL, 'SUSE Linux Enterprise Desktop 10 SP1 (Dell Edition)', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sled" description=""/>
	<param id="moniker" description=""/>
	<param id="vendor" description=""/>
	<param id="serial" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="bios" description="" command="hwinfo --bios"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="disk" description="" command="hwinfo --disk"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="scsi" description="" command="hwinfo --scsi"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="sys" description="" command="hwinfo --sys"/>
	<param id="tape" description="" command="hwinfo --tape"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="identification" description="" page="reg.jsp?guid={guid}&amp;lang={lang}" class="mandatory">
		<param id="email" description=""/>
	</param>
	<param id="regcode-sled" description="" page="reg.jsp?guid={guid}&amp;lang={lang}" class="hidden"/>
	<param id="moniker" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="vendor" description="" page="serial.jsp?guid={guid}&amp;lang={lang}" class="mandatory"/>
	<param id="serial" description="" page="serial.jsp?guid={guid}&amp;lang={lang}" class="mandatory"/>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="bios" description="" command="hwinfo --bios"/>
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
		<param id="sound" description="" command="hwinfo --sound"/>
		<param id="sys" description="" command="hwinfo --sys"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" type="${mirror:type}" description="${mirror:name}">
	<param id="url">${mirror:url}</param>
	<group-catalogs/>
</service>', 'N', 'SLED');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(740, 'openSUSE-10.3-Live-Gnome', '10.3', NULL, NULL, 'opensuse-10.3-live-gnome', '10.3', NULL, NULL, 'openSUSE 10.3', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="elogin" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="desktops" description="" command="installed-desktops"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="identification" description="" page="http://download.novell.com/delivery/reg/suse.jsp" class="tentative">
		<param id="elogin" description=""/>
	</param>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="desktops" description="" command="installed-desktops"/>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="sound" description="" command="hwinfo --sound"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param name="catalog">openSUSE-10.3-Updates</param>
</service>', 'Y', 'SUSE');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(741, 'openSUSE-10.3-Live-KDE', '10.3', NULL, NULL, 'opensuse-10.3-live-kde', '10.3', NULL, NULL, 'openSUSE 10.3', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="elogin" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="desktops" description="" command="installed-desktops"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="identification" description="" page="http://download.novell.com/delivery/reg/suse.jsp" class="tentative">
		<param id="elogin" description=""/>
	</param>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="desktops" description="" command="installed-desktops"/>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="sound" description="" command="hwinfo --sound"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param name="catalog">openSUSE-10.3-Updates</param>
</service>', 'Y', 'SUSE');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(742, 'openSUSE-10.3-Promo', '10.3', NULL, NULL, 'opensuse-10.3-promo', '10.3', NULL, NULL, 'openSUSE 10.3', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="elogin" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="desktops" description="" command="installed-desktops"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="identification" description="" page="http://download.novell.com/delivery/reg/suse.jsp" class="tentative">
		<param id="elogin" description=""/>
	</param>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="desktops" description="" command="installed-desktops"/>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="sound" description="" command="hwinfo --sound"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param name="catalog">openSUSE-10.3-Updates</param>
</service>', 'Y', 'SUSE');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(760, 'SUSE-Linux-SLES-i386', '9', NULL, NULL, 'suse-linux-sles-i386', '9', NULL, NULL, 'SUSE Linux Enterprise Server 9', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sles" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="disk" description="" command="hwinfo --disk"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="scsi" description="" command="hwinfo --scsi"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="sys" description="" command="hwinfo --sys"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="identification" description="" page="reg.jsp?guid={guid}&amp;lang={lang}" class="mandatory">
		<param id="email" description=""/>
	</param>
	<param id="regcode-sles" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="moniker" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="disk" description="" command="hwinfo --disk"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
		<param id="scsi" description="" command="hwinfo --scsi"/>
		<param id="sound" description="" command="hwinfo --sound"/>
		<param id="sys" description="" command="hwinfo --sys"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', NULL, 'Y', 'SLES');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(761, 'SLES9-SLD-SP-i386', '9', NULL, NULL, 'sles9-sld-sp-i386', '9', NULL, NULL, 'Novell Linux Desktop 9', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sled" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="sys" description="" command="hwinfo --sys"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="identification" description="" page="reg.jsp?guid={guid}&amp;lang={lang}" class="mandatory">
		<param id="email" description=""/>
	</param>
	<param id="regcode-sled" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="moniker" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
		<param id="sound" description="" command="hwinfo --sound"/>
		<param id="sys" description="" command="hwinfo --sys"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', NULL, 'Y', 'SLED');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(762, 'Novell-Open-Enterprise-Server-i386', '9', NULL, NULL, 'novell-open-enterprise-server-i386', '9', NULL, NULL, 'Novell Open Enterprise Server', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sles" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="disk" description="" command="hwinfo --disk"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="scsi" description="" command="hwinfo --scsi"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="sys" description="" command="hwinfo --sys"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="identification" description="" page="reg.jsp?guid={guid}&amp;lang={lang}" class="mandatory">
		<param id="email" description=""/>
	</param>
	<param id="regcode-sles" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="moniker" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="disk" description="" command="hwinfo --disk"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
		<param id="scsi" description="" command="hwinfo --scsi"/>
		<param id="sound" description="" command="hwinfo --sound"/>
		<param id="sys" description="" command="hwinfo --sys"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', NULL, 'Y', 'SLES');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(763, 'SUSE-Linux-SLES-x86_64', '9', NULL, NULL, 'suse-linux-sles-x86_64', '9', NULL, NULL, 'SUSE Linux Enterprise Server 9', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sles" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="disk" description="" command="hwinfo --disk"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="scsi" description="" command="hwinfo --scsi"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="sys" description="" command="hwinfo --sys"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="identification" description="" page="reg.jsp?guid={guid}&amp;lang={lang}" class="mandatory">
		<param id="email" description=""/>
	</param>
	<param id="regcode-sles" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="moniker" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="disk" description="" command="hwinfo --disk"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
		<param id="scsi" description="" command="hwinfo --scsi"/>
		<param id="sound" description="" command="hwinfo --sound"/>
		<param id="sys" description="" command="hwinfo --sys"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', NULL, 'Y', 'SLES');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(764, 'SLES9-SLD-SP-x86_64', '9', NULL, NULL, 'sles9-sld-sp-x86_64', '9', NULL, NULL, 'Novell Linux Desktop 9', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sled" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="sys" description="" command="hwinfo --sys"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="identification" description="" page="reg.jsp?guid={guid}&amp;lang={lang}" class="mandatory">
		<param id="email" description=""/>
	</param>
	<param id="regcode-sled" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="moniker" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
		<param id="sound" description="" command="hwinfo --sound"/>
		<param id="sys" description="" command="hwinfo --sys"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', NULL, 'Y', 'SLED');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(765, 'Novell-Open-Enterprise-Server-x86_64', '9', NULL, NULL, 'novell-open-enterprise-server-x86_64', '9', NULL, NULL, 'Novell Open Enterprise Server', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sles" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="disk" description="" command="hwinfo --disk"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="scsi" description="" command="hwinfo --scsi"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="sys" description="" command="hwinfo --sys"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="identification" description="" page="reg.jsp?guid={guid}&amp;lang={lang}" class="mandatory">
		<param id="email" description=""/>
	</param>
	<param id="regcode-sles" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="moniker" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="disk" description="" command="hwinfo --disk"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
		<param id="scsi" description="" command="hwinfo --scsi"/>
		<param id="sound" description="" command="hwinfo --sound"/>
		<param id="sys" description="" command="hwinfo --sys"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', NULL, 'Y', 'SLES');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(800, 'SUSE-Linux-Enterprise-Desktop-SP2-migration', '10', NULL, 'i686', 'suse-linux-enterprise-desktop-sp2-migration', '10', NULL, 'i686', 'SUSE Linux Enterprise Desktop 10 SP2 Migration', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sled" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
    <guid description="" class="mandatory"/>
    <param id="secret" description="" command="zmd-secret" class="mandatory"/>
    <host description=""/>
    <product description="" class="mandatory"/>
    <param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
    <param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
    <param id="regcode-sled" description=""/>
    <param id="moniker" description=""/>
    <param id="sysident" description="">
        <param id="processor" description="" command="uname -p"/>
        <param id="platform" description="" command="uname -i"/>
        <param id="hostname" description="" command="uname -n"/>
    </param>
    <privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo> 
', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" type="${mirror:type}" description="${mirror:name}">
	<param id="url">${mirror:url}</param>
	<param id="group">sled10-sp2-migration</param>
</service>', 'Y', 'SLED');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(801, 'SUSE-Linux-Enterprise-Desktop-SP2-migration', '10', NULL, 'i586', 'suse-linux-enterprise-desktop-sp2-migration', '10', NULL, 'i586', 'SUSE Linux Enterprise Desktop 10 SP2 Migration', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sled" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
    <guid description="" class="mandatory"/>
    <param id="secret" description="" command="zmd-secret" class="mandatory"/>
    <host description=""/>
    <product description="" class="mandatory"/>
    <param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
    <param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
    <param id="regcode-sled" description=""/>
    <param id="moniker" description=""/>
    <param id="sysident" description="">
        <param id="processor" description="" command="uname -p"/>
        <param id="platform" description="" command="uname -i"/>
        <param id="hostname" description="" command="uname -n"/>
    </param>
    <privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo> 
', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" type="${mirror:type}" description="${mirror:name}">
	<param id="url">${mirror:url}</param>
	<param id="group">sled10-sp2-migration</param>
</service>', 'Y', 'SLED');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(802, 'SUSE-Linux-Enterprise-Desktop-SP2-migration', '10', NULL, 'i486', 'suse-linux-enterprise-desktop-sp2-migration', '10', NULL, 'i486', 'SUSE Linux Enterprise Desktop 10 SP2 Migration', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sled" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
    <guid description="" class="mandatory"/>
    <param id="secret" description="" command="zmd-secret" class="mandatory"/>
    <host description=""/>
    <product description="" class="mandatory"/>
    <param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
    <param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
    <param id="regcode-sled" description=""/>
    <param id="moniker" description=""/>
    <param id="sysident" description="">
        <param id="processor" description="" command="uname -p"/>
        <param id="platform" description="" command="uname -i"/>
        <param id="hostname" description="" command="uname -n"/>
    </param>
    <privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo> 
', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" type="${mirror:type}" description="${mirror:name}">
	<param id="url">${mirror:url}</param>
	<param id="group">sled10-sp2-migration</param>
</service>', 'Y', 'SLED');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(803, 'SUSE-Linux-Enterprise-Desktop-SP2-migration', '10', NULL, 'i386', 'suse-linux-enterprise-desktop-sp2-migration', '10', NULL, 'i386', 'SUSE Linux Enterprise Desktop 10 SP2 Migration', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sled" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
    <guid description="" class="mandatory"/>
    <param id="secret" description="" command="zmd-secret" class="mandatory"/>
    <host description=""/>
    <product description="" class="mandatory"/>
    <param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
    <param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
    <param id="regcode-sled" description=""/>
    <param id="moniker" description=""/>
    <param id="sysident" description="">
        <param id="processor" description="" command="uname -p"/>
        <param id="platform" description="" command="uname -i"/>
        <param id="hostname" description="" command="uname -n"/>
    </param>
    <privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo> 
', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" type="${mirror:type}" description="${mirror:name}">
	<param id="url">${mirror:url}</param>
	<param id="group">sled10-sp2-migration</param>
</service>', 'Y', 'SLED');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(804, 'SUSE-Linux-Enterprise-Desktop-SP2-migration', '10', NULL, 'x86_64', 'suse-linux-enterprise-desktop-sp2-migration', '10', NULL, 'x86_64', 'SUSE Linux Enterprise Desktop 10 SP2 Migration', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sled" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
    <guid description="" class="mandatory"/>
    <param id="secret" description="" command="zmd-secret" class="mandatory"/>
    <host description=""/>
    <product description="" class="mandatory"/>
    <param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
    <param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
    <param id="regcode-sled" description=""/>
    <param id="moniker" description=""/>
    <param id="sysident" description="">
        <param id="processor" description="" command="uname -p"/>
        <param id="platform" description="" command="uname -i"/>
        <param id="hostname" description="" command="uname -n"/>
    </param>
    <privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo> 
', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" type="${mirror:type}" description="${mirror:name}">
	<param id="url">${mirror:url}</param>
	<param id="group">sled10-sp2-migration</param>
</service>', 'Y', 'SLED');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(805, 'SUSE-Linux-Enterprise-Server-SP2-migration', '10', NULL, 'i686', 'suse-linux-enterprise-server-sp2-migration', '10', NULL, 'i686', 'SUSE Linux Enterprise Server 10 SP2 Migration', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sles" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
    <guid description="" class="mandatory"/>
    <param id="secret" description="" command="zmd-secret" class="mandatory"/>
    <host description=""/>
    <product description="" class="mandatory"/>
    <param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
    <param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
    <param id="regcode-sles" description=""/>
    <param id="moniker" description=""/>
    <param id="sysident" description="">
        <param id="processor" description="" command="uname -p"/>
        <param id="platform" description="" command="uname -i"/>
        <param id="hostname" description="" command="uname -n"/>
    </param>
    <privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo> 
', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="group">sles10-sp2-migration</param>
</service>', 'Y', 'SLES');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(806, 'SUSE-Linux-Enterprise-Server-SP2-migration', '10', NULL, 'i586', 'suse-linux-enterprise-server-sp2-migration', '10', NULL, 'i586', 'SUSE Linux Enterprise Server 10 SP2 Migration', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sles" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
    <guid description="" class="mandatory"/>
    <param id="secret" description="" command="zmd-secret" class="mandatory"/>
    <host description=""/>
    <product description="" class="mandatory"/>
    <param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
    <param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
    <param id="regcode-sles" description=""/>
    <param id="moniker" description=""/>
    <param id="sysident" description="">
        <param id="processor" description="" command="uname -p"/>
        <param id="platform" description="" command="uname -i"/>
        <param id="hostname" description="" command="uname -n"/>
    </param>
    <privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo> 
', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="group">sles10-sp2-migration</param>
</service>', 'Y', 'SLES');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(807, 'SUSE-Linux-Enterprise-Server-SP2-migration', '10', NULL, 'i486', 'suse-linux-enterprise-server-sp2-migration', '10', NULL, 'i486', 'SUSE Linux Enterprise Server 10 SP2 Migration', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sles" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
    <guid description="" class="mandatory"/>
    <param id="secret" description="" command="zmd-secret" class="mandatory"/>
    <host description=""/>
    <product description="" class="mandatory"/>
    <param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
    <param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
    <param id="regcode-sles" description=""/>
    <param id="moniker" description=""/>
    <param id="sysident" description="">
        <param id="processor" description="" command="uname -p"/>
        <param id="platform" description="" command="uname -i"/>
        <param id="hostname" description="" command="uname -n"/>
    </param>
    <privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo> 
', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="group">sles10-sp2-migration</param>
</service>', 'Y', 'SLES');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(808, 'SUSE-Linux-Enterprise-Server-SP2-migration', '10', NULL, 'i386', 'suse-linux-enterprise-server-sp2-migration', '10', NULL, 'i386', 'SUSE Linux Enterprise Server 10 SP2 Migration', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sles" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
    <guid description="" class="mandatory"/>
    <param id="secret" description="" command="zmd-secret" class="mandatory"/>
    <host description=""/>
    <product description="" class="mandatory"/>
    <param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
    <param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
    <param id="regcode-sles" description=""/>
    <param id="moniker" description=""/>
    <param id="sysident" description="">
        <param id="processor" description="" command="uname -p"/>
        <param id="platform" description="" command="uname -i"/>
        <param id="hostname" description="" command="uname -n"/>
    </param>
    <privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo> 
', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="group">sles10-sp2-migration</param>
</service>', 'Y', 'SLES');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(809, 'SUSE-Linux-Enterprise-Server-SP2-migration', '10', NULL, 'x86_64', 'suse-linux-enterprise-server-sp2-migration', '10', NULL, 'x86_64', 'SUSE Linux Enterprise Server 10 SP2 Migration', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sles" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
    <guid description="" class="mandatory"/>
    <param id="secret" description="" command="zmd-secret" class="mandatory"/>
    <host description=""/>
    <product description="" class="mandatory"/>
    <param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
    <param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
    <param id="regcode-sles" description=""/>
    <param id="moniker" description=""/>
    <param id="sysident" description="">
        <param id="processor" description="" command="uname -p"/>
        <param id="platform" description="" command="uname -i"/>
        <param id="hostname" description="" command="uname -n"/>
    </param>
    <privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo> 
', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="group">sles10-sp2-migration</param>
</service>', 'Y', 'SLES');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(810, 'SUSE-Linux-Enterprise-Server-SP2-migration', '10', NULL, 'ppc', 'suse-linux-enterprise-server-sp2-migration', '10', NULL, 'ppc', 'SUSE Linux Enterprise Server 10 SP2 Migration', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sles" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
    <guid description="" class="mandatory"/>
    <param id="secret" description="" command="zmd-secret" class="mandatory"/>
    <host description=""/>
    <product description="" class="mandatory"/>
    <param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
    <param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
    <param id="regcode-sles" description=""/>
    <param id="moniker" description=""/>
    <param id="sysident" description="">
        <param id="processor" description="" command="uname -p"/>
        <param id="platform" description="" command="uname -i"/>
        <param id="hostname" description="" command="uname -n"/>
    </param>
    <privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo> 
', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="group">sles10-sp2-migration</param>
</service>', 'Y', 'SLES');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(811, 'SUSE-Linux-Enterprise-Server-SP2-migration', '10', NULL, 'ppc64', 'suse-linux-enterprise-server-sp2-migration', '10', NULL, 'ppc64', 'SUSE Linux Enterprise Server 10 SP2 Migration', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sles" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
    <guid description="" class="mandatory"/>
    <param id="secret" description="" command="zmd-secret" class="mandatory"/>
    <host description=""/>
    <product description="" class="mandatory"/>
    <param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
    <param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
    <param id="regcode-sles" description=""/>
    <param id="moniker" description=""/>
    <param id="sysident" description="">
        <param id="processor" description="" command="uname -p"/>
        <param id="platform" description="" command="uname -i"/>
        <param id="hostname" description="" command="uname -n"/>
    </param>
    <privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo> 
', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="group">sles10-sp2-migration</param>
</service>', 'Y', 'SLES');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(812, 'SUSE-Linux-Enterprise-Server-SP2-migration', '10', NULL, 'ia64', 'suse-linux-enterprise-server-sp2-migration', '10', NULL, 'ia64', 'SUSE Linux Enterprise Server 10 SP2 Migration', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sles" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
    <guid description="" class="mandatory"/>
    <param id="secret" description="" command="zmd-secret" class="mandatory"/>
    <host description=""/>
    <product description="" class="mandatory"/>
    <param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
    <param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
    <param id="regcode-sles" description=""/>
    <param id="moniker" description=""/>
    <param id="sysident" description="">
        <param id="processor" description="" command="uname -p"/>
        <param id="platform" description="" command="uname -i"/>
        <param id="hostname" description="" command="uname -n"/>
    </param>
    <privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo> 
', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="group">sles10-sp2-migration</param>
</service>', 'Y', 'SLES');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(813, 'SUSE-Linux-Enterprise-Server-SP2-migration', '10', NULL, 's390', 'suse-linux-enterprise-server-sp2-migration', '10', NULL, 's390', 'SUSE Linux Enterprise Server 10 SP2 Migration', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sles" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
    <guid description="" class="mandatory"/>
    <param id="secret" description="" command="zmd-secret" class="mandatory"/>
    <host description=""/>
    <product description="" class="mandatory"/>
    <param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
    <param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
    <param id="regcode-sles" description=""/>
    <param id="moniker" description=""/>
    <param id="sysident" description="">
        <param id="processor" description="" command="uname -p"/>
        <param id="platform" description="" command="uname -i"/>
        <param id="hostname" description="" command="uname -n"/>
    </param>
    <privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo> 
', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="group">sles10-sp2-migration</param>
</service>', 'Y', 'SLES');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(814, 'SUSE-Linux-Enterprise-Server-SP2-migration', '10', NULL, 's390x', 'suse-linux-enterprise-server-sp2-migration', '10', NULL, 's390x', 'SUSE Linux Enterprise Server 10 SP2 Migration', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sles" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
    <guid description="" class="mandatory"/>
    <param id="secret" description="" command="zmd-secret" class="mandatory"/>
    <host description=""/>
    <product description="" class="mandatory"/>
    <param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
    <param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
    <param id="regcode-sles" description=""/>
    <param id="moniker" description=""/>
    <param id="sysident" description="">
        <param id="processor" description="" command="uname -p"/>
        <param id="platform" description="" command="uname -i"/>
        <param id="hostname" description="" command="uname -n"/>
    </param>
    <privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo> 
', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="group">sles10-sp2-migration</param>
</service>', 'Y', 'SLES');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(815, 'SUSE-Linux-Enterprise-Desktop-SP2', '10', NULL, 'i686', 'suse-linux-enterprise-desktop-sp2', '10', NULL, 'i686', 'SUSE Linux Enterprise Desktop 10 SP2', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sled" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="disk" description="" command="hwinfo --disk"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="scsi" description="" command="hwinfo --scsi"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="sys" description="" command="hwinfo --sys"/>
	<param id="tape" description="" command="hwinfo --tape"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="identification" description="" page="reg.jsp?guid={guid}&amp;lang={lang}" class="mandatory">
		<param id="email" description=""/>
	</param>
	<param id="regcode-sled" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="moniker" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
		<param id="sound" description="" command="hwinfo --sound"/>
		<param id="sys" description="" command="hwinfo --sys"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" type="${mirror:type}" description="${mirror:name}">
	<param id="url">${mirror:url}</param>
	<group-catalogs/>
</service>', 'Y', 'SLED');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(816, 'SUSE-Linux-Enterprise-Desktop-SP2', '10', NULL, 'i586', 'suse-linux-enterprise-desktop-sp2', '10', NULL, 'i586', 'SUSE Linux Enterprise Desktop 10 SP2', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sled" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="disk" description="" command="hwinfo --disk"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="scsi" description="" command="hwinfo --scsi"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="sys" description="" command="hwinfo --sys"/>
	<param id="tape" description="" command="hwinfo --tape"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="identification" description="" page="reg.jsp?guid={guid}&amp;lang={lang}" class="mandatory">
		<param id="email" description=""/>
	</param>
	<param id="regcode-sled" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="moniker" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
		<param id="sound" description="" command="hwinfo --sound"/>
		<param id="sys" description="" command="hwinfo --sys"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" type="${mirror:type}" description="${mirror:name}">
	<param id="url">${mirror:url}</param>
	<group-catalogs/>
</service>', 'Y', 'SLED');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(817, 'SUSE-Linux-Enterprise-Desktop-SP2', '10', NULL, 'i486', 'suse-linux-enterprise-desktop-sp2', '10', NULL, 'i486', 'SUSE Linux Enterprise Desktop 10 SP2', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sled" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="disk" description="" command="hwinfo --disk"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="scsi" description="" command="hwinfo --scsi"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="sys" description="" command="hwinfo --sys"/>
	<param id="tape" description="" command="hwinfo --tape"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="identification" description="" page="reg.jsp?guid={guid}&amp;lang={lang}" class="mandatory">
		<param id="email" description=""/>
	</param>
	<param id="regcode-sled" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="moniker" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
		<param id="sound" description="" command="hwinfo --sound"/>
		<param id="sys" description="" command="hwinfo --sys"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" type="${mirror:type}" description="${mirror:name}">
	<param id="url">${mirror:url}</param>
	<group-catalogs/>
</service>', 'Y', 'SLED');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(818, 'SUSE-Linux-Enterprise-Desktop-SP2', '10', NULL, 'i386', 'suse-linux-enterprise-desktop-sp2', '10', NULL, 'i386', 'SUSE Linux Enterprise Desktop 10 SP2', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sled" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="disk" description="" command="hwinfo --disk"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="scsi" description="" command="hwinfo --scsi"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="sys" description="" command="hwinfo --sys"/>
	<param id="tape" description="" command="hwinfo --tape"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="identification" description="" page="reg.jsp?guid={guid}&amp;lang={lang}" class="mandatory">
		<param id="email" description=""/>
	</param>
	<param id="regcode-sled" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="moniker" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
		<param id="sound" description="" command="hwinfo --sound"/>
		<param id="sys" description="" command="hwinfo --sys"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" type="${mirror:type}" description="${mirror:name}">
	<param id="url">${mirror:url}</param>
	<group-catalogs/>
</service>', 'Y', 'SLED');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(819, 'SUSE-Linux-Enterprise-Desktop-SP2', '10', NULL, 'x86_64', 'suse-linux-enterprise-desktop-sp2', '10', NULL, 'x86_64', 'SUSE Linux Enterprise Desktop 10 SP2', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sled" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="disk" description="" command="hwinfo --disk"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="scsi" description="" command="hwinfo --scsi"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="sys" description="" command="hwinfo --sys"/>
	<param id="tape" description="" command="hwinfo --tape"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="identification" description="" page="reg.jsp?guid={guid}&amp;lang={lang}" class="mandatory">
		<param id="email" description=""/>
	</param>
	<param id="regcode-sled" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="moniker" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
		<param id="sound" description="" command="hwinfo --sound"/>
		<param id="sys" description="" command="hwinfo --sys"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" type="${mirror:type}" description="${mirror:name}">
	<param id="url">${mirror:url}</param>
	<group-catalogs/>
</service>', 'Y', 'SLED');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(820, 'SUSE-Linux-Enterprise-Server-SP2', '10', NULL, 'i686', 'suse-linux-enterprise-server-sp2', '10', NULL, 'i686', 'SUSE Linux Enterprise Server 10 SP2', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sles" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="disk" description="" command="hwinfo --disk"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="scsi" description="" command="hwinfo --scsi"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="sys" description="" command="hwinfo --sys"/>
	<param id="tape" description="" command="hwinfo --tape"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="identification" description="" page="reg.jsp?guid={guid}&amp;lang={lang}" class="mandatory">
		<param id="email" description=""/>
	</param>
	<param id="regcode-sles" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="moniker" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="disk" description="" command="hwinfo --disk"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
		<param id="scsi" description="" command="hwinfo --scsi"/>
		<param id="sound" description="" command="hwinfo --sound"/>
		<param id="sys" description="" command="hwinfo --sys"/>
		<param id="tape" description="" command="hwinfo --tape"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<group-catalogs/>
</service>', 'Y', 'SLES');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(821, 'SUSE-Linux-Enterprise-Server-SP2', '10', NULL, 'i586', 'suse-linux-enterprise-server-sp2', '10', NULL, 'i586', 'SUSE Linux Enterprise Server 10 SP2', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sles" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="disk" description="" command="hwinfo --disk"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="scsi" description="" command="hwinfo --scsi"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="sys" description="" command="hwinfo --sys"/>
	<param id="tape" description="" command="hwinfo --tape"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="identification" description="" page="reg.jsp?guid={guid}&amp;lang={lang}" class="mandatory">
		<param id="email" description=""/>
	</param>
	<param id="regcode-sles" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="moniker" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="disk" description="" command="hwinfo --disk"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
		<param id="scsi" description="" command="hwinfo --scsi"/>
		<param id="sound" description="" command="hwinfo --sound"/>
		<param id="sys" description="" command="hwinfo --sys"/>
		<param id="tape" description="" command="hwinfo --tape"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<group-catalogs/>
</service>', 'Y', 'SLES');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(822, 'SUSE-Linux-Enterprise-Server-SP2', '10', NULL, 'i486', 'suse-linux-enterprise-server-sp2', '10', NULL, 'i486', 'SUSE Linux Enterprise Server 10 SP2', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sles" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="disk" description="" command="hwinfo --disk"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="scsi" description="" command="hwinfo --scsi"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="sys" description="" command="hwinfo --sys"/>
	<param id="tape" description="" command="hwinfo --tape"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="identification" description="" page="reg.jsp?guid={guid}&amp;lang={lang}" class="mandatory">
		<param id="email" description=""/>
	</param>
	<param id="regcode-sles" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="moniker" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="disk" description="" command="hwinfo --disk"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
		<param id="scsi" description="" command="hwinfo --scsi"/>
		<param id="sound" description="" command="hwinfo --sound"/>
		<param id="sys" description="" command="hwinfo --sys"/>
		<param id="tape" description="" command="hwinfo --tape"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<group-catalogs/>
</service>', 'Y', 'SLES');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(823, 'SUSE-Linux-Enterprise-Server-SP2', '10', NULL, 'i386', 'suse-linux-enterprise-server-sp2', '10', NULL, 'i386', 'SUSE Linux Enterprise Server 10 SP2', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sles" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="disk" description="" command="hwinfo --disk"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="scsi" description="" command="hwinfo --scsi"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="sys" description="" command="hwinfo --sys"/>
	<param id="tape" description="" command="hwinfo --tape"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="identification" description="" page="reg.jsp?guid={guid}&amp;lang={lang}" class="mandatory">
		<param id="email" description=""/>
	</param>
	<param id="regcode-sles" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="moniker" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="disk" description="" command="hwinfo --disk"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
		<param id="scsi" description="" command="hwinfo --scsi"/>
		<param id="sound" description="" command="hwinfo --sound"/>
		<param id="sys" description="" command="hwinfo --sys"/>
		<param id="tape" description="" command="hwinfo --tape"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<group-catalogs/>
</service>', 'Y', 'SLES');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(824, 'SUSE-Linux-Enterprise-Server-SP2', '10', NULL, 'x86_64', 'suse-linux-enterprise-server-sp2', '10', NULL, 'x86_64', 'SUSE Linux Enterprise Server 10 SP2', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sles" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="disk" description="" command="hwinfo --disk"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="scsi" description="" command="hwinfo --scsi"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="sys" description="" command="hwinfo --sys"/>
	<param id="tape" description="" command="hwinfo --tape"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="identification" description="" page="reg.jsp?guid={guid}&amp;lang={lang}" class="mandatory">
		<param id="email" description=""/>
	</param>
	<param id="regcode-sles" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="moniker" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="disk" description="" command="hwinfo --disk"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
		<param id="scsi" description="" command="hwinfo --scsi"/>
		<param id="sound" description="" command="hwinfo --sound"/>
		<param id="sys" description="" command="hwinfo --sys"/>
		<param id="tape" description="" command="hwinfo --tape"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<group-catalogs/>
</service>', 'Y', 'SLES');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(825, 'SUSE-Linux-Enterprise-Server-SP2', '10', NULL, 'ppc', 'suse-linux-enterprise-server-sp2', '10', NULL, 'ppc', 'SUSE Linux Enterprise Server 10 SP2', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sles" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="disk" description="" command="hwinfo --disk"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="scsi" description="" command="hwinfo --scsi"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="sys" description="" command="hwinfo --sys"/>
	<param id="tape" description="" command="hwinfo --tape"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="identification" description="" page="reg.jsp?guid={guid}&amp;lang={lang}" class="mandatory">
		<param id="email" description=""/>
	</param>
	<param id="regcode-sles" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="moniker" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="disk" description="" command="hwinfo --disk"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
		<param id="scsi" description="" command="hwinfo --scsi"/>
		<param id="sound" description="" command="hwinfo --sound"/>
		<param id="sys" description="" command="hwinfo --sys"/>
		<param id="tape" description="" command="hwinfo --tape"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<group-catalogs/>
</service>', 'Y', 'SLES');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(826, 'SUSE-Linux-Enterprise-Server-SP2', '10', NULL, 'ppc64', 'suse-linux-enterprise-server-sp2', '10', NULL, 'ppc64', 'SUSE Linux Enterprise Server 10 SP2', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sles" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="disk" description="" command="hwinfo --disk"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="scsi" description="" command="hwinfo --scsi"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="sys" description="" command="hwinfo --sys"/>
	<param id="tape" description="" command="hwinfo --tape"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="identification" description="" page="reg.jsp?guid={guid}&amp;lang={lang}" class="mandatory">
		<param id="email" description=""/>
	</param>
	<param id="regcode-sles" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="moniker" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="disk" description="" command="hwinfo --disk"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
		<param id="scsi" description="" command="hwinfo --scsi"/>
		<param id="sound" description="" command="hwinfo --sound"/>
		<param id="sys" description="" command="hwinfo --sys"/>
		<param id="tape" description="" command="hwinfo --tape"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<group-catalogs/>
</service>', 'Y', 'SLES');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(827, 'SUSE-Linux-Enterprise-Server-SP2', '10', NULL, 'ia64', 'suse-linux-enterprise-server-sp2', '10', NULL, 'ia64', 'SUSE Linux Enterprise Server 10 SP2', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sles" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="disk" description="" command="hwinfo --disk"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="scsi" description="" command="hwinfo --scsi"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="sys" description="" command="hwinfo --sys"/>
	<param id="tape" description="" command="hwinfo --tape"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="identification" description="" page="reg.jsp?guid={guid}&amp;lang={lang}" class="mandatory">
		<param id="email" description=""/>
	</param>
	<param id="regcode-sles" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="moniker" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="disk" description="" command="hwinfo --disk"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
		<param id="scsi" description="" command="hwinfo --scsi"/>
		<param id="sound" description="" command="hwinfo --sound"/>
		<param id="sys" description="" command="hwinfo --sys"/>
		<param id="tape" description="" command="hwinfo --tape"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<group-catalogs/>
</service>', 'Y', 'SLES');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(828, 'SUSE-Linux-Enterprise-Server-SP2', '10', NULL, 's390', 'suse-linux-enterprise-server-sp2', '10', NULL, 's390', 'SUSE Linux Enterprise Server 10 SP2', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sles" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="disk" description="" command="hwinfo --disk"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="scsi" description="" command="hwinfo --scsi"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="sys" description="" command="hwinfo --sys"/>
	<param id="tape" description="" command="hwinfo --tape"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="identification" description="" page="reg.jsp?guid={guid}&amp;lang={lang}" class="mandatory">
		<param id="email" description=""/>
	</param>
	<param id="regcode-sles" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="moniker" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="disk" description="" command="hwinfo --disk"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
		<param id="scsi" description="" command="hwinfo --scsi"/>
		<param id="sound" description="" command="hwinfo --sound"/>
		<param id="sys" description="" command="hwinfo --sys"/>
		<param id="tape" description="" command="hwinfo --tape"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<group-catalogs/>
</service>', 'Y', 'SLES');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(829, 'SUSE-Linux-Enterprise-Server-SP2', '10', NULL, 's390x', 'suse-linux-enterprise-server-sp2', '10', NULL, 's390x', 'SUSE Linux Enterprise Server 10 SP2', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sles" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="disk" description="" command="hwinfo --disk"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="scsi" description="" command="hwinfo --scsi"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="sys" description="" command="hwinfo --sys"/>
	<param id="tape" description="" command="hwinfo --tape"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="identification" description="" page="reg.jsp?guid={guid}&amp;lang={lang}" class="mandatory">
		<param id="email" description=""/>
	</param>
	<param id="regcode-sles" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="moniker" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="disk" description="" command="hwinfo --disk"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
		<param id="scsi" description="" command="hwinfo --scsi"/>
		<param id="sound" description="" command="hwinfo --sound"/>
		<param id="sys" description="" command="hwinfo --sys"/>
		<param id="tape" description="" command="hwinfo --tape"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<group-catalogs/>
</service>', 'Y', 'SLES');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(830, 'SUSE-Linux-Enterprise-Desktop-SP2', '10', 'online', 'i686', 'suse-linux-enterprise-desktop-sp2', '10', 'online', 'i686', 'SUSE Linux Enterprise Desktop 10 SP2', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sled" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="disk" description="" command="hwinfo --disk"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="scsi" description="" command="hwinfo --scsi"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="sys" description="" command="hwinfo --sys"/>
	<param id="tape" description="" command="hwinfo --tape"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="identification" description="" page="reg.jsp?guid={guid}&amp;lang={lang}" class="mandatory">
		<param id="email" description=""/>
	</param>
	<param id="regcode-sled" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="moniker" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
		<param id="sound" description="" command="hwinfo --sound"/>
		<param id="sys" description="" command="hwinfo --sys"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" type="${mirror:type}" description="${mirror:name}">
	<param id="url">${mirror:url}</param>
	<group-catalogs/>
</service>', 'Y', 'SLED');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(831, 'SUSE-Linux-Enterprise-Desktop-SP2', '10', 'online', 'i586', 'suse-linux-enterprise-desktop-sp2', '10', 'online', 'i586', 'SUSE Linux Enterprise Desktop 10 SP2', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sled" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="disk" description="" command="hwinfo --disk"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="scsi" description="" command="hwinfo --scsi"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="sys" description="" command="hwinfo --sys"/>
	<param id="tape" description="" command="hwinfo --tape"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="identification" description="" page="reg.jsp?guid={guid}&amp;lang={lang}" class="mandatory">
		<param id="email" description=""/>
	</param>
	<param id="regcode-sled" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="moniker" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
		<param id="sound" description="" command="hwinfo --sound"/>
		<param id="sys" description="" command="hwinfo --sys"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" type="${mirror:type}" description="${mirror:name}">
	<param id="url">${mirror:url}</param>
	<group-catalogs/>
</service>', 'Y', 'SLED');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(832, 'SUSE-Linux-Enterprise-Desktop-SP2', '10', 'online', 'i486', 'suse-linux-enterprise-desktop-sp2', '10', 'online', 'i486', 'SUSE Linux Enterprise Desktop 10 SP2', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sled" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="disk" description="" command="hwinfo --disk"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="scsi" description="" command="hwinfo --scsi"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="sys" description="" command="hwinfo --sys"/>
	<param id="tape" description="" command="hwinfo --tape"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="identification" description="" page="reg.jsp?guid={guid}&amp;lang={lang}" class="mandatory">
		<param id="email" description=""/>
	</param>
	<param id="regcode-sled" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="moniker" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
		<param id="sound" description="" command="hwinfo --sound"/>
		<param id="sys" description="" command="hwinfo --sys"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" type="${mirror:type}" description="${mirror:name}">
	<param id="url">${mirror:url}</param>
	<group-catalogs/>
</service>', 'Y', 'SLED');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(833, 'SUSE-Linux-Enterprise-Desktop-SP2', '10', 'online', 'i386', 'suse-linux-enterprise-desktop-sp2', '10', 'online', 'i386', 'SUSE Linux Enterprise Desktop 10 SP2', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sled" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="disk" description="" command="hwinfo --disk"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="scsi" description="" command="hwinfo --scsi"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="sys" description="" command="hwinfo --sys"/>
	<param id="tape" description="" command="hwinfo --tape"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="identification" description="" page="reg.jsp?guid={guid}&amp;lang={lang}" class="mandatory">
		<param id="email" description=""/>
	</param>
	<param id="regcode-sled" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="moniker" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
		<param id="sound" description="" command="hwinfo --sound"/>
		<param id="sys" description="" command="hwinfo --sys"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" type="${mirror:type}" description="${mirror:name}">
	<param id="url">${mirror:url}</param>
	<group-catalogs/>
</service>', 'Y', 'SLED');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(834, 'SUSE-Linux-Enterprise-Desktop-SP2', '10', 'online', 'x86_64', 'suse-linux-enterprise-desktop-sp2', '10', 'online', 'x86_64', 'SUSE Linux Enterprise Desktop 10 SP2', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sled" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="disk" description="" command="hwinfo --disk"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="scsi" description="" command="hwinfo --scsi"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="sys" description="" command="hwinfo --sys"/>
	<param id="tape" description="" command="hwinfo --tape"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="identification" description="" page="reg.jsp?guid={guid}&amp;lang={lang}" class="mandatory">
		<param id="email" description=""/>
	</param>
	<param id="regcode-sled" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="moniker" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
		<param id="sound" description="" command="hwinfo --sound"/>
		<param id="sys" description="" command="hwinfo --sys"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" type="${mirror:type}" description="${mirror:name}">
	<param id="url">${mirror:url}</param>
	<group-catalogs/>
</service>', 'Y', 'SLED');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(835, 'SUSE-Linux-Enterprise-Server-SP2', '10', 'online', 'i686', 'suse-linux-enterprise-server-sp2', '10', 'online', 'i686', 'SUSE Linux Enterprise Server 10 SP2', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sles" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="disk" description="" command="hwinfo --disk"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="scsi" description="" command="hwinfo --scsi"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="sys" description="" command="hwinfo --sys"/>
	<param id="tape" description="" command="hwinfo --tape"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="identification" description="" page="reg.jsp?guid={guid}&amp;lang={lang}" class="mandatory">
		<param id="email" description=""/>
	</param>
	<param id="regcode-sles" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="moniker" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="disk" description="" command="hwinfo --disk"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
		<param id="scsi" description="" command="hwinfo --scsi"/>
		<param id="sound" description="" command="hwinfo --sound"/>
		<param id="sys" description="" command="hwinfo --sys"/>
		<param id="tape" description="" command="hwinfo --tape"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<group-catalogs/>
</service>', 'Y', 'SLES');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(836, 'SUSE-Linux-Enterprise-Server-SP2', '10', 'online', 'i586', 'suse-linux-enterprise-server-sp2', '10', 'online', 'i586', 'SUSE Linux Enterprise Server 10 SP2', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sles" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="disk" description="" command="hwinfo --disk"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="scsi" description="" command="hwinfo --scsi"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="sys" description="" command="hwinfo --sys"/>
	<param id="tape" description="" command="hwinfo --tape"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="identification" description="" page="reg.jsp?guid={guid}&amp;lang={lang}" class="mandatory">
		<param id="email" description=""/>
	</param>
	<param id="regcode-sles" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="moniker" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="disk" description="" command="hwinfo --disk"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
		<param id="scsi" description="" command="hwinfo --scsi"/>
		<param id="sound" description="" command="hwinfo --sound"/>
		<param id="sys" description="" command="hwinfo --sys"/>
		<param id="tape" description="" command="hwinfo --tape"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<group-catalogs/>
</service>', 'Y', 'SLES');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(837, 'SUSE-Linux-Enterprise-Server-SP2', '10', 'online', 'i486', 'suse-linux-enterprise-server-sp2', '10', 'online', 'i486', 'SUSE Linux Enterprise Server 10 SP2', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sles" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="disk" description="" command="hwinfo --disk"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="scsi" description="" command="hwinfo --scsi"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="sys" description="" command="hwinfo --sys"/>
	<param id="tape" description="" command="hwinfo --tape"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="identification" description="" page="reg.jsp?guid={guid}&amp;lang={lang}" class="mandatory">
		<param id="email" description=""/>
	</param>
	<param id="regcode-sles" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="moniker" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="disk" description="" command="hwinfo --disk"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
		<param id="scsi" description="" command="hwinfo --scsi"/>
		<param id="sound" description="" command="hwinfo --sound"/>
		<param id="sys" description="" command="hwinfo --sys"/>
		<param id="tape" description="" command="hwinfo --tape"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<group-catalogs/>
</service>', 'Y', 'SLES');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(838, 'SUSE-Linux-Enterprise-Server-SP2', '10', 'online', 'i386', 'suse-linux-enterprise-server-sp2', '10', 'online', 'i386', 'SUSE Linux Enterprise Server 10 SP2', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sles" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="disk" description="" command="hwinfo --disk"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="scsi" description="" command="hwinfo --scsi"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="sys" description="" command="hwinfo --sys"/>
	<param id="tape" description="" command="hwinfo --tape"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="identification" description="" page="reg.jsp?guid={guid}&amp;lang={lang}" class="mandatory">
		<param id="email" description=""/>
	</param>
	<param id="regcode-sles" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="moniker" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="disk" description="" command="hwinfo --disk"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
		<param id="scsi" description="" command="hwinfo --scsi"/>
		<param id="sound" description="" command="hwinfo --sound"/>
		<param id="sys" description="" command="hwinfo --sys"/>
		<param id="tape" description="" command="hwinfo --tape"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<group-catalogs/>
</service>', 'Y', 'SLES');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(839, 'SUSE-Linux-Enterprise-Server-SP2', '10', 'online', 'x86_64', 'suse-linux-enterprise-server-sp2', '10', 'online', 'x86_64', 'SUSE Linux Enterprise Server 10 SP2', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sles" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="disk" description="" command="hwinfo --disk"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="scsi" description="" command="hwinfo --scsi"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="sys" description="" command="hwinfo --sys"/>
	<param id="tape" description="" command="hwinfo --tape"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="identification" description="" page="reg.jsp?guid={guid}&amp;lang={lang}" class="mandatory">
		<param id="email" description=""/>
	</param>
	<param id="regcode-sles" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="moniker" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="disk" description="" command="hwinfo --disk"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
		<param id="scsi" description="" command="hwinfo --scsi"/>
		<param id="sound" description="" command="hwinfo --sound"/>
		<param id="sys" description="" command="hwinfo --sys"/>
		<param id="tape" description="" command="hwinfo --tape"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<group-catalogs/>
</service>', 'Y', 'SLES');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(840, 'SUSE-Linux-Enterprise-Server-SP2', '10', 'online', 'ppc', 'suse-linux-enterprise-server-sp2', '10', 'online', 'ppc', 'SUSE Linux Enterprise Server 10 SP2', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sles" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="disk" description="" command="hwinfo --disk"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="scsi" description="" command="hwinfo --scsi"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="sys" description="" command="hwinfo --sys"/>
	<param id="tape" description="" command="hwinfo --tape"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="identification" description="" page="reg.jsp?guid={guid}&amp;lang={lang}" class="mandatory">
		<param id="email" description=""/>
	</param>
	<param id="regcode-sles" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="moniker" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="disk" description="" command="hwinfo --disk"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
		<param id="scsi" description="" command="hwinfo --scsi"/>
		<param id="sound" description="" command="hwinfo --sound"/>
		<param id="sys" description="" command="hwinfo --sys"/>
		<param id="tape" description="" command="hwinfo --tape"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<group-catalogs/>
</service>', 'Y', 'SLES');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(841, 'SUSE-Linux-Enterprise-Server-SP2', '10', 'online', 'ppc64', 'suse-linux-enterprise-server-sp2', '10', 'online', 'ppc64', 'SUSE Linux Enterprise Server 10 SP2', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sles" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="disk" description="" command="hwinfo --disk"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="scsi" description="" command="hwinfo --scsi"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="sys" description="" command="hwinfo --sys"/>
	<param id="tape" description="" command="hwinfo --tape"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="identification" description="" page="reg.jsp?guid={guid}&amp;lang={lang}" class="mandatory">
		<param id="email" description=""/>
	</param>
	<param id="regcode-sles" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="moniker" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="disk" description="" command="hwinfo --disk"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
		<param id="scsi" description="" command="hwinfo --scsi"/>
		<param id="sound" description="" command="hwinfo --sound"/>
		<param id="sys" description="" command="hwinfo --sys"/>
		<param id="tape" description="" command="hwinfo --tape"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<group-catalogs/>
</service>', 'Y', 'SLES');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(842, 'SUSE-Linux-Enterprise-Server-SP2', '10', 'online', 'ia64', 'suse-linux-enterprise-server-sp2', '10', 'online', 'ia64', 'SUSE Linux Enterprise Server 10 SP2', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sles" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="disk" description="" command="hwinfo --disk"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="scsi" description="" command="hwinfo --scsi"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="sys" description="" command="hwinfo --sys"/>
	<param id="tape" description="" command="hwinfo --tape"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="identification" description="" page="reg.jsp?guid={guid}&amp;lang={lang}" class="mandatory">
		<param id="email" description=""/>
	</param>
	<param id="regcode-sles" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="moniker" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="disk" description="" command="hwinfo --disk"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
		<param id="scsi" description="" command="hwinfo --scsi"/>
		<param id="sound" description="" command="hwinfo --sound"/>
		<param id="sys" description="" command="hwinfo --sys"/>
		<param id="tape" description="" command="hwinfo --tape"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<group-catalogs/>
</service>', 'Y', 'SLES');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(843, 'SUSE-Linux-Enterprise-Server-SP2', '10', 'online', 's390', 'suse-linux-enterprise-server-sp2', '10', 'online', 's390', 'SUSE Linux Enterprise Server 10 SP2', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sles" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="disk" description="" command="hwinfo --disk"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="scsi" description="" command="hwinfo --scsi"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="sys" description="" command="hwinfo --sys"/>
	<param id="tape" description="" command="hwinfo --tape"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="identification" description="" page="reg.jsp?guid={guid}&amp;lang={lang}" class="mandatory">
		<param id="email" description=""/>
	</param>
	<param id="regcode-sles" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="moniker" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="disk" description="" command="hwinfo --disk"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
		<param id="scsi" description="" command="hwinfo --scsi"/>
		<param id="sound" description="" command="hwinfo --sound"/>
		<param id="sys" description="" command="hwinfo --sys"/>
		<param id="tape" description="" command="hwinfo --tape"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<group-catalogs/>
</service>', 'Y', 'SLES');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(844, 'SUSE-Linux-Enterprise-Server-SP2', '10', 'online', 's390x', 'suse-linux-enterprise-server-sp2', '10', 'online', 's390x', 'SUSE Linux Enterprise Server 10 SP2', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-sles" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="disk" description="" command="hwinfo --disk"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="scsi" description="" command="hwinfo --scsi"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="sys" description="" command="hwinfo --sys"/>
	<param id="tape" description="" command="hwinfo --tape"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="identification" description="" page="reg.jsp?guid={guid}&amp;lang={lang}" class="mandatory">
		<param id="email" description=""/>
	</param>
	<param id="regcode-sles" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="moniker" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="disk" description="" command="hwinfo --disk"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
		<param id="scsi" description="" command="hwinfo --scsi"/>
		<param id="sound" description="" command="hwinfo --sound"/>
		<param id="sys" description="" command="hwinfo --sys"/>
		<param id="tape" description="" command="hwinfo --tape"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<group-catalogs/>
</service>', 'Y', 'SLES');

INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(860, 'SUSE-Linux-Enterprise-POS', '10', NULL, NULL, 'suse-linux-enterprise-pos', '10', NULL, NULL, 'SUSE Linux Enterprise Point of Service 10', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="email" description="" class="mandatory"/>
	<param id="regcode-slepos" description=""/>
	<param id="moniker" description=""/>
	<param id="processor" description="" command="uname -p"/>
	<param id="platform" description="" command="uname -i"/>
	<param id="hostname" description="" command="uname -n"/>
	<param id="cpu" description="" command="hwinfo --cpu"/>
	<param id="disk" description="" command="hwinfo --disk"/>
	<param id="dsl" description="" command="hwinfo --dsl"/>
	<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
	<param id="isdn" description="" command="hwinfo --isdn"/>
	<param id="memory" description="" command="hwinfo --memory"/>
	<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
	<param id="scsi" description="" command="hwinfo --scsi"/>
	<param id="sound" description="" command="hwinfo --sound"/>
	<param id="sys" description="" command="hwinfo --sys"/>
	<param id="tape" description="" command="hwinfo --tape"/>
</paramlist>', '<?xml version="1.0" encoding="UTF-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="" href="">
	<guid description="" class="mandatory"/>
	<param id="secret" description="" command="zmd-secret" class="mandatory"/>
	<host description=""/>
	<product description="" class="mandatory"/>
	<param id="ostarget" description="" command="zmd-ostarget" class="mandatory"/>
	<param id="ostarget-bak" description="" command="lsb_release -sd" class="mandatory"/>
	<param id="identification" description="" page="reg.jsp?guid={guid}&amp;lang={lang}" class="mandatory">
		<param id="email" description=""/>
	</param>
	<param id="regcode-slepos" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="moniker" description="" page="reg.jsp?guid={guid}&amp;lang={lang}"/>
	<param id="sysident" description="">
		<param id="processor" description="" command="uname -p"/>
		<param id="platform" description="" command="uname -i"/>
		<param id="hostname" description="" command="uname -n"/>
	</param>
	<param id="hw_inventory" description="">
		<param id="cpu" description="" command="hwinfo --cpu"/>
		<param id="disk" description="" command="hwinfo --disk"/>
		<param id="dsl" description="" command="hwinfo --dsl"/>
		<param id="gfxcard" description="" command="hwinfo --gfxcard"/>
		<param id="isdn" description="" command="hwinfo --isdn"/>
		<param id="memory" description="" command="hwinfo --memory"/>
		<param id="netcard" description="" command="hwinfo --netcard --nowpa"/>
		<param id="scsi" description="" command="hwinfo --scsi"/>
		<param id="sound" description="" command="hwinfo --sound"/>
		<param id="sys" description="" command="hwinfo --sys"/>
		<param id="tape" description="" command="hwinfo --tape"/>
	</param>
	<privacy url="http://www.novell.com/company/policies/privacy/textonly.html" description="" class="informative"/>
</needinfo>', '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<group-catalogs/>
</service>', 'Y', 'SLEPOS');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, REL, ARCH, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST, PRODUCT_CLASS)
  VALUES(880, 'SUSE-Linux-Enterprise-SDK-SP2', '10', NULL, NULL, 'suse-linux-enterprise-sdk-sp2', '10', NULL, NULL, 'SUSE Linux 10 SP2 Software Development Kit', NULL, NULL, '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="group">sle10-sdk-sp2</param>
</service>', 'Y', 'SDK');
