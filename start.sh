#!/bin/sh

bin/gh_issues_contributors eval "Sysaud.Release.migrate" && \
bin/gh_issues_contributors eval "Sysaud.Release.seed" && \
bin/gh_issues_contributors start