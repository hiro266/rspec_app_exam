require 'rails_helper'

RSpec.describe 'Task', type: :system do
  let(:project) { create(:project) }
  let(:task) { create(:task, project_id: project.id) }
  let(:task_status_done) { create(:task, :status_done, project_id: project.id) }

  describe 'Task一覧' do
    context '正常系' do
      it '一覧ページにアクセスした場合、Taskが表示されること' do
        # TODO: ローカル変数ではなく let を使用してください → 修正済
        visit project_tasks_path(project)
        expect(current_path).to eq project_tasks_path(project)
        expect(page).to have_content task.title
        expect(Task.count).to eq 1
      end

      it 'Project詳細からTask一覧ページにアクセスした場合、Taskが表示されること' do
        # FIXME: テストが失敗するので修正してください → 修正済
        visit project_path(project)
        click_link 'View Todos'
        # 別タブに遷移する
        switch_to_window(windows.last)
        expect(current_path).to eq project_tasks_path(project)
        expect(page).to have_content task.title
        expect(Task.count).to eq 1
      end
    end
  end

  describe 'Task新規作成' do
    context '正常系' do
      it 'Taskが新規作成されること' do
        # TODO: ローカル変数ではなく let を使用してください → 修正済
        visit project_tasks_path(project)
        click_link 'New Task'
        fill_in 'Title', with: 'test'
        click_button 'Create Task'
        expect(current_path).to eq '/projects/1/tasks/1'
        expect(page).to have_content('Task was successfully created.')
        expect(Task.count).to eq 1
      end
    end
  end

  describe 'Task詳細' do
    context '正常系' do
      it 'Taskが表示されること' do
        # TODO: ローカル変数ではなく let を使用してください → 修正済
        visit project_task_path(project, task)
        expect(current_path).to eq project_task_path(project, task)
        expect(page).to have_content(task.title)
        expect(page).to have_content(task.status)
        expect(page).to have_content(task.deadline.strftime('%Y-%m-%d %H:%M'))
      end
    end
  end

  describe 'Task編集' do
    context '正常系' do
      it 'Taskを編集した場合、一覧画面で編集後の内容が表示されること' do
        # FIXME: テストが失敗するので修正してください → 修正済
        visit edit_project_task_path(project, task)
        # Time.current 現在の時刻
        fill_in 'Deadline', with: Time.current
        click_button 'Update Task'
        click_link 'Back'
        expect(current_path).to eq project_tasks_path(project)
        # short_timeメソッドを使用(ApplicationHelperをrails_helper.rbへinclude)
        expect(find('.task_list')).to have_content(short_time(Time.current))
      end

      it 'ステータスを完了にした場合、Taskの完了日に今日の日付が登録されること' do
        # TODO: ローカル変数ではなく let を使用してください → 修正済
        visit edit_project_task_path(project, task)
        select 'done', from: 'Status'
        click_button 'Update Task'
        expect(current_path).to eq project_task_path(project, task)
        expect(page).to have_content('done')
        expect(page).to have_content(Time.current.strftime('%Y-%m-%d'))
      end
    end

    context 'ステータス' do
      before { task_status_done }
      it '既にステータスが完了のタスクのステータスを変更した場合、Taskの完了日が更新されないこと' do
        # TODO: FactoryBotのtraitを利用してください → 修正済
        visit edit_project_task_path(project, task)
        select 'todo', from: 'Status'
        click_button 'Update Task'
        expect(current_path).to eq project_task_path(project, task)
        expect(page).to have_content('todo')
        expect(page).not_to have_content(Time.current.strftime('%Y-%m-%d'))
      end
    end
  end

  describe 'Task削除' do
    # let(:task)の呼び出し
    before { task }
    context '正常系' do
      # FIXME: テストが失敗するので修正してください 修正済
      it 'Taskが削除されること' do
        visit project_tasks_path(project)
        click_link 'Destroy'
        page.driver.browser.switch_to.alert.accept
        expect(current_path).to eq project_tasks_path(project)
        # have_content → have_no_content
        expect(page).not_to have_no_content task.title
        expect(Task.count).to eq 0
      end
    end
  end
end
