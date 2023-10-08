/*
Crypt class
	Currently Contains two classes and different methods for encryption and hashing
Classes:
	Crypt.Encrypt - Encryption class
	Crypt.Hash - Hashing class
=====================================================================
Methods:
=====================================================================
Crypt.Encrypt.FileEncrypt(pFileIn,pFileOut,password,CryptAlg = 1, HashAlg = 1)
	Encrypts the file
Parameters:
	pFileIn - path to file which to encrypt
	pFileOut - path to save encrypted file
	password - no way, it's just a password...
	(optional) CryptAlg - Encryption algorithm ID, for details see below
	(optional) HashAlg - hashing algorithm ID, for details see below
Return:
	on success, - Number of bytes writen to pFileOut
	on fail, - ""
--------
Crypt.Encrypt.FileDecrypt(pFileIn,pFileOut,password,CryptAlg = 1, HashAlg = 1)
	Decrypts the file, the parameters are identical to FileEncrypt,	except:
	pFileIn - path to encrypted file which to decrypt
	pFileOut - path to save decrypted file
=====================================================================
Crypt.Encrypt.StrEncrypt(string,password,CryptAlg = 1, HashAlg = 1)
	Encrypts the string
Parameters:
	string - UTF string, means any string you use in AHK_L Unicode
	password - no way, it's just a password...
	(optional) CryptAlg - Encryption algorithm ID, for details see below
	(optional) HashAlg - hashing algorithm ID, for details see below
Return:
	on success, - HASH representaion of encrypted buffer, which is easily transferable. 
				You can get actual encrypted buffer from HASH by using function HashToByte()
	on fail, - ""	
--------
Crypt.Encrypt.StrDecrypt(EncryptedHash,password,CryptAlg = 1, HashAlg = 1)
	Decrypts the string, the parameters are identical to StrEncrypt,	except:
	EncryptedHash - hash string returned by StrEncrypt()
=====================================================================
Crypt.Hash.FileHash(pFile,HashAlg = 1,pwd = "",hmac_alg = 1)
--------
	Gets the HASH of file
Parameters:
	pFile - path to file which hash will be calculated
	(optional) HashAlg - hashing algorithm ID, for details see below
	(optional) pwd - password, if present - the hashing algorith will use HMAC to calculate hash
	(optional) hmac_alg - Encryption algorithm ID of HMAC key, will be used if pwd parameter present
Return:
	on success, - HASH of target file calculated using choosen algorithm
	on fail, - ""
--------
Crypt.Hash.StrHash(string,HashAlg = 1,pwd = "",hmac_alg = 1)
	Gets the HASH of string. HASH will be calculated for ANSI representation of passed string
Parameters:
	string - UTF string
	other parameters same as for FileHash
=====================================================================
FileEncryptToStr(pFileIn,password,CryptAlg = 1, HashAlg = 1)
--------
	Encrypt file and returns it's hash
Parameters:
	pFileIn - path to file which will be encrypted
	password - no way, it's just a password...
	(optional) CryptAlg - Encryption algorithm ID, for details see below
	(optional) HashAlg - hashing algorithm ID, for details see below
Return:
	on success, - HASH of target file calculated using choosen algorithm
	on fail, - ""
=====================================================================
StrDecryptToFile(EncryptedHash,pFileOut,password,CryptAlg = 1, HashAlg = 1)
	Decrypt EncryptedHash to file and returns amount of bytes writen to file
Parameters:
	EncryptedHash - hash of formerly encrypted data
	pFileOut - path to destination file where decrypted data will be writen
	password - no way, it's just a password...
	(optional) CryptAlg - Encryption algorithm ID, for details see below
	(optional) HashAlg - hashing algorithm ID, for details see below
Return:
	on success, - amount of bytes writen to the destination file
	on fail, - ""
=====================================================================
Crypt.Encrypt class contain following fields
Crypt.Encrypt.StrEncoding - encoding of string passed to Crypt.Encrypt.StrEncrypt()
Crypt.Encrypt.PassEncoding - password encoding for each of Crypt.Encrypt methods

Same is valid for Crypt.Hash class

HASH and Encryption algorithms currently available:
HashAlg IDs:
1 - MD5
2 - MD2
3 - SHA
4 - SHA_256	;Vista+ only
5 - SHA_384	;Vista+ only
6 - SHA_512	;Vista+ only
--------
CryptAlg and hmac_alg IDs:
1 - RC4
2 - RC2
3 - 3DES
4 - 3DES_112
5 - AES_128 ;not supported for win 2000
6 - AES_192 ;not supported for win 2000
7 - AES_256 ;not supported for win 2000
=====================================================================

*/


