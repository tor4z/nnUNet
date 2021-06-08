PYTHON                 := python
PIP                    := pip
MOD_BG                 := batchgenerators
MOD_BV                 := BatchViewer
ID_RSA                 := ~/.ssh/server.id_rsa
DIST_DIR               := dist

SERVER_USER            := cwj
DIST_TARGET_PATH       := /home/cwj/Experiments/nnUNet
MAKEFILE_SERVER_LOCAL  := Makefile.server
MAKEFILE_SERVER_REMOTE := Makefile

RTX1                   := 172.31.71.68
RTX2                   := 172.31.71.64
RTX3                   := 172.31.71.75
RTX4                   := 172.31.71.175

INIT_CMD               := "rm -rf $(DIST_TARGET_PATH)/dist && \
						   mkdir -p $(DIST_TARGET_PATH) && \
					 	   mkdir -p $(DIST_TARGET_PATH)/dist && \
					 	   mkdir -p $(DIST_TARGET_PATH)/experiments"


.PHONY: install clean build deploy


install_nn:
	$(PIP) install -e --upgrade .


install_mod_bg: $(MOD_BG)
	$(PIP) install -e --upgrade $^


install_mod_bv: $(MOD_BV)
	$(PIP) install -e --upgrade $^


install: install_nn install_mod_bv install_mod_bg


build_nn:
	$(PYTHON) -m build


build_mod_bg: $(MOD_BG)
	$(PYTHON) -m build $(MOD_BG)


build_mod_bv: $(MOD_BV)
	$(PYTHON) -m build $(MOD_BV)


collect_dist:
	cp $(MOD_BG)/dist/* $(DIST_DIR)
	cp $(MOD_BV)/dist/* $(DIST_DIR)


build: clean build_nn build_mod_bv build_mod_bg collect_dist


deploy_rtx1: build
	ssh -i $(ID_RSA) $(SERVER_USER)@$(RTX1) $(INIT_CMD)
	scp -i $(ID_RSA) -r $(DIST_DIR)/*.whl $(SERVER_USER)@$(RTX1):$(DIST_TARGET_PATH)/dist
	scp -i $(ID_RSA) -r $(MAKEFILE_SERVER_LOCAL) $(SERVER_USER)@$(RTX1):$(DIST_TARGET_PATH)/$(MAKEFILE_SERVER_REMOTE)


deploy_rtx2: build
	ssh -i $(ID_RSA) $(SERVER_USER)@$(RTX2) $(INIT_CMD)
	scp -i $(ID_RSA) -r $(DIST_DIR)/*.whl $(SERVER_USER)@$(RTX2):$(DIST_TARGET_PATH)/dist
	scp -i $(ID_RSA) -r $(MAKEFILE_SERVER_LOCAL) $(SERVER_USER)@$(RTX2):$(DIST_TARGET_PATH)/$(MAKEFILE_SERVER_REMOTE)


deploy_rtx3: build
	ssh -i $(ID_RSA) $(SERVER_USER)@$(RTX3) $(INIT_CMD)
	scp -i $(ID_RSA) -r $(DIST_DIR)/*.whl $(SERVER_USER)@$(RTX3):$(DIST_TARGET_PATH)/dist
	scp -i $(ID_RSA) -r $(MAKEFILE_SERVER_LOCAL) $(SERVER_USER)@$(RTX3):$(DIST_TARGET_PATH)/$(MAKEFILE_SERVER_REMOTE)


deploy_rtx4: build
	ssh -i $(ID_RSA) $(SERVER_USER)@$(RTX4) $(INIT_CMD)
	scp -i $(ID_RSA) -r $(DIST_DIR)/*.whl $(SERVER_USER)@$(RTX4):$(DIST_TARGET_PATH)/dist
	scp -i $(ID_RSA) -r $(MAKEFILE_SERVER_LOCAL) $(SERVER_USER)@$(RTX4):$(DIST_TARGET_PATH)/$(MAKEFILE_SERVER_REMOTE)


deploy: deploy_rtx1 deploy_rtx2 deploy_rtx3 deploy_rtx4


clean:
	-rm -rf dist ./**/dist ./**/build ./**/*.egg-info \
	dist build *.egg-info
