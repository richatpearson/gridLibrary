//
//  GridClientManager.swift
//  GridClientManager
//
//  Created by Joe Miller on 11/6/14.
//  Copyright (c) 2014 Pearson. All rights reserved.
//

import Foundation

class GridClientManager {
    
    // Singleton
    class var sharedInstance: GridClientManager {
        struct Static {
            static var instance: GridClientManager?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = GridClientManager()
        }
        
        return Static.instance!
    }
    
    let clients: [PGMEnvironmentType: PGMClient]
    var currentEnvironment: String?
    var currentClient: PGMClient?
    var consentPolicies: Array<PGMConsentPolicy>!
    var loginView: ViewController!
    var escrowTicket: String!
    
    init() {
        clients = [PGMEnvironmentType.StagingEnv: PGMClient(environmentType:PGMEnvironmentType.StagingEnv, andOptions:GridClientManager.getStagingAuthOptions()),
            PGMEnvironmentType.ProductionEnv: PGMClient(environmentType:PGMEnvironmentType.ProductionEnv, andOptions:GridClientManager.getProductionAuthOptions()),
            PGMEnvironmentType.SimulatedEnv: PGMClient(environmentType:PGMEnvironmentType.SimulatedEnv, andOptions:GridClientManager.getStagingAuthOptions())]
    }
    
    class func getStagingAuthOptions() -> PGMAuthOptions {
        let clientId = "wkLZmUJAsTSMbVEI9Po6hNwgJJBGsgi5"
        let clientSecret = "SAftAexlgpeSTZ7n"
        let redirectUrl = "http://int-piapi.stg-openclass.com/pi_group12client"
        return PGMAuthOptions(clientId: clientId, andClientSecret: clientSecret, andRedirectUrl: redirectUrl)
    }
    
    class func getProductionAuthOptions() -> PGMAuthOptions {
        let clientId = "GgXYn6HjbT2CzKXm5jh9aIGC7htBNWk1"
        let clientSecret = "pKAsAPi4DAEPesbw"
        let redirectUrl = "http://piapi.openclass.com/pi_group12client"
        return PGMAuthOptions(clientId: clientId, andClientSecret: clientSecret, andRedirectUrl: redirectUrl)
    }
    
    func clientFor(environment: PGMEnvironmentType) -> PGMClient? {
        currentClient = clients[environment]
        if (currentClient != nil) {
            switch environment {
            case PGMEnvironmentType.StagingEnv:
                currentEnvironment = "Staging"
            case PGMEnvironmentType.ProductionEnv:
                currentEnvironment = "Production"
            case PGMEnvironmentType.SimulatedEnv:
                currentEnvironment = "Simulated"
            default:
                currentEnvironment = ""
            }
        }
        return currentClient
    }
    
}