Free(byRef var)
{
  VarSetCapacity(var,0)
  return
}
CryptConst(name)
{

ALG_CLASS_ANY := (0)
ALG_CLASS_SIGNATURE := (1 << 13)
ALG_CLASS_MSG_ENCRYPT := (2 << 13)
ALG_CLASS_DATA_ENCRYPT := (3 << 13)
ALG_CLASS_HASH := (4 << 13)
ALG_CLASS_KEY_EXCHANGE := (5 << 13)
ALG_CLASS_ALL := (7 << 13)
ALG_TYPE_ANY := (0)
ALG_TYPE_DSS := (1 << 9)
ALG_TYPE_RSA := (2 << 9)
ALG_TYPE_BLOCK := (3 << 9)
ALG_TYPE_STREAM := (4 << 9)
ALG_TYPE_DH := (5 << 9)
ALG_TYPE_SECURECHANNEL := (6 << 9)
ALG_SID_ANY := (0)
ALG_SID_RSA_ANY := 0
ALG_SID_RSA_PKCS := 1
ALG_SID_RSA_MSATWORK := 2
ALG_SID_RSA_ENTRUST := 3
ALG_SID_RSA_PGP := 4
ALG_SID_DSS_ANY := 0
ALG_SID_DSS_PKCS := 1
ALG_SID_DSS_DMS := 2
ALG_SID_ECDSA := 3
ALG_SID_DES := 1
ALG_SID_3DES := 3
ALG_SID_DESX := 4
ALG_SID_IDEA := 5
ALG_SID_CAST := 6
ALG_SID_SAFERSK64 := 7
ALG_SID_SAFERSK128 := 8
ALG_SID_3DES_112 := 9
ALG_SID_CYLINK_MEK := 12
ALG_SID_RC5 := 13
ALG_SID_AES_128 := 14
ALG_SID_AES_192 := 15
ALG_SID_AES_256 := 16
ALG_SID_AES := 17
ALG_SID_SKIPJACK := 10
ALG_SID_TEK := 11
CRYPT_MODE_CBCI := 6       ; ANSI CBC Interleaved
CRYPT_MODE_CFBP := 7       ; ANSI CFB Pipelined
CRYPT_MODE_OFBP := 8       ; ANSI OFB Pipelined
CRYPT_MODE_CBCOFM := 9       ; ANSI CBC + OF Masking
CRYPT_MODE_CBCOFMI := 10      ; ANSI CBC + OFM Interleaved
ALG_SID_RC2 := 2
ALG_SID_RC4 := 1
ALG_SID_SEAL := 2
ALG_SID_DH_SANDF := 1
ALG_SID_DH_EPHEM := 2
ALG_SID_AGREED_KEY_ANY := 3
ALG_SID_KEA := 4
ALG_SID_ECDH := 5
ALG_SID_MD2 := 1
ALG_SID_MD4 := 2
ALG_SID_MD5 := 3
ALG_SID_SHA := 4
ALG_SID_SHA1 := 4
ALG_SID_MAC := 5
ALG_SID_RIPEMD := 6
ALG_SID_RIPEMD160 := 7
ALG_SID_SSL3SHAMD5 := 8
ALG_SID_HMAC := 9
ALG_SID_TLS1PRF := 10
ALG_SID_HASH_REPLACE_OWF := 11
ALG_SID_SHA_256 := 12
ALG_SID_SHA_384 := 13
ALG_SID_SHA_512 := 14
ALG_SID_SSL3_MASTER := 1
ALG_SID_SCHANNEL_MASTER_HASH := 2
ALG_SID_SCHANNEL_MAC_KEY := 3
ALG_SID_PCT1_MASTER := 4
ALG_SID_SSL2_MASTER := 5
ALG_SID_TLS1_MASTER := 6
ALG_SID_SCHANNEL_ENC_KEY := 7
ALG_SID_ECMQV := 1
ALG_SID_EXAMPLE := 80
CALG_MD2 := (ALG_CLASS_HASH | ALG_TYPE_ANY | ALG_SID_MD2)
CALG_MD4 := (ALG_CLASS_HASH | ALG_TYPE_ANY | ALG_SID_MD4)
CALG_MD5 := (ALG_CLASS_HASH | ALG_TYPE_ANY | ALG_SID_MD5)
CALG_SHA := (ALG_CLASS_HASH | ALG_TYPE_ANY | ALG_SID_SHA)
CALG_SHA1 := (ALG_CLASS_HASH | ALG_TYPE_ANY | ALG_SID_SHA1)
CALG_MAC := (ALG_CLASS_HASH | ALG_TYPE_ANY | ALG_SID_MAC)
CALG_RSA_SIGN := (ALG_CLASS_SIGNATURE | ALG_TYPE_RSA | ALG_SID_RSA_ANY)
CALG_DSS_SIGN := (ALG_CLASS_SIGNATURE | ALG_TYPE_DSS | ALG_SID_DSS_ANY)
CALG_NO_SIGN := (ALG_CLASS_SIGNATURE | ALG_TYPE_ANY | ALG_SID_ANY)
CALG_RSA_KEYX := (ALG_CLASS_KEY_EXCHANGE|ALG_TYPE_RSA|ALG_SID_RSA_ANY)
CALG_DES := (ALG_CLASS_DATA_ENCRYPT|ALG_TYPE_BLOCK|ALG_SID_DES)
CALG_3DES_112 := (ALG_CLASS_DATA_ENCRYPT|ALG_TYPE_BLOCK|ALG_SID_3DES_112)
CALG_3DES := (ALG_CLASS_DATA_ENCRYPT|ALG_TYPE_BLOCK|ALG_SID_3DES)
CALG_DESX := (ALG_CLASS_DATA_ENCRYPT|ALG_TYPE_BLOCK|ALG_SID_DESX)
CALG_RC2 := (ALG_CLASS_DATA_ENCRYPT|ALG_TYPE_BLOCK|ALG_SID_RC2)
CALG_RC4 := (ALG_CLASS_DATA_ENCRYPT|ALG_TYPE_STREAM|ALG_SID_RC4)
CALG_SEAL := (ALG_CLASS_DATA_ENCRYPT|ALG_TYPE_STREAM|ALG_SID_SEAL)
CALG_DH_SF := (ALG_CLASS_KEY_EXCHANGE|ALG_TYPE_DH|ALG_SID_DH_SANDF)
CALG_DH_EPHEM := (ALG_CLASS_KEY_EXCHANGE|ALG_TYPE_DH|ALG_SID_DH_EPHEM)
CALG_AGREEDKEY_ANY := (ALG_CLASS_KEY_EXCHANGE|ALG_TYPE_DH|ALG_SID_AGREED_KEY_ANY)
CALG_KEA_KEYX := (ALG_CLASS_KEY_EXCHANGE|ALG_TYPE_DH|ALG_SID_KEA)
CALG_HUGHES_MD5 := (ALG_CLASS_KEY_EXCHANGE|ALG_TYPE_ANY|ALG_SID_MD5)
CALG_SKIPJACK := (ALG_CLASS_DATA_ENCRYPT|ALG_TYPE_BLOCK|ALG_SID_SKIPJACK)
CALG_TEK := (ALG_CLASS_DATA_ENCRYPT|ALG_TYPE_BLOCK|ALG_SID_TEK)
CALG_CYLINK_MEK := (ALG_CLASS_DATA_ENCRYPT|ALG_TYPE_BLOCK|ALG_SID_CYLINK_MEK)
CALG_SSL3_SHAMD5 := (ALG_CLASS_HASH | ALG_TYPE_ANY | ALG_SID_SSL3SHAMD5)
CALG_SSL3_MASTER := (ALG_CLASS_MSG_ENCRYPT|ALG_TYPE_SECURECHANNEL|ALG_SID_SSL3_MASTER)
CALG_SCHANNEL_MASTER_HASH := (ALG_CLASS_MSG_ENCRYPT|ALG_TYPE_SECURECHANNEL|ALG_SID_SCHANNEL_MASTER_HASH)
CALG_SCHANNEL_MAC_KEY := (ALG_CLASS_MSG_ENCRYPT|ALG_TYPE_SECURECHANNEL|ALG_SID_SCHANNEL_MAC_KEY)
CALG_SCHANNEL_ENC_KEY := (ALG_CLASS_MSG_ENCRYPT|ALG_TYPE_SECURECHANNEL|ALG_SID_SCHANNEL_ENC_KEY)
CALG_PCT1_MASTER := (ALG_CLASS_MSG_ENCRYPT|ALG_TYPE_SECURECHANNEL|ALG_SID_PCT1_MASTER)
CALG_SSL2_MASTER := (ALG_CLASS_MSG_ENCRYPT|ALG_TYPE_SECURECHANNEL|ALG_SID_SSL2_MASTER)
CALG_TLS1_MASTER := (ALG_CLASS_MSG_ENCRYPT|ALG_TYPE_SECURECHANNEL|ALG_SID_TLS1_MASTER)
CALG_RC5 := (ALG_CLASS_DATA_ENCRYPT|ALG_TYPE_BLOCK|ALG_SID_RC5)
CALG_HMAC := (ALG_CLASS_HASH | ALG_TYPE_ANY | ALG_SID_HMAC)
CALG_TLS1PRF := (ALG_CLASS_HASH | ALG_TYPE_ANY | ALG_SID_TLS1PRF)
CALG_HASH_REPLACE_OWF := (ALG_CLASS_HASH | ALG_TYPE_ANY | ALG_SID_HASH_REPLACE_OWF)
CALG_AES_128 := (ALG_CLASS_DATA_ENCRYPT|ALG_TYPE_BLOCK|ALG_SID_AES_128)
CALG_AES_192 := (ALG_CLASS_DATA_ENCRYPT|ALG_TYPE_BLOCK|ALG_SID_AES_192)
CALG_AES_256 := (ALG_CLASS_DATA_ENCRYPT|ALG_TYPE_BLOCK|ALG_SID_AES_256)
CALG_AES := (ALG_CLASS_DATA_ENCRYPT|ALG_TYPE_BLOCK|ALG_SID_AES)
CALG_SHA_256 := (ALG_CLASS_HASH | ALG_TYPE_ANY | ALG_SID_SHA_256)
CALG_SHA_384 := (ALG_CLASS_HASH | ALG_TYPE_ANY | ALG_SID_SHA_384)
CALG_SHA_512 := (ALG_CLASS_HASH | ALG_TYPE_ANY | ALG_SID_SHA_512)
CALG_ECDH := (ALG_CLASS_KEY_EXCHANGE | ALG_TYPE_DH | ALG_SID_ECDH)
CALG_ECMQV := (ALG_CLASS_KEY_EXCHANGE | ALG_TYPE_ANY | ALG_SID_ECMQV)
CALG_ECDSA := (ALG_CLASS_SIGNATURE | ALG_TYPE_DSS | ALG_SID_ECDSA)
CRYPT_VERIFYCONTEXT := 0xF0000000
CRYPT_NEWKEYSET := 0x00000008
CRYPT_DELETEKEYSET := 0x00000010
CRYPT_MACHINE_KEYSET := 0x00000020
CRYPT_SILENT := 0x00000040
CRYPT_DEFAULT_CONTAINER_OPTIONAL := 0x00000080
CRYPT_EXPORTABLE := 0x00000001
CRYPT_USER_PROTECTED := 0x00000002
CRYPT_CREATE_SALT := 0x00000004
CRYPT_UPDATE_KEY := 0x00000008
CRYPT_NO_SALT := 0x00000010
CRYPT_PREGEN := 0x00000040
CRYPT_RECIPIENT := 0x00000010
CRYPT_INITIATOR := 0x00000040
CRYPT_ONLINE := 0x00000080
CRYPT_SF := 0x00000100
CRYPT_CREATE_IV := 0x00000200
CRYPT_KEK := 0x00000400
CRYPT_DATA_KEY := 0x00000800
CRYPT_VOLATILE := 0x00001000
CRYPT_SGCKEY := 0x00002000
CRYPT_ARCHIVABLE := 0x00004000
CRYPT_FORCE_KEY_PROTECTION_HIGH := 0x00008000
RSA1024BIT_KEY := 0x04000000
CRYPT_SERVER := 0x00000400
KEY_LENGTH_MASK := 0xFFFF0000
CRYPT_Y_ONLY := 0x00000001
CRYPT_SSL2_FALLBACK := 0x00000002
CRYPT_DESTROYKEY := 0x00000004
CRYPT_OAEP := 0x00000040  ; used with RSA encryptions/decryptions
CRYPT_BLOB_VER3 := 0x00000080  ; export version 3 of a blob type
CRYPT_IPSEC_HMAC_KEY := 0x00000100  ; CryptImportKey only
CRYPT_DECRYPT_RSA_NO_PADDING_CHECK := 0x00000020
CRYPT_SECRETDIGEST := 0x00000001
CRYPT_OWF_REPL_LM_HASH := 0x00000001  ; this is only for the OWF replacement CSP
CRYPT_LITTLE_ENDIAN := 0x00000001
CRYPT_NOHASHOID := 0x00000001
CRYPT_TYPE2_FORMAT := 0x00000002
CRYPT_X931_FORMAT := 0x00000004
CRYPT_MACHINE_DEFAULT := 0x00000001
CRYPT_USER_DEFAULT := 0x00000002
CRYPT_DELETE_DEFAULT := 0x00000004
SIMPLEBLOB := 0x1
PUBLICKEYBLOB := 0x6
PRIVATEKEYBLOB := 0x7
PLAINTEXTKEYBLOB := 0x8
OPAQUEKEYBLOB := 0x9
PUBLICKEYBLOBEX := 0xA
SYMMETRICWRAPKEYBLOB := 0xB
KEYSTATEBLOB := 0xC
AT_KEYEXCHANGE := 1
AT_SIGNATURE := 2
CRYPT_USERDATA := 1
KP_IV := 1       ; Initialization vector
KP_SALT := 2       ; Salt value
KP_PADDING := 3       ; Padding values
KP_MODE := 4       ; Mode of the cipher
KP_MODE_BITS := 5       ; Number of bits to feedback
KP_PERMISSIONS := 6       ; Key permissions DWORD
KP_ALGID := 7       ; Key algorithm
KP_BLOCKLEN := 8       ; Block size of the cipher
KP_KEYLEN := 9       ; Length of key in bits
KP_SALT_EX := 10      ; Length of salt in bytes
KP_P := 11      ; DSS/Diffie-Hellman P value
KP_G := 12      ; DSS/Diffie-Hellman G value
KP_Q := 13      ; DSS Q value
KP_X := 14      ; Diffie-Hellman X value
KP_Y := 15      ; Y value
KP_RA := 16      ; Fortezza RA value
KP_RB := 17      ; Fortezza RB value
KP_INFO := 18      ; for putting information into an RSA envelope
KP_EFFECTIVE_KEYLEN := 19      ; setting and getting RC2 effective key length
KP_SCHANNEL_ALG := 20      ; for setting the Secure Channel algorithms
KP_CLIENT_RANDOM := 21      ; for setting the Secure Channel client random data
KP_SERVER_RANDOM := 22      ; for setting the Secure Channel server random data
KP_RP := 23
KP_PRECOMP_MD5 := 24
KP_PRECOMP_SHA := 25
KP_CERTIFICATE := 26      ; for setting Secure Channel certificate data (PCT1)
KP_CLEAR_KEY := 27      ; for setting Secure Channel clear key data (PCT1)
KP_PUB_EX_LEN := 28
KP_PUB_EX_VAL := 29
KP_KEYVAL := 30
KP_ADMIN_PIN := 31
KP_KEYEXCHANGE_PIN := 32
KP_SIGNATURE_PIN := 33
KP_PREHASH := 34
KP_ROUNDS := 35
KP_OAEP_PARAMS := 36      ; for setting OAEP params on RSA keys
KP_CMS_KEY_INFO := 37
KP_CMS_DH_KEY_INFO := 38
KP_PUB_PARAMS := 39      ; for setting public parameters
KP_VERIFY_PARAMS := 40      ; for verifying DSA and DH parameters
KP_HIGHEST_VERSION := 41      ; for TLS protocol version setting
KP_GET_USE_COUNT := 42      ; for use with PP_CRYPT_COUNT_KEY_USE contexts
KP_PIN_ID := 43
KP_PIN_INFO := 44
HP_ALGID := 0x0001  ; Hash algorithm
HP_HASHVAL := 0x0002  ; Hash value
HP_HASHSIZE := 0x0004  ; Hash value size
HP_HMAC_INFO := 0x0005  ; information for creating an HMAC
HP_TLS1PRF_LABEL := 0x0006  ; label for TLS1 PRF
HP_TLS1PRF_SEED := 0x0007  ; seed for TLS1 PRF
PROV_RSA_FULL := 1
PROV_RSA_SIG := 2
PROV_DSS := 3
PROV_FORTEZZA := 4
PROV_MS_EXCHANGE := 5
PROV_SSL := 6
PROV_RSA_SCHANNEL := 12
PROV_DSS_DH := 13
PROV_EC_ECDSA_SIG := 14
PROV_EC_ECNRA_SIG := 15
PROV_EC_ECDSA_FULL := 16
PROV_EC_ECNRA_FULL := 17
PROV_DH_SCHANNEL := 18
PROV_SPYRUS_LYNKS := 20
PROV_RNG := 21
PROV_INTEL_SEC := 22
PROV_REPLACE_OWF := 23
PROV_RSA_AES := 24
PROV_STT_MER := 7
PROV_STT_ACQ := 8
PROV_STT_BRND := 9
PROV_STT_ROOT := 10
PROV_STT_ISS := 11
StringReplace,name,name,`n,`,,1				;replacing new lines with comma
	IfInString, name,,
	{
		arr := {}
		StringSplit,const,name,`,,%A_TAB%%A_SPACE%`n
		loop,%const0%
		{
			v := const%A_Index%
			if !v
				continue
			arr[v] := %v%
		}
		return arr
	}
	else
	{
		p := %name%
		if (p = "")
			p = err
		return p
	}
}

