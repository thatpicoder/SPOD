//
//  APODResponse.swift
//  SPOD
//
//  Created by dylan on 5/24/26.
//

import Foundation

struct APODResponse: Codable {
    let title: String
    let explanation: String
    let url: String
    let hdurl: String?
    let date: String
    let media_type: String
}
