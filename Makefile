#
# Eltrun web site creation and data validation
#
# (C) Copyright 2005 Diomidis Spinellis
#
# $Id$
#

MEMBERFILES=$(wildcard data/members/*.xml)
GROUPFILES=$(wildcard data/groups/*.xml)
PROJECTFILES=$(wildcard data/projects/*.xml)
# Database containing all the above
DB=build/db.xml
# XSLT file for public data
PXSLT=schema/eltrun-public.xslt
# XSLT file for fetching the ids
IDXSLT=schema/eltrun-ids.xslt
# Today' date in ISO format
TODAY=$(shell date +'%Y%m%d')
# Fetch the ids
GROUPIDS=$(shell xml tr ${IDXSLT} -s category=group ${DB})
PROJECTIDS=$(shell xml tr ${IDXSLT} -s category=project ${DB})
MEMBERIDS=$(shell xml tr ${IDXSLT} -s category=member ${DB})
# HTML output directory
HTML=public_html

all: html

$(DB): ${MEMBERFILES} ${GROUPFILES} ${PROJECTFILES}
	echo '<eltrun>' >$@
	echo '<group_list>' >>$@
	cat ${GROUPFILES} >>$@
	echo '</group_list>' >>$@
	echo '<member_list>' >>$@
	cat ${MEMBERFILES} >>$@
	echo '</member_list>' >>$@
	echo '<project_list>' >>$@
	cat ${PROJECTFILES} >>$@
	echo '</project_list>' >>$@
	echo '</eltrun>' >>$@

clean:
	rm -f build/*
	rm -f ${HTML}/groups/*
	rm -f ${HTML}/images/*
	rm -f ${HTML}/projects/*
	rm -f ${HTML}/publications/*

val: ${DB}
	xml val -d schema/eltrun.dtd $(DB)

html: ${DB}
	# For all groups and the empty group
	for group in $(GROUPIDS) '' ; \
	do \
		xml tr ${PXSLT} -s today=${TODAY} -s ogroup=$$group -s what=completed-projects ${DB} >${HTML}/groups/$$group-completed-projects.html ; \
		xml tr ${PXSLT} -s today=${TODAY} -s ogroup=$$group -s what=current-projects ${DB} >${HTML}/groups/$$group-current-projects.html ; \
	done
	for project in $(PROJECTIDS) ; \
	do \
		xml tr ${PXSLT} -s oproject=$$project -s what=project-details ${DB} >${HTML}/projects/$$project.html ; \
	done
