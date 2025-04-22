# Global.gd
extends Node

# Example of a global function
func load_admob():
	MobileAds.initialize()
	var request_configuration := RequestConfiguration.new()
	request_configuration.tag_for_child_directed_treatment = RequestConfiguration.TagForChildDirectedTreatment.TRUE
		# Optionally handle users under the age of consent in the EEA (GDPR compliance)
	request_configuration.tag_for_under_age_of_consent = RequestConfiguration.TagForUnderAgeOfConsent.UNSPECIFIED
	# Set the maximum ad content rating to G for child-safe ads
	request_configuration.max_ad_content_rating = RequestConfiguration.MAX_AD_CONTENT_RATING_G
	MobileAds.set_request_configuration(request_configuration)
	print_debug("mobile ads")
	print("mobileads.initialize in global.gd")

# Initialization function
func _ready():
	load_admob()
