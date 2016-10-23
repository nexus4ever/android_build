#
# Copyright (C) 2011 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Restrict the vendor module owners here.
_vendor_owner_whitelist := \
        asus \
        audience \
        broadcom \
        csr \
        elan \
        google \
        imgtec \
        invensense \
        lge \
        nvidia \
        nxp \
        qcom \
        samsung \
        samsung_arm \
        ti \
        trusted_logic \
        widevine \
	uber

ifneq (,$(PRODUCTS.$(INTERNAL_PRODUCT).PRODUCT_RESTRICT_VENDOR_FILES))

_vendor_check_modules := $(sort $(PRODUCTS.$(INTERNAL_PRODUCT).PRODUCT_PACKAGES))
$(call expand-required-modules,_vendor_check_modules,$(_vendor_check_modules))

# Expand the target modules installed via LOCAL_SHARED_LIBRARIES
# $(1): the list of modules to expand.
define expand-required-shared-libraries
$(eval _ersl_new_modules := $(filter $(addsuffix :%,$(1)),$(TARGET_DEPENDENCIES_ON_SHARED_LIBRARIES)))\
$(eval _ersl_new_modules := $(foreach p,$(_ersl_new_modules),$(word 3,$(subst :,$(space),$(p)))))\
$(eval _ersl_new_modules := $(sort $(subst $(comma),$(space),$(_ersl_new_modules))))\
$(eval _ersl_new_modules := $(filter-out $(_vendor_check_modules),$(_ersl_new_modules)))\
$(if $(_ersl_new_modules),$(eval _vendor_check_modules += $(_ersl_new_modules))\
  $(call expand-required-shared-libraries,$(_ersl_new_modules)))
endef
$(call expand-required-shared-libraries,$(_vendor_check_modules))

_vendor_module_owner_info :=

_vendor_module_owner_info_txt := $(call intermediates-dir-for,PACKAGING,vendor_owner_info)/vendor_owner_info.txt
$(_vendor_module_owner_info_txt): PRIVATE_INFO := $(_vendor_module_owner_info)
$(_vendor_module_owner_info_txt):
	@echo "Write vendor module owner info $@"
	$(hide) mkdir -p $(dir $@) && rm -f $@
ifdef _vendor_module_owner_info
	@for w in $(PRIVATE_INFO); \
	  do \
	    echo $$w >> $@; \
	done
else
	@echo "No vendor module owner info." > $@
endif

$(call dist-for-goals, droidcore, $(_vendor_module_owner_info_txt))

_vendor_module_owner_info_txt :=
_vendor_module_owner_info :=
_vendor_check_modules :=
endif