class Crypt
{
	class Encrypt
	{
		static StrEncoding := "UTF-16"
		static PassEncoding := "UTF-16"
		
		StrDecryptToFile(EncryptedHash,pFileOut,password,CryptAlg = 1, HashAlg = 1) 
		{
			if !EncryptedHash
				return ""
			if !len := HashToByte(EncryptedHash,encr_Buf)
				return ""
			temp_file := "crypt.temp"
			f := FileOpen(temp_file,"w","CP0")
			if !IsObject(f)
				return ""
			if !f.RawWrite(encr_Buf,len)
				return ""
			f.close()
			bytes := this._Encrypt( p, pp, password, 0, temp_file, pFileOut, CryptAlg, HashAlg )
			FileDelete,% temp_file
			return bytes
		}
		
		FileEncryptToStr(pFileIn,password,CryptAlg = 1, HashAlg = 1) 
		{
			temp_file := "crypt.temp"
			if !this._Encrypt( p, pp, password, 1, pFileIn, temp_file, CryptAlg, HashAlg )
				return ""
			f := FileOpen(temp_file,"r","CP0")
			if !IsObject(f)
			{
				FileDelete,% temp_file
				return ""
			}
			fLen := f.Length
			VarSetCapacity(tembBuf,fLen,0)
			if !f.RawRead(tembBuf,fLen)
			{
				Free(tembBuf)
				return ""
			}
			f.Close()
			FileDelete,% temp_file
			return ByteToHash(tembBuf,fLen)
		}
		
