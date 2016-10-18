
@defcomp MarketDamages begin
    region = Index(region)
    y_year = Parameter(index=[time], unit="year")

    #incoming parameters from Climate
    rt_realizedtemperature = Parameter(index=[time, region], unit="degreeC")

    #tolerability parameters
    plateau_increaseintolerableplateaufromadaptationM = Parameter(index=[region], unit="degreeC")
    pstart_startdateofadaptpolicyM = Parameter(index=[region], unit="year")
    pyears_yearstilfulleffectM = Parameter(index=[region], unit="year")
    impred_eventualpercentreductionM = Parameter(index=[region], unit= "%")
    impmax_maxtempriseforadaptpolicyM = Parameter(index=[region], unit= "degreeC")
    istart_startdateM = Parameter(index=[region], unit = "year")
    iyears_yearstilfulleffectM = Parameter(index=[region], unit= "year")

    #tolerability variables
    atl_adjustedtolerableleveloftemprise = Variable(index=[time,region], unit="degreeC")
    imp_actualreduction = Variable(index=[time, region], unit= "%")
    i_regionalimpact = Variable(index=[time, region], unit="degreeC")

    #impact Parameters
    rcons_per_cap_SLRRemainConsumption = Parameter(index=[time, region], unit = "")
    rgdp_per_cap_SLRRemainGDP = Parameter(index=[time, region], unit = "")

    SAVE_savingsrate = Parameter(unit= "%")
    WINCF_weightsfactor =Parameter(index=[region], unit="")
    W_MarketImpactsatCalibrationTemp =Parameter()
    ipow_MarketImpactFxnExponent =Parameter()
    iben_MarketInitialBenefit=Parameter()
    tcal_CalibrationTemp = Parameter()
    GDP_per_cap_focus_0_FocusRegionEU = Parameter()
    isat_0_InitialImpactFxnSaturation= Parameter()

    #impact variables
    isatg_impactfxnsaturation = Variable()
    rcons_per_cap_MarketRemainConsumption = Variable(index=[time, region], unit = "")
    rgdp_per_cap_MarketRemainGDP = Variable(index=[time, region], unit = "")
    iref_ImpactatReferenceGDPperCap=Variable(index=[time, region])
    igdp_ImpactatActualGDPperCap=Variable(index=[time, region])
    isat_ImpactinclSaturationandAdaptation= Variable(index=[time,region])
    isat_per_cap_ImpactperCapinclSaturationandAdaptation = Variable(index=[time,region])
    pow_MarketImpactExponent=Variable()

end

