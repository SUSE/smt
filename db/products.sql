---------------------------------------------------------------------------------------------------------------
-- select PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST
-- from activator.NNW_PRODUCT_DATA where PRODUCT_LIST = 'Y'
--------------------------------------------------------------------------------------------------------------- 
-- result export as insert statements
---------------------------------------------------------------------------------------------------------------
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(424, 'SUSE-Linux-Enterprise-Server-SP1-migration', '10', NULL, 'i386', 'SUSE Linux Enterprise Server 10 SP1 Migration', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(425, 'SUSE-Linux-Enterprise-Server-SP1-migration', '10', NULL, 'x86_64', 'SUSE Linux Enterprise Server 10 SP1 Migration', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(422, 'SUSE-Linux-Enterprise-Server-SP1-migration', '10', NULL, 'i586', 'SUSE Linux Enterprise Server 10 SP1 Migration', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(423, 'SUSE-Linux-Enterprise-Server-SP1-migration', '10', NULL, 'i486', 'SUSE Linux Enterprise Server 10 SP1 Migration', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(421, 'SUSE-Linux-Enterprise-Server-SP1-migration', '10', NULL, 'i686', 'SUSE Linux Enterprise Server 10 SP1 Migration', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(420, 'SUSE-Linux-Enterprise-Desktop-SP1-migration', '10', NULL, 'x86_64', 'SUSE Linux Enterprise Desktop 10 SP1 Migration', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(418, 'SUSE-Linux-Enterprise-Desktop-SP1-migration', '10', NULL, 'i486', 'SUSE Linux Enterprise Desktop 10 SP1 Migration', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(419, 'SUSE-Linux-Enterprise-Desktop-SP1-migration', '10', NULL, 'i386', 'SUSE Linux Enterprise Desktop 10 SP1 Migration', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(416, 'SUSE-Linux-Enterprise-Desktop-SP1-migration', '10', NULL, 'i686', 'SUSE Linux Enterprise Desktop 10 SP1 Migration', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(417, 'SUSE-Linux-Enterprise-Desktop-SP1-migration', '10', NULL, 'i586', 'SUSE Linux Enterprise Desktop 10 SP1 Migration', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(376, 'openSUSE-10.3-dvd5-download', '10.3', NULL, NULL, 'openSUSE 10.3', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(377, 'openSUSE-10.3-CD-download', '10.3', NULL, NULL, 'openSUSE 10.3', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(340, 'openSUSE-10.2-FTP', '10.2', NULL, NULL, 'openSUSE 10.2', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(21, 'SUSE-Linux-Enterprise-Desktop-i386', '10', NULL, 'i686', 'SUSE Linux Enterprise Desktop 10', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(22, 'SUSE-Linux-Enterprise-Desktop-i386', '10', NULL, 'i586', 'SUSE Linux Enterprise Desktop 10', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(23, 'SUSE-Linux-Enterprise-Desktop-i386', '10', NULL, 'i486', 'SUSE Linux Enterprise Desktop 10', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(24, 'SUSE-Linux-Enterprise-Desktop-i386', '10', NULL, 'i386', 'SUSE Linux Enterprise Desktop 10', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(25, 'SUSE-Linux-Enterprise-Desktop-x86_64', '10', NULL, 'x86_64', 'SUSE Linux Enterprise Desktop 10', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(26, 'SUSE-Linux-Enterprise-Server-i386', '10', NULL, 'i686', 'SUSE Linux Enterprise Server 10', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(27, 'SUSE-Linux-Enterprise-Server-i386', '10', NULL, 'i586', 'SUSE Linux Enterprise Server 10', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(28, 'SUSE-Linux-Enterprise-Server-i386', '10', NULL, 'i486', 'SUSE Linux Enterprise Server 10', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(29, 'SUSE-Linux-Enterprise-Server-i386', '10', NULL, 'i386', 'SUSE Linux Enterprise Server 10', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(30, 'SUSE-Linux-Enterprise-Server-x86_64', '10', NULL, 'x86_64', 'SUSE Linux Enterprise Server 10', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(31, 'SUSE-Linux-Enterprise-Server-ppc', '10', NULL, 'ppc', 'SUSE Linux Enterprise Server 10', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(32, 'SUSE-Linux-Enterprise-Server-ppc', '10', NULL, 'ppc64', 'SUSE Linux Enterprise Server 10', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(33, 'SUSE-Linux-Enterprise-Server-ia64', '10', NULL, 'ia64', 'SUSE Linux Enterprise Server 10', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(34, 'SUSE-Linux-Enterprise-Server-s390x', '10', NULL, 's390x', 'SUSE Linux Enterprise Server 10', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(35, 'SUSE-Linux-Enterprise-Server-s390x', '10', NULL, 's390', 'SUSE Linux Enterprise Server 10', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(56, 'SUSE-Linux-10.1-CD-download-x86', '10.1', NULL, 'i386', 'SUSE Linux 10.1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(57, 'SUSE-Linux-10.1-CD-download-ppc', '10.1', NULL, NULL, 'SUSE Linux 10.1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(58, 'SUSE-Linux-10.1-CD-download-x86_64', '10.1', NULL, 'x86_64', 'SUSE Linux 10.1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(81, 'SUSE-Linux-10.1-CD-download-x86', '10.1', NULL, 'i686', 'SUSE Linux 10.1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(80, 'SUSE-Linux-10.1-CD-download-x86', '10.1', NULL, 'i586', 'SUSE Linux 10.1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(61, 'SUSE-Linux-10.1-CD-x86', '10.1', NULL, 'i386', 'SUSE Linux 10.1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(62, 'SUSE-Linux-10.1-CD-ppc', '10.1', NULL, 'ppc', 'SUSE Linux 10.1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(63, 'SUSE-Linux-10.1-CD-x86_64', '10.1', NULL, 'x86_64', 'SUSE Linux 10.1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(64, 'SUSE-Linux-10.1-DVD9-x86-x86_64', '10.1', NULL, 'x86_64', 'SUSE Linux 10.1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(65, 'SUSE-Linux-10.1-OSS-DVD-x86', '10.1', NULL, 'i386', 'SUSE Linux 10.1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(66, 'SUSE-Linux-10.1-DVD-OSS-i386', '10.1', NULL, 'i386', 'SUSE Linux 10.1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(67, 'SUSE-Linux-10.1-DVD-OSS-ppc', '10.1', NULL, 'ppc', 'SUSE Linux 10.1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(68, 'SUSE-Linux-10.1-DVD-OSS-x86_64', '10.1', NULL, 'x86_64', 'SUSE Linux 10.1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(69, 'SUSE-Linux-10.1-FTP', '10.1', NULL, NULL, 'SUSE Linux 10.1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(76, 'SUSE-Linux-10.1-DVD-i386', '10.1', NULL, 'i386', 'SUSE Linux 10.1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(77, 'SUSE-Linux-10.1-DVD-x86_64', '10.1', NULL, 'x86_64', 'SUSE Linux 10.1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(78, 'SuSE-Linux-10.1-PromoDVD-i386', '10.1', NULL, 'i386', 'SUSE Linux 10.1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(79, 'SUSE-Linux-10.1-CD-download-x86', '10.1', NULL, 'i486', 'SUSE Linux 10.1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(96, 'SUSE-Linux-10.1-CD-x86', '10.1', NULL, 'i486', 'SUSE Linux 10.1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(97, 'SUSE-Linux-10.1-CD-x86', '10.1', NULL, 'i586', 'SUSE Linux 10.1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(98, 'SUSE-Linux-10.1-CD-x86', '10.1', NULL, 'i686', 'SUSE Linux 10.1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(99, 'SUSE-Linux-10.1-DVD-OSS-i386', '10.1', NULL, 'i486', 'SUSE Linux 10.1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(100, 'SUSE-Linux-10.1-DVD-OSS-i386', '10.1', NULL, 'i586', 'SUSE Linux 10.1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(101, 'SUSE-Linux-10.1-DVD-OSS-i386', '10.1', NULL, 'i686', 'SUSE Linux 10.1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(102, 'SUSE-Linux-10.1-DVD-i386', '10.1', NULL, 'i486', 'SUSE Linux 10.1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(103, 'SUSE-Linux-10.1-DVD-i386', '10.1', NULL, 'i586', 'SUSE Linux 10.1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(104, 'SUSE-Linux-10.1-DVD-i386', '10.1', NULL, 'i686', 'SUSE Linux 10.1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(105, 'SUSE-Linux-10.1-OSS-DVD-x86', '10.1', NULL, 'i486', 'SUSE Linux 10.1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(106, 'SUSE-Linux-10.1-OSS-DVD-x86', '10.1', NULL, 'i586', 'SUSE Linux 10.1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(107, 'SUSE-Linux-10.1-OSS-DVD-x86', '10.1', NULL, 'i686', 'SUSE Linux 10.1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(108, 'SuSE-Linux-10.1-PromoDVD-i386', '10.1', NULL, 'i486', 'SUSE Linux 10.1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(109, 'SuSE-Linux-10.1-PromoDVD-i386', '10.1', NULL, 'i586', 'SUSE Linux 10.1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(110, 'SuSE-Linux-10.1-PromoDVD-i386', '10.1', NULL, 'i686', 'SUSE Linux 10.1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(125, 'SUSE-Linux-10.1-DVD9-x86-x86_64', '10.1', NULL, 'i386', 'SUSE Linux 10.1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(126, 'SUSE-Linux-10.1-DVD9-x86-x86_64', '10.1', NULL, 'i486', 'SUSE Linux 10.1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(127, 'SUSE-Linux-10.1-DVD9-x86-x86_64', '10.1', NULL, 'i586', 'SUSE Linux 10.1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(128, 'SUSE-Linux-10.1-DVD9-x86-x86_64', '10.1', NULL, 'i686', 'SUSE Linux 10.1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(136, 'SUSE-Linux-10.1-DVD9-CTMAGAZIN-x86-x86_64', '10.1', NULL, 'i686', 'SUSE Linux 10.1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(137, 'SUSE-Linux-10.1-DVD9-CTMAGAZIN-x86-x86_64', '10.1', NULL, 'i586', 'SUSE Linux 10.1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(138, 'SUSE-Linux-10.1-DVD9-CTMAGAZIN-x86-x86_64', '10.1', NULL, 'i486', 'SUSE Linux 10.1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(139, 'SUSE-Linux-10.1-DVD9-CTMAGAZIN-x86-x86_64', '10.1', NULL, 'i386', 'SUSE Linux 10.1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(140, 'SUSE-Linux-10.1-DVD9-CTMAGAZIN-x86-x86_64', '10.1', NULL, 'x86_64', 'SUSE Linux 10.1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(141, 'nVidia Video Drivers', NULL, NULL, NULL, 'nVidia Video Drivers', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(142, 'ATI Video Drivers', NULL, NULL, NULL, 'ATI Video Drivers', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(176, 'SUSE-Linux-Enterprise-SDK-i386', '10', NULL, NULL, 'SUSE Linux 10 Software Development Kit', NULL, NULL, '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="group">sle10-sdk</param>
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(177, 'SUSE-Linux-Enterprise-SDK-x86_64', '10', NULL, NULL, 'SUSE Linux 10 Software Development Kit', NULL, NULL, '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="group">sle10-sdk</param>
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(178, 'SUSE-Linux-Enterprise-SDK-ia64', '10', NULL, NULL, 'SUSE Linux 10 Software Development Kit', NULL, NULL, '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="group">sle10-sdk</param>
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(179, 'SUSE-Linux-Enterprise-SDK-s390x', '10', NULL, NULL, 'SUSE Linux 10 Software Development Kit', NULL, NULL, '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="group">sle10-sdk</param>
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(180, 'SUSE-Linux-Enterprise-SDK-ppc', '10', NULL, NULL, 'SUSE Linux 10 Software Development Kit', NULL, NULL, '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="group">sle10-sdk</param>
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(236, 'openSUSE-10.2-CD-download', '10.2', NULL, NULL, 'SUSE Linux 10.2', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(276, 'SUSE-Linux-Enterprise-RT', '10', NULL, NULL, 'SUSE Linux Enterprise Real-Time 10', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(316, 'SUSE-Linux-Enterprise-SDK-DVD-i386', '10', NULL, NULL, 'SUSE Linux 10 Software Development Kit', NULL, NULL, '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="group">sle10-sdk</param>
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(317, 'SUSE-Linux-Enterprise-SDK-DVD-x86_64', '10', NULL, NULL, 'SUSE Linux 10 Software Development Kit', NULL, NULL, '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="group">sle10-sdk</param>
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(318, 'SUSE-Linux-Enterprise-SDK-DVD-ia64', '10', NULL, NULL, 'SUSE Linux 10 Software Development Kit', NULL, NULL, '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="group">sle10-sdk</param>
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(319, 'SUSE-Linux-Enterprise-SDK-DVD-s390x', '10', NULL, NULL, 'SUSE Linux 10 Software Development Kit', NULL, NULL, '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="group">sle10-sdk</param>
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(320, 'SUSE-Linux-Enterprise-SDK-DVD-ppc', '10', NULL, NULL, 'SUSE Linux 10 Software Development Kit', NULL, NULL, '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="group">sle10-sdk</param>
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(336, 'openSUSE-10.2-dvd5-download', '10.2', NULL, NULL, 'openSUSE 10.2', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(337, 'openSUSE-10.2-CD-retail', '10.2', NULL, NULL, 'openSUSE 10.2', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(338, 'openSUSE-10.2-DVD9-retail', '10.2', NULL, NULL, 'openSUSE 10.2', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(339, 'openSUSE-10.2-Promo', '10.2', NULL, NULL, 'openSUSE 10.2', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(426, 'SUSE-Linux-Enterprise-Server-SP1-migration', '10', NULL, 'ppc', 'SUSE Linux Enterprise Server 10 SP1 Migration', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(427, 'SUSE-Linux-Enterprise-Server-SP1-migration', '10', NULL, 'ppc64', 'SUSE Linux Enterprise Server 10 SP1 Migration', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(428, 'SUSE-Linux-Enterprise-Server-SP1-migration', '10', NULL, 'ia64', 'SUSE Linux Enterprise Server 10 SP1 Migration', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(429, 'SUSE-Linux-Enterprise-Server-SP1-migration', '10', NULL, 's390', 'SUSE Linux Enterprise Server 10 SP1 Migration', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(430, 'SUSE-Linux-Enterprise-Server-SP1-migration', '10', NULL, 's390x', 'SUSE Linux Enterprise Server 10 SP1 Migration', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(431, 'SUSE-Linux-Enterprise-Desktop-SP1', '10', NULL, 'i686', 'SUSE Linux Enterprise Desktop 10 SP1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(432, 'SUSE-Linux-Enterprise-Desktop-SP1', '10', NULL, 'i586', 'SUSE Linux Enterprise Desktop 10 SP1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(433, 'SUSE-Linux-Enterprise-Desktop-SP1', '10', NULL, 'i486', 'SUSE Linux Enterprise Desktop 10 SP1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(434, 'SUSE-Linux-Enterprise-Desktop-SP1', '10', NULL, 'i386', 'SUSE Linux Enterprise Desktop 10 SP1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(435, 'SUSE-Linux-Enterprise-Desktop-SP1', '10', NULL, 'x86_64', 'SUSE Linux Enterprise Desktop 10 SP1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(436, 'SUSE-Linux-Enterprise-Server-SP1', '10', NULL, 'i686', 'SUSE Linux Enterprise Server 10 SP1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(437, 'SUSE-Linux-Enterprise-Server-SP1', '10', NULL, 'i586', 'SUSE Linux Enterprise Server 10 SP1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(438, 'SUSE-Linux-Enterprise-Server-SP1', '10', NULL, 'i486', 'SUSE Linux Enterprise Server 10 SP1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(439, 'SUSE-Linux-Enterprise-Server-SP1', '10', NULL, 'i386', 'SUSE Linux Enterprise Server 10 SP1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(440, 'SUSE-Linux-Enterprise-Server-SP1', '10', NULL, 'x86_64', 'SUSE Linux Enterprise Server 10 SP1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(441, 'SUSE-Linux-Enterprise-Server-SP1', '10', NULL, 'ppc', 'SUSE Linux Enterprise Server 10 SP1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(442, 'SUSE-Linux-Enterprise-Server-SP1', '10', NULL, 'ppc64', 'SUSE Linux Enterprise Server 10 SP1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(443, 'SUSE-Linux-Enterprise-Server-SP1', '10', NULL, 'ia64', 'SUSE Linux Enterprise Server 10 SP1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(444, 'SUSE-Linux-Enterprise-Server-SP1', '10', NULL, 's390', 'SUSE Linux Enterprise Server 10 SP1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(445, 'SUSE-Linux-Enterprise-Server-SP1', '10', NULL, 's390x', 'SUSE Linux Enterprise Server 10 SP1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(446, 'SUSE-Linux-Enterprise-Desktop-SP1', '10', 'online', 'i686', 'SUSE Linux Enterprise Desktop 10 SP1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(447, 'SUSE-Linux-Enterprise-Desktop-SP1', '10', 'online', 'i586', 'SUSE Linux Enterprise Desktop 10 SP1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(448, 'SUSE-Linux-Enterprise-Desktop-SP1', '10', 'online', 'i486', 'SUSE Linux Enterprise Desktop 10 SP1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(449, 'SUSE-Linux-Enterprise-Desktop-SP1', '10', 'online', 'i386', 'SUSE Linux Enterprise Desktop 10 SP1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(450, 'SUSE-Linux-Enterprise-Desktop-SP1', '10', 'online', 'x86_64', 'SUSE Linux Enterprise Desktop 10 SP1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(451, 'SUSE-Linux-Enterprise-Server-SP1', '10', 'online', 'i686', 'SUSE Linux Enterprise Server 10 SP1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(452, 'SUSE-Linux-Enterprise-Server-SP1', '10', 'online', 'i586', 'SUSE Linux Enterprise Server 10 SP1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(453, 'SUSE-Linux-Enterprise-Server-SP1', '10', 'online', 'i486', 'SUSE Linux Enterprise Server 10 SP1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(454, 'SUSE-Linux-Enterprise-Server-SP1', '10', 'online', 'i386', 'SUSE Linux Enterprise Server 10 SP1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(455, 'SUSE-Linux-Enterprise-Server-SP1', '10', 'online', 'x86_64', 'SUSE Linux Enterprise Server 10 SP1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(456, 'SUSE-Linux-Enterprise-Server-SP1', '10', 'online', 'ppc', 'SUSE Linux Enterprise Server 10 SP1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(457, 'SUSE-Linux-Enterprise-Server-SP1', '10', 'online', 'ppc64', 'SUSE Linux Enterprise Server 10 SP1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(458, 'SUSE-Linux-Enterprise-Server-SP1', '10', 'online', 'ia64', 'SUSE Linux Enterprise Server 10 SP1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(459, 'SUSE-Linux-Enterprise-Server-SP1', '10', 'online', 's390', 'SUSE Linux Enterprise Server 10 SP1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(460, 'SUSE-Linux-Enterprise-Server-SP1', '10', 'online', 's390x', 'SUSE Linux Enterprise Server 10 SP1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(538, 'Novell-Open-Enterprise-Server-i386', '2', NULL, 'i486', 'Novell Open Enterprise Server 2', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(536, 'Novell-Open-Enterprise-Server-i386', '2', NULL, 'i686', 'Novell Open Enterprise Server 2', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(537, 'Novell-Open-Enterprise-Server-i386', '2', NULL, 'i586', 'Novell Open Enterprise Server 2', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(539, 'Novell-Open-Enterprise-Server-i386', '2', NULL, 'i386', 'Novell Open Enterprise Server 2', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(540, 'Novell-Open-Enterprise-Server-x86_64', '2', NULL, 'x86_64', 'Novell Open Enterprise Server 2', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(556, 'SUSE-Linux-Enterprise-SDK-SP1-migration', '10', NULL, NULL, 'SUSE Linux 10 SP1 Software Development Kit', NULL, NULL, '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="group">sle10-sdk-sp1-online</param>
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(557, 'SUSE-Linux-Enterprise-SDK-SP1', '10', NULL, NULL, 'SUSE Linux 10 SP1 Software Development Kit', NULL, NULL, '<service xmlns="http://www.novell.com/xml/center/regsvc-1_0" id="${mirror:id}" description="${mirror:name}" type="${mirror:type}">
	<param id="url">${mirror:url}</param>
	<param id="group">sle10-sdk-sp1</param>
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(560, 'openSUSE-10.3-GNOME-download', '10.3', NULL, NULL, 'openSUSE 10.3', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(561, 'openSUSE-10.3-KDE-download', '10.3', NULL, NULL, 'openSUSE 10.3', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(580, 'SUSE-Linux-Enterprise-Virtual-Machine-Driver-Pack', '10', NULL, NULL, 'SUSE Linux Enterprise Virtual Machine Driver Pack 1.1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(600, 'ZENworks Pulsar', '1.0', NULL, NULL, 'ZENworks Pulsar 1.0', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(621, 'SUSE-Linux-Enterprise-HA-Server', '1.0', NULL, NULL, 'SUSE Linux Enterprise HA Server 1.0', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(640, 'ZENworks_Orchestrator', '1.1', NULL, 'i686', 'ZENworks Orchestrator 1.1', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(660, 'openSUSE-10.3-OSS-Gnome', '10.3', NULL, NULL, 'openSUSE 10.3', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(661, 'openSUSE-10.3-OSS-KDE', '10.3', NULL, NULL, 'openSUSE 10.3', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(662, 'openSUSE-10.3-DVD', '10.3', NULL, NULL, 'openSUSE 10.3', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(663, 'openSUSE-10.3-retail', '10.3', NULL, NULL, 'openSUSE 10.3', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(664, 'openSUSE-10.3-FTP', '10.3', NULL, NULL, 'openSUSE 10.3', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(680, 'SUSE-Linux-Enterprise-RT', '10.2.0', NULL, NULL, 'SUSE Linux Enterprise Server RT Solution 10', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(700, 'openSUSE-10.3-DVD-ct', '10.3', NULL, NULL, 'openSUSE 10.3', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(701, 'openSUSE-10.3-DVD-Magazine', '10.3', NULL, NULL, 'openSUSE 10.3', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(740, 'openSUSE-10.3-Live-Gnome', '10.3', NULL, NULL, 'openSUSE 10.3', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(741, 'openSUSE-10.3-Live-KDE', '10.3', NULL, NULL, 'openSUSE 10.3', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(742, 'openSUSE-10.3-Promo', '10.3', NULL, NULL, 'openSUSE 10.3', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</service>', 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(760, 'SUSE-Linux-SLES-i386', '9', NULL, NULL, 'SUSE Linux Enterprise Server 9', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</needinfo>', NULL, 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(761, 'SLES9-SLD-SP-i386', '9', NULL, NULL, 'Novell Linux Desktop 9', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</needinfo>', NULL, 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(762, 'Novell-Open-Enterprise-Server-i386', '9', NULL, NULL, 'Novell Open Enterprise Server', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</needinfo>', NULL, 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(763, 'SUSE-Linux-SLES-x86_64', '9', NULL, NULL, 'SUSE Linux Enterprise Server 9', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</needinfo>', NULL, 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(764, 'SLES9-SLD-SP-x86_64', '9', NULL, NULL, 'Novell Linux Desktop 9', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</needinfo>', NULL, 'Y');
INSERT INTO Products(PRODUCTDATAID, PRODUCT, VERSION, RELEASE, ARCH, FRIENDLY, PARAMLIST, NEEDINFO, SERVICE, PRODUCT_LIST)
  VALUES(765, 'Novell-Open-Enterprise-Server-x86_64', '9', NULL, NULL, 'Novell Open Enterprise Server', '<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0" lang="">
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
</needinfo>', NULL, 'Y');