		FileEncrypt(pFileIn,pFileOut,password,CryptAlg = 1, HashAlg = 1)
		{
			return this._Encrypt( p, pp, password, 1, pFileIn, pFileOut, CryptAlg, HashAlg )
		}

		FileDecrypt(pFileIn,pFileOut,password,CryptAlg = 1, HashAlg = 1)
		{
			return this._Encrypt( p, pp, password, 0, pFileIn, pFileOut, CryptAlg, HashAlg )
		}

		StrEncrypt(string,password,CryptAlg = 1, HashAlg = 1)
		{
			len := StrPutVar(string, str_buf,100,this.StrEncoding)
			if this._Encrypt(str_buf,len, password, 1,0,0,CryptAlg,HashAlg)
				return ByteToHash(str_buf,len)
			else
				return ""
		}
	
		StrDecrypt(EncryptedHash,password,CryptAlg = 1, HashAlg = 1)
		{
			if !EncryptedHash
				return ""
			if !len := HashToByte(EncryptedHash,encr_Buf)
				return 0
			if this._Encrypt(encr_Buf,len, password, 0,0,0,CryptAlg,HashAlg)
				return strget(&encr_Buf,this.StrEncoding)
			else
				return ""
		}		
	
		_Encrypt(ByRef encr_Buf,ByRef Buf_Len, password, mode, pFileIn=0, pFileOut=0, CryptAlg = 1,HashAlg = 1)	;mode - 1 encrypt, 0 - decrypt
		{
			c = 																	;constants list
			(
			CALG_MD5,CALG_MD2,CALG_SHA,CALG_SHA_256,CALG_SHA_384,CALG_SHA_512
			CALG_RC4,CALG_RC2,CALG_3DES,CALG_3DES_112,CALG_AES_128,CALG_AES_192,CALG_AES_256
			PROV_RSA_AES,CRYPT_VERIFYCONTEXT,KP_BLOCKLEN
			)
			c := CryptConst(c)													;getting an array of constants
			;password hashing algorithms
			CUR_PWD_HASH_ALG := HashAlg==1?c.CALG_MD5
								:HashAlg==2?c.CALG_MD2
								:HashAlg==3?c.CALG_SHA
								:HashAlg==4?c.CALG_SHA_256	;Vista+ only
								:HashAlg==5?c.CALG_SHA_384	;Vista+ only
								:HashAlg==6?c.CALG_SHA_512	;Vista+ only
								:0
			;encryption algorithms
			CUR_ENC_ALG 	:= CryptAlg==1?c.CALG_RC4
								:CryptAlg==2?c.CALG_RC2
								:CryptAlg==3?c.CALG_3DES
								:CryptAlg==4?c.CALG_3DES_112
								:CryptAlg==5?c.CALG_AES_128 ;not supported for win 2000
								:CryptAlg==6?c.CALG_AES_192	;not supported for win 2000
								:CryptAlg==7?c.CALG_AES_256	;not supported for win 2000
								:0
			KEY_LENGHT 		:= CryptAlg==1?0x80
								:CryptAlg==2?0x80
								:CryptAlg==3?0xC0
								:CryptAlg==4?0x80
								:CryptAlg==5?0x80
								:CryptAlg==6?0xC0
								:CryptAlg==7?0x100
								:0
			KEY_LENGHT <<= 16
			if (CUR_PWD_HASH_ALG = 0 || CUR_ENC_ALG = 0)
				return 0
			
			if !dllCall("Advapi32\CryptAcquireContextW","Ptr*",hCryptProv,"Uint",0,"Uint",0,"Uint",c.PROV_RSA_AES,"UInt",c.CRYPT_VERIFYCONTEXT)
					{foo := "CryptAcquireContextW", err := GetLastError(), err2 := ErrorLevel
					GoTO FINITA_LA_COMEDIA
					}	
			if !dllCall("Advapi32\CryptCreateHash","Ptr",hCryptProv,"Uint",CUR_PWD_HASH_ALG,"Uint",0,"Uint",0,"Ptr*",hHash )
					{foo := "CryptCreateHash", err := GetLastError(), err2 := ErrorLevel
					GoTO FINITA_LA_COMEDIA
					}
			;hashing password
			passLen := StrPutVar(password, passBuf,0,this.PassEncoding) - (this.PassEncoding = "UTF-16" ? 2 : 1)
			if !dllCall("Advapi32\CryptHashData","Ptr",hHash,"Ptr",&passBuf,"Uint",passLen,"Uint",0 )
					{foo := "CryptHashData", err := GetLastError(), err2 := ErrorLevel
					GoTO FINITA_LA_COMEDIA
					}	
			;getting encryption key from password
			if !dllCall("Advapi32\CryptDeriveKey","Ptr",hCryptProv,"Uint",CUR_ENC_ALG,"Ptr",hHash,"Uint",KEY_LENGHT,"Ptr*",hKey )
					{foo := "CryptDeriveKey", err := GetLastError(), err2 := ErrorLevel
					GoTO FINITA_LA_COMEDIA
					}
			;~ SetKeySalt(hKey,hCryptProv)
			if !dllCall("Advapi32\CryptGetKeyParam","Ptr",hKey,"Uint",c.KP_BLOCKLEN,"Uint*",BlockLen,"Uint*",dwCount := 4,"Uint",0)
					{foo := "CryptGetKeyParam", err := GetLastError(), err2 := ErrorLevel
					GoTO FINITA_LA_COMEDIA
					}	
			BlockLen /= 8
			if (mode == 1)							;Encrypting
			{
				if (pFileIn && pFileOut)			;encrypting file
				{
					ReadBufSize := 10240 - mod(10240,BlockLen==0?1:BlockLen )	;10KB
					pfin := FileOpen(pFileIn,"r","CP0")
					pfout := FileOpen(pFileOut,"w","CP0")
					if !IsObject(pfin)
						{foo := "File Opening " . pFileIn
						GoTO FINITA_LA_COMEDIA
						}
					if !IsObject(pfout)
						{foo := "File Opening " . pFileOut
						GoTO FINITA_LA_COMEDIA
						}
					VarSetCapacity(ReadBuf,ReadBufSize+BlockLen,0)
					isFinal := 0
					hModule := DllCall("LoadLibrary", "Str", "Advapi32.dll","UPtr")
					CryptEnc := DllCall("GetProcAddress", "Ptr", hModule, "AStr", "CryptEncrypt","UPtr")
					while !pfin.AtEOF
					{
						BytesRead := pfin.RawRead(ReadBuf, ReadBufSize)
						if pfin.AtEOF
							isFinal := 1
						if !dllCall(CryptEnc
								,"Ptr",hKey	;key
								,"Ptr",0	;hash
								,"Uint",isFinal	;final
								,"Uint",0	;dwFlags
								,"Ptr",&ReadBuf	;pbdata
								,"Uint*",BytesRead	;dwsize
								,"Uint",ReadBufSize+BlockLen )	;dwbuf		
						{foo := "CryptEncrypt", err := GetLastError(), err2 := ErrorLevel
						GoTO FINITA_LA_COMEDIA
						}	
						pfout.RawWrite(ReadBuf,BytesRead)
						Buf_Len += BytesRead
					}
					DllCall("FreeLibrary", "Ptr", hModule)
					pfin.Close()
					pfout.Close()
				}
				else
				{
					if !dllCall("Advapi32\CryptEncrypt"
								,"Ptr",hKey	;key
								,"Ptr",0	;hash
								,"Uint",1	;final
								,"Uint",0	;dwFlags
								,"Ptr",&encr_Buf	;pbdata
								,"Uint*",Buf_Len	;dwsize
								,"Uint",Buf_Len + BlockLen )	;dwbuf		
					{foo := "CryptEncrypt", err := GetLastError(), err2 := ErrorLevel
					GoTO FINITA_LA_COMEDIA
					}	
				}
			}
			else if (mode == 0)								;decrypting
			{	
				if (pFileIn && pFileOut)					;decrypting file
				{
					ReadBufSize := 10240 - mod(10240,BlockLen==0?1:BlockLen )	;10KB
					pfin := FileOpen(pFileIn,"r","CP0")
					pfout := FileOpen(pFileOut,"w","CP0")
					if !IsObject(pfin)
						{foo := "File Opening " . pFileIn
						GoTO FINITA_LA_COMEDIA
						}
					if !IsObject(pfout)
						{foo := "File Opening " . pFileOut
						GoTO FINITA_LA_COMEDIA
						}
					VarSetCapacity(ReadBuf,ReadBufSize+BlockLen,0)
					isFinal := 0
					hModule := DllCall("LoadLibrary", "Str", "Advapi32.dll","UPtr")
					CryptDec := DllCall("GetProcAddress", "Ptr", hModule, "AStr", "CryptDecrypt","UPtr")
					while !pfin.AtEOF
					{
						BytesRead := pfin.RawRead(ReadBuf, ReadBufSize)
						if pfin.AtEOF
							isFinal := 1
						if !dllCall(CryptDec
								,"Ptr",hKey	;key
								,"Ptr",0	;hash
								,"Uint",isFinal	;final
								,"Uint",0	;dwFlags
								,"Ptr",&ReadBuf	;pbdata
								,"Uint*",BytesRead )	;dwsize
						{foo := "CryptDecrypt", err := GetLastError(), err2 := ErrorLevel
						GoTO FINITA_LA_COMEDIA
						}	
						pfout.RawWrite(ReadBuf,BytesRead)
						Buf_Len += BytesRead
					}
					DllCall("FreeLibrary", "Ptr", hModule)
					pfin.Close()
					pfout.Close()
					
				}
				else if !dllCall("Advapi32\CryptDecrypt"
								,"Ptr",hKey	;key
								,"Ptr",0	;hash
								,"Uint",1	;final
								,"Uint",0	;dwFlags
								,"Ptr",&encr_Buf	;pbdata
								,"Uint*",Buf_Len )	;dwsize
					{foo := "CryptDecrypt", err := GetLastError(), err2 := ErrorLevel
					GoTO FINITA_LA_COMEDIA
					}	
			}
FINITA_LA_COMEDIA:
			dllCall("Advapi32\CryptDestroyKey","Ptr",hKey )
			dllCall("Advapi32\CryptDestroyHash","Ptr",hHash)
			dllCall("Advapi32\CryptReleaseContext","Ptr",hCryptProv,"UInt",0)
			if (A_ThisLabel = "FINITA_LA_COMEDIA")
			{
				if (A_IsCompiled = 1)
					return ""
				else
					msgbox % foo " call failed with:`nErrorLevel: " err2 "`nLastError: " err "`n" ErrorFormat(err) 
				return ""
			}
			return Buf_Len
		}
	}
	
