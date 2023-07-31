//
//  ISO6392Service.swift
//  mooApp
//
//  Created by duy on 3/8/16.
//  Copyright © 2016 moosocialloft. All rights reserved.
//

import Foundation

open class ISO6392Service : NSObject {
    // Mark : Propeties
    var map: [String:String] = [
        "ab" : "abk",
        "aa" : "aar",
        "af" : "afr",
        "ak" : "aka",
        "sq" : "alb",
        "am" : "amh",
        "ar" : "ara",
        "an" : "arg",
        "hy" : "arm",
        "as" : "asm",
        "av" : "ava",
        "ae" : "ave",
        "ay" : "aym",
        "az" : "aze",
        "bm" : "bam",
        "ba" : "bak",
        "eu" : "baq",
        "be" : "bel",
        "bn" : "ben",
        "bh" : "bih",
        "bi" : "bis",
        "nb" : "nob",
        "bs" : "bos",
        "br" : "bre",
        "bg" : "bul",
        "my" : "bur",
        "km" : "khm",
        "ch" : "cha",
        "ce" : "che",
        "zh" : "chi",
        "za" : "zha",
        "cu" : "chu",
        "cv" : "chv",
        "kw" : "cor",
        "co" : "cos",
        "cr" : "cre",
        "hr" : "hrv",
        "cs" : "cze",
        "da" : "dan",
        "dv" : "div",
        "nl" : "dut",
        "dz" : "dzo",
        "en" : "eng",
        "eo" : "epo",
        "et" : "est",
        "ee" : "ewe",
        "fo" : "fao",
        "fj" : "fij",
        "fi" : "fin",
        "fr" : "fre", // or fra
        "ff" : "ful",
        "gd" : "gla",
        "gl" : "glg",
        "lg" : "lug",
        "ka" : "geo", // or kat
        "de" : "ger",  // or deu
        "ki" : "kik",
        "el" : "gre",  // or  ell
        "kl" : "kal",
        "gn" : "grn",
        "gu" : "guj",
        "ht" : "hat",
        "ha" : "hau",
        "he" : "heb",
        "hz" : "her",
        "hi" : "hin",
        "ho" : "hmo",
        "hu" : "hun",
        "is" : "ice", // or isl
        "io" : "ido",
        "ig" : "ibo",
        "id" : "ind",
        "ia" : "ina",
        "ie" : "ile",
        "iu" : "iku",
        "ik" : "ipk",
        "ga" : "gle",
        "it" : "ita",
        "ja" : "jpn",
        "jv" : "jav",
        "kn" : "kan",
        "kr" : "kau",
        "ks" : "kas",
        "kk" : "kaz",
        "rw" : "kin",
        "ky"  : "kir",
        "kv"  : "kom",
        "kg"  : "kon",
        "ko"  : "kor",
        "kj"  : "kua",
        "ku"  : "kur",
        "lo"  : "lao",
        "la"  : "lat",
        "lv"  : "lav",
        "lb"  : "ltz",
        "li"  : "lim",
        "ln"  : "lin",
        "lt"  : "lit",
        "lu"  : "lub",
        "mk"  : "mac", // or mkd
        "mg"  : "mlg",
        "ms"  : "may", // ot msa
        "ml"  : "mal",
        "mt"  : "mlt",
        "gv"  : "glv",
        "mi"  : "mao", // or mri
        "mr"  : "mar",
        "mh"  : "mah",
        "ro"  : "rum", // or ron
        "mn"  : "mon",
        "na"  : "nau",
        "nv"  : "nav",
        "nd"  : "nde",
        "nr"  : "nbl",
        "ng"  : "ndo",
        "ne"  : "nep",
        "se"  : "sme",
        "no"  : "nor",
        "nn"  : "nno",
        "ii"  : "iii",
        "ny"  : "nya",
        "oc"  : "oci",
        "oj"  : "oji",

        "or"  : "ori",
        "om"  : "orm",
        "os"  : "oss",
        "pi"  : "pli",
        "pa"  : "pan",
        "ps"  : "pus",
        "fa"  : "per", // or fas
        "pl"  : "pol",
        "pt"  : "por",
        "qu"  : "que",
        "rm"   : "roh",
        "rn"   : "run",
        "ru"   : "rus",
        "sm"   : "smo",
        "sg"   : "sag",
        "sa"   : "san",
        "sc"   : "srd",
        "sr"   : "srp",
        "sn"   : "sna",
        "sd"   : "snd",
        "si"   : "sin",
        "sk"   : "slo", // or slk
        "sl"   : "slv",
        "so"   : "som",
        "st"   : "sot",
        "es"   : "spa",
        "su"   : "sun",
        "sw"   : "swa",
        "ss"   : "ssw",
        "sv"   : "swe",
        "tl"   : "tgl",
        "ty"   : "tah",
        "tg"   : "tgk",
        "ta"   : "tam",
        "tt"   : "tat",
        "te"   : "tel",
        "th"   : "tha",
        "bo"   : "tib", // or bod
        "ti"   : "tir",
        "to"   : "ton",
        "ts"   : "tso",
        "tn"   : "tsn",
        "tr"   : "tur",
        "tk"   : "tuk",
        "tw"   : "twi",
        "ug"   : "uig",
        "uk"   : "ukr",
        "ur"   : "urd",
        "uz"   : "uzb",
        "ca"   : "cat",
        "ve"   : "ven",
        "vi"   : "vie",
        "vo"   : "vol",
        "wa"   : "wln",
        "cy"   : "wel", // or cym
        "fy"   : "fry",
        "wo"   : "wol",
        "xh"   : "xho",
        "yi"   : "yid",
        "yo"   : "yor",
        "zu"   : "zul"
    ]
    
    // Mark: Singleton
    class var sharedInstance : ISO6392Service {
        struct Singleton {
            static let instance = ISO6392Service()
        }
        // Return singleton instance
        return Singleton.instance
    }

    func convert(_ code:String)->String{
        if code.characters.count == 2
        {
            return map[code]!
        }

        return "en"
        
    }
}
