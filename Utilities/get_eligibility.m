function eligible_struct = get_eligibility(flatflag,moderateflag,steepflag,rentedflag,ownerflag,nosoilconsflag,soilconsflag,coffeeflag,hortflag,riceflag,agroforestryflag,miniedu,riskflag,socialflag,minimumdistance)
% ========================================================================
% ** IndoMod function **
% This function packages the eligibility of plots and households into
% vectors for the contract coffee scenario. 
% The output is a structure eligible_struct where eligible_struct.plots =
% vector of binary 'switches' for eligible plots based on tenure, current
% lu, soil conservation, min plot size, and slope.
% and eligible_struct.hh = vector of binary 'switches' for min eduation of
% hh head, hh-head and spouse, risk taking of hh-head, and membership for
% social groups. 
% ========================================================================

% Parameterise the vector. Note we will make section determined in the User
% interface later and parsed into this function. 
% Note that this does not include the min area defined by the buyer. 
flat = flatflag;
moderate = moderateflag;
steep = steepflag;
rented = rentedflag;
owned = ownerflag;
no_cons_prac = nosoilconsflag;
cons_prac = soilconsflag;
coffee = coffeeflag;
hort = hortflag;
rice = riceflag;
agroforestry = agroforestryflag;
plots = table(flat, moderate, steep, rented, owned, no_cons_prac, cons_prac, coffee, hort, rice, agroforestry);
eligible_struct.plots = plots;

%Min household head education
edu_head = miniedu;
%Min education of household spouse or head
edu_min = miniedu;
%Risk taking flag - 1 implies only those with positive risk taking
%behaviour participate. 
risk_takin = riskflag;
%Social member flag - 1 implies only those a member of social network
%participate. 
soc_memb_a = socialflag;
%Min dsitance to market  - in metres
dist_market_mtr = minimumdistance;

hh = table(edu_head, edu_min, risk_takin, soc_memb_a, dist_market_mtr);
eligible_struct.hh = hh;



