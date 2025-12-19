import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_course_2/services/repository/note_repository.dart';
import 'package:flutter_course_2/blocs/home/home_bloc.dart';
import 'package:flutter_course_2/constants/app_colors.dart';
import 'package:flutter_course_2/constants/app_dimensions.dart';
import 'package:flutter_course_2/widgets/custom_app_bar.dart';
import 'package:flutter_course_2/widgets/category_chip.dart';
import 'package:flutter_course_2/widgets/note_card.dart';
import 'package:flutter_course_2/widgets/empty_state.dart';
import 'package:flutter_course_2/widgets/loading_shimmer.dart';
import 'package:flutter_course_2/services/cloud/cloud_note.dart';
import 'package:flutter_course_2/constants/padge_routs.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeBloc(NoteRepository())..add(HomeLoadNotes()),
      child: const _HomeScreenView(),
    );
  }
}

class _HomeScreenView extends StatefulWidget {
  const _HomeScreenView({Key? key}) : super(key: key);

  @override
  State<_HomeScreenView> createState() => _HomeScreenViewState();
}

class _HomeScreenViewState extends State<_HomeScreenView> {
  final List<String> _categories = ['All Notes', 'Work', 'Personal', 'Study', 'Ideas'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        onSearchTap: () {
          Navigator.pushNamed(context, searchRoute);
        },
        onProfileTap: () {
          Navigator.pushNamed(context, settingsRoute);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
           Navigator.pushNamed(context, createOrUpdateNoteRoute);
        },
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading) {
            return _buildLoadingState();
          }

          if (state is HomeError) {
            return Center(child: Text('Error: ${state.message}'));
          }

          if (state is HomeLoaded) {
            return Column(
              children: [
                _buildCategoryTabs(context, state.selectedCategory),
                Expanded(
                  child: state.filteredNotes.isEmpty
                      ? EmptyState(
                          title: 'No notes found',
                          subtitle: 'Try selecting a different category or create a new note.',
                          actionLabel: 'Create Note',
                          onAction: () {
                             Navigator.pushNamed(context, createOrUpdateNoteRoute);
                          },
                        )
                      : _buildNotesList(state.filteredNotes),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: 'Saved'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
        onTap: (index) {
          switch (index) {
            case 1:
              Navigator.pushNamed(context, searchRoute);
              break;
            case 3:
              Navigator.pushNamed(context, settingsRoute);
              break;
          }
        },
      ),
    );
  }

  Widget _buildCategoryTabs(BuildContext context, String selectedCategory) {
    return Container(
      height: 60.h,
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: AppDimensions.paddingM),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          return CategoryChip(
            label: category,
            isSelected: category == selectedCategory,
            onTap: () {
              context.read<HomeBloc>().add(HomeFilterChanged(category));
            },
          );
        },
      ),
    );
  }

  Widget _buildNotesList(List<CloudNote> notes) {
    return GridView.builder(
      padding: EdgeInsets.all(AppDimensions.paddingM),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppDimensions.paddingM,
        crossAxisSpacing: AppDimensions.paddingM,
        childAspectRatio: 0.75,
      ),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return Dismissible(
          key: Key(note.documentId),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(right: 20.w),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            ),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (direction) {
            context.read<HomeBloc>().add(HomeDeleteNote(note.documentId));
          },
          child: NoteCard(
            note: note,
            onTap: () {
              Navigator.pushNamed(context, createOrUpdateNoteRoute, arguments: note);
            },
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: EdgeInsets.all(AppDimensions.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           SizedBox(height: 60.h), // Space for tabs
           Expanded(
             child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: AppDimensions.paddingM,
                crossAxisSpacing: AppDimensions.paddingM,
                childAspectRatio: 0.75,
              ),
              itemCount: 4,
              itemBuilder: (context, index) {
                return LoadingShimmer(height: 200.h, borderRadius: 16);
              },
            ),
           ),
        ],
      ),
    );
  }
}
