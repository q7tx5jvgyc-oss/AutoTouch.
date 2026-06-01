export THEOS = /home/runner/theos
ARCHS = arm64
TARGET = iphone:clang:14.0:14.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = MoustacheMod
MoustacheMod_FILES = main.mm
MoustacheMod_FRAMEWORKS = UIKit Foundation

include $(THEOS_MAKE_PATH)/tweak.mk
