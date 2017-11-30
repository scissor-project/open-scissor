#include<CompositionManager.hpp>
#include<PoolManager.hpp>
#include<TimerThread.hpp>
#include <limits.h>
#include <signal.h>
#include <unistd.h>

#include <fstream>

#include <dlfcn.h>

#define PID_FILE "streamon.pid"

using namespace bm;

bool signal_triggered = false;

void sig_handler(int signum)
{
	if (!signal_triggered)
	{
		std::cout<<"Stopping pool manager"<<std::endl;
		PoolManager::instance().stop();
		std::cout<<"Stopping timer thread"<<std::endl;

		TimerThread::instance().stop();

		signal_triggered = true;
	}
}

void signal_USR1( int signum )
{
    std::cout << "Interrupt signal (" << signum << ") received.\n";

    if (signum == SIGUSR1)
    {
        printf("Received SIGUSR1!\n");
    }

    std::cout << "C++ dlopen demo\n\n";

    // open the library
    std::cout << "Opening FeatureLib.so...\n";
    void* handle = dlopen("./FeatureLib.so", RTLD_LAZY);
    
    if (!handle) {
        std::cerr << "Cannot open library: " << dlerror() << '\n';
        //return 1;
    }
    
    // load the symbol
    std::cout << "Loading symbol reload...\n";
    typedef void (*reload_t)();

    // reset errors
    dlerror();
    reload_t reload = (reload_t) dlsym(handle, "reload");
    const char *dlsym_error = dlerror();
    if (dlsym_error) {
        std::cerr << "Cannot load symbol 'reload': " << dlsym_error <<
            '\n';
        dlclose(handle);
        //return 1;
    }
    
    // use it to do the calculation
    std::cout << "Calling reload...\n";
    reload();
    
    // close the library
    std::cout << "Closing library...\n";
    dlclose(handle);  
	
}


int main (int argc, char** argv)
{
    pid_t blockmon_pid;

    if(argc!=2)
        throw std::runtime_error("must specify configuration file");

    //std::cout<<"add config\n";
    CompositionManager::instance().add_config_from_file(argv[1]);
    std::cout<<"Startup completed!\n";

	struct sigaction sa;
    memset(&sa,0,sizeof(sa));
    sa.sa_handler=sig_handler;

    sigaction(SIGINT,&sa,NULL);

    // register signal SIG_USR1 and signal handler  
    signal(SIGUSR1, signal_USR1);

	PoolManager::instance().start();

	std::thread tt(std::ref(TimerThread::instance()));

    blockmon_pid = getpid();

    std::ofstream pid_file(PID_FILE);

    pid_file << blockmon_pid;

    pid_file.close();

/*
	sleep(300); // ULONG_MAX);

*/

	tt.join();

    unlink(PID_FILE);

	return (0);
}