	class Hash
	{
		static StrEncoding := "CP0"
		static PassEncoding := "UTF-16"
		
		FileHash(pFile,HashAlg = 1,pwd = "",hmac_alg = 1)
		{
			return this._CalcHash(p,pp,pFile,HashAlg,pwd,hmac_alg)
		}
		
		StrHash(string,HashAlg = 1,pwd = "",hmac_alg = 1)		;strType 1 for ASC, 0 for UTF
		{
			buf_len := StrPutVar(string, buf,0,this.StrEncoding)
			return this._CalcHash(buf,buf_len,0,HashAlg,pwd,hmac_alg)
		}
		
		_CalcHash(ByRef bBuffer,BufferLen,pFile,HashAlg = 1,pwd = "",hmac_alg = 1)
		{
			c = 																	;constants list
			(
			CALG_MD5,CALG_MD2,CALG_SHA,CALG_SHA_256,CALG_SHA_384,CALG_SHA_512
			CALG_RC4,CALG_RC2,CALG_3DES,CALG_3DES_112,CALG_AES_128,CALG_AES_192,CALG_AES_256
			PROV_RSA_AES,CRYPT_VERIFYCONTEXT,HP_HASHVAL,HP_HASHSIZE,CALG_HMAC,HP_HMAC_INFO
			)
			c := CryptConst(c)													;getting an array of constants
			;password hashing algorithms
			HASH_ALG := HashAlg==1?c.CALG_MD5
						:HashAlg==2?c.CALG_MD2
						:HashAlg==3?c.CALG_SHA
						:HashAlg==4?c.CALG_SHA_256	;Vista+ only
						:HashAlg==5?c.CALG_SHA_384	;Vista+ only
						:HashAlg==6?c.CALG_SHA_512	;Vista+ only
						:0
			;encryption algorithms
			HMAC_KEY_ALG 	:= hmac_alg==1?c.CALG_RC4
								:hmac_alg==2?c.CALG_RC2
								:hmac_alg==3?c.CALG_3DES
								:hmac_alg==4?c.CALG_3DES_112
								:hmac_alg==5?c.CALG_AES_128 ;not supported for win 2000
								:hmac_alg==6?c.CALG_AES_192	;not supported for win 2000
								:hmac_alg==7?c.CALG_AES_256	;not supported for win 2000
								:0
			KEY_LENGHT 		:= hmac_alg==1?0x80
								:hmac_alg==2?0x80
								:hmac_alg==3?0xC0
								:hmac_alg==4?0x80
								:hmac_alg==5?0x80
								:hmac_alg==6?0xC0
								:hmac_alg==7?0x100
								:0
			KEY_LENGHT <<= 16
			if (!HASH_ALG || !HMAC_KEY_ALG)
				return 0
			if !dllCall("Advapi32\CryptAcquireContextW","Ptr*",hCryptProv,"Uint",0,"Uint",0,"Uint",c.PROV_RSA_AES,"UInt",c.CRYPT_VERIFYCONTEXT )
				{foo := "CryptAcquireContextW", err := GetLastError(), err2 := ErrorLevel
				GoTO FINITA_DA_COMEDIA
				}	
			if !dllCall("Advapi32\CryptCreateHash","Ptr",hCryptProv,"Uint",HASH_ALG,"Uint",0,"Uint",0,"Ptr*",hHash )
				{foo := "CryptCreateHash1", err := GetLastError(), err2 := ErrorLevel
				GoTO FINITA_DA_COMEDIA
				}
			
			if (pwd != "")			;going HMAC
			{
				passLen := StrPutVar(pwd, passBuf,0,this.PassEncoding) - (this.PassEncoding = "UTF-16" ? 2 : 1)
				if !dllCall("Advapi32\CryptHashData","Ptr",hHash,"Ptr",&passBuf,"Uint",passLen,"Uint",0 )
					{foo := "CryptHashData Pwd", err := GetLastError(), err2 := ErrorLevel
					GoTO FINITA_DA_COMEDIA
					}
				;getting encryption key from password
				if !dllCall("Advapi32\CryptDeriveKey","Ptr",hCryptProv,"Uint",HMAC_KEY_ALG,"Ptr",hHash,"Uint",KEY_LENGHT,"Ptr*",hKey )
					{foo := "CryptDeriveKey Pwd", err := GetLastError(), err2 := ErrorLevel
					GoTO FINITA_DA_COMEDIA
					}
				dllCall("Advapi32\CryptDestroyHash","Ptr",hHash)
				if !dllCall("Advapi32\CryptCreateHash","Ptr",hCryptProv,"Uint",c.CALG_HMAC,"Ptr",hKey,"Uint",0,"Ptr*",hHash )
					{foo := "CryptCreateHash2", err := GetLastError(), err2 := ErrorLevel
					GoTO FINITA_DA_COMEDIA
					}
				VarSetCapacity(HmacInfoStruct,4*A_PtrSize + 4,0)
				NumPut(HASH_ALG,HmacInfoStruct,0,"UInt")
				if !dllCall("Advapi32\CryptSetHashParam","Ptr",hHash,"Uint",c.HP_HMAC_INFO,"Ptr",&HmacInfoStruct,"Uint",0)
					{foo := "CryptSetHashParam", err := GetLastError(), err2 := ErrorLevel
					GoTO FINITA_DA_COMEDIA
					}
			}
				
			if pFile
			{
				f := FileOpen(pFile,"r","CP0")
				BUFF_SIZE := 1024 * 1024 ; 1 MB
				if !IsObject(f)
					{foo := "File Opening"
					GoTO FINITA_DA_COMEDIA
					}
				if !hModule := DllCall( "GetModuleHandleW", "str", "Advapi32.dll", "UPtr" )
					hModule := DllCall( "LoadLibraryW", "str", "Advapi32.dll", "UPtr" )
				hCryptHashData := DllCall("GetProcAddress", "Ptr", hModule, "AStr", "CryptHashData", "UPtr")
				VarSetCapacity(read_buf,BUFF_SIZE,0)
				While (cbCount := f.RawRead(read_buf, BUFF_SIZE))
				{
					if (cbCount = 0)
						break
					if !dllCall(hCryptHashData
								,"Ptr",hHash
								,"Ptr",&read_buf
								,"Uint",cbCount
								,"Uint",0 )
						{foo := "CryptHashData", err := GetLastError(), err2 := ErrorLevel
						GoTO FINITA_DA_COMEDIA
						}
				}
				f.Close()
			}
			else
			{
				if !dllCall("Advapi32\CryptHashData"
							,"Ptr",hHash
							,"Ptr",&bBuffer
							,"Uint",BufferLen
							,"Uint",0 )
					{foo := "CryptHashData", err := GetLastError(), err2 := ErrorLevel
					GoTO FINITA_DA_COMEDIA
					}
			}
			if !dllCall("Advapi32\CryptGetHashParam","Ptr",hHash,"Uint",c.HP_HASHSIZE,"Uint*",HashLen,"Uint*",HashLenSize := 4,"UInt",0 )
				{foo := "CryptGetHashParam HP_HASHSIZE", err := GetLastError(), err2 := ErrorLevel
				GoTO FINITA_DA_COMEDIA
				}
			VarSetCapacity(pbHash,HashLen,0)
			if !dllCall("Advapi32\CryptGetHashParam","Ptr",hHash,"Uint",c.HP_HASHVAL,"Ptr",&pbHash,"Uint*",HashLen,"UInt",0 )
				{foo := "CryptGetHashParam HP_HASHVAL", err := GetLastError(), err2 := ErrorLevel
				GoTO FINITA_DA_COMEDIA
				}
			hashval := ByteToHash(pbHash,HashLen)
				
		FINITA_DA_COMEDIA:
			DllCall("FreeLibrary", "Ptr", hModule)
			dllCall("Advapi32\CryptDestroyHash","Ptr",hHash)
			dllCall("Advapi32\CryptDestroyKey","Ptr",hKey )
			dllCall("Advapi32\CryptReleaseContext","Ptr",hCryptProv,"UInt",0)
			if (A_ThisLabel = "FINITA_LA_COMEDIA")
			{
				if (A_IsCompiled = 1)
					return ""
				else
					msgbox % foo " call failed with:`nErrorLevel: " err2 "`nLastError: " err "`n" ErrorFormat(err) 
				return 0
			}
			return hashval
		}
	}
}

