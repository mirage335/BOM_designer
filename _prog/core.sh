##### Core


_BOM_designer_geometry_sequence() {
	_start
	
	[[ "$ub_specimen" != "" ]] && cd "$ub_specimen"
	[[ "$1" != "" ]] && cd "$1"
	
	# Leveled Bill-Of-Materials
	
	# Find. Update.
	find . \( -iname '*.lbom.csv' -o -iname '*.lbom.txt' -o -iname '*.lbom' \) -not -path '*/w_*/*' -not \( -iname 'overrides.lbom.csv' -o -iname 'overrides.lbom.txt' -o -iname 'overrides.lbom' \) -exec "$scriptAbsoluteLocation" _bom_update '{}' \;
	
	# Concatenate.
	echo -n > "$safeTmp"/concatenated.csv
	find . \( -iname '*.lbom.csv' -o -iname '*.lbom.txt' -o -iname '*.lbom' \) -not -path '*/w_*/*' -not \( -iname 'overrides.lbom.csv' -o -iname 'overrides.lbom.txt' -o -iname 'overrides.lbom' \) -exec cat '{}' \; >> "$safeTmp"/concatenated.csv
	echo -n > "$safeTmp"/overrides_concatenated.csv
	find . \( -iname 'overrides.lbom.csv' -o -iname 'overrides.lbom.txt' -o -iname 'overrides.lbom' \) -exec cat '{}' \; >> "$safeTmp"/overrides_concatenated.csv
	
	# Update (optional, redundant, precautionary).
	_bom_update "$safeTmp"/concatenated.csv
	
	# Consolidate.
	echo -n > "$safeTmp"/consolidated.csv
	_bom_consolidate "$safeTmp"/concatenated.csv "$safeTmp"/consolidated.csv "$safeTmp"/overrides_concatenated.csv
	
	# Simplify.
	echo -n > "$safeTmp"/simplified.csv
	_bom_simplify "$safeTmp"/consolidated.csv "$safeTmp"/simplified.csv
	
	# Sort. Label.
	sort "$safeTmp"/simplified.csv > "$safeTmp"/simplified_sorted.csv
	echo '#item,dstpn,mult,qty,dst,mark,provider,path' > "$safeTmp"/simplified_consolidated.csv
	sort "$safeTmp"/consolidated.csv >> "$safeTmp"/simplified_consolidated.csv
	
	rm -f ./_bom.csv > /dev/null 2>&1
	rm -f ./_consolidated_bom.csv > /dev/null 2>&1
	
	cp "$safeTmp"/simplified_sorted.csv ./_bom.csv
	cp "$safeTmp"/simplified_consolidated.csv ./_consolidated_bom.csv
	
	_stop
}



_BOM_designer_geometry() {
	"$scriptAbsoluteLocation" _BOM_designer_geometry_sequence "$@"
}



_scope_prog() {
	[[ "$ub_scope_name" == "" ]] && export ub_scope_name='bom'
}


#_scope_var_here_prog() {
#	true
#	cat << CZXWXcRMTo8EmM8i4d

#Global Variables and Defaults
#Sketch (Scope Current, SEssion)
#export se_sketch="$se_sketch"
#export se_sketchDir="$se_sketchDir"
#export se_out="$se_out"

#export se_basename="$se_basename"

#Debug
#export se_remotePort="$se_remotePort"
#export se_sym="$se_sym"

#CZXWXcRMTo8EmM8i4d
#}

_scope_attach_prog() {
	_messagePlain_nominal '_scope_attach: prog'
	
	#if ! _set_bom_var "$@"
	#then
	#	_messagePlain_bad 'fail: _set_bom_var'
	#	_stop 1
	#fi
	
	_messagePlain_probe_var ub_specimen
	
	#_set_bom_userShortHome
	#_set_bom_editShortHome
	#_set_bom_fakeHome
	
	_messagePlain_nominal '_scope_attach: prog: deploy'
	
	#_scope_command_write _true
	_scope_command_write _BOM_designer_geometry
}





# # ATTENTION: Add to ops!
_refresh_anchors_task() {
	true
}

_refresh_anchors_specific() {
	true
	
	_refresh_anchors_specific_single_procedure _BOM_designer_geometry
}

_refresh_anchors_user() {
	true
	_refresh_anchors_user_single_procedure _BOM_designer_geometry
}

_associate_anchors_request() {
	if type "_refresh_anchors_user" > /dev/null 2>&1
	then
		_tryExec "_refresh_anchors_user"
		#return
	fi
	
	
	#_messagePlain_request 'association: dir, *.pcb'
	_messagePlain_request 'association: dir'
	echo _BOM_designer_geometry"$ub_anchor_suffix"
}


#duplicate _anchor
_refresh_anchors() {
	
	cp -a "$scriptAbsoluteFolder"/_anchor "$scriptAbsoluteFolder"/_scope
	
	cp -a "$scriptAbsoluteFolder"/_anchor "$scriptAbsoluteFolder"/_BOM_designer_geometry
	
	_tryExec "_refresh_anchors_task"
	
	return 0
}


