import DiscourseURL from 'discourse/lib/url';
import { ajax } from 'discourse/lib/ajax';

export default Ember.Component.extend({
  users: [],

  loading: true,

  loadUsers: function(){
    ajax('/dev-login/users.json', {method: 'GET'}).then(result => {
      this.set('users', result['users']);
      this.set('loading', false);
    }, () => {
      this.set('users', ['system']);
      this.set('loading', false);
    });
  }.on('init'),

  actions: {
    login(username){
      DiscourseURL.redirectTo(`/dev-login?user=${username}`);
    }
  }
});