function run_timestep(s::MarketDamages, t::Int64)
    v = s.Variables
    p = s.Parameters
    d = s.Dimensions

    for r in d.region
        #calculate tolerability
        if (p.y_year[t] - p.pstart_startdateofadaptpolicyM[r]) < 0
            v.atl_adjustedtolerableleveloftemprise[t,r]= 0
        elseif ((p.y_year[t]-p.pstart_startdateofadaptpolicyM[r])/p.pyears_yearstilfulleffectM[r])<1.
            v.atl_adjustedtolerableleveloftemprise[t,r]=
                ((p.y_year[t]-p.pstart_startdateofadaptpolicyM[r])/p.pyears_yearstilfulleffectM[r]) *
                p.plateau_increaseintolerableplateaufromadaptationM[r]
        else
            p.plateau_increaseintolerableplateaufromadaptationM[r]
        end

        if (p.y_year[t]- p.istart_startdateM[r]) < 0
            v.imp_actualreduction[t,r] = 0
        elseif ((p.y_year[t]-p.istart_startdateM[r])/p.iyears_yearstilfulleffectM[r]) < 1
            v.imp_actualreduction[t,r] =
                (p.y_year[t]-p.istart_startdateM[r])/p.iyears_yearstilfulleffectM[r]*
                p.impred_eventualpercentreductionM[r]
        else
            v.imp_actualreduction[t,r] = p.impred_eventualpercentreductionM[r]
        end

        if (p.rt_realizedtemperature[t,r]-v.atl_adjustedtolerableleveloftemprise[t,r]) < 0
            v.i_regionalimpact[t,r] = 0
        else
            v.i_regionalimpact[t,r] = p.rt_realizedtemperature[t,r]-v.atl_adjustedtolerableleveloftemprise[t,r]
        end

        v.iref_ImpactatReferenceGDPperCap[t,r]= p.WINCF_weightsfactor[r]*((p.W_MarketImpactsatCalibrationTemp + p.iben_MarketInitialBenefit * p.tcal_CalibrationTemp)*
            (v.i_regionalimpact[t,r]/p.tcal_CalibrationTemp)^p.pow_MarketImpactExponent - v.i_regionalimpact[t,r] * p.iben_MarketInitialBenefit)

        v.igdp_ImpactatActualGDPperCap[t,r]= v.iref_ImpactatReferenceGDPperCap[t,r]*
            (p.rgdp_per_cap_SLRRemainGDP[t,r]/p.GDP_per_cap_focus_0_FocusRegionEU)^p.ipow_MarketImpactFxnExponent

        v.isatg_impactfxnsaturation= p.isat_0_InitialImpactFxnSaturation * (1 - p.SAVE_savingsrate/100)

        if v.igdp_ImpactatActualGDPperCap[t,r] < v.isatg_impactfxnsaturation
            v.isat_ImpactinclSaturationandAdaptation[t,r] = v.igdp_ImpactatActualGDPperCap[t,r]
        elseif v.i_regionalimpact[t,r] < p.impmax_maxtempriseforadaptpolicyM[r]
            v.isat_ImpactinclSaturationandAdaptation[t,r] = v.isatg_impactfxnsaturation+
                ((100-p.SAVE_savingsrate)-v.isatg_impactfxnsaturation)*
                ((v.igdp_ImpactatActualGDPperCap[t,r]-v.isatg_impactfxnsaturation)/
                (((100-p.SAVE_savingsrate)-v.isatg_impactfxnsaturation)+
                (v.igdp_ImpactatActualGDPperCap[t,r]*
                v.isatg_impactfxnsaturation)))*(1-v.imp_actualreduction[t,r]/100)
        else
            v.isat_ImpactinclSaturationandAdaptation[t,r] = v.isatg_impactfxnsaturation+
                ((100-p.SAVE_savingsrate)-v.isatg_impactfxnsaturation) *
                ((v.igdp_ImpactatActualGDPperCap[t,r]-v.isatg_impactfxnsaturation)/
                (((100-p.SAVE_savingsrate)-v.isatg_impactfxnsaturation)+
                (v.igdp_ImpactatActualGDPperCap[t,r] * v.isatg_impactfxnsaturation))) *
                (1-(v.imp_actualreduction[t,r]/100)* p.impmax_maxtempriseforadaptpolicyM[r] /
                v.i_regionalimpact[t,r])
        end

        v.isat_per_cap_ImpactperCapinclSaturationandAdaptation[t,r] = (v.isat_ImpactinclSaturationandAdaptation[t,r]/100)*p.rgdp_per_cap_SLRRemainGDP[t,r]
        v.rcons_per_cap_MarketRemainConsumption[t,r] = p.rcons_per_cap_SLRRemainConsumption[t,r] - v.isat_per_cap_ImpactperCapinclSaturationandAdaptation[t,r]
        v.rgdp_per_cap_MarketRemainGDP[t,r] = v.rcons_per_cap_MarketRemainConsumption[t,r]/(1-p.SAVE_savingsrate/100)
    end

end

function addmarketdamages(model::Model)
    marketdamagescomp = addcomponent(model, MarketDamages)

    marketdamagescomp[:tcal_CalibrationTemp]= 3.
    marketdamagescomp[:isat_0_InitialImpactFxnSaturation]= .5
    marketdamagescomp[:W_MarketImpactsatCalibrationTemp] = .5
    marketdamagescomp[:iben_MarketInitialBenefit] = .13
    marketdamagescomp[:ipow_MarketImpactFxnExponent] = -.13
    marketdamagescomp[:SAVE_savingsrate]= 15.
    marketdamagescomp[:GDP_per_cap_focus_0_FocusRegionEU]= (1.39*10^7)/496
    marketdamagescomp[:pow_MarketImpactExponent]=2.17

    return marketdamagescomp
end