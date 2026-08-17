/*
 * civiclight-gate.c — CivicNet (CIVIC) mining algorithm for cpuminer-opt
 *
 * Pipeline: SHA256d(header) -> SHA256 -> civic_yespower(N=2048,r=8) -> XOR -> SHA256
 * Uses namespaced civic_yespower (from NitroPool/CivicNet daemon source)
 * to guarantee hash compatibility with the chain.
 *
 * Blackshirt Crypto — blkshirtpool.com
 */

#include "algo-gate-api.h"
#include "algo/sha/sha256-hash.h"
#include "algo/civiclight/yespower/yespower.h"

static void sha256d_local( void *output, const void *input, size_t len )
{
   uint8_t h[32];
   sha256_full( h, input, len );
   sha256_full( output, h, 32 );
}

static void civiclight_core_v2( void *output, const void *input, size_t len )
{
   uint8_t hash1[32];
   uint8_t xor_buf[32];
   sha256_full( hash1, input, len );

   civic_yespower_local_t local;
   civic_yespower_init_local( &local );

   civic_yespower_params_t params;
   params.version = YESPOWER_1_0;
   params.N = 2048;
   params.r = 8;
   params.pers = NULL;
   params.perslen = 0;

   civic_yespower_binary_t yp_out;
   civic_yespower( &local, hash1, 32, &params, &yp_out );

   for ( int i = 0; i < 32; i++ )
      xor_buf[i] = yp_out.uc[i] ^ hash1[i];

   sha256_full( output, xor_buf, 32 );
   civic_yespower_free_local( &local );
}

static void civiclight_powhash( void *output, const void *header80 )
{
   uint8_t intermediate[32];
   sha256d_local( intermediate, header80, 80 );
   civiclight_core_v2( output, intermediate, 32 );
}

int civiclight_hash( const char *input, char *output, int thrid )
{
   civiclight_powhash( output, input );
   return 1;
}

int scanhash_civiclight( struct work *work, uint32_t max_nonce,
                          uint64_t *hashes_done, struct thr_info *mythr )
{
   uint32_t _ALIGN(64) edata[20];
   uint32_t _ALIGN(64) hash[8];
   uint32_t *pdata = work->data;
   uint32_t *ptarget = work->target;
   const uint32_t first_nonce = pdata[19];
   const uint32_t last_nonce = max_nonce - 1;
   uint32_t n = first_nonce;
   const int thr_id = mythr->id;
   const bool bench = opt_benchmark;

   for ( int k = 0; k < 20; k++ )
      be32enc( &edata[k], pdata[k] );

   do
   {
      edata[19] = n;
      civiclight_powhash( hash, edata );
      if ( unlikely( valid_hash( hash, ptarget ) && !bench ) )
      {
         pdata[19] = bswap_32( n );
         submit_solution( work, hash, mythr );
      }
      n++;
   } while ( n < last_nonce && !work_restart[thr_id].restart );

   *hashes_done = n - first_nonce;
   pdata[19] = n;
   return 0;
}

bool register_civiclight_algo( algo_gate_t* gate )
{
   gate->optimizations = SSE2_OPT | AVX2_OPT | AVX512_OPT | NEON_OPT;
   gate->scanhash      = (void*)&scanhash_civiclight;
   gate->hash          = (void*)&civiclight_hash;

   applog( LOG_NOTICE, "Civiclight: SHA256d -> SHA256 -> civic_yespower(N=2048,r=8) -> XOR -> SHA256" );
   return true;
}