/*
ByteToHash()
Converts bytes from memory into transferable HASH
Parameters:
pbData - variable of raw address from which hash will be read
dwLen  - amount of bytes of 
return:
hash string
*/
ByteToHash(ByRef pbData,dwLen)
{
	if (dwLen < 1)
		return 0
	if pbData is integer
		ptr := pbData
	else
		ptr := &pbData
	SetFormat,integer,Hex
	loop,%dwLen%
	{
		num := numget(ptr+0,A_index-1,"UChar")
		hash .= substr((num >> 4),0) . substr((num & 0xf),0)
	}
	SetFormat,integer,D
	return hash
}

/*
HashToByte()
Puts hash from string into memory
Parameters:
sHash - hash string
ByteBuf - variable where bytes will be writen
return:
amount of bytes writen
*/
HashToByte(sHash,ByRef ByteBuf)
{
	if (sHash == "" || RegExMatch(sHash,"[^\dABCDEF]") || mod(StrLen(sHash),2))
		return 0
	BufLen := StrLen(sHash)/2
	VarSetCapacity(ByteBuf,BufLen,0)
	loop,%BufLen%
	{
		num1 := (p := "0x" . SubStr(sHash,(A_Index-1)*2+1,1)) << 4
		num2 := "0x" . SubStr(sHash,(A_Index-1)*2+2,1)
		num := num1 | num2
		NumPut(num,ByteBuf,A_Index-1,"UChar")
	}
	return BufLen
}

