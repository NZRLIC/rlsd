#' Extract model fits and load into lsdOutput object class for plotting
#' 
#' @param dir the directory to extract from
#' @param data extract a dat file
#' @param mcmc extract one or more MCMC files
#' @param variational extract a var file
#' @param model a name or label for the model being extracted
#' @import rstan
#' @import methods
#' @importFrom plyr adply
#' @importFrom utils write.csv write.table
#' @export
#'
do_extract_ref <- function(dir = ".", data = TRUE,
                       mcmc = FALSE, variational = FALSE,
                       model = "ref_lsd")
{

    # pars we want for diagnostics
    do_extract_items <- c("proj_catch_commercial_jryt", 
                          "proj_catch_recreational_jryt",
                          "proj_catch_sl_jryt", 
                          "proj_catch_nsl_jryt",
                          "pred_catch_sl_jryt", 
                          "pred_catch_nsl_jryt",
                          "resid_catch_sl_jryt", 
                          "resid_catch_nsl_jryt",
                          "recruits_ry", 
                          "mp_offset_cpue_jry",
                          "biomass_vuln_jytrs", 
                          "biomass_vulnref_jytr",
                          "biomass_vulnref_AW_jyr", 
                          "B0_r", 
                          "biomass_ssb_jyr",
                          "SSB0_r", 
                          "MSY_r",
                          "Bmsy_r")  

    # initialise object
    dS4 <- new("lsdOutput", model.name = model)
    
    if (data) {
        datfile <- list.files(pattern = "[.]dat")[grepl(model, list.files(pattern = "[.]dat"))]
        if (length(datfile) > 0) {
            message("Reading ", datfile)
            dS4@data <- rstan::read_rdump(datfile)
            dS4@regions <- as.character(1:dS4@data$n_area)
        } else warning("no 'dat' file")
    }

    if (mcmc) {
        if (file.exists("mpe.csv")){
            mcmcfiles <- "mpe.csv"
        } else {
            mcmcfiles <- list.files(pattern = "[.]mcmc")[grepl(model, list.files(pattern = "[.]mcmc"))]
        }
        if (length(mcmcfiles) > 0) {
            message("Reading ", mcmcfiles)
            
            # create stanfit object from mcmc outputs
            #mcmc_raw_stan <- rstan::read_stan_csv(mcmcfiles)
            mcmc_raw <- read_stan_mcmc(mcmcfiles)
            
            # create list object containing all model outputs
            dS4@mcmc <- lsd::extract(mcmc_raw, pars = do_extract_items, permuted = TRUE, include = TRUE)
            
          
        } else warning("no 'mcmc' files")
    }
    
    return(dS4)
}