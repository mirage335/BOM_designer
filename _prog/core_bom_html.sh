# WARNING: No known production use. Untested.
_bom_html() {
	
	# Force HTML production.
	export BOM_designer_enable_html='true'
	
	"$scriptAbsoluteLocation" _bom_html_sequence "$@"
	
}