;returns positive hex value of last error
GetLastError()
{
	return DecToHex(A_LastError < 0 ? A_LastError & 0xFFFFFFFF : A_LastError)
}

;converting decimal to hex value
DecToHex(num)
{
	if num is not integer
		return num
	Loop
	{
		hn := ChHex(mod(num,16))
		hex_val := hn . hex_val
		if !(num := num//16)
		{
			hex_val := "0x" . hex_val
			break
		}
	}
	return hex_val
}

ChHex(numb)
{
	return numb==10?"A"
			:numb==11?"B"
			:numb==12?"C"
			:numb==13?"D"
			:numb==14?"E"
			:numb==15?"F"
			:numb
}

;And this function returns error description based on error number passed. ;
;Error number is one returned by GetLastError() or from A_LastError
ErrorFormat(error_id)
{
	VarSetCapacity(msg,1000,0)
	if !len := DllCall("FormatMessageW"
				,"UInt",FORMAT_MESSAGE_FROM_SYSTEM := 0x00001000 | FORMAT_MESSAGE_IGNORE_INSERTS := 0x00000200		;dwflags
				,"Ptr",0		;lpSource
				,"UInt",error_id	;dwMessageId
				,"UInt",0			;dwLanguageId
				,"Ptr",&msg			;lpBuffer
				,"UInt",500)			;nSize
		return
	return 	strget(&msg,len)
}

StrPutVar(string, ByRef var, addBufLen = 0,encoding="UTF-16")
{
	; Ensure capacity.
	; StrPut returns char count, but VarSetCapacity needs bytes.
	str_len := StrPut(string, encoding) * ((encoding="utf-16"||encoding="cp1200") ? 2 : 1)
    VarSetCapacity( var, str_len + addBufLen,0 )
    ; Copy or convert the string.
	StrPut(string, &var, encoding)
    return str_len
}

SetKeySalt(hKey,hProv)
{
	KP_SALT_EX := 10
	SALT := "89ABF9C1005EDD40"
	len := HashToByte(SALT,pb)
	VarSetCapacity(st,2*A_PtrSize,0)
	NumPut(len,st,0,"UInt")
	NumPut(&pb,st,A_PtrSize,"UPtr")
	if !dllCall("Advapi32\CryptSetKeyParam"
				,"Ptr",hKey
				,"Uint",KP_SALT_EX
				,"Ptr",&st
				,"Uint",0)
		msgbox % ErrorFormat(GetLastError())
}

GetKeySalt(hKey)
{
	KP_IV := 1       ; Initialization vector
	KP_SALT := 2       ; Salt value
	if !dllCall("Advapi32\CryptGetKeyParam"
				,"Ptr",hKey
				,"Uint",KP_SALT
				,"Uint",0
				,"Uint*",dwCount
				,"Uint",0)
	msgbox % "Fail to get SALT length."
	msgbox % "SALT length.`n" dwCount
	VarSetCapacity(pb,dwCount,0)
	if !dllCall("Advapi32\CryptGetKeyParam"
				,"Ptr",hKey
				,"Uint",KP_SALT
				,"Ptr",&pb
				,"Uint*",dwCount
				,"Uint",0)
	msgbox % "Fail to get SALT"	
	msgbox % ByteToHash(pb,dwCount) "`n" dwCount
}
