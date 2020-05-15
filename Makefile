CXX = mpicxx

# use -xmic-avx512 instead of -xHost for Intel Xeon Phi platforms

#OPTFLAGS = -O3 -xHost -qopenmp -DCHECK_NUM_EDGES #-DPRINT_EXTRA_NEDGES #-DPRINT_DIST_STATS #-DUSE_MPI_RMA -DUSE_MPI_ACCUMULATE #-DUSE_32_BIT_GRAPH #-DDEBUG_PRINTF #-DUSE_MPI_RMA #-DPRINT_LCG_DOUBLE_LOHI_RANDOM_NUMBERS#-DUSE_MPI_RMA #-DPRINT_LCG_DOUBLE_RANDOM_NUMBERS #-DPRINT_RANDOM_XY_COORD
#-DUSE_MPI_SENDRECV
#-DUSE_MPI_COLLECTIVES
# use export ASAN_OPTIONS=verbosity=1 to check ASAN output

MYINFO = -DDEBUG_PRINTF -DPRINT_DIST_STATS

OPTFLAGS = -O3 -fopenmp \
	-DCHECK_NUM_EDGES \
	-I$(HOME)/pkg/tessil-lib/include \
	$(MYINFO) -DDEBUG_CLMAP=1

LNFLAGS = -static-libgcc -static-libstdc++

# -fopenmp

 #-DPRINT_EXTRA_NEDGES #-DPRINT_DIST_STATS #-DUSE_MPI_RMA -DUSE_MPI_ACCUMULATE #-DUSE_32_BIT_GRAPH #-DDEBUG_PRINTF #-DUSE_MPI_RMA #-DPRINT_LCG_DOUBLE_LOHI_RANDOM_NUMBERS#-DUSE_MPI_RMA #-DPRINT_LCG_DOUBLE_RANDOM_NUMBERS #-DPRINT_RANDOM_XY_COORD

#SNTFLAGS = -std=c++11 -fopenmp -fsanitize=address -O1 -fno-omit-frame-pointer

CXXFLAGS = -std=c++11 -g $(OPTFLAGS)

TARGET = miniVite

TARGET_VERSIONS = v1 v2 v3 v4

TARGET_L = $(addprefix $(TARGET)-,$(TARGET_VERSIONS))


all: $(TARGET_L)

#OBJ = main.o

#%.o: %.cpp
#	$(CXX) $(CXXFLAGS) -c -o $@ $^

#$(TARGET):  $(OBJ)
#	$(CXX) $^ $(OPTFLAGS) $(LNFLAGS) -o $@


$(TARGET_L) : $(TARGET)-%: main.cpp
	$(CXX) -D DSPL_VERSION=\"dspl-$(*F).hpp\" $(OPTFLAGS) $(LNFLAGS) -o $@ $^
#	$(CXX) -D VERSION=$(*F) $(OPTFLAGS) $(LNFLAGS) -o $@ $^


.PHONY: clean

clean:
	rm -rf *~ $(OBJ) $(TARGET_L)
