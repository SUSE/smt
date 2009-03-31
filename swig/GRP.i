%module "Sys::GRP"

%{
#include <grp.h>
%}

extern int initgroups (const char *user, unsigned int group);

