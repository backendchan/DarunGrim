/* File : DiffEngine.i */
%module DiffEngine
%include typemaps.i

%{
#include <windows.h>
#include "DataStructure.h"
#include "Configuration.h"
#include "DiffMachine.h"
#include "IDAController.h"
#include "DarunGrim.h"
%}
%inline %{
	unsigned long GetDWORD(unsigned long *a,int index) {
		return a[index];
	}
%}

class DBWrapper
{
public:
	DBWrapper( char *DatabaseName = NULL );
};

class IDAController
{
public:
	IDAController(DBWrapper *StorageDB=NULL);
	AnalysisInfo *GetClientAnalysisInfo();
	FileInfo *GetClientFileInfo();
	void DumpAnalysisInfo();
	void DumpBlockInfo(unsigned long block_address);
	void RemoveFromFingerprintHash(unsigned long address);
	unsigned long GetBlockAddress(unsigned long address);
	unsigned long *GetMappedAddresses(unsigned long address,int type,int *OUTPUT);
	char *GetDisasmLines(unsigned long start_addr,unsigned long end_addr);
	void FreeDisasmLines();
	void JumpToAddress(unsigned long address);
};

class DiffMachine
{
public:
	DiffMachine( IDAController *the_source=NULL, IDAController *the_target=NULL );
	void ShowDiffMap(unsigned long unpatched_address,unsigned long patched_address);
	void PrintMatchMapInfo();
	bool Analyze();
	void AnalyzeFunctionSanity();
	unsigned long GetMatchAddr(int index,unsigned long address);
	int GetUnidentifiedBlockCount(int index);
	CodeBlock GetUnidentifiedBlock(int index,int i);
	
	BOOL Load( DBWrapper* InputDB);
	BOOL Save( DBWrapper& OutputDB, hash_set <DWORD> *pTheSourceSelectedAddresses=NULL, hash_set <DWORD> *pTheTargetSelectedAddresses=NULL );
};

class DarunGrim
{
public:
	void SetLogParameters( int ParamLogOutputType, int ParamDebugLevel, const char *LogFile = NULL );
	void SetIDAPath( const char *path, bool is_64 );
	bool AcceptIDAClientsFromSocket( const char *storage_filename = NULL );
	bool PerformDiff(char *src_storage_filename, unsigned long source_address, char *target_storage_filename, unsigned long target_address, char *output_storage_filename);
	bool PerformDiff();

	void AddSrcDumpAddress(unsigned long address);
	void AddTargetDumpAddress(unsigned long address);
	void EnableLogType(int type);
	
	void SetSourceFilename( char *source_filename );
	void SetTargetFilename( char *target_filename );	
	
	bool Load( const char *storage_filename );
	void JumpToAddresses( unsigned long source_address, unsigned long target_address );
	void ColorAddress( int index, unsigned long start_address, unsigned long end_address, unsigned long color );

	void SetDatabase( DBWrapper *OutputDB );
	unsigned short StartIDAListenerThread(unsigned short port);
	bool StartIDAListener( unsigned short port );
	bool SetSourceController(const char *identity);
	bool SetTargetController(const char *identity);

	void SetLogFilename(char *LogFilename);
	void GenerateSourceDGFFromIDA(char *output_filename, char *log_filename, bool is_64);
	void GenerateTargetDGFFromIDA(char *output_filename, char *log_filename, bool is_64);
	void GenerateDGFFromIDA(const char *ida_filename, unsigned long StartAddress, unsigned long EndAddress, char *output_filename, char *log_filename, bool is_64);
	void ConnectToDarunGrim(char *ida_filename);
	const char *GetIDALogFilename();
	void SetAutoMode(bool mode);
};
