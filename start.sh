#!/bin/sh

bin/gh_issues_contributors eval "GhIssuesContributors.Release.migrate" && \
bin/gh_issues_contributors eval "GhIssuesContributors.Release.seed" && \
bin/gh_issues_contributors start